#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51516026 "SwizzKashLivetest-notuse"
{

    trigger OnRun()
    begin
        //MESSAGE(RegisteredMemberDetailsUSSD('0741301635','000023456'));
        //MESSAGE(OutstandingLoansUSSD('0741301635'));
        //MESSAGE(LoanRepayment('000008','BLN00145','QWER122344',5000));
        //MESSAGE(MiniStatement('0741301635','124000014'));
        //MESSAGE(Accounts('0741301635','25195455'));
        //MESSAGE(Accounts('0741301635','99556'));
        //MESSAGE(MemberAccounts('0741301635'));
        //MESSAGE(AccountBalance('0741301635','15909652'));
        //MESSAGE(SurePESARegistration());Polytech
        //MESSAGE(WSSAccount('0702636777'));
        //SMSMessage('3457111','1234','0727758318','sms service test by mutinda');
        //MESSAGE(OutstandingLoanName('0741301635'));
        //MESSAGE(UpdateSurePESARegistration('BES000004'));
        //MESSAGE(LoanGuarantorsUSSD('LB15205','0729534407','27897'));
        //MESSAGE(MiniStatement('0741301635', '8855255'));
        //MESSAGE(OutstandingLoans('0741301635'));
        //MESSAGE(HolidayAcc('0729534407'));
        //MESSAGE(PayBillToAcc('SDWTYRES','lMNSW345','BES000615','703000541',100,'MNBBB'));
        //MESSAGE(InsertTransaction('mQ54190WSDS6','SHA','0729534407','Ngosa','0729534407',2000,7000));
        //MESSAGE(PaybillSwitch());
        //MESSAGE(Loancalculator(''));
        //MESSAGE(FundsTransferBOSA('0702673946','Share Capital','0100001025633',500));
        //MESSAGE(FnpostRemitanceDis('MS56T123024',10000,'0702636777'));
    end;

    var
        Vendor: Record Vendor;
        AccountTypes: Record 51516436;
        miniBalance: Decimal;
        accBalance: Decimal;
        minimunCount: Integer;
        VendorLedgEntry: Record "Vendor Ledger Entry";
        amount: Decimal;
        Loans: Integer;
        LoansRegister: Record 51516371;
        LoanProductsSetup: Record 51516381;
        Members: Record 51516364;
        dateExpression: Text[20];
        DetailedVendorLedgerEntry: Record "Detailed Vendor Ledg. Entry";
        dashboardDataFilter: Date;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        MemberLedgerEntry: Record 51516365;
        LoansTable: Record 51516371;
        SurePESAApplications: Record 51516521;
        GenJournalLine: Record "Gen. Journal Line";
        GenBatches: Record "Gen. Journal Batch";
        LineNo: Integer;
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        SurePESATrans: Record 51516522;
        GenLedgerSetup: Record "General Ledger Setup";
        Charges: Record 51516439;
        MobileCharges: Decimal;
        MobileChargesACC: Text[20];
        SurePESACommACC: Code[20];
        SurePESACharge: Decimal;
        ExcDuty: Decimal;
        TempBalance: Decimal;
        BOSATransSchedule: Record 51516406;
        SMSMessages: Record 51516471;
        iEntryNo: Integer;
        msg: Text[250];
        accountName1: Text[40];
        accountName2: Text[40];
        fosaAcc: Text[30];
        LoanGuaranteeDetails: Record 51516372;
        bosaNo: Text[20];
        RanNo: Text[20];
        PaybillTrans: Record 51516098;
        PaybillRecon: Code[10];
        ChargeAmount: Decimal;
        glamount: Decimal;
        LoanProducttype: Record 51516381;
        varLoan: Text[1024];
        MPESACharge: Decimal;
        MPESARecon: Code[100];
        TotalCharges: Decimal;
        ExxcDuty: label '11111';
        TariffDetails: Record 51516097;
        samount: Decimal;
        genstup: Record 51516398;
        Surefactory: Codeunit "Swizzsoft Factory.";
        LBatches: Record 51516377;
        Jtemplate: Code[30];
        JBatch: Code[30];
        DocNo: Code[30];
        SwizzKashCommACC: Code[20];
        SwizzKashCharge: Decimal;

    procedure AccountBalance(Acc: Code[30]; DocNumber: Code[20]) Bal: Text[500]
    begin

        Members.Reset;
        Members.SetRange(Members."No.", Acc);
        if Members.Find('-') then begin
            Members.CalcFields(Members."Balance (LCY)");
            accBalance := Members."Qualifying Shares";
            Bal := Format(accBalance);
        end;
    end;


    procedure MiniStatement(Phone: Text[20]; DocNumber: Text[20]) MiniStmt: Text[350]
    var
        mdate: Text;
        mdes: Text;
    begin

        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", Phone);
            if Members.FindSet then begin
                //Members.CALCFIELDS(Vendor.Balance);
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetCurrentkey(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.Ascending(false);
                MemberLedgerEntry.SetFilter(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                //VendorLedgEntry.SETFILTER(VendorLedgEntry.Description,'<>*Excise duty*');
                MemberLedgerEntry.SetRange(MemberLedgerEntry.Reversed, MemberLedgerEntry.Reversed::"0");
                if MemberLedgerEntry.FindSet then begin
                    MiniStmt := '';
                    repeat
                        amount := MemberLedgerEntry.Amount;
                        if amount < 1 then
                            amount := amount * -1;
                        mdate := Format(MemberLedgerEntry."Posting Date");
                        mdes := MemberLedgerEntry.Description;
                        if mdate = '' then begin
                            mdate := 'Date Missing'
                        end;
                        if mdes = '' then begin
                            mdes := 'Descr Missing'
                        end;
                        MiniStmt := MiniStmt + '::::' + Format(mdate) + ':::' + CopyStr(mdes, 1, 70) + ':::' +
                        Format(amount);
                        minimunCount := minimunCount + 1;
                        if minimunCount > 5 then
                            break
                      until MemberLedgerEntry.Next = 0;
                    MiniStmt := CopyStr(MiniStmt, 1, StrLen(MiniStmt) - 2);
                    //SMSMessage(DocNumber,Members."No.",Phone,' Your current ministatement '+MiniStmt);
                end;
            end
            else begin
                MiniStmt := 'You have INSUFFICIENT funds to use this service.';
            end;
        end;
    end;


    procedure LoanProducts() LoanTypes: Text[150]
    begin
        begin
            LoanProductsSetup.Reset;
            LoanProductsSetup.SetRange(LoanProductsSetup.Source, LoanProductsSetup.Source::FOSA);
            if LoanProductsSetup.Find('-') then begin
                repeat
                    LoanTypes := LoanTypes + ':::' + LoanProductsSetup."Product Description";
                until LoanProductsSetup.Next = 0;
            end
        end
    end;


    procedure BOSAAccount(Phone: Text[20]) bosaAcc: Text[20]
    begin
        begin
            Vendor.Reset;
            Vendor.SetRange(Vendor."Phone No.", Phone);
            if Vendor.Find('-') then begin
                bosaAcc := Vendor."BOSA Account No";
            end;
        end
    end;


    procedure MemberAccountNumbers(phone: Text[20]) accounts: Text[250]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            Members.SetRange(Members.Status, Members.Status::Active);
            if Members.Find('-') then begin
                accounts := '';
                repeat
                    accounts := accounts + '::::' + Members."No.";
                until Members.Next = 0;
            end
            else begin
                accounts := '';
            end
        end;
    end;


    procedure RegisteredMemberDetails(Phone: Text[20]) reginfo: Text[250]
    var
        idno: Text;
        email: Text;
        personal: Text;
        employerName: Text;
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", Phone);
            if Members.Find('-') then begin
                if Members."ID No." = '' then
                    idno := 'Empty'
                else
                    idno := Format(Members."ID No.");

                if Members."E-Mail" = '' then
                    email := 'Empty'
                else
                    email := Members."E-Mail";

                if Members."Personal No" = '' then
                    personal := 'Empty'
                else
                    personal := Members."Personal No";

                if Members."Employer Name" = '' then
                    employerName := 'Empty'
                else
                    employerName := Members."Employer Name";

                reginfo := Members."No." + ':::' + Members.Name + ':::' + idno + ':::' + personal + ':::' + email + ':::' + employerName;
            end
            else begin
                reginfo := '';
            end
        end;
    end;


    procedure DetailedStatement(Phone: Text[20]; lastEntry: Integer) detailedstatement: Text[1023]
    begin
        begin
            dateExpression := '<CD-1M>'; // Current date less 3 months
            dashboardDataFilter := CalcDate(dateExpression, Today);

            Vendor.Reset;
            Vendor.SetRange(Vendor."Phone No.", Phone);
            detailedstatement := '';
            if Vendor.FindSet then
                repeat
                    minimunCount := 1;
                    AccountTypes.Reset;
                    AccountTypes.SetRange(AccountTypes.Code, Vendor."Account Type");

                    if AccountTypes.FindSet then
                        repeat

                            DetailedVendorLedgerEntry.Reset;
                            DetailedVendorLedgerEntry.SetRange(DetailedVendorLedgerEntry."Vendor No.", Vendor."No.");
                            DetailedVendorLedgerEntry.SetFilter(DetailedVendorLedgerEntry."Entry No.", '>%1', lastEntry);
                            DetailedVendorLedgerEntry.SetFilter(DetailedVendorLedgerEntry."Posting Date", '>%1', dashboardDataFilter);

                            if DetailedVendorLedgerEntry.FindSet then
                                repeat

                                    VendorLedgerEntry.Reset;
                                    VendorLedgerEntry.SetRange(VendorLedgerEntry."Entry No.", DetailedVendorLedgerEntry."Vendor Ledger Entry No.");

                                    if VendorLedgerEntry.FindSet then begin
                                        if detailedstatement = ''
                                        then begin
                                            detailedstatement := Format(DetailedVendorLedgerEntry."Entry No.") + ':::' +
                                            Format(AccountTypes.Description) + ':::' +
                                            Format(DetailedVendorLedgerEntry."Posting Date") + ':::' +
                                            Format((DetailedVendorLedgerEntry."Posting Date"), 0, '<Month Text>') + ':::' +
                                            Format(Date2dmy((DetailedVendorLedgerEntry."Posting Date"), 3)) + ':::' +
                                            Format((DetailedVendorLedgerEntry."Credit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                            Format((DetailedVendorLedgerEntry."Debit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                            Format((DetailedVendorLedgerEntry.Amount), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                            Format(DetailedVendorLedgerEntry."Journal Batch Name") + ':::' +
                                            Format(DetailedVendorLedgerEntry."Initial Entry Global Dim. 1") + ':::' +
                                            Format(VendorLedgerEntry.Description);
                                        end
                                        else
                                            repeat
                                                detailedstatement := detailedstatement + '::::' +
                                                Format(DetailedVendorLedgerEntry."Entry No.") + ':::' +
                                                Format(AccountTypes.Description) + ':::' +
                                                Format(DetailedVendorLedgerEntry."Posting Date") + ':::' +
                                                Format((DetailedVendorLedgerEntry."Posting Date"), 0, '<Month Text>') + ':::' +
                                                Format(Date2dmy((DetailedVendorLedgerEntry."Posting Date"), 3)) + ':::' +
                                                Format((DetailedVendorLedgerEntry."Credit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                                Format((DetailedVendorLedgerEntry."Debit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                                Format((DetailedVendorLedgerEntry.Amount), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
                                                Format(DetailedVendorLedgerEntry."Journal Batch Name") + ':::' +
                                                Format(DetailedVendorLedgerEntry."Initial Entry Global Dim. 1") + ':::' +
                                                Format(VendorLedgerEntry.Description);

                                                if minimunCount > 20 then
                                                    exit
                                            until VendorLedgerEntry.Next = 0;
                                    end;
                                until DetailedVendorLedgerEntry.Next = 0;
                        until AccountTypes.Next = 0;
                until Vendor.Next = 0;
        end;
    end;


    procedure MemberAccountNames(phone: Text[20]) accounts: Text[250]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            //Members.SETRANGE(Members.Status, Members.Status::Active);
            if Members.Find('-') then begin
                accounts := '';
                repeat
                    accounts := accounts + '::::' + 'Guarantee free shares';
                until Members.Next = 0;
            end
            else begin
                accounts := '';
            end
        end;
    end;


    procedure LoanBalances(phone: Text[20]) loanbalances: Text[700]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                LoansTable.Reset;
                LoansTable.SetRange(LoansTable."Client Code", Members."No.");
                if LoansTable.Find('-') then begin
                    repeat
                        LoansTable.CalcFields(LoansTable."Outstanding Balance", LoansTable."Oustanding Interest", LoansTable."Interest to be paid", LoansTable."Interest Paid");
                        if (LoansTable."Outstanding Balance" > 0) then
                            loanbalances := loanbalances + '::::' + LoansTable."Loan  No." + ':::' + Format(LoansTable."Issued Date") + ':::' + LoansTable."Loan Product Type Name" + ':::' +
                             Format(LoansTable."Outstanding Balance" + LoansTable."Oustanding Interest");
                    until LoansTable.Next = 0;
                    //MESSAGE('Loan Balance %1',loanbalances);

                end;
            end;
        end;
    end;


    procedure MemberAccounts(phone: Text[20]) accounts: Text[250]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            //Members.SETRANGE(Members.Status, Members.Status::Active);
            Members.SetRange(Members.Blocked, Members.Blocked::" ");
            // Members.SETRANGE(Members."Demand Savings Status",Members."Demand Savings Status"::Active);
            if Members.Find('-') then begin


                // MemberLedgerEntry.RESET;
                // MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.",Members."No.");
                // MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Transaction Type",MemberLedgerEntry."Transaction Type"::"Demand Savings");
                // IF MemberLedgerEntry.FIND('-') THEN BEGIN

                // accounts:=accounts+'::::'+Members."No."+':::'+FORMAT(MemberLedgerEntry."Transaction Type"::"Jiokoe Savings");
                //END;


            end
            else begin
                accounts := '';
            end;
        end;
    end;


    procedure SurePESARegistration() memberdetails: Text[1000]
    begin
        begin
            SurePESAApplications.Reset;
            SurePESAApplications.SetRange(SurePESAApplications.SentToServer, false);
            if SurePESAApplications.FindFirst() then begin
                memberdetails := SurePESAApplications."Account No" + ':::' + '+254' + CopyStr(SurePESAApplications.Telephone, 2, 10) + ':::' + SurePESAApplications."ID No";
            end
            else begin
                memberdetails := '';
            end
        end;
    end;


    procedure FundsTransferFOSA(accFrom: Text[20]; accTo: Text[20]; DocNumber: Text[30]; amount: Decimal) result: Text[30]
    begin
    end;


    procedure UpdateSurePESARegistration(accountNo: Text[30]) result: Text[10]
    begin
        begin
            SurePESAApplications.Reset;
            SurePESAApplications.SetRange(SurePESAApplications.SentToServer, false);
            SurePESAApplications.SetRange(SurePESAApplications."Account No", accountNo);
            if SurePESAApplications.Find('-') then begin
                SurePESAApplications.SentToServer := true;
                SurePESAApplications.Modify;
                result := 'Modified';
            end
            else begin
                result := 'Failed';
            end
        end;
    end;


    procedure FundsTransferBOSA(accFrom: Text[20]; accTo: Text[20]; DocNumber: Text[30]; amount: Decimal) result: Text[30]
    begin
        SurePESATrans.Reset;
        SurePESATrans.SetRange(SurePESATrans."Document No", DocNumber);
        if SurePESATrans.Find('-') then begin
            result := 'REFEXISTS';
        end
        else begin



            Members.Reset;
            Members.SetRange(Members."No.", accFrom);
            // Members.CALCFIELDS(Members."Jiokoe Savings");
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                //MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Transaction Type",MemberLedgerEntry."Transaction Type"::"Jiokoe Savings");
                if MemberLedgerEntry.Find('-') then begin
                    repeat
                        samount := (samount + MemberLedgerEntry.Amount) * -1;
                    until MemberLedgerEntry.Next = 0;
                    //samount:=Members."Jiokoe Savings";


                end;
                //samount:=PolytechFactory.KnGetDemandSavingsBalance(Members."No.");


                TempBalance := -1 * samount;

                //MESSAGE(FORMAT(TempBalance));
                if (TempBalance > amount) then begin
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'TRANSFER');
                    GenJournalLine.DeleteAll;
                    //end of deletion

                    GenBatches.Reset;
                    GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                    GenBatches.SetRange(GenBatches.Name, 'TRANSFER');

                    if GenBatches.Find('-') = false then begin
                        GenBatches.Init;
                        GenBatches."Journal Template Name" := 'GENERAL';
                        GenBatches.Name := 'TRANSFER';
                        GenBatches.Description := 'TRANSFER Funds';
                        GenBatches.Validate(GenBatches."Journal Template Name");
                        GenBatches.Validate(GenBatches.Name);
                        GenBatches.Insert;
                    end;

                    //DR Customer Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'TRANSFER';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                    GenJournalLine."Account No." := Members."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := DocNumber;
                    GenJournalLine."External Document No." := Members."No.";
                    GenJournalLine."Posting Date" := Today;
                    //GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Jiokoe Savings";
                    GenJournalLine.Description := 'Mobile Transfer';
                    GenJournalLine.Amount := amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;


                    if accTo = 'Share Capital' then begin
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'TRANSFER';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := Members."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := Members."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Share Capital";
                        GenJournalLine.Description := 'Share Capital';
                        GenJournalLine.Amount := -amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;

                    if accTo = 'Deposit' then begin
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'TRANSFER';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := Members."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := Members."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                        GenJournalLine.Description := Format(GenJournalLine."transaction type"::"Deposit Contribution");
                        GenJournalLine.Amount := -amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;
                    if accTo = 'Mwanangu' then begin
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'TRANSFER';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := Members."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := Members."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Mwanangu Savings";
                        GenJournalLine.Description := Format(GenJournalLine."transaction type"::"Insurance Contribution");
                        GenJournalLine.Amount := -amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;
                    if accTo = 'Polytech' then begin
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'TRANSFER';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := Members."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := Members."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Holiday savings";
                        GenJournalLine.Description := Format(GenJournalLine."transaction type"::"Holiday savings");
                        GenJournalLine.Amount := -amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;



                    //Post
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'TRANSFER');
                    if GenJournalLine.Find('-') then begin
                        repeat
                            GLPosting.Run(GenJournalLine);
                        until GenJournalLine.Next = 0;
                    end;
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'TRANSFER');
                    GenJournalLine.DeleteAll;

                    SurePESATrans.Init;
                    SurePESATrans."Document No" := DocNumber;
                    SurePESATrans.Description := 'TRANSFER funds';
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
                    SurePESATrans.Amount := amount;
                    SurePESATrans.Status := SurePESATrans.Status::Completed;
                    SurePESATrans.Posted := true;
                    SurePESATrans."Posting Date" := Today;
                    SurePESATrans.Comments := 'Success';
                    SurePESATrans.Client := Vendor."BOSA Account No";
                    SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Transfer to Bosa";
                    SurePESATrans."Transaction Time" := Time;
                    SurePESATrans.Insert;
                    result := 'TRUE';
                    msg := 'You have transfered KES ' + Format(amount) + ' from Account Jiokoe Savings to ' + accTo + ' thank you for using Polytech Sacco Mobile.';
                    SMSMessage(DocNumber, Vendor."No.", Members."Phone No.", msg);
                end
                else begin
                    result := 'INSUFFICIENT';
                    /* msg:='You have insufficient funds in your savings Account to use this service.'+
                    ' .Thank you for using Polytech Sacco Mobile.';
                    SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                    SurePESATrans.Init;
                    SurePESATrans."Document No" := DocNumber;
                    SurePESATrans.Description := 'TRANSFER funds';
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
                    SurePESATrans.Amount := amount;
                    SurePESATrans.Status := SurePESATrans.Status::Failed;
                    SurePESATrans.Posted := false;
                    SurePESATrans."Posting Date" := Today;
                    SurePESATrans.Comments := 'Failed,Insufficient Funds';
                    SurePESATrans.Client := Vendor."BOSA Account No";
                    SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Transfer to Bosa";
                    SurePESATrans."Transaction Time" := Time;
                    SurePESATrans.Insert;
                end;
            end
            else begin
                result := 'ACCINEXISTENT';
                /* msg:='Your request has failed because account does not exist.'+
                 ' .Thank you for using Polytech Sacco Mobile.';
                 SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                SurePESATrans.Init;
                SurePESATrans."Document No" := DocNumber;
                SurePESATrans.Description := 'TRANSFER FUNDS';
                SurePESATrans."Document Date" := Today;
                SurePESATrans."Account No" := '';
                SurePESATrans."Account No2" := MPESARecon;
                SurePESATrans.Amount := amount;
                SurePESATrans.Posted := false;
                SurePESATrans."Posting Date" := Today;
                SurePESATrans.Comments := 'Failed,Invalid Account';
                SurePESATrans.Client := '';
                SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Transfer to Bosa";
                SurePESATrans."Transaction Time" := Time;
                SurePESATrans.Insert;
            end;
        end;

    end;


    procedure WSSAccount(phone: Text[20]) accounts: Text[250]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            // Members.SETRANGE(Members.Status, Members.Status::Active);
            //Members.SETRANGE(Members."Demand Savings Status", Members."Demand Savings Status"::Active);
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Jiokoe Savings");
                if MemberLedgerEntry.Find('-') then begin

                    accounts := Members."No." + ':::' + Format(MemberLedgerEntry."transaction type"::"Jiokoe Savings");
                end;
                //END;
            end
            else begin
                accounts := '';
            end
        end;
    end;


    procedure SMSMessage(documentNo: Text[30]; accfrom: Text[30]; phone: Text[20]; message: Text[250])
    begin

        SMSMessages.Reset;
        if SMSMessages.Find('+') then begin
            iEntryNo := SMSMessages."Entry No";
            iEntryNo := iEntryNo + 1;
        end
        else begin
            iEntryNo := 1;
        end;
        SMSMessages.Init;
        SMSMessages."Entry No" := iEntryNo;
        SMSMessages."Batch No" := documentNo;
        SMSMessages."Document No" := documentNo;
        SMSMessages."Account No" := accfrom;
        SMSMessages."Date Entered" := Today;
        SMSMessages."Time Entered" := Time;
        SMSMessages.Source := 'MOBILETRAN';
        SMSMessages."Entered By" := UserId;
        SMSMessages."Sent To Server" := SMSMessages."sent to server"::No;
        SMSMessages."SMS Message" := message;
        SMSMessages."Telephone No" := phone;
        if SMSMessages."Telephone No" <> '' then
            SMSMessages.Insert;
    end;


    procedure LoanRepayment(accFrom: Text[20]; loanNo: Text[20]; DocNumber: Text[30]; amount: Decimal) result: Text[30]
    var
        batch: Code[10];
    begin
        batch := 'MOBILE';
        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        GenJournalLine.SetRange("Journal Batch Name", batch);
        GenJournalLine.DeleteAll;
        //end of deletion

        GenBatches.Reset;
        GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SetRange(GenBatches.Name, batch);

        if GenBatches.Find('-') = false then begin
            GenBatches.Init;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Loan Repayment';
            GenBatches.Validate(GenBatches."Journal Template Name");
            GenBatches.Validate(GenBatches.Name);
            GenBatches.Insert;
        end;//General Jnr Batches

        Members.Reset;
        Members.SetRange(Members."No.", accFrom);
        if Members.Find('-') then begin

            // samount:=PolytechFactory.KnGetDemandSavingsBalance(Members."No.");

            Message(Format(samount));

            TempBalance := samount;


            if (TempBalance > amount) then begin
                //DR Customer Acc
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                GenJournalLine."Account No." := Members."No.";
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := DocNumber;
                GenJournalLine."External Document No." := Members."No.";
                GenJournalLine."Posting Date" := Today;
                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Unallocated Funds";
                GenJournalLine.Description := 'Mobile Transfer';
                GenJournalLine.Amount := amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                LoansRegister.Reset;
                LoansRegister.SetRange(LoansRegister."Loan  No.", loanNo);
                // LoansRegister.SETRANGE(LoansRegister."Client Code",memberNo);

                if LoansRegister.Find('+') then begin
                    LoansRegister.CalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                    if (LoansRegister."Outstanding Balance" > 0) then begin

                        if LoansRegister."Oustanding Interest" > 0 then begin
                            LineNo := LineNo + 10000;

                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                            GenJournalLine."Account No." := LoansRegister."Client Code";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := DocNumber;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Loan Interest Payment';


                            if amount > LoansRegister."Oustanding Interest" then
                                GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                            else
                                GenJournalLine.Amount := -amount;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Paid";

                            if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                                GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                            end;
                            GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            amount := amount + GenJournalLine.Amount;
                        end;

                        if amount > 0 then begin
                            LineNo := LineNo + 10000;

                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                            GenJournalLine."Account No." := LoansRegister."Client Code";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := '';
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Mobile Loan Repayment';
                            GenJournalLine.Amount := -amount;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                            if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                                GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                            end;
                            GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;
                        end;

                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                        GenJournalLine.SetRange("Journal Batch Name", batch);
                        if GenJournalLine.Find('-') then begin
                            repeat
                                GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                        end;


                        SurePESATrans.Init;
                        SurePESATrans."Document No" := DocNumber;
                        SurePESATrans.Description := 'TRANSFER funds';
                        SurePESATrans."Document Date" := Today;
                        SurePESATrans."Account No" := Vendor."No.";
                        SurePESATrans."Account No2" := MPESARecon;
                        SurePESATrans.Amount := amount;
                        SurePESATrans.Status := SurePESATrans.Status::Completed;
                        SurePESATrans.Posted := true;
                        SurePESATrans."Posting Date" := Today;
                        SurePESATrans.Comments := 'Success';
                        SurePESATrans.Client := Vendor."BOSA Account No";
                        SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Loan Application";
                        SurePESATrans."Transaction Time" := Time;
                        SurePESATrans.Insert;
                        result := 'TRUE';
                        msg := 'You have transfered KES ' + Format(amount) + ' from Account jiokoe savings to ' + LoansRegister."Loan Product Type Name" + ' thank you for using Polytech Sacco Mobile.';
                        SMSMessage(DocNumber, Vendor."No.", Members."Mobile Phone No", msg);

                    end;//oustanding loan
                end; //LOAN REGISTER
            end
            else begin
                result := 'INSUFFICIENT';
                /* msg:='You have insufficient funds in your savings Account to use this service.'+
                ' .Thank you for using Polytech Sacco Mobile.';
                SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                SurePESATrans.Init;
                SurePESATrans."Document No" := DocNumber;
                SurePESATrans.Description := 'TRANSFER funds';
                SurePESATrans."Document Date" := Today;
                SurePESATrans."Account No" := Vendor."No.";
                SurePESATrans."Account No2" := MPESARecon;
                SurePESATrans.Amount := amount;
                SurePESATrans.Status := SurePESATrans.Status::Failed;
                SurePESATrans.Posted := false;
                SurePESATrans."Posting Date" := Today;
                SurePESATrans.Comments := 'Failed,Insufficient Funds';
                SurePESATrans.Client := Vendor."BOSA Account No";
                SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Transfer to Bosa";
                SurePESATrans."Transaction Time" := Time;
                SurePESATrans.Insert;
            end;
        end
        else begin
            result := 'ACCINEXISTENT';
            /* msg:='Your request has failed because account does not exist.'+
             ' .Thank you for using Polytech Sacco Mobile.';
             SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
            SurePESATrans.Init;
            SurePESATrans."Document No" := DocNumber;
            SurePESATrans.Description := 'TRANSFER FUNDS';
            SurePESATrans."Document Date" := Today;
            SurePESATrans."Account No" := '';
            SurePESATrans."Account No2" := MPESARecon;
            SurePESATrans.Amount := amount;
            SurePESATrans.Posted := false;
            SurePESATrans."Posting Date" := Today;
            SurePESATrans.Comments := 'Failed,Invalid Account';
            SurePESATrans.Client := '';
            SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Loan Application";
            SurePESATrans."Transaction Time" := Time;
            SurePESATrans.Insert;
        end;
        //END;
        //END;

    end;


    procedure OutstandingLoans(phone: Text[20]) loannos: Text[200]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                LoansTable.Reset;
                LoansTable.SetRange(LoansTable."Client Code", Members."No.");
                if LoansTable.Find('-') then begin
                    repeat

                        // amount:=LoansTable.Installments-PolytechFactory.kt
                        LoansTable.CalcFields(LoansTable."Outstanding Balance", LoansTable."Interest Due", LoansTable."Oustanding Interest", LoansTable."Interest Paid");
                        if (LoansTable."Outstanding Balance" > 0) then
                            loannos := loannos + ':::' + LoansTable."Loan  No.";
                    until LoansTable.Next = 0;
                end;
            end
        end;
    end;


    procedure LoanGuarantors(loanNo: Text[20]) guarantors: Text[1000]
    begin
        begin
            LoanGuaranteeDetails.Reset;
            LoanGuaranteeDetails.SetRange(LoanGuaranteeDetails."Loan No", loanNo);
            if LoanGuaranteeDetails.Find('-') then begin
                repeat
                    guarantors := guarantors + '::::' + LoanGuaranteeDetails.Name + ':::' + Format(LoanGuaranteeDetails."Amont Guaranteed");
                until LoanGuaranteeDetails.Next = 0;
            end;
        end;
    end;


    procedure LoansGuaranteed(phone: Text[20]) guarantors: Text[1000]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin

                LoanGuaranteeDetails.Reset;
                LoanGuaranteeDetails.SetRange(LoanGuaranteeDetails."Member No", Members."No.");
                LoanGuaranteeDetails.SetFilter(LoanGuaranteeDetails."Loan Balance", '>%1', 0);
                if LoanGuaranteeDetails.Find('-') then begin
                    repeat
                        guarantors := guarantors + '::::' + LoanGuaranteeDetails."Loan No" + ':::' + Format(LoanGuaranteeDetails."Amont Guaranteed");
                    until LoanGuaranteeDetails.Next = 0;
                end;
            end;
        end;
    end;


    procedure ClientCodes(loanNo: Text[20]) codes: Text[20]
    begin
        begin
            LoansTable.Reset;
            LoansTable.SetRange(LoansTable."Loan  No.", loanNo);
            if LoansTable.Find('-') then begin
                codes := LoansTable."Client Code";
            end;
        end
    end;


    procedure ClientNames(ccode: Text[20]) names: Text[100]
    begin
        begin
            LoansTable.Reset;
            LoansTable.SetRange(LoansTable."Client Code", ccode);
            if LoansTable.Find('-') then begin
                Members.Reset;
                Members.SetRange(Members."No.", ccode);
                if Members.Find('-') then begin
                    names := Members.Name;
                end;
            end;
        end
    end;


    procedure RegisteredMemberDetailsUSSD(Phone: Text[20]; docNo: Text[30]) reginfo: Text[250]
    var
        empno: Text;
    begin
        begin
            RanNo := Format(Random(10000));
            Members.Reset;
            Members.SetRange(Members."Phone No.", Phone);
            if Members.Find('-') then begin
                if Members."Employer Name" = '' then
                    empno := 'n/a'
                else
                    empno := Members."Employer Name";
                reginfo := 'Member No: ' + Members."No." + ',  Name: ' + Members.Name + ',  ID No: ' + Format(Members."ID No.") + ',  Payroll No: ' + Members."Payroll/Staff No2" + ',  Email :' + Members."E-Mail" + ', Employer:' + empno;

                SMSMessage(RanNo + Members."No.", Members."No.", Phone, reginfo);
            end
            else begin
                reginfo := '';
            end
        end;
    end;


    procedure LoansGuaranteedUSSD(phone: Text[20]; docNo: Text[30]) guarantors: Text[1000]
    var
        Ran2: Text[20];
        newtext: Text[500];
    begin
        begin
            RanNo := Format(Random(10000));
            Ran2 := Format(Random(10000));
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
            end;
            LoanGuaranteeDetails.Reset;
            LoanGuaranteeDetails.SetRange(LoanGuaranteeDetails."Member No", Members."No.");
            LoanGuaranteeDetails.SetFilter(LoanGuaranteeDetails."Loan Balance", '>%1', 0);
            if LoanGuaranteeDetails.Find('-') then begin
                repeat
                    guarantors := guarantors + LoanGuaranteeDetails."Loanees  Name" + '-(' + Format(LoanGuaranteeDetails."Amont Guaranteed") + '), ';
                until LoanGuaranteeDetails.Next = 0;
                newtext := guarantors;
                if StrLen(guarantors) > 220 then begin
                    guarantors := CopyStr(guarantors, 1, 220);
                    SMSMessage(RanNo + Members."No.", Members."No.", phone, 'LOANS GUARANTEED  ' + CopyStr(guarantors, 1, 220));
                    SMSMessage(Ran2 + Members."No.", Members."No.", phone, CopyStr(newtext, 221, StrLen(newtext)));
                end
                else begin
                    SMSMessage(RanNo + Members."No.", Members."No.", phone, 'LOANS GUARANTEED  ' + guarantors);
                end;
                guarantors := CopyStr(guarantors, 1, StrLen(guarantors) - 2);
            end;
        end;
    end;


    procedure LoanGuarantorsUSSD(loanNo: Text[20]; Phone: Text[20]; docNo: Text[30]) guarantors: Text[1000]
    var
        loantype: Text[30];
    begin
        begin
            LoansTable.Reset;
            LoansTable.SetRange(LoansTable."Loan  No.", loanNo);
            if LoansTable.Find('-') then begin
                loantype := LoansTable."Loan Product Type";
            end;

            RanNo := Format(Random(10000));
            LoanGuaranteeDetails.Reset;
            LoanGuaranteeDetails.SetRange(LoanGuaranteeDetails."Loan No", loanNo);
            if LoanGuaranteeDetails.Find('-') then begin
                repeat
                    guarantors := guarantors + '::' + LoanGuaranteeDetails.Name + '(' + Format(LoanGuaranteeDetails."Amont Guaranteed") + ')';
                until LoanGuaranteeDetails.Next = 0;
                SMSMessage(RanNo + loanNo, Members."No.", Phone, 'GUARANTORS' + '(' + loantype + ')' + guarantors);
            end;
        end;
    end;


    procedure MiniStatementUSSD(Phone: Text[20]; DocNumber: Text[20]) MiniStmt: Text[400]
    begin
        begin
            Members.SetRange(Members."Phone No.", Phone);
            if Members.FindSet then begin
                //Members.CALCFIELDS(Vendor.Balance);
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetCurrentkey(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.Ascending(false);
                MemberLedgerEntry.SetFilter(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                //VendorLedgEntry.SETFILTER(VendorLedgEntry.Description,'<>*Excise duty*');
                MemberLedgerEntry.SetRange(MemberLedgerEntry.Reversed, MemberLedgerEntry.Reversed::"0");
                if MemberLedgerEntry.FindSet then begin
                    MiniStmt := '';
                    repeat
                        amount := MemberLedgerEntry.Amount;
                        if amount < 1 then
                            amount := amount * -1;
                        MiniStmt := MiniStmt + Format(MemberLedgerEntry."Posting Date") + '-' + CopyStr(MemberLedgerEntry.Description, 1, 50) + '-' +
                        Format(amount) + ' , ';
                        minimunCount := minimunCount + 1;
                        if minimunCount > 5 then
                            break
                      until MemberLedgerEntry.Next = 0;
                    MiniStmt := CopyStr(MiniStmt, 1, StrLen(MiniStmt) - 2);
                    SMSMessage(DocNumber, Members."No.", Phone, ' MINI STATEMENT ' + MiniStmt);
                end;
            end
            else begin
                MiniStmt := 'You have INSUFFICIENT funds to use this service.';
            end;
        end;
    end;


    procedure AccountBalanceUSSD(Phone: Code[30]; DocNumber: Code[20]) Bal: Text[50]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", Phone);
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Jiokoe Savings");
                if MemberLedgerEntry.Find('-') then
                    repeat
                        amount := amount + MemberLedgerEntry.Amount;
                        Bal := Format(amount, 0, '<Precision,2:2><Integer><Decimals>');
                    until MemberLedgerEntry.Next = 0;
            end;
            SMSMessage(DocNumber, Members."No.", Phone, ' Your Account balance is Kshs: ' + Bal + '. Thank you for using Polytech Mobile');
        end;
    end;


    procedure Accounts(phone: Text[20]; docNo: Text[30]) accounts: Text[1000]
    var
        sharecap: Text[50];
        deposit: Text[50];
        holiday: Text[50];
        property: Text[50];
        junior: Text[50];
        benevolent: Text[50];
    begin
        begin
            sharecap := ShareCapital(phone);
            if sharecap <> 'NULL' then begin
                sharecap := 'Share Capital= KES ' + sharecap;
                accounts := accounts + sharecap + ' , ';
            end;

            deposit := DepositContribution(phone);
            if deposit <> 'NULL' then begin
                deposit := 'Deposit Contribution= KES ' + deposit + ' , ';
                accounts := accounts + deposit;
            end;

            // holiday:=HolidayAcc(phone);
            // IF HolidayAcc(phone) <>'NULL' THEN BEGIN
            // holiday:='Holiday Savers= KES '+HolidayAcc(phone);
            // accounts:=accounts+holiday+' , ';
            // END;
            //
            // IF PropertyAcc(phone) <>'NULL' THEN BEGIN
            //  property:='Housing = KES '+PropertyAcc(phone);
            //  accounts:=accounts+property+' , ';
            // END;

            accounts := CopyStr(accounts, 1, StrLen(accounts) - 3);
            SMSMessage(docNo, Members."No.", phone, ' ACCOUNTS BALANCE ' + accounts);
        end;
    end;


    procedure HolidayAcc(phone: Text[20]) shares: Text[1000]
    var
        hlamount: Decimal;
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                //shares:=FORMAT( PolytechFactory.KnGetDemandSavingsBalance(Members."No."));
            end else begin
                shares := '0';
            end;
        end;
    end;


    procedure PropertyAcc(phone: Text[20]) shares: Text[1000]
    var
        pptamount: Decimal;
    begin

        Members.Reset;
        Members.SetRange(Members."Phone No.", phone);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::Dividend);
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    pptamount := pptamount + MemberLedgerEntry.Amount;
                    shares := Format(pptamount, 0, '<Precision,2:2><Integer><Decimals>');
                until MemberLedgerEntry.Next = 0;
            end
            else begin
                shares := '0';
            end;
            if shares = '' then
                shares := '0'
        end;
    end;


    procedure JuniorAcc(phone: Text[20]) bal: Text[1000]
    var
        jramount: Decimal;
    begin

        Members.Reset;
        Members.SetRange(Members."Phone No.", phone);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Mwanangu Savings");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    jramount := jramount + MemberLedgerEntry.Amount;
                    bal := Format(jramount, 0, '<Precision,2:2><Integer><Decimals>');
                until MemberLedgerEntry.Next = 0;
            end
            else begin
                bal := '0';
            end;
            if bal = '' then
                bal := '0'
        end;
    end;


    procedure BenevolentFund(phone: Text[20]) bal: Text[1000]
    var
        bvamount: Decimal;
    begin

        Members.Reset;
        Members.SetRange(Members."Phone No.", phone);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Jiokoe Savings");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    bvamount := bvamount + MemberLedgerEntry.Amount;
                    bal := Format(bvamount, 0, '<Precision,2:2><Integer><Decimals>');
                until MemberLedgerEntry.Next = 0;
            end
            else begin
                bal := '0';
            end;
            if bal = '' then
                bal := '0'
        end;
    end;


    procedure DepositContribution(phone: Text[20]) bal: Text[250]
    var
        dcmount: Decimal;
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Deposit Contribution");
                if MemberLedgerEntry.Find('-') then begin
                    repeat
                        dcmount := dcmount + MemberLedgerEntry.Amount;
                        bal := Format(dcmount, 0, '<Precision,2:2><Integer><Decimals>');
                    until MemberLedgerEntry.Next = 0;
                end
                else begin
                    bal := '0';
                end;
                if bal = '' then
                    bal := '0'
            end;
        end;
    end;


    procedure ShareCapital(phone: Text[20]) bal: Text[1000]
    var
        samount: Decimal;
    begin

        Members.Reset;
        Members.SetRange(Members."Phone No.", phone);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Share Capital");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    samount := samount + MemberLedgerEntry.Amount;
                    bal := Format(samount, 0, '<Precision,2:2><Integer><Decimals>');
                until MemberLedgerEntry.Next = 0;
            end
            else begin
                bal := '0';
            end;
            if bal = '' then
                bal := '0'
        end;
    end;


    procedure SharesRetained(phone: Text[20]) bal: Text[1000]
    var
        samount: Decimal;
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Share Capital");
                if MemberLedgerEntry.Find('-') then begin
                    repeat
                        samount := samount + MemberLedgerEntry.Amount;
                        bal := Format(samount, 0, '<Precision,2:2><Integer><Decimals>');
                    until MemberLedgerEntry.Next = 0;
                end
                else begin
                    bal := '0';
                end;
            end;
            if bal = '' then
                bal := '0';
        end;
    end;


    procedure CurrentShares(phone: Text[20]) bal: Text[1000]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                MemberLedgerEntry.Reset;
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Deposit Contribution");
                if MemberLedgerEntry.Find('-') then begin
                    repeat
                        amount := amount + MemberLedgerEntry.Amount;
                        bal := Format(amount, 0, '<Precision,2:2><Integer><Decimals>');
                    until MemberLedgerEntry.Next = 0;
                end
                else begin
                    bal := '0';
                end;
            end;
            if bal = '' then
                bal := '0';
        end;
    end;


    procedure OutstandingLoanName(phone: Text[20]) loannos: Text[200]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                LoansTable.Reset;
                LoansTable.SetRange(LoansTable."Client Code", Members."No.");
                if LoansTable.Find('-') then begin
                    repeat
                        LoansTable.CalcFields(LoansTable."Outstanding Balance", LoansTable."Interest Due", LoansTable."Interest to be paid", LoansTable."Interest Paid");
                        if (LoansTable."Outstanding Balance" > 0) then
                            loannos := loannos + ':::' + LoansTable."Loan  No.";
                    until LoansTable.Next = 0;
                end;
            end
        end;
    end;


    procedure MemberName(memNo: Text[20]) name: Text[200]
    begin
        begin
            Members.Reset;
            Members.SetRange(Members."No.", memNo);
            if Members.Find('-') then begin
                name := Members.Name;
            end
        end;
    end;


    procedure InsertTransaction("Document No": Code[30]; Keyword: Code[30]; "Account No": Code[30]; "Account Name": Text[100]; Telephone: Code[20]; Amount: Decimal; "Sacco Bal": Decimal; transactionDate: Date) Result: Code[20]
    begin
        begin
            begin
                begin
                    PaybillTrans.Init;
                    PaybillTrans."Document No" := "Document No";
                    PaybillTrans."Key Word" := Keyword;
                    PaybillTrans."Account No" := "Account No";
                    PaybillTrans."Account Name" := "Account Name";
                    PaybillTrans."Transaction Date" := Today;
                    //PaybillTrans."Transaction Time":=TIME;
                    PaybillTrans.Description := 'PayBill Deposit';
                    PaybillTrans.Telephone := Telephone;
                    PaybillTrans.Amount := Amount;
                    PaybillTrans."Transaction Time" := Time;
                    PaybillTrans."Paybill Acc Balance" := "Sacco Bal";
                    PaybillTrans.Posted := false;
                    PaybillTrans.Insert;
                end;
                PaybillTrans.Reset;
                PaybillTrans.SetRange(PaybillTrans."Document No", "Document No");
                if PaybillTrans.Find('-') then begin
                    Result := 'TRUE';
                end
                else begin
                    Result := 'FALSE';
                end;
            end;
        end;
    end;


    procedure PaybillSwitch() Result: Code[20]
    begin
        begin

            PaybillTrans.Reset;
            PaybillTrans.SetRange(PaybillTrans.Posted, false);
            PaybillTrans.SetRange(PaybillTrans."Needs Manual Posting", false);
            if PaybillTrans.Find('-') then begin

                //Members.RESET;
                //Members.SETRANGE(Members."No.",PaybillTrans."Account No");
                //IF Members.FIND('-') THEN
                //  //Result:='';
                //  //// Result:=FnpostRemitanceDis('REMITANCE',PaybillTrans."Document No",PaybillTrans.Amount,PaybillTrans.Telephone)
                //  Result:=PayBillToBOSAAPI('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans.Telephone,PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill from '+PaybillTrans.Telephone +'-' +PaybillTrans."Account Name")
                //  ELSE BEGIN
                LoansRegister.Reset;
                LoansRegister.SetRange(LoansRegister."Loan  No.", PaybillTrans."Account No");
                if LoansRegister.Find('-') then
                    Result := PayBillToLoan('PAYBILL', PaybillTrans."Document No", PaybillTrans."Account No", PaybillTrans."Account No", PaybillTrans.Amount, 'Loan Repayment')
                else begin
                    if PaybillTrans."Account No" = 'SHARE CAPITAL' then
                        Result := PayBillToBOSA('PAYBILL', PaybillTrans."Document No", PaybillTrans."Account No", PaybillTrans.Telephone, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Share capital');

                    if PaybillTrans."Account No" = 'DEPOSIT CONTRIBUTION' then
                        Result := PayBillToBOSA('PAYBILL', PaybillTrans."Document No", PaybillTrans."Account No", PaybillTrans.Telephone, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Deposit Contibution');

                    //IF PaybillTrans."Account No"='JIOKOE SAVINGS' THEN
                    //Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans.Telephone,PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Jiokoe Savings');

                    //IF PaybillTrans."Account No"='MWANANGU SAVINGS' THEN
                    // Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans.Telephone,PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Mwanangu Savings');


                    if PaybillTrans."Account No" = 'LUMPSUM PAYMENTS' then
                        Result := FnpostRemitanceDis('REMITANCE', PaybillTrans."Document No", PaybillTrans.Amount, PaybillTrans.Telephone);

                end;
                // END;





                if Result = '' then begin
                    PaybillTrans."Date Posted" := Today;
                    PaybillTrans."Needs Manual Posting" := true;
                    PaybillTrans.Description := 'Failed';
                    PaybillTrans.Modify;
                end;

            end;
        end;

        /*
        BEGIN
              PaybillTrans.RESET;
              PaybillTrans.SETRANGE(PaybillTrans.Posted,FALSE);
              PaybillTrans.SETRANGE(PaybillTrans."Needs Manual Posting",FALSE);
              IF PaybillTrans.FIND('-') THEN BEGIN
        
                CASE PaybillTrans."Key Word" OF
                 'SHARE CAPITAL':
                    Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Share Capital');
                 'DEPOSIT':
                    Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Deposit');
                 'DEMAND SAVINGS':
                    Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Demand Savings');
                 'INSURANCE':
                    Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Insurance Contribution');
                 'STOCKS':
                    Result:=PayBillToBOSA('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,PaybillTrans."Key Word",'PayBill to Stocks Paid');
                 'NORM':
                 Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'NORMAL LOAN');
                 'PREM':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'PREMIUM LOAN');
                  'INST':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'INSTANT LOAN');
                'EMEG':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'EMERGENCY ADVANCE');
               'SCHL':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'SCHOOL FEES LOAN');
                'SSCH':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'SUPER SCHOOL FEES LOAN');
                 'SALO':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'SALARY ADVANCE LOAN');
                 'HOSE':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'HOUSING LOAN');
                 'HOME':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'HOME APPLIANCE LOAN');
                 'REFN':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'REFINANCED LOANS');
                 'BLBL':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'BANK LOAN BAILOUT');
                 'DFGL':
                    Result:=PayBillToLoan('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'DEFAULTER GUARANTORS LOAN');
        
                 ELSE
                    PaybillTrans."Transaction Date":=TODAY;
                    PaybillTrans."Needs Manual Posting":=TRUE;
                    PaybillTrans.Description:='Failed';
                    PaybillTrans.MODIFY;
               END;
               IF Result='' THEN BEGIN
                      PaybillTrans."Transaction Date":=TODAY;
                      PaybillTrans."Needs Manual Posting":=TRUE;
                      PaybillTrans.Description:='Failed';
                      PaybillTrans.MODIFY;
                 END;
              END;
            END;*/

    end;

    local procedure PayBillToAcc(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; Amount: Decimal; accountType: Code[30]) res: Code[10]
    begin
        begin
            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            //Gensetup.RESET;
            //Gensetup.GET;
            GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."PayBill Settl Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");
            // Gensetup.TESTFIELD(Gensetup);
            //SwizzKashCharge:=GetCharge(Amount,'PAYBILL');
            PaybillRecon := GenLedgerSetup."PayBill Settl Acc";
            //SwizzKashCommACC:=GenLedgerSetup."SwizzKash Comm Acc";


            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            GenJournalLine.DeleteAll;
            //end of deletion

            GenBatches.Reset;
            GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SetRange(GenBatches.Name, batch);


            if GenBatches.Find('-') = false then begin
                GenBatches.Init;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := 'Paybill Deposit';
                GenBatches.Validate(GenBatches."Journal Template Name");
                GenBatches.Validate(GenBatches.Name);
                GenBatches.Insert;
            end;//General Jnr Batches

            Members.Reset;
            Members.SetRange(Members."ID No.", accNo);
            if Members.Find('-') then begin
                Vendor.Reset;
                Vendor.SetRange(Vendor."No.", Members."FOSA Account No.");
                Vendor.SetRange(Vendor."Account Type", accountType);
                if Vendor.Find('-') then begin

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.Validate(GenJournalLine."Account No.");

                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Paybill from ' + PaybillTrans.Telephone + '-' + PaybillTrans."Account Name";
                    ;
                    GenJournalLine.Amount := Amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Paybill from ' + PaybillTrans.Telephone + '-' + PaybillTrans."Account Name";
                    GenJournalLine.Amount := -1 * Amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Dr Customer Charge amount
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Paybill transaction charges';
                    //GenJournalLine.Amount:=(SwizzKashCharge);
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //CR SwizzKash a/c
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    // GenJournalLine."Account No.":=SwizzKashCommACC;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := ' Charges';
                    // GenJournalLine.Amount:=-SwizzKashCharge;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;
                    //cr excise duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := Format(ExxcDuty);
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                end;//Vendor
            end;//Member

            //Post
            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            if GenJournalLine.Find('-') then begin
                repeat
                    GLPosting.Run(GenJournalLine);
                until GenJournalLine.Next = 0;
                PaybillTrans.Posted := true;
                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Time Posted" := Time;
                PaybillTrans.Description := 'Posted';
                PaybillTrans.Modify;
                res := 'TRUE';

                msg := 'Dear ' + Vendor.Name + ' your acc: ' + Vendor."No." + ' has been credited with Ksh. ' + Format(Amount) + ' Thank you for using Polytech M-Banking';
                SMSMessage('PAYBILLTRANS', Vendor."No.", Vendor."Phone No.", msg);
            end
            else begin
                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Needs Manual Posting" := true;
                PaybillTrans.Description := 'Failed';
                PaybillTrans.Modify;
                res := 'FALSE';
                msg := 'Dear ' + Vendor.Name + ' your deposit of Ksh. ' + Format(Amount) + ' has been received but not credited to your account';
                SMSMessage('PAYBILLTRANS', Vendor."No.", Vendor."Phone No.", msg);

            end;
        end;
    end;

    local procedure PayBillToLoan(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]) res: Code[10]
    begin
        GenLedgerSetup.Reset;
        GenLedgerSetup.Get;
        // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Comm Acc");
        GenLedgerSetup.TestField(GenLedgerSetup."PayBill Settl Acc");
        // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Charge");

        //SurePESACommACC:=  GenLedgerSetup."SurePESA Comm Acc";
        // SurePESACharge:=GenLedgerSetup."SurePESA Charge";
        PaybillRecon := GenLedgerSetup."PayBill Settl Acc";

        ExcDuty := 0;//(10/100)*BIBLIACharge;

        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        GenJournalLine.SetRange("Journal Batch Name", batch);
        GenJournalLine.DeleteAll;
        //end of deletion

        GenBatches.Reset;
        GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SetRange(GenBatches.Name, batch);

        if GenBatches.Find('-') = false then begin
            GenBatches.Init;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Paybill Loan Repayment';
            GenBatches.Validate(GenBatches."Journal Template Name");
            GenBatches.Validate(GenBatches.Name);
            GenBatches.Insert;
        end;//General Jnr Batches

        //Members.RESET;
        //Members.SETRANGE(Members."ID No.", accNo);
        //IF Members.FIND('-') THEN BEGIN
        // Vendor.RESET;
        // Vendor.SETRANGE(Vendor."BOSA Account No", accNo);
        //  Vendor.SETRANGE(Vendor."Account Type", fosaConst);
        //   IF Vendor.FINDFIRST THEN BEGIN


        LoansRegister.Reset;
        //LoansRegister.SETRANGE(LoansRegister."Loan Product Type",type);
        //LoansRegister.SETRANGE(LoansRegister."Client Code",memberNo);
        LoansRegister.SetRange(LoansRegister."Loan  No.", accNo);
        if LoansRegister.Find('+') then begin

            Members.Reset;
            Members.SetRange(Members."No.", LoansRegister."Client Code");
            if Members.Find('-') then begin
                LoansRegister.CalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                if LoansRegister."Outstanding Balance" > 0 then begin

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;

                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Paybill Loan Repayment';
                    GenJournalLine.Amount := amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    if LoansRegister."Oustanding Interest" > 0 then begin
                        LineNo := LineNo + 10000;

                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := batch;
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := LoansRegister."Client Code";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := docNo;
                        GenJournalLine."External Document No." := docNo;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Loan Interest Payment';
                    end;

                    if amount > LoansRegister."Oustanding Interest" then
                        GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                    else
                        GenJournalLine.Amount := -amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Paid";

                    if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                        GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                    end;
                    GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    amount := amount + GenJournalLine.Amount;

                    if amount > 0 then begin
                        LineNo := LineNo + 10000;

                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := batch;
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                        GenJournalLine."Account No." := LoansRegister."Client Code";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := docNo;
                        GenJournalLine."External Document No." := '';
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Paybill Loan Repayment';
                        GenJournalLine.Amount := -amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                        if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                            GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                            GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                        end;
                        GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;
                    //Post
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", batch);
                    if GenJournalLine.Find('-') then begin
                        repeat
                            GLPosting.Run(GenJournalLine);
                        until GenJournalLine.Next = 0;
                        msg := 'Dear ' + Members.Name + ' your  ' + LoansRegister."Loan Product Type Name" + ' has been credited with Ksh ' + Format(PaybillTrans.Amount) + ' Thank you for using Polytech M-Banking';
                        SMSMessage('PAYBILLTRANS', Members."No.", Members."Mobile Phone No", msg);

                        PaybillTrans.Posted := true;
                        PaybillTrans."Date Posted" := Today;
                        PaybillTrans.Description := 'Posted';
                        PaybillTrans.Modify;
                        res := 'TRUE';
                    end
                    else begin
                        PaybillTrans."Date Posted" := Today;
                        PaybillTrans."Needs Manual Posting" := true;
                        PaybillTrans.Description := 'Failed';
                        PaybillTrans.Modify;
                        res := 'FALSE';
                    end;


                end//Outstanding Balance
            end;//Member
        end;//Loan Register
            // END;//Vendor
    end;

    local procedure PayBillToBOSAAPI(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[20]; descr: Text[100]) res: Code[10]
    begin
        begin

            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Comm Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."PayBill Settl Acc");
            // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Charge");



            // SurePESACommACC:=  GenLedgerSetup."SurePESA Comm Acc";

            PaybillRecon := GenLedgerSetup."PayBill Settl Acc";

            //ExcDuty:=(10/100)*SurePESACharge;

            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            GenJournalLine.DeleteAll;
            //end of deletion

            GenBatches.Reset;
            GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SetRange(GenBatches.Name, batch);

            if GenBatches.Find('-') = false then begin
                GenBatches.Init;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.Validate(GenBatches."Journal Template Name");
                GenBatches.Validate(GenBatches.Name);
                GenBatches.Insert;
            end;//General Jnr Batches

            Members.Reset;
            Members.SetRange(Members."No.", accNo);
            if Members.Find('-') then begin
                /*  Vendor.RESET;
                  Vendor.SETRANGE(Vendor."BOSA Account No", accNo);
                  Vendor.SETRANGE(Vendor."Account Type", memberNo);
                    IF Vendor.FINDFIRST THEN BEGIN
                    */

                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := CopyStr(descr, 1, 50);
                GenJournalLine.Amount := amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                //Cr Customer
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                GenJournalLine."Account No." := Members."No.";
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := Today;

                //CASE PaybillTrans."Key Word" OF 'DEPOSIT CONTRIBUTION':
                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Unallocated Funds";
                // END;
                /*
                CASE PaybillTrans."Key Word" OF 'SHA':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                END;
                CASE PaybillTrans."Key Word" OF 'DEMAND SAVINGS':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Demand Savings";
                END;
                CASE PaybillTrans."Key Word" OF 'INSUARNCE':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Insurance Contribution";
                END;

                CASE PaybillTrans."Key Word" OF 'STOCKS':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Stock paid";
                 END;


                CASE PaybillTrans."Key Word" OF 'DEPO':
                    GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Dividend;
                END;
                CASE PaybillTrans."Key Word" OF 'SHAC':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Stock Due";
                END;
                CASE PaybillTrans."Key Word" OF 'DMND':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Life Assurance";
                END;
                CASE PaybillTrans."Key Word" OF 'INSC':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Dividend Advance";
                END;
                CASE PaybillTrans."Key Word" OF 'STKS':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Stock paid";
                 END;
                  */

                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Description := CopyStr(descr, 1, 50);
                GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;


            end;//Member

            //Post
            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            if GenJournalLine.Find('-') then begin
                repeat
                    GLPosting.Run(GenJournalLine);
                until GenJournalLine.Next = 0;
                PaybillTrans.Posted := true;
                PaybillTrans."Date Posted" := Today;
                PaybillTrans.Description := 'Posted';
                PaybillTrans.Modify;
                res := 'TRUE';
                msg := 'Dear ' + Members.Name + ' your acc: ' + Members."No." + ' has been credited with Ksh' + Format(amount) + ' Thank you for using Polytech SACCO Mobile';
                SMSMessage(docNo, Members."No.", Members."Mobile Phone No", msg);
            end
            else begin

                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Needs Manual Posting" := true;
                PaybillTrans.Description := 'Failed';
                PaybillTrans.Modify;
                res := 'FALSE';
            end;


        end;

    end;

    local procedure PayBillToBOSA(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[20]; descr: Text[100]) res: Code[10]
    begin
        begin

            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Comm Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."PayBill Settl Acc");
            // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SurePESA Charge");



            // SurePESACommACC:=  GenLedgerSetup."SurePESA Comm Acc";

            PaybillRecon := GenLedgerSetup."PayBill Settl Acc";

            //ExcDuty:=(10/100)*SurePESACharge;

            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            GenJournalLine.DeleteAll;
            //end of deletion

            GenBatches.Reset;
            GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SetRange(GenBatches.Name, batch);

            if GenBatches.Find('-') = false then begin
                GenBatches.Init;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.Validate(GenBatches."Journal Template Name");
                GenBatches.Validate(GenBatches.Name);
                GenBatches.Insert;
            end;//General Jnr Batches

            Members.Reset;
            Members.SetRange(Members."Mobile Phone No", PaybillTrans.Telephone);
            //Members.SETRANGE(Members."Mobile Phone No",'+'+ PaybillTrans.Telephone);
            if Members.Find('-') then begin
                /*  Vendor.RESET;
                  Vendor.SETRANGE(Vendor."BOSA Account No", accNo);
                  Vendor.SETRANGE(Vendor."Account Type", memberNo);
                    IF Vendor.FINDFIRST THEN BEGIN
                    */

                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := descr;
                GenJournalLine.Amount := amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                //Cr Customer
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                GenJournalLine."Account No." := Members."No.";
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := Today;
                case PaybillTrans."Account No" of
                    'DEPOSIT CONTRIBUTION':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                end;
                case PaybillTrans."Account No" of
                    'SHARE CAPITAL':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Share Capital";
                end;
                //              CASE PaybillTrans."Account No" OF 'JIOKOE SAVINGS':
                //                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Due";
                //              END;
                //              CASE PaybillTrans."Account No" OF 'MWANANGU SAVINGS':
                //                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"20";
                //              END;



                /*CASE PaybillTrans."Key Word" OF 'DEPO':
                    GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Dividend;
                END;
                CASE PaybillTrans."Key Word" OF 'SHAC':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Stock Due";
                END;
                CASE PaybillTrans."Key Word" OF 'DMND':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Life Assurance";
                END;
                CASE PaybillTrans."Key Word" OF 'INSC':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Dividend Advance";
                END;
                CASE PaybillTrans."Key Word" OF 'STKS':
                  GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"56";
                 END;
                 */
                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Description := descr;
                GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;


            end;//Member

            //Post
            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            if GenJournalLine.Find('-') then begin
                repeat
                    GLPosting.Run(GenJournalLine);
                until GenJournalLine.Next = 0;
                PaybillTrans.Posted := true;
                PaybillTrans."Date Posted" := Today;
                PaybillTrans.Description := 'Posted';
                PaybillTrans.Modify;
                res := 'TRUE';
                msg := 'Dear ' + Members.Name + ' your acc: ' + Members."No." + ' has been credited with Ksh' + Format(amount) + ' Thank you for using Polytech SACCO Mobile';
                SMSMessage(docNo, Members."No.", Members."Mobile Phone No", msg);
            end
            else begin

                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Needs Manual Posting" := true;
                PaybillTrans.Description := 'Failed';
                PaybillTrans.Modify;
                res := 'FALSE';
            end;


        end;

    end;

    local procedure LoanRepaymentSchedule(varLoanNo: Integer; varPrincipalRepayment: Integer; varInterestRepayment: Integer; varTotalRepayment: Integer)
    begin
    end;


    procedure Loancalculator2(Loansetup: Text[1024]) calcdetails: Text[1024]
    var
        Loanproducts: Text[500];
    begin
        begin
            LoanProducttype.Reset;
            //LoanProducttype.GET();
            LoanProducttype.SetRange(LoanProducttype.Source, LoanProducttype.Source::BOSA);
            if LoanProducttype.Find('-') then begin

                repeat

                    varLoan := varLoan + '::::' + Format(LoanProducttype."Product Description") + ':::' + Format(LoanProducttype."Interest rate") + ':::' + Format(LoanProducttype."No of Installment") + ':::' + Format(LoanProducttype."Max. Loan Amount");

                until LoanProducttype.Next = 0;
                //MESSAGE('Loan Balance %1',loanbalances);
                calcdetails := varLoan;

            end;
        end;
    end;


    procedure OutstandingLoansUSSD(phone: Code[20]) loanbalances: Text[1024]
    begin
        begin

            Members.Reset;
            Members.SetRange(Members."Phone No.", phone);
            if Members.Find('-') then begin
                LoansRegister.Reset;
                LoansRegister.SetRange(LoansRegister."Client Code", Members."No.");
                if LoansRegister.Find('-') then begin
                    repeat
                        LoansRegister.CalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest", LoansRegister."Interest to be paid", LoansRegister."Interest Paid");
                        if (LoansRegister."Outstanding Balance" > 0) or (LoansRegister."Oustanding Interest" > 0) then
                            loanbalances := loanbalances + '::::' + LoansRegister."Loan  No." + ':::' + LoansRegister."Loan Product Type Name" + ':::' +
                             Format(LoansRegister."Outstanding Balance") + ':::' + Format(LoansRegister."Oustanding Interest");
                    until LoansRegister.Next = 0;
                end;

            end;
            if loanbalances = '' then
                loanbalances := '::::no';

        end;
    end;


    procedure PostMPESATrans(docNo: Text[20]; telephoneNo: Text[20]; amount: Decimal; transactionDate: Date) result: Text[30]
    begin

        SurePESATrans.Reset;
        SurePESATrans.SetRange(SurePESATrans."Document No", docNo);
        if SurePESATrans.Find('-') then begin
            result := 'REFEXISTS';
        end
        else begin

            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TestField(GenLedgerSetup."MPESA Settl Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
            // GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            Charges.Reset;
            Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
            if Charges.Find('-') then begin
                Charges.TestField(Charges."GL Account");

                MPESACharge := GetCharge(amount, 'MPESA');
                SwizzKashCharge := GetCharge(amount, 'VENDWD');
                MobileCharges := GetCharge(amount, 'SACCOWD');

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                MPESARecon := GenLedgerSetup."MPESA Settl Acc";
                MobileChargesACC := Charges."GL Account";

                ExcDuty := (20 / 100) * (MobileCharges);
                TotalCharges := SwizzKashCharge + MobileCharges + ExcDuty + MPESACharge;
            end;

            Vendor.Reset;
            Vendor.SetRange(Vendor."No.", telephoneNo);
            // Vendor.SETFILTER(Vendor."Account Type",'<>%1', 'SALARY');
            if Vendor.Find('-') then begin
                Vendor.CalcFields(Vendor."Balance (LCY)");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");

                if (TempBalance > amount + TotalCharges) then begin
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DeleteAll;
                    //end of deletion

                    GenBatches.Reset;
                    GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                    GenBatches.SetRange(GenBatches.Name, 'MPESAWITHD');

                    if GenBatches.Find('-') = false then begin
                        GenBatches.Init;
                        GenBatches."Journal Template Name" := 'GENERAL';
                        GenBatches.Name := 'MPESAWITHD';
                        GenBatches.Description := 'MPESA Withdrawal';
                        GenBatches.Validate(GenBatches."Journal Template Name");
                        GenBatches.Validate(GenBatches.Name);
                        GenBatches.Insert;
                    end;

                    //DR Customer Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'MPESA Withdrawal';
                    GenJournalLine.Amount := amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Cr Bank a/c
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := MPESARecon;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'MPESA Withdrawal';
                    GenJournalLine.Amount := (amount + MPESACharge) * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Dr Withdrawal Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := TotalCharges;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //CR Mobile Transactions Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := MobileChargesACC;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := MobileCharges * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //CR Swizzsoft Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := SwizzKashCommACC;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := -SwizzKashCharge;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := Format(ExxcDuty);
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Post
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'MPESAWITHD');
                    if GenJournalLine.Find('-') then begin
                        repeat
                            GLPosting.Run(GenJournalLine);
                        until GenJournalLine.Next = 0;
                    end;
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DeleteAll;
                    msg := 'You have withdrawn KES ' + Format(amount) + ' from Account ' + Vendor.Name +
                  ' .Thank you for using Polytech Sacco Mobile.';

                    SurePESATrans.Init;
                    SurePESATrans."Document No" := docNo;
                    SurePESATrans.Description := 'MPESA Withdrawal';
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
                    TotalCharges := ExcDuty + MobileCharges + SwizzKashCharge;
                    SurePESATrans.Charge := TotalCharges;
                    SurePESATrans."Account Name" := Vendor.Name;
                    SurePESATrans."Telephone Number" := Vendor."Phone No.";
                    SurePESATrans."SMS Message" := msg;
                    SurePESATrans.Amount := amount;
                    SurePESATrans.Status := SurePESATrans.Status::Completed;
                    SurePESATrans.Posted := true;
                    SurePESATrans."Posting Date" := Today;
                    SurePESATrans.Comments := 'Success';
                    SurePESATrans.Client := Vendor."BOSA Account No";
                    SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Withdrawal;
                    SurePESATrans."Transaction Time" := Time;
                    SurePESATrans.Insert;
                    result := 'TRUE';

                    SMSMessage(docNo, Vendor."No.", Vendor."Phone No.", msg);
                end
                else begin
                    result := 'INSUFFICIENT';
                    /* msg:='You have insufficient funds in your savings Account to use this service.'+
                    ' .Thank you for using KENCREAM Sacco Mobile.';
                    SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                    SurePESATrans.Init;
                    SurePESATrans."Document No" := docNo;
                    SurePESATrans.Description := 'MPESA Withdrawal';
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
                    TotalCharges := ExcDuty + MobileCharges + SwizzKashCharge;
                    SurePESATrans.Charge := TotalCharges;
                    SurePESATrans."Account Name" := Vendor.Name;
                    SurePESATrans."Telephone Number" := Vendor."Phone No.";
                    SurePESATrans.Amount := amount;
                    SurePESATrans.Status := SurePESATrans.Status::Failed;
                    SurePESATrans.Posted := false;
                    SurePESATrans."Posting Date" := Today;
                    SurePESATrans.Comments := 'Failed,Insufficient Funds';
                    SurePESATrans.Client := Vendor."BOSA Account No";
                    SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Withdrawal;
                    SurePESATrans."Transaction Time" := Time;
                    SurePESATrans.Insert;
                end;
            end
            else begin
                result := 'ACCINEXISTENT';
                /* msg:='Your request has failed because account does not exist.'+
                 ' .Thank you for using KENCREAM Sacco Mobile.';
                 SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                SurePESATrans.Init;
                SurePESATrans."Document No" := docNo;
                SurePESATrans.Description := 'MPESA Withdrawal';
                SurePESATrans."Document Date" := Today;
                SurePESATrans."Account No" := '';
                SurePESATrans."Account No2" := MPESARecon;
                SurePESATrans.Amount := amount;
                SurePESATrans.Posted := false;
                SurePESATrans."Posting Date" := Today;
                SurePESATrans.Comments := 'Failed,Invalid Account';
                SurePESATrans.Client := '';
                SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Withdrawal;
                SurePESATrans."Transaction Time" := Time;
                SurePESATrans.Insert;
            end;
        end;

    end;

    local procedure GetCharge(amount: Decimal; "code": Text[20]) charge: Decimal
    begin
        TariffDetails.Reset;
        TariffDetails.SetRange(TariffDetails.Code, code);
        TariffDetails.SetFilter(TariffDetails."Lower Limit", '<=%1', amount);
        TariffDetails.SetFilter(TariffDetails."Upper Limit", '>=%1', amount);
        if TariffDetails.Find('-') then begin
            charge := TariffDetails."Charge Amount";
        end
    end;


    procedure AccountBalanceDec(Acc: Code[30]; amt: Decimal) Bal: Decimal
    begin
        Members.Reset;
        Members.SetRange(Members."Mobile Phone No", Acc);
        // Members.SETRANGE(Members."Demand Savings Status",Members."Demand Savings Status"::Active);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"Jiokoe Savings");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    samount := samount + MemberLedgerEntry.Amount;

                until MemberLedgerEntry.Next = 0;

                GenLedgerSetup.Reset;
                GenLedgerSetup.Get;
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

                Charges.Reset;
                Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");

                    MPESACharge := GetCharge(amt, 'MPESA');
                    SurePESACharge := GetCharge(amt, 'VENDWD');
                    MobileCharges := GetCharge(amt, 'SACCOWD');

                    ExcDuty := (10 / 100) * (MobileCharges + SurePESACharge);
                    TotalCharges := SurePESACharge + MobileCharges + ExcDuty + MPESACharge;
                end;
                Bal := samount - TotalCharges;
            end
        end;
    end;


    procedure postAirtime("Doc No": Code[100]; Phone: Code[100]; amount: Decimal) result: Code[400]
    var
        airtimeAcc: Code[50];
    begin
        SurePESATrans.Reset;
        SurePESATrans.SetRange(SurePESATrans."Document No", "Doc No");
        if SurePESATrans.Find('-') then begin
            result := 'REFEXISTS';
        end
        else begin

            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            GenLedgerSetup.TestField(GenLedgerSetup.AirTimeSettlAcc);
            airtimeAcc := GenLedgerSetup.AirTimeSettlAcc;
        end;

        Members.Reset;
        Members.SetRange(Members."Mobile Phone No", Phone);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"54");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    samount := samount + MemberLedgerEntry.Amount;

                until MemberLedgerEntry.Next = 0;
            end;
            TempBalance := samount;
            if (TempBalance > amount) then begin
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                GenJournalLine.SetRange("Journal Batch Name", 'AIRTIME');
                GenJournalLine.DeleteAll;
                //end of deletion
                GenBatches.Reset;
                GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                GenBatches.SetRange(GenBatches.Name, 'AIRTIME');

                if GenBatches.Find('-') = false then begin
                    GenBatches.Init;
                    GenBatches."Journal Template Name" := 'GENERAL';
                    GenBatches.Name := 'AIRTIME';
                    GenBatches.Description := 'AIRTIME Purchase';
                    GenBatches.Validate(GenBatches."Journal Template Name");
                    GenBatches.Validate(GenBatches.Name);
                    GenBatches.Insert;
                end;

                //DR Customer Acc
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := 'AIRTIME';
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                GenJournalLine."Bal. Account Type" := GenJournalLine."account type"::"G/L Account";
                GenJournalLine."Account No." := Members."No.";
                GenJournalLine."Bal. Account No." := airtimeAcc;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                GenJournalLine."Document No." := "Doc No";
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := 'AIRTIME Purchase';
                GenJournalLine.Amount := amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;



                //Post
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                GenJournalLine.SetRange("Journal Batch Name", 'AIRTIME');
                if GenJournalLine.Find('-') then begin
                    repeat
                        GLPosting.Run(GenJournalLine);
                    until GenJournalLine.Next = 0;
                end;
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                GenJournalLine.SetRange("Journal Batch Name", 'AIRTIME');
                GenJournalLine.DeleteAll;

                SurePESATrans.Init;
                SurePESATrans."Document No" := "Doc No";
                SurePESATrans.Description := 'AIRTIME Purchase';
                SurePESATrans."Document Date" := Today;
                SurePESATrans."Account No" := Members."No.";
                SurePESATrans."Account No2" := Phone;
                SurePESATrans."Account Name" := Members.Name;
                SurePESATrans.Amount := amount;
                SurePESATrans.Status := SurePESATrans.Status::Completed;
                SurePESATrans.Posted := true;
                SurePESATrans."Posting Date" := Today;
                SurePESATrans.Comments := 'Success';
                SurePESATrans.Client := Vendor."BOSA Account No";
                SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Airtime;
                SurePESATrans."Transaction Time" := Time;
                SurePESATrans.Insert;
                result := 'TRUE';
                msg := 'You have purchased airtime worth KES ' + Format(amount) + ' from Account ' + Vendor.Name + ' thank you for using Polytech Sacco Mobile.';
                SMSMessage("Doc No", Vendor."No.", Vendor."Phone No.", msg);
            end
            else begin
                result := 'INSUFFICIENT';
                /* msg:='You have insufficient funds in your savings Account to use this service.'+
                ' .Thank you for using Polytech Sacco Mobile.';
                SMSMessage(docNo,Vendor."No.",Vendor."Phone No.",msg);*/
                SurePESATrans.Init;
                SurePESATrans."Document No" := "Doc No";
                SurePESATrans.Description := 'AIRTIME Purchase';
                SurePESATrans."Document Date" := Today;
                SurePESATrans."Account No" := Vendor."No.";
                SurePESATrans."Account No2" := Phone;
                SurePESATrans.Amount := amount;
                SurePESATrans."Account Name" := Vendor.Name;
                SurePESATrans.Status := SurePESATrans.Status::Failed;
                SurePESATrans.Posted := false;
                SurePESATrans."Posting Date" := Today;
                SurePESATrans.Comments := 'Failed,Insufficient Funds';
                SurePESATrans.Client := Vendor."BOSA Account No";
                SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Airtime;
                SurePESATrans."Transaction Time" := Time;
                SurePESATrans.Insert;
            end;
        end
        else begin
            result := 'ACCINEXISTENT';
            SurePESATrans.Init;
            SurePESATrans."Document No" := "Doc No";
            SurePESATrans.Description := 'AIRTIME Purchase';
            SurePESATrans."Document Date" := Today;
            SurePESATrans."Account No" := '';
            SurePESATrans."Account No2" := Phone;
            SurePESATrans.Amount := amount;
            SurePESATrans."Account Name" := Vendor.Name;
            SurePESATrans.Posted := false;
            SurePESATrans."Posting Date" := Today;
            SurePESATrans.Comments := 'Failed,Invalid Account';
            SurePESATrans.Client := '';
            SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Airtime;
            SurePESATrans."Transaction Time" := Time;
            SurePESATrans.Insert;
        end;

    end;


    procedure getMembernames(memberno: Code[20]) name: Text[1024]
    begin
        Members.Reset;
        Members.SetRange(Members."No.", memberno);
        if Members.Find('-') then begin

            name := Members.Name
        end;
    end;


    procedure AccountBalanceAirtime(Acc: Code[30]; amt: Decimal) Bal: Decimal
    begin
        Members.Reset;
        Members.SetRange(Members."Mobile Phone No", Acc);
        if Members.Find('-') then begin
            MemberLedgerEntry.Reset;
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Customer No.", Members."No.");
            MemberLedgerEntry.SetRange(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."transaction type"::"54");
            if MemberLedgerEntry.Find('-') then begin
                repeat
                    samount := samount + MemberLedgerEntry.Amount;

                until MemberLedgerEntry.Next = 0;

                GenLedgerSetup.Reset;
                GenLedgerSetup.Get;
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

                Charges.Reset;
                Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");

                    MPESACharge := GetCharge(amt, 'MPESA');
                    SurePESACharge := GetCharge(amt, 'VENDWD');
                    MobileCharges := GetCharge(amt, 'SACCOWD');

                    ExcDuty := (10 / 100) * (MobileCharges + SurePESACharge);
                    TotalCharges := SurePESACharge + MobileCharges + ExcDuty + MPESACharge;
                end;
                Bal := samount - TotalCharges;
            end
        end;
    end;

    local procedure FnRecoverInsurance(MembNo: Code[20]; Balance: Decimal) RunningBal: Decimal
    var
        ObjMembReg: Record 51516364;
        InsAmount: Decimal;
        RemainindBal: Decimal;
        PaymentType: Option " ",Insurance,Stock,Interest,"Loan Repayment","Deposit Contribution",ShareCapital,"Demand Savings";
    begin
        /*IF Balance > 0 THEN
        BEGIN
        genstup.GET();
        IF ObjMembReg.GET(MembNo) THEN
          BEGIN
            InsAmount:=PolytechFactory.KnGetInsurancePaid(MembNo);
            IF InsAmount > 0 THEN
              BEGIN
                RemainindBal:=InsAmount;
        
                IF RemainindBal > genstup."Welfare Contribution" THEN
                  RemainindBal:=genstup."Welfare Contribution"
                ELSE
                  RemainindBal:=RemainindBal;
        
                IF RemainindBal > Balance THEN
                  RemainindBal:=Balance
                ELSE
                  RemainindBal:=RemainindBal;
        
                //***************************Create Journal lines*******************************//
                LineNo := LineNo + 10000;
        Surefactory.FnCreateGnlJournalLine(Jtemplate, JBatch, DocNo, LineNo, GenJournalLine."transaction type"::"Insurance Contribution",
                     GenJournalLine."account type"::Member, MembNo, Today, RemainindBal * -1, 'BOSA', DocNo,
                     Format(GenJournalLine."transaction type"::"Insurance Contribution"), '', GenJournalLine."defaulter payment type"::" ");

        //***********************Update variance buffer***************************//
        //FnGetVariance(RemainindBal,genstup."Welfare Contribution",No,PaymentType::Insurance,MembNo,'',"CheckOff Period",LoanApp."Loan Product Type");
        //***********************end update variance************************//

        //***************************Create Journal lines*******************************//
    end;
            END;
Codeunit ""
