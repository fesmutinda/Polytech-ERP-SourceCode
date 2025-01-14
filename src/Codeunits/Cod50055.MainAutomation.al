codeunit 50055 "Main Automation"
{
    trigger OnRun()
    var
        CustLedgerEntry: record "Cust. Ledger Entry";
        IsRun: Boolean;
    begin

        //FnInsertMissingOverdraftLoans();
        FnRunAllAutomations();
        Message('Done');
    end;

    local procedure FnRunAllAutomations()
    var
    begin
        msg := 'STARTED Main Automation At ' + Format(time);
        //SurestepFactory.FnSendSMS('MOBILETRAN', msg, '', '0741194089');
        //...............2)Run Monthly FOSA Interests
        /* SaccoGenSetUp.get();
        if (Today = CalcDate('CM', Today)) and (SaccoGenSetUp."Date For FOSA Interest Run" <> Today) then begin
            GenerateMonthlyFOSAInterest.FnGenerateFOSAInterest();
            SaccoGenSetUp."Date For FOSA Interest Run" := Today;
            SaccoGenSetUp.Modify();
        end; */
        //...............3)Charge FOSA Account Maintainance
        /* if (Today = CalcDate('CM', Today)) and (SaccoGenSetUp."Date For FOSA Maintanance Run" <> Today) then begin
            ChargeMonthlyAccountMaintainance.FnInitiateGLs();
            ChargeMonthlyAccountMaintainance.FnInitiateGLs();
            ChargeMonthlyAccountMaintainance.FnChargeFOSAAccountMaintainance();
            ChargeMonthlyAccountMaintainance.FnAutoPostGls();
            SaccoGenSetUp."Date For FOSA Maintanance Run" := Today;
            SaccoGenSetUp.Modify();
        end; */
        //...............4)Run Loan Interest Due for loans and post
        if (SaccoGenSetUp."Last Loan Interest Run Date" <> Today) and (Today <> 20230920D) then begin
            //FOSA & BOSA Loans
            GenerateLoanInterestDue.FnInitiateGLs();
            //GenerateLoanInterestDue.FnGenerateFOSALoansInterest();
            GenerateLoanInterestDue.FnGenerateBOSALoansInterest();
            GenerateLoanInterestDue.FnAutoPostGls();
            //MICRO Loans
            // if Today = DMY2DATE(01, DATE2DMY(Today, 2), DATE2DMY(Today, 3)) then begin
            //     GenerateLoanInterestDue.FnInitiateGLs();
            //     //GenerateLoanInterestDue.FnGenerateMICROLoansInterest();
            //     GenerateLoanInterestDue.FnAutoPostGls();
            // end;
            SaccoGenSetUp."Last Loan Interest Run Date" := Today;
            SaccoGenSetUp.Modify();
        end;
        // //...............5)Incase there are loans missing loan type in Customer ledger Entry,correct
        //UpdateCustLedgeEntryLoanType.FnUpdateLoanProductType();
        //..................6)Update Loan Category-SASRA & Arrears
        //GenerateLoanSchedule.FnRegenerateNewSchedule();
        SASRALoanClassification.FnResetLoanStatus();//Reset Loan SASRA Status
        SASRALoanClassification.FnUpdateLoanStatus();//Update Loan Status
        //...............7)Recover Loans
        //LoanRecoverys.FnRecoverLoanArrears();
        //SASRALoanClassification.FnResetLoanStatus();//Reset Loan SASRA Status
        //SASRALoanClassification.FnUpdateLoanStatus();//Update Loan Status
        //...............8)Send Member Notification SMS
        //SendLoanNotifications.FnSendLoanReminderNotifications();
        //...............9)Generate End Of Period Neccessary Documents()
        msg := 'Ended Main Automation At ' + Format(time);
        //SurestepFactory.FnSendSMS('MOBILETRAN', msg, '', '0741194089');
        Message('Done');
    end;

    local procedure FnInsertMissingOverdraftLoans()
    var
        VendorTable: record Vendor;
        LoanNo: Code[20];
        LoanTable: Record "Loans Register";
        PostedInterest: Decimal;
        LoanPostingDate: Date;
        LoansTotal: Integer;
        Reached: integer;
        PercentageDone: Decimal;
        DialogBox: Dialog;
    begin
        PostedInterest := 0;
        LoanTable.Reset();
        LoanTable.SetRange(LoanTable.Posted, true);
        LoanTable.SetFilter(LoanTable."Loan Product Type", '%1', 'OVERDRAFT');
        LoanTable.SetAutoCalcFields(LoanTable."Oustanding Interest");
        IF LoanTable.Find('-') THEN begin
            LoansTotal := 0;
            LoansTotal := LoanTable.Count();
            Reached := 0;
            PercentageDone := 0;
            repeat
                Reached := Reached + 1;
                PercentageDone := (Reached / LoansTotal) * 100;
                DialogBox.Open('Processing ' + Format(Reached) + ' of ' + Format(LoansTotal) + ': Percentage= ' + Format(Round(PercentageDone)));
                //........................Ensure all Loan Have Loan Disbursment Date

                PostedInterest := 0;
                PostedInterest := FnGetPostedInterest(LoanTable."Loan  No.", LoanTable."Client Code");
                if PostedInterest > 0 then begin
                    //..........Loan Interest Rate
                    if LoanTable.Installments = 1 then begin
                        LoanTable.Interest := 10;
                    end;
                    if LoanTable.Installments = 2 then begin
                        LoanTable.Interest := 15;
                    end;
                    if LoanTable.Installments = 3 then begin
                        LoanTable.Interest := 15;
                    end;
                    if LoanTable."Overdraft Installements" = LoanTable."Overdraft Installements"::Loan then begin
                        LoanTable.Interest := 5;
                    end;
                    LoanTable."Loan Interest Repayment" := (PostedInterest / LoanTable.Installments);
                end;
                //....................Update Repayment Date
                LoanPostingDate := 0D;
                LoanPostingDate := FnGetPostedLoan(LoanTable."Loan  No.", LoanTable."Client Code");
                if LoanPostingDate <> 0D then begin
                    LoanTable."Loan Disbursement Date" := LoanPostingDate;
                    LoanTable."Repayment Start Date" := CalcDate('1M', LoanPostingDate);
                    LoanTable."Expected Date of Completion" := CalcDate(FORMAT(LoanTable.Installments) + 'M', LoanTable."Repayment Start Date");
                end;
                LoanTable.Modify();
            UNTIL LoanTable.Next = 0;
        end;
    end;
    //.......................................................................................................
    local procedure FnGetPostedInterest(LoanNo: Code[30]; ClientCode: Code[50]): Decimal
    var
        LedgerEntry: Record "Cust. Ledger Entry";
    begin
        LedgerEntry.Reset();
        LedgerEntry.SetRange(LedgerEntry."Customer No.", ClientCode);
        LedgerEntry.SetRange(LedgerEntry."Loan No", LoanNo);
        LedgerEntry.SetAutoCalcFields(LedgerEntry.Amount);
        LedgerEntry.SetRange(LedgerEntry."Transaction Type", LedgerEntry."Transaction Type"::"Interest Due");
        if LedgerEntry.FindLast() then begin
            exit(LedgerEntry.Amount);
        end;
    end;

    local procedure FnGetPostedLoan(LoanNo: Code[30]; ClientCode: Code[50]): Date
    var
        LedgerEntry: Record "Cust. Ledger Entry";
    begin
        LedgerEntry.Reset();
        LedgerEntry.SetRange(LedgerEntry."Customer No.", ClientCode);
        LedgerEntry.SetRange(LedgerEntry."Loan No", LoanNo);
        LedgerEntry.SetRange(LedgerEntry."Transaction Type", LedgerEntry."Transaction Type"::Loan);
        if LedgerEntry.FindLast() then begin
            exit(LedgerEntry."Posting Date");
        end;
    end;

    var

        SaccoGenSetUp: record "Sacco General Set-Up";
        // GenerateMonthlyFOSAInterest: Codeunit "Generate Monthly FOSA Interest";
        // ChargeMonthlyAccountMaintainance: Codeunit "Charge FOSA Account Maintain";
        GenerateLoanInterestDue: Codeunit GenerateLoanInterestDue;
        //UpdateCustLedgeEntryLoanType: Codeunit "Update CustLedgeEntryLoanType";
        // SendLoanNotifications: Codeunit "Send Loan Notifications";
        GenerateLoanSchedule: Codeunit "Regenerate loan repayment sch";
        SASRALoanClassification: Codeunit "Live SASRA Loan Classification";
        msg: Text;
        SurestepFactory: Codeunit "SURESTEP Factory";

}
