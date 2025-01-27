#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51022 SwizzKashMobile
{

    trigger OnRun()
    begin
        Message(PostLoan('78511383102', '100-3023', 25000, 3));
    end;

    var
        Vendor: Record Vendor;
        AccountTypes: Record "Account Types-Saving Products";
        miniBalance: Decimal;
        accBalance: Decimal;
        minimunCount: Integer;
        VendorLedgEntry: Record "Vendor Ledger Entry";
        amount: Decimal;
        Loans: Integer;
        LoansRegister: Record "Loans Register";
        LoanProductsSetup: Record "Loan Products Setup";
        Members: Record Customer;
        dateExpression: Text[20];
        DetailedVendorLedgerEntry: Record "Detailed Vendor Ledg. Entry";
        dashboardDataFilter: Date;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        MemberLedgerEntry: Record "Cust. Ledger Entry";
        SurePESAApplications: Record "SwizzKash Applications";
        GenJournalLine: Record "Gen. Journal Line";
        GenBatches: Record "Gen. Journal Batch";
        LineNo: Integer;
        SurePESATrans: Record "SwizzKash Transactions";
        GenLedgerSetup: Record "General Ledger Setup";
        Charges: Record Charges;
        MobileCharges: Decimal;
        MobileChargesACC: Text[20];
        SurePESACommACC: Code[20];
        SurePESACharge: Decimal;
        ExcDuty: Decimal;
        TempBalance: Decimal;
        SMSMessages: Record "SMS Messages";
        iEntryNo: Integer;
        msg: Text[250];
        accountName1: Text[40];
        accountName2: Text[40];
        fosaAcc: Text[30];
        LoanGuaranteeDetails: Record "Loans Guarantee Details";
        bosaNo: Text[20];
        MPESARecon: Text[20];
        TariffDetails: Record "Tariff Details";
        MPESACharge: Decimal;
        TotalCharges: Decimal;
        ExxcDuty: label '201421';
        PaybillTrans: Record "SwizzKash MPESA Trans";
        PaybillRecon: Code[30];
        fosaConst: label '101';
        accountsFOSA: Text[1023];
        interestRate: Integer;
        LoanAmt: Decimal;
        GLEntries: Record "G/L Entry";
        GLPosting: Codeunit "Gen. Jnl.-Post line";
        SFactory: Codeunit "SURESTEP Factory";
        SwizzKashCommACC: Code[20];
        SwizzKashCharge: Decimal;
        exciseDutyAcc: Code[30];
        exciseDutyRate: Decimal;

    procedure SMSMessage(documentNo: Text[30]; accfrom: Text[30]; phone: Text[20]; message: Text)
    var
        smsmessagesTable: Record "SMS Messages";
    begin

        iEntryNo := 0;
        smsmessagesTable.RESET;
        IF smsmessagesTable.FIND('+') THEN iEntryNo := smsmessagesTable."Entry No";
        iEntryNo += 1;

        smsmessagesTable.Init;
        smsmessagesTable."Entry No" := iEntryNo;
        smsmessagesTable."Batch No" := documentNo;
        smsmessagesTable."Document No" := documentNo;
        smsmessagesTable."Account No" := accfrom;
        smsmessagesTable."Date Entered" := Today;
        smsmessagesTable."Time Entered" := Time;
        smsmessagesTable.Source := 'MOBILETRAN';
        smsmessagesTable."Entered By" := UserId;
        smsmessagesTable."Sent To Server" := smsmessagesTable."sent to server"::No;
        smsmessagesTable."SMS Message" := message;
        smsmessagesTable."Telephone No" := phone;
        if smsmessagesTable."Telephone No" <> '' then
            smsmessagesTable.Insert;

    end;

    procedure GetRegistrationRequests(recCount: Integer) response: Text
    var
        activationsList: Text;
        icount: Integer;
        Mstatus: Text[10];
    begin
        response := '{ "StatusCode":"2","StatusDescription":"ERROR","ActivationRequests":[] }';
        IF recCount <= 0 THEN recCount := 5;

        SurePESAApplications.RESET;
        SurePESAApplications.SETRANGE(SurePESAApplications.SentToServer, false);
        // SurePESAApplications.SETRANGE(SurePESAApplications."PIN Requested", TRUE);
        SurePESAApplications.SETRANGE(SurePESAApplications.ActivationStatus, SurePESAApplications.ActivationStatus::PENDING);
        SurePESAApplications.SETRANGE(SurePESAApplications.status, SurePESAApplications.status::"Pending Approval");
        SurePESAApplications.SETFILTER(SurePESAApplications."Account No", '<>%1', '');
        IF SurePESAApplications.FIND('-') THEN BEGIN
            activationsList := '';
            icount := 0;
            REPEAT

                icount += 1;

                IF SurePESAApplications."Mobile Status" = SurePESAApplications."Mobile Status"::ACTIVE THEN BEGIN
                    Mstatus := '1';
                END ELSE BEGIN
                    Mstatus := '0';
                END;

                IF activationsList = '' THEN BEGIN
                    activationsList := '{ "AccountNo":"' + SurePESAApplications."Account No" + '","Phone":"' + SurePESAApplications.Telephone
                            + '","MobileStatus":"' + Mstatus + '" }';
                END ELSE BEGIN
                    activationsList := activationsList + ',{ "AccountNo":"' + SurePESAApplications."Account No" + '","Phone":"' + SurePESAApplications.Telephone
                            + '","MobileStatus":"' + Mstatus + '" }';
                END;

                SurePESAApplications.ActivationStatus := SurePESAApplications.ActivationStatus::SUBMITTED;
                SurePESAApplications."PIN Requested" := false;
                SurePESAApplications.status := SurePESAApplications.status::Approved;
                SurePESAApplications.SentToServer := true;
                SurePESAApplications.MODIFY;
            UNTIL (icount <= recCount) OR (SurePESAApplications.NEXT = 0);
            IF activationsList <> '' THEN BEGIN
                response := '{ "StatusCode":"000","StatusDescription":"OK","ActivationRequests":[' + activationsList + '] }';
            END ELSE BEGIN
                response := '{ "StatusCode":"3","StatusDescription":"NOPENDINGRESETS","ActivationRequests":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NOPENDINGRESETS","ActivationRequests":[] }';
        END;
    end;

    procedure GetPinRequests(recCount: Integer) response: Text
    var
        activationsList: Text;
        icount: Integer;
        Mstatus: Text[10];
    begin
        response := '{ "StatusCode":"2","StatusDescription":"ERROR","ActivationRequests":[] }';
        IF recCount <= 0 THEN recCount := 5;

        SurePESAApplications.RESET;
        //SurePESAApplications.SETRANGE(SurePESAApplications.SentToServer, TRUE);
        SurePESAApplications.SETRANGE(SurePESAApplications."PIN Requested", TRUE);
        //SurePESAApplications.SETRANGE(SurePESAApplications.ActivationStatus, SurePESAApplications.ActivationStatus::PENDING);
        SurePESAApplications.SETFILTER(SurePESAApplications."Account No", '<>%1', '');
        IF SurePESAApplications.FIND('-') THEN BEGIN
            activationsList := '';
            icount := 0;
            REPEAT

                icount += 1;

                IF SurePESAApplications."Mobile Status" = SurePESAApplications."Mobile Status"::ACTIVE THEN BEGIN
                    Mstatus := '1';
                END ELSE BEGIN
                    Mstatus := '0';
                END;

                IF activationsList = '' THEN BEGIN
                    activationsList := '{ "AccountNo":"' + SurePESAApplications."Account No" + '","Phone":"' + SurePESAApplications.Telephone
                            + '","MobileStatus":"' + Mstatus + '" }';
                END ELSE BEGIN
                    activationsList := activationsList + ',{ "AccountNo":"' + SurePESAApplications."Account No" + '","Phone":"' + SurePESAApplications.Telephone
                            + '","MobileStatus":"' + Mstatus + '" }';
                END;

                SurePESAApplications.ActivationStatus := SurePESAApplications.ActivationStatus::SUBMITTED;
                SurePESAApplications."PIN Requested" := false;
                SurePESAApplications.SentToServer := true;
                SurePESAApplications.MODIFY;
            UNTIL (icount <= recCount) OR (SurePESAApplications.NEXT = 0);
            IF activationsList <> '' THEN BEGIN
                response := '{ "StatusCode":"000","StatusDescription":"OK","ActivationRequests":[' + activationsList + '] }';
            END ELSE BEGIN
                response := '{ "StatusCode":"3","StatusDescription":"NOPENDINGRESETS","ActivationRequests":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NOPENDINGRESETS","ActivationRequests":[] }';
        END;
    end;

    procedure UpdateRegistrationRequests(accountNo: Text[30]) response: Text
    begin

        response := '{ "StatusCode":"2","StatusDescription":"ERROR","UpdateResponse":"FAILED" }';

        SurePESAApplications.RESET;
        //  SurePESAApplications.SETRANGE(SurePESAApplications.SentToServer, TRUE);
        //  SurePESAApplications.SETRANGE(SurePESAApplications."Reset PIN", TRUE);
        SurePESAApplications.SETRANGE(SurePESAApplications."Account No", accountNo);
        IF SurePESAApplications.FIND('-') THEN BEGIN
            SurePESAApplications."PIN Requested" := FALSE;
            SurePESAApplications.SentToServer := TRUE;
            SurePESAApplications.ActivationStatus := SurePESAApplications.ActivationStatus::CONFIRMED;
            SurePESAApplications.status := SurePESAApplications.status::Approved;
            SurePESAApplications.MODIFY;

            response := '{ "StatusCode":"000","StatusDescription":"OK","UpdateResponse":"UPDATED" }';
        END ELSE BEGIN
            response := '{ "StatusCode":"1","StatusDescription":"ACCOUNTNOTFOUND","UpdateResponse":"ACCOUNTNOTFOUND" }';
        END;
    end;

    procedure WSSAccount(phonenumber: text[100]) accounts: Text[550]
    var
        membersTable: Record Customer;
        vendorTable: Record Vendor;
        accountsList: Text;
    begin

        accounts := '{ "StatusCode":"02","StatusDescription":"NOTQUERYIED","Accounts":[] }';

        accountsList := '';

        vendorTable.RESET;
        //vendorTable.SETRANGE(vendorTable."BOSA Account No", membersTable."No.");
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        vendorTable.SETRANGE(vendorTable.Status, vendorTable.Status::Active);
        vendorTable.SetRange(vendorTable.Blocked, vendorTable.Blocked::" ");
        //vendorTable.SETRANGE(vendorTable."Account Type", 'M-WALLET');
        IF vendorTable.FIND('-') THEN BEGIN

            membersTable.RESET;
            membersTable.SETRANGE(membersTable."No.", vendorTable."BOSA Account No");
            membersTable.SETRANGE(membersTable.Status, membersTable.Status::Active);
            IF NOT membersTable.FIND('-') THEN BEGIN
                EXIT('{ "StatusCode":"01","StatusDescription":"MEMBERNOTACTIVEORNOTFOUND","Accounts":[] }');
            END;

            //accounts:='{ "StatusCode":"000","StatusDescription":"OK","Accounts":[ { "AccountNo":"'+vendorTable."No."+'","AccountName":"M-WALLET" } ] }'; //accounts:=accounts+Vendor."No."+'|M-WALLET|4;';
            REPEAT

                IF accountsList = '' THEN BEGIN
                    accountsList := '{ "AccountNo":"' + vendorTable."No." + '","AccountName":"' + AccountDescription(vendorTable."Account Type") + '" }';
                END ELSE BEGIN
                    accountsList += ',{ "AccountNo":"' + vendorTable."No." + '","AccountName":"' + AccountDescription(vendorTable."Account Type") + '" }';
                END;

            UNTIL vendorTable.NEXT = 0;

            IF accountsList <> '' THEN BEGIN
                accounts := '{ "StatusCode":"000","StatusDescription":"OK","Accounts":[' + accountsList + '] }';
            END ELSE BEGIN
                accounts := '{ "StatusCode":"03","StatusDescription":"NOACCOUNTSFOUND","Accounts":[] }';
            END;

        END ELSE BEGIN
            accounts := '{ "StatusCode":"1","StatusDescription":"NUMBERNOTFOUND","Accounts":[] }';
        END;

        exit(accounts);
    end;

    PROCEDURE GetAccountDetails(accountNo: Text[20]) accounts: Text;
    VAR
        membersTable: Record Customer;
        vendorTable: Record Vendor;
        accountsList: Text;
        phone: Text;
    BEGIN

        accounts := '{ "StatusCode":"2","StatusDescription":"ERROR","Accounts":[] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."No.", accountNo);
        vendorTable.SetRange(vendorTable.Blocked, vendorTable.Blocked::" ");
        vendorTable.SETRANGE(vendorTable."Account Type", 'M-WALLET');
        IF vendorTable.FIND('-') THEN BEGIN

            accountsList := '';

            membersTable.RESET;
            membersTable.SETRANGE(membersTable."No.", vendorTable."BOSA Account No");
            membersTable.SETRANGE(membersTable.Status, membersTable.Status::Active);
            IF NOT membersTable.FIND('-') THEN BEGIN
                EXIT('{ "StatusCode":"1","StatusDescription":"MEMBERNOTACTIVEORNOTFOUND","Accounts":[] }');
            END;

            REPEAT

                IF accountsList = '' THEN BEGIN
                    accountsList := '{ "AccountNo":"' + vendorTable."No." + '","AccountName":"' + vendorTable."Account Type" + '" }';
                END ELSE BEGIN
                    accountsList += ',{ "AccountNo":"' + vendorTable."No." + '","AccountName":"' + vendorTable."Account Type" + '" }';
                END;

            UNTIL vendorTable.NEXT = 0;

            IF accountsList <> '' THEN BEGIN
                accounts := '{ "StatusCode":"000","StatusDescription":"OK","Accounts":[' + accountsList + '] }';
            END ELSE BEGIN
                accounts := '{ "StatusCode":"3","StatusDescription":"NOACCOUNTSFOUND","Accounts":[] }';
            END;

        END ELSE BEGIN
            accounts := '{ "StatusCode":"1","StatusDescription":"NUMBERNOTFOUND","Accounts":[] }';
        END;
    END;

    PROCEDURE WithdrawRequest(account: Text[30]; amount: Decimal; traceid: Text[30]; phonenumber: text[100]; transactionDate: DateTime) response: Text
    VAR
        bufferTable: Record "Swizzkash Buffer";
        entryNo: Integer;
        SwizzKashTransTable: Record "SwizzKash Transactions";
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"ERROR","TraceId":"' + traceid + '" }'; // ** DEFAULT, INCASE ERROR OCCURED

        bufferTable.Reset();
        bufferTable.SetRange(bufferTable.Description, 'Withdrawal-' + phonenumber);
        bufferTable.SetRange(bufferTable.Posted, false);
        if bufferTable.Find('-') then begin
            response := '{ "StatusCode":"3","StatusDescription":"Pending Withdrawal request: "' + '","TraceId":"' + traceid + '" }';//'1|EXISTS';
            exit;
        end;

        SwizzKashTransTable.Reset();
        SwizzKashTransTable.SetRange(SwizzKashTransTable."Telephone Number", phonenumber);
        SwizzKashTransTable.SetRange(SwizzKashTransTable.Posted, false);
        if SwizzKashTransTable.Find('-') then begin
            response := '{ "StatusCode":"4","StatusDescription":"unprocessed Withdrawal","TraceId":"' + traceid + '" }';//'1|EXISTS';
            exit;
        end;

        bufferTable.Reset();
        bufferTable.SETRANGE(bufferTable."Trace ID", traceid);
        //bufferTable.SETRANGE(bufferTable.Posted,FALSE);
        IF bufferTable.FIND('-') THEN BEGIN
            // ** IF IT EXISTS RETURN
            response := '{ "StatusCode":"1","StatusDescription":"EXISTS","TraceId":"' + traceid + '" }';//'1|EXISTS';
        END ELSE BEGIN
            /* CHECK ACCOUNT BALANCE */

            bufferTable.INIT;
            bufferTable."Trace ID" := traceid;
            bufferTable."Account No" := account;
            bufferTable."Posting Date" := TODAY;
            bufferTable.Description := 'Withdrawal-' + phonenumber;
            bufferTable.Amount := amount;
            bufferTable."Unit ID" := 'MPESA';
            bufferTable."Transaction Type" := 'Withdrawal';
            bufferTable."Transaction Date" := DT2DATE(transactionDate); //TODAY;
            bufferTable."Transaction Time" := DT2TIME(transactionDate);
            bufferTable.Source := bufferTable.Source::MOBILE;
            bufferTable.INSERT;

            response := '{ "StatusCode":"000","StatusDescription":"OK","TraceId":"' + traceid + '" }';
        END;
    END;

    PROCEDURE WithdrawDecline(traceid: Text[30]; transactionDate: DateTime) response: Text;
    VAR
        bufferTable: Record "SwizzKash Buffer";
    BEGIN
        response := '{ "StatusCode":"1","StatusDescription":"ERROR","TraceId":"' + traceid + '" }'; // ** DEFAULT, INCASE ERROR OCCURED

        bufferTable.SETRANGE(bufferTable."Trace ID", traceid);
        bufferTable.SETRANGE(bufferTable.Posted, FALSE);
        IF bufferTable.FIND('-') THEN BEGIN
            bufferTable.Posted := TRUE;
            bufferTable."Posting Date" := DT2DATE(transactionDate);
            bufferTable.MODIFY;
            response := '{ "StatusCode":"000","StatusDescription":"SUCCESS","TraceId":"' + traceid + '" }';
        END ELSE BEGIN
            response := '{ "StatusCode":"2","StatusDescription":"TRANSNOTFOUND","TraceId":"' + traceid + '" }';
        END;
    END;

    PROCEDURE WithdrawCommit(documentNo: Text[20]; traceid: Text[30]; phonenumber: text[100]; account: Text[20]; amount: Decimal; corporateCharges: Decimal; charges: Decimal; transactionDate: DateTime; appType: Code[100]; description: Text[100]; mpesanames: Text[100]) response: Text
    VAR
        bufferTable: Record "SwizzKash Buffer";
        intNumber: Integer;
        SwizzKashTransTable: Record "SwizzKash Transactions";
    BEGIN
        response := '{ "StatusCode":"2","StatusDescription":"ERROR","TraceId":"' + traceid + '" }'; // ** DEFAULT, INCASE NOT ERROR OCCURED

        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SETRANGE(SwizzKashTransTable."Document No", documentNo);
        //SwizzKashTrans.SETRANGE(SwizzKashTrans.Description,Description);
        IF SwizzKashTransTable.FIND('-') THEN BEGIN
            // ** IF IT EXISTS RETURN
            response := '{ "StatusCode":"1","StatusDescription":"EXISTS","TraceId":"' + traceid + '" }';
        END ELSE BEGIN
            SwizzKashTransTable.INIT;
            SwizzKashTransTable."Document No" := documentNo;
            SwizzKashTransTable.Description := description;
            SwizzKashTransTable."Telephone Number" := phonenumber;
            SwizzKashTransTable."Account No" := account;
            SwizzKashTransTable.Amount := amount;
            SwizzKashTransTable.Charge := charges;
            SwizzKashTransTable."Transaction Type" := SwizzKashTransTable."Transaction Type"::Withdrawal;//TransType;
            SwizzKashTransTable."Document Date" := DT2DATE(transactionDate);
            SwizzKashTransTable."Transaction Time" := DT2TIME(transactionDate);
            SwizzKashTransTable."Account Name" := mpesanames;

            Evaluate(intNumber, traceid);//, intNumber);
            //SwizzKashTransTable.Entry := intNumber;
            SwizzKashTransTable.Posted := FALSE;
            SwizzKashTransTable.INSERT;

            bufferTable.SETRANGE(bufferTable."Trace ID", traceid);
            bufferTable.SETRANGE(bufferTable.Posted, FALSE);
            IF bufferTable.FIND('-') THEN BEGIN
                bufferTable.Posted := TRUE;
                bufferTable."Posting Date" := DT2DATE(transactionDate);
                bufferTable.MODIFY;
            END;

            response := '{ "StatusCode":"000","StatusDescription":"OK","TraceId":"' + traceid + '" }';
        END;
    END;

    PROCEDURE EnquireAccountBalanceOld(traceid: code[30]; phonenumber: text[100]; documentNo: Text[20]; AccountNo: Text[20]; TransactionDate: DateTime) response: Text
    VAR
        exciseDutyRate: Decimal;
        exciseDutyAccount: Text;
        exciseDutyAmount: Decimal;
        Bal: Decimal;
        vendorTable: Record Vendor;
        SwizzKashTrans: Record "SwizzKash Transactions";
        localMessage: Text[300];
        chargesTable: Record charges;
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
        intNumber: Integer;
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            //this checks for that request...
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
        END ELSE BEGIN
            //begins the enquiry process...

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);
            vendorTable.SETRANGE(vendorTable.Status, vendorTable.Status::Active);
            vendorTable.SetRange(vendorTable.Blocked, vendorTable.Blocked::" ");
            //vendorTable.SETRANGE(vendorTable."Account Type", 'M-WALLET');
            IF vendorTable.FIND('-') THEN BEGIN
                //the member is found, and is active..

                // -- get balance enquiry charges
                chargesTable.RESET;
                //chargesTable.SETRANGE(Code, 'BLE');
                Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
                IF chargesTable.FIND('-') THEN BEGIN
                    Charges.TESTFIELD(Charges."GL Account");
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                //starting charges.....
                Charges.RESET;
                Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
                IF Charges.FIND('-') THEN BEGIN
                    Charges.TESTFIELD(Charges."GL Account");
                    MobileCharges := Charges."Charge Amount";
                    MobileChargesACC := Charges."GL Account";
                END;
                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";

                exciseDutyAcc := GetExciseDutyAccount();
                ExcDuty := GetExciseDutyRate() * (MobileCharges);

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";

                ExcDuty := (20 / 100) * (MobileCharges);

                TotalCharges := ExcDuty + (MobileCharges + SwizzKashCharge);

                AccountTypes.RESET;
                AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                //AccountTypes.SETRANGE(AccountTypes."Last Account No Used(HQ)",FALSE);
                IF AccountTypes.FIND('-') THEN BEGIN
                    miniBalance := AccountTypes."Minimum Balance";
                END;
                Vendor.CalcFields(Vendor."Balance (LCY)");
                Vendor.CalcFields(Vendor."ATM Transactions");
                Vendor.CalcFields(Vendor."Uncleared Cheques");
                Vendor.CalcFields(Vendor."EFT Transactions");

                Vendor.CALCFIELDS(Vendor."Balance (LCY)", Vendor."Mobile Transactions");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance + Vendor."Mobile Transactions");

                IF Vendor."Account Type" = 'M-WALLET' THEN BEGIN
                    IF (TempBalance > MobileCharges + SwizzKashCharge) THEN BEGIN
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;
                        //end of deletion

                        GenBatches.RESET;
                        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                        GenBatches.SETRANGE(GenBatches.Name, 'MOBILETRAN');

                        IF GenBatches.FIND('-') = FALSE THEN BEGIN
                            GenBatches.INIT;
                            GenBatches."Journal Template Name" := 'GENERAL';
                            GenBatches.Name := 'MOBILETRAN';
                            GenBatches.Description := 'Balance Enquiry';
                            GenBatches.VALIDATE(GenBatches."Journal Template Name");
                            GenBatches.VALIDATE(GenBatches.Name);
                            GenBatches.INSERT;
                        END;

                        //Dr Mobile Transfer Charges
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := vendorTable."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := traceid;
                        GenJournalLine."External Document No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry' + '' + Vendor.Name + '-' + Vendor."No.";
                        GenJournalLine.Amount := (MobileCharges + SwizzKashCharge);
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := vendorTable."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := traceid;
                        GenJournalLine."External Document No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry' + Vendor.Name + '-' + Vendor."No.";
                        GenJournalLine.Amount := ExcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Ex. Duty
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := ExxcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := traceid;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Source No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry' + '' + Vendor.Name + '-' + Vendor."No.";
                        GenJournalLine.Amount := ExcDuty * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Commission
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := SwizzKashCommACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := traceid;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Source No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry Charges' + '' + Vendor.Name + '-' + Vendor."No.";
                        GenJournalLine.Amount := -SwizzKashCharge;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := MobileChargesACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := traceid;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine."Source No." := Vendor."No.";
                        GenJournalLine.Description := 'Balance Enquiry Charges' + '' + Vendor.Name + '-' + Vendor."No.";
                        GenJournalLine.Amount := MobileCharges * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //Post
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        IF GenJournalLine.FIND('-') THEN BEGIN
                            REPEAT
                                GLPosting.RUN(GenJournalLine);
                            UNTIL GenJournalLine.NEXT = 0;
                        END;
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;


                        AccountTypes.RESET;
                        AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                        //  AccountTypes.SETFILTER(AccountTypes."Last Account No Used(HQ)",'=%1',FALSE);    //Restrict account types
                        IF AccountTypes.FIND('-') THEN BEGIN
                            miniBalance := AccountTypes."Minimum Balance";
                        END;
                        Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                        Vendor.CALCFIELDS(Vendor."ATM Transactions");
                        Vendor.CALCFIELDS(Vendor."Uncleared Cheques");
                        Vendor.CALCFIELDS(Vendor."EFT Transactions");
                        accBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);
                        //Bal := FORMAT(accBalance);
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":' + FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>') + ' }';

                        localMessage := FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>');
                        //SMSMessage(DocumentNo,vendorTable."No.",PhoneNo,' Your Share Capital balance is Kshs: '+localMessage+' Thank you, POLYTECH SACCO Mobile');
                        SMSMessage(DocumentNo, vendorTable."No.", phonenumber, ' Your balance is Kshs: ' + localMessage + '. POLYTECH SACCO Mobile');

                    END
                    ELSE BEGIN
                        //Bal := 'INSUFFICIENT';
                        response := '{ "StatusCode":"3003","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
                        SMSMessage(DocumentNo, vendorTable."No.", phonenumber, ' You have insufficient funds to querry balances. POLYTECH SACCO Mobile');
                    END;
                END
                ELSE BEGIN
                    AccountTypes.RESET;
                    AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                    // AccountTypes.SETFILTER(AccountTypes."Last Account No Used(HQ)",'=%1',FALSE);  //Restrict account types
                    IF AccountTypes.FIND('-') THEN BEGIN
                        miniBalance := AccountTypes."Minimum Balance";
                    END;
                    Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                    Vendor.CALCFIELDS(Vendor."ATM Transactions");
                    Vendor.CALCFIELDS(Vendor."Uncleared Cheques");
                    Vendor.CALCFIELDS(Vendor."EFT Transactions");
                    accBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);
                    //Bal := FORMAT(accBalance);
                    response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":' + FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                END;


                //// -- check m-wallet account balance
                //vendorTable.CALCFIELDS("Balance (LCY)");
                //IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                //response := '{ "StatusCode":"3003","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
                //EXIT(response);
                //END;

                Evaluate(intNumber, traceid);//, intNumber);

                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'Balance Enquiry';
                //SwizzKashTrans.Entry := intNumber;
                SwizzKashTrans."Document Date" := DT2DATE(TransactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//Members."No.";
                SwizzKashTrans.Charge := TotalCharges;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Date Posted" := CurrentDateTime;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                //SwizzKashTrans.Remarks := '';
                SwizzKashTrans.Comments := 'Success';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Balance;//    "Balance Enquiry";
                SwizzKashTrans."Transaction Time" := DT2TIME(TransactionDate);// TIME;
                SwizzKashTrans.INSERT;


                // ** THIS BALANCE IS PLACEHOLDER FOR M-WALLET BALANCE DURING TESTING- TO BE COMMENTED OUT WHEN GOING LIVE
                // {
                // MemberLedgerEntry.RESET;
                //     MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", vendorTable."BOSA Account No");
                //     MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Transaction Type", MemberLedgerEntry."Transaction Type"::"Share Capital");
                //     IF MemberLedgerEntry.FIND('-') THEN BEGIN
                //         REPEAT
                //             Bal := Bal + MemberLedgerEntry.Amount;
                //         UNTIL MemberLedgerEntry.NEXT = 0;
                //         //response:= FORMAT(Bal,0,'<Precision,2:2><Integer><Decimals>');
                //     END;
                // }
                // ** END THIS BALANCE IS PLACEHOLDER FOR M-WALLET BALANCE DURING TESTING- TO BE COMMENTED OUT WHEN GOING LIVE



            END ELSE BEGIN
                response := '{ "StatusCode":"3004","StatusDescription":"ACOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
            END;

        END;
    END;

    PROCEDURE EnquireLoanBalance(traceid: code[30]; phonenumber: text[100]; documentNumber: Text[20]; transactionDate: DateTime) response: Text
    VAR
        loanbalanceList: Text;
        loanbalanceamt: Decimal;
        vendorTable: Record Vendor;
        localMessage: Text;
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        AccountNo: Code[50];
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
        intNumber: Integer;
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", documentNumber);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            EXIT('{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }');
        END;

        vendorTable.RESET;
        vendorTable.SETRANGE("Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group", 'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN

            // ** enable when going live

            // -- get loan balance enquiry charges
            chargesTable.RESET;
            chargesTable.SETRANGE(Code, 'LNB');
            IF chargesTable.FIND('-') THEN BEGIN
                vendorCommAcc := chargesTable."GL Account";
                vendorCommAmount := chargesTable."Charge Amount";
                saccoCommAmount := chargesTable."Sacco Amount";
                saccoCommAcc := chargesTable."GL Account";//'3000407';     // -- sacco commission account
            END;

            // -- check m-wallet account balance
            vendorTable.CALCFIELDS("Balance (LCY)");
            IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                EXIT('{ "StatusCode":"3003","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }');
            END;

            // ** POST THE LOAN BALANCE ENQUIRY CHARGES ** //

            journalTemplateName := 'GENERAL';
            journalBatchName := 'LOANENQ';

            ClearGLJournal(journalTemplateName, journalBatchName);
            PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'LOAN BALANCE ENQUIRY');

            //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
            LineNo := LineNo + 10000;
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := journalTemplateName;
            GenJournalLine."Journal Batch Name" := journalBatchName;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Document No." := documentNumber;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
            GenJournalLine."Account No." := vendorTable."No.";
            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
            GenJournalLine."External Document No." := vendorCommAcc;
            GenJournalLine."Posting Date" := DT2DATE(transactionDate);// swizzkasTransTable."Document Date";
            GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
            GenJournalLine.VALIDATE(GenJournalLine.Amount);
            GenJournalLine.Description := 'Loan Bal. Enquiry-SwizzKash Comm.';
            IF GenJournalLine.Amount <> 0 THEN
                GenJournalLine.INSERT;

            //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
            LineNo := LineNo + 10000;
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := journalTemplateName;
            GenJournalLine."Journal Batch Name" := journalBatchName;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Document No." := documentNumber;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            GenJournalLine."Account No." := vendorCommAcc;
            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
            GenJournalLine."External Document No." := vendorTable."No.";
            GenJournalLine."Posting Date" := DT2DATE(transactionDate);// swizzkasTransTable."Document Date";
            GenJournalLine.Amount := vendorCommAmount * -1;
            GenJournalLine.VALIDATE(GenJournalLine.Amount);
            GenJournalLine.Description := 'Loan Bal. Enquiry-SwizzKash Comm.';
            IF GenJournalLine.Amount <> 0 THEN
                GenJournalLine.INSERT;

            //Cr Sacco Comm Acc - Sacco comm. Charges
            LineNo := LineNo + 10000;
            GenJournalLine.INIT;
            GenJournalLine."Journal Template Name" := journalTemplateName;
            GenJournalLine."Journal Batch Name" := journalBatchName;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Document No." := documentNumber;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            GenJournalLine."Account No." := saccoCommAcc;
            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
            GenJournalLine."External Document No." := vendorTable."No.";
            GenJournalLine."Posting Date" := DT2DATE(transactionDate);// swizzkasTransTable."Document Date";
            GenJournalLine.Amount := saccoCommAmount * -1;
            GenJournalLine.VALIDATE(GenJournalLine.Amount);
            GenJournalLine.Description := 'Loan Bal. Enquiry-SACCO Comm.';
            IF GenJournalLine.Amount <> 0 THEN
                GenJournalLine.INSERT;

            //Post
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
            GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
            IF GenJournalLine.FIND('-') THEN BEGIN
                REPEAT
                    GLPosting.RUN(GenJournalLine);
                UNTIL GenJournalLine.NEXT = 0;
            END;

            Evaluate(intNumber, traceid);

            SwizzKashTrans.INIT;
            SwizzKashTrans."Document No" := documentNumber;
            SwizzKashTrans.Description := 'Loan Balance';
            //SwizzKashTrans.Entry := intNumber;
            SwizzKashTrans."Document Date" := DT2DATE(transactionDate);
            SwizzKashTrans."Account No" := vendorTable."No.";
            SwizzKashTrans.Charge := 0;
            SwizzKashTrans."Account Name" := vendorTable.Name;
            SwizzKashTrans."Telephone Number" := phonenumber;
            SwizzKashTrans."Account No2" := '';
            SwizzKashTrans.Amount := 0;
            SwizzKashTrans.Posted := TRUE;
            SwizzKashTrans."Posting Date" := TODAY;
            SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
            SwizzKashTrans.Comments := 'POSTED';
            SwizzKashTrans.Client := vendorTable.Name;//Members."No.";
            SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::"Loan balance";
            SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);
            SwizzKashTrans.INSERT;
            // ** END POST THE LOAN BALANCE ENQUIRY CHARGES ** //

            // ** COMPILE LOAN BALANCE STATEMENT ** //
            LoansRegister.RESET;
            LoansRegister.SetFilter(LoansRegister."Client Code", '%1|%2', vendorTable."BOSA Account No", vendorTable."No.");
            IF LoansRegister.FIND('-') THEN BEGIN
                loanbalanceList := '';
                REPEAT
                    LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest", LoansRegister."Interest to be paid", LoansRegister."Interest Paid");
                    IF (LoansRegister."Outstanding Balance" > 0) THEN BEGIN
                        loanbalanceamt := (LoansRegister."Outstanding Balance" + LoansRegister."Oustanding Interest");
                        IF loanbalanceList = '' THEN BEGIN
                            loanbalanceList := ' { "LoanNo":"' + LoansRegister."Loan  No." + '","ProductType":"' + GetLoanProductName(LoansRegister."Loan Product Type") + '","BalanceAmount":' + FORMAT(loanbalanceamt) + ' } ';
                            localMessage := LoansRegister."Loan  No." + ' ' + GetLoanProductName(LoansRegister."Loan Product Type") + ' ' + FORMAT(loanbalanceamt) + ',';
                        END ELSE BEGIN
                            loanbalanceList += ',{ "LoanNo":"' + LoansRegister."Loan  No." + '","ProductType":"' + GetLoanProductName(LoansRegister."Loan Product Type") + '","BalanceAmount":' + FORMAT(loanbalanceamt) + ' } ';
                            localMessage += LoansRegister."Loan  No." + ' ' + GetLoanProductName(LoansRegister."Loan Product Type") + ' ' + FORMAT(loanbalanceamt) + ',';
                        END;
                    END;
                UNTIL LoansRegister.NEXT = 0;

                IF loanbalanceList <> '' THEN BEGIN
                    response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [' + loanbalanceList + '] }';
                END ELSE BEGIN
                    response := '{ "StatusCode":"3003","StatusDescription":"NOOUTSTANDINGLOANS","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }';
                    localMessage := 'No Outstanding loans';
                END;

            END ELSE BEGIN



                response := '{ "StatusCode":"3004","StatusDescription":"NOOUTSTANDINGLOANS","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }';
                localMessage := 'No Outstanding loans';
            END;

            // ** send loan balance statement ** //
            SMSMessage(documentNumber, vendorTable."No.", phonenumber, localMessage + '. POLYTECH MOBILE');

        END ELSE BEGIN
            response := '{ "StatusCode":"3005","StatusDescription":"NUMBERNOTFOUND","DocumentNo":"' + documentNumber + '","Phone":"' + phonenumber + '","LoanBalances": [] }';
        END;

    END;

    //FOSA BALANCE
    PROCEDURE EnquireAccountBalance(traceid: code[30]; phonenumber: text[100]; documentNo: Text[20]; AccountNo: Text[20]; TransactionDate: DateTime) response: Text
    VAR
        exciseDutyRate: Decimal;
        exciseDutyAccount: Text;
        exciseDutyAmount: Decimal;
        Bal: Decimal;
        vendorTable: Record Vendor;
        SwizzKashTrans: Record "SwizzKash Transactions";
        localMessage: Text[300];
        chargesTable: Record charges;
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
        intNumber: Integer;
    BEGIN
        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", documentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            //Bal:='REFEXISTS';
            response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + documentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
        END
        ELSE BEGIN
            // Bal := '';
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");
                MobileCharges := Charges."Charge Amount";
                MobileChargesACC := Charges."GL Account";
            END;

            SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";

            ExcDuty := (20 / 100) * (MobileCharges);

            Vendor.RESET;
            Vendor.RESET;
            Vendor.SETRANGE("Mobile Phone No", phonenumber);
            Vendor.SETRANGE(Vendor.Status, Vendor.Status::Active);
            Vendor.SetRange(Vendor.Blocked, Vendor.Blocked::" ");
            Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            //Vendor.SETRANGE(Vendor."No.", Acc);
            //Vendor.SETRANGE("Mobile Phone No", phonenumber);
            IF Vendor.FIND('-') THEN BEGIN
                AccountTypes.RESET;
                AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                //AccountTypes.SETRANGE(AccountTypes."Last Account No Used(HQ)",FALSE);
                IF AccountTypes.FIND('-') THEN BEGIN
                    miniBalance := AccountTypes."Minimum Balance";
                END;
                Vendor.CALCFIELDS(Vendor."Balance (LCY)", Vendor."ATM Transactions", Vendor."Uncleared Cheques", Vendor."EFT Transactions");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);

                IF (Vendor."Account Type" = 'M-WALLET') OR (Vendor."Account Type" = 'SALARY') OR (Vendor."Account Type" = 'FIXED') THEN BEGIN
                    IF (TempBalance > MobileCharges + SwizzKashCharge) THEN BEGIN
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;
                        //end of deletion

                        GenBatches.RESET;
                        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                        GenBatches.SETRANGE(GenBatches.Name, 'MOBILETRAN');

                        IF GenBatches.FIND('-') = FALSE THEN BEGIN
                            GenBatches.INIT;
                            GenBatches."Journal Template Name" := 'GENERAL';
                            GenBatches.Name := 'MOBILETRAN';
                            GenBatches.Description := 'Balance Enquiry';
                            GenBatches.VALIDATE(GenBatches."Journal Template Name");
                            GenBatches.VALIDATE(GenBatches.Name);
                            GenBatches.INSERT;
                        END;

                        //Dr Mobile Transfer Charges
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := Vendor."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := MobileCharges + SwizzKashCharge;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := Vendor."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := ExcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := ExxcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := ExcDuty * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Commission
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := SwizzKashCommACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry Charges';
                        GenJournalLine.Amount := -SwizzKashCharge;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := MobileChargesACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry Charges';
                        GenJournalLine.Amount := MobileCharges * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //Post
                        GenJournalLine.RESET;

                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        IF GenJournalLine.FIND('-') THEN BEGIN
                            REPEAT
                                GLPosting.RUN(GenJournalLine);
                            UNTIL GenJournalLine.NEXT = 0;
                        END;
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;

                        SwizzKashTrans.INIT;
                        SwizzKashTrans."Document No" := DocumentNo;
                        SwizzKashTrans.Description := 'Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        SwizzKashTrans."Document Date" := TODAY;
                        SwizzKashTrans."Account No" := Vendor."No.";
                        TotalCharges := ExcDuty + MobileCharges + SwizzKashCharge;
                        SwizzKashTrans.Charge := TotalCharges;
                        SwizzKashTrans."Account Name" := Vendor.Name;
                        SwizzKashTrans."Telephone Number" := Vendor."Mobile Phone No";
                        SwizzKashTrans."Account No2" := '';
                        SwizzKashTrans.Amount := amount;
                        SwizzKashTrans.Posted := TRUE;
                        SwizzKashTrans."Posting Date" := TODAY;
                        SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                        SwizzKashTrans.Comments := 'Success';
                        SwizzKashTrans.Client := Vendor."BOSA Account No";
                        SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Balance;
                        SwizzKashTrans."Transaction Time" := TIME;
                        SwizzKashTrans."APP Type" := 'USSD';
                        SwizzKashTrans.INSERT;

                        AccountTypes.RESET;
                        AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                        IF AccountTypes.FIND('-') THEN BEGIN
                            miniBalance := AccountTypes."Minimum Balance";
                        END;
                        Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                        Vendor.CALCFIELDS(Vendor."ATM Transactions");
                        Vendor.CALCFIELDS(Vendor."Uncleared Cheques");
                        Vendor.CALCFIELDS(Vendor."EFT Transactions");
                        accBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);
                        msg := 'Account Name: ' + Vendor.Name + ', ' + 'BALANCE: ' + FORMAT(accBalance) + '. '
                       + 'Thank you for using POLYTECH  Sacco Mobile';
                        //SMSMessage(DocNumber, Vendor."No.", Vendor."Mobile Phone No", msg);
                        localMessage := FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>');
                        SMSMessage(DocumentNo, Vendor."No.", phonenumber, ' Your balance is Kshs: ' + localMessage + '. Thank you for using POLYTECH SACCO Mobile Banking.');
                        //Bal := FORMAT(accBalance);
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":' + FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                    END
                    ELSE BEGIN
                        // Bal:='INSUFFICIENT';
                        response := '{ "StatusCode":"3003","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';

                    END;
                END
                ELSE BEGIN
                    AccountTypes.RESET;
                    AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                    IF AccountTypes.FIND('-') THEN BEGIN
                        miniBalance := AccountTypes."Minimum Balance";
                    END;
                END;
            END
            ELSE BEGIN
                //Bal:='ACCNOTFOUND';
                response := '{ "StatusCode":"3004","StatusDescription":"ACOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';

            END;
        END;
    END;

    //BOSA BALANCE
    PROCEDURE EnquireAccountBalanceBOSA(traceid: code[30]; phonenumber: text[100]; documentNo: Text[20]; AccountNo: Text[20]; TransactionDate: DateTime) response: Text
    VAR
        exciseDutyRate: Decimal;
        exciseDutyAccount: Text;
        exciseDutyAmount: Decimal;
        Bal: Decimal;
        vendorTable: Record Vendor;
        SwizzKashTrans: Record "SwizzKash Transactions";
        localMessage: Text[300];
        chargesTable: Record charges;
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
        intNumber: Integer;
        khojaBalances: Decimal;
        sharesBalances: Decimal;
        memberDeposits: Decimal;
        accountsBalances: Text[500];
    BEGIN
        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", documentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            //Bal:='REFEXISTS';
            response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + documentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';
        END
        ELSE BEGIN
            // Bal := '';
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");
                MobileCharges := Charges."Charge Amount";
                MobileChargesACC := Charges."GL Account";
            END;

            SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";

            ExcDuty := (20 / 100) * (MobileCharges);

            Vendor.RESET;
            Vendor.RESET;
            Vendor.SETRANGE("Mobile Phone No", phonenumber);
            Vendor.SETRANGE(Vendor.Status, Vendor.Status::Active);
            Vendor.SetRange(Vendor.Blocked, Vendor.Blocked::" ");
            Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            //Vendor.SETRANGE(Vendor."No.", Acc);
            //Vendor.SETRANGE("Mobile Phone No", phonenumber);
            IF Vendor.FIND('-') THEN BEGIN
                AccountTypes.RESET;
                AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                //AccountTypes.SETRANGE(AccountTypes."Last Account No Used(HQ)",FALSE);
                IF AccountTypes.FIND('-') THEN BEGIN
                    miniBalance := AccountTypes."Minimum Balance";
                END;
                Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                Vendor.CALCFIELDS(Vendor."Balance (LCY)", Vendor."ATM Transactions", Vendor."Uncleared Cheques", Vendor."EFT Transactions");

                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);

                IF (Vendor."Account Type" = 'M-WALLET') OR (Vendor."Account Type" = 'SALARY') OR (Vendor."Account Type" = 'FIXED') THEN BEGIN
                    IF (TempBalance > MobileCharges + SwizzKashCharge) THEN BEGIN
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;
                        //end of deletion

                        GenBatches.RESET;
                        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                        GenBatches.SETRANGE(GenBatches.Name, 'MOBILETRAN');

                        IF GenBatches.FIND('-') = FALSE THEN BEGIN
                            GenBatches.INIT;
                            GenBatches."Journal Template Name" := 'GENERAL';
                            GenBatches.Name := 'MOBILETRAN';
                            GenBatches.Description := 'Balance Enquiry';
                            GenBatches.VALIDATE(GenBatches."Journal Template Name");
                            GenBatches.VALIDATE(GenBatches.Name);
                            GenBatches.INSERT;
                        END;

                        //Dr Mobile Transfer Charges
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := Vendor."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := MobileCharges + SwizzKashCharge;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                        GenJournalLine."Account No." := Vendor."No.";
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := Vendor."No.";
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := ExcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := ExxcDuty;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Excise duty-Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        GenJournalLine.Amount := ExcDuty * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Commission
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := SwizzKashCommACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry Charges';
                        GenJournalLine.Amount := -SwizzKashCharge;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        GenJournalLine.INIT;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                        GenJournalLine."Account No." := MobileChargesACC;
                        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocumentNo;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := TODAY;
                        GenJournalLine.Description := 'Balance Enquiry Charges';
                        GenJournalLine.Amount := MobileCharges * -1;
                        GenJournalLine.VALIDATE(GenJournalLine.Amount);
                        IF GenJournalLine.Amount <> 0 THEN
                            GenJournalLine.INSERT;

                        //Post
                        GenJournalLine.RESET;

                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        IF GenJournalLine.FIND('-') THEN BEGIN
                            REPEAT
                                GLPosting.RUN(GenJournalLine);
                            UNTIL GenJournalLine.NEXT = 0;
                        END;
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DELETEALL;

                        SwizzKashTrans.INIT;
                        SwizzKashTrans."Document No" := DocumentNo;
                        SwizzKashTrans.Description := 'Balance Enquiry-' + Vendor."No." + '' + Vendor.Name;
                        SwizzKashTrans."Document Date" := TODAY;
                        SwizzKashTrans."Account No" := Vendor."No.";
                        TotalCharges := ExcDuty + MobileCharges + SwizzKashCharge;
                        SwizzKashTrans.Charge := TotalCharges;
                        SwizzKashTrans."Account Name" := Vendor.Name;
                        SwizzKashTrans."Telephone Number" := Vendor."Mobile Phone No";
                        SwizzKashTrans."Account No2" := '';
                        SwizzKashTrans.Amount := amount;
                        SwizzKashTrans.Posted := TRUE;
                        SwizzKashTrans."Posting Date" := TODAY;
                        SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                        SwizzKashTrans.Comments := 'Success';
                        SwizzKashTrans.Client := Vendor."BOSA Account No";
                        SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Balance;
                        SwizzKashTrans."Transaction Time" := TIME;
                        SwizzKashTrans."APP Type" := 'USSD';
                        SwizzKashTrans.INSERT;

                        AccountTypes.RESET;
                        AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                        IF AccountTypes.FIND('-') THEN BEGIN
                            miniBalance := AccountTypes."Minimum Balance";
                        END;

                        Members.Reset();
                        Members.SetRange("No.", Vendor."BOSA Account No");
                        IF Members.FINDFIRST() THEN BEGIN
                            Members.CalcFields(Members."Holiday Savings", Members."Current Shares", Members."Shares Retained");
                            sharesBalances := Members."Shares Retained";
                            memberDeposits := Members."Current Shares";
                            khojaBalances := Members."Holiday Savings";

                        end
                    end;
                    accountsBalances := 'Account Name: ' + Vendor.Name + ', ' + 'Deposits: ' + FORMAT(memberDeposits, 0, '<Precision,2:2><Integer><Decimals>') + ',' + 'Share Capital: ' + FORMAT(sharesBalances, 0, '<Precision,2:2><Integer><Decimals>') + ',' + 'Khoja Savings: ' + FORMAT(khojaBalances, 0, '<Precision,2:2><Integer><Decimals>') + ',' + '. '
                   + 'Thank you for using POLYTECH  Sacco Mobile';
                    SMSMessage(DocumentNo, Vendor."No.", phonenumber, ' Your Balances: ' + accountsBalances + '. Thank you for using POLYTECH SACCO Mobile Banking.');
                    //Bal := FORMAT(accBalance);
                    response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":' + FORMAT(accBalance, 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                END
                ELSE BEGIN

                    response := '{ "StatusCode":"3003","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';

                END;
            END

            ELSE BEGIN

                response := '{ "StatusCode":"3004","StatusDescription":"ACOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNo + '","AccountBal":0 }';

            END;
        END;
    end;



    PROCEDURE EnquireMinistatement(traceid: code[30]; phonenumber: Text; DocumentNo: Text; AccountNumber: Text; transactionDate: DateTime) response: Text
    VAR
        phone: Text;
        amount: Decimal;
        transactionsList: Text;
        vendorTable: Record 23;
        localMessage: Text;
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
        END ELSE BEGIN

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);

            IF vendorTable.FIND('-') THEN BEGIN

                // ** enable when live

                // -- get loan balance enquiry charges
                chargesTable.RESET;
                chargesTable.SETRANGE(Code, 'MIS');
                IF chargesTable.FIND('-') THEN BEGIN
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                // -- check m-wallet account balance TRUE THEN BEGIN// 
                vendorTable.CALCFIELDS("Balance (LCY)");
                vendorTable.CALCFIELDS(vendorTable."Balance (LCY)", vendorTable."ATM Transactions", vendorTable."Uncleared Cheques", vendorTable."EFT Transactions");

                IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                    EXIT('{ "StatusCode":"3002","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }');
                END;

                journalTemplateName := 'GENERAL';
                journalBatchName := 'MINISTTMNT';

                ClearGLJournal(journalTemplateName, journalBatchName);
                PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'MINISTATEMENT ENQUIRY');

                if vendorTable."No." <> '0101-001-68954' then begin
                    //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := vendorTable."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorCommAcc;
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := vendorCommAcc;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorTable."No.";
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := vendorCommAmount * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Sacco Comm Acc - Sacco comm. Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := saccoCommAcc;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorTable."No.";
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := saccoCommAmount * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SACCO Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
                    GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                    END;
                end;



                phone := phonenumber;// Members."Phone No.";// getMemberphonenumber(AccountNumber);
                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'MiniStatement';
                SwizzKashTrans."Document Date" := DT2DATE(transactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//."BOSA Account No";// Members."No.";
                SwizzKashTrans.Charge := 0;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Amount := 0;
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                SwizzKashTrans.Comments := 'POSTED';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";//Members."No.";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Ministatement;
                SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);// TIME;
                SwizzKashTrans.INSERT;

                minimunCount := 1;
                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.ASCENDING(FALSE);
                MemberLedgerEntry.SETFILTER(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", vendorTable."BOSA Account No");
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry.Reversed, false);
                IF MemberLedgerEntry.FINDSET THEN BEGIN
                    response := '';
                    transactionsList := '';
                    REPEAT
                        amount := MemberLedgerEntry."Amount Posted";
                        IF amount < 1 THEN amount := amount * -1;
                        IF transactionsList = '' THEN BEGIN
                            transactionsList := '{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage := FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END ELSE BEGIN
                            localMessage += FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END;

                        minimunCount := minimunCount + 1;

                    UNTIL (minimunCount > 5) OR (MemberLedgerEntry.NEXT = 0);

                    IF transactionsList <> '' THEN BEGIN
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [' + transactionsList + '] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"3003","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                        localMessage := 'No transactions';
                    END;
                END ELSE BEGIN
                    response := '{ "StatusCode":"3004","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                    localMessage := 'No transactions';
                END;
                SMSMessage(DocumentNo, AccountNumber, phonenumber, localMessage + '. POLYTECH SACCO');
            END ELSE BEGIN
                response := '{ "StatusCode":"3005","StatusDescription":"ACCOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
            END;

        END;
    END;

    PROCEDURE MINISTATEMENT_FOSA(traceid: code[30]; phonenumber: Text; DocumentNo: Text; AccountNumber: Text; transactionDate: DateTime) response: Text[1000]
    VAR
        phone: Text;
        amount: Decimal;
        transactionsList: Text;
        vendorTable: Record 23;
        localMessage: Text[1000];
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
        VendorLedgerEntries: Record "Vendor Ledger Entry";
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
        END ELSE BEGIN

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);
            //vendorTable.SETRANGE("No.",AccountNumber);
            IF vendorTable.FIND('-') THEN BEGIN

                // ** enable when live

                // -- get loan balance enquiry charges
                chargesTable.RESET;
                chargesTable.SETRANGE(Code, 'MIS');
                IF chargesTable.FIND('-') THEN BEGIN
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                // -- check m-wallet account balance
                vendorTable.CALCFIELDS("Balance (LCY)");
                IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                    EXIT('{ "StatusCode":"3002","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }');
                END;

                journalTemplateName := 'GENERAL';
                journalBatchName := 'MINISTTMNT';

                ClearGLJournal(journalTemplateName, journalBatchName);
                PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'MINISTATEMENT ENQUIRY');

                if vendorTable."No." <> '0101-001-68954' then begin
                    //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := vendorTable."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorCommAcc;
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := vendorCommAcc;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorTable."No.";
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := vendorCommAmount * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Sacco Comm Acc - Sacco comm. Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := journalTemplateName;
                    GenJournalLine."Journal Batch Name" := journalBatchName;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := DocumentNo;//documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := saccoCommAcc;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."External Document No." := vendorTable."No.";
                    GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                    GenJournalLine.Amount := saccoCommAmount * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    GenJournalLine.Description := 'Ministatement Enquiry-SACCO Comm.';
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
                    GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                    END;

                end;
                phone := phonenumber;// Members."Phone No.";// getMemberphonenumber(AccountNumber);
                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'MiniStatement';
                SwizzKashTrans."Document Date" := DT2DATE(transactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//."BOSA Account No";// Members."No.";
                SwizzKashTrans.Charge := 0;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Amount := 0;
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                SwizzKashTrans.Comments := 'POSTED';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";//Members."No.";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Ministatement;
                SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);// TIME;
                SwizzKashTrans.INSERT;

                minimunCount := 1;

                VendorLedgerEntries.RESET;
                VendorLedgerEntries.SETCURRENTKEY(VendorLedgerEntries."Entry No.");
                VendorLedgerEntries.ASCENDING(FALSE);
                VendorLedgerEntries.SETFILTER(VendorLedgerEntries.Description, '<>%1', '*Charges*');
                VendorLedgerEntries.SETFILTER(VendorLedgerEntries.Description, '<>%1', '*Balance*');
                VendorLedgerEntries.SETRANGE(VendorLedgerEntries."Vendor No.", vendorTable."No.");
                VendorLedgerEntries.SETRANGE(VendorLedgerEntries.Reversed, false);
                IF VendorLedgerEntries.FINDSET THEN BEGIN
                    response := '';
                    transactionsList := '';
                    REPEAT
                        VendorLedgerEntries.CalcFields(Amount);
                        amount := VendorLedgerEntries.Amount;

                        IF amount < 1 THEN amount := amount * -1;
                        IF transactionsList = '' THEN BEGIN
                            transactionsList := '{"PostingDate":"' + FORMAT(VendorLedgerEntries."Posting Date") + '","Description":"' + VendorLedgerEntries.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage := FORMAT(VendorLedgerEntries."Posting Date") + ' ' + VendorLedgerEntries.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END ELSE BEGIN
                            transactionsList += ',{"PostingDate":"' + FORMAT(VendorLedgerEntries."Posting Date") + '","Description":"' + VendorLedgerEntries.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage += FORMAT(VendorLedgerEntries."Posting Date") + ' ' + VendorLedgerEntries.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END;

                        minimunCount := minimunCount + 1;
                    //IF minimunCount>5 THEN EXIT;

                    UNTIL (minimunCount > 5) OR (VendorLedgerEntries.NEXT = 0);

                    IF transactionsList <> '' THEN BEGIN
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [' + transactionsList + '] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"3003","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                        localMessage := 'No transactions';
                    END;

                END ELSE BEGIN
                    response := '{ "StatusCode":"3004","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                    localMessage := 'No transactions';
                END;

                SMSMessage(DocumentNo, AccountNumber, phonenumber, localMessage + '. POLYTECH SACCO');

            END ELSE BEGIN
                response := '{ "StatusCode":"3005","StatusDescription":"ACCOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
            END;

        END;
    END;

    PROCEDURE MINISTATEMENT_DEPOSITS(traceid: code[30]; phonenumber: Text; DocumentNo: Text; AccountNumber: Text; transactionDate: DateTime) response: Text
    VAR
        phone: Text;
        amount: Decimal;
        transactionsList: Text;
        vendorTable: Record 23;
        localMessage: Text;
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
        END ELSE BEGIN

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);
            //vendorTable.SETRANGE("No.",AccountNumber);
            IF vendorTable.FIND('-') THEN BEGIN

                // ** enable when live

                // -- get loan balance enquiry charges
                chargesTable.RESET;
                chargesTable.SETRANGE(Code, 'MIS');
                IF chargesTable.FIND('-') THEN BEGIN
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                // -- check m-wallet account balance
                vendorTable.CALCFIELDS("Balance (LCY)");
                IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                    EXIT('{ "StatusCode":"3002","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }');
                END;

                journalTemplateName := 'GENERAL';
                journalBatchName := 'MINISTTMNT';

                ClearGLJournal(journalTemplateName, journalBatchName);
                PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'MINISTATEMENT ENQUIRY');


                //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := vendorTable."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorCommAcc;
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := vendorCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Sacco Comm Acc - Sacco comm. Charges
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := saccoCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := saccoCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SACCO Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;


                //Post
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
                GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                END;


                phone := phonenumber;// Members."Phone No.";// getMemberphonenumber(AccountNumber);
                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'MiniStatement';
                SwizzKashTrans."Document Date" := DT2DATE(transactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//."BOSA Account No";// Members."No.";
                SwizzKashTrans.Charge := 0;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Amount := 0;
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                SwizzKashTrans.Comments := 'POSTED';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";//Members."No.";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Ministatement;
                SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);// TIME;
                SwizzKashTrans.INSERT;

                minimunCount := 1;

                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.ASCENDING(FALSE);
                MemberLedgerEntry.SETFILTER(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", vendorTable."BOSA Account No");
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry.Reversed, false);
                IF MemberLedgerEntry.FINDSET THEN BEGIN

                    response := '';
                    transactionsList := '';

                    REPEAT

                        amount := MemberLedgerEntry."Amount Posted";
                        IF amount < 1 THEN amount := amount * -1;

                        IF transactionsList = '' THEN BEGIN
                            transactionsList := '{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage := FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END ELSE BEGIN
                            transactionsList += ',{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage += FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END;

                        minimunCount := minimunCount + 1;
                    //IF minimunCount>5 THEN EXIT;

                    UNTIL (minimunCount > 5) OR (MemberLedgerEntry.NEXT = 0);

                    IF transactionsList <> '' THEN BEGIN
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [' + transactionsList + '] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"3003","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                        localMessage := 'No transactions';
                    END;

                END ELSE BEGIN
                    response := '{ "StatusCode":"3004","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                    localMessage := 'No transactions';
                END;

                SMSMessage(DocumentNo, AccountNumber, phonenumber, localMessage + '. POLYTECH SACCO');

            END ELSE BEGIN
                response := '{ "StatusCode":"3005","StatusDescription":"ACCOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
            END;

        END;
    END;
    //MINISTATEMENT_LOAN
    PROCEDURE MINISTATEMENT_SHARES(traceid: code[30]; phonenumber: Text; DocumentNo: Text; AccountNumber: Text; transactionDate: DateTime) response: Text
    VAR
        phone: Text;
        amount: Decimal;
        transactionsList: Text;
        vendorTable: Record 23;
        localMessage: Text;
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
        END ELSE BEGIN

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);
            //vendorTable.SETRANGE("No.",AccountNumber);
            IF vendorTable.FIND('-') THEN BEGIN

                // ** enable when live

                // -- get loan balance enquiry charges
                chargesTable.RESET;
                chargesTable.SETRANGE(Code, 'MIS');
                IF chargesTable.FIND('-') THEN BEGIN
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                // -- check m-wallet account balance
                vendorTable.CALCFIELDS("Balance (LCY)");
                IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                    EXIT('{ "StatusCode":"3002","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }');
                END;

                journalTemplateName := 'GENERAL';
                journalBatchName := 'MINISTTMNT';

                ClearGLJournal(journalTemplateName, journalBatchName);
                PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'MINISTATEMENT ENQUIRY');


                //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := vendorTable."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorCommAcc;
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := vendorCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Sacco Comm Acc - Sacco comm. Charges
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := saccoCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := saccoCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SACCO Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;


                //Post
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
                GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                END;


                phone := phonenumber;// Members."Phone No.";// getMemberphonenumber(AccountNumber);
                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'MiniStatement';
                SwizzKashTrans."Document Date" := DT2DATE(transactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//."BOSA Account No";// Members."No.";
                SwizzKashTrans.Charge := 0;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Amount := 0;
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                SwizzKashTrans.Comments := 'POSTED';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";//Members."No.";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Ministatement;
                SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);// TIME;
                SwizzKashTrans.INSERT;

                minimunCount := 1;

                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.ASCENDING(FALSE);
                MemberLedgerEntry.SETFILTER(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", vendorTable."BOSA Account No");
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry.Reversed, false);
                IF MemberLedgerEntry.FINDSET THEN BEGIN

                    response := '';
                    transactionsList := '';

                    REPEAT

                        amount := MemberLedgerEntry.Amount;
                        IF amount < 1 THEN amount := amount * -1;

                        IF transactionsList = '' THEN BEGIN
                            transactionsList := '{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage := FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END ELSE BEGIN
                            transactionsList += ',{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage += FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END;

                        minimunCount := minimunCount + 1;
                    //IF minimunCount>5 THEN EXIT;

                    UNTIL (minimunCount > 5) OR (MemberLedgerEntry.NEXT = 0);

                    IF transactionsList <> '' THEN BEGIN
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [' + transactionsList + '] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"3003","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                        localMessage := 'No transactions';
                    END;

                END ELSE BEGIN
                    response := '{ "StatusCode":"3004","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                    localMessage := 'No transactions';
                END;

                SMSMessage(DocumentNo, AccountNumber, phonenumber, localMessage + '. POLYTECH SACCO');

            END ELSE BEGIN
                response := '{ "StatusCode":"3005","StatusDescription":"ACCOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
            END;

        END;
    END;

    PROCEDURE MINISTATEMENT_LOAN(traceid: code[30]; phonenumber: Text; DocumentNo: Text; AccountNumber: Text; transactionDate: DateTime) response: Text
    VAR
        phone: Text;
        amount: Decimal;
        transactionsList: Text;
        vendorTable: Record 23;
        localMessage: Text;
        chargesTable: Record Charges;
        SwizzKashTrans: Record "SwizzKash Transactions";
        vendorCommAcc: Code[30];
        saccoCommAcc: Code[30];
        vendorCommAmount: Decimal;
        saccoCommAmount: Decimal;
        journalTemplateName: Code[50];
        journalBatchName: Code[50];
    BEGIN

        response := '{ "StatusCode":"3002","StatusDescription":"NOTPROCESSED","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';

        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", DocumentNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"3001","StatusDescription":"REFEXISTS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
        END ELSE BEGIN

            vendorTable.RESET;
            vendorTable.SETRANGE("Mobile Phone No", phonenumber);
            //vendorTable.SETRANGE("No.",AccountNumber);
            IF vendorTable.FIND('-') THEN BEGIN

                // ** enable when live

                // -- get loan balance enquiry charges
                chargesTable.RESET;
                chargesTable.SETRANGE(Code, 'MIS');
                IF chargesTable.FIND('-') THEN BEGIN
                    vendorCommAcc := chargesTable."GL Account";
                    vendorCommAmount := chargesTable."Charge Amount";
                    saccoCommAmount := chargesTable."Sacco Amount";
                    saccoCommAcc := chargesTable."GL Account";// '3000407';     // -- sacco commission account
                END;

                // -- check m-wallet account balance
                vendorTable.CALCFIELDS("Balance (LCY)");
                IF (vendorTable."Balance (LCY)" < (saccoCommAmount + vendorCommAmount)) THEN BEGIN
                    EXIT('{ "StatusCode":"3002","StatusDescription":"INSUFFICIENTFUNDS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }');
                END;

                journalTemplateName := 'GENERAL';
                journalBatchName := 'MINISTTMNT';

                ClearGLJournal(journalTemplateName, journalBatchName);
                PrepareGLJournalBatch(journalTemplateName, journalBatchName, 'MINISTATEMENT ENQUIRY');


                //Dr M-WALLET - (vendor comm. Charges(SwizzKash)) +(sacco comm. charges)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := vendorTable."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorCommAcc;
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount + saccoCommAmount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Vendor Comm Acc - vendor comm. Charges(SwizzKash)
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := vendorCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := vendorCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SwizzKash Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Sacco Comm Acc - Sacco comm. Charges
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := journalTemplateName;
                GenJournalLine."Journal Batch Name" := journalBatchName;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Document No." := DocumentNo;//documentNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := saccoCommAcc;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."External Document No." := vendorTable."No.";
                GenJournalLine."Posting Date" := DT2DATE(transactionDate);//swizzkasTransTable."Document Date";
                GenJournalLine.Amount := saccoCommAmount * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                GenJournalLine.Description := 'Ministatement Enquiry-SACCO Comm.';
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;


                //Post
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", journalTemplateName);
                GenJournalLine.SETRANGE("Journal Batch Name", journalBatchName);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                END;


                phone := phonenumber;// Members."Phone No.";// getMemberphonenumber(AccountNumber);
                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := DocumentNo;
                SwizzKashTrans.Description := 'MiniStatement';
                SwizzKashTrans."Document Date" := DT2DATE(transactionDate);// TODAY;
                SwizzKashTrans."Account No" := vendorTable."No.";//."BOSA Account No";// Members."No.";
                SwizzKashTrans.Charge := 0;
                SwizzKashTrans."Account Name" := vendorTable.Name;// Members.Name;
                SwizzKashTrans."Telephone Number" := phonenumber;
                SwizzKashTrans."Account No2" := '';
                SwizzKashTrans.Amount := 0;
                SwizzKashTrans.Posted := TRUE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                SwizzKashTrans.Comments := 'POSTED';
                SwizzKashTrans.Client := vendorTable."BOSA Account No";//Members."No.";
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Ministatement;
                SwizzKashTrans."Transaction Time" := DT2TIME(transactionDate);// TIME;
                SwizzKashTrans.INSERT;

                minimunCount := 1;

                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Entry No.");
                MemberLedgerEntry.ASCENDING(FALSE);
                MemberLedgerEntry.SETFILTER(MemberLedgerEntry.Description, '<>%1', '*Charges*');
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", vendorTable."BOSA Account No");
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry.Reversed, false);
                IF MemberLedgerEntry.FINDSET THEN BEGIN

                    response := '';
                    transactionsList := '';

                    REPEAT

                        amount := MemberLedgerEntry.Amount;
                        IF amount < 1 THEN amount := amount * -1;

                        IF transactionsList = '' THEN BEGIN
                            transactionsList := '{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage := FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END ELSE BEGIN
                            transactionsList += ',{"PostingDate":"' + FORMAT(MemberLedgerEntry."Posting Date") + '","Description":"' + MemberLedgerEntry.Description + '","Amount":"' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            localMessage += FORMAT(MemberLedgerEntry."Posting Date") + ' ' + MemberLedgerEntry.Description + ' ' + FORMAT(amount, 0, '<Precision,2:2><Integer><Decimals>') + ',';
                        END;

                        minimunCount := minimunCount + 1;
                    //IF minimunCount>5 THEN EXIT;

                    UNTIL (minimunCount > 5) OR (MemberLedgerEntry.NEXT = 0);

                    IF transactionsList <> '' THEN BEGIN
                        response := '{ "StatusCode":"0000","StatusDescription":"OK","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [' + transactionsList + '] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"3003","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                        localMessage := 'No transactions';
                    END;

                END ELSE BEGIN
                    response := '{ "StatusCode":"3004","StatusDescription":"NOTRANSACTIONS","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
                    localMessage := 'No transactions';
                END;

                SMSMessage(DocumentNo, AccountNumber, phonenumber, localMessage + '. POLYTECH SACCO');

            END ELSE BEGIN
                response := '{ "StatusCode":"3005","StatusDescription":"ACCOUNTNOTFOUND","DocumentNo":"' + DocumentNo + '","AccountNo":"' + AccountNumber + '","TransactionLines": [] }';
            END;

        END;
    END;

    procedure GetWSSAccountBalance(phonenumber: Code[100]) response: Text
    var
        Bal: Decimal;
        accountMinBalance: Decimal;
    begin

        response := '{ "StatusCode":"602","StatusDescription":"BALANCENOTFETCHED", "AccountBalance": "0" }';

        Vendor.Reset;
        Vendor.SetRange(Vendor."Mobile Phone No", phonenumber);
        //vendor.SetRange(vendor.Status, vendor.Status::Active);
        if Vendor.Find('-') then begin
            //response:='{ "StatusCode":"602","StatusDescription":"Account is "' + Format(vendor.Status) + '", "AccountBalance": "'+ Format(vendor."Balance (LCY)") +'" }';
            if (Vendor.Status <> Vendor.Status::Active) then begin
                response := '{ "StatusCode":"602","StatusDescription":"Account is "' + Format(Vendor.Status) + '", "AccountBalance": "0" }';
                EXIT(response);
            end;

            if (Vendor.Blocked <> Vendor.Blocked::" ") then begin
                response := '{ "StatusCode":"602","StatusDescription":"Account is blocked with type "' + Format(Vendor.Blocked) + '", "AccountBalance": "0" }';
                EXIT(response);
            end;
            accountMinBalance := 0;
            // AccountTypes.Reset;
            // AccountTypes.SetRange(AccountTypes.Code, Vendor."Account Type");
            // if AccountTypes.Find('-') then begin
            //     accountMinBalance := AccountTypes."Minimum Balance";
            // end;
            // Vendor.CalcFields(Vendor."Balance (LCY)");
            // Vendor.CalcFields(Vendor."ATM Transactions");
            // Vendor.CalcFields(Vendor."Uncleared Cheques");
            // Vendor.CalcFields(Vendor."EFT Transactions");
            // Bal := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + accountMinBalance);
            //
            Bal := SFactory.FnGetFosaAccountBalance(Vendor."No.");

            //
            if Bal < 0 then
                //the precision does not respect the negative value when formating
                response := '{ "StatusCode":"000","StatusDescription":"OK", "AccountBalance": "-' + Format(ABS(Bal), 0, '<Precision,2:2><Integer><Decimals>') + '" }'
            else
                response := '{ "StatusCode":"000","StatusDescription":"OK", "AccountBalance": "' + Format(Bal, 0, '<Precision,2:2><Integer><Decimals>') + '" }';

            //response := '{ "StatusCode":"000","StatusDescription":"OK", "AccountBalance": "' + Format(Bal, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
        end;
        EXIT(response);
    end;

    procedure AccountBalanceDec(phonenumber: Code[30]; amt: Decimal) Bal: Decimal
    var
    BEGIN
        Vendor.Reset;
        Vendor.SetRange(Vendor."Mobile Phone No", phonenumber);
        IF Vendor.FIND('-') THEN BEGIN
            AccountTypes.RESET;
            AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
            //AccountTypes.SETRANGE(AccountTypes."Last Account No Used(HQ)",FALSE);
            IF AccountTypes.FIND('-') THEN BEGIN
                miniBalance := AccountTypes."Minimum Balance";
            END;
            Vendor.CALCFIELDS(Vendor."Balance (LCY)");
            Vendor.CALCFIELDS(Vendor."ATM Transactions");
            Vendor.CALCFIELDS(Vendor."Uncleared Cheques");
            Vendor.CALCFIELDS(Vendor."EFT Transactions");
            Bal := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            //GenLedgerSetup.TESTFIELD(GenLedgerSetup."MPESA Reconciliation acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");

                MPESACharge := GetCharge(amt, 'MPESA');
                SwizzKashCharge := GetCharge(amt, 'VENDWD');
                MobileCharges := GetCharge(amt, 'SACCOWD');

                ExcDuty := (20 / 100) * (MobileCharges + SwizzKashCharge);
                TotalCharges := SwizzKashCharge + MobileCharges + ExcDuty + MPESACharge;
            END;
            Bal := Bal - TotalCharges;
        END
    END;

    procedure GetMobileCharge(chargecode: Text[20]; transactionamount: Decimal) response: Text
    var
        charge: Decimal;
    begin
        response := '{ "StatusCode":"02","StatusDescription":"NOTPROCESSED","ChargeAmount": "0" }';
        charge := 0;
        TariffDetails.Reset;
        TariffDetails.SetRange(TariffDetails.Code, chargecode);
        TariffDetails.SetFilter(TariffDetails."Lower Limit", '<=%1', transactionamount);
        TariffDetails.SetFilter(TariffDetails."Upper Limit", '>=%1', transactionamount);
        if TariffDetails.Find('-') then begin
            charge := TariffDetails."Charge Amount";
            response := '{ "StatusCode":"000","StatusDescription":"OK","ChargeAmount": "' + Format(charge, 0, '<Precision,2:2><Integer><Decimals>') + '" }';
        end else begin
            response := '{ "StatusCode":"03","StatusDescription":"CHARGECODENOTFOUND","ChargeAmount": "0" }';
        end;
        exit(response);
    end;

    PROCEDURE GetMemberNumber(phonenumber: text[100]) response: Text
    VAR
        vendorTable: Record Vendor;
        memberTable: Record Customer;
        fullName: Code[20];
        int1: Integer;
    BEGIN

        response := '{ "StatusCode":"302","StatusDescription":"NOTPROCESSED","MemberNo":"","MemberName":"" }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        IF vendorTable.FIND('-') THEN BEGIN
            memberTable.RESET;
            memberTable.SETRANGE(memberTable."No.", vendorTable."BOSA Account No");
            IF memberTable.FIND('-') THEN BEGIN
                response := '{ "StatusCode":"000","StatusDescription":"OK", "MemberNo":"' + memberTable."No." + '", "MemberName":"' + memberTable.Name + '" }';
            END ELSE BEGIN
                response := '{ "StatusCode":"301","StatusDescription":"MEMBERNOTFOUND","MemberNo":"","MemberName":"" }';
            END;
        END ELSE BEGIN
            response := '{ "StatusCode":"303","StatusDescription":"NUMBERNOTFOUND","MemberNo":"","MemberName":"" }';
        END;
    END;

    PROCEDURE GetMemberAccounts(phonenumber: text[100]) response: Text
    VAR
        accountsList: Text;
        vendorTable: Record Vendor;
        memberTable: Record Customer;
        bosaAccounts: Text;
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"NOTPROCESSED","accountsList": [] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group",'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN
            accountsList := '';
            REPEAT
                IF accountsList = '' THEN BEGIN
                    accountsList := '{ "accountNo":"' + vendorTable."No." +
                                   '", "accountName":"' + vendorTable."Account Type" +
                                   '","balance":' + FORMAT(vendorTable."Balance (LCY)", 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                END ELSE BEGIN
                    accountsList += ',{ "accountNo":"' + vendorTable."No." +
                                  '", "accountName":"' + vendorTable."Account Type" +
                                  '","balance":' + FORMAT(vendorTable."Balance (LCY)", 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                END;

            UNTIL vendorTable.NEXT = 0;

            memberTable.RESET;
            memberTable.SETRANGE(memberTable."No.", vendorTable."BOSA Account No");
            memberTable.SETAUTOCALCFIELDS(memberTable."Current Shares", memberTable."Shares Retained");
            IF memberTable.FIND('-') THEN BEGIN

                //memberTable.CALCFIELDS(memberTable."Current Shares");
                //memberTable.CALCFIELDS(memberTable."Shares Retained");
                IF bosaAccounts = '' THEN BEGIN
                    bosaAccounts += ',{ "accountNo":"' + memberTable."No." +
                                  '", "accountName":"Deposit Contribution"' +
                                  '","balance":' + FORMAT(memberTable."Current Shares", 0, '<Precision,2:2><Integer><Decimals>') + ' }';

                    bosaAccounts += ',{ "accountNo":"' + memberTable."No." +
                                  '", "accountName":"Share Capital"' +
                                  '","balance":' + FORMAT(memberTable."Shares Retained", 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                END;

                IF accountsList <> '' THEN BEGIN
                    response := '{ "StatusCode":"000","StatusDescription":"OK","accountsList":[ ' + accountsList + bosaAccounts + ' ] }';
                END ELSE BEGIN
                    response := '{ "StatusCode":"1","StatusDescription":"NOTRANSACTIONS","accountsList":[] }';
                END;
            END ELSE BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"MEMBERNOTFOUND","accountsList":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","accountsList":[] }';
        END;
    END;

    PROCEDURE EnquireLoanGuarantors(traceid: code[30]; documentno: code[30]; phonenumber: text[100]; transactiondate: datetime) response: Text
    VAR
        guarantorsList: Text;
        vendorTable: Record Vendor;
        memberTable: Record Customer;
        LoansTable: Record "Loans Register";
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"ERROR","guarantorsList": [] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group",'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN
            memberTable.RESET;
            memberTable.SETRANGE(memberTable."No.", vendorTable."BOSA Account No");
            IF memberTable.FIND('-') THEN BEGIN
                LoansTable.RESET;
                LoansTable.SETRANGE(LoansTable."Client Code", memberTable."No.");
                LoansTable.SETFILTER(LoansTable."Outstanding Balance", '>%1', 0);
                IF LoansTable.FIND('-') THEN BEGIN
                    LoanGuaranteeDetails.RESET;
                    LoanGuaranteeDetails.SETRANGE(LoanGuaranteeDetails."Loan No", LoansTable."Loan  No.");
                    IF LoanGuaranteeDetails.FIND('-') THEN BEGIN
                        LoanGuaranteeDetails.CALCFIELDS(LoanGuaranteeDetails."Outstanding Balance");
                        IF LoanGuaranteeDetails."Outstanding Balance" > 0 THEN
                            guarantorsList := '';
                        REPEAT
                            IF guarantorsList = '' THEN BEGIN
                                guarantorsList += '{ "name": "' + LoanGuaranteeDetails.Name +
                                                  '", "amount": "' + FORMAT(LoanGuaranteeDetails."Amont Guaranteed", 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            END ELSE BEGIN
                                guarantorsList += ',{ "name": "' + LoanGuaranteeDetails.Name +
                                                  '", "amount": "' + FORMAT(LoanGuaranteeDetails."Amont Guaranteed", 0, '<Precision,2:2><Integer><Decimals>') + '" }';
                            END;
                        UNTIL LoanGuaranteeDetails.NEXT = 0;

                        IF guarantorsList <> '' THEN BEGIN
                            response := '{ "StatusCode":"000","StatusDescription":"OK","guarantorsList":[ ' + guarantorsList + ' ] }';
                        END ELSE BEGIN
                            response := '{ "StatusCode":"1","StatusDescription":"NOLOANSGUARANTEED","guarantorsList":[] }';
                        END;
                    END ELSE BEGIN
                        response := '{ "StatusCode":"1","StatusDescription":"NOGUARANTORSFOUND","guarantorsList":[] }';
                    END;
                END ELSE BEGIN
                    response := '{ "StatusCode":"1","StatusDescription":"NOLOANSFOUND","guarantorsList":[] }';
                END;
            END ELSE BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"MEMBERNOTFOUND","guarantorsList":[] }';
            END;
        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","guarantorsList":[] }';
        END;
    END;

    PROCEDURE EnquireLoansGuaranteed(traceid: code[30]; documentno: code[30]; phonenumber: text[100]; transactindate: datetime) response: Text
    VAR
        guaranteedList: Text;
        vendorTable: Record Vendor;
        memberTable: Record Customer;
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"NOTPROCESSED","guaranteedList": [] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group",'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN
            memberTable.RESET;
            memberTable.SETRANGE(memberTable."No.", vendorTable."BOSA Account No");
            IF memberTable.FIND('-') THEN BEGIN
                LoanGuaranteeDetails.RESET;
                LoanGuaranteeDetails.SETRANGE(LoanGuaranteeDetails."Member No", Members."No.");
                LoanGuaranteeDetails.SETFILTER(LoanGuaranteeDetails."Loans Outstanding", '>%1', 0);
                IF LoanGuaranteeDetails.FIND('-') THEN BEGIN

                    guaranteedList := '';

                    REPEAT
                        IF guaranteedList = '' THEN BEGIN
                            guaranteedList += '{ "loanId":' + LoanGuaranteeDetails."Loan No" +
                                            '","guaranteedAmount":' + FORMAT(LoanGuaranteeDetails."Amont Guaranteed", 0, '<Precision,2:2><Integer><Decimals>') + '}';
                        END ELSE BEGIN
                            guaranteedList += ',{ "loanId":' + LoanGuaranteeDetails."Loan No" +
                                            '","guaranteedAmount":' + FORMAT(LoanGuaranteeDetails."Amont Guaranteed", 0, '<Precision,2:2><Integer><Decimals>') + '}';
                        END;
                    UNTIL LoanGuaranteeDetails.NEXT = 0;

                    IF guaranteedList <> '' THEN BEGIN
                        response := '{ "StatusCode":"000","StatusDescription":"OK","guaranteedList":[ ' + guaranteedList + ' ] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"1","StatusDescription":"NOLOANSGUARANTEED","guaranteedList":[] }';
                    END;

                END ELSE BEGIN
                    response := '{ "StatusCode":"1","StatusDescription":"NOLOANSGUARANTEED","guaranteedList":[] }';
                END;
            END ELSE BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"MEMBERNOTFOUND","guaranteedList":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","guaranteedList":[] }';
        END;
    END;

    PROCEDURE GetOutstandingLoans(phonenumber: text[100]) response: Text
    VAR
        outstandingloansList: Text;
        vendorTable: Record Vendor;
        loanProductsTable: Record "Loan Products Setup";
        loansTable: Record "Loans Register";
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"ERROR","LoanBalances": [] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group", 'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN
            LoansTable.RESET;
            LoansTable.SETRANGE(LoansTable."Client Code", vendorTable."BOSA Account No");
            IF LoansTable.FIND('-') THEN BEGIN
                outstandingloansList := '';
                REPEAT
                    LoansTable.CALCFIELDS(LoansTable."Outstanding Balance", LoansTable."Interest Due", LoansTable."Interest to be paid", LoansTable."Interest Paid");
                    IF (LoansTable."Outstanding Balance" > 0) THEN BEGIN
                        loanProductsTable.RESET;
                        loanProductsTable.GET(LoansTable."Loan Product Type");
                        IF outstandingloansList = '' THEN BEGIN
                            outstandingloansList := '{ "LoanNo":"' + LoansTable."Loan  No." + '", "LoanName":"' + loanProductsTable."Product Description" + '","BalanceAmount":' + FORMAT(LoansTable."Outstanding Balance", 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                        END ELSE BEGIN
                            outstandingloansList += ',{ "LoanNo":"' + LoansTable."Loan  No." + '", "LoanName":"' + loanProductsTable."Product Description" + '","BalanceAmount":' + FORMAT(LoansTable."Outstanding Balance", 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                        END;
                    END;
                UNTIL LoansTable.NEXT = 0;

                IF outstandingloansList <> '' THEN BEGIN
                    response := '{ "StatusCode":"000","StatusDescription":"OK","LoanBalances":[ ' + outstandingloansList + ' ] }';
                END ELSE BEGIN
                    response := '{ "StatusCode":"1","StatusDescription":"NOOUTSTANDINGLOANS","LoanBalances":[] }';
                END;

            END ELSE BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"NOOUTSTANDINGLOANS","LoanBalances":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","LoanBalances":[] }';
        END;
    END;

    PROCEDURE GetLoanAmountLimit(phonenumber: text[100]; loancode: Text[50]) response: Text
    VAR
        StoDedAmount: Decimal;
        VendorTable: Record "Vendor";
        CustomerTable: Record "Customer";
        StandingOrderTable: Record "Standing Order Register";
        LoanGuaranteeTable: Record "Loans Guarantee Details";
        LoanRepaymentS: Record "Loan Repayment Schedule";
        Cust_LedgerEntryTable: Record "Cust. Ledger Entry";
        Cust_LedgerEntry_2_Table: Record "Cust. Ledger Entry";
        LoansRegisterTable: Record "Loans Register";
        LoanProductsSetupTable: Record "Loan Products Setup";
        limitAmount: Decimal;
        maxLoanAmount: Decimal;
        minLoanAmount: Decimal;
        FOSALoanRepayAmount: Decimal;
        CumulativeNet: Decimal;
        LastSalaryDate: Date;
        FirstSalaryDate: Date;
        AvarageNetPay: Decimal;
        AdvQualificationAmount: Decimal;
        CumulativeNet2: Decimal;
        finalAmount: Decimal;
        interestAMT: Decimal;
        MaxLoanAmt: Decimal;
        LastPaydate: Date;
        MPayDate: Decimal;
        MToday: Decimal;
        DateRegistered: Date;
        MtodayYear: Decimal;
        RegYear: Decimal;
        MtodayDiff: Decimal;
        MRegdate: Decimal;
        ComittedShares: Decimal;
        FreeShares: Decimal;
        TotalAmount: Decimal;
        TransactionLoanAmt: Decimal;
        TransactionLoanDiff: Decimal;
        RepayedLoanAmt: Decimal;
        Fulldate: Date;
        LastRepayDate: Date;
        PrincipalAmount: Decimal;
        Totalshares: Decimal;
        loanBal: Decimal;
        defaulterStatus: Code[20];
        countTrans: Integer;
        employeeCode: Code[20];
        penaltyDate: Date;
    BEGIN

        response := '{ "StatusCode":"502","StatusDescription":"NOTPROCESSED","LimitAmount":0,"Message":"Not processed" } ';

        VendorTable.RESET;
        VendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        IF VendorTable.FIND('-') THEN BEGIN

            //=================================================must be member for 6 months
            CustomerTable.RESET;
            CustomerTable.SETRANGE(CustomerTable."No.", VendorTable."BOSA Account No");
            CustomerTable.SETRANGE(CustomerTable.Status, CustomerTable.Status::Active);
            IF CustomerTable.FIND('-') THEN BEGIN
                DateRegistered := CustomerTable."Registration Date";
            END;

            IF DateRegistered <> 0D THEN BEGIN
                MtodayYear := DATE2DMY(TODAY, 3);
                RegYear := DATE2DMY(DateRegistered, 3);
                MRegdate := DATE2DMY(DateRegistered, 2);

                IF (CALCDATE('6M', DateRegistered) > TODAY) THEN begin
                    amount := 1;
                    response := '{ "StatusCode":"503","StatusDescription":"MUSTBEAMEMBERFORATLEAST6MONTHS","LimitAmount":0,"Message":"Must be a member for atleast 6 months" } ';
                    exit(response);
                end;

            END ELSE BEGIN
                response := '{ "StatusCode":"503","StatusDescription":"MUSTBEAMEMBERFORATLEAST6MONTHS","LimitAmount":0,"Message":"Must be a member for atleast 6 months" } ';
                exit(response);
            END;



            // =================================== Check if member has an outstanding ELOAN
            LoansRegisterTable.RESET;
            LoansRegisterTable.SETRANGE(LoansRegisterTable."Client Code", CustomerTable."No.");
            LoansRegisterTable.SETRANGE(LoansRegisterTable.Posted, TRUE);
            LoansRegisterTable.SetFilter(LoansRegisterTable."Loan Product Type", '%1|%2', '25', '552');
            IF LoansRegisterTable.FIND('-') THEN BEGIN
                REPEAT
                    LoansRegisterTable.CALCFIELDS(LoansRegisterTable."Outstanding Balance");
                    IF (LoansRegisterTable."Outstanding Balance" > 0) THEN BEGIN

                        response := '{ "StatusCode":"504","StatusDescription":"OUTSTANDINGMOBILELOAN","LimitAmount":0,"Message":"Outstanding mobile loan" } ';
                        exit(response);

                        // IF (LoansRegisterTable."Loan Product Type" = '552')
                        //     OR (LoansRegisterTable."Loan Product Type" = '551')
                        // THEN amount := 2;
                    END;

                UNTIL LoansRegisterTable.NEXT = 0;
            END;

            //******Get Standing Order Amounts
            StoDedAmount := 0;

            StandingOrderTable.RESET;
            StandingOrderTable.SETRANGE(StandingOrderTable."Source Account No.", VendorTable."No.");
            //StandingOrderTable.SETRANGE(StandingOrderTable."Attempt Status", StandingOrderTable."Attempt Status"::"2nd Attempt");
            //StandingOrderTable.SETRANGE(Status, StandingOrderTable.Status::Approved);
            IF StandingOrderTable.FIND('-') THEN BEGIN
                REPEAT
                    StoDedAmount := StoDedAmount + StandingOrderTable.Amount;
                UNTIL StandingOrderTable.NEXT = 0;
            END;

            // ============================================Get Loan Defaulter status
            defaulterStatus := '';
            CustomerTable.RESET;
            CustomerTable.SETRANGE(CustomerTable."No.", VendorTable."BOSA Account No");
            CustomerTable.SETRANGE(CustomerTable."Loans Defaulter Status", CustomerTable."Loans Defaulter Status"::Perfoming);
            IF CustomerTable.FIND('-') THEN BEGIN

                LoansRegisterTable.RESET;
                LoansRegisterTable.SETRANGE(LoansRegisterTable."Client Code", VendorTable."BOSA Account No");
                LoansRegisterTable.SetFilter(LoansRegisterTable."Loans Category-SASRA", '%1|%2|%3|%4', LoansRegisterTable."Loans Category-SASRA"::Substandard, LoansRegisterTable."Loans Category-SASRA"::Watch, LoansRegisterTable."Loans Category-SASRA"::Doubtful, LoansRegisterTable."Loans Category-SASRA"::Loss);

                IF LoansRegisterTable.FIND('-') THEN BEGIN
                    REPEAT
                        LoansRegisterTable.CALCFIELDS(LoansRegisterTable."Outstanding Balance");
                        IF LoansRegisterTable."Outstanding Balance" > 0 THEN BEGIN

                            response := '{ "StatusCode":"505","StatusDescription":"OUTSTANDINGNONPERFORMINGLOAN","LimitAmount":0,"Message":"Outstanding non-performing loan" } ';
                            exit(response);

                            // IF (LoansRegisterTable."Loans Category-SASRA" = LoansRegisterTable."Loans Category-SASRA"::Substandard)
                            //    OR (LoansRegisterTable."Loans Category-SASRA" = LoansRegisterTable."Loans Category-SASRA"::Loss)
                            //    OR (LoansRegisterTable."Loans Category-SASRA" = LoansRegisterTable."Loans Category-SASRA"::Doubtful)
                            //    OR (LoansRegisterTable."Loans Category-SASRA" = LoansRegisterTable."Loans Category-SASRA"::Watch)
                            // THEN begin
                            //     amount := 3;
                            //     response := '{ "StatusCode":"505","StatusDescription":"OUTSTANDINGNONPERFORMINGLOAN","LimitAmount":0,"Message":"Outstanding non-performing loan" } ';
                            //     exit(response);
                            // end;
                        END;
                    UNTIL LoansRegisterTable.NEXT = 0;
                END;
            END;

            CustomerTable.RESET;
            CustomerTable.SETRANGE(CustomerTable."No.", VendorTable."BOSA Account No");
            IF CustomerTable.FIND('-') THEN BEGIN
                employeeCode := CustomerTable."Employer Code";
            END;

            IF employeeCode = '002' THEN BEGIN
                countTrans := 1;
                Cust_LedgerEntryTable.RESET;
                Cust_LedgerEntryTable.SETRANGE(Cust_LedgerEntryTable."Customer No.", VendorTable."BOSA Account No");
                Cust_LedgerEntryTable.SETRANGE(Cust_LedgerEntryTable."Transaction Type", Cust_LedgerEntryTable."Transaction Type"::"Interest Due");
                IF Cust_LedgerEntryTable.FIND('-') THEN BEGIN
                    countTrans := Cust_LedgerEntryTable.Count;
                    // REPEAT
                    //     countTrans := countTrans + 1;
                    // UNTIL Cust_LedgerEntryTable.NEXT = 0;
                END;

                if countTrans <= 6 then begin
                    response := '{ "StatusCode":"506","StatusDescription":"INCONSISTENTMONTHLYCONTRIBUTION","LimitAmount":0,"Message":"Inconsistent monthly contributions" } ';
                    exit(response);
                end;

                // IF countTrans <> 0 THEN BEGIN
                //     IF countTrans <= 6 THEN amount := 6;
                // END ELSE BEGIN
                //     amount := 6;
                // END;

            END ELSE BEGIN

                countTrans := 0;
                Cust_LedgerEntryTable.RESET;
                Cust_LedgerEntryTable.SETRANGE(Cust_LedgerEntryTable."Customer No.", VendorTable."BOSA Account No");
                Cust_LedgerEntryTable.SETRANGE(Cust_LedgerEntryTable."Transaction Type", Cust_LedgerEntryTable."Transaction Type"::"Interest Due");
                Cust_LedgerEntryTable.SETFILTER(Cust_LedgerEntryTable."Posting Date", FORMAT(CALCDATE('CM+1D-6M', TODAY)) + '..' + FORMAT(CALCDATE('CM', TODAY)));
                Cust_LedgerEntryTable.SETFILTER(Cust_LedgerEntryTable.Description, '<>%1', 'Opening Balance');
                Cust_LedgerEntryTable.SETCURRENTKEY(Cust_LedgerEntryTable."Posting Date");
                Cust_LedgerEntryTable.ASCENDING(FALSE);
                Cust_LedgerEntryTable.SETFILTER(Cust_LedgerEntryTable."Credit Amount", '>%1', 0);
                IF Cust_LedgerEntryTable.FIND('-') THEN BEGIN
                    REPEAT
                        Cust_LedgerEntry_2_Table.RESET;
                        Cust_LedgerEntry_2_Table.SETRANGE(Cust_LedgerEntry_2_Table."Customer No.", Cust_LedgerEntryTable."Customer No.");
                        Cust_LedgerEntry_2_Table.SETRANGE(Cust_LedgerEntry_2_Table."Transaction Type", Cust_LedgerEntryTable."Transaction Type"::"Interest Due");
                        Cust_LedgerEntry_2_Table.SETRANGE(Cust_LedgerEntry_2_Table."Posting Date", Cust_LedgerEntryTable."Posting Date");
                        Cust_LedgerEntry_2_Table.SETFILTER(Cust_LedgerEntry_2_Table.Description, '<>%1', 'Opening Balance');
                        Cust_LedgerEntry_2_Table.SETFILTER(Cust_LedgerEntry_2_Table."Credit Amount", '>%1', 0);
                        IF Cust_LedgerEntry_2_Table.FINDLAST THEN BEGIN
                            countTrans := countTrans + 1;
                        END;
                    UNTIL Cust_LedgerEntryTable.NEXT = 0;
                END;

                if countTrans <= 6 then begin
                    response := '{ "StatusCode":"506","StatusDescription":"INCONSISTENTMONTHLYCONTRIBUTION","LimitAmount":0,"Message":"Inconsistent monthly contributions" } ';
                    exit(response);
                end;

                // IF countTrans <> 0 THEN BEGIN
                //     IF countTrans < 6 THEN amount := 6;
                // END ELSE BEGIN
                //     amount := 6;
                // END;
            END;

            // ******************************* calculate the loan limit

            // =========================================================Get Free Shares
            ComittedShares := 0;
            loanBal := 0;

            CustomerTable.CALCFIELDS(CustomerTable."Current Shares");
            CustomerTable.CALCFIELDS(CustomerTable."Outstanding Balance");
            CustomerTable.CALCFIELDS(CustomerTable."Outstanding Interest");
            loanBal := CustomerTable."Outstanding Balance" + CustomerTable."Outstanding Interest";

            Totalshares := CustomerTable."Current Shares";
            FreeShares := Totalshares - (loanBal / 3);
            limitAmount := ROUND(0.75 * FreeShares, 0.05, '>');

            //==================================================Get maximum loan amount

            IF loancode = '' then loancode := '552';

            LoanProductsSetupTable.RESET;
            LoanProductsSetupTable.SETRANGE(LoanProductsSetupTable.Code, loancode);// '552');
            IF LoanProductsSetupTable.FIND('-') THEN BEGIN
                interestAMT := LoanProductsSetupTable."Interest rate";
                maxLoanAmount := LoanProductsSetupTable."Max. Loan Amount";
                minLoanAmount := LoanProductsSetupTable."Min. Loan Amount";
            END;

            IF limitAmount < minLoanAmount THEN begin
                response := '{ "StatusCode":"507","StatusDescription":"INSUFFICIENTQUALIFYINGAMOUNT","LimitAmount":0,"Message":"Insufficient qualifying amount" } ';
                exit(response);
            end;

            IF limitAmount > maxLoanAmount THEN limitAmount := maxLoanAmount;

            response := '{ "StatusCode":"000","StatusDescription":"OK","LimitAmount":"' + Format(limitAmount, 0, '<Precision,2:2><Integer><Decimals>') + '","Message":"Qualifying amount is KES ' + Format(limitAmount) + '" } ';
            exit(response);
            // ******************************* calculate the loan limit

        END;//vendor
    END;

    PROCEDURE ApplyLoan(traceid: Code[70]; documentno: Code[20]; phonenumber: Code[100]; accountno: Code[50]; loancode: Code[20]; amountapplied: Decimal; repaymentperiod: Decimal; transactiondate: DateTime; narration: Text) response: Text;
    VAR
        LoanProdChargesTable: Record "Loan Product Charges";
        Sacco_No_SeriesTable: Record "Sacco No. Series";
        LoanRepaymentScheduleTable: Record "Loan Repayment Schedule";
        SwizzKashTransactionsTable: Record "SwizzKash Transactions";
        LoanPurposeTable: Record "Loans Purpose";
        VendorTable: Record Vendor;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LoanAcc: Code[30];
        InterestAcc: Code[30];
        InterestAmount: Decimal;
        AmountToCredit: Decimal;
        loanNo: Text[20];
        // advSMS: Decimal;
        // advFee: Decimal;
        // advApp: Decimal;
        // advSMSAcc: Code[20];
        // advFEEAcc: Code[20];
        // advAppAcc: Code[20];
        // advSMSDesc: Text[100];
        // advFeeDesc: Text[100];
        // advAppDesc: Text[100];
        loanType: Code[50];
        InsuranceAcc: Code[10];
        AmountDispursed: Decimal;
        intNumber: Integer;
    BEGIN

        /*this function should appraise the loan, post it, record it in the transactions table and return the loan details and statusp*/

        response := '{ "StatusCode":"502","StatusDescription":"ERROR", "DocumentNo":"' + DocumentNo + '" }';

        SwizzKashTransactionsTable.RESET;
        SwizzKashTransactionsTable.SETRANGE(SwizzKashTransactionsTable."Document No", DocumentNo);
        IF SwizzKashTransactionsTable.FIND('-') THEN BEGIN
            response := '{ "StatusCode":"501","StatusDescription":"REFEXISTS", "DocumentNo":"' + DocumentNo + '" }';
        END ELSE BEGIN
            // -- check if there is a pending e-loan application from the member
            SwizzKashTransactionsTable.RESET;
            SwizzKashTransactionsTable.SETRANGE(SwizzKashTransactionsTable."Telephone Number", phonenumber);
            //SwizzKashTransactionsTable.SETRANGE(Posted,FALSE);
            SwizzKashTransactionsTable.SETRANGE(Status, SwizzKashTransactionsTable.Status::Pending);
            SwizzKashTransactionsTable.SETRANGE("Transaction Type", SwizzKashTransactionsTable."Transaction Type"::"Loan Application");
            IF SwizzKashTransactionsTable.FIND('-') THEN BEGIN
                response := '{ "StatusCode":"503","StatusDescription":"PENDINGAPPLICATION", "DocumentNo":"' + SwizzKashTransactionsTable."Document No" + '" }';
            END ELSE BEGIN

                VendorTable.RESET;
                VendorTable.SETRANGE("Mobile Phone No", phonenumber);
                //VendorTable.SETRANGE(VendorTable."Vendor Posting Group", 'M_WALLET');
                IF VendorTable.FIND('-') THEN BEGIN
                    Evaluate(intNumber, traceid);

                    SwizzKashTransactionsTable.INIT;
                    //SwizzKashTransactionsTable.Entry := intNumber;
                    SwizzKashTransactionsTable."Document No" := DocumentNo;
                    SwizzKashTransactionsTable.Description := 'E-Loan Application';
                    SwizzKashTransactionsTable."Document Date" := DT2DATE(TransactionDate);// TODAY;
                    SwizzKashTransactionsTable."Transaction Time" := DT2TIME(TransactionDate);// TIME;
                    SwizzKashTransactionsTable."Telephone Number" := phonenumber;
                    SwizzKashTransactionsTable."Account No" := AccountNo;//Members."No.";
                    SwizzKashTransactionsTable."Account Name" := VendorTable.Name;
                    SwizzKashTransactionsTable."Account No2" := '';
                    SwizzKashTransactionsTable."Loan No" := loanNo;
                    SwizzKashTransactionsTable.Amount := amountapplied;
                    SwizzKashTransactionsTable.Status := SwizzKashTransactionsTable.Status::Pending;
                    SwizzKashTransactionsTable.Posted := FALSE;
                    SwizzKashTransactionsTable.Comments := 'PENDING';
                    SwizzKashTransactionsTable.Client := Members."No.";
                    SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."Transaction Type"::"Loan Application";
                    SwizzKashTransactionsTable.INSERT;

                    response := '{ "StatusCode":"000","StatusDescription":"OK", "DocumentNo":"' + DocumentNo + '" }';
                END ELSE BEGIN
                    response := '{ "StatusCode":"502","StatusDescription":"Account Not Found", "DocumentNo":"' + DocumentNo + '" }';
                END;

            END;
        END;

        EXIT(response);
    END;

    PROCEDURE RepayLoan(traceid: code[30]; phonenumber: text[100]; loanno: Text[20]; documentno: Text[30]; repaymentamount: Decimal; transactiondate: DateTime) response: Text
    var
        sourceaccount: code[30];
    begin

        SurePESATrans.Reset;
        SurePESATrans.SetRange(SurePESATrans."Document No", documentno);
        if SurePESATrans.Find('-') then begin
            response := 'REFEXISTS';
        end else begin

            Vendor.Reset;
            Vendor.SetRange(vendor."Mobile Phone No", phonenumber);
            if not Vendor.Find('-') then begin
                msg := 'Your request has failed.Please make sure you are registered for mobile banking.' +
                   '. Thank you for using POLYTECH Sacco Mobile.';
                //SMSMessage(documentno, phonenumber,phonenumber, msg);
                response := '{ "StatusCode": "302", "StatusDescription":"SOURCENOTFOUND" }';
                exit(response);
            END ELSE begin
                sourceaccount := Vendor."No.";
            end;

            LoanAmt := repaymentamount;

            Members.Reset;
            Members.SetRange(Members."FOSA Account No.", sourceaccount);
            if not Members.Find('-') then begin

                response := 'MEMBERINEXISTENT';
                msg := 'Your request has failed because the recipent account does not exist.' +
                '. Thank you for using POLYTECH Sacco Mobile.';
                SMSMessage(documentno, sourceaccount, Vendor."Phone No.", msg);
                response := '{ "StatusCode": "303", "StatusDescription":"MEMBERNOTFOUND" }';
                exit(response);

            end else begin

                GenLedgerSetup.Reset;
                GenLedgerSetup.Get;
                GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

                Charges.Reset;
                Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");
                    MobileCharges := Charges."Charge Amount";
                    //MobileCharges:=GetmobileCharges('LOANREP');
                    MobileChargesACC := Charges."GL Account";
                end;

                SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SurePESACharge := GenLedgerSetup."SwizzKash Charge";

                ExcDuty := (15 / 100) * (MobileCharges + SurePESACharge);

                // Vendor.Reset;
                // Vendor.SetRange(Vendor."No.", accFrom);
                // if Vendor.Find('-') then begin

                Vendor.CalcFields(Vendor."Balance (LCY)");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");

                LoansRegister.Reset;
                LoansRegister.SetRange(LoansRegister."Loan  No.", loanNo);
                LoansRegister.SetRange(LoansRegister."Client Code", Members."No.");
                if LoansRegister.Find('+') then begin
                    LoansRegister.CalcFields(LoansRegister."Outstanding Balance", LoansRegister."Outstanding Balance");
                    //changed from Outstanding interest by kerioh on 29th may2018 on client request
                    if (TempBalance > amount + MobileCharges + SurePESACharge) then begin
                        if LoansRegister."Outstanding Balance" > 50 then begin
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DeleteAll;
                            //end of deletion

                            GenBatches.Reset;
                            GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                            GenBatches.SetRange(GenBatches.Name, 'MOBILETRAN');

                            if GenBatches.Find('-') = false then begin
                                GenBatches.Init;
                                GenBatches."Journal Template Name" := 'GENERAL';
                                GenBatches.Name := 'MOBILETRAN';
                                GenBatches.Description := 'Mobile Loan Repayment';
                                GenBatches.Validate(GenBatches."Journal Template Name");
                                GenBatches.Validate(GenBatches.Name);
                                GenBatches.Insert;
                            end;

                            //DR ACC 1
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Account No." := sourceaccount;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := sourceaccount;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Mobile Loan Repayment';
                            GenJournalLine.Amount := amount;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //Dr Transfer Charges
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine."Account No." := sourceaccount;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := sourceaccount;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Mobile Charges';
                            GenJournalLine.Amount := MobileCharges + SurePESACharge;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;


                            //DR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Account No." := sourceaccount;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := sourceaccount;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                            GenJournalLine.Description := 'Excise duty-Mobile Charges';
                            GenJournalLine.Amount := ExcDuty;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := ExxcDuty;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Excise duty-Mobile Charges';
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //CR Mobile Transactions Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := MobileChargesACC;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Mobile Charges';
                            GenJournalLine.Amount := MobileCharges * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //CR Commission
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentno;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Mobile Charges';
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            if LoansRegister."Oustanding Interest" > 0 then begin
                                LineNo := LineNo + 10000;

                                GenJournalLine.Init;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := documentno;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := Today;
                                GenJournalLine.Description := 'Loan Payment';
                            end;

                            if repaymentamount > LoansRegister."Oustanding Interest" then
                                GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                            else
                                GenJournalLine.Amount := -repaymentamount;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Paid";

                            if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                                GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                            end;
                            GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            repaymentamount := repaymentamount + GenJournalLine.Amount;

                            if repaymentamount > 0 then begin
                                LineNo := LineNo + 10000;

                                GenJournalLine.Init;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := documentno;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := Today;
                                GenJournalLine.Description := 'Loan repayment';
                                GenJournalLine.Amount := -repaymentamount;
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
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            if GenJournalLine.Find('-') then begin
                                repeat
                                //GLPosting.Run(GenJournalLine);
                                until GenJournalLine.Next = 0;
                            end;
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DeleteAll;

                            SurePESATrans.Init;
                            SurePESATrans."Document No" := documentno;
                            SurePESATrans.Description := 'Mobile repayment';
                            SurePESATrans."Document Date" := Today;
                            SurePESATrans."Account No" := sourceaccount;
                            SurePESATrans."Account No2" := loanNo;
                            SurePESATrans.Amount := LoanAmt;
                            SurePESATrans.Posted := true;
                            SurePESATrans."Posting Date" := Today;
                            SurePESATrans.Comments := 'Success';
                            SurePESATrans.Client := Vendor."BOSA Account No";
                            SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::"Transfer to Fosa";
                            SurePESATrans."Transaction Time" := Time;
                            SurePESATrans.Insert;

                            //response := 'TRUE';
                            response := '{ "StatusCode": "200", "StatusDescription":"OK" }';
                            msg := 'You have transfered KES ' + Format(LoanAmt) + ' from Account ' + Vendor.Name + ' to ' + loanNo +
                             '. Thank you for using POLYTECH Sacco Mobile.';
                            SMSMessage(documentno, sourceaccount, Vendor."Phone No.", msg);

                        end;
                    end else begin
                        response := '{ "StatusCode": "304", "StatusDescription":"INSUFFICIENTBALANCE" }';
                        msg := 'You have insufficient funds in your savings Account to use this service.' +
                       '. Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, sourceaccount, Vendor."Phone No.", msg);
                    end;
                end else begin
                    response := '{ "StatusCode": "305", "StatusDescription":"INSUFFICIENTBALANCE" }';
                    msg := 'Your request has failed because you do not have any outstanding balance.' +
                   '. Thank you for using POLYTECH Sacco Mobile.';
                    SMSMessage(documentno, sourceaccount, Vendor."Phone No.", msg);
                end;

            end;
        end
    end;

    procedure FundsTransferFOSA(traceid: text[30]; documentno: text[30]; phonenumber: text[100]; accountFrom: Text[20]; destinationAccount: Text[20]; transferamount: Decimal; transactiondate: DateTime) result: Text
    var
        SwizzKashTransactionsTable: Record "SwizzKash Transactions";
        vendorTable: Record Vendor;
        saccoCommAccount: code[20];
        vendorCommAccount: code[20];
        saccoCommAmnt: Decimal;
        vendorCommAmnt: Decimal;
        sourceaccount: code[30];
        jnlBatchTemplate: Code[20];
        jnlBatchName: code[20];
        intNumber: Integer;
    begin
        Evaluate(intNumber, traceid);
        SwizzKashTransactionsTable.Reset;
        SwizzKashTransactionsTable.SetRange(SwizzKashTransactionsTable."Document No", documentno);
        if SwizzKashTransactionsTable.Find('-') then begin
            result := '{ "StatusCode":"501":",StatusDescription":"DOCUMENTNUMBEREXISTS" }';
        end else begin

            IF (SwizzKashTransactionsTable.Entry = intNumber) AND (SwizzKashTransactionsTable."transaction type" = SwizzKashTransactionsTable."transaction type"::"Transfer to Fosa") THEN begin
                result := '{ "StatusCode":"501":",StatusDescription":"DOCUMENTNUMBEREXISTS" }';
                exit(result);
            end;

            jnlBatchTemplate := 'GENERAL';
            jnlBatchName := 'MOBILETRAN';

            Charges.Reset;
            Charges.SetRange(Charges.Code, 'FTF');
            if Charges.Find('-') then begin
                Charges.TestField(Charges."GL Account");
                vendorCommAccount := Charges."GL Account";
                vendorCommAmnt := Charges."Charge Amount";
                saccoCommAccount := Charges."SAcco GL Account";
                saccoCommAmnt := Charges."Sacco Amount";
            end;
            ExcDuty := (20 / 100) * (saccoCommAmnt + vendorCommAmnt);

            vendorTable.Reset;
            vendorTable.SetRange(vendorTable."Mobile Phone No", phonenumber);
            if vendorTable.Find('-') then begin

                vendorTable.CalcFields(vendorTable."Balance (LCY)");
                vendorTable.CalcFields(vendorTable."ATM Transactions");
                vendorTable.CalcFields(vendorTable."Uncleared Cheques");
                vendorTable.CalcFields(vendorTable."EFT Transactions");
                TempBalance := vendorTable."Balance (LCY)" - (vendorTable."ATM Transactions" + vendorTable."Uncleared Cheques" + vendorTable."EFT Transactions");// + accountMinBalance);


                vendorTable.CalcFields(vendorTable."Balance (LCY)", vendorTable."ATM Transactions", vendorTable."Uncleared Cheques");
                //TempBalance := vendorTable."Balance (LCY)" - (vendorTable."ATM Transactions" + vendorTable."Uncleared Cheques" + vendorTable."EFT Transactions");
                accountName1 := vendorTable.Name;
                if vendorTable.Get(destinationAccount) then begin

                    if (TempBalance > amount + saccoCommAmnt + vendorCommAmnt) then begin

                        ClearGLJournal(jnlBatchTemplate, jnlBatchName);

                        PrepareGLJournalBatch(jnlBatchTemplate, jnlBatchName, 'MOBILE TRANSFER');

                        //DR ACC 1
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Mobile FOSA Transfer',
                        transferamount, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);

                        //Dr Transfer Charges
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Mobile FOSA Transfer charges',
                        saccoCommAmnt + vendorCommAmnt, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);

                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Ex. Duty Mobile FOSA transfer',
                        ExcDuty, Today, TransactionTypesEnum::EXCISE_DUTY);

                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        ExxcDuty, saccoCommAccount, 'Ex. Duty Mobile FOSA transfer',
                        -1 * ExcDuty, Today, TransactionTypesEnum::EXCISE_DUTY);

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        saccoCommAccount, saccoCommAccount, 'Mobile FOSA transfer Charges',
                        -1 * saccoCommAmnt, Today, TransactionTypesEnum::" ");

                        //CR Commission
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        vendorCommAccount, saccoCommAccount, 'Vendor Mobile FOSA transfer Charges',
                        -1 * vendorCommAmnt, Today, TransactionTypesEnum::" ");

                        //CR ACC2
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        destinationAccount, destinationAccount, 'Mobile FOSA transfer' + vendorTable."No.",
                        -1 * transferamount, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);


                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        if GenJournalLine.Find('-') then begin
                            repeat
                                GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                        end;
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        GenJournalLine.DeleteAll;

                        Evaluate(intNumber, traceid);

                        SwizzKashTransactionsTable.Init;
                        //SwizzKashTransactionsTable.Entry := intNumber;
                        SwizzKashTransactionsTable."Document No" := documentno;
                        SwizzKashTransactionsTable.Description := 'Mobile FOSA Transfer';
                        SwizzKashTransactionsTable."Document Date" := Today;
                        SwizzKashTransactionsTable."Account No" := vendorTable."No.";
                        SwizzKashTransactionsTable."Account No2" := destinationAccount;
                        SwizzKashTransactionsTable.Amount := amount;
                        SwizzKashTransactionsTable.Posted := true;
                        SwizzKashTransactionsTable."Posting Date" := Today;
                        SwizzKashTransactionsTable.Comments := 'Success';
                        SwizzKashTransactionsTable.Client := vendorTable."BOSA Account No";
                        SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."transaction type"::"Transfer to Fosa";
                        SwizzKashTransactionsTable."Transaction Time" := Time;
                        SwizzKashTransactionsTable.Insert;

                        result := '{ "StatusCode":"000":",StatusDescription":"OK" }';

                        vendorTable.Reset();
                        vendorTable.SetRange(vendorTable."No.", destinationAccount);
                        if vendorTable.Find('-') then begin
                            accountName2 := vendorTable.Name;
                        end;

                        msg := 'You have transfered KES ' + Format(amount) + ' from Account ' + accountName1 + ' to ' + accountName2 +
                         ' .Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);

                    end else begin
                        result := '{ "StatusCode":"503":",StatusDescription":"INSUFFIENTBALANCE" }';
                        msg := 'You have insufficient funds in your savings Account to use this service.' +
                       ' .Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
                    end;
                end else begin
                    result := '{ "StatusCode":"504":",StatusDescription":"DESTINATIONAACCOUNTNOTFOUND" }';
                    msg := 'Your request has failed because the recipent account does not exist.' +
                   ' .Thank you, POLYTECH Sacco Mobile.';
                    SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
                end;
            end else begin
                result := '{ "StatusCode":"504":",StatusDescription":"DESTINATIONAACCOUNTNOTFOUND" }';
                msg := 'Your request has failed because the recipent account does not exist.' +
                ' .Thank you, POLYTECH Sacco Mobile.';
                SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
            end;
        end;
    end;

    procedure FundsTransferBOSA(traceid: text[30]; documentno: text[30]; phonenumber: text[100]; accountFrom: Text[20]; destinationAccount: Text[20]; transferamount: Decimal; transactiondate: DateTime) result: Text
    var
        SwizzKashTransactionsTable: Record "SwizzKash Transactions";
        vendorTable: Record Vendor;
        saccoCommAccount: code[20];
        vendorCommAccount: code[20];
        saccoCommAmnt: Decimal;
        vendorCommAmnt: Decimal;
        jnlBatchTemplate: Code[20];
        jnlBatchName: code[20];
        intNumber: Integer;
    begin
        Evaluate(intNumber, traceid);

        SwizzKashTransactionsTable.Reset;
        SwizzKashTransactionsTable.SetRange(SwizzKashTransactionsTable."Document No", documentno);
        if SwizzKashTransactionsTable.Find('-') then begin
            result := '{ "StatusCode":"501":",StatusDescription":"DOCUMENTNUMBEREXISTS" }';
        end else begin

            IF (SwizzKashTransactionsTable.Entry = intNumber) AND (SwizzKashTransactionsTable."transaction type" = SwizzKashTransactionsTable."transaction type"::"Transfer to Fosa") THEN begin
                result := '{ "StatusCode":"502":",StatusDescription":"REFIDREXISTS" }';
                exit(result);
            end;

            jnlBatchTemplate := 'GENERAL';
            jnlBatchName := 'MOBILETRAN';

            vendorTable.Reset;
            vendorTable.SetRange(vendorTable."Mobile Phone No", phonenumber);
            if not vendorTable.Find('-') then begin
                result := '{ "StatusCode":"503":",StatusDescription":"SOURCEACCOUNTNOTFOUND" }';
                msg := 'Your request has failed because the recipent account does not exist.' +
                '. Thank you, POLYTECH Sacco Mobile.';
                // SMSMessage(documentno, accFrom, vendorTable."Phone No.", msg);
                exit(result);
            end;


            Members.Reset;
            Members.SetRange(Members."FOSA Account No.", vendorTable."No.");
            if Members.Find('-') then begin


                Charges.Reset;
                Charges.SetRange(Charges.Code, 'FTO');
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");
                    vendorCommAccount := Charges."GL Account";
                    vendorCommAmnt := Charges."Charge Amount";
                    saccoCommAccount := Charges."SAcco GL Account";
                    saccoCommAmnt := Charges."Sacco Amount";
                end;
                ExcDuty := (20 / 100) * (saccoCommAmnt + vendorCommAmnt);

                // vendorTable.Reset;
                // vendorTable.SetRange(vendorTable."No.", accFrom);
                // if vendorTable.Find('-') then begin


                vendorTable.CalcFields(vendorTable."Balance (LCY)");
                vendorTable.CalcFields(vendorTable."ATM Transactions");
                vendorTable.CalcFields(vendorTable."Uncleared Cheques");
                vendorTable.CalcFields(vendorTable."EFT Transactions");
                TempBalance := vendorTable."Balance (LCY)" - (vendorTable."ATM Transactions" + vendorTable."Uncleared Cheques" + vendorTable."EFT Transactions");// + accountMinBalance);


                vendorTable.CalcFields(vendorTable."Balance (LCY)");
                //TempBalance := vendorTable."Balance (LCY)" - (vendorTable."ATM Transactions" + vendorTable."Uncleared Cheques" + vendorTable."EFT Transactions");

                if (destinationAccount = 'Shares Capital')
                    or (destinationAccount = 'Deposit Contribution')
                    or (destinationAccount = 'Benevolent Fund')
                then begin

                    if (TempBalance > (amount + saccoCommAmnt + vendorCommAmnt)) then begin

                        ClearGLJournal(jnlBatchTemplate, jnlBatchName);

                        PrepareGLJournalBatch(jnlBatchTemplate, jnlBatchName, 'MOBILE FOSA BOSA TRANSFER');

                        //DR ACC 1                        
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Mobile BOSA Transfer',
                        transferamount, Today, TransactionTypesEnum::MOBILE_BOSA_TRANSFER);
                        /*
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                        GenJournalLine."Account No." := vendorTable."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                        GenJournalLine.Description := 'Mobile Transfer';
                        GenJournalLine.Amount := amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */

                        //Dr Transfer Charges                        
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Mobile BOSA Transfer Charge',
                        saccoCommAmnt + vendorCommAmnt, Today, TransactionTypesEnum::MOBILE_BOSA_TRANSFER_CHARGE);
                        /*
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                        GenJournalLine."Account No." := vendorTable."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := vendorTable."No.";
                        GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Mobile Transfer Charges';
                        GenJournalLine.Amount := saccoCommAmnt + vendorCommAmnt;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */


                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        vendorTable."No.", vendorTable."No.", 'Excise Duty. Mobile BOSA Transfer',
                        ExcDuty, Today, TransactionTypesEnum::EXCISE_DUTY);
                        /*                        
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                        GenJournalLine."Account No." := vendorTable."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Excise duty-Mobile Transfer';
                        GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                        GenJournalLine.Amount := ExcDuty;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */

                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        ExxcDuty, saccoCommAccount, 'Excise Duty. Mobile BOSA Transfer',
                        -1 * ExcDuty, Today, TransactionTypesEnum::" ");
                        /*
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                        GenJournalLine."Account No." := ExxcDuty;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := saccoCommAccount;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Excise duty-Mobile Transfer';
                        GenJournalLine.Amount := ExcDuty * -1;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        saccoCommAccount, saccoCommAccount, 'Mobile BOSA Transfer Charge',
                        -1 * saccoCommAmnt, Today, TransactionTypesEnum::" ");
                        /*                        
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                        GenJournalLine."Account No." := saccoCommAccount;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := saccoCommAccount;
                        GenJournalLine."Source No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Mobile Transfer Charges';
                        GenJournalLine.Amount := saccoCommAmnt * -1;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */


                        //CR Commission
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        vendorCommAccount, saccoCommAccount, 'Mobile BOSA Transfer Charge',
                        -1 * vendorCommAmnt, Today, TransactionTypesEnum::" ");
                        /*
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                        GenJournalLine."Account No." := vendorCommAccount;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := saccoCommAccount;
                        GenJournalLine."Source No." := vendorTable."No.";
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Mobile Transfer Charges';
                        GenJournalLine.Amount := -vendorCommAmnt;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        */


                        //CR ACC2
                        /*
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Customer,
                        Members."No.",'SUREPESA', 'Mobile BOSA Transfer Charge',
                        -1*transferamount, Today, TransactionTypesEnum::MOBILE_BOSA_TRANSFER_CHARGE);
                        */

                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := jnlBatchTemplate;
                        GenJournalLine."Journal Batch Name" := jnlBatchName;
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                        GenJournalLine."Account No." := Members."No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentno;
                        GenJournalLine."External Document No." := 'SUREPESA';
                        GenJournalLine."Posting Date" := Today;
                        case destinationAccount of
                            'Deposit Contribution':
                                begin
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                end;
                            'Shares Capital':
                                begin
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Shares Capital";
                                end;
                            'Benevolent Fund':
                                begin
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Benevolent Fund";
                                end;
                        end;
                        GenJournalLine.Description := 'Mobile Transfer from ' + vendorTable."No.";
                        GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        GenJournalLine.Amount := -amount;
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;

                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        if GenJournalLine.Find('-') then begin
                            repeat
                                GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                        end;
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        GenJournalLine.DeleteAll;

                        SwizzKashTransactionsTable.Init;
                        // SwizzKashTransactionsTable.Entry := intNumber;
                        SwizzKashTransactionsTable."Document No" := documentno;
                        SwizzKashTransactionsTable.Description := 'Mobile BOSA Transfer';
                        SwizzKashTransactionsTable."Document Date" := Today;
                        SwizzKashTransactionsTable."Account No" := vendorTable."No.";
                        SwizzKashTransactionsTable."Account No2" := destinationAccount;
                        SwizzKashTransactionsTable.Amount := amount;
                        SwizzKashTransactionsTable.Posted := true;
                        SwizzKashTransactionsTable."Posting Date" := Today;
                        SwizzKashTransactionsTable.Comments := 'Success';
                        SwizzKashTransactionsTable.Client := vendorTable."BOSA Account No";
                        SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."transaction type"::"Transfer to Bosa";
                        SwizzKashTransactionsTable."Transaction Time" := Time;
                        SwizzKashTransactionsTable.Insert;

                        result := '{ "StatusCode":"000", "StatusDecription":"OK" }';
                        msg := 'You have transfered KES ' + Format(amount) + ' from Account ' + vendorTable.Name + ' to ' + destinationAccount +
                         ' .Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);

                    end else begin
                        result := '{ "StatusCode":"502", "StatusDecription":"INSUFFICIENTFUNDS" }';
                        msg := 'You have insufficient funds in your savings Account to use this service.' +
                       '. Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
                    end;

                end else begin
                    result := '{ "StatusCode":"504", "StatusDecription":"DESTINATIONACCOUNTNOTFOUND" }';
                    msg := 'Your request has failed because the recipent account does not exist.' +
                   '. Thank you, POLYTECH Sacco Mobile.';
                    SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
                end;

            end else begin
                result := '{ "StatusCode":"505", "StatusDecription":"MEMBERNUMBERNOTFOUND" }';
                msg := 'Your request has failed because the recipent account does not exist.' +
                '. Thank you, POLYTECH Sacco Mobile.';
                SMSMessage(documentno, vendorTable."No.", vendorTable."Phone No.", msg);
            end;

        end;
    end;

    procedure FundsTransferFOSAOTHER(traceid: text[30]; documentno: text[30]; phonenumber: text[100]; accountFrom: Text[20]; destinationAccount: Text[20]; transferamount: Decimal; transactiondate: DateTime) result: Text
    var
        SwizzKashTransactionsTable: Record "SwizzKash Transactions";
        vendorDestTable: Record Vendor;
        sourceaccount: code[30];
        saccoCommAccount: code[20];
        vendorCommAccount: code[20];
        saccoCommAmnt: Decimal;
        vendorCommAmnt: Decimal;
        jnlBatchTemplate: Code[20];
        jnlBatchName: code[20];
        intNumber: Integer;
    begin
        SwizzKashTransactionsTable.Reset;
        SwizzKashTransactionsTable.SetRange(SwizzKashTransactionsTable."Document No", documentno);
        if SwizzKashTransactionsTable.Find('-') then begin
            result := '{ "StatusCode":"501":",StatusDescription":"DOCUMENTNUMBEREXISTS" }';
        end else begin
            Evaluate(intNumber, traceid);

            IF (SwizzKashTransactionsTable.Entry = intNumber) AND (SwizzKashTransactionsTable."transaction type" = SwizzKashTransactionsTable."transaction type"::"Transfer to Fosa") THEN begin
                result := '{ "StatusCode":"501":",StatusDescription":"DOCUMENTNUMBEREXISTS" }';
                exit(result);
            end;

            jnlBatchTemplate := 'GENERAL';
            jnlBatchName := 'MOBILETRAN';

            GenLedgerSetup.Reset;

            Charges.Reset;
            Charges.SetRange(Charges.Code, 'FTO');
            if Charges.Find('-') then begin
                Charges.TestField(Charges."GL Account");
                vendorCommAccount := Charges."GL Account";
                vendorCommAmnt := Charges."Charge Amount";
                saccoCommAccount := Charges."SAcco GL Account";
                saccoCommAmnt := Charges."Sacco Amount";
            end;

            ExcDuty := (20 / 100) * (saccoCommAmnt + vendorCommAmnt);

            Vendor.Reset;
            //Vendor.SetRange(Vendor."No.", accFrom);
            Vendor.SetRange(vendor."Mobile Phone No", phonenumber);
            if Vendor.Find('-') then begin


                Vendor.CalcFields(Vendor."Balance (LCY)");
                Vendor.CalcFields(Vendor."ATM Transactions");
                Vendor.CalcFields(Vendor."Uncleared Cheques");
                Vendor.CalcFields(Vendor."EFT Transactions");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");


                Vendor.CalcFields(Vendor."Balance (LCY)");
                //TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
                accountName1 := Vendor.Name;
                if vendorDestTable.Get(destinationAccount) then begin

                    if (TempBalance > (amount + saccoCommAmnt + vendorCommAmnt)) then begin

                        ClearGLJournal(jnlBatchTemplate, jnlBatchName);

                        PrepareGLJournalBatch(jnlBatchTemplate, jnlBatchName, 'MOBILE TRANSFER');

                        //DR ACC 1
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        Vendor."No.", Vendor."No.", 'Mobile FOSA Transfer',
                        transferamount, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);

                        //Dr Transfer Charges
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        Vendor."No.", Vendor."No.", 'Mobile FOSA Transfer charges',
                        saccoCommAmnt + vendorCommAmnt, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);

                        //DR Excise Duty
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        Vendor."No.", Vendor."No.", 'Ex. Duty Mobile FOSA transfer',
                        ExcDuty, Today, TransactionTypesEnum::EXCISE_DUTY);

                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        ExxcDuty, saccoCommAccount, 'Ex. Duty Mobile FOSA transfer',
                        -1 * ExcDuty, Today, TransactionTypesEnum::EXCISE_DUTY);

                        //CR Mobile Transactions Acc
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        saccoCommAccount, saccoCommAccount, 'Mobile FOSA transfer Charges',
                        -1 * saccoCommAmnt, Today, TransactionTypesEnum::" ");

                        //CR Commission
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::"G/L Account",
                        vendorCommAccount, saccoCommAccount, 'Vendor Mobile FOSA transfer Charges',
                        -1 * vendorCommAmnt, Today, TransactionTypesEnum::" ");

                        //CR ACC2
                        LineNo := LineNo + 10000;
                        CreateGenJournalLine(jnlBatchTemplate, jnlBatchName, LineNo,
                        documentno, "Gen. Journal Account Type"::Vendor,
                        destinationAccount, destinationAccount, 'Mobile FOSA transfer' + Vendor."No.",
                        -1 * transferamount, Today, TransactionTypesEnum::MOBILE_FOSA_TRANSFER);


                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        if GenJournalLine.Find('-') then begin
                            repeat
                            // GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                        end;
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", jnlBatchTemplate);
                        GenJournalLine.SetRange("Journal Batch Name", jnlBatchName);
                        GenJournalLine.DeleteAll;

                        Evaluate(intNumber, traceid);

                        SwizzKashTransactionsTable.Init;
                        //SwizzKashTransactionsTable.Entry := intNumber;
                        SwizzKashTransactionsTable."Document No" := documentno;
                        SwizzKashTransactionsTable.Description := 'Mobile FOSA Transfer';
                        SwizzKashTransactionsTable."Document Date" := Today;
                        SwizzKashTransactionsTable."Account No" := Vendor."No.";
                        SwizzKashTransactionsTable."Account No2" := destinationAccount;
                        SwizzKashTransactionsTable.Amount := amount;
                        SwizzKashTransactionsTable.Posted := true;
                        SwizzKashTransactionsTable."Posting Date" := Today;
                        SwizzKashTransactionsTable.Comments := 'Success';
                        SwizzKashTransactionsTable.Client := Vendor."BOSA Account No";
                        SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."transaction type"::"Transfer to Fosa";
                        SwizzKashTransactionsTable."Transaction Time" := Time;
                        SwizzKashTransactionsTable.Insert;

                        result := '{ "StatusCode":"000":",StatusDescription":"OK" }';

                        // Vendor.Reset();
                        // Vendor.SetRange(Vendor."No.", destinationAccount);
                        // if Vendor.Find('-') then begin
                        accountName2 := vendorDestTable.Name;
                        // end;

                        msg := 'You have transfered KES ' + Format(amount) + ' from Account ' + accountName1 + ' to ' + accountName2 +
                         ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, Vendor."No.", Vendor."Phone No.", msg);

                    end else begin
                        result := '{ "StatusCode":"503":",StatusDescription":"INSUFFIENTBALANCE" }';
                        msg := 'You have insufficient funds in your savings Account to use this service.' +
                       ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage(documentno, Vendor."No.", Vendor."Phone No.", msg);
                    end;
                end else begin
                    result := '{ "StatusCode":"504":",StatusDescription":"DESTINATIONAACCOUNTNOTFOUND" }';
                    msg := 'Your request has failed because the recipent account does not exist.' +
                   ' .Thank you for using POLYTECH Sacco Mobile.';
                    SMSMessage(documentno, Vendor."No.", Vendor."Phone No.", msg);
                end;
            end else begin
                result := '{ "StatusCode":"504":",StatusDescription":"DESTINATIONAACCOUNTNOTFOUND" }';
                msg := 'Your request has failed because the recipent account does not exist.' +
                ' .Thank you for using POLYTECH Sacco Mobile.';
                SMSMessage(documentno, Vendor."No.", Vendor."Phone No.", msg);
            end;
        end;
    end;



    procedure PaybillTransaction(traceid: Text[30]; documentno: Code[30]; accountno: Text[150]; accountname: Text[150]; phonenumber: Text[100]; amountpaidin: Decimal; saccopaybillbal: Decimal; transactiondate: DateTime; transactiontype: Text[30]; narration: Text[150]) Result: Text
    var
        paybillTransTable: Record "SwizzKash MPESA Trans";
        Keyword: Text[30];
    begin

        Result := '{ "StatusCode":"2","StatusDescription":"NOTRECORDED","DocumentNo":"' + documentNo + '","TraceId":"' + traceid + '" }';
        paybillTransTable.RESET;
        paybillTransTable.SETRANGE(paybillTransTable."Document No", documentNo);
        IF paybillTransTable.FIND('-') THEN BEGIN
            Result := '{ "StatusCode":"1","StatusDescription":"DUPLICATERECORD","DocumentNo":"' + documentNo + '","TraceId":"' + traceid + '" }';
        END ELSE BEGIN

            IF StrLen(accountno) > 3 THEN KeyWord := COPYSTR(accountno, 1, 3) ELSE Keyword := accountno;

            /* CHECK IF ALREADY POSTED BEFORE AND MARK POSTED ACCORDINGLY */

            paybillTransTable.INIT;
            paybillTransTable."Document No" := documentNo;
            paybillTransTable."Key Word" := Keyword;
            paybillTransTable."Account No" := accountNo;
            paybillTransTable."Account Name" := accountName;
            paybillTransTable."Transaction Date" := DT2DATE(transactionDate);
            paybillTransTable."Transaction Time" := DT2TIME(transactionDate);
            paybillTransTable.TransDate := transactionDate;
            paybillTransTable."Document Date" := TODAY;
            paybillTransTable.Description := 'PayBill-' + accountno + ' ' + accountname;
            paybillTransTable.Telephone := phonenumber;
            paybillTransTable."Transaction Type" := transactionType;
            paybillTransTable.Amount := amountpaidin;
            paybillTransTable."Paybill Acc Balance" := saccopaybillbal;
            paybillTransTable.Posted := FALSE;
            paybillTransTable.TraceId := traceid;

            paybillTransTable.INSERT;

            Result := '{ "StatusCode":"000","StatusDescription":"OK","DocumentNo":"' + documentNo + '","TraceId":"' + traceid + '" }';
        END;
    end;

    PROCEDURE ProcessLoanRepayments() result: Text[30];
    VAR
        accFrom: Text[20];
        loanNo: Text[20];
        DocNumber: Text[30];
        amount: Decimal;
        AppType: Code[100];
    BEGIN

        SurePESATrans.RESET;
        //SurePESATrans.SETRANGE(SurePESATrans.Entry,83791);
        SurePESATrans.SETRANGE(Posted, FALSE);
        SurePESATrans.SETRANGE(Status, SurePESATrans.Status::Pending);
        SurePESATrans.SETRANGE("Transaction Type", SurePESATrans."Transaction Type"::"Loan Repayment");
        SurePESATrans.SETFILTER("Document Date", '>=%1', 20180325D);// 081223D);
        IF SurePESATrans.FIND('-') THEN BEGIN
            REPEAT
                result := PostLoanRepayment(SurePESATrans."Document No");
            UNTIL SurePESATrans.NEXT = 0;
        END;
    END;

    PROCEDURE PostLoanRepayment(DocNumber: Text[30]) result: Text[30];
    VAR
        accFrom: Text[20];
        loanNo: Text[20];
        amount: Decimal;
        AppType: Code[100];
        SwizzKashTransTable: Record "SwizzKash Transactions";
        runningTotal: Decimal;
        totalCharges: Decimal;
    BEGIN
        result := 'NOTPROCESSED';
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SETRANGE(SwizzKashTransTable."Document No", DocNumber);
        SwizzKashTransTable.SETRANGE(Posted, FALSE);
        SwizzKashTransTable.SETRANGE("Transaction Type", SwizzKashTransTable."Transaction Type"::"Loan Repayment");
        IF SwizzKashTransTable.FIND('-') THEN BEGIN

            IF SwizzKashTransTable.Amount = 0 THEN BEGIN
                result := 'INVALIDAMOUNT';
                SwizzKashTransTable.Posted := TRUE;
                SwizzKashTransTable.Status := SwizzKashTransTable.Status::Failed;
                SwizzKashTransTable."Posting Date" := TODAY;
                SwizzKashTransTable.Comments := result;
                SwizzKashTransTable.MODIFY;
                EXIT(result);
            END;

            amount := SwizzKashTransTable.Amount;
            accFrom := SwizzKashTransTable."Account No";
            //loanNo:=SwizzKashTransTable."Loan No";
            loanNo := SwizzKashTransTable."Account No2";

            LoanAmt := amount;

            runningTotal := amount;
            totalCharges := 0;

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."No.", accFrom);
            IF Vendor.FIND('-') THEN BEGIN

                GenLedgerSetup.RESET;
                GenLedgerSetup.GET;
                GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
                GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

                Charges.RESET;
                Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
                IF Charges.FIND('-') THEN BEGIN
                    Charges.TESTFIELD(Charges."GL Account");
                    MobileChargesACC := Charges."GL Account";
                    MobileCharges := Charges."Charge Amount";
                END;

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";

                ExcDuty := GetExciseDutyRate() * (MobileCharges);

                AccountTypes.RESET;
                AccountTypes.SETRANGE(AccountTypes.Code, Vendor."Account Type");
                IF AccountTypes.FIND('-') THEN BEGIN
                    miniBalance := AccountTypes."Minimum Balance";
                END;

                Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions" + miniBalance);

                accountName1 := Vendor.Name;

                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Loan  No.", loanNo);
                IF LoansRegister.FIND('+') THEN BEGIN

                    LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                    totalCharges := MobileCharges + SwizzKashCharge + ExcDuty;
                    IF (TempBalance > (amount + totalCharges)) THEN BEGIN
                        IF LoansRegister."Outstanding Balance" > 0 THEN BEGIN

                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DELETEALL;
                            //end of deletion

                            GenBatches.RESET;
                            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                            GenBatches.SETRANGE(GenBatches.Name, 'MOBILETRAN');

                            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                                GenBatches.INIT;
                                GenBatches."Journal Template Name" := 'GENERAL';
                                GenBatches.Name := 'MOBILETRAN';
                                GenBatches.Description := 'Mobile Loan Repayment';
                                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                                GenBatches.VALIDATE(GenBatches.Name);
                                GenBatches.INSERT;
                            END;

                            //DR ACC 1
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                            GenJournalLine."Account No." := accFrom;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := accFrom;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Mobile Loan Repayment';
                            GenJournalLine.Amount := amount;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //Dr Transfer Charges
                            //            LineNo:=LineNo+10000;
                            //            GenJournalLine.INIT;
                            //            GenJournalLine."Journal Template Name":='GENERAL';
                            //            GenJournalLine."Journal Batch Name":='MOBILETRAN';
                            //            GenJournalLine."Line No.":=LineNo;
                            //            GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
                            //            GenJournalLine."Account No.":=accFrom;
                            //            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            //            GenJournalLine."Document No.":=DocNumber;
                            //            GenJournalLine."External Document No.":=accFrom;
                            //            GenJournalLine."Posting Date":=TODAY;
                            //            GenJournalLine.Description:='Mobile Charges';
                            //            GenJournalLine.Amount:=MobileCharges + SwizzKashCharge ;
                            //            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            //            IF GenJournalLine.Amount<>0 THEN
                            //            GenJournalLine.INSERT;


                            //DR Excise Duty
                            //            LineNo:=LineNo+10000;
                            //            GenJournalLine.INIT;
                            //            GenJournalLine."Journal Template Name":='GENERAL';
                            //            GenJournalLine."Journal Batch Name":='MOBILETRAN';
                            //            GenJournalLine."Line No.":=LineNo;
                            //            GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
                            //            GenJournalLine."Account No.":=accFrom;
                            //            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            //            GenJournalLine."Document No.":=DocNumber;
                            //            GenJournalLine."External Document No.":=accFrom;
                            //            GenJournalLine."Posting Date":=TODAY;
                            //            GenJournalLine.Description:='Excise duty-Mobile Charges';
                            //            GenJournalLine.Amount:=ExcDuty;
                            //            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            //            IF GenJournalLine.Amount<>0 THEN
                            //            GenJournalLine.INSERT;

                            //CR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := ExxcDuty;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Excise duty-Mobile Charges';
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;
                            runningTotal := runningTotal + GenJournalLine.Amount;

                            //CR SACCO Mobile Transactions Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := MobileChargesACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Mobile Charges';
                            GenJournalLine.Amount := MobileCharges * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;
                            runningTotal := runningTotal + GenJournalLine.Amount;

                            //CR Vendor Commission
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := SwizzKashCommACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Vendor Mobile Charges';
                            GenJournalLine.Amount := SwizzKashCharge * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;
                            runningTotal := runningTotal + GenJournalLine.Amount;

                            IF LoansRegister."Oustanding Interest" > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := DocNumber;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Interest Payment-' + LoansRegister."Client Code" + ' ' + Vendor.Name;
                                IF runningTotal > LoansRegister."Oustanding Interest" THEN
                                    GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                                ELSE
                                    GenJournalLine.Amount := runningTotal * -1;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;

                                runningTotal := runningTotal + GenJournalLine.Amount;
                            END;

                            IF runningTotal > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := DocNumber;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Loan repayment ' + LoansRegister."Client Code" + ' ' + Vendor.Name;
                                GenJournalLine.Amount := runningTotal * -1;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Loan Repayment";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;
                            END;

                            //EXIT; // -- remove after debug

                            //Post
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    GLPosting.RUN(GenJournalLine);
                                UNTIL GenJournalLine.NEXT = 0;
                            END;
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DELETEALL;

                            result := 'TRUE';
                            SwizzKashTransTable.Posted := TRUE;
                            SwizzKashTransTable.Status := SwizzKashTransTable.Status::Completed;
                            SwizzKashTransTable."Posting Date" := TODAY;
                            SwizzKashTransTable.Comments := 'Success';
                            SwizzKashTransTable.MODIFY;

                        END ELSE BEGIN
                            result := 'LOANHASNOBALANCE';
                            SwizzKashTransTable.Posted := TRUE;
                            SwizzKashTransTable.Status := SwizzKashTransTable.Status::Failed;
                            SwizzKashTransTable."Posting Date" := TODAY;
                            SwizzKashTransTable.Comments := result;
                            SwizzKashTransTable.MODIFY;
                        END;
                    END ELSE BEGIN
                        result := 'INSUFFICIENTBALANCE';
                        SwizzKashTransTable.Posted := TRUE;
                        SwizzKashTransTable.Status := SwizzKashTransTable.Status::Failed;
                        SwizzKashTransTable."Posting Date" := TODAY;
                        SwizzKashTransTable.Comments := result;
                        SwizzKashTransTable.MODIFY;
                    END;
                END ELSE BEGIN
                    result := 'LOANNOTFOUND';
                    SwizzKashTransTable.Posted := TRUE;
                    SwizzKashTransTable.Status := SwizzKashTransTable.Status::Failed;
                    SwizzKashTransTable."Posting Date" := TODAY;
                    SwizzKashTransTable.Comments := result;
                    SwizzKashTransTable.MODIFY;
                END;
            END ELSE BEGIN
                result := 'ACCOUNTNOTFOUND';
                SwizzKashTransTable.Posted := TRUE;
                SwizzKashTransTable.Status := SwizzKashTransTable.Status::Failed;
                SwizzKashTransTable."Posting Date" := TODAY;
                SwizzKashTransTable.Comments := result;
                SwizzKashTransTable.MODIFY;
            END;

        END;
    END;

    LOCAL PROCEDURE CheckKeyword2(AccountNumber: Text[50]) Response: Text;
    VAR
        strKeyWord: Text[3];
    BEGIN
        strKeyWord := UPPERCASE(COPYSTR(AccountNumber, 1, 3));
        CASE strKeyWord OF
            'FAD':
                Response := strKeyWord;
            'TOT':
                Response := strKeyWord;
            'ORD':
                Response := strKeyWord;
            'SAV':
                Response := strKeyWord;

            'FXD':
                Response := strKeyWord;
            'CON':
                Response := strKeyWord;
            'MIC':
                Response := strKeyWord;
            'SSL':
                Response := strKeyWord;
            'HLD':
                Response := strKeyWord;

            'DEP':
                Response := strKeyWord;
            'GSD':
                Response := strKeyWord;
            'SHD':
                Response := strKeyWord;
            'SHA':
                Response := strKeyWord;
            'SHC':
                Response := strKeyWord;
            //'SHD': Response:=strKeyWord;
            'MSD':
                Response := strKeyWord;

            'GPS':
                Response := strKeyWord;
            'BVF':
                Response := strKeyWord;

            'EML':
                Response := strKeyWord;
            'ELB':
                Response := strKeyWord;
            'SFL':
                Response := strKeyWord;
            'SFB':
                Response := strKeyWord;
            'RFL':
                Response := strKeyWord;
            'RFB':
                Response := strKeyWord;

            'NML':
                Response := strKeyWord;
            'NLB':
                Response := strKeyWord;
            'IML':
                Response := strKeyWord;
            'ES1':
                Response := strKeyWord;
            'E1B':
                Response := strKeyWord;
            'ES2':
                Response := strKeyWord;
            'E2B':
                Response := strKeyWord;
            'ES3':
                Response := strKeyWord;
            'E3B':
                Response := strKeyWord;
            'ES4':
                Response := strKeyWord;
            'E4B':
                Response := strKeyWord;
            'ES5':
                Response := strKeyWord;
            'E5B':
                Response := strKeyWord;
            'SPL':
                Response := strKeyWord;
            'SCL':
                Response := strKeyWord;
            // 'SHC': Response:=strKeyWord;
            'DAD':
                Response := strKeyWord;
            'TAD':
                Response := strKeyWord;
            '1AD':
                Response := strKeyWord;
            'LAD':
                Response := strKeyWord;
            'LAB':
                Response := strKeyWord;
            'CDL':
                Response := strKeyWord;
            ELSE
                Response := 'FALSE';
        END;
        EXIT(Response);
    END;

    LOCAL PROCEDURE CheckKeyword(AccountNumber: Text[150]) Response: Text;
    VAR
        strKeyWord: Text[3];
    BEGIN
        strKeyWord := UPPERCASE(COPYSTR(AccountNumber, 1, 3));
        CASE strKeyWord OF
            'FAD':
                Response := strKeyWord;
            'TOT':
                Response := strKeyWord;
            'ORD':
                Response := strKeyWord;
            'SAV':
                Response := strKeyWord;

            'FXD':
                Response := strKeyWord;
            'CON':
                Response := strKeyWord;
            'MIC':
                Response := strKeyWord;
            'SSL':
                Response := strKeyWord;
            'HLD':
                Response := strKeyWord;

            'DEP':
                Response := strKeyWord;
            'GSD':
                Response := strKeyWord;
            'SHD':
                Response := strKeyWord;
            'SHA':
                Response := strKeyWord;
            'SHC':
                Response := strKeyWord;
            //'SHD': Response:=strKeyWord;
            'MSD':
                Response := strKeyWord;

            'GPS':
                Response := strKeyWord;
            'BVF':
                Response := strKeyWord;

            'EML':
                Response := strKeyWord;
            'ELB':
                Response := strKeyWord;
            'SFL':
                Response := strKeyWord;
            'SFB':
                Response := strKeyWord;
            'RFL':
                Response := strKeyWord;
            'RFB':
                Response := strKeyWord;

            'NML':
                Response := strKeyWord;
            'NLB':
                Response := strKeyWord;
            'IML':
                Response := strKeyWord;
            'ES1':
                Response := strKeyWord;
            'E1B':
                Response := strKeyWord;
            'ES2':
                Response := strKeyWord;
            'E2B':
                Response := strKeyWord;
            'ES3':
                Response := strKeyWord;
            'E3B':
                Response := strKeyWord;
            'ES4':
                Response := strKeyWord;
            'E4B':
                Response := strKeyWord;
            'ES5':
                Response := strKeyWord;
            'E5B':
                Response := strKeyWord;
            'SPL':
                Response := strKeyWord;
            'SCL':
                Response := strKeyWord;
            // 'SHC': Response:=strKeyWord;
            'DAD':
                Response := strKeyWord;
            'TAD':
                Response := strKeyWord;
            '1AD':
                Response := strKeyWord;
            'LAD':
                Response := strKeyWord;
            'LAB':
                Response := strKeyWord;
            'OMA':
                Response := strKeyWord;
            'CDL':
                Response := strKeyWord;
            'JTD':
                Response := strKeyWord;
            'JTS':
                Response := strKeyWord;
            ELSE
                Response := 'FALSE';
        END;
        EXIT(Response);
    END;
    //this is the live one
    PROCEDURE PaybillSwitch() Result: Code[20];
    VAR
        thisAccNum: Code[150];
        thisKeyWord: Code[30];
        vendorTable: Record 23;
        thisDocNum: Code[30];
        thisAmount: Decimal;
        thisMemberNum: Code[130];
        strKeyWord: Text[10];
    BEGIN

        PaybillTrans.RESET;
        PaybillTrans.SETRANGE(PaybillTrans.Posted, FALSE);
        PaybillTrans.SETRANGE(PaybillTrans."Needs Manual Posting", FALSE);
        //PaybillTrans.SETRANGE("Document No",'RIB4HZF5FW');
        PaybillTrans.SETFILTER(PaybillTrans."Transaction Date", '>=%1', 20180325D);
        PaybillTrans.SETCURRENTKEY(PaybillTrans.TransDate);
        //PaybillTrans.SETRANGE(PaybillTrans."Transaction Date", 081723D);
        PaybillTrans.SETASCENDING(PaybillTrans.TransDate, true);

        IF PaybillTrans.FIND('-') THEN BEGIN
            //................................
            //if StrLen(PaybillTrans."Account No") > 20 then begin
            //PaybillTrans."Date Posted" := TODAY;
            //PaybillTrans."Needs Manual Posting" := TRUE;
            //PaybillTrans.Remarks := 'STRING LENGTH';
            //PaybillTrans.MODIFY;
            //Result := PaybillTrans.Remarks;
            //exit;
            //end;
            //................................

            // check if account contains keyword and account separated by '#'
            IF STRPOS(PaybillTrans."Account No", '#') > 0 THEN BEGIN
                thisKeyWord := COPYSTR(PaybillTrans."Account No", 1, 3);
                thisAccNum := COPYSTR(PaybillTrans."Account No", 5, STRLEN(PaybillTrans."Account No") - 4);
            END ELSE BEGIN

                // check if account contains keyword and account
                strKeyWord := CheckKeyword(PaybillTrans."Account No");
                IF NOT (strKeyWord = 'FALSE') THEN BEGIN
                    thisKeyWord := strKeyWord;
                    thisAccNum := COPYSTR(PaybillTrans."Account No", 4, STRLEN(PaybillTrans."Account No") - 3);
                END ELSE BEGIN
                    thisKeyWord := PaybillTrans."Key Word";
                    thisAccNum := PaybillTrans."Account No";
                END;

            END;

            thisDocNum := PaybillTrans."Document No";
            thisAmount := PaybillTrans.Amount;
            thisMemberNum := thisAccNum;

            CASE UPPERCASE(PaybillTrans."Key Word") OF
                'NON':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'Paybill to Non Member Deposit');
                'FAD':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'BUSINESS');
                'TOT':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'TOTO');
                'ORD':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'M-WALLET');
                'SAV':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'M-WALLET');

                'FXD':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'FIXED');
                'CON':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'CONTROL');
                'MIC':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'MICRO SAVING');
                'SSL':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'SUPERSAVER');
                'HLD':
                    Result := PayBillToAcc('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'HOLIDAY');

                'DEP':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Deposit');
                'GSD':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Share Deposit');
                'SHD':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Deposit');
                'JTD':
                    Result := PayBillToJointAccount('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Joint Deposit');
                'JTS':
                    Result := PayBillToJointAccount('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Joint Share capital');
                'SHA':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Share capital');
                'SHC':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Share capital');
                'OMA':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'OMA');

                'GPS':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Group Deposit');
                'BVF':
                    Result := PayBillToBOSA('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, thisKeyWord, 'PayBill to Benevolent Fund');

                'EML':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'EMERGENCY');
                'ELB':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'EMERGENCY LOAN B');
                'SFL':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'SCHOOL');
                'SFB':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'SCHOOL FEES LOAN  B');
                'RFL':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'REFINANCING');
                'NML':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'NORMAL');
                'NLB':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'NORMAL LOANB');
                'IML':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'IMPORTED');
                'ES1':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'ESS_1');
                'ES2':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'ESS_2');
                'ES3':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'ESS_3');
                'ES4':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'ESS_4');
                'ES5':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'ESS_5');
                'SPL':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'SUPER');
                'SCL':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'STAFFCAR');
                'DAD':
                    Result := PaybillToFosaLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'DIVIDENDADV');
                'TAD':
                    Result := PaybillToFosaLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'TOPUPADV');
                '1AD':
                    Result := PaybillToFosaLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, '1MONTHADV');
                'LAD':
                    Result := PaybillToFosaLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'LOANADVANCE');
                'LAB':
                    Result := PaybillToFosaLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'LOANADVANCE B');

                'CDL':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'CAPITAL DEVELOPMENT');
                'RLB':
                    Result := PayBillToLoan('PAYBILL', thisDocNum, thisAccNum, thisMemberNum, thisAmount, 'REFINANCING B');
                ELSE

                    // check if acc is fosa
                    IF STRLEN(thisAccNum) <= 20 THEN BEGIN
                        vendorTable.RESET;
                        vendorTable.SETRANGE("No.", thisAccNum);
                        IF vendorTable.FIND('-') THEN BEGIN
                            Result := PayBillToFOSA('PAYBILL', thisDocNum, thisAccNum, thisAmount, 'M-WALLET');
                        END ELSE BEGIN
                            PaybillTrans."Date Posted" := TODAY;
                            PaybillTrans."Needs Manual Posting" := TRUE;
                            PaybillTrans.Remarks := 'KEYWORDNOTFOUND';
                            PaybillTrans.MODIFY;
                            Result := PaybillTrans.Remarks;
                        END;
                    END ELSE BEGIN
                        PaybillTrans."Date Posted" := TODAY;
                        PaybillTrans."Needs Manual Posting" := TRUE;
                        PaybillTrans.Remarks := 'KEYWORDNOTFOUND';
                        PaybillTrans.MODIFY;
                        Result := PaybillTrans.Remarks;
                    END;

            END;

        END ELSE BEGIN
            Result := 'No transactions';
        END;

        // **
        ProcessLoanRepayments();
    END;

    local procedure GetMemberNameVendor(MemberNo: Code[30]): Text
    var
    begin
        Vendor.Reset();
        Vendor.SetRange(Vendor."No.", MemberNo);
        if Vendor.FindSet() then begin
            exit(Vendor.Name);
        end;
    end;

    local procedure GetMemberNameCustomer(MemberNo: Code[30]): Text
    var
        Member: Record Customer;
    begin
        Member.Reset();
        member.SetRange(Member."No.", MemberNo);
        if Member.FindSet() then begin
            exit(Member.Name);
        end;
    end;

    LOCAL PROCEDURE PayBillToAcc(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; memberNo: Code[120]; Amount: Decimal; accountType: Code[30]) res: Code[10];
    VAR
        accNum: Text[20];
        PaybillTransTable: Record "SwizzKash MPESA Trans";
    BEGIN

        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);

            PaybillRecon := GenLedgerSetup.PayBillAcc;
            SurePESACharge := GetCharge(Amount, 'PAYBILL');
            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";

            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            //begin of deletion
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);
            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := 'Paybill Deposit';
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;
            //General Jnr Batches

            //accNum:=COPYSTR(accNo,4,100);
            //MESSAGE(accNo);

            Members.RESET;
            Members.SETRANGE(Members."No.", accNo);
            IF Members.FIND('-') THEN BEGIN

                //MESSAGE(Members."No.");

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                Vendor.SETRANGE(Vendor."Account Type", accountType);
                IF Vendor.FIND('-') THEN BEGIN
                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Paybill Deposit ' + Vendor.Name;
                    GenJournalLine.Amount := Amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                    GenJournalLine.Description := 'Paybill Deposit ' + Vendor.Name;
                    GenJournalLine.Amount := -1 * Amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Dr Customer charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                    GenJournalLine.Description := 'Paybill Deposit Charges ' + Vendor.Name;
                    GenJournalLine.Amount := SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //DR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                    GenJournalLine.Description := 'Excise duty-Paybill Deposit ' + vendor.Name;
                    GenJournalLine.Amount := ExcDuty;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-Paybill deposit ' + Vendor.Name;
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    //GenJournalLine."Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Mobile Deposit Charges ' + Vendor.Name;
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Vendor.Name + ', Your ACC: ' + Vendor."No." + ' has been credited with KES. ' + FORMAT(Amount) +
                                    ' .Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN//Vendor
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'Failed,FOSAACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor

            END ELSE BEGIN// Member
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'Failed,MEMBERACCNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//
        END;
    END;

    LOCAL PROCEDURE PayBillToBOSA(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; memberNo: Code[120]; amount: Decimal; type: Code[30]; descr: Text[100]) res: Code[10];
    VAR
        PaybillTransTable: Record "SwizzKash MPESA Trans";
    BEGIN
        //MESSAGE('in bosa, accno %1',accNo);
        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN
            //MESSAGE('in bosa doc search');
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SurePESACharge := GetCharge(amount, 'PAYBILL');
            PaybillRecon := GenLedgerSetup.PayBillAcc;


            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);

            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;//General Jnr Batches
                //..........................................................................................................
            IF type = 'NON' THEN BEGIN
                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine.Description := descr + ' ' + GetMemberNameCustomer(accNo);
                GenJournalLine.Amount := amount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Customer
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                GenJournalLine."Account No." := accNo;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := accNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Description := descr + ' ' + GetMemberNameCustomer(accNo);
                GenJournalLine.Amount := (amount) * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                GenJournalLine.SETRANGE("Journal Batch Name", batch);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                    PaybillTrans.Posted := TRUE;
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans.Description := 'Posted';
                    PaybillTrans.MODIFY;
                    res := 'TRUE';
                END
                ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Description := 'Failed Posting';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;
                EXIT;
            END;
            //............................................................................................................
            Members.RESET;
            IF (accNo = 'DEPOSIT CONTRIBUTION') OR (accNo = 'SHARE CAPITAL') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE("Mobile Phone No", '0' + COPYSTR(PaybillTransTable.Telephone, STRLEN(PaybillTransTable.Telephone) - 8, 9));
                IF Vendor.FIND('-') THEN BEGIN
                    //MESSAGE('found phone '+PaybillTransTable.Telephone+' mno ' +Vendor."BOSA Account No"+' '+Vendor.Name );
                    Members.SETRANGE("No.", Vendor."BOSA Account No");
                END ELSE BEGIN
                    Members.SETRANGE("No.", accNo);
                END;
            END ELSE BEGIN
                Members.SETRANGE("No.", accNo);
            END;

            IF Members.FIND('-') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                // Vendor.SETRANGE(Vendor."Account Type", fosaConst);
                IF Vendor.FIND('-') THEN BEGIN

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."BOSA Account No";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr + Vendor.Name;
                    GenJournalLine.Amount := amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Account No." := Members."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Members."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    //MESSAGE('Test keyword type %1',PaybillTransTable."Key Word");
                    CASE UPPERCASE(PaybillTransTable."Key Word") OF
                        'MSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHC':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHA':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'JTS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'GSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'GPS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'SHD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'DEP':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'JTD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'BVF':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Benevolent Fund";
                    END;
                    // MESSAGE('Test transaction type %1',GenJournalLine."Transaction Type");
                    //        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
                    //        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");

                    IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                        GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    END;

                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    //GenJournalLine."Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-' + descr + ' ' + Vendor.Name;
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr + ' Charges'' ' + Vendor.Name;
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Members.Name + ', Your ACC: ' + accNo + ' has been credited with KES. ' + FORMAT(amount) +
                                  ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'ACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor;

            END ELSE BEGIN
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'MEMBERNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//Member

        END;
    END;

    LOCAL PROCEDURE PayBillToJointAccount(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; memberNo: Code[120]; amount: Decimal; type: Code[30]; descr: Text[100]) res: Code[10];
    VAR
        PaybillTransTable: Record "SwizzKash MPESA Trans";
    BEGIN
        //MESSAGE('in bosa, accno %1',accNo);
        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN
            //MESSAGE('in bosa doc search');
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SurePESACharge := GetCharge(amount, 'PAYBILL');
            PaybillRecon := GenLedgerSetup.PayBillAcc;


            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);

            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;//General Jnr Batches

            Members.RESET;
            IF (accNo = 'DEPOSIT CONTRIBUTION') OR (accNo = 'SHARE CAPITAL') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE("Mobile Phone No", '0' + COPYSTR(PaybillTransTable.Telephone, STRLEN(PaybillTransTable.Telephone) - 8, 9));
                IF Vendor.FIND('-') THEN BEGIN
                    //MESSAGE('found phone '+PaybillTransTable.Telephone+' mno ' +Vendor."BOSA Account No"+' '+Vendor.Name );
                    Members.SETRANGE("No.", Vendor."BOSA Account No");
                END ELSE BEGIN
                    Members.SETRANGE("No.", accNo);
                    Members.SETRANGE(Members."Account Category", Members."Account Category"::Joint);
                END;
            END ELSE BEGIN
                Members.SETRANGE("No.", accNo);
                Members.SETRANGE(Members."Account Category", Members."Account Category"::Joint);
            END;

            IF Members.FIND('-') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                // Vendor.SETRANGE(Vendor."Account Type", fosaConst);
                IF Vendor.FIND('-') THEN BEGIN

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Members."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Account No." := Members."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Members."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    //MESSAGE('Test keyword type %1',PaybillTransTable."Key Word");
                    CASE UPPERCASE(PaybillTransTable."Key Word") OF
                        'MSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        //'SHC': GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHA':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'JTS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'GSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'GPS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        //'SHD': GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'DEP':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'JTD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'BVF':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Benevolent Fund";
                    END;
                    // MESSAGE('Test transaction type %1',GenJournalLine."Transaction Type");
                    //        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
                    //        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");

                    IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                        GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    END;

                    GenJournalLine.Description := descr + ' ' + GetMemberNameCustomer(Members."No.");
                    GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-' + descr + ' ' + GetMemberNameCustomer(Members."No.");
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    //GenJournalLine."Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr + ' Charges' + ' ' + GetMemberNameCustomer(Members."No.");
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Members.Name + ', Your ACC: ' + accNo + ' has been credited with KES. ' + FORMAT(amount) +
                                  ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'ACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor;

            END ELSE BEGIN
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'MEMBERNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//Member

        END;
    END;

    LOCAL PROCEDURE PayBillToLoan(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; memberNo: Code[120]; amount: Decimal; type: Code[30]) res: Code[10];
    VAR
        isPosted: Boolean;
        runningBalance: Decimal;
    BEGIN
        GenLedgerSetup.RESET;
        GenLedgerSetup.GET;
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge(amount, 'PAYBILL');
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        exciseDutyAcc := GetExciseDutyAccount();
        ExcDuty := GetExciseDutyRate() * (SurePESACharge);

        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        GenJournalLine.SETRANGE("Journal Batch Name", batch);
        GenJournalLine.DELETEALL;
        //end of deletion



        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SETRANGE(GenBatches.Name, batch);

        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Paybill Loan Repayment';
            GenBatches.VALIDATE(GenBatches."Journal Template Name");
            GenBatches.VALIDATE(GenBatches.Name);
            GenBatches.INSERT;
        END;//General Jnr Batches



        Members.RESET;
        Members.SETRANGE(Members."No.", accNo);
        IF Members.FIND('-') THEN BEGIN


            //MESSAGE('member %1 ln %2', Members.Name,type);

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Loan Product Type", type);
                LoansRegister.SETRANGE(LoansRegister."Client Code", Members."No.");
                IF LoansRegister.FIND('-') THEN BEGIN
                    isPosted := FALSE;
                    //MESSAGE('found %1',LoansRegister."Loan  No.");
                    REPEAT

                        LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");

                        //MESSAGE('outbal %1',LoansRegister."Outstanding Balance");

                        IF LoansRegister."Outstanding Balance" > 50 THEN BEGIN
                            isPosted := TRUE;// flag to exit loop when loan bal is found


                            //Dr MPESA PAybill ACC
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Account No." := PaybillRecon;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine.Description := 'Paybill Loan Repayment' + ' ' + Vendor.Name;
                            GenJournalLine.Amount := amount;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            IF LoansRegister."Oustanding Interest" > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := LoansRegister."Client Code";
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Loan Interest Payment ' + Vendor.Name;
                                IF amount > LoansRegister."Oustanding Interest" THEN
                                    GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                                ELSE
                                    GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";

                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;

                                amount := amount + GenJournalLine.Amount;
                            END;

                            IF amount > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := LoansRegister."Client Code";
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Paybill Loan Repayment ' + Vendor.Name;
                                GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Loan Repayment";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;
                            END;

                            //DR Cust Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                            GenJournalLine."Account No." := Vendor."No.";
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Paybill Loan Repayment ' + Vendor.Name;
                            GenJournalLine.Amount := SurePESACharge + ExcDuty;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;


                            //Distribute overpayment to deposits
                            //            runningBalance:=0;
                            //            runningBalance:=amount+GenJournalLine.Amount;
                            //
                            //            IF runningBalance>0 THEN BEGIN
                            //              LineNo:=LineNo+10000;
                            //              GenJournalLine.INIT;
                            //              GenJournalLine."Journal Template Name":='GENERAL';
                            //              GenJournalLine."Journal Batch Name":=batch;
                            //              GenJournalLine."Line No.":=LineNo;
                            //              GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
                            //              GenJournalLine."Account No.":=Members."No.";
                            //              GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            //              GenJournalLine."Document No.":=docNo;
                            //              GenJournalLine."External Document No.":=docNo;
                            //              GenJournalLine."Posting Date":=TODAY;
                            //              GenJournalLine."Transaction Type":= GenJournalLine."Transaction Type"::"Deposit Contribution";
                            //              GenJournalLine.Description:='Paybill to FOSA Loan Overpayment';
                            //              GenJournalLine.Amount:=-runningBalance;
                            //              GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            //              IF GenJournalLine.Amount<>0 THEN
                            //              GenJournalLine.INSERT;
                            //            END;

                            //CR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := exciseDutyAcc;// FORMAT(ExxcDuty);
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Excise duty-' + 'Paybill Loan Repayment ' + Vendor.Name;
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //CR Surestep Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            //GenJournalLine."Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine.Description := 'Paybill Loan Repayment' + ' Charges ' + Vendor.Name;
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //Post
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", batch);
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    GLPosting.RUN(GenJournalLine);
                                UNTIL GenJournalLine.NEXT = 0;
                                PaybillTrans.Posted := TRUE;
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans.Remarks := 'Posted';
                                PaybillTrans.MODIFY;
                                res := 'TRUE';
                                isPosted := TRUE;
                                msg := 'Dear ' + Members.Name + ', your payment of KES. ' + FORMAT(PaybillTrans.Amount) +
                                          ' for loan: ' + LoansRegister."Loan  No." + '-' + LoansRegister."Loan Product Type Name"
                                      + ' has been received.Thank you, POLYTECH DT SACCO Mobile.';
                                SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);

                            END ELSE BEGIN
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans."Needs Manual Posting" := TRUE;
                                PaybillTrans.Remarks := 'Failed Posting';
                                PaybillTrans.MODIFY;
                                res := 'FALSE';
                                isPosted := TRUE;
                            END;
                        END ELSE BEGIN
                            //MESSAGE('0 balance');
                            isPosted := FALSE;
                        END;//Outstanding Balance

                        IF isPosted = TRUE THEN BREAK;

                    UNTIL (LoansRegister.NEXT = 0);

                    IF isPosted = FALSE THEN BEGIN
                        PaybillTrans."Date Posted" := TODAY;
                        PaybillTrans."Needs Manual Posting" := TRUE;
                        PaybillTrans.Remarks := 'NOOUTSTANDINGBALANCE';
                        PaybillTrans.MODIFY;
                        res := 'FALSE';
                        isPosted := TRUE;
                    END;

                END ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Remarks := 'LOANNOTFOUND';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;//Loan Register

            END ELSE BEGIN
                PaybillTrans."Date Posted" := TODAY;
                PaybillTrans."Needs Manual Posting" := TRUE;
                PaybillTrans.Remarks := 'ACCNOTFOUND';
                PaybillTrans.MODIFY;
                res := 'FALSE';
            END;//Vendor;

        END ELSE BEGIN
            PaybillTrans."Date Posted" := TODAY;
            PaybillTrans."Needs Manual Posting" := TRUE;
            PaybillTrans.Remarks := 'MEMBERNOTFOUND';
            PaybillTrans.MODIFY;
            res := 'FALSE';
        END;//Member
    END;

    LOCAL PROCEDURE PaybillToFosaLoan(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; memberNo: Code[120]; amount: Decimal; type: Code[30]) res: Code[10];
    VAR
        isPosted: Boolean;
        runningBalance: Decimal;
    BEGIN
        GenLedgerSetup.RESET;
        GenLedgerSetup.GET;
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge(amount, 'PAYBILL');
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        exciseDutyAcc := GetExciseDutyAccount();
        ExcDuty := GetExciseDutyRate() * (SurePESACharge);

        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        GenJournalLine.SETRANGE("Journal Batch Name", batch);
        GenJournalLine.DELETEALL;
        //end of deletion



        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SETRANGE(GenBatches.Name, batch);

        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Paybill Loan Repayment';
            GenBatches.VALIDATE(GenBatches."Journal Template Name");
            GenBatches.VALIDATE(GenBatches.Name);
            GenBatches.INSERT;
        END;//General Jnr Batches



        Members.RESET;
        Members.SETRANGE(Members."No.", accNo);
        IF Members.FIND('-') THEN BEGIN


            //MESSAGE('member %1 ln %2', Members.Name,type);

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Loan Product Type", type);
                LoansRegister.SETRANGE(LoansRegister."Client Code", Vendor."No.");
                IF LoansRegister.FIND('-') THEN BEGIN
                    isPosted := FALSE;
                    //MESSAGE('found %1',LoansRegister."Loan  No.");
                    REPEAT

                        LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");

                        //MESSAGE('outbal %1',LoansRegister."Outstanding Balance");

                        IF LoansRegister."Outstanding Balance" > 50 THEN BEGIN
                            isPosted := TRUE;// flag to exit loop when loan bal is found


                            //Dr MPESA PAybill ACC
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Account No." := PaybillRecon;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine.Description := 'Paybill Loan Repayment ' + Vendor.Name;
                            GenJournalLine.Amount := amount;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            IF LoansRegister."Oustanding Interest" > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := docNo;
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Loan Interest Payment ' + Vendor.Name;
                                IF amount > LoansRegister."Oustanding Interest" THEN
                                    GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                                ELSE
                                    GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";

                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;

                                amount := amount + GenJournalLine.Amount;
                            END;

                            IF amount > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := Vendor."No.";
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Paybill Loan Repayment ' + Vendor.Name;
                                GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Loan Repayment";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;
                            END;

                            //DR Cust Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                            GenJournalLine."Account No." := Vendor."No.";
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Paybill Loan Repayment ' + Vendor.Name;
                            GenJournalLine.Amount := SurePESACharge + ExcDuty;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;



                            //CR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := exciseDutyAcc;// FORMAT(ExxcDuty);
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Excise duty-' + 'Paybill Loan Repayment ' + vendor.Name;
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //CR Surestep Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            //GenJournalLine."Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := Vendor."No.";
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine.Description := 'Paybill Loan Repayment' + ' Charges ' + Vendor.Name;
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //Post
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", batch);
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    GLPosting.RUN(GenJournalLine);
                                UNTIL GenJournalLine.NEXT = 0;
                                PaybillTrans.Posted := TRUE;
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans.Remarks := 'Posted';
                                PaybillTrans.MODIFY;
                                res := 'TRUE';
                                isPosted := TRUE;
                                msg := 'Dear ' + Members.Name + ', your payment of KES. ' + FORMAT(PaybillTrans.Amount) +
                                          ' for loan: ' + LoansRegister."Loan  No." + '-' + LoansRegister."Loan Product Type Name"
                                      + ' has been received.Thank you, POLYTECH DT SACCO Mobile.';
                                SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);

                            END ELSE BEGIN
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans."Needs Manual Posting" := TRUE;
                                PaybillTrans.Remarks := 'Failed Posting';
                                PaybillTrans.MODIFY;
                                res := 'FALSE';
                                isPosted := TRUE;
                            END;
                        END ELSE BEGIN
                            //MESSAGE('0 balance');
                            isPosted := FALSE;
                        END;//Outstanding Balance

                        IF isPosted = TRUE THEN BREAK;

                    UNTIL (LoansRegister.NEXT = 0);

                    IF isPosted = FALSE THEN BEGIN
                        PaybillTrans."Date Posted" := TODAY;
                        PaybillTrans."Needs Manual Posting" := TRUE;
                        PaybillTrans.Remarks := 'NOOUTSTANDINGBALANCE';
                        PaybillTrans.MODIFY;
                        res := 'FALSE';
                        isPosted := TRUE;
                    END;

                END ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Remarks := 'LOANNOTFOUND';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;//Loan Register

            END ELSE BEGIN
                PaybillTrans."Date Posted" := TODAY;
                PaybillTrans."Needs Manual Posting" := TRUE;
                PaybillTrans.Remarks := 'ACCNOTFOUND';
                PaybillTrans.MODIFY;
                res := 'FALSE';
            END;//Vendor;

        END ELSE BEGIN
            PaybillTrans."Date Posted" := TODAY;
            PaybillTrans."Needs Manual Posting" := TRUE;
            PaybillTrans.Remarks := 'MEMBERNOTFOUND';
            PaybillTrans.MODIFY;
            res := 'FALSE';
        END;//Member
    END;

    LOCAL PROCEDURE PayBillToFOSA(batch: Code[20]; docNo: Code[20]; accNo: Code[120]; Amount: Decimal; accountType: Code[30]) res: Code[10];
    VAR
        accNum: Text[20];
        PaybillTransTable: Record "SwizzKash MPESA Trans";
    BEGIN

        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);

            PaybillRecon := GenLedgerSetup.PayBillAcc;
            SurePESACharge := GetCharge(Amount, 'PAYBILL');
            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";

            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            //begin of deletion
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);
            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := 'Paybill Deposit';
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;
            //General Jnr Batches



            Vendor.RESET;
            Vendor.SETRANGE(Vendor."No.", accNo);
            Vendor.SETRANGE(Vendor."Account Type", accountType);
            IF Vendor.FIND('-') THEN BEGIN

                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Source No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine.Description := 'Paybill Deposit ' + Vendor.Name;
                GenJournalLine.Amount := Amount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Customer
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := Vendor."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                GenJournalLine.Description := 'Paybill Deposit ' + vendor.Name;
                GenJournalLine.Amount := -1 * Amount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Dr Customer charges
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := Vendor."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                GenJournalLine.Description := 'Paybill Deposit Charges ' + Vendor.Name;
                GenJournalLine.Amount := SurePESACharge;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //DR Excise Duty
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := Vendor."No.";
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                GenJournalLine.Description := 'Excise duty-Paybill Deposit ' + Vendor.Name;
                GenJournalLine.Amount := ExcDuty;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;


                //CR Excise Duty
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine.Description := 'Excise duty-Paybill deposit ' + vendor.Name;
                GenJournalLine.Amount := ExcDuty * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //CR Surestep Acc
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                GenJournalLine."Account No." := SurePESACommACC;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."Source No." := Vendor."No.";
                GenJournalLine."External Document No." := Vendor."No.";
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine.Description := 'Mobile Deposit Charges ' + Vendor.Name;
                GenJournalLine.Amount := -SurePESACharge;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Post
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                GenJournalLine.SETRANGE("Journal Batch Name", batch);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                    PaybillTransTable.Posted := TRUE;
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable.Remarks := 'Posted';
                    PaybillTransTable.MODIFY;
                    res := 'TRUE';
                    msg := 'Dear ' + Vendor.Name + ', Your ACC: ' + Vendor."No." + ' has been credited with KES. ' + FORMAT(Amount) +
                                ' .Thank you, POLYTECH Sacco Mobile.';
                    SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                END ELSE BEGIN
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'Failed Posting';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;

            END ELSE BEGIN//Vendor
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'Failed,FOSAACCNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//Vendor

        END;
    END;
    //this one is not in use.. its for testing the paybills
    procedure PaybillSwitch2() Result: Code[20]
    var
        thisAccNum: Code[30];
        thisKeyWord: Code[30];
        vendorTable: Record 23;
        thisDocNum: Code[30];
        thisAmount: Decimal;
        thisMemberNum: Code[30];
        strKeyWord: Text[10];
    begin
        PaybillTrans.Reset;
        PaybillTrans.SetRange(PaybillTrans.Posted, false);
        //PaybillTrans.SetRange(PaybillTrans."Account No", 'SAV04138');
        PaybillTrans.SetRange(PaybillTrans."Needs Manual Posting", false);

        if PaybillTrans.Find('-') then begin


            // check if account contains keyword and account separated by '#'
            IF STRPOS(PaybillTrans."Account No", '#') > 0 THEN BEGIN
                thisKeyWord := COPYSTR(PaybillTrans."Account No", 1, 3);
                thisAccNum := COPYSTR(PaybillTrans."Account No", 5, STRLEN(PaybillTrans."Account No") - 4);
            END ELSE BEGIN

                // check if account contains keyword and account
                strKeyWord := CheckKeyword2(PaybillTrans."Account No");
                IF NOT (strKeyWord = 'FALSE') THEN BEGIN
                    thisKeyWord := strKeyWord;
                    thisAccNum := COPYSTR(PaybillTrans."Account No", 4, STRLEN(PaybillTrans."Account No") - 3);
                END ELSE BEGIN
                    thisKeyWord := PaybillTrans."Key Word";
                    thisAccNum := PaybillTrans."Account No";
                END;

            END;
            thisDocNum := PaybillTrans."Document No";
            thisAmount := PaybillTrans.Amount;
            thisMemberNum := thisAccNum;

            //Result:=PayBillToAcc('PAYBILL',PaybillTrans."Document No",PaybillTrans."Account No",PaybillTrans."Account No",PaybillTrans.Amount,'WSS');
            case PaybillTrans."Key Word" of
                'FAD':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'BUSINESS');
                'TOT':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'TOTO');
                'ORD':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'M-WALLET');
                '010':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'M-WALLET');
                'SAV':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'M-WALLET');
                'FXD':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'FIXED');
                'CON':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'CONTROL');
                'MIC':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'MICRO SAVING');
                'SSL':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'SUPERSAVER');
                'HLD':
                    Result := PayBillToAcc2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'HOLIDAY');

                'DEP':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Deposit');
                'GSD':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Share Capital');
                'SHD':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Deposit');
                'JTD':
                    Result := PayBillToJointAccount2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Joint Deposit');
                'JTS':
                    Result := PayBillToJointAccount2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Joint Share capital');
                'SHA':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Share Capital');
                'SHC':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Share Capital');

                'GPS':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Group Deposit');
                'BVF':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Benevolent Fund');


                'EML':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'EMERGENCY');
                'ELB':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'EMERGENCY LOAN B');
                'SFL':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'SCHOOL');
                'SFB':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'SCHOOL FEES LOAN  B');
                'RFL':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'REFINANCING');
                'NML':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'NORMAL');
                'NLB':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'NORMAL LOANB');
                'IML':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'IMPORTED');
                'ES1':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'ESS_1');
                'ES2':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'ESS_2');
                'ES3':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'ESS_3');
                'ES4':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'ESS_4');
                'ES5':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'ESS_5');
                'SPL':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'SUPER');
                'SCL':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'STAFFCAR');
                'DAD':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'DIVIDENDADV');
                'TAD':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'TOPUPADV');
                '1AD':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, '1MONTHADV');
                'LAD':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'LOANADVANCE');
                'LAB':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'LOANADVANCE B');
                'OMA':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'OMA');
                'RLB':
                    Result := PaybillToFosaLoan2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'REFINANCING B');
                'CDL':
                    Result := PayBillToLoanNew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, 'CAPITAL DEVELOPMENT');

                'NON':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'Paybill to Non Member Deposit');
                'MSD':
                    Result := PayBillToBOSANew2('PAYBILL', PaybillTrans."Document No", thisAccNum, thisAccNum, PaybillTrans.Amount, PaybillTrans."Key Word", 'PayBill to Share Capital');

            end;
            if Result = '' then begin
                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Needs Manual Posting" := true;
                //PaybillTrans.Description := 'Failed';
                PaybillTrans.Modify;
            end;
        end;
    end;

    local procedure PaybillToFOSA2(batch: Code[20]; documentNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; Amount: Decimal; accountType: Code[30]) res: Text
    var
        Keyword: Text[20];
    begin
        GenLedgerSetup.Reset;
        GenLedgerSetup.Get;
        GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");
        GenLedgerSetup.TestField(GenLedgerSetup.PayBillAcc);
        PaybillRecon := GenLedgerSetup.PayBillAcc;
        SurePESACharge := GetCharge('PAYBILL', Amount);
        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        ExcDuty := (10 / 100) * (SurePESACharge);

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
            // MESSAGE(accNo);


        // Festus ----// Retrieve keyword from PaybillTrans table
        // PaybillTrans.Reset;
        // PaybillTrans.SetRange("Document No", documentNo);
        // if PaybillTrans.FindFirst then begin
        //     Keyword := PaybillTrans."Key Word";
        //     if StrPos(accNo, Keyword) = 1 then
        //         accNo := CopyStr(accNo, StrLen(Keyword) + 1);
        // end;

        Members.Reset;
        Members.SetRange(Members."No.", accNo);

        if Members.Find('-') then
            Message(Members."No.");

        Vendor.RESET;
        Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
        Vendor.SETRANGE(Vendor."Account Type", accountType);

        if Vendor.Find('-') then begin

            //Dr MPESA PAybill ACC
            LineNo := LineNo + 10000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := batch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
            GenJournalLine."Account No." := PaybillRecon;
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."External Document No." := documentNo;
            GenJournalLine."Source No." := Vendor."No.";
            GenJournalLine."Posting Date" := Today;
            GenJournalLine.Description := 'Paybill Deposit';
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
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."External Document No." := documentNo;
            GenJournalLine."Posting Date" := Today;
            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
            GenJournalLine.Description := 'Paybill Deposit';
            GenJournalLine.Amount := -1 * Amount;
            GenJournalLine.Validate(GenJournalLine.Amount);
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;

            //Dr Customer charges
            LineNo := LineNo + 10000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := batch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
            GenJournalLine."Account No." := Vendor."No.";
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."External Document No." := documentNo;
            GenJournalLine."Posting Date" := Today;
            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
            GenJournalLine.Description := 'Paybill Deposit Charges';
            GenJournalLine.Amount := SurePESACharge;
            GenJournalLine.Validate(GenJournalLine.Amount);
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;
            //DR Excise Duty
            LineNo := LineNo + 10000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := batch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
            GenJournalLine."Account No." := Vendor."No.";
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."External Document No." := documentNo;
            GenJournalLine."Posting Date" := Today;
            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
            GenJournalLine.Description := 'Excise duty-Paybill Deposit';
            GenJournalLine.Amount := ExcDuty;
            GenJournalLine.Validate(GenJournalLine.Amount);
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;


            //CR Excise Duty
            LineNo := LineNo + 10000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := batch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
            GenJournalLine."Account No." := Format(ExxcDuty);
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."External Document No." := MobileChargesACC;
            GenJournalLine."Posting Date" := Today;
            GenJournalLine.Description := 'Excise duty-Paybill deposit';
            GenJournalLine.Amount := ExcDuty * -1;
            GenJournalLine.Validate(GenJournalLine.Amount);
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;
            //CR Surestep Acc
            LineNo := LineNo + 10000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := 'GENERAL';
            GenJournalLine."Journal Batch Name" := batch;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
            GenJournalLine."Account No." := SurePESACommACC;
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Document No." := documentNo;
            GenJournalLine."Source No." := Vendor."No.";
            GenJournalLine."External Document No." := MobileChargesACC;
            GenJournalLine."Posting Date" := Today;
            GenJournalLine.Description := 'Mobile Deposit Charges';
            GenJournalLine.Amount := -SurePESACharge;
            GenJournalLine.Validate(GenJournalLine.Amount);
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;

            //Post
            GenJournalLine.Reset;
            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
            GenJournalLine.SetRange("Journal Batch Name", batch);
            if GenJournalLine.Find('-') then begin
                repeat
                // GLPosting.Run(GenJournalLine);
                until GenJournalLine.Next = 0;
                PaybillTrans.Posted := true;
                PaybillTrans."Date Posted" := Today;
                PaybillTrans.Description := 'Posted';
                PaybillTrans.Modify;
                res := 'TRUE';
                msg := 'Dear ' + Vendor.Name + ', Your ACC: ' + Vendor."No." + ' has been credited with KES. ' + Format(Amount) +
                    ' .Thank you for using POLYTECH Sacco Mobile.';
                SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
            end
            else begin
                PaybillTrans."Date Posted" := Today;
                PaybillTrans."Needs Manual Posting" := true;
                PaybillTrans.Description := 'Failed';
                PaybillTrans.Modify;
                res := 'FALSE';
            end;
        end;
        //Vendor
        //END;//Member


    end;

    local procedure PaybillToBOSA2(batch: Code[20]; documentNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]; descr: Text[100]) res: Text
    begin

        GenLedgerSetup.Reset;
        GenLedgerSetup.Get;
        GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TestField(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge('PAYBILL', amount);
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        ExcDuty := (10 / 100) * SurePESACharge;

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
            Vendor.Reset;
            Vendor.SetRange(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", fosaConst);
            if Vendor.FindFirst then begin

                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := documentNo;
                GenJournalLine."External Document No." := documentNo;
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
                GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                GenJournalLine."Account No." := accNo;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := documentNo;
                GenJournalLine."External Document No." := documentNo;
                GenJournalLine."Posting Date" := Today;
                case PaybillTrans."Key Word" of
                    'MSD':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Shares Capital";
                end;
                case PaybillTrans."Key Word" of
                    'GSD':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                end;
                case PaybillTrans."Key Word" of
                    'SHC':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Shares Capital";
                end;
                case PaybillTrans."Key Word" of
                    'BVF':
                        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Benevolent Fund";
                end;
                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Description := descr;
                GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                //CR Excise Duty
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                GenJournalLine."Account No." := Format(ExxcDuty);
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := documentNo;
                GenJournalLine."External Document No." := documentNo;
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := 'Excise duty-' + descr;
                GenJournalLine.Amount := ExcDuty * -1;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                //CR Surestep Acc
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                GenJournalLine."Account No." := SurePESACommACC;
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := documentNo;
                GenJournalLine."External Document No." := documentNo;
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := descr + ' Charges';
                GenJournalLine.Amount := -SurePESACharge;
                GenJournalLine.Validate(GenJournalLine.Amount);
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;

                //Post
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                GenJournalLine.SetRange("Journal Batch Name", batch);
                if GenJournalLine.Find('-') then begin
                    repeat
                    // GLPosting.Run(GenJournalLine);
                    until GenJournalLine.Next = 0;
                    PaybillTrans.Posted := true;
                    PaybillTrans."Date Posted" := Today;
                    PaybillTrans.Description := 'Posted';
                    PaybillTrans.Modify;
                    res := 'TRUE';
                    msg := 'Dear ' + Members.Name + ', Your ACC: ' + accNo + ' has been credited with KES. ' + Format(amount) +
                             ' .Thank you for using POLYTECH Sacco Mobile.';
                    SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                end
                else begin
                    PaybillTrans."Date Posted" := Today;
                    PaybillTrans."Needs Manual Posting" := true;
                    PaybillTrans.Description := 'Failed';
                    PaybillTrans.Modify;
                    res := 'FALSE';
                end;
            end;//Vendor
        end;//Member


    end;

    local procedure PaybillToLoan2(batch: Code[20]; documentNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]) res: Text
    begin
        GenLedgerSetup.Reset;
        GenLedgerSetup.Get;
        GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TestField(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge('PAYBILL', amount);
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        ExcDuty := (10 / 100) * SurePESACharge;

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

        Members.Reset;
        Members.SetRange(Members."No.", accNo);
        if Members.Find('-') then begin
            Vendor.Reset;
            Vendor.SetRange(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            if Vendor.Find('-') then begin

                LoansRegister.Reset;
                LoansRegister.SetRange(LoansRegister."Loan Product Type", type);
                LoansRegister.SetRange(LoansRegister."Client Code", Members."No.");

                if LoansRegister.Find('+') then begin
                    LoansRegister.CalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                    if (LoansRegister."Outstanding Balance" > 0) or (LoansRegister."Oustanding Interest" > 0) then begin
                        //Dr MPESA PAybill ACC
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := batch;
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                        GenJournalLine."Account No." := PaybillRecon;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := documentNo;
                        GenJournalLine."External Document No." := documentNo;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Source No." := Vendor."No.";
                        GenJournalLine.Description := 'Paybill Loan Repayment';
                        GenJournalLine.Amount := amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                        //Any Charges CR Them start

                        //Any Charges CR  Them stop
                        //Interest
                        if LoansRegister."Oustanding Interest" > 0 then begin
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                            GenJournalLine."Account No." := LoansRegister."Client Code";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentNo;
                            GenJournalLine."External Document No." := documentNo;
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
                        end;
                        amount := amount + GenJournalLine.Amount;
                        //Principal
                        if amount > 0 then begin
                            if LoansRegister."Outstanding Balance" > 0 then begin
                                LineNo := LineNo + 10000;
                                GenJournalLine.Init;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := documentNo;
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
                        end;
                        //Overpayment
                        //...............Incse of excess Amount deposit to NWD start
                        amount := amount + GenJournalLine.Amount;
                        if amount > 0 then begin
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                            GenJournalLine."Account No." := LoansRegister."Client Code";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := documentNo;
                            GenJournalLine."External Document No." := '';
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Paybill Loan Repayment-Excess';
                            GenJournalLine.Amount := -amount;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                            if GenJournalLine."Shortcut Dimension 1 Code" = '' then begin
                                GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                            end;
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;
                        end;
                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                        GenJournalLine.SetRange("Journal Batch Name", batch);
                        if GenJournalLine.Find('-') then begin
                            repeat
                            // GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                            PaybillTrans.Posted := true;
                            PaybillTrans."Date Posted" := Today;
                            PaybillTrans.Description := 'Posted';
                            PaybillTrans.Modify;
                            res := 'TRUE';
                            msg := 'Dear ' + Members.Name + ' loan: ' + LoansRegister."Loan  No." + ' has been credited with KES. ' + Format(LoanAmt) +
                                     ' .Thank you for using POLYTECH Sacco Mobile.';
                            SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                        end else begin
                            PaybillTrans."Date Posted" := Today;
                            PaybillTrans."Needs Manual Posting" := true;
                            PaybillTrans.Description := 'Failed';
                            PaybillTrans.Modify;
                            res := 'FALSE';
                        end;
                    end;//LoansRegister."Outstanding Balance"+LoansRegister."Oustanding Interest"
                end;//Loan Register
            end;//Vendor
        end;//Member


    end;

    LOCAL PROCEDURE PayBillToAcc2(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; Amount: Decimal; accountType: Code[30]) res: Code[10];
    VAR
        accNum: Text[20];
        PaybillTransTable: Record "SwizzKash MPESA Trans";
        exciseDutyAcc: Code[30];
    BEGIN

        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);

            PaybillRecon := GenLedgerSetup.PayBillAcc;
            SurePESACharge := GetCharge(Amount, 'PAYBILL');
            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";

            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            //begin of deletion
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);
            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := 'Paybill Deposit';
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;
            //General Jnr Batches

            //accNum:=COPYSTR(accNo,4,100);
            //MESSAGE(accNo);

            Members.RESET;
            Members.SETRANGE(Members."No.", accNo);
            IF Members.FIND('-') THEN BEGIN

                //MESSAGE(Members."No.");

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                Vendor.SETRANGE(Vendor."Account Type", accountType);
                IF Vendor.FIND('-') THEN BEGIN

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Paybill Deposit';
                    GenJournalLine.Amount := Amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                    GenJournalLine.Description := 'Paybill Deposit';
                    GenJournalLine.Amount := -1 * Amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Dr Customer charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                    GenJournalLine.Description := 'Paybill Deposit Charges';
                    GenJournalLine.Amount := SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //DR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                    GenJournalLine.Description := 'Excise duty-Paybill Deposit';
                    GenJournalLine.Amount := ExcDuty;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-Paybill deposit';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Mobile Deposit Charges';
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Vendor.Name + ', Your ACC: ' + Vendor."No." + ' has been credited with KES. ' + FORMAT(Amount) +
                                    ' .Thank you, POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN//Vendor
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'Failed,FOSAACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor

            END ELSE BEGIN// Member
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'Failed,MEMBERACCNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//
        END;
    END;

    LOCAL PROCEDURE PayBillToBOSANew2(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]; descr: Text[100]) res: Code[10];
    VAR
        PaybillTransTable: Record "SwizzKash MPESA Trans";
        exciseDutyAcc: Code[30];
    BEGIN
        //MESSAGE('in bosa, accno %1',accNo);
        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN
            //MESSAGE('in bosa doc search');
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SurePESACharge := GetCharge(amount, 'PAYBILL');
            PaybillRecon := GenLedgerSetup.PayBillAcc;


            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);

            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;//General Jnr Batches
                //..........................................................................................................
            IF type = 'NON' THEN BEGIN
                //Dr MPESA PAybill ACC
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                GenJournalLine."Account No." := PaybillRecon;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine.Description := descr;
                GenJournalLine.Amount := amount;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                //Cr Customer
                LineNo := LineNo + 10000;
                GenJournalLine.INIT;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := batch;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                GenJournalLine."Account No." := accNo;
                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                GenJournalLine."Document No." := docNo;
                GenJournalLine."External Document No." := docNo;
                GenJournalLine."Posting Date" := TODAY;
                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Description := descr;
                GenJournalLine.Amount := (amount) * -1;
                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                IF GenJournalLine.Amount <> 0 THEN
                    GenJournalLine.INSERT;

                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                GenJournalLine.SETRANGE("Journal Batch Name", batch);
                IF GenJournalLine.FIND('-') THEN BEGIN
                    REPEAT
                        GLPosting.RUN(GenJournalLine);
                    UNTIL GenJournalLine.NEXT = 0;
                    PaybillTrans.Posted := TRUE;
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans.Description := 'Posted';
                    PaybillTrans.MODIFY;
                    res := 'TRUE';
                END
                ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Description := 'Failed Posting';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;
                EXIT;
            END;
            //............................................................................................................
            Members.RESET;
            IF (accNo = 'DEPOSIT CONTRIBUTION') OR (accNo = 'SHARE CAPITAL') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE("Mobile Phone No", '0' + COPYSTR(PaybillTransTable.Telephone, STRLEN(PaybillTransTable.Telephone) - 8, 9));
                IF Vendor.FIND('-') THEN BEGIN
                    //MESSAGE('found phone '+PaybillTransTable.Telephone+' mno ' +Vendor."BOSA Account No"+' '+Vendor.Name );
                    Members.SETRANGE("No.", Vendor."BOSA Account No");
                END ELSE BEGIN
                    Members.SETRANGE("No.", accNo);
                END;
            END ELSE BEGIN
                Members.SETRANGE("No.", accNo);
            END;

            IF Members.FIND('-') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                // Vendor.SETRANGE(Vendor."Account Type", fosaConst);
                IF Vendor.FIND('-') THEN BEGIN

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Account No." := Members."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    //MESSAGE('Test keyword type %1',PaybillTransTable."Key Word");
                    CASE UPPERCASE(PaybillTransTable."Key Word") OF
                        'MSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHC':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHA':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'JTS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'GSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'GPS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'SHD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'DEP':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'JTD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'BVF':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Benevolent Fund";
                    END;
                    // MESSAGE('Test transaction type %1',GenJournalLine."Transaction Type");
                    //        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
                    //        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");

                    IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                        GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    END;

                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-' + descr;
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr + ' Charges';
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Members.Name + ', Your ACC: ' + accNo + ' has been credited with KES. ' + FORMAT(amount) +
                                  ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'ACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor;

            END ELSE BEGIN
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'MEMBERNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//Member

        END;
    END;

    LOCAL PROCEDURE PayBillToJointAccount2(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]; descr: Text[100]) res: Code[10];
    VAR
        PaybillTransTable: Record "SwizzKash MPESA Trans";
        exciseDutyAcc: Code[30];
    BEGIN
        //MESSAGE('in bosa, accno %1',accNo);
        PaybillTransTable.RESET;
        PaybillTransTable.SETRANGE("Document No", docNo);
        PaybillTransTable.SETRANGE(Posted, FALSE);
        IF PaybillTransTable.FIND('-') THEN BEGIN
            //MESSAGE('in bosa doc search');
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
            SurePESACharge := GetCharge(amount, 'PAYBILL');
            PaybillRecon := GenLedgerSetup.PayBillAcc;


            exciseDutyAcc := GetExciseDutyAccount();
            ExcDuty := GetExciseDutyRate() * (SurePESACharge);

            GenJournalLine.RESET;
            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE("Journal Batch Name", batch);
            GenJournalLine.DELETEALL;
            //end of deletion

            GenBatches.RESET;
            GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
            GenBatches.SETRANGE(GenBatches.Name, batch);

            IF GenBatches.FIND('-') = FALSE THEN BEGIN
                GenBatches.INIT;
                GenBatches."Journal Template Name" := 'GENERAL';
                GenBatches.Name := batch;
                GenBatches.Description := descr;
                GenBatches.VALIDATE(GenBatches."Journal Template Name");
                GenBatches.VALIDATE(GenBatches.Name);
                GenBatches.INSERT;
            END;//General Jnr Batches

            Members.RESET;
            IF (accNo = 'DEPOSIT CONTRIBUTION') OR (accNo = 'SHARE CAPITAL') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE("Mobile Phone No", '0' + COPYSTR(PaybillTransTable.Telephone, STRLEN(PaybillTransTable.Telephone) - 8, 9));
                IF Vendor.FIND('-') THEN BEGIN
                    //MESSAGE('found phone '+PaybillTransTable.Telephone+' mno ' +Vendor."BOSA Account No"+' '+Vendor.Name );
                    Members.SETRANGE("No.", Vendor."BOSA Account No");
                END ELSE BEGIN
                    Members.SETRANGE("No.", accNo);
                    Members.SETRANGE(Members."Account Category", Members."Account Category"::Joint);
                END;
            END ELSE BEGIN
                Members.SETRANGE("No.", accNo);
                Members.SETRANGE(Members."Account Category", Members."Account Category"::Joint);
            END;

            IF Members.FIND('-') THEN BEGIN

                Vendor.RESET;
                Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
                // Vendor.SETRANGE(Vendor."Account Type", fosaConst);
                IF Vendor.FIND('-') THEN BEGIN

                    //Dr MPESA PAybill ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := PaybillRecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Customer
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Account No." := Members."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    //MESSAGE('Test keyword type %1',PaybillTransTable."Key Word");
                    CASE UPPERCASE(PaybillTransTable."Key Word") OF
                        'MSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        //'SHC': GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'SHA':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'JTS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Shares Capital";
                        'GSD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'GPS':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        //'SHD': GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'DEP':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'JTD':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
                        'BVF':
                            GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Benevolent Fund";
                    END;
                    // MESSAGE('Test transaction type %1',GenJournalLine."Transaction Type");
                    //        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
                    //        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");

                    IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                        GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    END;

                    GenJournalLine.Description := descr;
                    GenJournalLine.Amount := (amount - SurePESACharge - ExcDuty) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := exciseDutyAcc;//FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'Excise duty-' + descr;
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := batch;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := descr + ' Charges';
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", batch);
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                        PaybillTransTable.Posted := TRUE;
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable.Remarks := 'Posted';
                        PaybillTransTable.MODIFY;
                        res := 'TRUE';
                        msg := 'Dear ' + Members.Name + ', Your ACC: ' + accNo + ' has been credited with KES. ' + FORMAT(amount) +
                                  ' .Thank you for using POLYTECH Sacco Mobile.';
                        SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);
                    END ELSE BEGIN
                        PaybillTransTable."Date Posted" := TODAY;
                        PaybillTransTable."Needs Manual Posting" := TRUE;
                        PaybillTransTable.Remarks := 'Failed Posting';
                        PaybillTransTable.MODIFY;
                        res := 'FALSE';
                    END;

                END ELSE BEGIN
                    PaybillTransTable."Date Posted" := TODAY;
                    PaybillTransTable."Needs Manual Posting" := TRUE;
                    PaybillTransTable.Remarks := 'ACCNOTFOUND';
                    PaybillTransTable.MODIFY;
                    res := 'FALSE';
                END;//Vendor;

            END ELSE BEGIN
                PaybillTransTable."Date Posted" := TODAY;
                PaybillTransTable."Needs Manual Posting" := TRUE;
                PaybillTransTable.Remarks := 'MEMBERNOTFOUND';
                PaybillTransTable.MODIFY;
                res := 'FALSE';
            END;//Member

        END;
    END;

    LOCAL PROCEDURE PayBillToLoanNew2(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]) res: Code[10];
    VAR
        isPosted: Boolean;
        runningBalance: Decimal;
        exciseDutyAcc: Code[30];
    BEGIN
        GenLedgerSetup.RESET;
        GenLedgerSetup.GET;
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge(amount, 'PAYBILL');
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        exciseDutyAcc := GetExciseDutyAccount();
        ExcDuty := GetExciseDutyRate() * (SurePESACharge);

        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        GenJournalLine.SETRANGE("Journal Batch Name", batch);
        GenJournalLine.DELETEALL;
        //end of deletion



        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SETRANGE(GenBatches.Name, batch);

        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Paybill Loan Repayment';
            GenBatches.VALIDATE(GenBatches."Journal Template Name");
            GenBatches.VALIDATE(GenBatches.Name);
            GenBatches.INSERT;
        END;//General Jnr Batches



        Members.RESET;
        Members.SETRANGE(Members."No.", accNo);
        IF Members.FIND('-') THEN BEGIN


            //MESSAGE('member %1 ln %2', Members.Name,type);

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Loan Product Type", type);
                LoansRegister.SETRANGE(LoansRegister."Client Code", Members."No.");
                IF LoansRegister.FIND('-') THEN BEGIN
                    isPosted := FALSE;
                    //MESSAGE('found %1',LoansRegister."Loan  No.");
                    REPEAT

                        LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");

                        //MESSAGE('outbal %1',LoansRegister."Outstanding Balance");

                        IF LoansRegister."Outstanding Balance" > 50 THEN BEGIN
                            isPosted := TRUE;// flag to exit loop when loan bal is found


                            //Dr MPESA PAybill ACC
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Account No." := PaybillRecon;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine.Description := 'Paybill Loan Repayment';
                            GenJournalLine.Amount := amount;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            IF LoansRegister."Oustanding Interest" > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := docNo;
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Loan Interest Payment';
                                IF amount > LoansRegister."Oustanding Interest" THEN
                                    GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                                ELSE
                                    GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";

                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;

                                amount := amount + GenJournalLine.Amount;
                            END;

                            IF amount > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Paybill Loan Repayment';
                                GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Loan Repayment";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;
                            END;

                            //DR Cust Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                            GenJournalLine."Account No." := Vendor."No.";
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Paybill Loan Repayment';
                            GenJournalLine.Amount := SurePESACharge + ExcDuty;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;


                            //CR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := exciseDutyAcc;// FORMAT(ExxcDuty);
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Excise duty-' + 'Paybill Loan Repayment';
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //CR Surestep Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine.Description := 'Paybill Loan Repayment' + ' Charges';
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //Post
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", batch);
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    GLPosting.RUN(GenJournalLine);
                                UNTIL GenJournalLine.NEXT = 0;
                                PaybillTrans.Posted := TRUE;
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans.Remarks := 'Posted';
                                PaybillTrans.MODIFY;
                                res := 'TRUE';
                                isPosted := TRUE;
                                msg := 'Dear ' + Members.Name + ', your payment of KES. ' + FORMAT(PaybillTrans.Amount) +
                                          ' for loan: ' + LoansRegister."Loan  No." + '-' + LoansRegister."Loan Product Type Name"
                                      + ' has been received.Thank you, POLYTECH DT SACCO Mobile.';
                                SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);

                            END ELSE BEGIN
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans."Needs Manual Posting" := TRUE;
                                PaybillTrans.Remarks := 'Failed Posting';
                                PaybillTrans.MODIFY;
                                res := 'FALSE';
                                isPosted := TRUE;
                            END;
                        END ELSE BEGIN
                            //MESSAGE('0 balance');
                            isPosted := FALSE;
                        END;//Outstanding Balance

                        IF isPosted = TRUE THEN BREAK;

                    UNTIL (LoansRegister.NEXT = 0);

                    IF isPosted = FALSE THEN BEGIN
                        PaybillTrans."Date Posted" := TODAY;
                        PaybillTrans."Needs Manual Posting" := TRUE;
                        PaybillTrans.Remarks := 'NOOUTSTANDINGBALANCE';
                        PaybillTrans.MODIFY;
                        res := 'FALSE';
                        isPosted := TRUE;
                    END;

                END ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Remarks := 'LOANNOTFOUND';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;//Loan Register

            END ELSE BEGIN
                PaybillTrans."Date Posted" := TODAY;
                PaybillTrans."Needs Manual Posting" := TRUE;
                PaybillTrans.Remarks := 'ACCNOTFOUND';
                PaybillTrans.MODIFY;
                res := 'FALSE';
            END;//Vendor;

        END ELSE BEGIN
            PaybillTrans."Date Posted" := TODAY;
            PaybillTrans."Needs Manual Posting" := TRUE;
            PaybillTrans.Remarks := 'MEMBERNOTFOUND';
            PaybillTrans.MODIFY;
            res := 'FALSE';
        END;//Member
    END;

    LOCAL PROCEDURE PaybillToFosaLoan2(batch: Code[20]; docNo: Code[20]; accNo: Code[20]; memberNo: Code[20]; amount: Decimal; type: Code[30]) res: Code[10];
    VAR
        isPosted: Boolean;
        runningBalance: Decimal;
        exciseDutyAcc: Code[30];
    BEGIN
        GenLedgerSetup.RESET;
        GenLedgerSetup.GET;
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
        GenLedgerSetup.TESTFIELD(GenLedgerSetup.PayBillAcc);
        GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

        SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
        SurePESACharge := GetCharge(amount, 'PAYBILL');
        PaybillRecon := GenLedgerSetup.PayBillAcc;

        exciseDutyAcc := GetExciseDutyAccount();
        ExcDuty := GetExciseDutyRate() * (SurePESACharge);

        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        GenJournalLine.SETRANGE("Journal Batch Name", batch);
        GenJournalLine.DELETEALL;
        //end of deletion



        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
        GenBatches.SETRANGE(GenBatches.Name, batch);

        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'GENERAL';
            GenBatches.Name := batch;
            GenBatches.Description := 'Paybill Loan Repayment';
            GenBatches.VALIDATE(GenBatches."Journal Template Name");
            GenBatches.VALIDATE(GenBatches.Name);
            GenBatches.INSERT;
        END;//General Jnr Batches



        Members.RESET;
        Members.SETRANGE(Members."No.", accNo);
        IF Members.FIND('-') THEN BEGIN


            //MESSAGE('member %1 ln %2', Members.Name,type);

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."BOSA Account No", Members."No.");
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Loan Product Type", type);
                LoansRegister.SETRANGE(LoansRegister."Client Code", Vendor."No.");
                IF LoansRegister.FIND('-') THEN BEGIN
                    isPosted := FALSE;
                    //MESSAGE('found %1',LoansRegister."Loan  No.");
                    REPEAT

                        LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");

                        //MESSAGE('outbal %1',LoansRegister."Outstanding Balance");

                        IF LoansRegister."Outstanding Balance" > 50 THEN BEGIN
                            isPosted := TRUE;// flag to exit loop when loan bal is found


                            //Dr MPESA PAybill ACC
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Account No." := PaybillRecon;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine.Description := 'Paybill Loan Repayment';
                            GenJournalLine.Amount := amount;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            IF LoansRegister."Oustanding Interest" > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := docNo;
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Loan Interest Payment';
                                IF amount > LoansRegister."Oustanding Interest" THEN
                                    GenJournalLine.Amount := -LoansRegister."Oustanding Interest"
                                ELSE
                                    GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";

                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;

                                amount := amount + GenJournalLine.Amount;
                            END;

                            IF amount > 0 THEN BEGIN
                                LineNo := LineNo + 10000;
                                GenJournalLine.INIT;
                                GenJournalLine."Journal Template Name" := 'GENERAL';
                                GenJournalLine."Journal Batch Name" := batch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                                GenJournalLine."Account No." := LoansRegister."Client Code";
                                GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                GenJournalLine."Document No." := docNo;
                                GenJournalLine."External Document No." := '';
                                GenJournalLine."Posting Date" := TODAY;
                                GenJournalLine.Description := 'Paybill Loan Repayment';
                                GenJournalLine.Amount := -amount;
                                GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Loan Repayment";
                                IF GenJournalLine."Shortcut Dimension 1 Code" = '' THEN BEGIN
                                    GenJournalLine."Shortcut Dimension 1 Code" := Members."Global Dimension 1 Code";
                                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                                END;
                                GenJournalLine."Loan No" := LoansRegister."Loan  No.";
                                IF GenJournalLine.Amount <> 0 THEN
                                    GenJournalLine.INSERT;
                            END;

                            //DR Cust Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                            GenJournalLine."Account No." := Vendor."No.";
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Paybill Loan Repayment';
                            GenJournalLine.Amount := SurePESACharge + ExcDuty;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //CR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := exciseDutyAcc;// FORMAT(ExxcDuty);
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine.Description := 'Excise duty-' + 'Paybill Loan Repayment';
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //CR Surestep Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := batch;
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := docNo;
                            GenJournalLine."External Document No." := docNo;
                            GenJournalLine."Posting Date" := TODAY;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine.Description := 'Paybill Loan Repayment' + ' Charges';
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                            IF GenJournalLine.Amount <> 0 THEN
                                GenJournalLine.INSERT;

                            //Post
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                            GenJournalLine.SETRANGE("Journal Batch Name", batch);
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                REPEAT
                                    GLPosting.RUN(GenJournalLine);
                                UNTIL GenJournalLine.NEXT = 0;
                                PaybillTrans.Posted := TRUE;
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans.Remarks := 'Posted';
                                PaybillTrans.MODIFY;
                                res := 'TRUE';
                                isPosted := TRUE;
                                msg := 'Dear ' + Members.Name + ', your payment of KES. ' + FORMAT(PaybillTrans.Amount) +
                                          ' for loan: ' + LoansRegister."Loan  No." + '-' + LoansRegister."Loan Product Type Name"
                                      + ' has been received.Thank you, POLYTECH DT SACCO Mobile.';
                                SMSMessage('PAYBILL', Vendor."No.", Vendor."Phone No.", msg);

                            END ELSE BEGIN
                                PaybillTrans."Date Posted" := TODAY;
                                PaybillTrans."Needs Manual Posting" := TRUE;
                                PaybillTrans.Remarks := 'Failed Posting';
                                PaybillTrans.MODIFY;
                                res := 'FALSE';
                                isPosted := TRUE;
                            END;
                        END ELSE BEGIN
                            //MESSAGE('0 balance');
                            isPosted := FALSE;
                        END;//Outstanding Balance

                        IF isPosted = TRUE THEN BREAK;

                    UNTIL (LoansRegister.NEXT = 0);

                    IF isPosted = FALSE THEN BEGIN
                        PaybillTrans."Date Posted" := TODAY;
                        PaybillTrans."Needs Manual Posting" := TRUE;
                        PaybillTrans.Remarks := 'NOOUTSTANDINGBALANCE';
                        PaybillTrans.MODIFY;
                        res := 'FALSE';
                        isPosted := TRUE;
                    END;

                END ELSE BEGIN
                    PaybillTrans."Date Posted" := TODAY;
                    PaybillTrans."Needs Manual Posting" := TRUE;
                    PaybillTrans.Remarks := 'LOANNOTFOUND';
                    PaybillTrans.MODIFY;
                    res := 'FALSE';
                END;//Loan Register

            END ELSE BEGIN
                PaybillTrans."Date Posted" := TODAY;
                PaybillTrans."Needs Manual Posting" := TRUE;
                PaybillTrans.Remarks := 'ACCNOTFOUND';
                PaybillTrans.MODIFY;
                res := 'FALSE';
            END;//Vendor;

        END ELSE BEGIN
            PaybillTrans."Date Posted" := TODAY;
            PaybillTrans."Needs Manual Posting" := TRUE;
            PaybillTrans.Remarks := 'MEMBERNOTFOUND';
            PaybillTrans.MODIFY;
            res := 'FALSE';
        END;//Member
    END;

    LOCAL PROCEDURE GetExciseDutyAccount() response: Code[20];
    VAR
        SaccoGenSetUpTable: Record "Sacco General Set-Up";
    BEGIN
        SaccoGenSetUpTable.RESET;
        SaccoGenSetUpTable.GET;
        SaccoGenSetUpTable.TESTFIELD("Excise Duty Account");
        response := SaccoGenSetUpTable."Excise Duty Account";
        EXIT(response);
    END;

    LOCAL PROCEDURE GetExciseDutyRate() response: Decimal;
    VAR
        SaccoGenSetUpTable: Record "Sacco General Set-Up";
    BEGIN
        SaccoGenSetUpTable.RESET;
        SaccoGenSetUpTable.GET;
        SaccoGenSetUpTable.TESTFIELD("Excise Duty(%)");
        response := SaccoGenSetUpTable."Excise Duty(%)" / 100;
        EXIT(response);
    END;

    LOCAL PROCEDURE GetCharge(amount: Decimal; code: Text[20]) charge: Decimal;
    BEGIN
        TariffDetails.RESET;
        TariffDetails.SETRANGE(TariffDetails.Code, code);
        TariffDetails.SETFILTER(TariffDetails."Lower Limit", '<=%1', amount);
        TariffDetails.SETFILTER(TariffDetails."Upper Limit", '>=%1', amount);
        IF TariffDetails.FIND('-') THEN BEGIN
            charge := TariffDetails."Charge Amount";
        END
    END;

    LOCAL PROCEDURE GetLoanLimit(phonenumber: text[100]; loancode: Text[50]) response: Text
    VAR
        StoDedAmount: Decimal;
        STO: Record "Standing Order Register";
        FOSALoanRepayAmount: Decimal;
        CumulativeNet: Decimal;
        LastSalaryDate: Date;
        FirstSalaryDate: Date;
        AvarageNetPay: Decimal;
        AdvQualificationAmount: Decimal;
        CumulativeNet2: Decimal;
        finalAmount: Decimal;
        interestAMT: Decimal;
        MaxLoanAmt: Decimal;
        LastPaydate: Date;
        MPayDate: Decimal;
        MToday: Decimal;
        DateRegistered: Date;
        MtodayYear: Decimal;
        RegYear: Decimal;
        MtodayDiff: Decimal;
        MRegdate: Decimal;
        ComittedShares: Decimal;
        LoanGuarantors: Record "Loans Guarantee Details";
        FreeShares: Decimal;
        TotalAmount: Decimal;
        TransactionLoanAmt: Decimal;
        TransactionLoanDiff: Decimal;
        RepayedLoanAmt: Decimal;
        LoanRepaymentS: Record "Loan Repayment Schedule";
        Fulldate: Date;
        LastRepayDate: Date;
        PrincipalAmount: Decimal;
        countTrans: Integer;
        amount: Decimal;
        vendorTable: Record Vendor;
        membersTable: Record Customer;
        memberledgerentryTable: Record "Cust. Ledger Entry";
        limitAmount: Decimal;
        maxLoanAmount: Decimal;
        minLoanAmount: Decimal;
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"ERROR","LimitAmount":0,"Message":"Error-Could not determine limit" } ';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group", 'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN

            // ======= must be member for 6 months
            Members.RESET;
            Members.SETRANGE(Members."No.", vendorTable."BOSA Account No");
            IF NOT Members.FIND('-') THEN BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"FAIL","LimitAmount":0,"Message":"Must be a member atleast 6 months" } ';
                EXIT(response);
            END;

            DateRegistered := Members."Registration Date";

            // ===== no registration date
            IF DateRegistered = 0D THEN BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"FAIL","LimitAmount":0,"Message":"Must be a member atleast 6 months" } ';
                EXIT(response);
            END;

            MtodayYear := DATE2DMY(TODAY, 3);
            RegYear := DATE2DMY(DateRegistered, 3);
            MRegdate := DATE2DMY(DateRegistered, 2);
            MToday := DATE2DMY(TODAY, 2) + MRegdate;
            IF MToday < 6 THEN BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"FAIL","LimitAmount":0,"Message":"Must be a member atleast 6 months" } ';
                EXIT(response);
            END;
            // ===== end 6 months membership check




            // ===== must not be a defaulter
            Members.RESET;
            Members.SETRANGE(Members."No.", Vendor."BOSA Account No");
            IF Members.FIND('-') THEN BEGIN
                LoansRegister.RESET;
                LoansRegister.SETRANGE(LoansRegister."Client Code", Vendor."BOSA Account No");
                IF LoansRegister.FIND('-') THEN BEGIN
                    REPEAT
                        IF (LoansRegister."Loans Category-SASRA" = LoansRegister."Loans Category-SASRA"::Substandard)
                          OR (LoansRegister."Loans Category-SASRA" = LoansRegister."Loans Category-SASRA"::Loss)
                          OR (LoansRegister."Loans Category-SASRA" = LoansRegister."Loans Category-SASRA"::Doubtful) THEN BEGIN
                            response := '{ "StatusCode":"3","StatusDescription":"FAIL","LimitAmount":0,"Message":"Must not be a defaulter" } ';
                            EXIT(response);
                        END;
                    UNTIL LoansRegister.NEXT = 0;
                END;
            END;
            // ===== end must not be a defaulter



            // ===== is under probation (penalty)?
            //   MpesaDisbus.RESET;
            //   MpesaDisbus.SETCURRENTKEY(MpesaDisbus."Entry No");
            //   MpesaDisbus.ASCENDING(FALSE);
            //   MpesaDisbus.SETRANGE(MpesaDisbus."Member No",vendorTable."BOSA Account No");
            //   IF  MpesaDisbus.FIND('-') THEN BEGIN
            //     IF MpesaDisbus."Penalty Date"<>0D THEN BEGIN
            //       IF (TODAY<= CALCDATE('3M', MpesaDisbus."Penalty Date")) THEN BEGIN
            //         response:='{ "StatusCode":"4","StatusDescription":"FAIL","LimitAmount":0,"Message":"You were penalized for deliquency" } ';
            //         EXIT(response);
            //       END;
            //     END;
            //   END;
            // ===== end is under probation (penalty)?



            // * ===== must be active for atleast 3 months (making deposits for the last 3 months) ======= * //
            //    countTrans:=0;
            //    MemberLedgerEntry.RESET;
            //    MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.",vendorTable."BOSA Account No");
            //    MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Transaction Type",MemberLedgerEntry."Transaction Type"::"Deposit Contribution");
            //    MemberLedgerEntry.SETFILTER(MemberLedgerEntry."Posting Date", FORMAT(CALCDATE('CM+1D-4M', TODAY))+'..'+FORMAT(CALCDATE('CM',TODAY)));
            //    MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Posting Date");
            //    MemberLedgerEntry.ASCENDING(FALSE);
            //    IF MemberLedgerEntry.FIND('-') THEN BEGIN
            //      REPEAT
            //
            //        MemberLedgerEntry2.RESET;
            //        MemberLedgerEntry2.SETRANGE(MemberLedgerEntry2."Customer No.", Members."No.");
            //        MemberLedgerEntry2.SETRANGE(MemberLedgerEntry2."Transaction Type",MemberLedgerEntry."Transaction Type"::"Deposit Contribution");
            //        MemberLedgerEntry2.SETRANGE(MemberLedgerEntry2."Posting Date",MemberLedgerEntry."Posting Date");
            //        MemberLedgerEntry2.SETFILTER(MemberLedgerEntry2.Description,'<>%1','Opening Balance');
            //        MemberLedgerEntry2.SETFILTER(MemberLedgerEntry2."Credit Amount",'>%1',0);
            //        IF MemberLedgerEntry2.FINDLAST THEN BEGIN
            //          countTrans:=countTrans+1;
            //        END;
            //
            //      UNTIL MemberLedgerEntry.NEXT=0;
            //    END;
            //    IF (countTrans<3) THEN BEGIN
            //      response:='{ "StatusCode":"5","StatusDescription":"FAIL","LimitAmount":0,"Message":"Must have contributed consistently for the last 3 months" } ';
            //      EXIT(response);
            //    END;
            // * ===== end must be active for atleast 3 months (making deposits for the last 3 months)




            // ===== Check if member has an outstanding ELOAN
            LoansRegister.RESET;
            LoansRegister.SETRANGE(LoansRegister."Client Code", vendorTable."BOSA Account No");
            LoansRegister.SETRANGE(LoansRegister."Product Code", 'ELOAN');
            LoansRegister.SETRANGE(LoansRegister.Posted, TRUE);
            IF LoansRegister.FIND('-') THEN BEGIN
                REPEAT
                    LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance");
                    IF (LoansRegister."Outstanding Balance" > 0) THEN BEGIN
                        IF (LoansRegister."Loan Product Type" = 'ELOAN') THEN BEGIN
                            response := '{ "StatusCode":"6","StatusDescription":"FAIL","LimitAmount":0,"Message":"Outstanding E-Loan Balance" }';
                            EXIT(response);
                        END;
                    END;
                UNTIL LoansRegister.NEXT = 0;
            END;
            // ===== END Check if member has an outstanding ELOAN



            // ***************  BOSA BALANCES  ****************** //

            amount := 0;

            // =====  share capital >=2000?
            memberledgerentryTable.RESET;
            memberledgerentryTable.SETRANGE(memberledgerentryTable."Customer No.", vendorTable."BOSA Account No");
            memberledgerentryTable.SETRANGE(memberledgerentryTable."Transaction Type", memberledgerentryTable."Transaction Type"::"Shares Capital");
            IF memberledgerentryTable.FIND('-') THEN BEGIN
                REPEAT
                    amount := amount + (memberledgerentryTable.Amount * -1);
                UNTIL memberledgerentryTable.NEXT = 0;
            END;
            //MESSAGE('sc > %1',amount);
            IF amount < 2000 THEN BEGIN
                response := '{ "StatusCode":"7","StatusDescription":"FAIL","LimitAmount":0,"Message":"Share Capital Balance less than 2,000" }';
                EXIT(response);
            END;
            // ===== end share capital >=2000?

            // =====  share deposits >=5000?
            amount := 0;
            //    memberledgerentryTable.RESET;
            //    memberledgerentryTable.SETRANGE(memberledgerentryTable."Customer No.",vendorTable."BOSA Account No");
            //    memberledgerentryTable.SETRANGE(memberledgerentryTable."Transaction Type",memberledgerentryTable."Transaction Type"::"Deposit Contribution");
            //    IF memberledgerentryTable.FIND('-') THEN BEGIN
            //      REPEAT
            //        amount:=amount+(memberledgerentryTable.Amount*-1);
            //      UNTIL memberledgerentryTable.NEXT =0;
            //    END;
            Members.CALCFIELDS(Members."Current Shares");
            amount := Members."Current Shares";
            //    MESSAGE('sd > %1',amount);
            IF amount < 5000 THEN BEGIN
                response := '{ "StatusCode":"8","StatusDescription":"FAIL","LimitAmount":0,"Message":"Share Deposits Balance less than 5,000" }';
                EXIT(response);
            END;
            // ===== end share deposit >=5000?




            // ===== available share deposits
            ComittedShares := 0;
            limitAmount := 0;
            LoanGuarantors.RESET;
            LoanGuarantors.SETRANGE(LoanGuarantors."Member No", vendorTable."BOSA Account No");
            LoanGuarantors.SETRANGE(LoanGuarantors.Substituted, FALSE);
            IF LoanGuarantors.FIND('-') THEN BEGIN
                REPEAT
                    IF LoansRegister.GET(LoanGuarantors."Loan No") THEN BEGIN
                        LoansRegister.CALCFIELDS(LoansRegister."Outstanding Balance");
                        IF LoansRegister."Outstanding Balance" > 0 THEN BEGIN
                            ComittedShares := ComittedShares + LoanGuarantors."Amont Guaranteed";
                        END;
                    END;
                UNTIL LoanGuarantors.NEXT = 0;
            END;
            Members.CALCFIELDS(Members."Current Shares");
            //    MESSAGE('cs > %1',Members."Current Shares");
            FreeShares := Members."Current Shares" - ComittedShares;
            limitAmount := 0.3 * FreeShares;
            // ===== end available share deposits



            maxLoanAmount := 0;
            minLoanAmount := 0;
            LoanProductsSetup.RESET;
            LoanProductsSetup.SETRANGE(LoanProductsSetup.Code, 'ELOAN');
            IF LoanProductsSetup.FIND('-') THEN BEGIN
                //interestAMT:=(LoanProductsSetup."Interest rate"/100);
                maxLoanAmount := LoanProductsSetup."Max. Loan Amount";
                minLoanAmount := LoanProductsSetup."Min. Loan Amount";
            END;

            IF limitAmount < minLoanAmount THEN BEGIN
                response := '{ "StatusCode":"9","StatusDescription":"FAIL","LimitAmount":0,"Message":"Qualified amount is less than minimum" }';
                EXIT(response);
            END;

            IF limitAmount > maxLoanAmount THEN limitAmount := maxLoanAmount;

            response := '{ "StatusCode":"000","StatusDescription":"OK","LimitAmount":' + FORMAT(limitAmount, 0, 1) + ',"Message":"Qualified amount ' + FORMAT(limitAmount, 0, 1) + '" }';
            EXIT(response);


        END;
    END;

    LOCAL PROCEDURE PostLoan(documentNo: Code[20]; AccountNo: Code[50]; amount: Decimal; Period: Decimal) result: Code[30];
    VAR
        swizzkasTransTable: Record "SwizzKash Transactions";
        membersTable: Record Customer;
        vendorTable: Record Vendor;
        loansRegisterTable: Record "Loans Register";
        chargesTable: Record Charges;
        LoanProdCharges: Record "Loan Product Charges";
        SaccoNoSeries: Record "Sacco No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LoanRepSchedule: Record "Loan Repayment Schedule";
        ObjLoanPurpose: Record "Loans Purpose";
        SaccoNo: Record "Sacco No. Series";
        GenSetUp: Record "Sacco General Set-Up";
        SaccoGenSetup: Record "Sacco General Set-Up";
        vendorCommAcc: Code[30];
        vendorCommAmount: Decimal;
        LoanAcc: Code[30];
        InterestAcc: Code[30];
        InterestAmount: Decimal;
        AmountToCredit: Decimal;
        AmountToDisburse: Decimal;
        loanNo: Text[20];
        loanType: Code[50];
        InsuranceAcc: Code[10];
        AmountDispursed: Decimal;
    BEGIN
        loanType := '24';

        swizzkasTransTable.RESET;
        swizzkasTransTable.SETRANGE(swizzkasTransTable."Document No", documentNo);
        swizzkasTransTable.SETRANGE(swizzkasTransTable.Posted, FALSE);
        swizzkasTransTable.SETRANGE(swizzkasTransTable."Transaction Type", swizzkasTransTable."Transaction Type"::"Loan Application");
        swizzkasTransTable.SETRANGE(swizzkasTransTable.Status, swizzkasTransTable.Status::Pending);
        IF swizzkasTransTable.FIND('-') THEN BEGIN

            GenSetUp.RESET;
            GenSetUp.GET();
            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;

            // ** get loan and interest accounts **
            LoanProductsSetup.RESET;
            LoanProductsSetup.SETRANGE(LoanProductsSetup.Code, loanType);
            IF LoanProductsSetup.FINDFIRST() THEN BEGIN
                LoanAcc := LoanProductsSetup."Loan Account";
                InterestAcc := LoanProductsSetup."Loan Interest Account";
            END;

            SaccoGenSetup.RESET;
            SaccoGenSetup.GET;
            //SaccoGenSetup.TESTFIELD("Mpesa Cash Withdrawal fee ac");


            // -- get balance enquiry charges
            chargesTable.RESET;
            chargesTable.SETRANGE(Code, 'LNA');
            IF chargesTable.FIND('-') THEN BEGIN
                vendorCommAcc := chargesTable."GL Account";
                vendorCommAmount := chargesTable."Charge Amount";
                //saccoCommAmount:=chargesTable."Sacco Amount";
                //saccoCommAcc:='3000407';     // -- sacco commission account
            END;


            InterestAmount := ((LoanProductsSetup."Interest rate" / 12) / 100) * amount;
            AmountToCredit := amount;
            AmountToDisburse := amount - (InterestAmount + vendorCommAmount);// ** interest charged upfront , disburse amount less (interest+vendor commision)

            vendorTable.RESET;
            vendorTable.SETRANGE("No.", AccountNo);
            IF NOT vendorTable.FIND('-') THEN BEGIN
                result := 'ACCNOTFOUND';
                swizzkasTransTable.Status := swizzkasTransTable.Status::Failed;
                swizzkasTransTable.Posted := TRUE;
                swizzkasTransTable."Posting Date" := TODAY;
                swizzkasTransTable.Comments := 'Failed.Account Not Found';
                swizzkasTransTable.MODIFY;
                EXIT;
            END;

            membersTable.RESET;
            membersTable.SETRANGE(membersTable."No.", vendorTable."BOSA Account No");
            IF membersTable.FIND('-') THEN BEGIN

                //******* Create Loan *********//
                SaccoNoSeries.RESET;
                SaccoNoSeries.GET;
                SaccoNoSeries.TESTFIELD(SaccoNoSeries."BOSA Loans Nos");
                NoSeriesMgt.InitSeries(SaccoNoSeries."BOSA Loans Nos", loansRegisterTable."No. Series", 0D, loansRegisterTable."Loan  No.", loansRegisterTable."No. Series");
                loanNo := loansRegisterTable."Loan  No.";

                loansRegisterTable.INIT;
                loansRegisterTable."Approved Amount" := amount;
                loansRegisterTable.Interest := LoanProductsSetup."Interest rate";
                loansRegisterTable."Instalment Period" := LoanProductsSetup."Instalment Period";
                loansRegisterTable.Repayment := amount + InterestAmount + MPESACharge;
                loansRegisterTable."Expected Date of Completion" := CALCDATE('1M', TODAY);
                //loansRegisterTable.Posted:=TRUE;
                //membersTable.CALCFIELDS(membersTable."Current Shares", membersTable."Outstanding Balance", membersTable."Current Loan");
                loansRegisterTable."Shares Balance" := membersTable."Current Shares";
                loansRegisterTable."Amount Disbursed" := amount;
                loansRegisterTable.Savings := membersTable."Current Shares";
                loansRegisterTable."Interest Paid" := 0;
                loansRegisterTable."Issued Date" := TODAY;
                loansRegisterTable.Source := LoanProductsSetup.Source;
                loansRegisterTable."Loan Disbursed Amount" := amount;
                loansRegisterTable."Scheduled Principal to Date" := AmountToDisburse;
                loansRegisterTable."Current Interest Paid" := 0;
                loansRegisterTable."Loan Disbursement Date" := TODAY;
                loansRegisterTable."Client Code" := membersTable."No.";
                loansRegisterTable."Client Name" := membersTable.Name;
                loansRegisterTable."Outstanding Balance to Date" := AmountToDisburse;
                loansRegisterTable."Existing Loan" := membersTable."Outstanding Balance";
                //loansRegisterTable."Staff No":=membersTable."Payroll/Staff No";
                loansRegisterTable.Gender := membersTable.Gender;
                loansRegisterTable."BOSA No" := membersTable."No.";
                // loansRegisterTable."Branch Code":=Vendor."Global Dimension 2 Code";
                loansRegisterTable."Requested Amount" := amount;
                loansRegisterTable."ID NO" := membersTable."ID No.";
                IF loansRegisterTable."Branch Code" = '' THEN loansRegisterTable."Branch Code" := membersTable."Global Dimension 2 Code";
                loansRegisterTable."Loan  No." := loanNo;
                loansRegisterTable."No. Series" := SaccoNoSeries."BOSA Loans Nos";
                loansRegisterTable."Doc No Used" := documentNo;
                loansRegisterTable."Loan Interest Repayment" := InterestAmount;
                loansRegisterTable."Loan Principle Repayment" := amount;
                loansRegisterTable."Loan Repayment" := amount;
                loansRegisterTable."Employer Code" := membersTable."Employer Code";
                loansRegisterTable."Approval Status" := loansRegisterTable."Approval Status"::Approved;
                loansRegisterTable."Account No" := membersTable."No.";
                loansRegisterTable."Application Date" := TODAY;
                loansRegisterTable."Loan Product Type" := LoanProductsSetup.Code;
                loansRegisterTable."Loan Product Type Name" := LoanProductsSetup."Product Description";
                loansRegisterTable."Loan Disbursement Date" := TODAY;
                loansRegisterTable."Repayment Start Date" := TODAY;
                loansRegisterTable."Recovery Mode" := loansRegisterTable."Recovery Mode"::Checkoff;
                loansRegisterTable."Mode of Disbursement" := loansRegisterTable."Mode of Disbursement"::" ";
                loansRegisterTable."Requested Amount" := amount;
                loansRegisterTable."Approved Amount" := amount;
                loansRegisterTable.Installments := 1;
                loansRegisterTable."Loan Amount" := amount;
                loansRegisterTable."Issued Date" := TODAY;
                loansRegisterTable."Outstanding Balance" := 0;//Update
                loansRegisterTable."Repayment Frequency" := loansRegisterTable."Repayment Frequency"::Monthly;
                loansRegisterTable.INSERT(TRUE);

                // InterestAmount:=0;

                //**********Process Loan*******************//

                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILELOAN');
                GenJournalLine.DELETEALL;
                //end of deletion

                GenBatches.RESET;
                GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                GenBatches.SETRANGE(GenBatches.Name, 'MOBILELOAN');
                IF GenBatches.FIND('-') = FALSE THEN BEGIN
                    GenBatches.INIT;
                    GenBatches."Journal Template Name" := 'GENERAL';
                    GenBatches.Name := 'MOBILELOAN';
                    GenBatches.Description := 'Normal Loan';
                    GenBatches.VALIDATE(GenBatches."Journal Template Name");
                    GenBatches.VALIDATE(GenBatches.Name);
                    GenBatches.INSERT;
                END;



                //Post Loan
                loansRegisterTable.RESET;
                loansRegisterTable.SETRANGE(loansRegisterTable."Loan  No.", loanNo);
                IF loansRegisterTable.FIND('-') THEN BEGIN

                    //Dr loan Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::Loan;
                    GenJournalLine."Loan No" := loansRegisterTable."Loan  No.";
                    GenJournalLine."Account No." := membersTable."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := membersTable."No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'E-Loan Disbursment-' + loansRegisterTable."Loan  No.";
                    GenJournalLine.Amount := amount;// AmountToDisburse;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Cr Fosa Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := vendorTable."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Loan No" := loansRegisterTable."Loan  No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'E-Loan Disbursment';
                    GenJournalLine.Amount := -amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Cr Interest Eloan
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := vendorTable."No.";
                    GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Paid";//:"Interest Due";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := documentNo + ' Interest Paid'; // -- interest paid
                    GenJournalLine.Amount := ROUND(InterestAmount, 1, '>');
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);

                    IF LoanProductsSetup.GET(loansRegisterTable."Loan Product Type") THEN BEGIN
                        GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                        GenJournalLine."Bal. Account No." := LoanProductsSetup."Receivable Interest Account";
                        GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
                    END;

                    IF loansRegisterTable.Source = loansRegisterTable.Source::BOSA THEN BEGIN
                        GenJournalLine."Shortcut Dimension 1 Code" := membersTable."Global Dimension 1 Code";
                        GenJournalLine."Shortcut Dimension 2 Code" := membersTable."Global Dimension 2 Code";
                    END;

                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Loan No" := loansRegisterTable."Loan  No.";
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Dr Fosa Acc - SwizzKash commission
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := vendorTable."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Loan No" := loansRegisterTable."Loan  No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'E-Loan Vendor Comm';
                    GenJournalLine.Amount := vendorCommAmount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr SwizzKash commission
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := vendorCommAcc;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Loan No" := loansRegisterTable."Loan  No.";
                    GenJournalLine."Posting Date" := TODAY;
                    GenJournalLine.Description := 'E-Loan Vendor Comm';
                    GenJournalLine.Amount := vendorCommAmount * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILELOAN');
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;

                        //***************Update Loan Status************//
                        loansRegisterTable."Loan Status" := loansRegisterTable."Loan Status"::Issued;
                        loansRegisterTable."Amount Disbursed" := AmountToCredit;
                        loansRegisterTable.Posted := TRUE;
                        loansRegisterTable."Interest Upfront Amount" := InterestAmount;
                        loansRegisterTable."Outstanding Balance" := amount;
                        loansRegisterTable.MODIFY;

                        // //=====================insert to Mpesa mobile disbursment
                        // MpesaDisbus.RESET;
                        // MpesaDisbus.SETRANGE(MpesaDisbus."Document No", documentNo);
                        // IF MpesaDisbus.FIND('-') = FALSE THEN BEGIN
                        //     MpesaDisbus."Account No" := membersTable."No.";
                        //     MpesaDisbus."Document Date" := TODAY;
                        //     MpesaDisbus."Loan Amount" := amount;
                        //     MpesaDisbus."Document No" := documentNo;
                        //     MpesaDisbus."Batch No" := 'MOBILE';
                        //     MpesaDisbus."Date Entered" := TODAY;
                        //     MpesaDisbus."Time Entered" := TIME;
                        //     MpesaDisbus."Entered By" := USERID;
                        //     MpesaDisbus."Member No" := membersTable."No.";
                        //     MpesaDisbus."Telephone No" := membersTable."Phone No.";
                        //     //MpesaDisbus."Corporate No":='597676';
                        //     //MpesaDisbus."Delivery Center":='M-WALLET';
                        //     MpesaDisbus."Customer Name" := membersTable.Name;
                        //     MpesaDisbus.Status := MpesaDisbus.Status::Closed;
                        //     MpesaDisbus.Purpose := 'ELOAN';
                        //     MpesaDisbus.INSERT;
                        // END;
                    END;

                    swizzkasTransTable.Status := swizzkasTransTable.Status::Completed;
                    swizzkasTransTable.Posted := TRUE;
                    swizzkasTransTable."Posting Date" := TODAY;
                    swizzkasTransTable.Comments := 'POSTED';
                    swizzkasTransTable.MODIFY;
                    result := 'TRUE';
                    msg := 'Dear ' + SplitString(membersTable.Name, ' ') + ', Your ELOAN No ' + loanNo
                      + ' of Ksh ' + FORMAT((AmountToDisburse)) + ' has been disbursed to your M-WALLET Account, '
                      + ' Your loan of KShs ' + FORMAT(amount) + ' is due on ' + FORMAT(CALCDATE('+1M', TODAY));

                    SMSMessage(documentNo, membersTable."No.", membersTable."Phone No.", msg);

                END;//Loans Register

            END ELSE BEGIN
                result := 'ACCINEXISTENT';
                swizzkasTransTable.Status := swizzkasTransTable.Status::Failed;
                swizzkasTransTable.Posted := TRUE;
                swizzkasTransTable."Posting Date" := TODAY;
                swizzkasTransTable.Comments := 'Failed.Invalid Account';
                swizzkasTransTable.MODIFY;
            END;

        END;
    END;
    //this one is not in use..2025, wait for CO-Op Wallets
    LOCAL PROCEDURE PostAdvance(docNo: Code[20]; AccountNo: Code[50]; amount: Decimal; period: Decimal) result: Code[30];
    VAR
        VendorTable: Record "Vendor";
        CustomerTable: Record "Customer";
        LoanProductChargesTable: Record "Loan Product Charges";
        Sacco_No_SeriesTable: Record "Sacco No. Series";
        LoansRegisterTable: Record "Loans Register";
        LoanRepaymentScheduleTable: Record "Loan Repayment Schedule";
        LoanPurposeTable: Record "Loans Purpose";
        SwizzKashTransactionsTable: Record "SwizzKash Transactions";
        SaccoNo: Record "No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        LoanAcc: Code[30];
        InterestAcc: Code[30];
        InterestAmount: Decimal;
        AmountToCredit: Decimal;
        loanNo: Text[20];
        advSMS: Decimal;
        advFee: Decimal;
        advApp: Decimal;
        advSMSAcc: Code[20];
        advFEEAcc: Code[20];
        advAppAcc: Code[20];
        advSMSDesc: Text[100];
        advFeeDesc: Text[100];
        advAppDesc: Text[100];
        loanType: Code[50];
        InsuranceAcc: Code[10];
        AmountDispursed: Decimal;
        VarLoanAmt: Decimal;
        loanamt: Decimal;
    BEGIN

        // //loanType:='322';
        // SwizzKashTransactionsTable.RESET;
        // SwizzKashTransactionsTable.SETRANGE(SwizzKashTransactionsTable."Document No", docNo);
        // IF SwizzKashTransactionsTable.FIND('-') THEN BEGIN
        //     result := 'REFEXISTS';
        //     EXIT(result);
        // END ELSE BEGIN
        //     GenLedgerSetup.RESET;
        //     GenLedgerSetup.GET;
        //     loanamt := amount;

        //     LoanProductsSetup.RESET;
        //     LoanProductsSetup.SETRANGE(LoanProductsSetup.Code, '552');
        //     IF LoanProductsSetup.FINDFIRST() THEN BEGIN
        //         LoanAcc := LoanProductsSetup."Loan Account";
        //         InterestAcc := LoanProductsSetup."Loan Interest Account";
        //         InsuranceAcc := LoanProductsSetup."Loan Insurance Accounts";
        //     END;

        //     //loan charges
        //     LoanProductChargesTable.RESET;
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable."Product Code", '552');
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable.Code, loanType);
        //     IF LoanProductChargesTable.FINDFIRST() THEN BEGIN
        //         advApp := LoanProductChargesTable.Amount;
        //         advAppAcc := LoanProductChargesTable."G/L Account";
        //         advAppDesc := LoanProductChargesTable.Description;
        //     END;
        //     //sms charge
        //     LoanProductChargesTable.RESET;
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable."Product Code", '552');
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable.Code, '001');
        //     IF LoanProductChargesTable.FINDFIRST() THEN BEGIN
        //         advSMS := (LoanProductChargesTable.Amount);
        //         advSMSAcc := LoanProductChargesTable."G/L Account";
        //         advSMSDesc := LoanProductChargesTable.Description;
        //     END;

        //     //Eloan Processing fee
        //     LoanProductChargesTable.RESET;
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable."Product Code", '552');
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable.Code, '552');
        //     IF LoanProductChargesTable.FINDFIRST() THEN BEGIN
        //         advSMS := LoanProductChargesTable.Amount;
        //         advSMSAcc := LoanProductChargesTable."G/L Account";
        //         advSMSDesc := LoanProductChargesTable.Description;
        //     END;
        //     //loan proccessing fee
        //     LoanProductChargesTable.RESET;
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable."Product Code", '552');
        //     LoanProductChargesTable.SETRANGE(LoanProductChargesTable.Code, '552');
        //     IF LoanProductChargesTable.FINDFIRST() THEN BEGIN
        //         advFee := (LoanProductChargesTable.Amount / 100) * amount;
        //         advFEEAcc := LoanProductChargesTable."G/L Account";
        //         advFeeDesc := LoanProductChargesTable.Description;
        //     END;

        //     VarLoanAmt := amount;

        //     GenLedgerSetup.RESET;
        //     GenLedgerSetup.GET;
        //     GenLedgerSetup.TESTFIELD(GenLedgerSetup."MPESA Recon Acc");
        //     //mpesaSettlementAccount := GenLedgerSetup."MPESA Recon Acc";
        //     mpesaCharge := GetCharge(amount, 'MPESA');

        //     SwizzKashCharge := GenLedgerSetup."SwizzKash Charge";
        //     SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
        //     InterestAmount := (LoanProductsSetup."Interest rate" / 100) * amount * period;
        //     AmountToCredit := amount + InterestAmount + MPESACharge + advSMS;
        //     //ExcDuty:=(10/100)*(MobileCharges+SurePESACharge);
        //     AmountDispursed := amount + MPESACharge + advSMS;

        //     VendorTable.RESET;
        //     VendorTable.SETRANGE(VendorTable."No.", AccountNo);
        //     IF VendorTable.FIND('-') THEN BEGIN
        //     END;

        //     CustomerTable.RESET;
        //     CustomerTable.SETRANGE(CustomerTable."No.", VendorTable."BOSA Account No");
        //     IF CustomerTable.FIND('-') THEN BEGIN

        //         //*******Create Loan *********//
        //         Sacco_No_SeriesTable.RESET;
        //         Sacco_No_SeriesTable.GET;
        //         Sacco_No_SeriesTable.TESTFIELD(Sacco_No_SeriesTable."BOSA Loans Nos");
        //         NoSeriesMgt.InitSeries(Sacco_No_SeriesTable."BOSA Loans Nos", LoansRegisterTable."No. Series", 0D, LoansRegisterTable."Loan  No.", LoansRegisterTable."No. Series");
        //         loanNo := LoansRegisterTable."Loan  No.";

        //         LoansRegisterTable.INIT;
        //         LoansRegisterTable."Approved Amount" := amount;
        //         LoansRegisterTable.Interest := LoanProductsSetup."Interest rate";
        //         // LoansRegisterTable."Instalment Period":=CALCDATE(FORMAT(period));
        //         LoansRegisterTable.Repayment := AmountDispursed;
        //         LoansRegisterTable."Expected Date of Completion" := CALCDATE(FORMAT(period) + 'M', TODAY);
        //         LoansRegisterTable.Posted := TRUE;
        //         CustomerTable.CALCFIELDS(CustomerTable."Current Shares", CustomerTable."Outstanding Balance", CustomerTable."Current Loan");
        //         LoansRegisterTable."Shares Balance" := CustomerTable."Current Shares";
        //         LoansRegisterTable."Amount Disbursed" := amount;
        //         LoansRegisterTable.Savings := CustomerTable."Current Shares";
        //         LoansRegisterTable."Interest Paid" := 0;
        //         LoansRegisterTable."Issued Date" := TODAY;
        //         LoansRegisterTable.Source := LoanProductsSetup.Source;
        //         LoansRegisterTable."Loan Disbursed Amount" := amount;
        //         LoansRegisterTable."Scheduled Principal to Date" := AmountDispursed;
        //         LoansRegisterTable."Current Interest Paid" := 0;
        //         LoansRegisterTable."Loan Disbursement Date" := TODAY;
        //         LoansRegisterTable."Client Code" := CustomerTable."No.";
        //         LoansRegisterTable."Client Name" := CustomerTable.Name;
        //         LoansRegisterTable."Outstanding Balance to Date" := AmountDispursed;
        //         LoansRegisterTable."Existing Loan" := CustomerTable."Outstanding Balance";
        //         //LoansRegisterTable."Staff No":=CustomerTable."Payroll/Staff No";
        //         LoansRegisterTable.Gender := CustomerTable.Gender;
        //         LoansRegisterTable."BOSA No" := CustomerTable."No.";
        //         // LoansRegisterTable."Branch Code":=VendorTable."Global Dimension 2 Code";
        //         LoansRegisterTable."Requested Amount" := amount;
        //         LoansRegisterTable."ID NO" := CustomerTable."ID No.";
        //         IF LoansRegisterTable."Branch Code" = '' THEN
        //             LoansRegisterTable."Branch Code" := CustomerTable."Global Dimension 2 Code";
        //         LoansRegisterTable."Loan  No." := loanNo;
        //         LoansRegisterTable."No. Series" := Sacco_No_SeriesTable."BOSA Loans Nos";
        //         LoansRegisterTable."Doc No Used" := docNo;
        //         LoansRegisterTable."Loan Interest Repayment" := InterestAmount;
        //         LoansRegisterTable."Loan Principle Repayment" := AmountDispursed;
        //         LoansRegisterTable."Loan Repayment" := AmountDispursed + InterestAmount;
        //         LoansRegisterTable."Employer Code" := CustomerTable."Employer Code";
        //         LoansRegisterTable."Approval Status" := LoansRegisterTable."Approval Status"::Approved;
        //         LoansRegisterTable."Account No" := CustomerTable."No.";
        //         LoansRegisterTable."Application Date" := TODAY;
        //         LoansRegisterTable."Loan Product Type" := LoanProductsSetup.Code;
        //         LoansRegisterTable."Loan Product Type Name" := LoanProductsSetup."Product Description";
        //         LoansRegisterTable."Loan Disbursement Date" := TODAY;
        //         LoansRegisterTable."Repayment Start Date" := TODAY;
        //         LoansRegisterTable."Recovery Mode" := LoansRegisterTable."Recovery Mode"::Checkoff;
        //         //   LoansRegisterTable."Disburesment Type":=LoansRegisterTable."Disburesment Type"::"1";
        //         LoansRegisterTable."Requested Amount" := amount;
        //         LoansRegisterTable."Approved Amount" := AmountDispursed;
        //         LoansRegisterTable.Installments := period;
        //         LoansRegisterTable."Loan Amount" := AmountDispursed;
        //         LoansRegisterTable."Issued Date" := TODAY;
        //         LoansRegisterTable."Outstanding Balance" := 0;//Update
        //         LoansRegisterTable."Repayment Frequency" := LoansRegisterTable."Repayment Frequency"::Monthly;
        //         LoansRegisterTable."Mode of Disbursement" := LoansRegisterTable."Mode of Disbursement"::"Bank Transfer";
        //         LoansRegisterTable.INSERT(TRUE);

        //         // InterestAmount:=0;

        //         //**********Process Loan*******************//

        //         GenJournalLine.RESET;
        //         GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        //         GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILELOAN');
        //         GenJournalLine.DELETEALL;
        //         //end of deletion

        //         GenBatches.RESET;
        //         GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
        //         GenBatches.SETRANGE(GenBatches.Name, 'MOBILELOAN');

        //         IF GenBatches.FIND('-') = FALSE THEN BEGIN
        //             GenBatches.INIT;
        //             GenBatches."Journal Template Name" := 'GENERAL';
        //             GenBatches.Name := 'MOBILELOAN';
        //             GenBatches.Description := 'E-Loan';
        //             GenBatches.VALIDATE(GenBatches."Journal Template Name");
        //             GenBatches.VALIDATE(GenBatches.Name);
        //             GenBatches.INSERT;
        //         END;



        //         //Post Loan
        //         LoansRegisterTable.RESET;
        //         LoansRegisterTable.SETRANGE(LoansRegisterTable."Loan  No.", loanNo);
        //         IF LoansRegisterTable.FIND('-') THEN BEGIN

        //             //Dr loan Acc
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::Investor;
        //             GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Deposit Contribution";
        //             GenJournalLine."Loan No" := LoansRegisterTable."Loan  No.";
        //             GenJournalLine."Account No." := CustomerTable."No.";
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := CustomerTable."No.";
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := 'MBanking Loan Disbursment -' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := AmountDispursed;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;



        //             //Cr Interest Eloan
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::Investor;
        //             GenJournalLine."Account No." := CustomerTable."No.";
        //             GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Withholding Tax";
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := docNo + ' ' + 'Interest charged' + CustomerTable."No." + '' + CustomerTable.Name;
        //             GenJournalLine.Amount := ROUND(InterestAmount, 1, '>');
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF LoanProductsSetup.GET(LoansRegisterTable."Loan Product Type") THEN BEGIN
        //                 GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
        //                 GenJournalLine."Bal. Account No." := LoanProductsSetup."Loan Interest Account";
        //                 GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
        //             END;
        //             IF LoansRegisterTable.Source = LoansRegisterTable.Source::BOSA THEN BEGIN
        //                 GenJournalLine."Shortcut Dimension 1 Code" := CustomerTable."Global Dimension 1 Code";
        //                 GenJournalLine."Shortcut Dimension 2 Code" := CustomerTable."Global Dimension 2 Code";
        //             END;
        //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
        //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
        //             GenJournalLine."Loan No" := LoansRegisterTable."Loan  No.";
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;

        //             //Cr proccesing Charges
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        //             GenJournalLine."Account No." := advSMSAcc;
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := advSMSDesc + ' ' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := advSMS * -1;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;

        //             //Dr proccesing Charges Acc with SwizzKash charges
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        //             GenJournalLine."Account No." := advSMSAcc;
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := 'ClouPESA Charges ' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := SwizzKashCharge;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;

        //             //Cr  SwizzKash commission acc
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        //             GenJournalLine."Account No." := SwizzKashCommACC;
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := 'ClouPESA Charges - ' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := SwizzKashCharge * -1;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;


        //             //Cr bank Charges
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
        //             GenJournalLine."Account No." := MpesaAccount;
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := 'MBanking Loan Disbursment - Charges -' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := MPESACharge * -1;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;

        //             //Cr bank
        //             LineNo := LineNo + 10000;
        //             GenJournalLine.INIT;
        //             GenJournalLine."Journal Template Name" := 'GENERAL';
        //             GenJournalLine."Journal Batch Name" := 'MOBILELOAN';
        //             GenJournalLine."Line No." := LineNo;
        //             GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
        //             GenJournalLine."Account No." := MpesaAccount;
        //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        //             GenJournalLine."Document No." := docNo;
        //             GenJournalLine."External Document No." := docNo;
        //             GenJournalLine."Posting Date" := TODAY;
        //             GenJournalLine.Description := 'MBanking Loan Disbursment -' + LoansRegisterTable."Loan  No.";
        //             GenJournalLine.Amount := (loanamt) * -1;
        //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
        //             IF GenJournalLine.Amount <> 0 THEN
        //                 GenJournalLine.INSERT;



        //             //Post
        //             GenJournalLine.RESET;
        //             GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
        //             GenJournalLine.SETRANGE("Journal Batch Name", 'MOBILELOAN');
        //             IF GenJournalLine.FIND('-') THEN BEGIN
        //                 REPEAT
        //                     GLPosting.RUN(GenJournalLine);
        //                 UNTIL GenJournalLine.NEXT = 0;

        //                 //***************Update Loan Status************//
        //                 LoansRegisterTable."Loan Status" := LoansRegisterTable."Loan Status"::Issued;
        //                 LoansRegisterTable."Amount Disbursed" := AmountToCredit;
        //                 LoansRegisterTable.Posted := TRUE;
        //                 LoansRegisterTable."Interest Upfront Amount" := InterestAmount;
        //                 LoansRegisterTable."Outstanding Balance" := AmountDispursed;
        //                 LoansRegisterTable.MODIFY;


        //                 //======================Generate schedule
        //                 I := 1;
        //                 WHILE I <= period DO BEGIN
        //                     LoansRegisterTable.CALCFIELDS(LoansRegisterTable."Oustanding Interest", LoansRegisterTable."Outstanding Balance");
        //                     LoanRepaymentScheduleTable.INIT;
        //                     LoanRepaymentScheduleTable."Repayment Code" := FORMAT(I);
        //                     LoanRepaymentScheduleTable."Loan No." := LoansRegisterTable."Loan  No.";
        //                     LoanRepaymentScheduleTable."Loan Amount" := LoansRegisterTable."Loan Amount";
        //                     LoanRepaymentScheduleTable."Instalment No" := I;
        //                     LoanRepaymentScheduleTable."Repayment Date" := CALCDATE(FORMAT(I) + 'M', LoansRegisterTable."Issued Date");
        //                     LoanRepaymentScheduleTable."Member No." := LoansRegisterTable."Client Code";
        //                     LoanRepaymentScheduleTable."Loan Category" := LoansRegisterTable."Loan Product Type";
        //                     LoanRepaymentScheduleTable."Monthly Repayment" := (LoansRegisterTable."Loan Principle Repayment" + LoansRegisterTable."Loan Interest Repayment") / I;
        //                     LoanRepaymentScheduleTable."Monthly Interest" := (LoansRegisterTable."Oustanding Interest") / I;
        //                     LoanRepaymentScheduleTable."Principal Repayment" := (LoansRegisterTable."Loan Principle Repayment") / I;
        //                     LoanRepaymentScheduleTable."Loan Balance" := LoansRegisterTable."Oustanding Interest" + LoansRegisterTable."Outstanding Balance";
        //                     LoanRepaymentScheduleTable.INSERT;

        //                     I := I + 1;
        //                 END;

        //                 result := 'TRUE';
        //                 msg := 'Dear ' + SplitString(CustomerTable.Name, ' ') + ', Your Eloan No ' + loanNo + ' of Ksh ' + FORMAT((loanamt)) + ' has been approved and disbursed to your Mpesa No.' +
        //                CustomerTable."Mobile Phone No" + '. The total payable amount is KShs ' + FORMAT(AmountToCredit) + ' payable on or before ' + FORMAT(LoansRegisterTable."Expected Date of Completion"); //FORMAT(CALCDATE((period) +'M',TODAY));
        //                 SMSMessage(docNo, CustomerTable."No.", CustomerTable."Mobile Phone No", msg);

        //                 SwizzKashTransactionsTable.INIT;
        //                 SwizzKashTransactionsTable."Document No" := docNo;
        //                 SwizzKashTransactionsTable.Description := 'Mobile Loan';
        //                 SwizzKashTransactionsTable."Document Date" := TODAY;
        //                 SwizzKashTransactionsTable."Account No" := AccountNo;
        //                 SwizzKashTransactionsTable."Account No2" := '';
        //                 SwizzKashTransactionsTable."Account Name" := CustomerTable.Name;
        //                 SwizzKashTransactionsTable."Telephone Number" := CustomerTable."Mobile Phone No";
        //                 SwizzKashTransactionsTable.Amount := amount;
        //                 SwizzKashTransactionsTable.Status := SwizzKashTransactionsTable.Status::Closed;
        //                 SwizzKashTransactionsTable.Posted := TRUE;
        //                 SwizzKashTransactionsTable."Posting Date" := TODAY;
        //                 SwizzKashTransactionsTable.Comments := 'Success';
        //                 SwizzKashTransactionsTable.Client := CustomerTable."No.";
        //                 SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."Transaction Type"::"Loan Application";
        //                 SwizzKashTransactionsTable."Transaction Time" := TIME;
        //                 SwizzKashTransactionsTable."SMS Message" := msg;
        //                 SwizzKashTransactionsTable.INSERT;


        //             END;//
        //         END;//Loans Register
        //     END
        //     ELSE BEGIN
        //         result := 'ACCINEXISTENT';
        //         SwizzKashTransactionsTable.INIT;
        //         SwizzKashTransactionsTable."Document No" := docNo;
        //         SwizzKashTransactionsTable.Description := 'Mobile Loan';
        //         SwizzKashTransactionsTable."Document Date" := TODAY;
        //         SwizzKashTransactionsTable."Account No" := AccountNo;
        //         SwizzKashTransactionsTable."Account No2" := '';
        //         SwizzKashTransactionsTable.Amount := amount;
        //         SwizzKashTransactionsTable.Status := SwizzKashTransactionsTable.Status::Rejected;
        //         SwizzKashTransactionsTable.Posted := TRUE;
        //         SwizzKashTransactionsTable."Posting Date" := TODAY;
        //         SwizzKashTransactionsTable.Comments := 'Failed';
        //         SwizzKashTransactionsTable.Client := CustomerTable."No.";
        //         SwizzKashTransactionsTable."Transaction Type" := SwizzKashTransactionsTable."Transaction Type"::"Loan Application";
        //         SwizzKashTransactionsTable."Transaction Time" := TIME;
        //         SwizzKashTransactionsTable.INSERT;

        //     END;
        // END;
    END;

    PROCEDURE GetMemberInformation(phonenumber: Text[100]) response: Text;
    BEGIN
        response := '{ "StatusCode":"02","StatusDescription":"INFONOTQUERIED","MemberInfo": [] }';

        Vendor.RESET;
        Vendor.SETRANGE(Vendor."Mobile Phone No", phonenumber);
        IF Vendor.FIND('-') THEN BEGIN
            // Members.RESET;
            // Members.SETRANGE(Members."No.", Vendor."BOSA Account No");
            // IF Members.FIND('-') THEN BEGIN
            response := '{"StatusCode":"000","StatusDescription":"OK","MemberInfo": [ { "MemberNo":"' + Vendor."BOSA Account No" + '",' + '"MemberName":"' + Vendor.Name + '"}] }';
            // END ELSE BEGIN
            //     response := '{ "StatusCode":"01","StatusDescription":"MEMBERNOTFOUND","MemberInfo": [] }';
            // END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","MemberInfo": [] }';
        END;
    END;

    PROCEDURE GetMinistatementApp(phonenumber: text[100]; dateFrom: Date; dateTo: Date) response: Text
    VAR
        statementList: Text;
        vendorTable: Record Vendor;
        memberTable: Record Customer;
        runCount: Integer;
        statementCount: Integer;
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"NOTPROCESSED","statementList": [] }';

        vendorTable.RESET;
        vendorTable.SETRANGE(vendorTable."Mobile Phone No", phonenumber);
        //vendorTable.SETRANGE(vendorTable."Vendor Posting Group",'M_WALLET');
        IF vendorTable.FIND('-') THEN BEGIN
            memberTable.RESET;
            memberTable.SETRANGE(memberTable."No.", vendorTable."BOSA Account No");
            IF memberTable.FIND('-') THEN BEGIN
                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETRANGE(MemberLedgerEntry."Customer No.", memberTable."No.");
                MemberLedgerEntry.SETCURRENTKEY(MemberLedgerEntry."Posting Date");
                MemberLedgerEntry.SETASCENDING("Posting Date", FALSE);
                IF MemberLedgerEntry.FIND('-') THEN BEGIN
                    statementCount := MemberLedgerEntry.COUNT;
                    runCount := 0;
                    statementList := '';

                    REPEAT
                        runCount := runCount + 1;

                        IF statementList = '' THEN BEGIN
                            statementList := '{ "transactionDate":"' + FORMAT(MemberLedgerEntry."Posting Date") +
                                            '", "transactionType":"' + FORMAT(MemberLedgerEntry."Transaction Type") +
                                            '","amount":' + FORMAT(MemberLedgerEntry.Amount, 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                        END ELSE BEGIN
                            statementList += ',{ "transactionDate":"' + FORMAT(MemberLedgerEntry."Posting Date") +
                                           '", "transactionType":"' + FORMAT(MemberLedgerEntry."Transaction Type") +
                                           '","amount":' + FORMAT(MemberLedgerEntry.Amount, 0, '<Precision,2:2><Integer><Decimals>') + ' }';
                        END;

                        IF runCount >= 15 THEN BEGIN
                            IF statementList <> '' THEN BEGIN
                                response := '{ "StatusCode":"000","StatusDescription":"OK","statementList":[ ' + statementList + ' ] }';
                            END ELSE BEGIN
                                response := '{ "StatusCode":"1","StatusDescription":"NOTRANSACTIONS","statementList":[] }';
                            END;
                            EXIT;
                        END;

                    UNTIL MemberLedgerEntry.NEXT = 0;

                    IF statementList <> '' THEN BEGIN
                        response := '{ "StatusCode":"000","StatusDescription":"OK","statementList":[ ' + statementList + ' ] }';
                    END ELSE BEGIN
                        response := '{ "StatusCode":"1","StatusDescription":"NOTRANSACTIONS","statementList":[] }';
                    END;
                END ELSE BEGIN
                    response := '{ "StatusCode":"1","StatusDescription":"NORECORDS","statementList":[] }';
                END;
            END ELSE BEGIN
                response := '{ "StatusCode":"1","StatusDescription":"MEMBERNOTFOUND","statementList":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"3","StatusDescription":"NUMBERNOTFOUND","statementList":[] }';
        END;
    END;

    LOCAL PROCEDURE GetCharge(chargecode: Code[50]; amount: Decimal) charge: Decimal;
    VAR
        TariffDetails: Record "Tariff Details";
    BEGIN
        TariffDetails.RESET;
        TariffDetails.SETRANGE(TariffDetails.Code, chargecode);
        TariffDetails.SETFILTER(TariffDetails."Lower Limit", '<=%1', amount);
        TariffDetails.SETFILTER(TariffDetails."Upper Limit", '>=%1', amount);
        IF TariffDetails.FIND('-') THEN BEGIN
            charge := TariffDetails."Charge Amount";
        END
    END;

    LOCAL PROCEDURE GetLoanProductName(loancode: Code[20]) name: Text
    var
        LoanProducttype: Record "Loan Products Setup";
    BEGIN
        LoanProducttype.RESET;
        LoanProducttype.SETRANGE(LoanProducttype.Code, loancode);
        IF LoanProducttype.FIND('-') THEN BEGIN
            name := LoanProducttype."Product Description";
        END;
    END;

    LOCAL PROCEDURE ClearGLJournal(jnlTemplateName: Code[50]; jnlBatchName: Code[50]);
    BEGIN

        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", jnlTemplateName);
        GenJournalLine.SETRANGE("Journal Batch Name", jnlBatchName);
        GenJournalLine.DELETEALL;
    END;

    LOCAL PROCEDURE PrepareGLJournalBatch(jnlTemplateName: Code[50]; jnlBatchName: Code[50]; jnlDescription: Text[100]);
    BEGIN
        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", jnlTemplateName);
        GenBatches.SETRANGE(GenBatches.Name, jnlBatchName);
        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := jnlTemplateName;
            GenBatches.Name := jnlBatchName;
            GenBatches.Description := jnlDescription;
            GenBatches.VALIDATE(GenBatches."Journal Template Name");
            GenBatches.VALIDATE(GenBatches.Name);
            GenBatches.INSERT;
        END;
    END;

    local procedure CreateGenJournalLine(BATCHTEMPLATE: code[20]; BATCHNAME: code[20]; linenumber: integer;
    documentno: code[20]; accounttype: enum "Gen. Journal Account Type";
                                           accountno: code[20];
                                           externaldocno: code[20];
                                           transactiondescription: text[50];
                                           transactionamount: Decimal;
                                           transactiondate: Date;
                                           TransactionType: Enum TransactionTypesEnum)
    begin
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := BATCHTEMPLATE;
        GenJournalLine."Journal Batch Name" := BATCHNAME;
        GenJournalLine."Line No." := linenumber;
        GenJournalLine."Document No." := documentno;
        GenJournalLine."Account Type" := accounttype;// GenJournalLine."account type"::Vendor;
        GenJournalLine."Account No." := accountno;// Vendor."No.";
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."External Document No." := externaldocno;// Vendor."No.";
        GenJournalLine."Posting Date" := transactiondate;// Today;
        GenJournalLine.Description := transactiondescription;// 'Mobile Transfer';
        GenJournalLine."Transaction Type" := TransactionType;//  ."Mobile Transaction Type" := TransactionType;// GenJournalLine."Mobile Transaction Type"::MobileTransactions;
        GenJournalLine.Amount := transactionamount;
        GenJournalLine.Validate(GenJournalLine.Amount);
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
    end;

    LOCAL PROCEDURE SplitString(sText: Text; separator: Text) Token: Text;
    VAR
        Pos: Integer;
        Tokenq: Text;
    BEGIN
        Pos := STRPOS(sText, separator);
        IF Pos > 0 THEN BEGIN
            Token := COPYSTR(sText, 1, Pos - 1);
            IF Pos + 1 <= STRLEN(sText) THEN
                sText := COPYSTR(sText, Pos + 1)
            ELSE
                sText := '';
        END ELSE BEGIN
            Token := sText;
            sText := '';
        END;
    END;

    LOCAL procedure ReplaceString(String: Text[250]; FindWhat: Text[250]; ReplaceWith: Text[250]) NewString: Text
    begin
        while StrPos(String, FindWhat) > 0 do
            String := DelStr(String, StrPos(String, FindWhat)) + ReplaceWith + CopyStr(String, StrPos(String, FindWhat) + StrLen(FindWhat));
        NewString := String;
    end;

    PROCEDURE SwizzKashPosts(fromDate: DateTime; toDate: DateTime; posted: Boolean) response: Text;
    VAR
        glentryTable: Record "G/L Entry";
        SwizzKashTransTable: Record "SwizzKash Transactions";
        postingList: text;
    BEGIN

        response := '{ "StatusCode":"2","StatusDescription":"NOTQUERIED","PostingList":[] }';
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SETRANGE("Posting Date", DT2DATE(fromDate), DT2DATE(toDate));
        SwizzKashTransTable.SETRANGE(Posted, posted);
        IF SwizzKashTransTable.FIND('-') THEN BEGIN
            REPEAT
                IF postingList = '' THEN BEGIN
                    postingList := '{ "AccounNo":"' + SwizzKashTransTable."Account No" + '","AccountName":"' + SwizzKashTransTable."Account Name" + '","DocumentNo":"' + SwizzKashTransTable."Document No" + '","Phone":"' + SwizzKashTransTable."Telephone Number" + '","Status":"' + FORMAT(SwizzKashTransTable.Status) + '","Description":"' + SwizzKashTransTable.Description + '","Amount":"' + FORMAT(SwizzKashTransTable.Amount) + '","Charges":"' + FORMAT(SwizzKashTransTable.Charge, 0, '<Precision,2:2><Integer><Decimals>') + '","DocumentDate":"' + FORMAT(SwizzKashTransTable."Document Date", 0, '<Day,2>/<Month,2>/<Year4>') + '" }';
                END ELSE BEGIN
                    postingList += ',{ "AccounNo":"' + SwizzKashTransTable."Account No" + '","AccountName":"' + SwizzKashTransTable."Account Name" + '","DocumentNo":"' + SwizzKashTransTable."Document No" + '","Phone":"' + SwizzKashTransTable."Telephone Number" + '","Status":"' + FORMAT(SwizzKashTransTable.Status) + '","Description":"' + SwizzKashTransTable.Description + '","Amount":"' + FORMAT(SwizzKashTransTable.Amount) + '","Charges":"' + FORMAT(SwizzKashTransTable.Charge, 0, '<Precision,2:2><Integer><Decimals>') + '","DocumentDate":"' + FORMAT(SwizzKashTransTable."Document Date", 0, '<Day,2>/<Month,2>/<Year4>') + '" }';
                END;
            UNTIL SwizzKashTransTable.NEXT = 0;

            IF postingList <> '' THEN BEGIN
                response := '{ "StatusCode":"000","StatusDescription":"OK","PostingList":[' + postingList + '] }';
            end else begin
                response := '{ "StatusCode":"3","StatusDescription":"NOPOSTINGDETAILS","PostingList":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"4","StatusDescription":"NOPOSTINGDETAILSINSPECIFIEDPERIOD","PostingList":[] }';
        END;
    END;

    PROCEDURE SwizzKashGLPosts(fromDate: Date; toDate: Date) response: Text;
    VAR
        generalLedgerSetup: Record "General Ledger Setup";
        glEntry: Record "G/L Entry";
        totals: Decimal;
        posts: Text;
    BEGIN
        response := '{ "StatusCode":"2","StatusDescription":"NOTQUERIED","Totals":"0.00", "PostingList":[] }';

        generalLedgerSetup.RESET;
        generalLedgerSetup.GET;
        generalLedgerSetup.TESTFIELD("SwizzKash Comm Acc");
        glEntry.RESET;
        glEntry.SETRANGE("G/L Account No.", generalLedgerSetup."SwizzKash Comm Acc");
        glEntry.SETRANGE("Posting Date", fromDate, toDate);
        IF glEntry.FIND('-') THEN BEGIN
            REPEAT

                IF posts = '' THEN BEGIN
                    posts := '{ "EntryNo":"' + FORMAT(glEntry."Entry No.") + '", "GLAccountNo":"' + glEntry."G/L Account No." + '","DocumentNo":"' + glEntry."Document No." + '","Description":"' + glEntry.Description + '","Amount":"' + FORMAT(glEntry.Amount, 0, '<Precision,2:2><Integer><Decimals>') + '","PostingDate":"' + FORMAT(glEntry."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') + '" }';
                END ELSE BEGIN
                    posts += ',{ "EntryNo":"' + FORMAT(glEntry."Entry No.") + '", "GLAccountNo":"' + glEntry."G/L Account No." + '","DocumentNo":"' + glEntry."Document No." + '","Description":"' + glEntry.Description + '","Amount":"' + FORMAT(glEntry.Amount, 0, '<Precision,2:2><Integer><Decimals>') + '","PostingDate":"' + FORMAT(glEntry."Posting Date", 0, '<Day,2>/<Month,2>/<Year4>') + '" }';
                END;
                totals += glEntry.Amount;
            UNTIL glEntry.NEXT = 0;

            IF posts <> '' THEN BEGIN
                response := '{ "StatusCode":"000","StatusDescription":"OK","Totals":"' + FORMAT(totals, 0, '<Precision,2:2><Integer><Decimals>') + '","PostingList":[' + posts + '] }';
            END ELSE BEGIN
                response := '{ "StatusCode":"3","StatusDescription":"NOPOSTINGDETAILS","Totals":"0.00","PostingList":[] }';
            END;

        END ELSE BEGIN
            response := '{ "StatusCode":"4","StatusDescription":"NOPOSTINGDETAILSINSPECIFIEDPERIOD","Totals":"0.00","PostingList":[] }';
        END;
    END;

    //-not this one... Festus
    PROCEDURE ProcessWithdrawals() result: Text[30]
    var
        bufferTable: Record "ATM Transactions";
        SwizzKashTranTable: Record "SwizzKash Transactions";
    begin
        result := '';
        SwizzKashTranTable.RESET;
        SwizzKashTranTable.SETRANGE(Posted, FALSE);
        //SwizzKashTranTable.SETRANGE(SwizzKashTranTable.Status, SwizzKashTranTable.Status::Pending);
        SwizzKashTranTable.SETRANGE(SwizzKashTranTable."Transaction Type", SwizzKashTranTable."Transaction Type"::Withdrawal);
        IF SwizzKashTranTable.FIND('-') THEN BEGIN
            REPEAT
                result := PostWithdrawalTransaction(SwizzKashTranTable."Document No"
                                          , SwizzKashTranTable."Account No"
                                          , SwizzKashTranTable."Telephone Number"
                                          , SwizzKashTranTable.Amount
                                          , SwizzKashTranTable."Document Date");
            UNTIL SwizzKashTranTable.NEXT = 0;
        END;
    end;

    LOCAL PROCEDURE PostWithdrawalTransaction(docNo: Text[20]; accountno: Code[20]; telephoneNo: Text; amount: Decimal; transactionDate: Date) result: Text[30]
    var
        GenLedgerSetup: Record "General Ledger Setup";
        SwizzKashTrans: Record "SwizzKash Transactions";
        SwizzKashCharge: Decimal;
        SwizzKashCommACC: Code[20];
        GenSetup: Record "Sacco General Set-Up";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        SwizzKashTrans.RESET;
        SwizzKashTrans.SETRANGE(SwizzKashTrans."Document No", docNo);
        IF SwizzKashTrans.FIND('-') THEN BEGIN
            result := 'REFEXISTS';
        END
        ELSE BEGIN

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."MPESA Recon Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");

                MPESACharge := GetCharge(amount, 'MPESA');
                SwizzKashCharge := GetCharge(amount, 'VENDWD');
                MobileCharges := GetCharge(amount, 'SACCOWD');

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                MPESARecon := GenLedgerSetup."MPESA Recon Acc";// "MPESA Settl Acc";
                MobileChargesACC := Charges."GL Account";
                GenSetup.GET();
                ExcDuty := (GenSetup."Excise Duty(%)" / 100) * (MobileCharges + SwizzKashCharge);
                TotalCharges := SwizzKashCharge + MobileCharges;
            END;

            Vendor.RESET;
            Vendor.SETRANGE(Vendor."No.", telephoneNo);
            // Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            //Vendor.SETRANGE(Hidden,FALSE);
            IF Vendor.FIND('-') THEN BEGIN
                Vendor.CALCFIELDS("Balance (LCY)", "ATM Transactions", "Uncleared Cheques", "EFT Transactions");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");

                IF (TempBalance > amount + TotalCharges + MPESACharge) THEN BEGIN
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DELETEALL;
                    //end of deletion

                    GenBatches.RESET;
                    GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                    GenBatches.SETRANGE(GenBatches.Name, 'MPESAWITHD');

                    IF GenBatches.FIND('-') = FALSE THEN BEGIN
                        GenBatches.INIT;
                        GenBatches."Journal Template Name" := 'GENERAL';
                        GenBatches.Name := 'MPESAWITHD';
                        GenBatches.Description := 'MPESA Withdrawal';
                        GenBatches.VALIDATE(GenBatches."Journal Template Name");
                        GenBatches.VALIDATE(GenBatches.Name);
                        GenBatches.INSERT;
                    END;

                    //DR Customer Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");

                    GenJournalLine."Bal. Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type");
                    GenJournalLine."Bal. Account No." := MPESARecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");

                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'MPESA Withdrawal ' + Vendor."No." + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := amount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;
                    //M-Pesa Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");

                    GenJournalLine."Bal. Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account Type");
                    GenJournalLine."Bal. Account No." := MPESARecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");

                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'MPESA Charges ' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := MPESACharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Dr Withdrawal Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := TotalCharges;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;
                    //Dr Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Excise - Withdrawal Charges';
                    GenJournalLine.Amount := TotalCharges * (GenSetup."Excise Duty(%)" / 100);
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //CR Mobile Transactions Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := MobileChargesACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := MobileCharges * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SwizzKashCommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := -SwizzKashCharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;


                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;
                    END;
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DELETEALL;

                    SwizzKashTrans.INIT;
                    SwizzKashTrans."Document No" := docNo;
                    SwizzKashTrans.Description := 'MPESA Withdrawal';
                    SwizzKashTrans."Document Date" := transactionDate;
                    SwizzKashTrans."Account No" := Vendor."No.";
                    SwizzKashTrans."Account No2" := MPESARecon;
                    SwizzKashTrans.Amount := amount;
                    SwizzKashTrans.Status := SwizzKashTrans.Status::Completed;
                    SwizzKashTrans.Posted := TRUE;
                    SwizzKashTrans."Posting Date" := TODAY;
                    SwizzKashTrans."Account Name" := Vendor.Name;
                    SwizzKashTrans.Comments := 'Success';
                    SwizzKashTrans.Client := Vendor."BOSA Account No";
                    SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Withdrawal;
                    SwizzKashTrans."Transaction Time" := TIME;
                    SwizzKashTrans.INSERT;
                    result := 'TRUE';
                    GenSetup.GET();
                    msg := 'M-pesa withdrawal Ref: ' + docNo + ' of KES ' + FORMAT(amount) + ' has been done from your Account ' + Vendor."No." +
                    ' on ' + FORMAT(TODAY) + ' at ' + FORMAT(TIME) + '. ';
                    SMSMessage(docNo, Vendor."No.", Vendor."Phone No.", msg);
                END
                ELSE BEGIN
                    result := 'INSUFFICIENT';

                    SwizzKashTrans.INIT;
                    SwizzKashTrans."Document No" := docNo;
                    SwizzKashTrans.Description := 'MPESA Withdrawal';
                    SwizzKashTrans."Document Date" := transactionDate;
                    SwizzKashTrans."Account No" := Vendor."No.";
                    SwizzKashTrans."Account No2" := MPESARecon;
                    SwizzKashTrans.Amount := amount;
                    SwizzKashTrans.Status := SwizzKashTrans.Status::Failed;
                    SwizzKashTrans.Posted := FALSE;
                    SwizzKashTrans."Posting Date" := TODAY;
                    SwizzKashTrans.Comments := 'Failed,Insufficient Funds';
                    SwizzKashTrans.Client := Vendor."BOSA Account No";
                    SwizzKashTrans."Account Name" := Vendor.Name;
                    SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Withdrawal;
                    SwizzKashTrans."Transaction Time" := TIME;
                    SwizzKashTrans.INSERT;
                END;
            END
            ELSE BEGIN
                result := 'ACCINEXISTENT';

                SwizzKashTrans.INIT;
                SwizzKashTrans."Document No" := docNo;
                SwizzKashTrans.Description := 'MPESA Withdrawal';
                SwizzKashTrans."Document Date" := TODAY;
                SwizzKashTrans."Account No" := '';
                SwizzKashTrans."Account No2" := MPESARecon;
                SwizzKashTrans.Amount := amount;
                SwizzKashTrans.Posted := FALSE;
                SwizzKashTrans."Posting Date" := TODAY;
                SwizzKashTrans.Comments := 'Failed,Invalid Account';
                SwizzKashTrans.Client := '';
                SwizzKashTrans."Transaction Type" := SwizzKashTrans."Transaction Type"::Withdrawal;
                SwizzKashTrans."Transaction Time" := TIME;
                SwizzKashTrans.INSERT;
            END;
        END;
    end;



    //---Festus
    PROCEDURE PostMPESAWithdrawals() result: Text[330];
    VAR
        SwizzKashTransTable: Record "SwizzKash Transactions";
        iCount: Integer;
    BEGIN
        iCount := 0;
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SETRANGE(Posted, FALSE);

        SwizzKashTransTable.SETCURRENTKEY("Document Date", "Transaction Time");
        SwizzKashTransTable.Ascending(false);
        //SwizzKashTransTable.SetRange(SwizzKashTransTable."Document No", 'SFE7HDSBG7');
        IF SwizzKashTransTable.FIND('-') THEN BEGIN
            REPEAT
                result := PostWithdrawal(SwizzKashTransTable."Document No");
                iCount += 1;
            UNTIL SwizzKashTransTable.NEXT = 0;
        END;

        EXIT('POSTEDCOUNT=' + FORMAT(iCount));
    END;

    PROCEDURE PostMPESAWithdrawalsTest(docNo: Text[20]) result: Text[330];
    VAR
        SwizzKashTransTable: Record "SwizzKash Transactions";
        iCount: Integer;
    BEGIN
        iCount := 0;
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SETRANGE(Posted, FALSE);

        SwizzKashTransTable.SETCURRENTKEY("Document Date", "Transaction Time");
        SwizzKashTransTable.Ascending(false);
        SwizzKashTransTable.SetRange(SwizzKashTransTable."Document No", docNo);
        IF SwizzKashTransTable.FIND('-') THEN BEGIN
            REPEAT
                result := PostWithdrawalTest(SwizzKashTransTable."Document No");
                iCount += 1;
            UNTIL SwizzKashTransTable.NEXT = 0;
        END;

        //EXIT('POSTEDCOUNT=' + FORMAT(iCount));
        exit('Result :' + result);
    END;

    LOCAL PROCEDURE PostWithdrawal(docNo: Text[20]) result: Text[330];
    VAR
        bankledgeE: Record 271;
        SwizzKashTransTable: Record "SwizzKash Transactions";
        telephoneNo: Text[20];
        withdrawAmount: Decimal;
        transactionDate: Date;
        AppType: Code[100];
        SwizzKashCharge: Decimal;
        SwizzKashCommACC: Code[100];
    BEGIN
        //result := '';
        //result := result + 'Starting PostWithdrawal';
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SetCurrentKey(SwizzKashTransTable.Entry);

        SwizzKashTransTable.SETRANGE(SwizzKashTransTable."Document No", docNo);
        IF SwizzKashTransTable.FIND('-') THEN BEGIN

            //result := result + '--Found Transaction, starting posting.';
            withdrawAmount := SwizzKashTransTable.Amount;
            transactionDate := SwizzKashTransTable."Document Date";
            telephoneNo := SwizzKashTransTable."Telephone Number";

            // check for double posting
            //result := result + '--Checking in the Bank Acc Le Entry..';
            bankledgeE.RESET;
            bankledgeE.SETRANGE(bankledgeE."Document No.", docNo);
            IF bankledgeE.FIND('-') THEN BEGIN
                SwizzKashTransTable.Status := SwizzKashTransTable.Status::Completed;
                SwizzKashTransTable.Posted := TRUE;
                SwizzKashTransTable.Comments := 'OK';
                SwizzKashTransTable.MODIFY;
                result := 'REFEXISTS';
                //result := result + 'Found its already posted in Bank Account Ledger Entry';
                EXIT;
            END;
            // end check for double posting

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."MPESA Recon Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            // result := result + '---fetching charges';
            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");

                MPESACharge := GetCharge(withdrawAmount, 'MPESA');
                SwizzKashCharge := GetCharge(withdrawAmount, 'VENDWD');
                MobileCharges := GetCharge(withdrawAmount, 'SACCOWD');

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                MPESARecon := GenLedgerSetup."MPESA Recon Acc";
                MobileChargesACC := Charges."GL Account";

                ExcDuty := GetExciseDutyRate() * (MobileCharges);
                TotalCharges := SwizzKashCharge + MobileCharges + ExcDuty + MPESACharge;
                //result := result + '--fetched charges';
            END;

            //result := result + '--validating member';
            Vendor.RESET;
            Vendor.SETRANGE(Vendor."Mobile Phone No", telephoneNo);
            Vendor.SETRANGE(Vendor.Status, Vendor.Status::Active);
            Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                //result := result + '--found member.. checking balance';
                Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                Vendor.CalcFields(Vendor."ATM Transactions");
                Vendor.CalcFields(Vendor."Uncleared Cheques");
                Vendor.CalcFields(Vendor."EFT Transactions");

                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
                IF (true) THEN BEGIN//TempBalance > 0) THEN BEGIN
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DELETEALL;
                    //end of deletion

                    GenBatches.RESET;
                    GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                    GenBatches.SETRANGE(GenBatches.Name, 'MPESAWITHD');

                    IF GenBatches.FIND('-') = FALSE THEN BEGIN
                        GenBatches.INIT;
                        GenBatches."Journal Template Name" := 'GENERAL';
                        GenBatches.Name := 'MPESAWITHD';
                        GenBatches.Description := 'MPESA Withdrawal';
                        GenBatches.VALIDATE(GenBatches."Journal Template Name");
                        GenBatches.VALIDATE(GenBatches.Name);
                        GenBatches.INSERT;
                    END;

                    //DR Customer Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := SwizzKashTransTable."Document Date";
                    GenJournalLine.Description := 'MPESA Withdraw-' + docNo + '' + Vendor.Name;
                    GenJournalLine.Amount := withdrawAmount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Bank a/c
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := MPESARecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'MPESA Withdrawal-' + Vendor."No." + '' + Vendor.Name;
                    GenJournalLine.Amount := (withdrawAmount + MPESACharge) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Dr Withdrawal Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges-' + Vendor."No." + '' + Vendor.Name;
                    GenJournalLine.Amount := TotalCharges;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Mobile Transactions Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := MobileChargesACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := MobileCharges * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SwizzKashCommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := -SwizzKashCharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;

                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                        GenJournalLine.DELETEALL;

                        msg := 'You have withdrawn KES ' + FORMAT(withdrawAmount) + ' from Account ' + Vendor.Name +
                        ' .Thank you for using POLYTECH Sacco Mobile.';

                        SwizzKashTransTable."Account No2" := MPESARecon;
                        SwizzKashTransTable.Charge := TotalCharges;

                        SwizzKashTransTable."SMS Message" := msg;
                        SwizzKashTransTable.Status := SwizzKashTransTable.Status::Completed;
                        SwizzKashTransTable.Posted := TRUE;
                        SwizzKashTransTable."Posting Date" := TODAY;
                        SwizzKashTransTable.Comments := 'POSTED';
                        SwizzKashTransTable.Client := Vendor."No.";
                        SwizzKashTransTable.MODIFY;

                        result := 'TRUE';
                        //result := result + '--done, sending Messages';

                        SMSMessage(docNo, Vendor."No.", Vendor."Mobile Phone No", msg);
                    END;
                END;
            END;

        END;
    END;

    LOCAL PROCEDURE PostWithdrawalTest(docNo: Text[20]) result: Text[330];
    VAR
        bankledgeE: Record 271;
        SwizzKashTransTable: Record "SwizzKash Transactions";
        telephoneNo: Text[20];
        withdrawAmount: Decimal;
        transactionDate: Date;
        AppType: Code[100];
        SwizzKashCharge: Decimal;
        SwizzKashCommACC: Code[100];
    BEGIN
        //result := '';
        result := result + 'Starting PostWithdrawal';
        SwizzKashTransTable.RESET;
        SwizzKashTransTable.SetCurrentKey(SwizzKashTransTable.Entry);

        SwizzKashTransTable.SETRANGE(SwizzKashTransTable."Document No", docNo);
        IF SwizzKashTransTable.FIND('-') THEN BEGIN

            result := result + '--Found Transaction, starting posting.';
            withdrawAmount := SwizzKashTransTable.Amount;
            transactionDate := SwizzKashTransTable."Document Date";
            telephoneNo := SwizzKashTransTable."Telephone Number";

            // check for double posting
            result := result + '--Checking in the Bank Acc Le Entry..';
            bankledgeE.RESET;
            bankledgeE.SETRANGE(bankledgeE."Document No.", docNo);
            IF bankledgeE.FIND('-') THEN BEGIN
                SwizzKashTransTable.Status := SwizzKashTransTable.Status::Completed;
                SwizzKashTransTable.Posted := TRUE;
                SwizzKashTransTable.Comments := 'OK';
                SwizzKashTransTable.MODIFY;
                result := 'REFEXISTS';
                result := result + 'Found its already posted in Bank Account Ledger Entry';
                EXIT;
            END;
            // end check for double posting

            GenLedgerSetup.RESET;
            GenLedgerSetup.GET;
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."MPESA Recon Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TESTFIELD(GenLedgerSetup."SwizzKash Charge");

            result := result + '---fetching charges';
            Charges.RESET;
            Charges.SETRANGE(Charges.Code, GenLedgerSetup."Mobile Charge");
            IF Charges.FIND('-') THEN BEGIN
                Charges.TESTFIELD(Charges."GL Account");

                MPESACharge := GetCharge(withdrawAmount, 'MPESA');
                SwizzKashCharge := GetCharge(withdrawAmount, 'VENDWD');
                MobileCharges := GetCharge(withdrawAmount, 'SACCOWD');

                SwizzKashCommACC := GenLedgerSetup."SwizzKash Comm Acc";
                MPESARecon := GenLedgerSetup."MPESA Recon Acc";
                MobileChargesACC := Charges."GL Account";

                ExcDuty := GetExciseDutyRate() * (MobileCharges);
                TotalCharges := SwizzKashCharge + MobileCharges + ExcDuty + MPESACharge;
                result := result + '--fetched charges';
            END;

            result := result + '--validating member using:' + telephoneNo;
            Vendor.RESET;
            Vendor.SETRANGE(Vendor."Mobile Phone No", telephoneNo);
            // Vendor.SETRANGE(Vendor.Status, Vendor.Status::Active);
            //Vendor.SETRANGE(Vendor."Account Type", 'M-WALLET');
            IF Vendor.FIND('-') THEN BEGIN

                result := result + '--found member.. checking balance';
                Vendor.CALCFIELDS(Vendor."Balance (LCY)");
                Vendor.CalcFields(Vendor."Balance (LCY)");
                Vendor.CalcFields(Vendor."ATM Transactions");
                Vendor.CalcFields(Vendor."Uncleared Cheques");
                Vendor.CalcFields(Vendor."EFT Transactions");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
                IF (true) then begin//TempBalance > 0) THEN BEGIN//true) then begin//
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DELETEALL;
                    //end of deletion

                    GenBatches.RESET;
                    GenBatches.SETRANGE(GenBatches."Journal Template Name", 'GENERAL');
                    GenBatches.SETRANGE(GenBatches.Name, 'MPESAWITHD');

                    IF GenBatches.FIND('-') = FALSE THEN BEGIN
                        GenBatches.INIT;
                        GenBatches."Journal Template Name" := 'GENERAL';
                        GenBatches.Name := 'MPESAWITHD';
                        GenBatches.Description := 'MPESA Withdrawal';
                        GenBatches.VALIDATE(GenBatches."Journal Template Name");
                        GenBatches.VALIDATE(GenBatches.Name);
                        GenBatches.INSERT;
                    END;

                    //DR Customer Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := SwizzKashTransTable."Document Date";
                    GenJournalLine.Description := 'MPESA Withdrawal-' + Vendor."No." + '' + Vendor.Name;
                    GenJournalLine.Amount := withdrawAmount;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Cr Bank a/c
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := MPESARecon;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'MPESA Withdrawal-' + Vendor."No." + '' + Vendor.Name;
                    GenJournalLine.Amount := (withdrawAmount + MPESACharge) * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Dr Withdrawal Charges
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges-' + Vendor."No." + '' + Vendor.Name;
                    GenJournalLine.Amount := TotalCharges;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Mobile Transactions Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := MobileChargesACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := MobileCharges * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := SwizzKashCommACC;
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges';
                    GenJournalLine.Amount := -SwizzKashCharge;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //CR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := FORMAT(ExxcDuty);
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := docNo;
                    GenJournalLine."External Document No." := docNo;
                    GenJournalLine."Posting Date" := transactionDate;
                    GenJournalLine.Description := 'Excise duty';
                    GenJournalLine.Amount := ExcDuty * -1;
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                    IF GenJournalLine.Amount <> 0 THEN
                        GenJournalLine.INSERT;

                    //Post
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                    GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                    IF GenJournalLine.FIND('-') THEN BEGIN
                        REPEAT
                            GLPosting.RUN(GenJournalLine);
                        UNTIL GenJournalLine.NEXT = 0;

                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name", 'GENERAL');
                        GenJournalLine.SETRANGE("Journal Batch Name", 'MPESAWITHD');
                        GenJournalLine.DELETEALL;

                        msg := 'You have withdrawn KES ' + FORMAT(withdrawAmount) + ' from Account ' + Vendor.Name +
                        ' .Thank you for using POLYTECH Sacco Mobile.';

                        SwizzKashTransTable."Account No2" := MPESARecon;
                        SwizzKashTransTable.Charge := TotalCharges;

                        SwizzKashTransTable."SMS Message" := msg;
                        SwizzKashTransTable.Status := SwizzKashTransTable.Status::Completed;
                        SwizzKashTransTable.Posted := TRUE;
                        SwizzKashTransTable."Posting Date" := TODAY;
                        SwizzKashTransTable.Comments := 'POSTED';
                        SwizzKashTransTable.Client := Vendor."No.";
                        SwizzKashTransTable.MODIFY;

                        result := 'TRUE';
                        result := result + '--done, sending Messages';

                        SMSMessage(docNo, Vendor."No.", Vendor."Mobile Phone No", msg);
                    END;
                END;
            END;

        END;
    END;

    // procedure MiniStatement(Phone: Text[20]; DocNumber: Text[20]) MiniStmt: Text[250]
    // begin
    //     begin
    //         SurePESATrans.Reset;
    //         SurePESATrans.SetRange(SurePESATrans."Document No", DocNumber);
    //         if SurePESATrans.Find('-') then begin
    //             MiniStmt := 'REFEXISTS';
    //         end
    //         else begin
    //             MiniStmt := '';
    //             GenLedgerSetup.Reset;
    //             GenLedgerSetup.Get;
    //             GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
    //             GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
    //             GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

    //             Charges.Reset;
    //             Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
    //             if Charges.Find('-') then begin
    //                 Charges.TestField(Charges."GL Account");
    //                 MobileChargesACC := Charges."GL Account";
    //                 MobileCharges := Charges."Charge Amount";
    //                 // MobileCharges:=GetmobileCharges('MINIST');
    //             end;

    //             SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
    //             SurePESACharge := GenLedgerSetup."SwizzKash Charge";
    //             ExcDuty := (10 / 100) * (MobileCharges + SurePESACharge);

    //             Vendor.Reset;
    //             Vendor.SetRange(Vendor."Phone No.", Phone);

    //             if Vendor.Find('-') then begin
    //                 Vendor.CalcFields(Vendor."Balance (LCY)");
    //                 TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
    //                 fosaAcc := Vendor."No.";

    //                 if (TempBalance > SurePESACharge) then begin
    //                     GenJournalLine.Reset;
    //                     GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
    //                     GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
    //                     GenJournalLine.DeleteAll;
    //                     //end of deletion

    //                     GenBatches.Reset;
    //                     GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
    //                     GenBatches.SetRange(GenBatches.Name, 'MOBILETRAN');

    //                     if GenBatches.Find('-') = false then begin
    //                         GenBatches.Init;
    //                         GenBatches."Journal Template Name" := 'GENERAL';
    //                         GenBatches.Name := 'MOBILETRAN';
    //                         GenBatches.Description := 'Mini Statement';
    //                         GenBatches.Validate(GenBatches."Journal Template Name");
    //                         GenBatches.Validate(GenBatches.Name);
    //                         GenBatches.Insert;
    //                     end;


    //                     //Dr Mobile Charges
    //                     LineNo := LineNo + 10000;
    //                     GenJournalLine.Init;
    //                     GenJournalLine."Journal Template Name" := 'GENERAL';
    //                     GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
    //                     GenJournalLine."Line No." := LineNo;
    //                     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
    //                     GenJournalLine."Account No." := Vendor."No.";
    //                     GenJournalLine.Validate(GenJournalLine."Account No.");
    //                     GenJournalLine."Document No." := DocNumber;
    //                     GenJournalLine."External Document No." := Vendor."No.";
    //                     ;
    //                     GenJournalLine."Posting Date" := Today;
    //                     GenJournalLine.Description := 'Mini statement Charges';
    //                     GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
    //                     GenJournalLine.Amount := (MobileCharges) + SurePESACharge;
    //                     GenJournalLine.Validate(GenJournalLine.Amount);
    //                     if GenJournalLine.Amount <> 0 then
    //                         GenJournalLine.Insert;

    //                     //DR Excise Duty
    //                     LineNo := LineNo + 10000;
    //                     GenJournalLine.Init;
    //                     GenJournalLine."Journal Template Name" := 'GENERAL';
    //                     GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
    //                     GenJournalLine."Line No." := LineNo;
    //                     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
    //                     GenJournalLine."Account No." := Vendor."No.";
    //                     ;
    //                     GenJournalLine.Validate(GenJournalLine."Account No.");
    //                     GenJournalLine."Document No." := DocNumber;
    //                     GenJournalLine."External Document No." := Vendor."No.";
    //                     GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
    //                     GenJournalLine."Posting Date" := Today;
    //                     GenJournalLine.Description := 'Excise duty-Mini statement';
    //                     GenJournalLine.Amount := ExcDuty;
    //                     GenJournalLine.Validate(GenJournalLine.Amount);
    //                     if GenJournalLine.Amount <> 0 then
    //                         GenJournalLine.Insert;

    //                     LineNo := LineNo + 10000;
    //                     GenJournalLine.Init;
    //                     GenJournalLine."Journal Template Name" := 'GENERAL';
    //                     GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
    //                     GenJournalLine."Line No." := LineNo;
    //                     GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
    //                     GenJournalLine."Account No." := ExxcDuty;
    //                     GenJournalLine.Validate(GenJournalLine."Account No.");
    //                     GenJournalLine."Document No." := DocNumber;
    //                     GenJournalLine."Source No." := Vendor."No.";
    //                     GenJournalLine."External Document No." := MobileChargesACC;
    //                     GenJournalLine."Posting Date" := Today;
    //                     GenJournalLine.Description := 'Excise duty-Mini statement';
    //                     GenJournalLine.Amount := ExcDuty * -1;
    //                     GenJournalLine.Validate(GenJournalLine.Amount);
    //                     if GenJournalLine.Amount <> 0 then
    //                         GenJournalLine.Insert;

    //                     //CR Commission
    //                     LineNo := LineNo + 10000;
    //                     GenJournalLine.Init;
    //                     GenJournalLine."Journal Template Name" := 'GENERAL';
    //                     GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
    //                     GenJournalLine."Line No." := LineNo;
    //                     GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
    //                     GenJournalLine."Account No." := SurePESACommACC;
    //                     GenJournalLine.Validate(GenJournalLine."Account No.");
    //                     GenJournalLine."Document No." := DocNumber;
    //                     GenJournalLine."External Document No." := MobileChargesACC;
    //                     GenJournalLine."Source No." := Vendor."No.";
    //                     GenJournalLine."Posting Date" := Today;
    //                     GenJournalLine.Description := 'Mini statement Charges';
    //                     GenJournalLine.Amount := -SurePESACharge;
    //                     GenJournalLine.Validate(GenJournalLine.Amount);
    //                     if GenJournalLine.Amount <> 0 then
    //                         GenJournalLine.Insert;

    //                     //CR Mobile Transactions Acc
    //                     LineNo := LineNo + 10000;
    //                     GenJournalLine.Init;
    //                     GenJournalLine."Journal Template Name" := 'GENERAL';
    //                     GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
    //                     GenJournalLine."Line No." := LineNo;
    //                     GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
    //                     GenJournalLine."Account No." := MobileChargesACC;
    //                     GenJournalLine.Validate(GenJournalLine."Account No.");
    //                     GenJournalLine."Document No." := DocNumber;
    //                     GenJournalLine."External Document No." := MobileChargesACC;
    //                     GenJournalLine."Source No." := Vendor."No.";
    //                     GenJournalLine."Posting Date" := Today;
    //                     GenJournalLine.Description := 'Mini statement Charges';
    //                     GenJournalLine.Amount := (MobileCharges) * -1;
    //                     GenJournalLine.Validate(GenJournalLine.Amount);
    //                     if GenJournalLine.Amount <> 0 then
    //                         GenJournalLine.Insert;

    //                     //Post
    //                     GenJournalLine.Reset;
    //                     GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
    //                     GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
    //                     if GenJournalLine.Find('-') then begin
    //                         repeat
    //                         // GLPosting.Run(GenJournalLine);
    //                         until GenJournalLine.Next = 0;
    //                     end;
    //                     GenJournalLine.Reset;
    //                     GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
    //                     GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
    //                     GenJournalLine.DeleteAll;

    //                     SurePESATrans.Init;
    //                     SurePESATrans."Document No" := DocNumber;
    //                     SurePESATrans.Description := 'Mini Statement';
    //                     SurePESATrans."Document Date" := Today;
    //                     SurePESATrans."Account No" := Vendor."No.";
    //                     SurePESATrans."Account No2" := '';
    //                     SurePESATrans.Amount := amount;
    //                     SurePESATrans.Posted := true;
    //                     SurePESATrans."Posting Date" := Today;
    //                     SurePESATrans.Status := SurePESATrans.Status::Closed;
    //                     SurePESATrans.Comments := 'Success';
    //                     SurePESATrans.Client := Vendor."BOSA Account No";
    //                     SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Ministatement;
    //                     SurePESATrans."Transaction Time" := Time;
    //                     SurePESATrans.Insert;

    //                     minimunCount := 1;
    //                     Vendor.CalcFields(Vendor.Balance);
    //                     VendorLedgEntry.Reset;
    //                     VendorLedgEntry.SetCurrentkey(VendorLedgEntry."Entry No.");
    //                     VendorLedgEntry.Ascending(false);
    //                     VendorLedgEntry.SetFilter(VendorLedgEntry.Description, '<>%1', '*Charges*');
    //                     VendorLedgEntry.SetRange(VendorLedgEntry."Vendor No.", Vendor."No.");
    //                     //VendorLedgEntry.SetRange(VendorLedgEntry.Reversed,VendorLedgEntry.Reversed::"0");
    //                     if VendorLedgEntry.FindSet then begin
    //                         MiniStmt := '';
    //                         repeat
    //                             VendorLedgEntry.CalcFields(VendorLedgEntry.Amount);
    //                             amount := VendorLedgEntry.Amount;
    //                             if amount < 1 then
    //                                 amount := amount * -1;
    //                             MiniStmt := MiniStmt + Format(VendorLedgEntry."Posting Date") + ':::' + CopyStr(VendorLedgEntry.Description, 1, 25) + ':::' +
    //                             Format(amount) + '::::';
    //                             minimunCount := minimunCount + 1;
    //                             if minimunCount > 5 then
    //                                 exit
    //                           until VendorLedgEntry.Next = 0;
    //                     end;
    //                 end
    //                 else begin
    //                     MiniStmt := 'INSUFFICIENT';
    //                 end;
    //             end
    //             else begin
    //                 MiniStmt := 'ACCNOTFOUND';
    //             end;
    //         end;
    //     end;
    // end;

    // procedure LoanProducts() LoanTypes: Text[1000]
    // begin
    //     begin
    //         LoanProductsSetup.Reset;
    //         LoanProductsSetup.SetRange(LoanProductsSetup.Source, LoanProductsSetup.Source::FOSA);
    //         if LoanProductsSetup.Find('-') then begin
    //             repeat
    //                 LoanTypes := LoanTypes + ':::' + LoanProductsSetup."Product Description";
    //             until LoanProductsSetup.Next = 0;
    //         end
    //     end
    // end;

    // procedure BOSAAccount(Phone: Text[20]) bosaAcc: Text[20]
    // begin
    //     Vendor.Reset;
    //     Vendor.SetRange(Vendor."Phone No.", Phone);
    //     if Vendor.Find('-') then begin
    //         Members.Reset;
    //         Members.SetRange(Members."No.", Vendor."BOSA Account No");
    //         if Members.Find('-') then begin
    //             bosaAcc := Members."No.";
    //         end;
    //     end;
    // end;

    // procedure MemberAccountNumbers(phone: Text[20]) accounts: Text[250]
    // begin
    //     begin
    //         Vendor.Reset;
    //         Vendor.SetRange(Vendor."Phone No.", phone);
    //         Vendor.SetRange(Vendor.Status, Vendor.Status::Active);
    //         if Vendor.Find('-') then begin
    //             accounts := '';
    //             repeat
    //                 accounts := accounts + '::::' + Vendor."No.";
    //             until Vendor.Next = 0;
    //         end
    //         else begin
    //             accounts := '';
    //         end
    //     end;
    // end;

    // procedure RegisteredMemberDetails(Phone: Text[20]) reginfo: Text[250]
    // begin
    //     begin
    //         Vendor.Reset;
    //         Vendor.SetRange(Vendor."Phone No.", Phone);
    //         if Vendor.Find('-') then begin
    //             Members.Reset;
    //             Members.SetRange(Members."No.", Vendor."BOSA Account No");
    //             if Members.Find('-') then begin
    //                 reginfo := Members."No." + ':::' + Members.Name + ':::' + Format(Members."ID No.") + ':::' + Members."Personal No" + ':::' + Members."E-Mail";
    //             end;
    //         end
    //         else begin
    //             reginfo := '';
    //         end
    //     end;
    // end;

    // procedure DetailedStatement(Phone: Text[20]; lastEntry: Integer) detailedstatement: Text[1023]
    // begin
    //     begin
    //         dateExpression := '<CD-1M>'; // Current date less 3 months
    //         dashboardDataFilter := CalcDate(dateExpression, Today);

    //         Vendor.Reset;
    //         Vendor.SetRange(Vendor."Phone No.", Phone);
    //         detailedstatement := '';
    //         if Vendor.FindSet then
    //             repeat
    //                 minimunCount := 1;
    //                 AccountTypes.Reset;
    //                 AccountTypes.SetRange(AccountTypes.Code, Vendor."Account Type");

    //                 if AccountTypes.FindSet then
    //                     repeat

    //                         DetailedVendorLedgerEntry.Reset;
    //                         DetailedVendorLedgerEntry.SetRange(DetailedVendorLedgerEntry."Vendor No.", Vendor."No.");
    //                         DetailedVendorLedgerEntry.SetFilter(DetailedVendorLedgerEntry."Entry No.", '>%1', lastEntry);
    //                         DetailedVendorLedgerEntry.SetFilter(DetailedVendorLedgerEntry."Posting Date", '>%1', dashboardDataFilter);

    //                         if DetailedVendorLedgerEntry.FindSet then
    //                             repeat

    //                                 VendorLedgerEntry.Reset;
    //                                 VendorLedgerEntry.SetRange(VendorLedgerEntry."Entry No.", DetailedVendorLedgerEntry."Vendor Ledger Entry No.");

    //                                 if VendorLedgerEntry.FindSet then begin
    //                                     if detailedstatement = ''
    //                                     then begin
    //                                         detailedstatement := Format(DetailedVendorLedgerEntry."Entry No.") + ':::' +
    //                                         Format(AccountTypes.Description) + ':::' +
    //                                         Format(DetailedVendorLedgerEntry."Posting Date") + ':::' +
    //                                         Format((DetailedVendorLedgerEntry."Posting Date"), 0, '<Month Text>') + ':::' +
    //                                         Format(Date2dmy((DetailedVendorLedgerEntry."Posting Date"), 3)) + ':::' +
    //                                         Format((DetailedVendorLedgerEntry."Credit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                         Format((DetailedVendorLedgerEntry."Debit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                         Format((DetailedVendorLedgerEntry.Amount), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                         Format(DetailedVendorLedgerEntry."Journal Batch Name") + ':::' +
    //                                         Format(DetailedVendorLedgerEntry."Initial Entry Global Dim. 1") + ':::' +
    //                                         Format(VendorLedgerEntry.Description);
    //                                     end
    //                                     else
    //                                         repeat
    //                                             detailedstatement := detailedstatement + '::::' +
    //                                             Format(DetailedVendorLedgerEntry."Entry No.") + ':::' +
    //                                             Format(AccountTypes.Description) + ':::' +
    //                                             Format(DetailedVendorLedgerEntry."Posting Date") + ':::' +
    //                                             Format((DetailedVendorLedgerEntry."Posting Date"), 0, '<Month Text>') + ':::' +
    //                                             Format(Date2dmy((DetailedVendorLedgerEntry."Posting Date"), 3)) + ':::' +
    //                                             Format((DetailedVendorLedgerEntry."Credit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                             Format((DetailedVendorLedgerEntry."Debit Amount"), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                             Format((DetailedVendorLedgerEntry.Amount), 0, '<Precision,2:2><Integer><Decimals>') + ':::' +
    //                                             Format(DetailedVendorLedgerEntry."Journal Batch Name") + ':::' +
    //                                             Format(DetailedVendorLedgerEntry."Initial Entry Global Dim. 1") + ':::' +
    //                                             Format(VendorLedgerEntry.Description);

    //                                             if minimunCount > 20 then
    //                                                 exit
    //                                         until VendorLedgerEntry.Next = 0;
    //                                 end;
    //                             until DetailedVendorLedgerEntry.Next = 0;
    //                     until AccountTypes.Next = 0;
    //             until Vendor.Next = 0;
    //     end;
    // end;







    local procedure ChargesGuarantorInfo(Phone: Text[20]; DocNumber: Text[20]) result: Text[250]
    begin
        begin
            SurePESATrans.Reset;
            SurePESATrans.SetRange(SurePESATrans."Document No", DocNumber);
            if SurePESATrans.Find('-') then begin
                result := 'REFEXISTS';
            end
            else begin
                result := '';
                GenLedgerSetup.Reset;
                GenLedgerSetup.Get;
                GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

                Charges.Reset;
                Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");
                    MobileChargesACC := Charges."GL Account";
                end;

                SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SurePESACharge := GenLedgerSetup."SwizzKash Charge";

                Vendor.Reset;
                Vendor.SetRange(Vendor."Phone No.", Phone);
                if Vendor.Find('-') then begin
                    Vendor.CalcFields(Vendor."Balance (LCY)");
                    TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
                    fosaAcc := Vendor."No.";

                    if (TempBalance > SurePESACharge) then begin
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                        GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DeleteAll;
                        //end of deletion

                        GenBatches.Reset;
                        GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                        GenBatches.SetRange(GenBatches.Name, 'MOBILETRAN');

                        if GenBatches.Find('-') = false then begin
                            GenBatches.Init;
                            GenBatches."Journal Template Name" := 'GENERAL';
                            GenBatches.Name := 'MOBILETRAN';
                            GenBatches.Description := 'Loan Guarantors Info';
                            GenBatches.Validate(GenBatches."Journal Template Name");
                            GenBatches.Validate(GenBatches.Name);
                            GenBatches.Insert;
                        end;

                        //Dr Mobile Charges
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                        GenJournalLine."Account No." := fosaAcc;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := fosaAcc;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                        GenJournalLine.Description := 'Loan Guarantors Info Charges';
                        GenJournalLine.Amount := SurePESACharge;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;

                        //CR Commission
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                        GenJournalLine."Line No." := LineNo;
                        GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                        GenJournalLine."Account No." := SurePESACommACC;
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        GenJournalLine."Document No." := DocNumber;
                        GenJournalLine."External Document No." := MobileChargesACC;
                        GenJournalLine."Posting Date" := Today;
                        GenJournalLine.Description := 'Loan Guarantors Info Charges';
                        GenJournalLine.Amount := -SurePESACharge;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;

                        //Post
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                        GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                        if GenJournalLine.Find('-') then begin
                            repeat
                            //GLPosting.Run(GenJournalLine);
                            until GenJournalLine.Next = 0;
                        end;
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                        GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                        GenJournalLine.DeleteAll;

                        SurePESATrans.Init;
                        SurePESATrans."Document No" := DocNumber;
                        SurePESATrans.Description := 'Loan Guarantors Info';
                        SurePESATrans."Document Date" := Today;
                        SurePESATrans."Account No" := Vendor."No.";
                        SurePESATrans."Account No2" := '';
                        SurePESATrans.Amount := amount;
                        SurePESATrans.Posted := true;
                        SurePESATrans."Posting Date" := Today;
                        SurePESATrans.Status := SurePESATrans.Status::Completed;
                        SurePESATrans.Comments := 'Success';
                        SurePESATrans.Client := Vendor."BOSA Account No";
                        SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Ministatement;
                        SurePESATrans."Transaction Time" := Time;
                        SurePESATrans.Insert;
                        result := 'TRUE';
                    end
                    else begin
                        result := 'INSUFFICIENT';
                    end;
                end
                else begin
                    result := 'ACCNOTFOUND';
                end;
            end;
        end;
    end;


    local procedure AccountBalanceNew(Acc: Code[30]; DocNumber: Code[20]) Bal: Text[50]
    begin
        begin
            SurePESATrans.Reset;
            SurePESATrans.SetRange(SurePESATrans."Document No", DocNumber);
            if SurePESATrans.Find('-') then begin
                Bal := 'REFEXISTS';
            end
            else begin
                Bal := '';
                GenLedgerSetup.Reset;
                GenLedgerSetup.Get;
                GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
                GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

                Charges.Reset;
                Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
                if Charges.Find('-') then begin
                    Charges.TestField(Charges."GL Account");
                    MobileCharges := Charges."Charge Amount";
                    // MobileCharges:=GetmobileCharges('ACCBAL');
                    MobileChargesACC := Charges."GL Account";
                end;

                SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
                SurePESACharge := GenLedgerSetup."SwizzKash Charge";

                ExcDuty := (10 / 100) * (MobileCharges + SurePESACharge);

                Vendor.Reset;
                Vendor.SetRange(Vendor."No.", Acc);
                if Vendor.Find('-') then begin
                    Vendor.CalcFields(Vendor."Balance (LCY)");
                    TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");

                    if (Vendor."Account Type" = 'M-WALLET') or (Vendor."Account Type" = 'CHURCH') or (Vendor."Account Type" = 'BUSINESS') or (Vendor."Account Type" = 'STAFF')
                      or (Vendor."Account Type" = 'COFFEE') or (Vendor."Account Type" = 'SAVINGS') then begin
                        if (TempBalance > MobileCharges + SurePESACharge) then begin
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DeleteAll;
                            //end of deletion

                            GenBatches.Reset;
                            GenBatches.SetRange(GenBatches."Journal Template Name", 'GENERAL');
                            GenBatches.SetRange(GenBatches.Name, 'MOBILETRAN');

                            if GenBatches.Find('-') = false then begin
                                GenBatches.Init;
                                GenBatches."Journal Template Name" := 'GENERAL';
                                GenBatches.Name := 'MOBILETRAN';
                                GenBatches.Description := 'Balance Enquiry';
                                GenBatches.Validate(GenBatches."Journal Template Name");
                                GenBatches.Validate(GenBatches.Name);
                                GenBatches.Insert;
                            end;

                            //Dr Mobile Charges
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Account No." := Acc;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := Acc;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                            GenJournalLine.Description := 'Balance Enquiry ' + COPYSTR(Vendor.Name, 1, 20);
                            GenJournalLine.Amount := MobileCharges + SurePESACharge;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //DR Excise Duty
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Account No." := Acc;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := Acc;
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                            GenJournalLine.Description := 'Excise duty-Balance Enquiry ' + COPYSTR(Vendor.Name, 1, 20);
                            GenJournalLine.Amount := ExcDuty;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := ExxcDuty;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Excise duty-Balance Enquiry ' + COPYSTR(Vendor.Name, 1, 20);
                            GenJournalLine.Amount := ExcDuty * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //CR Commission
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := SurePESACommACC;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Balance Enquiry Charges ' + COPYSTR(Vendor.Name, 1, 20);
                            GenJournalLine.Amount := -SurePESACharge;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //CR Mobile Transactions Acc
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'MOBILETRAN';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := MobileChargesACC;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Document No." := DocNumber;
                            GenJournalLine."External Document No." := MobileChargesACC;
                            GenJournalLine."Source No." := Vendor."No.";
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Balance Enquiry Charges ' + COPYSTR(Vendor.Name, 1, 20);
                            GenJournalLine.Amount := MobileCharges * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //Post
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            if GenJournalLine.Find('-') then begin
                                repeat
                                //GLPosting.Run(GenJournalLine);
                                until GenJournalLine.Next = 0;
                            end;
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'MOBILETRAN');
                            GenJournalLine.DeleteAll;

                            SurePESATrans.Init;
                            SurePESATrans."Document No" := DocNumber;
                            SurePESATrans.Description := 'Balance Enquiry';
                            SurePESATrans."Document Date" := Today;
                            SurePESATrans."Account No" := Vendor."No.";
                            SurePESATrans."Account No2" := '';
                            SurePESATrans.Amount := amount;
                            SurePESATrans.Posted := true;
                            SurePESATrans."Posting Date" := Today;
                            SurePESATrans.Status := SurePESATrans.Status::Completed;
                            SurePESATrans.Comments := 'Success';
                            SurePESATrans.Client := Vendor."BOSA Account No";
                            SurePESATrans."Transaction Type" := SurePESATrans."transaction type"::Balance;
                            SurePESATrans."Transaction Time" := Time;
                            SurePESATrans.Insert;
                            AccountTypes.Reset;
                            AccountTypes.SetRange(AccountTypes.Code, Vendor."Account Type");
                            if AccountTypes.Find('-') then begin
                                miniBalance := AccountTypes."Minimum Balance";
                            end;
                            Vendor.CalcFields(Vendor."Balance (LCY)");
                            Vendor.CalcFields(Vendor."ATM Transactions");
                            Vendor.CalcFields(Vendor."Uncleared Cheques");
                            Vendor.CalcFields(Vendor."EFT Transactions");
                            accBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");
                            msg := 'Account Name: ' + Vendor.Name + ', ' + 'BALANCE: ' + Format(accBalance) + '. '
                           + 'POLYTECH Mobile';
                            SMSMessage(DocNumber, Vendor."No.", Vendor."Phone No.", msg);
                            Bal := 'TRUE';
                        end
                        else begin
                            Bal := 'INSUFFICIENT';
                        end;
                    end
                    else begin
                        AccountTypes.Reset;
                        AccountTypes.SetRange(AccountTypes.Code, Vendor."Account Type");
                        if AccountTypes.Find('-') then begin
                            miniBalance := AccountTypes."Minimum Balance";
                        end;
                    end;
                end
                else begin
                    Bal := 'ACCNOTFOUND';
                end;
            end;
        end;
    end;


    local procedure PostMPESATrans(documentNo: Text[20]; telephoneNo: Text[20]; amount: Decimal) result: Text[30]
    begin

        SurePESATrans.Reset;
        SurePESATrans.SetRange(SurePESATrans."Document No", documentNo);
        if SurePESATrans.Find('-') then begin
            result := 'REFEXISTS';
        end
        else begin

            GenLedgerSetup.Reset;
            GenLedgerSetup.Get;
            GenLedgerSetup.TestField(GenLedgerSetup."Mobile Charge");
            GenLedgerSetup.TestField(GenLedgerSetup."MPESA Recon Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Comm Acc");
            GenLedgerSetup.TestField(GenLedgerSetup."SwizzKash Charge");

            Charges.Reset;
            Charges.SetRange(Charges.Code, GenLedgerSetup."Mobile Charge");
            if Charges.Find('-') then begin
                Charges.TestField(Charges."GL Account");

                MPESACharge := GetCharge('MPESA', amount);
                SurePESACharge := GetCharge('VENDWD', amount);
                MobileCharges := GetCharge('SACCOWD', amount);

                SurePESACommACC := GenLedgerSetup."SwizzKash Comm Acc";
                MPESARecon := GenLedgerSetup."MPESA Recon Acc";
                MobileChargesACC := Charges."GL Account";

                ExcDuty := (10 / 100) * (MobileCharges + SurePESACharge);
                TotalCharges := SurePESACharge + MobileCharges + MPESACharge;
            end;

            Vendor.Reset;
            Vendor.SetRange(Vendor."No.", telephoneNo);
            // IF  (Vendor."Account Type"='SALIMIA') OR (Vendor."Account Type"='STAFF') OR (Vendor."Account Type"='SAVINGS')OR (Vendor."Account Type"='CHURCH')OR (Vendor."Account Type"='BUSINESS')OR (Vendor."Account Type"='COFFEE') THEN BEGIN
            if Vendor.Find('-') then begin
                Vendor.CalcFields(Vendor."Balance (LCY)");
                TempBalance := Vendor."Balance (LCY)" - (Vendor."ATM Transactions" + Vendor."Uncleared Cheques" + Vendor."EFT Transactions");

                if (TempBalance > amount + TotalCharges + MPESACharge) then begin
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
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactions;
                    GenJournalLine.Description := 'MPESA Withdrawal-' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := amount;
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
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::MobileTransactionCharges;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := TotalCharges;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;
                    /*
                            //Dr MPESA Charges
                                    LineNo:=LineNo+10000;
                                    GenJournalLine.INIT;
                                    GenJournalLine."Journal Template Name":='GENERAL';
                                    GenJournalLine."Journal Batch Name":='MPESAWITHD';
                                    GenJournalLine."Line No.":=LineNo;
                                    GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
                                    GenJournalLine."Account No.":=Vendor."No.";
                                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                    GenJournalLine."Document No.":=documentNo;
                                    GenJournalLine."External Document No.":=Vendor."No.";
                                    GenJournalLine."Posting Date":=TODAY;
                                    GenJournalLine.Description:='MPESA Withdrawal Charges';
                                    GenJournalLine.Amount:=MPESACharge;
                                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                    IF GenJournalLine.Amount<>0 THEN
                                    GenJournalLine.INSERT;
                    */
                    //Cr MPESA ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := MPESARecon;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Withdrawal to MPESA' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := (amount) * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;
                    //Cr MPESA ACC
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := MPESARecon;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'MPESA Withdrawal Charges' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := (MPESACharge) * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;
                    //DR Excise Duty
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                    GenJournalLine."Account No." := Vendor."No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine."Mobile Transaction Type" := GenJournalLine."Mobile Transaction Type"::ExciseDuty;
                    GenJournalLine.Description := 'Excise duty-Mobile Withdrawal' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := ExcDuty;
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
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Excise duty-Mobile Withdrawal' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := ExcDuty * -1;
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
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := MobileCharges * -1;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //CR Surestep Acc
                    LineNo := LineNo + 10000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'MPESAWITHD';
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                    GenJournalLine."Account No." := SurePESACommACC;
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Document No." := documentNo;
                    GenJournalLine."External Document No." := MobileChargesACC;
                    GenJournalLine."Source No." := Vendor."No.";
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Mobile Withdrawal Charges' + Vendor."No." + '' + COPYSTR(Vendor.Name, 1, 20);
                    GenJournalLine.Amount := -SurePESACharge;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    //Post
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'MPESAWITHD');
                    if GenJournalLine.Find('-') then begin
                        repeat
                        //GLPosting.Run(GenJournalLine);
                        until GenJournalLine.Next = 0;
                    end;
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'MPESAWITHD');
                    GenJournalLine.DeleteAll;

                    SurePESATrans.Init;
                    SurePESATrans."Document No" := documentNo;
                    SurePESATrans.Description := 'MPESA Withdrawal' + Vendor."No.";
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
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
                    msg := 'You have withdrawn KES ' + Format(amount) + ' from Account ' + Vendor.Name + ' thank you for using POLYTECH Sacco Mobile.';
                    SMSMessage(documentNo, Vendor."No.", Vendor."Phone No.", msg);
                end
                else begin
                    result := 'INSUFFICIENT';
                    /* msg:='You have insufficient funds in your savings Account to use this service.'+
                    ' .Thank you for using POLYTECH Sacco Mobile.';
                    SMSMessage(documentNo,Vendor."No.",Vendor."Phone No.",msg);*/
                    SurePESATrans.Init;
                    SurePESATrans."Document No" := documentNo;
                    SurePESATrans.Description := 'MPESA Withdrawal';
                    SurePESATrans."Document Date" := Today;
                    SurePESATrans."Account No" := Vendor."No.";
                    SurePESATrans."Account No2" := MPESARecon;
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
                 ' .Thank you for using POLYTECH Sacco Mobile.';
                 SMSMessage(documentNo,Vendor."No.",Vendor."Phone No.",msg);*/
                SurePESATrans.Init;
                SurePESATrans."Document No" := documentNo;
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

    local procedure AccountDescription("code": Text[20]) description: Text[100]
    begin
        begin
            AccountTypes.Reset;
            AccountTypes.SetRange(AccountTypes.Code, code);
            if AccountTypes.Find('-') then begin
                description := AccountTypes.Description;
            end
            else begin
                description := '';
            end
        end;
    end;








}

