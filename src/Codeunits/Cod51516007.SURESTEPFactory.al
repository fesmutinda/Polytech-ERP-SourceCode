#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51516007 "Swizzsoft Factory"
{

    trigger OnRun()
    begin

    end;

    var
        ObjTransCharges: Record "Transaction Charges";
        UserSetup: Record "User Setup";
        ObjVendor: Record Vendor;
        ObjProducts: Record "Account Types-Saving Products";
        ObjMemberLedgerEntry: Record "Cust. Ledger Entry";
        ObjLoans: Record "Loans Register";
        ObjBanks: Record "Bank Account";
        ObjLoanProductSetup: Record "Loan Products Setup";
        ObjProductCharges: Record "Loan Product Charges";
        ObjMembers: Record Customer;
        ObjMembers2: Record Customer;
        ObjGenSetUp: Record "Sacco General Set-Up";
        ObjCompInfo: Record "Company Information";
        BAND1: Decimal;
        BAND2: Decimal;
        BAND3: Decimal;
        BAND4: Decimal;
        BAND5: Decimal;


    procedure FnGetCashierTransactionBudding(TransactionType: Code[100]; TransAmount: Decimal) TCharge: Decimal
    begin
        ObjTransCharges.Reset;
        ObjTransCharges.SetRange(ObjTransCharges."Transaction Type", TransactionType);
        ObjTransCharges.SetFilter(ObjTransCharges."Minimum Amount", '<=%1', TransAmount);
        ObjTransCharges.SetFilter(ObjTransCharges."Maximum Amount", '>=%1', TransAmount);
        TCharge := 0;
        if ObjTransCharges.FindSet then begin
            repeat
                TCharge := TCharge + ObjTransCharges."Charge Amount" + ObjTransCharges."Charge Amount" * 0.1;
            until ObjTransCharges.Next = 0;
        end;
    end;


    procedure FnGetUserBranch() branchCode: Code[20]
    begin
        UserSetup.Reset;
        UserSetup.SetRange(UserSetup."User ID", UserId);
        if UserSetup.Find('-') then begin
            branchCode := UserSetup."Branch Code";
        end;
        exit(branchCode);
    end;

    procedure FnSendSMS(SMSSource: Text; SMSBody: Text; CurrentAccountNo: Text; MobileNumber: Text)
    var
        SMSMessage: Record "SMS Messages";
        iEntryNo: Integer;
    begin
        ObjGenSetUp.Get;
        ObjCompInfo.Get;

        SMSMessage.Reset;
        if SMSMessage.Find('+') then begin
            iEntryNo := SMSMessage."Entry No";
            iEntryNo := iEntryNo + 1;
        end
        else begin
            iEntryNo := 1;
        end;


        SMSMessage.Init;
        SMSMessage."Entry No" := iEntryNo;
        SMSMessage."Batch No" := CurrentAccountNo;
        SMSMessage."Document No" := '';
        SMSMessage."Account No" := CurrentAccountNo;
        SMSMessage."Date Entered" := Today;
        SMSMessage."Time Entered" := CurrentDateTime;
        SMSMessage.Source := SMSSource;
        SMSMessage."Entered By" := UserId;
        SMSMessage."Sent To Server" := SMSMessage."Sent To Server"::PENDING;
        SMSMessage."SMS Message" := SMSBody;
        SMSMessage."Telephone No" := MobileNumber;
        if ((MobileNumber <> '') and (SMSBody <> '')) then
            SMSMessage.Insert;
    end;

    procedure FnCreateMembershipWithdrawalApplication(MemberNo: Code[20]; ApplicationDate: Date; Reason: Option Relocation,"Financial Constraints","House/Group Challages","Join another Institution","Personal Reasons",Other; ClosureDate: Date)
    var
        DateExp: Text[30];
        ObjNoSeries: Record "No. Series Line";
        ObjSalesSetup: Record "Sacco No. Series";
        ObjNoSeriesManagement: Codeunit NoSeriesManagement;
        ObjNextNo: Code[20];
        PostingDate: Date;
        ObjMembershipWithdrawal: Record "Membership Exist";

    begin
        DateExp := '<60D>';
        ObjGenSetUp.Get();
        //DateExp:=ObjGenSetUp."Withdrawal Period";

        PostingDate := WorkDate;
        ObjSalesSetup.GET;
        ApplicationDate := today;
        ObjSalesSetup.TestField(ObjSalesSetup."Closure  Nos");
        ObjNextNo := ObjNoSeriesManagement.TryGetNextNo(ObjSalesSetup."Closure  Nos", PostingDate);
        ObjNoSeries.RESET;
        ObjNoSeries.SETRANGE(ObjNoSeries."Series Code", ObjSalesSetup."Closure  Nos");
        IF ObjNoSeries.FINDSET THEN BEGIN
            ObjNoSeries."Last No. Used" := INCSTR(ObjNoSeries."Last No. Used");
            ObjNoSeries."Last Date Used" := TODAY;
            ObjNoSeries.MODIFY;
        END;
        ClosureDate := CalcDate(DateExp, ApplicationDate);

        ObjMembershipWithdrawal.INIT;
        ObjMembershipWithdrawal."No." := ObjNextNo;
        ObjMembershipWithdrawal."Member No." := MemberNo;
        ObjMembershipWithdrawal."Withdrawal Application Date" := ApplicationDate;
        ObjMembershipWithdrawal."Notice Date" := ApplicationDate;
        ObjMembershipWithdrawal."Closing Date" := ClosureDate;
        ObjMembershipWithdrawal."Reason For Withdrawal" := Reason;
        ObjMembershipWithdrawal.INSERT;

        ObjMembershipWithdrawal.VALIDATE(ObjMembershipWithdrawal."Member No.");
        ObjMembershipWithdrawal.MODIFY;

        if ObjMembers.Get(MemberNo) then begin
            ObjMembers.Status := ObjMembers.Status::"Pending Withdrawal";
            ObjMembers."Status - Withdrawal App." := ObjMembers."Status - Withdrawal App."::"Being Processed";
            ObjMembers.Modify;
        end;

        message('The Member has been marked as awaiting exit.');
    end;

    procedure FnCreateGnlJournalLine(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; TransactionType: Enum TransactionTypesEnum; AccountType: enum "Gen. Journal Account Type"; AccountNo: Code[50]; TransactionDate: Date; TransactionAmount: Decimal; DimensionActivity: Code[40]; ExternalDocumentNo: Code[50]; TransactionDescription: Text; LoanNumber: Code[50]; FosaTransType: Option " ",CashWithdrawal,CashDeposit,ChequeDeposit,CashWithdrawalCommission,ChequeDepositComission,InternalTransfers,BOSALoanPayment,BOSAPayout,LoansIssued,ATMTransactions,ATMCharges,StandingOrders,ExciseDuty,StampDuty,POSTransactions,POSTransactionCharges,MobileTransactions,MobileTransactionCharges,BankersCheques,BankersChequeCommission,SalaryProcessing,SalaryProcessingFee,SMS,ChequeWithdrawal,ChequeWithdrawalCommission,LoanOffsets,RegistrationFee,Receipts,PensionProcessing,PensionProcessingFee,FOSACardFee,ATMReplacement)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine."Transaction Type" := TransactionType;
        GenJournalLine."Loan No" := LoanNumber;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."Posting Date" := TransactionDate;
        GenJournalLine.Description := TransactionDescription;
        GenJournalLine.Validate(GenJournalLine."Currency Code");
        GenJournalLine.Amount := TransactionAmount;
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := DimensionActivity;
        GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
    end;


    procedure FnGetFosaAccountBalance(Acc: Code[30]) Bal: Decimal
    begin
        if ObjVendor.Get(Acc) then begin
            ObjVendor.CalcFields(ObjVendor."Balance (LCY)", ObjVendor."ATM Transactions", ObjVendor."Mobile Transactions", ObjVendor."Uncleared Cheques");
            Bal := ObjVendor."Balance (LCY)" - (ObjVendor."ATM Transactions" + ObjVendor."Mobile Transactions" + FnGetMinimumAllowedBalance(ObjVendor."Account Type"));
        end
    end;

    local procedure FnGetMinimumAllowedBalance(ProductCode: Code[60]) MinimumBalance: Decimal
    begin
        ObjProducts.Reset;
        ObjProducts.SetRange(ObjProducts.Code, ProductCode);
        if ObjProducts.Find('-') then
            MinimumBalance := ObjProducts."Minimum Balance";
    end;

    local procedure FnGetMemberLoanBalance(LoanNo: Code[50]; DateFilter: Date; TotalBalance: Decimal)
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Loan  No.", LoanNo);
        ObjLoans.SetFilter(ObjLoans."Date filter", '..%1', DateFilter);
        if ObjMemberLedgerEntry.FindSet then begin
            TotalBalance := TotalBalance + ObjMemberLedgerEntry."Amount (LCY)";
        end;
    end;


    procedure FnGetTellerTillNo() TellerTillNo: Code[40]
    begin
        ObjBanks.Reset;
        ObjBanks.SetRange(ObjBanks."Account Type", ObjBanks."account type"::Cashier);
        ObjBanks.SetRange(ObjBanks.CashierID, UserId);
        if ObjBanks.Find('-') then begin
            TellerTillNo := ObjBanks."No.";
        end;
        exit(TellerTillNo);
    end;


    procedure FnGetMpesaAccount() TellerTillNo: Code[40]
    begin
        // ObjBanks.Reset;
        // ObjBanks.SetRange(ObjBanks."Account Type",ObjBanks."account type"::"3");
        // ObjBanks.SetRange(ObjBanks."Bank Account Branch",FnGetUserBranch());
        // if ObjBanks.Find('-') then begin
        // TellerTillNo:=ObjBanks."No.";
        // end;
        Error('FnGetMpesaAccount');
        exit(TellerTillNo);
    end;


    procedure FnGetChargeFee(ProductCode: Code[50]; MemberCategory: Option Single,Joint,Corporate,Group,Parish,Church,"Church Department",Staff; InsuredAmount: Decimal; ChargeType: Code[100]) FCharged: Decimal
    begin
        if ObjLoanProductSetup.Get(ProductCode) then begin
            ObjProductCharges.Reset;
            ObjProductCharges.SetRange(ObjProductCharges."Product Code", ProductCode);
            ObjProductCharges.SetRange(ObjProductCharges.Code, ChargeType);
            if ObjProductCharges.Find('-') then begin
                if ObjProductCharges."Use Perc" = true then begin
                    FCharged := InsuredAmount * (ObjProductCharges.Percentage / 100);
                end
                else
                    FCharged := ObjProductCharges.Amount;
            end;
        end;
        exit(FCharged);
    end;


    procedure FnGetChargeAccount(ProductCode: Code[50]; MemberCategory: Option Single,Joint,Corporate,Group,Parish,Church,"Church Department",Staff; ChargeType: Code[100]) ChargeGLAccount: Code[50]
    begin
        if ObjLoanProductSetup.Get(ProductCode) then begin
            ObjProductCharges.Reset;
            ObjProductCharges.SetRange(ObjProductCharges."Product Code", ProductCode);
            ObjProductCharges.SetRange(ObjProductCharges.Code, ChargeType);
            if ObjProductCharges.Find('-') then begin
                ChargeGLAccount := ObjProductCharges."G/L Account";
            end;
        end;
        exit(ChargeGLAccount);
    end;

    local procedure FnUpdateMonthlyContributions()
    begin
        ObjMembers.Reset;
        ObjMembers.SetCurrentkey(ObjMembers."No.");
        ObjMembers.SetRange(ObjMembers."Monthly Contribution", 0.0);
        if ObjMembers.FindSet then begin
            repeat
                ObjMembers2."Monthly Contribution" := 500;
                ObjMembers2.Modify;
            until ObjMembers.Next = 0;
            Message('Succesfully done');
        end;


    end;


    procedure FnGetUserBranchB(varUserId: Code[100]) branchCode: Code[20]
    begin
        UserSetup.Reset;
        UserSetup.SetRange(UserSetup."User ID", varUserId);
        if UserSetup.Find('-') then begin
            branchCode := UserSetup."Branch Code";
        end;
        exit(branchCode);
    end;


    procedure FnGetMemberBranch(MemberNo: Code[100]) MemberBranch: Code[100]
    var
        ObjMemberLocal: Record Customer;
    begin
        ObjMemberLocal.Reset;
        ObjMemberLocal.SetRange(ObjMemberLocal."No.", MemberNo);
        if ObjMemberLocal.Find('-') then begin
            MemberBranch := ObjMemberLocal."Global Dimension 2 Code";
        end;
        exit(MemberBranch);
    end;

    local procedure FnReturnRetirementDate(MemberNo: Code[50]): Date
    var
        ObjMembers: Record Customer;
    begin
        ObjGenSetUp.Get();
        ObjMembers.Reset;
        ObjMembers.SetRange(ObjMembers."No.", MemberNo);
        if ObjMembers.Find('-') then
            Message(Format(CalcDate(ObjGenSetUp."Retirement Age", ObjMembers."Date of Birth")));
        exit(CalcDate(ObjGenSetUp."Retirement Age", ObjMembers."Date of Birth"));
    end;


    procedure FnGetTransferFee(DisbursementMode: Option " ",Cheque,"Bank Transfer",EFT,RTGS,"Cheque NonMember"): Decimal
    var
        TransferFee: Decimal;
    begin
        ObjGenSetUp.Get();
        case DisbursementMode of
            Disbursementmode::"Bank Transfer":
                TransferFee := ObjGenSetUp."Loan Trasfer Fee-FOSA";

            Disbursementmode::Cheque:
                TransferFee := ObjGenSetUp."Loan Trasfer Fee-Cheque";

            Disbursementmode::"Cheque NonMember":
                TransferFee := ObjGenSetUp."Loan Trasfer Fee-EFT";

            Disbursementmode::EFT:
                TransferFee := ObjGenSetUp."Loan Trasfer Fee-RTGS";
        end;
        exit(TransferFee);
    end;


    procedure FnGetFosaAccount(MemberNo: Code[50]) FosaAccount: Code[50]
    var
        ObjMembers: Record Customer;
    begin
        ObjMembers.Reset;
        ObjMembers.SetRange(ObjMembers."No.", MemberNo);
        if ObjMembers.Find('-') then begin
            FosaAccount := ObjMembers."FOSA Account No.";
        end;
        exit(FosaAccount);
    end;

    procedure SHA256Hash(entry: Text): Text
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        // Returns SHA256 Hash of input string
        exit(CryptographyManagement.GenerateHash(entry, HashAlgorithmType::SHA256));
    end;

    procedure FnCreateGnlJournalLineBalanced(TemplateName: Text; BatchName: Text; DocumentNo: Code[30]; LineNo: Integer; TransactionType: enum TransactionTypesEnum; AccountType: enum "Gen. Journal Account Type"; AccountNo: Code[50]; TransactionDate: Date; TransactionDescription: Text; BalancingAccountType: enum "Gen. Journal Account Type"; BalancingAccountNo: Code[50]; TransactionAmount: Decimal; DimensionActivity: Code[40]; ExternalDocNo: Code[30]; FosaTransType: Option " ",CashWithdrawal,CashDeposit,ChequeDeposit,CashWithdrawalCommission,ChequeDepositComission,InternalTransfers,BOSALoanPayment,BOSAPayout,LoansIssued,ATMTransactions,ATMCharges,StandingOrders,ExciseDuty,StampDuty,POSTransactions,POSTransactionCharges,MobileTransactions,MobileTransactionCharges,BankersCheques,BankersChequeCommission,SalaryProcessing,SalaryProcessingFee,SMS,ChequeWithdrawal,ChequeWithdrawalCommission,LoanOffsets,RegistrationFee,Receipts,PensionProcessing,PensionProcessingFee,FOSACardFee,ATMReplacement)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := TemplateName;
        GenJournalLine."Journal Batch Name" := BatchName;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Transaction Type" := TransactionType;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."Posting Date" := TransactionDate;
        GenJournalLine.Description := TransactionDescription;
        GenJournalLine.Validate(GenJournalLine."Currency Code");
        GenJournalLine.Amount := TransactionAmount;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Bal. Account Type" := BalancingAccountType;
        GenJournalLine."Bal. Account No." := BalancingAccountNo;
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
        GenJournalLine."Shortcut Dimension 1 Code" := DimensionActivity;
        GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."External Document No." := ExternalDocNo;
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
    end;


    procedure FnChargeExcise(ChargeCode: Code[100]): Boolean
    var
        ObjProductCharges: Record "Loan Charges";
    begin
        /*ObjProductCharges.RESET;
        ObjProductCharges.SETRANGE(Code,ChargeCode);
        IF ObjProductCharges.FIND('-') THEN
          EXIT(ObjProductCharges."Charge Excise");
          */

    end;


    procedure FnGetInterestDueTodate(ObjLoans: Record "Loans Register"): Decimal
    var
        ObjLoanRegister: Record "Loans Register";
    begin
        ObjLoans.SetFilter("Date filter", '..' + Format(Today));
        ObjLoans.CalcFields("Schedule Interest to Date", "Outstanding Balance");
        exit(ObjLoans."Schedule Interest to Date");
    end;


    procedure FnGetPhoneNumber(ObjLoans: Record "Loans Register"): Code[50]
    begin
        ObjMembers.Reset;
        ObjMembers.SetRange("No.", ObjLoans."Client Code");
        if ObjMembers.Find('-') then
            exit(ObjMembers."Phone No.");
    end;

    local procedure FnBoosterLoansDisbursement(ObjLoanDetails: Record "Loans Register"): Code[40]
    var
        GenJournalLine: Record "Gen. Journal Line";
        CUNoSeriesManagement: Codeunit NoSeriesManagement;
        DocNumber: Code[100];
        loanTypes: Record "Loan Products Setup";
        ObjLoanX: Record "Loans Register";
        LoansRec: Record "Loans Register";
        Cust: Record Customer;
    begin
        loanTypes.Reset;
        loanTypes.SetRange(loanTypes.Code, 'BLOAN');
        if loanTypes.Find('-') then begin
            DocNumber := CUNoSeriesManagement.GetNextNo('LOANSB', 0D, true);
            LoansRec.Init;
            LoansRec."Loan  No." := DocNumber;
            // LoansRec.INSERT;

        end;
        exit(DocNumber);
    end;


    procedure FnGenerateRepaymentSchedule(LoanNumber: Code[50]): Boolean
    var
        ObjLoans: Record "Loans Register";
        ObjRepaymentschedule: Record "Loan Repayment Schedule";
        ObjLoansII: Record "Loans Register";
        VarPeriodDueDate: Date;
        VarRunningDate: Date;
        VarGracePeiodEndDate: Date;
        VarInstalmentEnddate: Date;
        VarGracePerodDays: Integer;
        VarInstalmentDays: Integer;
        VarNoOfGracePeriod: Integer;
        VarLoanAmount: Decimal;
        VarInterestRate: Decimal;
        VarRepayPeriod: Integer;
        VarLBalance: Decimal;
        VarRunDate: Date;
        VarInstalNo: Decimal;
        VarRepayInterval: DateFormula;
        VarTotalMRepay: Decimal;
        VarLInterest: Decimal;
        VarLPrincipal: Decimal;
        VarLInsurance: Decimal;
        VarRepayCode: Code[30];
        VarGrPrinciple: Integer;
        VarGrInterest: Integer;
        VarQPrinciple: Decimal;
        VarQCounter: Integer;
        VarInPeriod: DateFormula;
        VarInitialInstal: Integer;
        VarInitialGraceInt: Integer;
        VarScheduleBal: Decimal;
        VarLNBalance: Decimal;
        ObjProductCharge: Record "Loan Product Charges";
        VarWhichDay: Integer;
        VarRepaymentStartDate: Date;
        VarMonthIncreament: Text;
        ScheduleEntryNo: Integer;
        saccogen: Record "Sacco General Set-Up";
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Loan  No.", LoanNumber);
        if ObjLoans.FindSet then begin
            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                Evaluate(VarInPeriod, '1D')
            else
                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                    Evaluate(VarInPeriod, '1W')
                else
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                        Evaluate(VarInPeriod, '1M')
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                            Evaluate(VarInPeriod, '1Q');

            VarRunDate := 0D;
            VarQCounter := 0;
            VarQCounter := 3;
            VarScheduleBal := 0;

            VarGrPrinciple := ObjLoans."Grace Period - Principle (M)";
            VarGrInterest := ObjLoans."Grace Period - Interest (M)";
            VarInitialGraceInt := ObjLoans."Grace Period - Interest (M)";


            ObjLoansII.Reset;
            ObjLoansII.SetRange(ObjLoansII."Loan  No.", LoanNumber);
            if ObjLoansII.Find('-') then begin
                ObjLoansII.CalcFields(ObjLoansII."Outstanding Balance");

                ObjLoans.TestField(ObjLoans."Loan Disbursement Date");
                ObjLoans.TestField(ObjLoans."Repayment Start Date");

                //=================================================================Delete From Tables
                ObjRepaymentschedule.Reset;
                ObjRepaymentschedule.SetRange(ObjRepaymentschedule."Loan No.", LoanNumber);
                if ObjRepaymentschedule.Find('-') then begin
                    ObjRepaymentschedule.DeleteAll;
                end;

                VarLoanAmount := ObjLoansII."Approved Amount";
                VarInterestRate := ObjLoansII.Interest;
                VarRepayPeriod := ObjLoansII.Installments;
                VarInitialInstal := ObjLoansII.Installments + ObjLoansII."Grace Period - Principle (M)";
                VarLBalance := VarLoanAmount;
                VarLNBalance := ObjLoansII."Outstanding Balance";
                VarRunDate := ObjLoansII."Repayment Start Date";
                VarRepaymentStartDate := ObjLoansII."Repayment Start Date";

                VarInstalNo := 0;
                Evaluate(VarRepayInterval, '1W');

                repeat
                    VarInstalNo := VarInstalNo + 1;
                    VarScheduleBal := VarLBalance;
                    ScheduleEntryNo := ScheduleEntryNo + 1;

                    //=======================================================================================Amortised
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Amortised
                       then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarTotalMRepay := ROUND((VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount, 1, '>');
                        VarTotalMRepay := (VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount;
                        VarLInterest := ROUND(VarLBalance / 100 / 12 * VarInterestRate);

                        VarLPrincipal := VarTotalMRepay - VarLInterest;
                    end;

                    //=======================================================================================Strainght Line
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Straight Line" then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 1200) * VarLoanAmount, 1, '>');
                        if VarInstalNo - ObjLoans."Grace Period - Interest (M)" = 1 then
                            VarLInterest := VarLInterest * VarInstalNo;

                        ObjLoans.Repayment := VarLPrincipal + VarLInterest;
                        ObjLoans."Loan Principle Repayment" := VarLPrincipal;
                        ObjLoans."Loan Interest Repayment" := VarLInterest;
                        ObjLoans.Modify;
                    end;

                    //=======================================================================================Reducing Balance
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Reducing Balance" then begin
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);//2828
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 12 / 100) * VarLBalance, 1, '>');

                    end;

                    //=======================================================================================Constant
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Constants then begin
                        ObjLoans.Repayment := ObjLoans."Approved Amount" / ObjLoans.Installments;
                        ObjLoans.Modify(true);
                        ObjLoans.TestField(ObjLoans.Repayment);
                        if VarLBalance < ObjLoans.Repayment then
                            VarLPrincipal := VarLBalance
                        else
                            VarLPrincipal := ObjLoans.Repayment;

                        VarLInterest := ObjLoans.Interest;

                    end;

                    VarLPrincipal := ROUND(VarLPrincipal, 1, '>');
                    Evaluate(VarRepayCode, Format(VarInstalNo));
                    //======================================================================================Grace Period
                    if VarLBalance < VarLPrincipal then
                        VarLPrincipal := VarLBalance
                    else
                        VarLPrincipal := VarLPrincipal;
                    if VarGrPrinciple > 0 then begin
                        VarLPrincipal := 0;
                        VarLInsurance := 0
                    end else begin
                        VarLBalance := VarLBalance - VarLPrincipal;
                        VarScheduleBal := VarScheduleBal - VarLPrincipal;
                    end;

                    if VarGrInterest > 0 then
                        VarLInterest := 0;

                    VarGrPrinciple := VarGrPrinciple - 1;
                    VarGrInterest := VarGrInterest - 1;


                    //======================================================================================Insert Repayment Schedule Table
                    if VarInstalNo <> 1 then begin
                        VarLInsurance := 0;
                    end;

                    ObjRepaymentschedule.Init;
                    //ObjRepaymentschedule."Entry No" := ScheduleEntryNo;
                    ObjRepaymentschedule."Repayment Code" := VarRepayCode;
                    ObjRepaymentschedule."Loan No." := ObjLoans."Loan  No.";
                    ObjRepaymentschedule."Loan Amount" := VarLoanAmount;
                    ObjRepaymentschedule."Interest Rate" := ObjLoans.Interest;
                    ObjRepaymentschedule."Instalment No" := VarInstalNo;
                    ObjRepaymentschedule."Repayment Date" := VarRunDate;//CALCDATE('CM',RunDate);
                    ObjRepaymentschedule."Member No." := ObjLoans."Client Code";
                    ObjRepaymentschedule."Loan Category" := ObjLoans."Loan Product Type";
                    ObjRepaymentschedule."Monthly Repayment" := VarLInterest + VarLPrincipal;
                    ObjRepaymentschedule."Monthly Interest" := VarLInterest;
                    ObjRepaymentschedule."Principal Repayment" := VarLPrincipal;
                    //ERROR(FORMAT(VarLPrincipal));
                    //ObjRepaymentschedule."Monthly Insurance" := VarLInsurance;
                    ObjRepaymentschedule."Loan Balance" := VarLBalance;
                    ObjRepaymentschedule.Insert;
                    VarWhichDay := Date2dwy(ObjRepaymentschedule."Repayment Date", 1);
                    //=======================================================================Get Next Repayment Date
                    VarMonthIncreament := Format(VarInstalNo) + 'M';
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                        VarRunDate := CalcDate('1D', VarRunDate)
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                            VarRunDate := CalcDate('1W', VarRunDate)
                        else
                            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                                VarRunDate := CalcDate(VarMonthIncreament, VarRepaymentStartDate)
                            else
                                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                                    VarRunDate := CalcDate('1Q', VarRunDate);

                until VarLBalance < 1
            end;
            Commit();
        end;
    end;


    procedure FnGetInterestDueFiltered(ObjLoans: Record "Loans Register"; DateFilter: Text): Decimal
    var
        ObjLoanRegister: Record "Loans Register";
    begin
        ObjLoans.SetFilter("Date filter", DateFilter);
        ObjLoans.CalcFields("Schedule Interest to Date", "Outstanding Balance");
        exit(ObjLoans."Schedule Interest to Date");
    end;


    procedure FnGetPAYEBudCharge(ChargeCode: Code[10]): Decimal
    var
        ObjpayeCharges: Record "PAYE Brackets Credit";
    begin
        ObjpayeCharges.Reset;
        ObjpayeCharges.SetRange("Tax Band", ChargeCode);
        if ObjpayeCharges.FindFirst then
            exit(ObjpayeCharges."Taxable Amount" * ObjpayeCharges.Percentage / 100);
    end;


    procedure FnPayeRate(ChargeCode: Code[10]): Decimal
    var
        ObjpayeCharges: Record "PAYE Brackets Credit";
    begin
        ObjpayeCharges.Reset;
        ObjpayeCharges.SetRange("Tax Band", ChargeCode);
        if ObjpayeCharges.FindFirst then
            exit(ObjpayeCharges.Percentage / 100);
    end;


    procedure FnCalculatePaye(Chargeable: Decimal) PAYE: Decimal
    var
        TAXABLEPAY: Record "PAYE Brackets Credit";
        Taxrelief: Decimal;
        OTrelief: Decimal;
    begin
        PAYE := 0;
        if TAXABLEPAY.Find('-') then begin
            repeat
                if Chargeable > 0 then begin
                    case TAXABLEPAY."Tax Band" of
                        '01':
                            begin
                                if Chargeable > TAXABLEPAY."Upper Limit" then begin
                                    BAND1 := FnGetPAYEBudCharge('01');
                                    Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                end else begin
                                    if Chargeable > TAXABLEPAY."Taxable Amount" then begin
                                        BAND1 := FnGetPAYEBudCharge('01');
                                        Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                    end else begin
                                        BAND1 := Chargeable * FnPayeRate('01');
                                        Chargeable := 0;
                                    end;
                                end;
                            end;
                        '02':
                            begin
                                if Chargeable > TAXABLEPAY."Upper Limit" then begin
                                    BAND2 := FnGetPAYEBudCharge('02');
                                    Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                end else begin
                                    if Chargeable > TAXABLEPAY."Taxable Amount" then begin
                                        BAND2 := FnGetPAYEBudCharge('02');
                                        Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                    end else begin
                                        BAND2 := Chargeable * FnPayeRate('02');
                                        Chargeable := 0;
                                    end;
                                end;
                            end;
                        '03':
                            begin
                                if Chargeable > TAXABLEPAY."Upper Limit" then begin
                                    BAND3 := FnGetPAYEBudCharge('03');
                                    Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                end else begin
                                    if Chargeable > TAXABLEPAY."Taxable Amount" then begin
                                        BAND3 := FnGetPAYEBudCharge('03');
                                        Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                    end else begin
                                        BAND3 := Chargeable * FnPayeRate('03');
                                        Chargeable := 0;
                                    end;
                                end;
                            end;
                        '04':
                            begin
                                if Chargeable > TAXABLEPAY."Upper Limit" then begin
                                    BAND4 := FnGetPAYEBudCharge('04');
                                    Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                end else begin
                                    if Chargeable > TAXABLEPAY."Taxable Amount" then begin
                                        BAND4 := FnGetPAYEBudCharge('04');
                                        Chargeable := Chargeable - TAXABLEPAY."Taxable Amount";
                                    end else begin
                                        BAND4 := Chargeable * FnPayeRate('04');
                                        Chargeable := 0;
                                    end;
                                end;
                            end;
                        '05':
                            begin
                                BAND5 := Chargeable * FnPayeRate('05');
                            end;
                    end;
                end;
            until TAXABLEPAY.Next = 0;
        end;
        exit(BAND1 + BAND2 + BAND3 + BAND4 + BAND5 - 1280);
    end;


    procedure FnGetUpfrontsTotal(ProductCode: Code[50]; InsuredAmount: Decimal) FCharged: Decimal
    var
        ObjLoanCharges: Record "Loan Charges";
    begin
        /*ObjProductCharges.RESET;
        ObjProductCharges.SETRANGE(ObjProductCharges."Product Code",ProductCode);
        IF ObjProductCharges.FIND('-') THEN
        BEGIN
          REPEAT
          IF ObjProductCharges."Use Perc"=TRUE THEN
            BEGIN
              FCharged:=InsuredAmount*(ObjProductCharges.Percentage/100)+FCharged;
              IF ObjLoanCharges.GET(ObjProductCharges.Code) THEN BEGIN
                IF ObjLoanCharges."Charge Excise"=TRUE THEN
                  FCharged:=FCharged+(InsuredAmount*(ObjProductCharges.Percentage/100))*0.1;
                END
              END
            ELSE BEGIN
            FCharged:=ObjProductCharges.Amount+FCharged;
            IF ObjLoanCharges.GET(ObjProductCharges.Code) THEN BEGIN
                IF ObjLoanCharges."Charge Excise"=TRUE THEN
                  FCharged:=FCharged+ObjProductCharges.Amount*0.1;
                END
            END
        
          UNTIL ObjProductCharges.NEXT=0;
        END;
        
        EXIT(FCharged);
        */

    end;


    procedure FnGetPrincipalDueFiltered(ObjLoans: Record "Loans Register"; DateFilter: Text): Decimal
    var
        ObjLoanRegister: Record "Loans Register";
    begin
        ObjLoans.SetFilter("Date filter", DateFilter);
        ObjLoans.CalcFields("Scheduled Principal to Date", "Outstanding Balance");
        exit(ObjLoans."Scheduled Principal to Date");
    end;


    procedure FnGetPreviousMonthLastDate(LoanNum: Code[10]; RunDate: Date) LastMonthDate: Date
    var
        ObjLoansReg: Record "Loans Register";
    begin
        if ObjLoansReg.Get(LoanNum) then begin
            if (ObjLoansReg."Repayment Frequency" = ObjLoansReg."repayment frequency"::Monthly) then begin
                if (RunDate = CalcDate('CM', RunDate)) then begin
                    LastMonthDate := RunDate;
                end else begin
                    LastMonthDate := CalcDate('-1M', RunDate);
                end;
                LastMonthDate := CalcDate('CM', LastMonthDate);
            end;
        end;

        exit(LastMonthDate);
    end;


    procedure FnGetScheduledExpectedBalance(LoanNum: Code[10]; RunDate: Date) ScheduleBal: Decimal
    var
        ObjRepaySch: Record "Loan Repayment Schedule";
    begin
        ScheduleBal := 0;

        ObjRepaySch.Reset;
        ObjRepaySch.SetRange(ObjRepaySch."Loan No.", LoanNum);
        ObjRepaySch.SetRange(ObjRepaySch."Repayment Date", RunDate);
        if ObjRepaySch.FindSet then begin
            ScheduleBal := ObjRepaySch."Loan Balance";
        end else begin
            ScheduleBal := 0;
        end;

        exit(ScheduleBal);
    end;


    procedure FnGetLoanBalance(LoanNum: Code[10]; RunDate: Date) LoanBal: Decimal
    var
        ObjLoanReg: Record "Loans Register";
        DateFilter: Text;
    begin
        LoanBal := 0;

        ObjLoanReg.Reset;
        ObjLoanReg.SetRange(ObjLoanReg."Loan  No.", LoanNum);
        ObjLoanReg.SetFilter(ObjLoanReg."Date filter", '..' + Format(RunDate));
        if ObjLoanReg.Find('-') then begin
            ObjLoanReg.CalcFields(ObjLoanReg."Outstanding Balance");
            LoanBal := ObjLoanReg."Outstanding Balance";
        end;

        exit(LoanBal);
    end;


    procedure FnCalculateLoanArrears(ScheduleBalance: Decimal; LoanBalance: Decimal; RunDate: Date; ExpCompDate: Date) Arrears: Decimal
    begin
        Arrears := 0;

        if ExpCompDate < RunDate then begin
            Arrears := (LoanBalance) * -1;
        end else begin
            Arrears := ScheduleBalance - LoanBalance;

            if Arrears > 0 then
                Arrears := 0
            else
                Arrears := Arrears;
        end;

        exit(Arrears);
    end;


    procedure FnCalculatePeriodInArrears(Arrears: Decimal; PRepay: Decimal; RunDate: Date; ExpCompletionDate: Date) PeriodArrears: Decimal
    begin
        PeriodArrears := 0;

        if Arrears <> 0 then begin
            if ExpCompletionDate < RunDate then begin
                PeriodArrears := ROUND((RunDate - ExpCompletionDate) / 30, 1, '=');
            end else
                PeriodArrears := ROUND(Arrears / PRepay, 1, '=') * -1;
        end;

        exit(PeriodArrears);
    end;


    procedure FnClassifyLoans(LoanNum: Code[10]; PeriodInArrears: Decimal; AmountArrears: Decimal) Class: Integer
    var
        ObjLoansReg: Record "Loans Register";
    begin

    end;


    procedure FnGetMemberApplicationAMLRiskRating(MemberNo: Code[20])
    var
        VarCategoryScore: Integer;
        VarResidencyScore: Integer;
        VarNatureofBusinessScore: Integer;
        VarEntityScore: Integer;
        VarIndustryScore: Integer;
        VarLenghtOfRelationshipScore: Integer;
        VarInternationalTradeScore: Integer;
        VarElectronicPaymentScore: Integer;
        VarCardTypeScore: Integer;
        VarAccountTypeScore: Integer;
        VarChannelTakenScore: Integer;
        VarAccountTypeOption: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        MemberTotalRiskRatingScore: Decimal;
        MemberNetRiskScore: Decimal;
        ObjMemberDueDiligence: Record "Member Due Diligence Measures";
        ObjDueDiligenceSetup: Record "Due Diligence Measures";
        VarRiskRatingDescription: Text[50];
        VarRefereeScore: Decimal;
        VarRefereeRiskRate: Text;
        ObjRefereeSetup: Record "Referee Risk Rating Scale";
        ObjMemberRiskRate: Record "Individual Customer Risk Rate";
        ObjControlRiskRating: Record "Control Risk Rating";
        VarControlRiskRating: Decimal;
        VarAccountTypeScoreVer1: Decimal;
        VarAccountTypeScoreVer2: Decimal;
        VarAccountTypeScoreVer3: Decimal;
        VarAccountTypeOptionVer1: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer2: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer3: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        ObjMembershipApplication: Record "Membership Applications";
        ObjCustRiskRates: Record "Customer Risk Rating";
    begin
        /*
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication.Category);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarCategoryScore:=ObjCustRiskRates."Risk Score";
               END;
           END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
          ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Entities);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication.Entities);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarEntityScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           //=============================================================Exisiting Referee
           ObjMemberRiskRate.RESET;
           ObjMemberRiskRate.SETRANGE(ObjMemberRiskRate."Membership Application No",ObjMembershipApplication."Referee Member No");
           IF ObjMemberRiskRate.FINDSET THEN
             BEGIN
               IF ObjMembershipApplication."Referee Member No"<>'' THEN
                BEGIN
        
                ObjRefereeSetup.RESET;
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                    REPEAT
                    IF (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING">=ObjRefereeSetup."Minimum Risk Rate") AND
                      (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING"<=ObjRefereeSetup."Maximum Risk Rate") THEN
                      BEGIN
                      VarRefereeScore:=ObjRefereeSetup.Score;
                      VarRefereeRiskRate:=ObjRefereeSetup.Description;
                      END;
                    UNTIL ObjRefereeSetup.NEXT=0;
                  END;
                 END;
        
            //=============================================================No Referee
            IF ObjMembershipApplication."Referee Member No"='' THEN
              BEGIN
                ObjRefereeSetup.RESET;
                ObjRefereeSetup.SETFILTER(ObjRefereeSetup.Description,'%1','Others with no referee');
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                  VarRefereeScore:=ObjRefereeSetup.Score;
                  VarRefereeRiskRate:='Others with no referee';
                  END;
                END;
               END;
        
        
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Industry);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Industry Type");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarIndustryScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Length Of Relationship");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Length Of Relationship");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarLenghtOfRelationshipScore:=ObjCustRiskRates."Risk Score";
              END;
         END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"International Trade");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."International Trade");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarInternationalTradeScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Electronic Payment");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        
        //ObjProductRiskRating.GET();
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Cards Type Taken");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarCardTypeScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Accounts Type Taken");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
               END;
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Others(Channels)");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
               END;
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp."Product Source",'<>%1',ObjProductsApp."Product Source"::FOSA);
         IF ObjProductsApp.FINDSET THEN
            BEGIN
               REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"12");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer1:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer1:=ObjProductRiskRating."Product Type"::"12";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"12";
                   END;
                 UNTIL ObjProductsApp.NEXT=0;
            END;
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp."Product Source",'%1',ObjProductsApp."Product Source"::FOSA);
         ObjProductsApp.SETFILTER(ObjProductsApp.Product,'<>%1|%2','503','506');
         IF ObjProductsApp.FINDSET THEN
            BEGIN
        
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','FOSA (KSA, Imara, Heritage, MJA)');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer2:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer2:=ObjProductRiskRating."Product Type"::"5";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"5";
                   END;
                   UNTIL ObjProductsApp.NEXT=0;
            END;
        
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp.Product,'%1|%2','503','506');
         IF ObjProductsApp.FINDSET THEN
            BEGIN
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"4");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer3:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer3:=ObjProductRiskRating."Product Type"::"4";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"4";
                   END;
                   UNTIL ObjProductsApp.NEXT=0;
            END;
        
        
        IF (VarAccountTypeScoreVer1>VarAccountTypeScoreVer2) AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer3) THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer1;
          VarAccountTypeOption:=VarAccountTypeOptionVer1
          END ELSE
        IF (VarAccountTypeScoreVer2>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer2>VarAccountTypeScoreVer3)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer2;
          VarAccountTypeOption:=VarAccountTypeOptionVer2
         END ELSE
        IF (VarAccountTypeScoreVer3>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer3>VarAccountTypeScoreVer2)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer3;
          VarAccountTypeOption:=VarAccountTypeOptionVer3
          END;
        
        
        //Create Entries on Membership Risk Rating Table
        ObjMemberRiskRating.RESET;
        ObjMemberRiskRating.SETRANGE(ObjMemberRiskRating."Membership Application No",MemberNo);
        IF ObjMemberRiskRating.FINDSET THEN
          BEGIN
            ObjMemberRiskRating.DELETEALL;
            END;
        
        
        //===============================================Get Control Risk Rating
        ObjControlRiskRating.RESET;
        IF ObjControlRiskRating.FINDSET THEN
          BEGIN
          ObjControlRiskRating.CALCSUMS(ObjControlRiskRating."Control Weight Aggregate");
          VarControlRiskRating:=ObjControlRiskRating."Control Weight Aggregate";
          END;
        
        
        
        ObjMemberRiskRating.INIT;
        ObjMemberRiskRating."Membership Application No":=MemberNo;
        ObjMemberRiskRating."What is the Customer Category?":=ObjMembershipApplication."Individual Category";
        ObjMemberRiskRating."Customer Category Score":=VarCategoryScore;
        ObjMemberRiskRating."What is the Member residency?":=ObjMembershipApplication."Member Residency Status";
        ObjMemberRiskRating."Member Residency Score":=VarResidencyScore;
        ObjMemberRiskRating."Cust Employment Risk?":=ObjMembershipApplication.Entities;
        ObjMemberRiskRating."Cust Employment Risk Score":=VarEntityScore;
        ObjMemberRiskRating."Cust Business Risk Industry?":=ObjMembershipApplication."Industry Type";
        ObjMemberRiskRating."Cust Bus. Risk Industry Score":=VarIndustryScore;
        ObjMemberRiskRating."Lenght Of Relationship?":=ObjMembershipApplication."Length Of Relationship";
        ObjMemberRiskRating."Length Of Relation Score":=VarLenghtOfRelationshipScore;
        ObjMemberRiskRating."Cust Involved in Intern. Trade":=ObjMembershipApplication."International Trade";
        ObjMemberRiskRating."Involve in Inter. Trade Score":=VarInternationalTradeScore;
        ObjMemberRiskRating."Account Type Taken?":=FORMAT(VarAccountTypeOption);
        ObjMemberRiskRating."Account Type Taken Score":=VarAccountTypeScore;
        ObjMemberRiskRating."Card Type Taken":=ObjMembershipApplication."Cards Type Taken";
        ObjMemberRiskRating."Card Type Taken Score":=VarCardTypeScore;
        ObjMemberRiskRating."Channel Taken?":=ObjMembershipApplication."Others(Channels)";
        ObjMemberRiskRating."Channel Taken Score":=VarChannelTakenScore;
        ObjMemberRiskRating."Electronic Payments?":=ObjMembershipApplication."Electronic Payment";
        ObjMemberRiskRating."Referee Score":=VarRefereeScore;
        ObjMemberRiskRating."Member Referee Rate":=VarRefereeRiskRate;
        ObjMemberRiskRating."Electronic Payments Score":=VarElectronicPaymentScore;
        MemberTotalRiskRatingScore:=VarCategoryScore+VarEntityScore+VarIndustryScore+VarInternationalTradeScore+VarRefereeScore+VarLenghtOfRelationshipScore+VarResidencyScore+VarAccountTypeScore
        +VarCardTypeScore+VarChannelTakenScore+VarElectronicPaymentScore;
        ObjMemberRiskRating."GROSS CUSTOMER AML RISK RATING":=MemberTotalRiskRatingScore;
        ObjMemberRiskRating."BANK'S CONTROL RISK RATING":=VarControlRiskRating;
        ObjMemberRiskRating."CUSTOMER NET RISK RATING":=ROUND(ObjMemberRiskRating."GROSS CUSTOMER AML RISK RATING"/ObjMemberRiskRating."BANK'S CONTROL RISK RATING",0.01,'>');
        MemberNetRiskScore:=MemberTotalRiskRatingScore/VarControlRiskRating;
        
        ObjNetRiskScale.RESET;
        IF ObjNetRiskScale.FINDSET THEN
          BEGIN
            REPEAT
            IF (MemberTotalRiskRatingScore>=ObjNetRiskScale."Minimum Risk Rate") AND (MemberTotalRiskRatingScore<=ObjNetRiskScale."Maximum Risk Rate") THEN BEGIN
             ObjMemberRiskRating."Risk Rate Scale":=ObjNetRiskScale."Risk Scale";
              VarRiskRatingDescription:=ObjNetRiskScale.Description;
              END;
            UNTIL ObjNetRiskScale.NEXT=0;
          END;
        ObjMemberRiskRating.INSERT;
        ObjMemberRiskRating.VALIDATE(ObjMemberRiskRating."Membership Application No");
        ObjMemberRiskRating.MODIFY;
        
        
        ObjMemberDueDiligence.RESET;
        ObjMemberDueDiligence.SETRANGE(ObjMemberDueDiligence."Member No",MemberNo);
        IF ObjMemberDueDiligence.FINDSET THEN
          BEGIN
            ObjMemberDueDiligence.DELETEALL;
            END;
        
        ObjDueDiligenceSetup.RESET;
        ObjDueDiligenceSetup.SETRANGE(ObjDueDiligenceSetup."Risk Rating Level",ObjMemberRiskRating."Risk Rate Scale");
        IF ObjDueDiligenceSetup.FINDSET THEN
          BEGIN
            REPEAT
              ObjMemberDueDiligence.INIT;
              ObjMemberDueDiligence."Member No":=MemberNo;
              IF ObjMembershipApplication.GET(MemberNo) THEN
                BEGIN
                  ObjMemberDueDiligence."Member Name":=ObjMembershipApplication.Name;
                  END;
              ObjMemberDueDiligence."Due Diligence No":=ObjDueDiligenceSetup."Due Diligence No";
              ObjMemberDueDiligence."Risk Rating Level":=ObjMemberRiskRating."Risk Rate Scale";
              ObjMemberDueDiligence."Risk Rating Scale":= VarRiskRatingDescription;
              ObjMemberDueDiligence."Due Diligence Type":=ObjDueDiligenceSetup."Due Diligence Type";
              ObjMemberDueDiligence."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Measure";
              ObjMemberDueDiligence.INSERT;
              UNTIL ObjDueDiligenceSetup.NEXT=0;
            END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
          BEGIN
            ObjMembershipApplication."Member Risk Level":=ObjMemberRiskRating."Risk Rate Scale";
            ObjMembershipApplication."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Type";
            ObjMembershipApplication.MODIFY;
            END;*/

    end;


    procedure FnGetEntitiesApplicationAMLRiskRating(MemberNo: Code[20])
    var
        VarCategoryScore: Integer;
        VarResidencyScore: Integer;
        VarNatureofBusinessScore: Integer;
        VarEntityScore: Integer;
        VarIndustryScore: Integer;
        VarLenghtOfRelationshipScore: Integer;
        VarInternationalTradeScore: Integer;
        VarElectronicPaymentScore: Integer;
        VarCardTypeScore: Integer;
        VarAccountTypeScore: Integer;
        VarChannelTakenScore: Integer;
        VarAccountTypeOption: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","FOSA(KSA",Imara," MJA","Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        MemberTotalRiskRatingScore: Decimal;
        MemberNetRiskScore: Decimal;
        ObjMemberDueDiligence: Record "Member Due Diligence Measures";
        ObjDueDiligenceSetup: Record "Due Diligence Measures";
        VarRiskRatingDescription: Text[50];
        ObjControlRiskRating: Record "Control Risk Rating";
        VarControlRiskRating: Decimal;
        ObjMemberRiskRate: Record "Individual Customer Risk Rate";
        ObjRefereeSetup: Record "Referee Risk Rating Scale";
        VarRefereeScore: Decimal;
        VarRefereeRiskRate: Text;
        VarAccountTypeScoreVer1: Decimal;
        VarAccountTypeScoreVer2: Decimal;
        VarAccountTypeScoreVer3: Decimal;
        VarAccountTypeOptionVer1: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer2: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer3: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        ObjMembershipApplication: Record "Membership Applications";
        ObjCustRiskRates: Record "Customer Risk Rating";
    begin
        /*
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication.Category);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarCategoryScore:=ObjCustRiskRates."Risk Score";
               END;
           END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
          ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Entities);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication.Entities);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarEntityScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           //=============================================================Exisiting Referee
           ObjMemberRiskRate.RESET;
           ObjMemberRiskRate.SETRANGE(ObjMemberRiskRate."Membership Application No",ObjMembershipApplication."Referee Member No");
           IF ObjMemberRiskRate.FINDSET THEN
             BEGIN
               IF ObjMembershipApplication."Referee Member No"<>'' THEN
                BEGIN
        
                ObjRefereeSetup.RESET;
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                    REPEAT
                    IF (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING">=ObjRefereeSetup."Minimum Risk Rate") AND
                      (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING"<=ObjRefereeSetup."Maximum Risk Rate") THEN
                      BEGIN
                      VarRefereeScore:=ObjRefereeSetup.Score;
                      VarRefereeRiskRate:=ObjRefereeSetup.Description;
                      END;
                    UNTIL ObjRefereeSetup.NEXT=0;
                  END;
                 END;
        
            //=============================================================No Referee
            IF ObjMembershipApplication."Referee Member No"='' THEN
              BEGIN
                ObjRefereeSetup.RESET;
                ObjRefereeSetup.SETFILTER(ObjRefereeSetup.Description,'%1','Others with no referee');
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                  VarRefereeScore:=ObjRefereeSetup.Score;
                  VarRefereeRiskRate:='Others with no referee';
                  END;
                END;
               END;
        
        
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Industry);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Industry Type");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarIndustryScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Length Of Relationship");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."Length Of Relationship");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarLenghtOfRelationshipScore:=ObjCustRiskRates."Risk Score";
              END;
         END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"International Trade");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembershipApplication."International Trade");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarInternationalTradeScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Electronic Payment");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        
        //ObjProductRiskRating.GET();
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
         BEGIN
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Cards Type Taken");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarCardTypeScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Accounts Type Taken");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
               END;
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembershipApplication."Others(Channels)");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
               END;
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp."Product Source",'<>%1',ObjProductsApp."Product Source"::FOSA);
         IF ObjProductsApp.FINDSET THEN
            BEGIN
               REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"12");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer1:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer1:=ObjProductRiskRating."Product Type"::"12";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"12";
                   END;
                 UNTIL ObjProductsApp.NEXT=0;
            END;
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp."Product Source",'%1',ObjProductsApp."Product Source"::FOSA);
         ObjProductsApp.SETFILTER(ObjProductsApp.Product,'<>%1|%2','503','506');
         IF ObjProductsApp.FINDSET THEN
            BEGIN
        
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','FOSA (KSA, Imara, Heritage, MJA)');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer2:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer2:=ObjProductRiskRating."Product Type"::"5";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"5";
                   END;
                   UNTIL ObjProductsApp.NEXT=0;
            END;
        
        
         ObjProductsApp.RESET;
         ObjProductsApp.SETRANGE(ObjProductsApp."Membership Applicaton No",MemberNo);
         ObjProductsApp.SETFILTER(ObjProductsApp.Product,'%1|%2','503','506');
         IF ObjProductsApp.FINDSET THEN
            BEGIN
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"4");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer3:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer3:=ObjProductRiskRating."Product Type"::"4";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"4";
                   END;
                   UNTIL ObjProductsApp.NEXT=0;
            END;
        
        
        IF (VarAccountTypeScoreVer1>VarAccountTypeScoreVer2) AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer3) THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer1;
          VarAccountTypeOption:=VarAccountTypeOptionVer1
          END ELSE
        IF (VarAccountTypeScoreVer2>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer2>VarAccountTypeScoreVer3)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer2;
          VarAccountTypeOption:=VarAccountTypeOptionVer2
         END ELSE
        IF (VarAccountTypeScoreVer3>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer3>VarAccountTypeScoreVer2)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer3;
          VarAccountTypeOption:=VarAccountTypeOptionVer3
          END;
        
        
        //Create Entries on Membership Risk Rating Table
        ObjEntitiesRiskRating.RESET;
        ObjEntitiesRiskRating.SETRANGE(ObjEntitiesRiskRating."Membership Application No",MemberNo);
        IF ObjEntitiesRiskRating.FINDSET THEN
          BEGIN
            ObjEntitiesRiskRating.DELETEALL;
            END;
        
        
        //===============================================Get Control Risk Rating
        ObjControlRiskRating.RESET;
        IF ObjControlRiskRating.FINDSET THEN
          BEGIN
          ObjControlRiskRating.CALCSUMS(ObjControlRiskRating."Control Weight Aggregate");
          VarControlRiskRating:=ObjControlRiskRating."Control Weight Aggregate";
          END;
        
        
        
        ObjEntitiesRiskRating.INIT;
        ObjEntitiesRiskRating."Membership Application No":=MemberNo;
        ObjEntitiesRiskRating."What is the Customer Category?":=ObjMembershipApplication."Individual Category";
        ObjEntitiesRiskRating."Customer Category Score":=VarCategoryScore;
        ObjEntitiesRiskRating."What is the Member residency?":=ObjMembershipApplication."Member Residency Status";
        ObjEntitiesRiskRating."Member Residency Score":=VarResidencyScore;
        ObjEntitiesRiskRating."Cust Employment Risk?":=ObjMembershipApplication.Entities;
        ObjEntitiesRiskRating."Cust Employment Risk Score":=VarEntityScore;
        ObjEntitiesRiskRating."Cust Business Risk Industry?":=ObjMembershipApplication."Industry Type";
        ObjEntitiesRiskRating."Cust Bus. Risk Industry Score":=VarIndustryScore;
        ObjEntitiesRiskRating."Lenght Of Relationship?":=ObjMembershipApplication."Length Of Relationship";
        ObjEntitiesRiskRating."Length Of Relation Score":=VarLenghtOfRelationshipScore;
        ObjEntitiesRiskRating."Cust Involved in Intern. Trade":=ObjMembershipApplication."International Trade";
        ObjEntitiesRiskRating."Involve in Inter. Trade Score":=VarInternationalTradeScore;
        ObjEntitiesRiskRating."Account Type Taken?":=FORMAT(VarAccountTypeOption);
        ObjEntitiesRiskRating."Account Type Taken Score":=VarAccountTypeScore;
        ObjEntitiesRiskRating."Card Type Taken":=ObjMembershipApplication."Cards Type Taken";
        ObjEntitiesRiskRating."Card Type Taken Score":=VarCardTypeScore;
        ObjEntitiesRiskRating."Channel Taken?":=ObjMembershipApplication."Others(Channels)";
        ObjEntitiesRiskRating."Channel Taken Score":=VarChannelTakenScore;
        ObjEntitiesRiskRating."Electronic Payments?":=ObjMembershipApplication."Electronic Payment";
        ObjEntitiesRiskRating."Electronic Payments Score":=VarElectronicPaymentScore;
        MemberTotalRiskRatingScore:=VarCategoryScore+VarEntityScore+VarIndustryScore+VarInternationalTradeScore+VarLenghtOfRelationshipScore+VarResidencyScore+VarAccountTypeScore
        +VarCardTypeScore+VarChannelTakenScore+VarElectronicPaymentScore;
        ObjEntitiesRiskRating."GROSS CUSTOMER AML RISK RATING":=MemberTotalRiskRatingScore;
        ObjEntitiesRiskRating."BANK'S CONTROL RISK RATING":=VarControlRiskRating;
        ObjEntitiesRiskRating."CUSTOMER NET RISK RATING":=ROUND(ObjEntitiesRiskRating."GROSS CUSTOMER AML RISK RATING"/ObjEntitiesRiskRating."BANK'S CONTROL RISK RATING",0.01,'>');
        MemberNetRiskScore:=MemberTotalRiskRatingScore/VarControlRiskRating;
        
        ObjEntitiesNetRiskScale.RESET;
        IF ObjEntitiesNetRiskScale.FINDSET THEN
          BEGIN
            REPEAT
            IF (MemberTotalRiskRatingScore>=ObjEntitiesNetRiskScale."Entry No") AND (MemberTotalRiskRatingScore<=ObjEntitiesNetRiskScale."Loan Application No") THEN BEGIN
             ObjEntitiesRiskRating."Risk Rate Scale":=ObjEntitiesNetRiskScale."Member No";
              VarRiskRatingDescription:=ObjEntitiesNetRiskScale.Names;
              END;
            UNTIL ObjEntitiesNetRiskScale.NEXT=0;
          END;
        ObjEntitiesRiskRating.INSERT;
        ObjEntitiesRiskRating.VALIDATE(ObjEntitiesRiskRating."Membership Application No");
        ObjEntitiesRiskRating.MODIFY;
        
        
        ObjMemberDueDiligence.RESET;
        ObjMemberDueDiligence.SETRANGE(ObjMemberDueDiligence."Member No",MemberNo);
        IF ObjMemberDueDiligence.FINDSET THEN
          BEGIN
            ObjMemberDueDiligence.DELETEALL;
            END;
        
        ObjDueDiligenceSetup.RESET;
        ObjDueDiligenceSetup.SETRANGE(ObjDueDiligenceSetup."Risk Rating Level",ObjEntitiesRiskRating."Risk Rate Scale");
        IF ObjDueDiligenceSetup.FINDSET THEN
          BEGIN
            REPEAT
              ObjMemberDueDiligence.INIT;
              ObjMemberDueDiligence."Member No":=MemberNo;
              IF ObjMembershipApplication.GET(MemberNo) THEN
                BEGIN
                  ObjMemberDueDiligence."Member Name":=ObjMembershipApplication.Name;
                  END;
              ObjMemberDueDiligence."Due Diligence No":=ObjDueDiligenceSetup."Due Diligence No";
              ObjMemberDueDiligence."Risk Rating Level":=ObjEntitiesRiskRating."Risk Rate Scale";
              ObjMemberDueDiligence."Risk Rating Scale":= VarRiskRatingDescription;
              ObjMemberDueDiligence."Due Diligence Type":=ObjDueDiligenceSetup."Due Diligence Type";
              ObjMemberDueDiligence."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Measure";
              ObjMemberDueDiligence.INSERT;
              UNTIL ObjDueDiligenceSetup.NEXT=0;
            END;
        
        ObjMembershipApplication.RESET;
        ObjMembershipApplication.SETRANGE(ObjMembershipApplication."No.",MemberNo);
        IF ObjMembershipApplication.FINDSET THEN
          BEGIN
            ObjMembershipApplication."Member Risk Level":=ObjEntitiesRiskRating."Risk Rate Scale";
            ObjMembershipApplication."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Type";
            ObjMembershipApplication.MODIFY;
            END;*/

    end;


    procedure FnGetMemberAMLRiskRating(MemberNo: Code[20])
    var
        VarCategoryScore: Integer;
        VarResidencyScore: Integer;
        VarNatureofBusinessScore: Integer;
        VarEntityScore: Integer;
        VarIndustryScore: Integer;
        VarLenghtOfRelationshipScore: Integer;
        VarInternationalTradeScore: Integer;
        VarElectronicPaymentScore: Integer;
        VarElectronicPayment: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarCardTypeScore: Integer;
        VarAccountTypeScore: Integer;
        VarChannelTakenScore: Integer;
        VarAccountTypeOption: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarChannelsTaken: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        MemberTotalRiskRatingScore: Decimal;
        MemberNetRiskScore: Decimal;
        VarMemberAnnualIncome: Decimal;
        ObjNetWorth: Record "Customer Net Income Risk Rates";
        ObjPeps: Record "Politically Exposed Persons";
        VarPepsRiskScore: Decimal;
        VarHighNet: Decimal;
        VarIndividualCategoryOption: Option "Politically Exposed Persons (PEPs)","High Net worth",Other,"Publicly Held Companies","Privately Held Companies","Domestic Government Entities",Churches,SMEs,Schools,"Welfare Groups","Financial entities Regulated by local regulators",Resident,"Non-Resident","Money Services Businesses","Charities and Non-Profit Organizations",Trusts,"Real Estate Agencies","High Value Goods Businesses","Precious Metals Businesses","Cash Intensive Businesses","Art Galleries & related businesses","Professional Service Providers","None of the above industries","0 – 1 Year","1 – 3 Years","Trade/Export Finance","Local Trade";
        VarLenghtOfRelationshipOption: Option "Politically Exposed Persons (PEPs)","High Net worth",Other,"Publicly Held Companies","Privately Held Companies","Domestic Government Entities",Churches,SMEs,Schools,"Welfare Groups","Financial entities Regulated by local regulators",Resident,"Non-Resident","Money Services Businesses","Charities and Non-Profit Organizations",Trusts,"Real Estate Agencies","High Value Goods Businesses","Precious Metals Businesses","Cash Intensive Businesses","Art Galleries & related businesses","Professional Service Providers","None of the above industries","0 – 1 Year","1 – 3 Years","Trade/Export Finance","Local Trade",">3";
        VarMemberSaccoAge: Integer;
        ObjMemberDueDiligence: Record "Member Due Diligence Measures";
        ObjDueDiligenceSetup: Record "Due Diligence Measures";
        VarRiskRatingDescription: Text[50];
        ObjControlRiskRating: Record "Control Risk Rating";
        VarControlRiskRating: Decimal;
        VarAccountTypeScoreVer1: Decimal;
        VarAccountTypeScoreVer2: Decimal;
        VarAccountTypeScoreVer3: Decimal;
        VarAccountTypeOptionVer1: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer2: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer3: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeScoreVer4: Decimal;
        VarAccountTypeOptionVer4: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        ObjProducts: Record Vendor;
        ObjMemberRiskRate: Record "Individual Customer Risk Rate";
        ObjRefereeSetup: Record "Referee Risk Rating Scale";
        VarRefereeScore: Decimal;
        VarRefereeRiskRate: Text;
        ObjLoans: Record "Loans Register";
    begin
        /*
        //==============================================================================================Member Category(High Net Worth|PEPS|Others)
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
        
        
           //==============================================================================High Net Worth
            ObjNetWorth.RESET;
            IF ObjNetWorth.FINDSET THEN
              BEGIN
                REPEAT
                IF (ObjMembers."Expected Monthly Income Amount">=ObjNetWorth."Min Monthly Income") AND
                  (ObjMembers."Expected Monthly Income Amount"<=ObjNetWorth."Max Monthlyl Income") THEN
                   BEGIN
                  VarHighNet:=ObjNetWorth."Risk Rate";
                  MESSAGE('VarHighNet is %1',VarHighNet);
                  END;
                UNTIL ObjNetWorth.NEXT=0;
              END;
            //==========================================================================End High Net Worth
        
          //====================================================================Politicall Exposed Persons
        
          {IF VarFirstName='' THEN
          VarFirstName:='$$';
          IF VarMidlleName='' THEN
            VarMidlleName:='$$';
          IF VarLastName='' THEN
            VarLastName:='$$';
        
          VarFirstName:=ObjMembers.First
          }
          {ObjPeps.RESET;
          ObjPeps.RESET;
          //ObjPeps.SETFILTER(ObjPeps.Name,'(%1&%2)|(%3&%4)|(%5&%6)','*'+VarFirstName+'*', '*'+VarMidlleName+'*','*'+VarFirstName+'*','*'+VarLastName+'*','*'+VarMidlleName+'*','*'+VarLastName+'*');
          IF ObjPeps.FINDSET THEN
            BEGIN
               ObjCustRiskRates.RESET;
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"Politically Exposed Persons (PEPs)");
               IF ObjCustRiskRates.FINDSET THEN
                 BEGIN
                   VarPepsRiskScore:=ObjCustRiskRates."Risk Score";
                   END;
              END;
          //================================================================End Politicall Exposed Persons}
        
          IF (VarHighNet<5) AND (VarPepsRiskScore=0) THEN
            BEGIN
        
               ObjCustRiskRates.RESET;
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::Other);
               IF ObjCustRiskRates.FINDSET THEN
                 BEGIN
                   VarCategoryScore:=ObjCustRiskRates."Risk Score";
                   VarIndividualCategoryOption:=VarIndividualCategoryOption::Other;
                   END;
        
               END ELSE
                IF (VarHighNet=5) AND (VarPepsRiskScore=0) THEN
                  BEGIN
        
                  ObjCustRiskRates.RESET;
                  ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
                  ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"High Net worth");
                  IF ObjCustRiskRates.FINDSET THEN
                    BEGIN
                      VarCategoryScore:=ObjCustRiskRates."Risk Score";
                      VarIndividualCategoryOption:=VarIndividualCategoryOption::"High Net worth";
                      END;
        
                  END ELSE
                    IF (VarHighNet<>5) AND (VarPepsRiskScore=5) THEN
                      BEGIN
        
                      ObjCustRiskRates.RESET;
                      ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
                      ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"Politically Exposed Persons (PEPs)");
                      IF ObjCustRiskRates.FINDSET THEN
                        BEGIN
                          VarCategoryScore:=ObjCustRiskRates."Risk Score";
                          VarIndividualCategoryOption:=VarIndividualCategoryOption::"Politically Exposed Persons (PEPs)";
                          END;
                    END;
           END;
        //=========================================================================END Member Category(High Net Worth|PEPS|Others)
        
        
        //=========================================================================Check Entities
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
          ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Entities);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers.Entities);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarEntityScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        //========================================================================Check Member Residency
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        //=======================================================================Check Member Industry
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Industry);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Industry Type");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarIndustryScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        //======================================================================Lenght Of Relationship
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           IF ObjMembers."Registration Date"<>0D THEN
           VarMemberSaccoAge:=ROUND((WORKDATE-ObjMembers."Registration Date")/365,1,'<');
        
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Length Of Relationship");
            IF ObjCustRiskRates.FINDSET THEN
              BEGIN
                REPEAT
                IF (VarMemberSaccoAge>=ObjCustRiskRates."Min Relationship Length(Years)") AND
                 (VarMemberSaccoAge<=ObjCustRiskRates."Max Relationship Length(Years)") THEN
                 BEGIN
                 VarLenghtOfRelationshipScore:=ObjCustRiskRates."Risk Score";
                 VarLenghtOfRelationshipOption:=ObjCustRiskRates."Sub Category Option";
                  END;
                UNTIL ObjNetWorth.NEXT=0;
              END;
         END;
        
        //======================================================================================Check For International Trade
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"International Trade");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."International Trade");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarInternationalTradeScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        //==============================================================================Check Electronic Payments
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        ObjMembers.SETRANGE(ObjMembers."Is Mobile Registered",FALSE);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Electronic Payment");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
              VarElectronicPayment:=VarElectronicPayment::"None of the Above";
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        ObjMembers.SETRANGE(ObjMembers."Is Mobile Registered",TRUE);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','Mobile Transfers');
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarElectronicPayment:=VarElectronicPayment::"Mobile Transfers";
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        
        //ObjProductRiskRating.GET();
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
          //======================================================================Check Card Type Taken
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Cards Type Taken");//VarCardType
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarCardTypeScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
           //================================================================Check Account Type Taken
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Accounts Type Taken");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
               END;
        
        
        
           ObjChequeBook.CALCFIELDS(ObjChequeBook."Member No");
           ObjChequeBook.RESET;
           ObjChequeBook.SETRANGE(ObjChequeBook."Member No",MemberNo);
           IF NOT ObjChequeBook.FINDSET THEN
           BEGIN
             ObjProductRiskRating.RESET;
             ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Others(Channels)");
             IF ObjCustRiskRates.FINDSET THEN
               BEGIN
               VarChannelsTaken:=VarChannelsTaken::Others;
                 VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
                 END;
        
          END ELSE
        
             ObjProductRiskRating.RESET;
             ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",'%1','Cheque book');
             IF ObjProductRiskRating.FINDSET THEN
               BEGIN
                 VarChannelsTaken:=VarChannelsTaken::"Cheque book";
                 VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
                 END;
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Global Dimension 1 Code",'<>%1','FOSA');
         IF ObjProducts.FINDSET THEN
            BEGIN
               REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"12");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer1:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer1:=ObjProductRiskRating."Product Type"::"12";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"12";
                   END;
                 UNTIL ObjProducts.NEXT=0;
            END;
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Global Dimension 1 Code",'%1','FOSA');
         ObjProducts.SETFILTER(ObjProducts."Account Type",'<>%1|%2','503','506');
         IF ObjProducts.FINDSET THEN
            BEGIN
        
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','FOSA (KSA, Imara, Heritage, MJA)');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer2:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer2:=ObjProductRiskRating."Product Type"::"5";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"5";
                   END;
                   UNTIL ObjProducts.NEXT=0;
            END;
        
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Account Type",'%1|%2','503','506');
         IF ObjProducts.FINDSET THEN
            BEGIN
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"4");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer3:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer3:=ObjProductRiskRating."Product Type"::"4";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"4";
                   END;
                   UNTIL ObjProducts.NEXT=0;
            END;
        
        
         ObjLoans.RESET;
         ObjLoans.CALCFIELDS(ObjLoans."Outstanding Balance");
         ObjLoans.SETRANGE(ObjLoans."Client Code",MemberNo);
         ObjLoans.SETFILTER(ObjLoans."Outstanding Balance",'>%1',0);
         IF ObjLoans.FINDSET THEN
            BEGIN
            ObjLoans.CALCFIELDS(ObjLoans."Outstanding Balance");
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','All Loan Accounts');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer4:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer4:=ObjProductRiskRating."Product Type"::"8";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"8";
        
                   END;
            END;
        
        IF (VarAccountTypeScoreVer1>VarAccountTypeScoreVer2) AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer3)
         AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer1;
          VarAccountTypeOption:=VarAccountTypeOptionVer1
          END ELSE
        IF (VarAccountTypeScoreVer2>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer2>VarAccountTypeScoreVer3)
        AND (VarAccountTypeScoreVer2>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer2;
          VarAccountTypeOption:=VarAccountTypeOptionVer2
         END ELSE
        IF (VarAccountTypeScoreVer3>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer3>VarAccountTypeScoreVer2)
        AND (VarAccountTypeScoreVer3>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer3;
          VarAccountTypeOption:=VarAccountTypeOptionVer3
          END ELSE
          IF (VarAccountTypeScoreVer4>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer4>VarAccountTypeScoreVer2)
          AND (VarAccountTypeScoreVer4>VarAccountTypeScoreVer3)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer4;
          VarAccountTypeOption:=VarAccountTypeOptionVer4
          END;
        
        
        
        //=============================================================================Check Referee
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           //=============================================================Exisiting Referee
           ObjMemberRiskRate.RESET;
           ObjMemberRiskRate.SETRANGE(ObjMemberRiskRate."Membership Application No",ObjMembers."Referee Member No");
           IF ObjMemberRiskRate.FINDSET THEN
             BEGIN
               IF ObjMembers."Referee Member No"<>'' THEN
                BEGIN
        
                ObjRefereeSetup.RESET;
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                    REPEAT
                    IF (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING">=ObjRefereeSetup."Minimum Risk Rate") AND
                      (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING"<=ObjRefereeSetup."Maximum Risk Rate") THEN
                      BEGIN
                      VarRefereeScore:=ObjRefereeSetup.Score;
                      VarRefereeRiskRate:=ObjRefereeSetup.Description;
                      END;
                    UNTIL ObjRefereeSetup.NEXT=0;
                  END;
                 END;
               END;
            //=============================================================No Referee
            IF ObjMembers."Referee Member No"='' THEN
              BEGIN
                ObjRefereeSetup.RESET;
                ObjRefereeSetup.SETFILTER(ObjRefereeSetup.Description,'%1','Others with no referee');
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                  VarRefereeScore:=ObjRefereeSetup.Score;
                  VarRefereeRiskRate:='Others with no referee';
                  END;
                END;
               END;
        
        //=============================================================Create Entries on Membership Risk Rating Table
        ObjMemberRiskRating.RESET;
        ObjMemberRiskRating.SETRANGE(ObjMemberRiskRating."Membership Application No",MemberNo);
        IF ObjMemberRiskRating.FINDSET THEN
          BEGIN
            ObjMemberRiskRating.DELETEALL;
            END;
        
        
        IF ObjMembers.GET(MemberNo) THEN
          BEGIN
            ObjMembers."Individual Category":=FORMAT(VarIndividualCategoryOption);
            ObjMembers."Length Of Relationship":=FORMAT(VarLenghtOfRelationshipOption);
            ObjMembers."Accounts Type Taken":=FORMAT(VarAccountTypeOption);
            ObjMembers.MODIFY;
             END;
        
        
        //===============================================Get Control Risk Rating
        ObjControlRiskRating.RESET;
        IF ObjControlRiskRating.FINDSET THEN
          BEGIN
          ObjControlRiskRating.CALCSUMS(ObjControlRiskRating."Control Weight Aggregate");
          VarControlRiskRating:=ObjControlRiskRating."Control Weight Aggregate";
          END;
        
        ObjMemberRiskRating.INIT;
        ObjMemberRiskRating."Membership Application No":=MemberNo;
        ObjMemberRiskRating."What is the Customer Category?":=FORMAT(VarIndividualCategoryOption);
        ObjMemberRiskRating."Customer Category Score":=VarCategoryScore;
        ObjMemberRiskRating."What is the Member residency?":=ObjMembers."Member Residency Status";
        ObjMemberRiskRating."Member Residency Score":=VarResidencyScore;
        ObjMemberRiskRating."Cust Employment Risk?":=ObjMembers.Entities;
        ObjMemberRiskRating."Cust Employment Risk Score":=VarEntityScore;
        ObjMemberRiskRating."Cust Business Risk Industry?":=ObjMembers."Industry Type";
        ObjMemberRiskRating."Cust Bus. Risk Industry Score":=VarIndustryScore;
        ObjMemberRiskRating."Lenght Of Relationship?":=FORMAT(VarLenghtOfRelationshipOption);
        ObjMemberRiskRating."Length Of Relation Score":=VarLenghtOfRelationshipScore;
        ObjMemberRiskRating."Cust Involved in Intern. Trade":=ObjMembers."International Trade";
        ObjMemberRiskRating."Involve in Inter. Trade Score":=VarInternationalTradeScore;
        ObjMemberRiskRating."Account Type Taken?":=FORMAT(VarAccountTypeOption);
        ObjMemberRiskRating."Account Type Taken Score":=VarAccountTypeScore;
        ObjMemberRiskRating."Card Type Taken":=ObjMembers."Cards Type Taken";
        ObjMemberRiskRating."Card Type Taken Score":=VarCardTypeScore;
        ObjMemberRiskRating."Channel Taken?":=FORMAT(VarChannelsTaken);
        ObjMemberRiskRating."Channel Taken Score":=VarChannelTakenScore;
        ObjMemberRiskRating."Referee Score":=VarRefereeScore;
        ObjMemberRiskRating."Member Referee Rate":=VarRefereeRiskRate;
        ObjMemberRiskRating."Electronic Payments?":=FORMAT(VarElectronicPayment);
        ObjMemberRiskRating."Electronic Payments Score":=VarElectronicPaymentScore;
        MemberTotalRiskRatingScore:=VarCategoryScore+VarEntityScore+VarIndustryScore+VarInternationalTradeScore+VarRefereeScore+VarLenghtOfRelationshipScore+VarResidencyScore+VarAccountTypeScore
        +VarCardTypeScore+VarChannelTakenScore+VarElectronicPaymentScore;
        ObjMemberRiskRating."GROSS CUSTOMER AML RISK RATING":=MemberTotalRiskRatingScore;
        ObjMemberRiskRating."BANK'S CONTROL RISK RATING":=VarControlRiskRating;
        ObjMemberRiskRating."CUSTOMER NET RISK RATING":=ROUND(ObjMemberRiskRating."GROSS CUSTOMER AML RISK RATING"/ObjMemberRiskRating."BANK'S CONTROL RISK RATING",0.5,'>');
        MemberNetRiskScore:=MemberTotalRiskRatingScore/VarControlRiskRating;
        
        ObjNetRiskScale.RESET;
        IF ObjNetRiskScale.FINDSET THEN
          BEGIN
            REPEAT
            IF (MemberTotalRiskRatingScore>=ObjNetRiskScale."Minimum Risk Rate") AND (MemberTotalRiskRatingScore<=ObjNetRiskScale."Maximum Risk Rate") THEN BEGIN
             ObjMemberRiskRating."Risk Rate Scale":=ObjNetRiskScale."Risk Scale";
              VarRiskRatingDescription:=ObjNetRiskScale.Description;
              END;
            UNTIL ObjNetRiskScale.NEXT=0;
          END;
        ObjMemberRiskRating.INSERT;
        ObjMemberRiskRating.VALIDATE(ObjMemberRiskRating."Membership Application No");
        ObjMemberRiskRating.MODIFY;
        
        
        ObjMemberDueDiligence.RESET;
        ObjMemberDueDiligence.SETRANGE(ObjMemberDueDiligence."Member No",MemberNo);
        IF ObjMemberDueDiligence.FINDSET THEN
          BEGIN
            ObjMemberDueDiligence.DELETEALL;
            END;
        
        ObjDueDiligenceSetup.RESET;
        ObjDueDiligenceSetup.SETRANGE(ObjDueDiligenceSetup."Risk Rating Level",ObjMemberRiskRating."Risk Rate Scale");
        IF ObjDueDiligenceSetup.FINDSET THEN
          BEGIN
            REPEAT
              ObjMemberDueDiligence.INIT;
              ObjMemberDueDiligence."Member No":=MemberNo;
              IF ObjMembers.GET(MemberNo) THEN
                BEGIN
                  ObjMemberDueDiligence."Member Name":=ObjMembers.Name;
                  END;
        
              ObjMemberDueDiligence."Due Diligence No":=ObjDueDiligenceSetup."Due Diligence No";
              ObjMemberDueDiligence."Risk Rating Level":=ObjMemberRiskRating."Risk Rate Scale";
              ObjMemberDueDiligence."Risk Rating Scale":= VarRiskRatingDescription;
              ObjMemberDueDiligence."Due Diligence Type":=ObjDueDiligenceSetup."Due Diligence Type";
              ObjMemberDueDiligence."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Measure";
              ObjMemberDueDiligence.INSERT;
              UNTIL ObjDueDiligenceSetup.NEXT=0;
            END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
          BEGIN
            ObjMembers.CALCFIELDS(ObjMembers."Has ATM Card");
            ObjMembers."Individual Category":=FORMAT(VarIndividualCategoryOption);
            ObjMembers."Member Residency Status":=ObjMembers."Member Residency Status";
            ObjMembers.Entities:=ObjMembers.Entities;
            ObjMembers."Industry Type":=ObjMembers."Industry Type";
            ObjMembers."Length Of Relationship":=FORMAT(VarLenghtOfRelationshipOption);
            ObjMembers."International Trade":=ObjMembers."International Trade";
            ObjMembers."Accounts Type Taken":=FORMAT(VarAccountTypeOption);
            IF ObjMembers."Has ATM Card"=TRUE THEN
            ObjMembers."Cards Type Taken":='ATM Debit'
            ELSE
            ObjMembers."Cards Type Taken":='None';
            ObjMembers."Others(Channels)":=FORMAT(VarChannelsTaken);
            ObjMembers."Referee Risk Rate":=VarRefereeRiskRate;
            ObjMembers."Electronic Payment":=FORMAT(VarElectronicPayment);
            ObjMembers."Member Risk Level":=ObjMemberRiskRating."Risk Rate Scale";
            ObjMembers."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Type";
            ObjMembers.MODIFY;
            END;*/

    end;


    procedure FnGetEntitiesAMLRiskRating(MemberNo: Code[20])
    var
        VarCategoryScore: Integer;
        VarResidencyScore: Integer;
        VarNatureofBusinessScore: Integer;
        VarEntityScore: Integer;
        VarIndustryScore: Integer;
        VarLenghtOfRelationshipScore: Integer;
        VarInternationalTradeScore: Integer;
        VarElectronicPaymentScore: Integer;
        VarCardTypeScore: Integer;
        VarAccountTypeScore: Integer;
        VarChannelTakenScore: Integer;
        VarAccountTypeOption: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        MemberTotalRiskRatingScore: Decimal;
        MemberNetRiskScore: Decimal;
        ObjMemberDueDiligence: Record "Member Due Diligence Measures";
        ObjDueDiligenceSetup: Record "Due Diligence Measures";
        VarRiskRatingDescription: Text[50];
        ObjControlRiskRating: Record "Control Risk Rating";
        VarControlRiskRating: Decimal;
        ObjMemberRiskRate: Record "Individual Customer Risk Rate";
        ObjRefereeSetup: Record "Referee Risk Rating Scale";
        VarRefereeScore: Decimal;
        VarRefereeRiskRate: Text;
        VarAccountTypeScoreVer1: Decimal;
        VarAccountTypeScoreVer2: Decimal;
        VarAccountTypeScoreVer3: Decimal;
        VarAccountTypeOptionVer1: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer2: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeOptionVer3: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarAccountTypeScoreVer4: Decimal;
        VarAccountTypeOptionVer4: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        ObjNetWorth: Record "Customer Net Income Risk Rates";
        ObjPeps: Record "Politically Exposed Persons";
        VarPepsRiskScore: Decimal;
        VarHighNet: Decimal;
        VarIndividualCategoryOption: Option "Politically Exposed Persons (PEPs)","High Net worth",Other,"Publicly Held Companies","Privately Held Companies","Domestic Government Entities",Churches,SMEs,Schools,"Welfare Groups","Financial entities Regulated by local regulators",Resident,"Non-Resident","Money Services Businesses","Charities and Non-Profit Organizations",Trusts,"Real Estate Agencies","High Value Goods Businesses","Precious Metals Businesses","Cash Intensive Businesses","Art Galleries & related businesses","Professional Service Providers","None of the above industries","0 – 1 Year","1 – 3 Years","Trade/Export Finance","Local Trade";
        VarLenghtOfRelationshipOption: Option "Politically Exposed Persons (PEPs)","High Net worth",Other,"Publicly Held Companies","Privately Held Companies","Domestic Government Entities",Churches,SMEs,Schools,"Welfare Groups","Financial entities Regulated by local regulators",Resident,"Non-Resident","Money Services Businesses","Charities and Non-Profit Organizations",Trusts,"Real Estate Agencies","High Value Goods Businesses","Precious Metals Businesses","Cash Intensive Businesses","Art Galleries & related businesses","Professional Service Providers","None of the above industries","0 – 1 Year","1 – 3 Years","Trade/Export Finance","Local Trade",">3";
        VarMemberSaccoAge: Integer;
        ObjProducts: Record Vendor;
        ObjChequeBook: Record "Cheque Book Application";
        VarElectronicPayment: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
        VarChannelsTaken: Option "International Wire Transfers","Local Wire Transfers","Mobile Transfers","None of the Above","Fixed/Call Deposit Accounts","KSA/Imara/MJA/Heritage)","Account with Sealed Safe deposit","Account with  Open Safe Deposit","All Loan Accounts",BOSA," Ufalme","ATM Debit",Credit,Both,"None","Non-face to face channels","Unsolicited Account Origination e.g. Walk-Ins","Cheque book",Others;
    begin
        /*
        //==============================================================================================Member Category(High Net Worth|PEPS|Others)
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
        
        
           //==============================================================================High Net Worth
            ObjNetWorth.RESET;
            IF ObjNetWorth.FINDSET THEN
              BEGIN
                REPEAT
                IF (ObjMembers."Expected Monthly Income Amount">=ObjNetWorth."Min Monthly Income") AND
                  (ObjMembers."Expected Monthly Income Amount"<=ObjNetWorth."Max Monthlyl Income") THEN
                   BEGIN
                  VarHighNet:=ObjNetWorth."Risk Rate";
                  MESSAGE('VarHighNet is %1',VarHighNet);
                  END;
                UNTIL ObjNetWorth.NEXT=0;
              END;
            //==========================================================================End High Net Worth
        
          //====================================================================Politicall Exposed Persons
        
          {IF VarFirstName='' THEN
          VarFirstName:='$$';
          IF VarMidlleName='' THEN
            VarMidlleName:='$$';
          IF VarLastName='' THEN
            VarLastName:='$$';
        
          VarFirstName:=ObjMembers.First
          }
          {ObjPeps.RESET;
          ObjPeps.RESET;
          //ObjPeps.SETFILTER(ObjPeps.Name,'(%1&%2)|(%3&%4)|(%5&%6)','*'+VarFirstName+'*', '*'+VarMidlleName+'*','*'+VarFirstName+'*','*'+VarLastName+'*','*'+VarMidlleName+'*','*'+VarLastName+'*');
          IF ObjPeps.FINDSET THEN
            BEGIN
               ObjCustRiskRates.RESET;
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"Politically Exposed Persons (PEPs)");
               IF ObjCustRiskRates.FINDSET THEN
                 BEGIN
                   VarPepsRiskScore:=ObjCustRiskRates."Risk Score";
                   END;
              END;
          //================================================================End Politicall Exposed Persons}
        
          IF (VarHighNet<5) AND (VarPepsRiskScore=0) THEN
            BEGIN
        
               ObjCustRiskRates.RESET;
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
               ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::Other);
               IF ObjCustRiskRates.FINDSET THEN
                 BEGIN
                   VarCategoryScore:=ObjCustRiskRates."Risk Score";
                   VarIndividualCategoryOption:=VarIndividualCategoryOption::Other;
                   END;
        
               END ELSE
                IF (VarHighNet=5) AND (VarPepsRiskScore=0) THEN
                  BEGIN
        
                  ObjCustRiskRates.RESET;
                  ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
                  ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"High Net worth");
                  IF ObjCustRiskRates.FINDSET THEN
                    BEGIN
                      VarCategoryScore:=ObjCustRiskRates."Risk Score";
                      VarIndividualCategoryOption:=VarIndividualCategoryOption::"High Net worth";
                      END;
        
                  END ELSE
                    IF (VarHighNet<>5) AND (VarPepsRiskScore=5) THEN
                      BEGIN
        
                      ObjCustRiskRates.RESET;
                      ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
                      ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category Option",ObjCustRiskRates."Sub Category Option"::"Politically Exposed Persons (PEPs)");
                      IF ObjCustRiskRates.FINDSET THEN
                        BEGIN
                          VarCategoryScore:=ObjCustRiskRates."Risk Score";
                          VarIndividualCategoryOption:=VarIndividualCategoryOption::"Politically Exposed Persons (PEPs)";
                          END;
                    END;
           END;
        //=========================================================================END Member Category(High Net Worth|PEPS|Others)
        
        
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Individuals);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Individual Category");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarCategoryScore:=ObjCustRiskRates."Risk Score";
               END;
           END;
        
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
          ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Entities);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers.Entities);
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarEntityScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           //=============================================================Exisiting Referee
           ObjMemberRiskRate.RESET;
           ObjMemberRiskRate.SETRANGE(ObjMemberRiskRate."Membership Application No",ObjMembers."Referee Member No");
           IF ObjMemberRiskRate.FINDSET THEN
             BEGIN
               IF ObjMembers."Referee Member No"<>'' THEN
                BEGIN
        
                ObjRefereeSetup.RESET;
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                    REPEAT
                    IF (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING">=ObjRefereeSetup."Minimum Risk Rate") AND
                      (ObjMemberRiskRate."GROSS CUSTOMER AML RISK RATING"<=ObjRefereeSetup."Maximum Risk Rate") THEN
                      BEGIN
                      VarRefereeScore:=ObjRefereeSetup.Score;
                      VarRefereeRiskRate:=ObjRefereeSetup.Description;
                      END;
                    UNTIL ObjRefereeSetup.NEXT=0;
                  END;
                 END;
        
            //=============================================================No Referee
            IF ObjMembers."Referee Member No"='' THEN
              BEGIN
                ObjRefereeSetup.RESET;
                ObjRefereeSetup.SETFILTER(ObjRefereeSetup.Description,'%1','Others with no referee');
                IF ObjRefereeSetup.FINDSET THEN
                  BEGIN
                  VarRefereeScore:=ObjRefereeSetup.Score;
                  VarRefereeRiskRate:='Others with no referee';
                  END;
                END;
               END;
        
        
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Residency Status");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Member Residency Status");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarResidencyScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::Industry);
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."Industry Type");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarIndustryScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        //======================================================================Lenght Of Relationship
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           IF ObjMembers."Registration Date"<>0D THEN
           VarMemberSaccoAge:=ROUND((WORKDATE-ObjMembers."Registration Date")/365,1,'<');
        
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"Length Of Relationship");
            IF ObjCustRiskRates.FINDSET THEN
              BEGIN
                REPEAT
                IF (VarMemberSaccoAge>=ObjCustRiskRates."Min Relationship Length(Years)") AND
                 (VarMemberSaccoAge<=ObjCustRiskRates."Max Relationship Length(Years)") THEN
                 BEGIN
                 VarLenghtOfRelationshipScore:=ObjCustRiskRates."Risk Score";
                 VarLenghtOfRelationshipOption:=ObjCustRiskRates."Sub Category Option";
                  END;
                UNTIL ObjCustRiskRates.NEXT=0;
              END;
         END;
        
        
        
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjCustRiskRates.RESET;
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates.Category,ObjCustRiskRates.Category::"International Trade");
           ObjCustRiskRates.SETRANGE(ObjCustRiskRates."Sub Category",ObjMembers."International Trade");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarInternationalTradeScore:=ObjCustRiskRates."Risk Score";
               END;
          END;
        
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        ObjMembers.SETRANGE(ObjMembers."Is Mobile Registered",FALSE);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Electronic Payment");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarElectronicPayment:=VarElectronicPayment::"None of the Above";
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        ObjMembers.SETRANGE(ObjMembers."Is Mobile Registered",TRUE);
        IF ObjMembers.FINDSET THEN
         BEGIN
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"0");
           ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','Mobile Transfers');
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarElectronicPayment:=VarElectronicPayment::"Mobile Transfers";
               VarElectronicPaymentScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
        
        //ObjProductRiskRating.GET();
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
         BEGIN
        
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Cards Type Taken");
           IF ObjProductRiskRating.FINDSET THEN
             BEGIN
               VarCardTypeScore:=ObjProductRiskRating."Risk Score";
               END;
          END;
        
           //================================================================Check Account Type Taken
           ObjProductRiskRating.RESET;
           ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"2");
           ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Accounts Type Taken");
           IF ObjCustRiskRates.FINDSET THEN
             BEGIN
               VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
               END;
        
           ObjChequeBook.CALCFIELDS(ObjChequeBook."Member No");
           ObjChequeBook.RESET;
           ObjChequeBook.SETRANGE(ObjChequeBook."Member No",MemberNo);
           IF NOT ObjChequeBook.FINDSET THEN
           BEGIN
             ObjProductRiskRating.RESET;
             ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",ObjMembers."Others(Channels)");
             IF ObjCustRiskRates.FINDSET THEN
               BEGIN
                  VarChannelsTaken:=VarChannelsTaken::Others;
                 VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
                 END;
        
          END ELSE
        
             ObjProductRiskRating.RESET;
             ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type Code");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"3");
             ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type Code",'%1','Cheque book');
             IF ObjCustRiskRates.FINDSET THEN
               BEGIN
                 VarChannelsTaken:=VarChannelsTaken::"Cheque book";
                 VarChannelTakenScore:=ObjProductRiskRating."Risk Score";
                 END;
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Global Dimension 1 Code",'<>%1','FOSA');
         IF ObjProducts.FINDSET THEN
            BEGIN
               REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"12");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer1:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer1:=ObjProductRiskRating."Product Type"::"12";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"12";
                   END;
                 UNTIL ObjProducts.NEXT=0;
            END;
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Global Dimension 1 Code",'%1','FOSA');
         ObjProducts.SETFILTER(ObjProducts."Account Type",'<>%1|%2','503','506');
         IF ObjProducts.FINDSET THEN
            BEGIN
        
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','FOSA (KSA, Imara, Heritage, MJA)');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer2:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer2:=ObjProductRiskRating."Product Type"::"5";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"5";
                   END;
                   UNTIL ObjProducts.NEXT=0;
            END;
        
        
         ObjProducts.RESET;
         ObjProducts.SETRANGE(ObjProducts."BOSA Account No",MemberNo);
         ObjProducts.SETFILTER(ObjProducts."Account Type",'%1|%2','503','506');
         IF ObjProducts.FINDSET THEN
            BEGIN
              REPEAT
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Type",ObjProductRiskRating."Product Type"::"4");
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer3:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer3:=ObjProductRiskRating."Product Type"::"4";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"4";
                   END;
                   UNTIL ObjProducts.NEXT=0;
            END;
        
        
         ObjLoans.RESET;
         ObjLoans.CALCFIELDS(ObjLoans."Outstanding Balance");
         ObjLoans.SETRANGE(ObjLoans."Client Code",MemberNo);
         ObjLoans.SETFILTER(ObjLoans."Outstanding Balance",'%1',0);
         IF ObjLoans.FINDSET THEN
            BEGIN
               ObjProductRiskRating.RESET;
               ObjProductRiskRating.SETCURRENTKEY(ObjProductRiskRating."Product Type");
               ObjProductRiskRating.SETRANGE(ObjProductRiskRating."Product Category",ObjProductRiskRating."Product Category"::"1");
               ObjProductRiskRating.SETFILTER(ObjProductRiskRating."Product Type Code",'%1','All Loan Accounts');
               IF ObjProductRiskRating.FINDSET THEN
                 BEGIN
                   VarAccountTypeScoreVer4:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOptionVer4:=ObjProductRiskRating."Product Type"::"8";
                   VarAccountTypeScore:=ObjProductRiskRating."Risk Score";
                   VarAccountTypeOption:=ObjProductRiskRating."Product Type"::"8";
                   END;
            END;
        
        IF (VarAccountTypeScoreVer1>VarAccountTypeScoreVer2) AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer3)
         AND (VarAccountTypeScoreVer1>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer1;
          VarAccountTypeOption:=VarAccountTypeOptionVer1
          END ELSE
        IF (VarAccountTypeScoreVer2>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer2>VarAccountTypeScoreVer3)
        AND (VarAccountTypeScoreVer2>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer2;
          VarAccountTypeOption:=VarAccountTypeOptionVer2
         END ELSE
        IF (VarAccountTypeScoreVer3>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer3>VarAccountTypeScoreVer2)
        AND (VarAccountTypeScoreVer3>VarAccountTypeScoreVer4)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer3;
          VarAccountTypeOption:=VarAccountTypeOptionVer3
          END ELSE
          IF (VarAccountTypeScoreVer4>VarAccountTypeScoreVer1) AND  (VarAccountTypeScoreVer4>VarAccountTypeScoreVer2)
          AND (VarAccountTypeScoreVer4>VarAccountTypeScoreVer3)THEN
          BEGIN
          VarAccountTypeScore:=VarAccountTypeScoreVer4;
          VarAccountTypeOption:=VarAccountTypeOptionVer4
          END;
        
        
        
        
        
        //Create Entries on Membership Risk Rating Table
        ObjEntitiesRiskRating.RESET;
        ObjEntitiesRiskRating.SETRANGE(ObjEntitiesRiskRating."Membership Application No",MemberNo);
        IF ObjEntitiesRiskRating.FINDSET THEN
          BEGIN
            ObjEntitiesRiskRating.DELETEALL;
            END;
        
        
        //===============================================Get Control Risk Rating
        ObjControlRiskRating.RESET;
        IF ObjControlRiskRating.FINDSET THEN
          BEGIN
          ObjControlRiskRating.CALCSUMS(ObjControlRiskRating."Control Weight Aggregate");
          VarControlRiskRating:=ObjControlRiskRating."Control Weight Aggregate";
          END;
        
        
        
        ObjEntitiesRiskRating.INIT;
        ObjEntitiesRiskRating."Membership Application No":=MemberNo;
        ObjEntitiesRiskRating."What is the Customer Category?":=ObjMembers."Individual Category";
        ObjEntitiesRiskRating."Customer Category Score":=VarCategoryScore;
        ObjEntitiesRiskRating."What is the Member residency?":=ObjMembers."Member Residency Status";
        ObjEntitiesRiskRating."Member Residency Score":=VarResidencyScore;
        ObjEntitiesRiskRating."Cust Employment Risk?":=ObjMembers.Entities;
        ObjEntitiesRiskRating."Cust Employment Risk Score":=VarEntityScore;
        ObjEntitiesRiskRating."Cust Business Risk Industry?":=ObjMembers."Industry Type";
        ObjEntitiesRiskRating."Cust Bus. Risk Industry Score":=VarIndustryScore;
        ObjEntitiesRiskRating."Lenght Of Relationship?":=FORMAT(VarLenghtOfRelationshipOption);
        ObjEntitiesRiskRating."Length Of Relation Score":=VarLenghtOfRelationshipScore;
        ObjEntitiesRiskRating."Cust Involved in Intern. Trade":=ObjMembers."International Trade";
        ObjEntitiesRiskRating."Involve in Inter. Trade Score":=VarInternationalTradeScore;
        ObjEntitiesRiskRating."Account Type Taken?":=FORMAT(VarAccountTypeOption);
        ObjEntitiesRiskRating."Account Type Taken Score":=VarAccountTypeScore;
        ObjEntitiesRiskRating."Card Type Taken":=ObjMembers."Cards Type Taken";
        ObjEntitiesRiskRating."Card Type Taken Score":=VarCardTypeScore;
        ObjEntitiesRiskRating."Channel Taken?":=FORMAT(VarChannelsTaken);
        ObjEntitiesRiskRating."Channel Taken Score":=VarChannelTakenScore;
        ObjEntitiesRiskRating."Electronic Payments?":=FORMAT(VarElectronicPayment);
        ObjEntitiesRiskRating."Electronic Payments Score":=VarElectronicPaymentScore;
        MemberTotalRiskRatingScore:=VarCategoryScore+VarEntityScore+VarIndustryScore+VarInternationalTradeScore+VarLenghtOfRelationshipScore+VarResidencyScore+VarAccountTypeScore
        +VarCardTypeScore+VarChannelTakenScore+VarElectronicPaymentScore;
        ObjEntitiesRiskRating."GROSS CUSTOMER AML RISK RATING":=MemberTotalRiskRatingScore;
        ObjEntitiesRiskRating."BANK'S CONTROL RISK RATING":=VarControlRiskRating;
        ObjEntitiesRiskRating."CUSTOMER NET RISK RATING":=ROUND(ObjEntitiesRiskRating."GROSS CUSTOMER AML RISK RATING"/ObjEntitiesRiskRating."BANK'S CONTROL RISK RATING",0.01,'>');
        MemberNetRiskScore:=MemberTotalRiskRatingScore/VarControlRiskRating;
        
        ObjEntitiesNetRiskScale.RESET;
        IF ObjEntitiesNetRiskScale.FINDSET THEN
          BEGIN
            REPEAT
            IF (MemberTotalRiskRatingScore>=ObjEntitiesNetRiskScale."Entry No") AND (MemberTotalRiskRatingScore<=ObjEntitiesNetRiskScale."Loan Application No") THEN BEGIN
             ObjEntitiesRiskRating."Risk Rate Scale":=ObjEntitiesNetRiskScale."Member No";
              VarRiskRatingDescription:=ObjEntitiesNetRiskScale.Names;
              END;
            UNTIL ObjEntitiesNetRiskScale.NEXT=0;
          END;
        ObjEntitiesRiskRating.INSERT;
        ObjEntitiesRiskRating.VALIDATE(ObjEntitiesRiskRating."Membership Application No");
        ObjEntitiesRiskRating.MODIFY;
        
        
        ObjMemberDueDiligence.RESET;
        ObjMemberDueDiligence.SETRANGE(ObjMemberDueDiligence."Member No",MemberNo);
        IF ObjMemberDueDiligence.FINDSET THEN
          BEGIN
            ObjMemberDueDiligence.DELETEALL;
            END;
        
        ObjDueDiligenceSetup.RESET;
        ObjDueDiligenceSetup.SETRANGE(ObjDueDiligenceSetup."Risk Rating Level",ObjEntitiesRiskRating."Risk Rate Scale");
        IF ObjDueDiligenceSetup.FINDSET THEN
          BEGIN
            REPEAT
              ObjMemberDueDiligence.INIT;
              ObjMemberDueDiligence."Member No":=MemberNo;
              IF ObjMembers.GET(MemberNo) THEN
                BEGIN
                  ObjMemberDueDiligence."Member Name":=ObjMembers.Name;
                  END;
              ObjMemberDueDiligence."Due Diligence No":=ObjDueDiligenceSetup."Due Diligence No";
              ObjMemberDueDiligence."Risk Rating Level":=ObjEntitiesRiskRating."Risk Rate Scale";
              ObjMemberDueDiligence."Risk Rating Scale":= VarRiskRatingDescription;
              ObjMemberDueDiligence."Due Diligence Type":=ObjDueDiligenceSetup."Due Diligence Type";
              ObjMemberDueDiligence."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Measure";
              ObjMemberDueDiligence.INSERT;
              UNTIL ObjDueDiligenceSetup.NEXT=0;
            END;
        
        ObjMembers.RESET;
        ObjMembers.SETRANGE(ObjMembers."No.",MemberNo);
        IF ObjMembers.FINDSET THEN
          BEGIN
            ObjMembers.CALCFIELDS(ObjMembers."Has ATM Card");
            ObjMembers."Individual Category":=FORMAT(VarIndividualCategoryOption);
            ObjMembers."Member Residency Status":=ObjMembers."Member Residency Status";
            ObjMembers.Entities:=ObjMembers.Entities;
            ObjMembers."Industry Type":=ObjMembers."Industry Type";
            ObjMembers."Length Of Relationship":=FORMAT(VarLenghtOfRelationshipOption);
            ObjMembers."International Trade":=ObjMembers."International Trade";
            ObjMembers."Accounts Type Taken":=FORMAT(VarAccountTypeOption);
            IF ObjMembers."Has ATM Card"=TRUE THEN
            ObjMembers."Cards Type Taken":='ATM Debit'
            ELSE
            ObjMembers."Cards Type Taken":='None';
            ObjMembers."Others(Channels)":=FORMAT(VarChannelsTaken);
            ObjMembers."Referee Risk Rate":=VarRefereeRiskRate;
            ObjMembers."Electronic Payment":=FORMAT(VarElectronicPayment);
            ObjMembers."Member Risk Level":=ObjMemberRiskRating."Risk Rate Scale";
            ObjMembers."Due Diligence Measure":=ObjDueDiligenceSetup."Due Diligence Type";
            ObjMembers.MODIFY;
            END;
            */

    end;

    procedure FnGetFilteredLoanBalance(Source: Option BOSA,FOSA,MICRO,ALL; AccountNo: Code[40]): Decimal
    var
        LnReg: Record "Loans Register";
        TheBalance: Decimal;
    begin
        TheBalance := 0;
        LnReg.Reset;
        case Source of
            Source::BOSA:
                begin
                    LnReg.SetRange(Source, LnReg.Source::BOSA);
                    LnReg.SetRange("Client Code", AccountNo);
                end;
            Source::FOSA:
                begin
                    LnReg.SetRange(Source, LnReg.Source::FOSA, LnReg.Source::MICRO);
                    LnReg.SetRange("Account No", AccountNo);
                end;
        end;
        LnReg.SetFilter("Outstanding Balance", '>0');
        LnReg.SetAutocalcFields("Outstanding Balance");
        if LnReg.FindSet then
            repeat
                TheBalance += LnReg."Outstanding Balance";
            until LnReg.Next = 0;

        exit(TheBalance);
    end;


    procedure FnGetFilteredLoanInterestBalance(Source: Option BOSA,FOSA,MICRO,ALL; AccountNo: Code[40]): Decimal
    var
        LnReg: Record "Loans Register";
        TheBalance: Decimal;
    begin
        TheBalance := 0;
        LnReg.Reset;
        case Source of
            Source::BOSA:
                begin
                    LnReg.SetRange(Source, LnReg.Source::BOSA);
                    LnReg.SetRange("Client Code", AccountNo);
                end;
            Source::FOSA:
                begin
                    LnReg.SetRange(Source, LnReg.Source::FOSA, LnReg.Source::MICRO);
                    LnReg.SetRange("Account No", AccountNo);
                end;
        end;
        LnReg.SetFilter("Oustanding Interest", '>0');
        LnReg.SetAutocalcFields("Oustanding Interest");
        if LnReg.FindSet then
            repeat
                TheBalance += LnReg."Oustanding Interest";
            until LnReg.Next = 0;

        exit(TheBalance);
    end;


    procedure FnSplitThisStringAndReturnStringNo(StringToSplit: Text; GetArrayNo: Integer) Output: Text
    var

    begin

    end;

    procedure FnGetMemberBranchUsingFosaAccount(MemberNo: Code[100]) MemberBranch: Code[100]
    var
        ObjMemberLocal: Record Customer;
    begin
        ObjMemberLocal.Reset;
        ObjMemberLocal.SetRange(ObjMemberLocal."FOSA Account", MemberNo);
        if ObjMemberLocal.Find('-') then begin
            MemberBranch := ObjMemberLocal."Global Dimension 2 Code";
        end;
        exit(MemberBranch);

    end;

    procedure FnGetActivityCode(AccountNo: Code[20]): Code[20]
    var
        ObjMemberLocal: Record Customer;
    begin
        ObjMemberLocal.reset;
        ObjMemberLocal.SetRange(ObjMemberLocal."No.", AccountNo);
        if ObjMemberLocal.find('-') then begin
            exit(ObjMemberLocal."Global Dimension 1 Code");
        end;
    end;

    procedure FnGetLoanClientCodeUsed(LoanNo: Code[20]): Code[50]
    var
        LoansRegister: Record "Loans Register";
    begin
        LoansRegister.reset;
        LoansRegister.SetRange(LoansRegister."Loan  No.", loanNo);
        if LoansRegister.find('-') then begin
            exit(LoansRegister."Client Code");
        end;
    end;

    procedure FnGetBranchCode(AccountNo: Code[20]): Code[20]
    var
        ObjMemberLocal: Record Customer;
    begin
        ObjMemberLocal.reset;
        ObjMemberLocal.SetRange(ObjMemberLocal."No.", AccountNo);
        if ObjMemberLocal.find('-') then begin
            exit(ObjMemberLocal."Global Dimension 2 Code");
        end;
    end;

    procedure GetMemberNo(AccountNo: Code[20]): Code[20]
    var
        ObjVendorLocal: Record Vendor;
    begin
        ObjVendorLocal.reset;
        ObjVendorLocal.SetRange(ObjVendorLocal."No.", AccountNo);
        if ObjVendorLocal.find('-') then begin
            exit(ObjVendorLocal."BOSA Account No");
        end;
    end;

    Procedure FnGetMemberMobileNo(AccountNo: Code[20]): text[100]
    var
        ObjVendorLocal: Record Vendor;
    begin
        ObjVendorLocal.reset;
        ObjVendorLocal.SetRange(ObjVendorLocal."BOSA Account No", AccountNo);
        if ObjVendorLocal.find('-') then begin
            exit(ObjVendorLocal."Mobile Phone No");
        end;
    end;

    procedure FnGetLoanType(LoanNo: code[50]): text[100];
    begin
        ObjLoans.reset;
        ObjLoans.setrange(ObjLoans."Loan  No.", LoanNo);
        if ObjLoans.Find('-') then begin
            exit(ObjLoans."Loan Product Type");
        end;
    end;

    procedure FnGetBOSAAccountNo(FOSAAccount: Code[50]): Code[30];
    var
        VendorTable: record Vendor;
    begin
        VendorTable.Reset();
        VendorTable.SetRange(VendorTable."No.", FOSAAccount);
        if VendorTable.Find('-') then begin
            exit(VendorTable."BOSA Account No");
        end;
    end;

    procedure CheckValidEmailAddresses(Recipients: Text)
    var
        TmpRecipients: Text;
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.', Comment = '%1 - Recipient email address';
    begin
        if Recipients = '' then
            Error(InvalidEmailAddressErr, Recipients);
        TmpRecipients := DelChr(Recipients, '<>', ';');
        while StrPos(TmpRecipients, ';') > 1 do begin
            CheckValidEmailAddress(CopyStr(TmpRecipients, 1, StrPos(TmpRecipients, ';') - 1));
            TmpRecipients := CopyStr(TmpRecipients, StrPos(TmpRecipients, ';') + 1);
        end;
        CheckValidEmailAddress(TmpRecipients);
    end;

    procedure FnGetDocumentApprover(DocumentNo: Code[20]): Code[100]
    var
        ApprovedEntries: Record "Posted Approval Entry";
    begin
        ApprovedEntries.Reset();
        ApprovedEntries.SetRange(ApprovedEntries."Document No.", DocumentNo);
        if ApprovedEntries.Find('-') then begin
            exit(ApprovedEntries."Approver ID");
        end;
        exit('Direct Posting');
    end;

    local procedure CheckValidEmailAddress(EmailAddress: Text)
    var
        EmailAccount: Codeunit "Email Account";
        IsHandled: Boolean;
        InvalidEmailAddressErr: Label 'The email address "%1" is not valid.', Comment = '%1 - Recipient email address';
        InvalidEmailDomainErr: Label 'The email address "%1" is domain name is not valid.', Comment = '%1 - Recipient email address';
        SpaceInEmailErr: Label 'The email address "%1" is not valid. It contains Spaces', Comment = '%1 - Recipient email address';

        FoundLetters: Boolean;
        FoundSpaces: Boolean;
    begin
        EmailAddress := DelChr(EmailAddress, '<>');

        // Check that only one address is validated.
        if EmailAddress.Split('@').Count() <> 2 then
            Error(InvalidEmailAddressErr, EmailAddress);

        if not EmailAccount.ValidateEmailAddress(EmailAddress) then
            Error(InvalidEmailAddressErr, EmailAddress);
        FoundLetters := (StrPos(EmailAddress, '.com') > 0) or (StrPos(EmailAddress, '.co.ke') > 0) or (StrPos(EmailAddress, '.org') > 0);
        if not FoundLetters then Error(InvalidEmailDomainErr, EmailAddress);

        FoundSpaces := (StrPos(EmailAddress, ' ') > 0);
        if FoundSpaces then Error(SpaceInEmailErr, EmailAddress);
    end;

    procedure FnGetAmountsCapitalised(LoanDisbursementDate: Date; LoanNo: Code[30]): Decimal
    var
        CustLedger: record "Cust. Ledger Entry";
        Totals: decimal;
    begin
        Totals := 0;
        CustLedger.Reset();
        CustLedger.SetRange(CustLedger."Loan No", LoanNo);
        CustLedger.SetRange(CustLedger."Transaction Type", CustLedger."Transaction Type"::Loan);
        CustLedger.SetRange(CustLedger."Posting Date", LoanDisbursementDate);
        if CustLedger.Find('-') then begin
            repeat
                Totals += CustLedger."Amount Posted";
            until CustLedger.Next = 0;
        end;
        exit(Totals);
    end;
    //.............................................................................................
    procedure FnCheckLoanConditionsAreMet(LoanNo: Code[50]; ClientCode: Code[50]; ProductType: Code[50])
    var
        LoanApp: record "Loans Register";
        LoanOffsetsTable: record "Loan Offset Details";
    begin
        //...................Before sending approval start
        //Ensure only offset can allow you to proceed with same product
        LoanApp.Reset;
        LoanApp.SetRange(LoanApp."Client Code", ClientCode);
        LoanApp.SetRange(LoanApp."Loan Product Type", ProductType);
        LoanApp.SetRange(LoanApp.Posted, true);
        if LoanApp.Find('-') then begin
            repeat
                LoanApp.CalcFields(LoanApp."Outstanding Balance");
                LoanApp.SetFilter(LoanApp."Outstanding Balance", '>%1', 0);
                if LoanApp."Outstanding Balance" > 0 then begin
                    LoanOffsetsTable.Reset();
                    LoanOffsetsTable.SetRange(LoanOffsetsTable."Loan Type", LoanApp."Loan Product Type");
                    if LoanOffsetsTable.Find('-') = false then begin
                        Error('Member has an active loan of the same product type applied. To proceed it MUST Be on offset basis');
                    end;
                end;
            until LoanApp.Next = 0;
        end;
        //...................Before sending Approval Stop
    end;

    procedure PreventLoanDoublePosting(LoanNo: Code[50]; ClientCode: Code[50]; ProductType: Code[50])
    var
        LoanApp: record "Loans Register";
        LoanOffsetsTable: record "Loan Offset Details";
    begin
        //...................Before sending approval start
        //Ensure only offset can allow you to proceed with same product
        LoanApp.Reset;
        LoanApp.SetRange(LoanApp."Client Code", ClientCode);
        LoanApp.SetRange(LoanApp."Loan Product Type", ProductType);
        LoanApp.SetRange(LoanApp.Posted, true);
        if LoanApp.Find('-') then begin
            repeat
                LoanApp.CalcFields(LoanApp."Outstanding Balance");
                if LoanApp."Outstanding Balance" > 0 then begin
                    LoanOffsetsTable.Reset();
                    LoanOffsetsTable.SetRange(LoanOffsetsTable."Loan Type", LoanApp."Loan Product Type");
                    if LoanOffsetsTable.Find('-') = false then begin
                        Error('Member has an active loan of the same product type [%1] applied already having a running balance of Ksh %2.', LoanOffsetsTable."Loan Type", LoanApp."Outstanding Balance");
                    end;
                end;
            until LoanApp.Next = 0;
        end;
        //Ensure no double posting loan of same product,if loan is approved...then other loans of same product that are approved but not posted itoe
        LoanApp.Reset;
        LoanApp.SetRange(LoanApp."Client Code", ClientCode);
        LoanApp.SetRange(LoanApp."Loan Product Type", ProductType);
        LoanApp.SetRange(LoanApp.Posted, true);
        if LoanApp.Find('-') then begin
            repeat
                LoanApp.CalcFields(LoanApp."Outstanding Balance");
                if LoanApp."Outstanding Balance" > 0 then begin
                    LoanOffsetsTable.Reset();
                    LoanOffsetsTable.SetRange(LoanOffsetsTable."Loan Type", LoanApp."Loan Product Type");
                    if LoanOffsetsTable.Find('-') = false then begin
                        Error('Member has an active loan of the same product type applied. To proceed it MUST Be on offset basis');
                    end;
                end;
            until LoanApp.Next = 0;
        end;
        //...................Before sending Approval Stop
    end;

    internal procedure FnGetAccountName(AccountNo: Code[30]): Text
    var
        GLaccount: record "G/L Account";
    begin
        GLaccount.RESET;
        GLaccount.SETRANGE(GLaccount."No.", AccountNo);
        IF GLaccount.FIND('-') THEN BEGIN
            EXIT(GLaccount.Name);
        END;
    end;

    procedure FnGenerateImportedLoansRepaymentSchedule(LoanNumber: Code[50]): Boolean
    var
        ObjLoans: Record "Loans Register";
        ObjRepaymentschedule: Record "Loan Repayment Schedule";
        ObjLoansII: Record "Loans Register";
        VarPeriodDueDate: Date;
        VarRunningDate: Date;
        VarGracePeiodEndDate: Date;
        VarInstalmentEnddate: Date;
        VarGracePerodDays: Integer;
        VarInstalmentDays: Integer;
        VarNoOfGracePeriod: Integer;
        VarLoanAmount: Decimal;
        VarInterestRate: Decimal;
        VarRepayPeriod: Integer;
        VarLBalance: Decimal;
        VarRunDate: Date;
        VarInstalNo: Decimal;
        VarRepayInterval: DateFormula;
        VarTotalMRepay: Decimal;
        VarLInterest: Decimal;
        VarLPrincipal: Decimal;
        VarLInsurance: Decimal;
        VarRepayCode: Code[30];
        VarGrPrinciple: Integer;
        VarGrInterest: Integer;
        VarQPrinciple: Decimal;
        VarQCounter: Integer;
        VarInPeriod: DateFormula;
        VarInitialInstal: Integer;
        VarInitialGraceInt: Integer;
        VarScheduleBal: Decimal;
        VarLNBalance: Decimal;
        ObjProductCharge: Record "Loan Product Charges";
        VarWhichDay: Integer;
        VarRepaymentStartDate: Date;
        VarMonthIncreament: Text;
        ScheduleEntryNo: Integer;
        saccogen: Record "Sacco General Set-Up";
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Loan  No.", LoanNumber);
        if ObjLoans.FindSet then begin
            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                Evaluate(VarInPeriod, '1D')
            else
                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                    Evaluate(VarInPeriod, '1W')
                else
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                        Evaluate(VarInPeriod, '1M')
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                            Evaluate(VarInPeriod, '1Q');

            VarRunDate := 0D;
            VarQCounter := 0;
            VarQCounter := 3;
            VarScheduleBal := 0;

            VarGrPrinciple := ObjLoans."Grace Period - Principle (M)";
            VarGrInterest := ObjLoans."Grace Period - Interest (M)";
            VarInitialGraceInt := ObjLoans."Grace Period - Interest (M)";


            ObjLoansII.Reset;
            ObjLoansII.SetRange(ObjLoansII."Loan  No.", LoanNumber);
            if ObjLoansII.Find('-') then begin
                ObjLoansII.CalcFields(ObjLoansII."Outstanding Balance");

                ObjLoans.TestField(ObjLoans."Loan Disbursement Date");
                ObjLoans.TestField(ObjLoans."Repayment Start Date");

                //=================================================================Delete From Tables
                ObjRepaymentschedule.Reset;
                ObjRepaymentschedule.SetRange(ObjRepaymentschedule."Loan No.", LoanNumber);
                if ObjRepaymentschedule.Find('-') then begin
                    ObjRepaymentschedule.DeleteAll;
                end;

                VarLoanAmount := FnGetAmountsCapitalised(ObjLoansII."Loan Disbursement Date", ObjLoansII."Loan  No.");
                if VarLoanAmount = 0 then VarLoanAmount := ObjLoansII."Approved Amount";
                if VarLoanAmount = 0 then VarLoanAmount := ObjLoansII."Outstanding Balance";
                if VarLoanAmount < ObjLoansII."Outstanding Balance" then VarLoanAmount := ObjLoansII."Outstanding Balance";
                VarInterestRate := ObjLoansII.Interest;
                VarRepayPeriod := ObjLoansII.Installments;
                VarInitialInstal := ObjLoansII.Installments + ObjLoansII."Grace Period - Principle (M)";
                VarLBalance := VarLoanAmount;
                VarLNBalance := FnGetAmountsCapitalised(ObjLoansII."Loan Disbursement Date", ObjLoansII."Loan  No.");
                if VarLNBalance = 0 then VarLNBalance := ObjLoansII."Approved Amount";
                if VarLNBalance = 0 then VarLNBalance := ObjLoansII."Outstanding Balance";
                if VarLNBalance < ObjLoansII."Outstanding Balance" then VarLNBalance := ObjLoansII."Outstanding Balance";
                VarRunDate := ObjLoansII."Repayment Start Date";
                VarRepaymentStartDate := ObjLoansII."Repayment Start Date";

                VarInstalNo := 0;
                Evaluate(VarRepayInterval, '1W');

                repeat
                    VarInstalNo := VarInstalNo + 1;
                    VarScheduleBal := VarLBalance;
                    ScheduleEntryNo := ScheduleEntryNo + 1;

                    //=======================================================================================Amortised
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Amortised
                       then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarTotalMRepay := ROUND((VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount, 1, '>');
                        VarTotalMRepay := (VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount;
                        VarLInterest := ROUND(VarLBalance / 100 / 12 * VarInterestRate);

                        VarLPrincipal := VarTotalMRepay - VarLInterest;
                    end;

                    //=======================================================================================Strainght Line
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Straight Line" then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 1200) * VarLoanAmount, 1, '>');
                        if VarInstalNo - ObjLoans."Grace Period - Interest (M)" = 1 then
                            VarLInterest := VarLInterest * VarInstalNo;

                        ObjLoans.Repayment := VarLPrincipal + VarLInterest;
                        ObjLoans."Loan Principle Repayment" := VarLPrincipal;
                        ObjLoans."Loan Interest Repayment" := VarLInterest;
                        ObjLoans.Modify;
                    end;

                    //=======================================================================================Reducing Balance
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Reducing Balance" then begin
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);//2828
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 12 / 100) * VarLBalance, 1, '>');

                    end;

                    //=======================================================================================Constant
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Constants then begin
                        ObjLoans.Repayment := ObjLoans."Approved Amount" / ObjLoans.Installments;
                        ObjLoans.Modify(true);
                        ObjLoans.TestField(ObjLoans.Repayment);
                        if VarLBalance < ObjLoans.Repayment then
                            VarLPrincipal := VarLBalance
                        else
                            VarLPrincipal := ObjLoans.Repayment;

                        VarLInterest := ObjLoans.Interest;

                    end;

                    VarLPrincipal := ROUND(VarLPrincipal, 1, '>');
                    Evaluate(VarRepayCode, Format(VarInstalNo));
                    //======================================================================================Grace Period
                    if VarLBalance < VarLPrincipal then
                        VarLPrincipal := VarLBalance
                    else
                        VarLPrincipal := VarLPrincipal;
                    if VarGrPrinciple > 0 then begin
                        VarLPrincipal := 0;
                        VarLInsurance := 0
                    end else begin
                        VarLBalance := VarLBalance - VarLPrincipal;
                        VarScheduleBal := VarScheduleBal - VarLPrincipal;
                    end;

                    if VarGrInterest > 0 then
                        VarLInterest := 0;

                    VarGrPrinciple := VarGrPrinciple - 1;
                    VarGrInterest := VarGrInterest - 1;


                    //======================================================================================Insert Repayment Schedule Table
                    if VarInstalNo <> 1 then begin
                        VarLInsurance := 0;
                    end;

                    ObjRepaymentschedule.Init;
                    //ObjRepaymentschedule."Entry No" := ScheduleEntryNo;
                    ObjRepaymentschedule."Repayment Code" := VarRepayCode;
                    ObjRepaymentschedule."Loan No." := ObjLoans."Loan  No.";
                    ObjRepaymentschedule."Loan Amount" := VarLoanAmount;
                    ObjRepaymentschedule."Interest Rate" := ObjLoans.Interest;
                    ObjRepaymentschedule."Instalment No" := VarInstalNo;
                    ObjRepaymentschedule."Repayment Date" := VarRunDate;//CALCDATE('CM',RunDate);
                    ObjRepaymentschedule."Member No." := ObjLoans."Client Code";
                    ObjRepaymentschedule."Loan Category" := ObjLoans."Loan Product Type";
                    ObjRepaymentschedule."Monthly Repayment" := VarLInterest + VarLPrincipal;
                    ObjRepaymentschedule."Monthly Interest" := VarLInterest;
                    ObjRepaymentschedule."Principal Repayment" := VarLPrincipal;
                    //ERROR(FORMAT(VarLPrincipal));
                    //ObjRepaymentschedule."Monthly Insurance" := VarLInsurance;
                    ObjRepaymentschedule."Loan Balance" := VarLBalance;
                    ObjRepaymentschedule.Insert;
                    VarWhichDay := Date2dwy(ObjRepaymentschedule."Repayment Date", 1);
                    //=======================================================================Get Next Repayment Date
                    VarMonthIncreament := Format(VarInstalNo) + 'M';
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                        VarRunDate := CalcDate('1D', VarRunDate)
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                            VarRunDate := CalcDate('1W', VarRunDate)
                        else
                            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                                VarRunDate := CalcDate(VarMonthIncreament, VarRepaymentStartDate)
                            else
                                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                                    VarRunDate := CalcDate('1Q', VarRunDate);

                until VarLBalance < 1
            end;
            Commit();
        end;
    end;

    procedure FnGenerateNewScheduleForLoans(LoanNumber: Code[50]; LoanAmountPassed: Decimal)
    var
        ObjLoans: Record "Loans Register";
        ObjRepaymentschedule: Record "Loan Repayment Schedule";
        ObjLoansII: Record "Loans Register";
        VarPeriodDueDate: Date;
        VarRunningDate: Date;
        VarGracePeiodEndDate: Date;
        VarInstalmentEnddate: Date;
        VarGracePerodDays: Integer;
        VarInstalmentDays: Integer;
        VarNoOfGracePeriod: Integer;
        VarLoanAmount: Decimal;
        VarInterestRate: Decimal;
        VarRepayPeriod: Integer;
        VarLBalance: Decimal;
        VarRunDate: Date;
        VarInstalNo: Decimal;
        VarRepayInterval: DateFormula;
        VarTotalMRepay: Decimal;
        VarLInterest: Decimal;
        VarLPrincipal: Decimal;
        VarLInsurance: Decimal;
        VarRepayCode: Code[30];
        VarGrPrinciple: Integer;
        VarGrInterest: Integer;
        VarQPrinciple: Decimal;
        VarQCounter: Integer;
        VarInPeriod: DateFormula;
        VarInitialInstal: Integer;
        VarInitialGraceInt: Integer;
        VarScheduleBal: Decimal;
        VarLNBalance: Decimal;
        ObjProductCharge: Record "Loan Product Charges";
        VarWhichDay: Integer;
        VarRepaymentStartDate: Date;
        VarMonthIncreament: Text;
        ScheduleEntryNo: Integer;
        saccogen: Record "Sacco General Set-Up";
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Loan  No.", LoanNumber);
        if ObjLoans.FindSet then begin
            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                Evaluate(VarInPeriod, '1D')
            else
                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                    Evaluate(VarInPeriod, '1W')
                else
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                        Evaluate(VarInPeriod, '1M')
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                            Evaluate(VarInPeriod, '1Q');

            VarRunDate := 0D;
            VarQCounter := 0;
            VarQCounter := 3;
            VarScheduleBal := 0;

            VarGrPrinciple := ObjLoans."Grace Period - Principle (M)";
            VarGrInterest := ObjLoans."Grace Period - Interest (M)";
            VarInitialGraceInt := ObjLoans."Grace Period - Interest (M)";


            ObjLoansII.Reset;
            ObjLoansII.SetRange(ObjLoansII."Loan  No.", LoanNumber);
            if ObjLoansII.Find('-') then begin
                ObjLoansII.CalcFields(ObjLoansII."Outstanding Balance");

                ObjLoans.TestField(ObjLoans."Loan Disbursement Date");
                ObjLoans.TestField(ObjLoans."Repayment Start Date");

                //=================================================================Delete From Tables
                ObjRepaymentschedule.Reset;
                ObjRepaymentschedule.SetRange(ObjRepaymentschedule."Loan No.", LoanNumber);
                if ObjRepaymentschedule.Find('-') then begin
                    ObjRepaymentschedule.DeleteAll;
                end;

                VarLoanAmount := LoanAmountPassed;
                VarInterestRate := ObjLoansII.Interest;
                VarRepayPeriod := ObjLoansII.Installments;
                VarInitialInstal := ObjLoansII.Installments + ObjLoansII."Grace Period - Principle (M)";
                VarLBalance := LoanAmountPassed;
                VarLNBalance := LoanAmountPassed;
                VarRunDate := ObjLoansII."Repayment Start Date";
                VarRepaymentStartDate := ObjLoansII."Repayment Start Date";

                VarInstalNo := 0;
                Evaluate(VarRepayInterval, '1W');

                repeat
                    VarInstalNo := VarInstalNo + 1;
                    VarScheduleBal := VarLBalance;
                    ScheduleEntryNo := ScheduleEntryNo + 1;

                    //=======================================================================================Amortised
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Amortised
                       then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarTotalMRepay := ROUND((VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount, 1, '>');
                        VarTotalMRepay := (VarInterestRate / 12 / 100) / (1 - Power((1 + (VarInterestRate / 12 / 100)), -VarRepayPeriod)) * VarLoanAmount;
                        VarLInterest := ROUND(VarLBalance / 100 / 12 * VarInterestRate);

                        VarLPrincipal := VarTotalMRepay - VarLInterest;
                    end;

                    //=======================================================================================Strainght Line
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Straight Line" then begin
                        ObjLoans.TestField(ObjLoans.Installments);
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 1200) * VarLoanAmount, 1, '>');
                        if VarInstalNo - ObjLoans."Grace Period - Interest (M)" = 1 then
                            VarLInterest := VarLInterest * VarInstalNo;

                        ObjLoans.Repayment := VarLPrincipal + VarLInterest;
                        ObjLoans."Loan Principle Repayment" := VarLPrincipal;
                        ObjLoans."Loan Interest Repayment" := VarLInterest;
                        ObjLoans.Modify;
                    end;

                    //=======================================================================================Reducing Balance
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::"Reducing Balance" then begin
                        ObjLoans.TestField(ObjLoans.Interest);
                        ObjLoans.TestField(ObjLoans.Installments);//2828
                        VarLPrincipal := ROUND(VarLoanAmount / VarRepayPeriod, 1, '>');
                        VarLInterest := ROUND((VarInterestRate / 12 / 100) * VarLBalance, 1, '>');

                    end;

                    //=======================================================================================Constant
                    if ObjLoans."Repayment Method" = ObjLoans."repayment method"::Constants then begin
                        ObjLoans.Repayment := ObjLoans."Approved Amount" / ObjLoans.Installments;
                        ObjLoans.Modify(true);
                        ObjLoans.TestField(ObjLoans.Repayment);
                        if VarLBalance < ObjLoans.Repayment then
                            VarLPrincipal := VarLBalance
                        else
                            VarLPrincipal := ObjLoans.Repayment;

                        VarLInterest := ObjLoans.Interest;

                    end;

                    VarLPrincipal := ROUND(VarLPrincipal, 1, '>');
                    Evaluate(VarRepayCode, Format(VarInstalNo));
                    //======================================================================================Grace Period
                    if VarLBalance < VarLPrincipal then
                        VarLPrincipal := VarLBalance
                    else
                        VarLPrincipal := VarLPrincipal;
                    if VarGrPrinciple > 0 then begin
                        VarLPrincipal := 0;
                        VarLInsurance := 0
                    end else begin
                        VarLBalance := VarLBalance - VarLPrincipal;
                        VarScheduleBal := VarScheduleBal - VarLPrincipal;
                    end;

                    if VarGrInterest > 0 then
                        VarLInterest := 0;

                    VarGrPrinciple := VarGrPrinciple - 1;
                    VarGrInterest := VarGrInterest - 1;


                    //======================================================================================Insert Repayment Schedule Table
                    if VarInstalNo <> 1 then begin
                        VarLInsurance := 0;
                    end;

                    ObjRepaymentschedule.Init;
                    //ObjRepaymentschedule."Entry No" := ScheduleEntryNo;
                    ObjRepaymentschedule."Repayment Code" := VarRepayCode;
                    ObjRepaymentschedule."Loan No." := ObjLoans."Loan  No.";
                    ObjRepaymentschedule."Loan Amount" := VarLoanAmount;
                    ObjRepaymentschedule."Interest Rate" := ObjLoans.Interest;
                    ObjRepaymentschedule."Instalment No" := VarInstalNo;
                    ObjRepaymentschedule."Repayment Date" := VarRunDate;//CALCDATE('CM',RunDate);
                    ObjRepaymentschedule."Member No." := ObjLoans."Client Code";
                    ObjRepaymentschedule."Loan Category" := ObjLoans."Loan Product Type";
                    ObjRepaymentschedule."Monthly Repayment" := VarLInterest + VarLPrincipal;
                    ObjRepaymentschedule."Monthly Interest" := VarLInterest;
                    ObjRepaymentschedule."Principal Repayment" := VarLPrincipal;
                    //ERROR(FORMAT(VarLPrincipal));
                    //ObjRepaymentschedule."Monthly Insurance" := VarLInsurance;
                    ObjRepaymentschedule."Loan Balance" := VarLBalance;
                    ObjRepaymentschedule.Insert;
                    VarWhichDay := Date2dwy(ObjRepaymentschedule."Repayment Date", 1);
                    //=======================================================================Get Next Repayment Date
                    VarMonthIncreament := Format(VarInstalNo) + 'M';
                    if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Daily then
                        VarRunDate := CalcDate('1D', VarRunDate)
                    else
                        if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Weekly then
                            VarRunDate := CalcDate('1W', VarRunDate)
                        else
                            if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Monthly then
                                VarRunDate := CalcDate(VarMonthIncreament, VarRepaymentStartDate)
                            else
                                if ObjLoans."Repayment Frequency" = ObjLoans."repayment frequency"::Quaterly then
                                    VarRunDate := CalcDate('1Q', VarRunDate);

                until VarLBalance < 1
            end;
            Commit();
        end;
    end;

    procedure FnGetDaysInArrears(AsAt: date; LoanNo: code[50]): Integer
    var
        LoansTable: record "Loans Register";
        LoanRepaymentSchedule: record "Loan Repayment schedule";
        AmountPaid: Decimal;
        ResetDate: date;
        DaysInArrears: Integer;
    begin
        AmountPaid := 0;
        LoansTable.RESET;
        LoansTable.SetRange(LoansTable."Loan  No.", LoanNo);
        IF LoansTable.FIND('-') THEN BEGIN
            LoansTable.SetFilter(LoansTable."Date Filter", '..%1', AsAt);
            LoansTable.CalcFields(LoansTable."Principal Paid");
            AmountPaid := (LoansTable."Principal Paid") * -1;
        END;
        ResetDate := 0D;
        DaysInArrears := 0;
        //Now Distribute Paid Amounts Until When The Payment Amount is exhausted
        LoanRepaymentSchedule.reset;
        LoanRepaymentSchedule.setrange(LoanRepaymentSchedule."Loan No.", LoanNo);
        LoanRepaymentSchedule.setfilter(LoanRepaymentSchedule."Repayment Date", '..%1', AsAt);
        if LoanRepaymentSchedule.find('-') then begin
            repeat
                ResetDate := 0D;
                ResetDate := LoanRepaymentSchedule."Repayment Date";
                AmountPaid := AmountPaid - LoanRepaymentSchedule."Principal Repayment";
            until (LoanRepaymentSchedule.NEXT = 0) or (AmountPaid <= 0);
            //Now Days In Arrears is asat - ResetDate
            DaysInArrears := AsAt - ResetDate;
        end;
        exit(DaysInArrears);
    end;
}

