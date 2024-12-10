codeunit 50051 "Regenerate loan repayment sch"
{
    trigger OnRun()
    begin
        // FnAutoCorrectWrongInterestPostings();
        //FnRegenerateNewSchedule();
    end;

    var
        LoansReg: Record "Loans Register";
        LoanRepaymentSchedule: Record "Loan Repayment Schedule";
        LoanProductSetUp: Record "Loan Products Setup";
        SFactoryCode: Codeunit "SURESTEP Factory";
        LoansTotal: Integer;
        Reached: integer;
        PercentageDone: Decimal;
        DialogBox: Dialog;
        GenJournalLine: Record "Gen. Journal Line";
        GenBatches: Record "Gen. Journal Batch";
        LineNo: Integer;
        LoansRegister: Record "Loans Register";
        LoanType: Record "Loan Products Setup";
        DocNo: text;

    procedure FnRegenerateNewSchedule()
    begin
        LoansReg.Reset;
        LoansReg.SetRange(LoansReg.Posted, true);
        LoansReg.SetRange(LoansReg.Source, LoansReg.Source::FOSA);
        LoansReg.SetAutocalcFields(LoansReg."Outstanding Balance", LoansReg."Total Loan Issued", LoansReg."Last Loan Issue Date");
        if LoansReg.Find('-') then begin
            //.............Count No of loans()
            LoansTotal := 0;
            LoansTotal := LoansReg.Count();
            Reached := 0;
            PercentageDone := 0;
            repeat
                Reached := Reached + 1;
                PercentageDone := (Reached / LoansTotal) * 100;
                DialogBox.Open('Processing ' + Format(Reached) + ' of ' + Format(LoansTotal) + ': Percentage= ' + Format(Round(PercentageDone)));
                //........................Ensure all Loan Have Loan Disbursment Date
                if (LoansReg.Repayment = 0) and (LoansReg."Loan Product Type" = 'OVERDRAFT') then begin
                    LoansReg.Repayment := LoansReg."Approved Amount" / 2;
                    LoansReg.Installments := 2;
                    LoansReg."Main-Sector" := '1000';
                    LoansReg."Specific-Sector" := '1110';
                    LoansReg."Sub-Sector" := '1100';
                    LoansReg."Loan Disbursement Date" := LoansReg."Application Date";
                    LoansReg.Modify();
                end;
                if (LoansReg."Loan Disbursement Date" = 0D) and (LoansReg."Issued Date" <> 0D) then begin
                    LoansReg."Loan Disbursement Date" := LoansReg."Issued Date";
                    LoansReg.Modify();
                end;

                LoansReg."Repayment Frequency" := LoansReg."Repayment Frequency"::Monthly;
                LoansReg.Modify();
                //...........................................................
                if (LoansReg."Loan Disbursement Date" = 0D) and (LoansReg."Issued Date" = 0D) then begin
                    LoansReg."Loan Disbursement Date" := FnCheckTheFirstLoanEntry(LoansReg."Loan  No.");
                    LoansReg.Modify();
                end;
                if LoansReg."Last Loan Issue Date" <> 0D then begin
                    LoansReg."Loan Disbursement Date" := LoansReg."Last Loan Issue Date";
                    LoansReg.Modify();
                end;
                if LoansReg."Loan  No." = 'LN007754' then begin
                    LoansReg."Loan Disbursement Date" := 20230301D;
                    LoansReg.Modify();
                end;
                //......................Loan Repayment Start Date
                LoansReg."Repayment Start Date" := CalcDate('30D', LoansReg."Loan Disbursement Date");
                LoansReg.Modify();
                //......................Get the loan Expected Completion Date
                //1.Check if Installemts Is Provided
                if (LoansReg.Installments = 0) then begin
                    LoansReg.Installments := FnGetLoanInstallements(LoansReg."Loan Product Type");
                    LoansReg.Modify();
                end;
                if (LoansReg."Approved Amount" <> 0) and (LoansReg."Loan Principle Repayment" <> 0) then begin
                    LoansReg.Installments := Round(LoansReg."Approved Amount" / LoansReg."Loan Principle Repayment", 1, '>');
                    LoansReg.Modify();
                end;
                LoansReg."Expected Date of Completion" := CalcDate(format(LoansReg.Installments) + 'M', LoansReg."Repayment Start Date");
                LoansReg.Modify();
                //..................Ensure loans have approved amount
                if (LoansReg."Approved Amount" = 0) AND (LoansReg."Loan Disbursed Amount" <> 0) THEN begin
                    LoansReg."Approved Amount" := LoansReg."Loan Disbursed Amount";
                    LoansReg.Modify();
                end;

                if (LoansReg."Approved Amount" = 0) AND (LoansReg."Loan Disbursed Amount" = 0) THEN begin
                    LoansReg."Approved Amount" := LoansReg."Outstanding Balance";
                    LoansReg.Modify();
                end;
                // LoansReg."Approved Amount" := LoansReg."Total Loan Issued";
                // LoansReg.Modify();
                //.....................Ensure all loans have Interest Rate
                if LoansReg.interest = 0 then begin
                    LoansReg.Interest := FnGetLoanInterestRate(LoansReg."Loan Product Type");
                    LoansReg.Modify();
                end;
                //....................Also Check On Monthly Loan Interest//To Repair CEEP loans
                if LoansReg.Source = LoansReg.Source::MICRO then begin
                    LoansReg."Repayment Method" := LoansReg."Repayment Method"::Constants;
                    //............Ensure Monthly Principle repayment and Monthly Interest Repayment is set for CEEP
                    LoansReg."Loan Principle Repayment" := LoansReg."Approved Amount" / LoansReg.Installments;
                    LoansReg.Repayment := LoansReg."Loan Principle Repayment";
                    LoansReg."Loan Interest Repayment" := Round(((LoansReg.Interest / 100) * LoansReg.Installments / 12) * LoansReg."Approved Amount", 1, '>');
                    LoansReg.Modify();
                end;
                if LoansReg."Client Name" = '' then begin
                    LoansReg."Client Name" := FnGetMemberName(LoansReg."Client Code");
                    LoansReg.Modify();
                end;
                if LoansReg."Repayment Frequency" <> LoansReg."Repayment Frequency"::Monthly then begin
                    LoansReg."Repayment Frequency" := LoansReg."Repayment Frequency"::Monthly;
                    LoansReg.Modify();
                end;
                //..........................................Update Loan Dates
                IF (LoansReg."Loan Product Type" = 'CHRISTMAS ADV') OR (LoansReg."Loan Product Type" = 'DIVIDEND') OR (LoansReg."Loan Product Type" = 'LPO') THEN begin
                    if (LoansReg."Loan Product Type" = 'CHRISTMAS ADV') OR (LoansReg."Loan Product Type" = 'DIVIDEND') then begin
                        IF CalcDate('12M', LoansReg."Loan Disbursement Date") >= Today then begin
                            IF LoansReg."Expected Date of Completion" <> CalcDate('12M', LoansReg."Loan Disbursement Date") then begin
                                LoansReg."Expected Date of Completion" := CalcDate('12M', LoansReg."Loan Disbursement Date");
                                LoansReg."Repayment Start Date" := CalcDate('12M', LoansReg."Loan Disbursement Date");
                                LoansReg.Modify();
                            end;
                        end;
                    end else
                        if (LoansReg."Loan Product Type" = 'LPO') then begin
                            IF LoansReg."Expected Date of Completion" <> CalcDate('6M', LoansReg."Loan Disbursement Date") then begin
                                LoansReg."Expected Date of Completion" := CalcDate('6M', LoansReg."Loan Disbursement Date");
                                LoansReg."Repayment Start Date" := CalcDate('6M', LoansReg."Loan Disbursement Date");
                                LoansReg.Modify();
                            end;
                        end;
                end;
                if (LoansReg."Loan Product Type" = 'OVERDRAFT') then begin
                    LoansReg."Loan Interest Repayment" := LoansReg."Loan Interest Repayment" * LoansReg.Installments;
                    LoansReg.Modify();
                end;
                //....................Now Regenerate Loan Repayment Schedule
                SFactoryCode.FnGenerateRepaymentSchedule(LoansReg."Loan  No.");
            until LoansReg.Next = 0;
        end;
        Message('Done');
    end;

    local procedure FnCheckTheFirstLoanEntry(LoanNo: Code[30]): Date
    var
        CustLedgerEntry: record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange(CustLedgerEntry."Loan No", LoanNo);
        if CustLedgerEntry.FindFirst() then begin
            exit(CustLedgerEntry."Posting Date");
        end;
        exit(20180101D);
    end;

    local procedure FnGetLoanInstallements(LoanType: Code[30]): Integer
    begin
        LoanProductSetUp.Reset();
        LoanProductSetUp.SetRange(LoanProductSetUp.Code, LoanType);
        if LoanProductSetUp.Find('-') then begin
            if LoanProductSetUp."No of Installment" <> 0 then begin
                exit(LoanProductSetUp."No of Installment");
            end ELSE
                IF (LoanProductSetUp."No of Installment" = 0) AND (LoanProductSetUp."Default Installements" <> 0) then begin
                    exit(LoanProductSetUp."Default Installements");
                end;
        end;
        exit(12);
    end;

    local procedure FnGetLoanInterestRate(LoanProductType: Code[20]): Decimal
    begin
        LoanProductSetUp.reset();
        LoanProductSetUp.setrange(LoanProductSetUp.Code, LoanProductType);
        if LoanProductSetUp.Find('-') then begin
            if LoanProductSetUp."Interest rate" <> 0 then begin
                exit(LoanProductSetUp."Interest rate");
            end;
        end;
        exit(12);
    end;

    local procedure FnGetMemberName(ClientCode: Code[50]): Text[80]
    var
        cust: record Customer;
    begin
        cust.reset;
        cust.SetRange(cust."No.", ClientCode);
        if cust.Find('-') then begin
            exit(cust.Name);
        end;
        exit('');
    end;

    local procedure FnAutoCorrectWrongInterestPostings()
    var
        LoansRegisterTable: record "Loans Register";
    begin
        FnInitiateGLs();
        LoansRegisterTable.Reset();
        LoansRegisterTable.SetRange(LoansRegisterTable.Source, LoansRegisterTable.Source::MICRO);
        LoansRegisterTable.SetAutoCalcFields(LoansRegisterTable."Outstanding Balance", LoansRegisterTable."Oustanding Interest");
        LoansRegisterTable.SetFilter(LoansRegisterTable."Outstanding Balance", '>%1', 0);
        LoansRegisterTable.SetFilter(LoansRegisterTable."Oustanding Interest", '<%1', 0);
        if LoansRegisterTable.find('-') then begin
            repeat
                FnInsertGlEntries(LoansRegisterTable."Loan  No.", LoansRegisterTable."Client Code", (LoansRegisterTable."Oustanding Interest") * -1, LoansRegisterTable."Outstanding Balance")
            until LoansRegisterTable.Next = 0;
        end;
    end;

    local procedure FnInitiateGLs()
    begin
        //delete journal line
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'General');
        GenJournalLine.SETRANGE("Journal Batch Name", 'TRANSFER');
        GenJournalLine.DELETEALL;
        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'General');
        GenBatches.SETRANGE(GenBatches.Name, 'TRANSFER');
        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'General';
            GenBatches.Name := 'TRANSFER';
            GenBatches.Description := 'Interest correction';
            GenBatches.INSERT;
        END;
    end;

    local procedure FnInsertGlEntries(LoanNo: Code[30]; ClientCode: Code[50]; OutstandingInterest: Decimal; OutstandingBalance: Decimal)
    begin
        LineNo := LineNo + 10000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name" := 'General';
        GenJournalLine."Journal Batch Name" := 'TRANSFER';
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := ClientCode;
        GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Due";
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Document No." := 'TRANSFER';
        GenJournalLine."Posting Date" := 20230831D;
        GenJournalLine.Description := 'Excess Interest posted transferred to pay loan principle';
        IF OutstandingInterest > OutstandingBalance then begin
            GenJournalLine.Amount := OutstandingBalance;
        end else
            IF OutstandingInterest <= OutstandingBalance then begin
                GenJournalLine.Amount := OutstandingInterest;
            end;
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := 'MICRO';
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoansRegister."Client Code");
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."Loan No" := LoanNo;
        IF (GenJournalLine.Amount <> 0) THEN
            GenJournalLine.INSERT;
        //...............Cr Principal
        LineNo := LineNo + 10000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name" := 'General';
        GenJournalLine."Journal Batch Name" := 'TRANSFER';
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := ClientCode;
        GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Repayment;
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Document No." := 'TRANSFER';
        GenJournalLine."Posting Date" := 20230831D;
        GenJournalLine.Description := 'loan principle paid';
        IF OutstandingInterest > OutstandingBalance then begin
            GenJournalLine.Amount := -(OutstandingBalance);
        end else
            IF OutstandingInterest <= OutstandingBalance then begin
                GenJournalLine.Amount := -(OutstandingInterest);
            end;
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := 'MICRO';
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoansRegister."Client Code");
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."Loan No" := LoanNo;
        IF (GenJournalLine.Amount <> 0) THEN
            GenJournalLine.INSERT;
    end;

    local procedure FnGetMemberBranch(ClientCode: Code[50]): Code[20]
    var
        Cust: Record Customer;
    begin
        Cust.RESET;
        Cust.SETRANGE(Cust."No.", ClientCode);
        IF Cust.FIND('-') THEN BEGIN
            EXIT(Cust."Global Dimension 2 Code");
        END;
    end;

    local procedure FnMemberIsStaff(ClientCode: Code[50]): Boolean
    var
        Vendor: Record Vendor;
    begin
        Vendor.Reset();
        Vendor.SetRange(Vendor."BOSA Account No", ClientCode);
        if Vendor.Find('-') then begin
            // if (Vendor."Company Code" = 'MMH') OR (Vendor."Company Code" = 'MMHSACCO') THEN begin
            //     exit(true);
            // end;
        end;
        exit(false);
    end;


}
