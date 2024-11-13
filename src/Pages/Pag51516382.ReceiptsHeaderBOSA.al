#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516382 "Receipts Header-BOSA"
{
    DeleteAllowed = false;
    Editable = true;
    PageType = Card;
    SourceTable = "Receipts & Payments";

    layout
    {
        area(content)
        {
            group(Transaction)
            {
                Caption = 'Transaction';
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Mode"; Rec."Receipt Mode")
                {
                    ApplicationArea = Basic;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                }
                field("Allocated Amount"; Rec."Allocated Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Un allocated Amount"; Rec."Un allocated Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Employer No."; Rec."Employer No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Teller Till / Bank  No.';
                }
                field("Cheque No."; Rec."Cheque No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cheque / Slip  No.';
                }
                field("Cheque Date"; Rec."Cheque Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cheque / Slip  Date';
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field(Insurance; Rec.Insuarance)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(Suggest)
            {
                Caption = 'Suggest';
                action("Cash/Cheque Clearance")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cash/Cheque Clearance';

                    trigger OnAction()
                    begin
                        Cheque := false;
                        //SuggestBOSAEntries();
                    end;
                }
                separator(Action1102760032)
                {
                }
                action("Suggest Payments")
                {
                    ApplicationArea = Basic;
                    Caption = 'Suggest Monthy Repayments';

                    trigger OnAction()
                    begin

                        Rec.TestField(Posted, false);
                        Rec.TestField("Account No.");
                        Rec.TestField(Amount);
                        //Cust.CALCFIELDS(Cust."Registration Fee Paid");

                        ReceiptAllocations.Reset;
                        ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                        ReceiptAllocations.DeleteAll;


                        if Rec."Account Type" = Rec."account type"::Member then begin

                            BosaSetUp.Get();
                            RunBal := Rec.Amount;

                            if RunBal > 0 then begin

                                if Cust.Get(Rec."Account No.") then begin
                                    Cust.CalcFields(Cust."Registration Fee Paid");
                                    if Cust."Registration Fee Paid" = 0 then begin
                                        if Cust."Registration Date" > 20140103D then begin
                                            ReceiptAllocations.Init;
                                            ReceiptAllocations."Document No" := Rec."Transaction No.";
                                            ReceiptAllocations."Member No" := Rec."Account No.";
                                            ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Registration Fee";
                                            ReceiptAllocations."Loan No." := '';
                                            ReceiptAllocations.Amount := BosaSetUp."Registration Fee";
                                            //ReceiptAllocations."Interest Amount":=Loans."Interest Due";
                                            ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount;
                                            ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                            ReceiptAllocations."Global Dimension 2 Code" := '01';
                                            ReceiptAllocations.Insert;
                                            RunBal := RunBal - ReceiptAllocations.Amount;
                                        end;
                                    end;
                                end;
                                //********** Mpesa Charges
                                if Rec."Receipt Mode" = Rec."receipt mode"::"Standing order" then begin
                                    ReceiptAllocations.Init;
                                    ReceiptAllocations."Document No" := Rec."Transaction No.";
                                    ReceiptAllocations."Member No" := Rec."Account No.";
                                    ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"35";
                                    ReceiptAllocations."Loan No." := '';

                                    // M Pesa Tarriff

                                    if Rec.Amount <= 2499 then
                                        ReceiptAllocations."Total Amount" := 55
                                    else if Rec.Amount <= 4999 then
                                        ReceiptAllocations."Total Amount" := 75
                                    else if Rec.Amount <= 9999 then
                                        ReceiptAllocations."Total Amount" := 105
                                    else if Rec.Amount <= 19999 then
                                        ReceiptAllocations."Total Amount" := 130
                                    else if Rec.Amount <= 34999 then
                                        ReceiptAllocations."Total Amount" := 185
                                    else if Rec.Amount <= 49999 then
                                        ReceiptAllocations."Total Amount" := 220
                                    else if Rec.Amount <= 70000 then
                                        ReceiptAllocations."Total Amount" := 240
                                    else if Rec.Amount > 70000 then
                                        Error('Sorry the Maximum M - Pesa transaction Amount is Ksha. 70,000');


                                    ReceiptAllocations.Amount := ReceiptAllocations."Total Amount";
                                    ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                    ReceiptAllocations."Global Dimension 2 Code" := '01';
                                    ReceiptAllocations.Insert;
                                end;
                                //********** END Mpesa Charges

                                if RunBal > 0 then begin
                                    //Loan Repayments
                                    Loans.Reset;
                                    Loans.SetCurrentkey(Loans.Source, Loans."Client Code");
                                    Loans.SetRange(Loans."Client Code", Rec."Account No.");
                                    Loans.SetRange(Loans.Source, Loans.Source::" ");
                                    if Loans.Find('-') then begin
                                        repeat

                                            //Insurance Charge
                                            Loans.CalcFields(Loans."Outstanding Balance", Loans."Interest Due", Loans."Loans Insurance", Loans."Oustanding Interest");
                                            if (Loans."Outstanding Balance" > 0) and (Loans."Approved Amount" > 100000) and
                                            (Loans."Loans Insurance" > 0) then begin



                                                ReceiptAllocations.Init;
                                                ReceiptAllocations."Document No" := Rec."Transaction No.";
                                                ReceiptAllocations."Member No" := Rec."Account No.";
                                                ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"37";
                                                ReceiptAllocations."Loan No." := Loans."Loan  No.";
                                                ReceiptAllocations."Loan ID" := Loans."Loan Product Type";
                                                ReceiptAllocations.Amount := Loans."Loans Insurance";
                                                //MESSAGE('ReceiptAllocations.Amount is %1',ReceiptAllocations.Amount);
                                                ReceiptAllocations."Amount Balance" := Loans."Outstanding Balance";
                                                ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount;
                                                ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                                ReceiptAllocations."Global Dimension 2 Code" := '01';
                                                ReceiptAllocations.Insert;
                                            end;


                                            if (Loans."Outstanding Balance") > 0 then begin
                                                LOustanding := 0;
                                                ReceiptAllocations.Init;
                                                ReceiptAllocations."Document No" := Rec."Transaction No.";
                                                ReceiptAllocations."Member No" := Rec."Account No.";
                                                ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Interest Paid";
                                                ReceiptAllocations."Loan No." := Loans."Loan  No.";
                                                ReceiptAllocations."Loan ID" := Loans."Loan Product Type";
                                                //ReceiptAllocations.Amount:=Loans.Repayment-Loans."Loans Insurance"-Loans."Oustanding Interest";
                                                ReceiptAllocations.Amount := Loans."Loan Principle Repayment";
                                                ReceiptAllocations."Amount Balance" := Loans."Outstanding Balance";
                                                ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount + ReceiptAllocations."Interest Amount";
                                                ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                                ReceiptAllocations."Global Dimension 2 Code" := '01';
                                                ReceiptAllocations.Insert;
                                            end;

                                            if (Loans."Oustanding Interest" > 0) then begin
                                                ReceiptAllocations.Init;
                                                ReceiptAllocations."Document No" := Rec."Transaction No.";
                                                ReceiptAllocations."Member No" := Rec."Account No.";
                                                ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Insurance Contribution";
                                                ReceiptAllocations."Loan No." := Loans."Loan  No.";
                                                ReceiptAllocations.Amount := Loans."Oustanding Interest";
                                                //ReceiptAllocations.Amount:=Loans."Loan Interest Repayment";
                                                //ReceiptAllocations.Amount:=Loans."Interest Due";
                                                ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount + ReceiptAllocations."Interest Amount";
                                                ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                                ReceiptAllocations."Global Dimension 2 Code" := '01';
                                                ReceiptAllocations.Insert;
                                            end;

                                            RunBal := RunBal - ReceiptAllocations.Amount;
                                            Message('RunBal is %1', RunBal);

                                        until Loans.Next = 0;
                                    end;
                                end;
                            end;
                            BosaSetUp.Get();
                            ReceiptAllocations.Init;
                            ReceiptAllocations."Document No" := Rec."Transaction No.";
                            ReceiptAllocations."Member No" := Rec."Account No.";
                            ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Benevolent Fund";
                            ReceiptAllocations."Loan No." := ' ';
                            ReceiptAllocations.Amount := BosaSetUp."Welfare Contribution";
                            ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount;
                            ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                            ReceiptAllocations."Global Dimension 2 Code" := '01';
                            ReceiptAllocations.Insert;

                            //Deposits Contribution
                            if Cust.Get(Rec."Account No.") then begin
                                if Cust."Monthly Contribution" > 0 then begin
                                    ReceiptAllocations.Init;
                                    ReceiptAllocations."Document No" := Rec."Transaction No.";
                                    ReceiptAllocations."Member No" := Rec."Account No.";
                                    ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::Loan;
                                    ReceiptAllocations."Loan No." := '';
                                    ReceiptAllocations.Amount := ROUND(Cust."Monthly Contribution", 0.01);
                                    ;
                                    ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount;
                                    ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                    ReceiptAllocations."Global Dimension 2 Code" := '01';
                                    ReceiptAllocations.Insert;
                                end;
                            end;

                            //Shares Contribution
                            if Cust.Get(Rec."Account No.") then begin
                                Cust.CalcFields(Cust."Shares Retained");

                                if Cust."Shares Retained" < 5000 then begin
                                    BosaSetUp.Get();
                                    if BosaSetUp."Monthly Share Contributions" > 0 then begin
                                        //IF CONFIRM('This member has reached a maximum share contribution of Kshs. 5,000/=. Do you want to post this transaction as shares contribution?',TRUE)=TRUE THEN
                                        //IF CONFIRM(Text001,TRUE) THEN BEGIN
                                        ReceiptAllocations.Init;
                                        ReceiptAllocations."Document No" := Rec."Transaction No.";
                                        ReceiptAllocations."Member No" := Rec."Account No.";
                                        ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Recovery Account";
                                        ReceiptAllocations."Loan No." := '';
                                        ReceiptAllocations.Amount := ROUND(BosaSetUp."Monthly Share Contributions", 0.01);
                                        ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount;
                                        ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                        ReceiptAllocations."Global Dimension 2 Code" := '01';
                                        ReceiptAllocations.Insert;
                                    end;
                                end;
                            end;
                        end;

                        if Rec."Account Type" = Rec."account type"::Vendor then begin
                            if Rec."Receipt Mode" = Rec."receipt mode"::"Standing order" then begin
                                ReceiptAllocations.Init;
                                ReceiptAllocations."Document No" := Rec."Transaction No.";
                                ReceiptAllocations."Member No" := Rec."Account No.";

                                ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"35";
                                ReceiptAllocations."Total Amount" := Rec.Amount;
                                ReceiptAllocations."Loan No." := '';


                                // M Pesa Tarriff
                                MpesaCharge := 0;
                                if Rec.Amount <= 2499 then
                                    ReceiptAllocations."Total Amount" := 55
                                else if Rec.Amount <= 4999 then
                                    ReceiptAllocations."Total Amount" := 75
                                else if Rec.Amount <= 9999 then
                                    ReceiptAllocations."Total Amount" := 105
                                else if Rec.Amount <= 19999 then
                                    ReceiptAllocations."Total Amount" := 130
                                else if Rec.Amount <= 34999 then
                                    ReceiptAllocations."Total Amount" := 185
                                else if Rec.Amount <= 49999 then
                                    ReceiptAllocations."Total Amount" := 220
                                else if Rec.Amount <= 70000 then
                                    ReceiptAllocations."Total Amount" := 240
                                else if Rec.Amount > 70000 then
                                    Error('Sorry the Maximum M - Pesa transaction Amount is Ksha. 70,000');
                                MpesaCharge := ReceiptAllocations."Total Amount";
                                ReceiptAllocations.Amount := ReceiptAllocations."Total Amount";

                                //ReceiptAllocations."Total Amount":=Amount;
                                ReceiptAllocations."Global Dimension 1 Code" := 'BOSA';
                                ReceiptAllocations."Global Dimension 2 Code" := '01';
                                ReceiptAllocations.Insert;
                            end;

                            //********** END Mpesa Charges


                            ReceiptAllocations.Init;
                            ReceiptAllocations."Document No" := Rec."Transaction No.";
                            ReceiptAllocations."Member No" := Rec."Account No.";
                            ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"38";
                            //GenJournalLine.Description:= 'BT'+'-'+Remarks+'-'+FORMAT("Mode of Payment")+'-'+"Cheque No.";
                            ReceiptAllocations."Loan No." := ' ';
                            ReceiptAllocations."Total Amount" := REC.Amount;
                            ReceiptAllocations."Global Dimension 1 Code" := 'FOSA';
                            ReceiptAllocations."Global Dimension 2 Code" := '01';
                            ReceiptAllocations.Amount := ReceiptAllocations."Total Amount";
                            ReceiptAllocations.Insert;



                        end;
                        //VALIDATE("Allocated Amount");
                        Rec.CalcFields("Allocated Amount");
                        Rec."Un allocated Amount" := (Rec.Amount - Rec."Allocated Amount");
                        Rec.Modify;
                    end;
                }
            }
        }
        area(processing)
        {
            action(Post)
            {
                ApplicationArea = Basic;
                Caption = 'Post (F11)';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if FundsUser.Get(UserId) then begin
                        FundsUser.TestField(FundsUser."Receipt Journal Template");
                        FundsUser.TestField(FundsUser."Receipt Journal Batch");
                        JournalTemplate := FundsUser."Receipt Journal Template";
                        JournalBatch := FundsUser."Receipt Journal Batch";
                    end else begin
                        Error('User Account Not Setup for Posting');
                    end;
                    if (Rec."Receipt Mode" = Rec."receipt mode"::Cheque) and (Rec."Transaction Date" <> Today) then
                        Error('You cannot post cash transactions with a date not today');

                    if Rec.Posted then
                        Error('This receipt is already posted');

                    Rec.TestField("Account No.");
                    Rec.TestField(Amount);
                    Rec.TestField("Employer No.");
                    //TESTFIELD("Cheque No.");
                    //TESTFIELD("Cheque Date");

                    if (Rec."Account Type" = Rec."account type"::"G/L Account") or
                       (Rec."Account Type" = Rec."account type"::Debtor) then
                        TransType := 'Withdrawal'
                    else
                        TransType := 'Deposit';

                    BOSABank := Rec."Employer No.";
                    if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::"FOSA Loan") then begin

                        if Rec.Amount <> Rec."Allocated Amount" then
                            Error('Receipt amount must be equal to the allocated amount.');
                    end;

                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
                    GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
                    GenJournalLine.DeleteAll;


                    LineNo := LineNo + 10000;

                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := JournalTemplate;
                    GenJournalLine."Journal Batch Name" := JournalBatch;
                    GenJournalLine."Document No." := Rec."Transaction No.";
                    GenJournalLine."External Document No." := Rec."Cheque No.";
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := Rec."Employer No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    //GenJournalLine."Posting Date":="Cheque Date";
                    GenJournalLine."Posting Date" := Rec."Transaction Date";
                    GenJournalLine.Description := 'BT-' + Rec."Account No." + '-' + Rec.Remarks;
                    GenJournalLine.Validate(GenJournalLine."Currency Code");
                    GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                    GenJournalLine."Shortcut Dimension 2 Code" := '01';
                    if TransType = 'Withdrawal' then
                        GenJournalLine.Amount := -Rec.Amount
                    else
                        GenJournalLine.Amount := Rec.Amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    if (Rec."Account Type" <> Rec."account type"::Member) and (Rec."Account Type" <> Rec."account type"::"FOSA Loan") and (Rec."Account Type" <> Rec."account type"::Vendor) then begin
                        LineNo := LineNo + 10000;

                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := JournalTemplate;
                        GenJournalLine."Journal Batch Name" := JournalBatch;
                        GenJournalLine."Document No." := Rec."Transaction No.";
                        GenJournalLine."External Document No." := Rec."Cheque No.";
                        GenJournalLine."Line No." := LineNo;
                        if Rec."Account Type" = Rec."account type"::"G/L Account" then
                            GenJournalLine."Account Type" := Rec."Account Type"
                        else if Rec."Account Type" = Rec."account type"::Debtor then
                            GenJournalLine."Account Type" := Rec."Account Type"
                        else if Rec."Account Type" = Rec."account type"::Vendor then
                            GenJournalLine."Account Type" := Rec."Account Type"
                        else if Rec."Account Type" = Rec."account type"::Member then
                            GenJournalLine."Account Type" := Rec."Account Type";
                        GenJournalLine."Account No." := Rec."Account No.";
                        GenJournalLine.Validate(GenJournalLine."Account No.");
                        //GenJournalLine."Posting Date":="Cheque Date";
                        GenJournalLine."Posting Date" := Rec."Transaction Date";
                        GenJournalLine.Description := 'BT-' + Rec.Name + '-' + Rec."Account No." + '-' + Rec.Remarks;
                        GenJournalLine.Validate(GenJournalLine."Currency Code");
                        if TransType = 'Withdrawal' then
                            GenJournalLine.Amount := Rec.Amount
                        else
                            GenJournalLine.Amount := -Rec.Amount;
                        GenJournalLine.Validate(GenJournalLine.Amount);
                        GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;

                    end;

                    GenSetup.Get();

                    if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::"FOSA Loan") or (Rec."Account Type" = Rec."account type"::Vendor) then begin

                        ReceiptAllocations.Reset;
                        ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                        if ReceiptAllocations.Find('-') then begin
                            repeat

                                LineNo := LineNo + 10000;
                                GenJournalLine.Init;
                                GenJournalLine."Journal Template Name" := JournalTemplate;
                                GenJournalLine."Journal Batch Name" := JournalBatch;
                                GenJournalLine."Line No." := LineNo;
                                GenJournalLine."Document No." := Rec."Transaction No.";
                                GenJournalLine."External Document No." := Rec."Cheque No.";
                                //GenJournalLine."Posting Date":="Cheque Date";
                                GenJournalLine."Posting Date" := Rec."Transaction Date";
                                if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"38" then begin
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                    GenJournalLine."Account No." := Rec."Account No.";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'BT-' + Rec.Name + '-' + Rec."Account No." + '-' + Remarks;
                                    GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                                    GenJournalLine."Shortcut Dimension 2 Code" := '01';
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");

                                end else begin
                                    if Rec."Account Type" = Rec."account type"::Vendor then begin
                                        GenJournalLine."Posting Date" := Rec."Transaction Date";
                                        GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                                        GenJournalLine."Shortcut Dimension 2 Code" := '01';
                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                        //GenJournalLine.Description:=FORMAT(ReceiptAllocations."Transaction Type")+'-'+Remarks;
                                        //GenJournalLine.Description:='BT-'+Name+'-'+"Account No."+'-'+Remarks;
                                        //GenJournalLine.Description:='BT'+'-'+Remarks+'-'+FORMAT("Mode of Payment")+'-'+"Cheque No.";

                                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                        GenJournalLine."Account No." := ReceiptAllocations."Member No";
                                        GenJournalLine.Validate(GenJournalLine."Account No.");

                                        if (Rec."Receipt Mode" = Rec."receipt mode"::"Standing order") and (ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"35") then begin
                                            GenJournalLine.Amount := -Rec.Amount;
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                            GenJournalLine."Account No." := GenSetup."FOSA MPESA COmm A/C";
                                            GenJournalLine.Description := Format(ReceiptAllocations."Transaction Type") + '-' + Remarks;
                                            GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::Vendor;
                                            GenJournalLine."Bal. Account No." := Rec."Account No.";

                                        end;
                                    end;

                                    if Rec."Account Type" = Rec."account type"::Member then begin
                                        GenJournalLine."Posting Date" := Rec."Transaction Date";
                                        GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                                        GenJournalLine."Shortcut Dimension 2 Code" := '01';
                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                        GenJournalLine."Account Type" := GenJournalLine."account type"::Investor;
                                        GenJournalLine."Account No." := ReceiptAllocations."Member No";
                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                        if (Rec."Receipt Mode" = Rec."receipt mode"::"Standing order") and (ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"35") then begin
                                            GenJournalLine.Amount := -Rec.Amount;
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                            GenJournalLine."Account No." := GenSetup."FOSA MPESA COmm A/C";
                                            GenJournalLine.Description := Format(ReceiptAllocations."Transaction Type") + '-' + Remarks;
                                        end;
                                    end;
                                end;
                                //GenJournalLine."Prepayment date":=ReceiptAllocations."Prepayment Date";
                                //IF ("Mode of Payment"="Mode of Payment"::Mpesa) AND (ReceiptAllocations."Transaction Type" = ReceiptAllocations."Transaction Type"::"Administration Fee") THEN
                                //GenJournalLine.Amount:=-ReceiptAllocations.Amount
                                //ELSE
                                GenJournalLine.Amount := -ReceiptAllocations.Amount;
                                GenJournalLine."Shortcut Dimension 1 Code" := ReceiptAllocations."Global Dimension 1 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                GenJournalLine."Shortcut Dimension 2 Code" := ReceiptAllocations."Global Dimension 2 Code";
                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                GenJournalLine.Validate(GenJournalLine.Amount);
                                //description
                                if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Insurance Contribution" then
                                    GenJournalLine.Description := 'Interest' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"37" then
                                    GenJournalLine.Description := 'L-Insurance' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Benevolent Fund" then
                                    GenJournalLine.Description := 'Insurance' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Registration Fee" then
                                    GenJournalLine.Description := 'Registration' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Interest Paid" then
                                    GenJournalLine.Description := 'Repayment' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Loan Insurance Paid" then
                                    GenJournalLine.Description := 'Unallocated' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"29" then
                                    GenJournalLine.Description := 'Lukenya' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"31" then
                                    GenJournalLine.Description := 'juja' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"30" then
                                    GenJournalLine.Description := 'Konza' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"33" then
                                    GenJournalLine.Description := 'Title' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"32" then
                                    GenJournalLine.Description := 'Water' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::Loan then
                                    GenJournalLine.Description := 'Deposit' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Recovery Account" then
                                    GenJournalLine.Description := 'Share' + '-' + rEC.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Benevolent Fund" then
                                    GenJournalLine.Description := 'Benevolent' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No."
                                else
                                    GenJournalLine.Description := 'BT' + '-' + Rec.Remarks + '-' + Format(Rec."Receipt Mode") + '-' + Rec."Cheque No.";

                                //description
                                GenJournalLine."Transaction Type" := ReceiptAllocations."Transaction Type";
                                GenJournalLine."Loan No" := ReceiptAllocations."Loan No.";
                                if GenJournalLine.Amount <> 0 then
                                    GenJournalLine.Insert;
                            /*
                          IF (ReceiptAllocations."Transaction Type" = ReceiptAllocations."Transaction Type"::Withdrawal) AND
                             (ReceiptAllocations."Interest Amount" > 0) THEN BEGIN
                          LineNo:=LineNo+10000;

                          GenJournalLine.INIT;
                          GenJournalLine."Journal Template Name":=JournalTemplate;
                          GenJournalLine."Journal Batch Name":=JournalBatch;
                          GenJournalLine."Line No.":=LineNo;
                          GenJournalLine."Document No.":="Transaction No.";
                          GenJournalLine."External Document No.":="Cheque No.";
                          GenJournalLine."Posting Date":="Cheque Date";
                          GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
                          GenJournalLine."Account No.":=ReceiptAllocations."Member No";
                          //GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                          GenJournalLine.Description:='Interest Paid'+'-'+Remarks;
                          GenJournalLine.Amount:=-ReceiptAllocations."Interest Amount";
                          GenJournalLine.VALIDATE(GenJournalLine.Amount);
                          GenJournalLine."Transaction Type":=GenJournalLine."Transaction Type"::"Interest Paid";
                          GenJournalLine."Loan No":=ReceiptAllocations."Loan No.";
                          IF GenJournalLine.Amount<>0 THEN
                          GenJournalLine.INSERT;

                          END;
                           */
                            until ReceiptAllocations.Next = 0;
                        end;


                    end;

                    //Post New
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", JournalTemplate);
                    GenJournalLine.SetRange("Journal Batch Name", JournalBatch);
                    if GenJournalLine.Find('-') then begin


                        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
                    end;
                    //Post New

                    Rec.Posted := true;
                    Rec.Modify;
                    BOSARcpt.Reset;
                    BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                    if BOSARcpt.Find('-') then
                        if/* ("Mode of Payment"<>"Mode of Payment"::"Standing order") AND */
                          //("Mode of Payment"<>"Mode of Payment"::"Direct Debit") AND
                           (Rec."Receipt Mode" <> Rec."receipt mode"::"Standing order") then begin

                            BOSARcpt.Reset;
                            BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                            if BOSARcpt.Find('-') then
                                Report.Run(51516387, false, true, BOSARcpt);

                        end;

                end;
            }
            action("Reprint Frecipt")
            {
                ApplicationArea = Basic;
                Caption = 'Reprint Receipt';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Rec.TestField(Posted);

                    BOSARcpt.Reset;
                    BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                    if BOSARcpt.Find('-') then
                        Report.Run(51516387, true, true, BOSARcpt)
                end;
            }
        }
    }

    var
        GenJournalLine: Record "Gen. Journal Line";
        InterestPaid: Decimal;
        PaymentAmount: Decimal;
        RunBal: Decimal;
        Recover: Boolean;
        Cheque: Boolean;
        ReceiptAllocations: Record "Receipt Allocation";
        Loans: Record "Loans Register";
        Commision: Decimal;
        LOustanding: Decimal;
        TotalCommision: Decimal;
        TotalOustanding: Decimal;
        Cust: Record "Member Register";
        BOSABank: Code[20];
        LineNo: Integer;
        BOSARcpt: Record "Receipts & Payments";
        TellerTill: Record "Bank Account";
        CurrentTellerAmount: Decimal;
        TransType: Text[30];
        RCPintdue: Decimal;
        Text001: label 'This member has reached a maximum share contribution of Kshs. 5,000/=. Do you want to post this transaction as shares contribution?';
        BosaSetUp: Record "Sacco General Set-Up";
        MpesaCharge: Decimal;
        CustPostingGrp: Record "Customer Posting Group";
        MpesaAc: Code[30];
        GenSetup: Record "Sacco General Set-Up";
        JournalTemplate: Code[20];
        JournalBatch: Code[20];
        FundsUser: Record "Funds User Setup";

    local procedure AllocatedAmountOnDeactivate()
    begin
        CurrPage.Update := true;
    end;
}

