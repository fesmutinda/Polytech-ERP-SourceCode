#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516400 "BOSA Receipt Card"
{
    DeleteAllowed = false;
    Editable = true;
    PageType = Card;
    SourceTable = "Receipts & Payments";
    SourceTableView = where(Posted = filter(No));

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
                    Editable = false;
                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Receipt Mode"; Rec."Receipt Mode")
                {
                    ApplicationArea = Basic;
                }
                field("Excess Transaction Type"; Rec."Excess Transaction Type")
                {
                    ApplicationArea = Basic;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Allocated Amount"; Rec."Allocated Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Un allocated Amount"; Rec."Un allocated Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Employer No."; Rec."Employer No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Teller Till / Bank  No.';
                    ShowMandatory = true;
                }
                field("Cheque No."; Rec."Cheque No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cheque / Slip  No.';
                    ShowMandatory = true;
                }
                field("Cheque Date"; Rec."Cheque Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cheque / Slip  Date';
                    ShowMandatory = true;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            part("Receipt Line"; "Individual Member Risk Rating")
            {
                SubPageLink = "Document No" = field(Rec."Transaction No.");
                Visible = false;
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
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Visible = false;

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
                    Image = Suggest;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        ObjTransactions: Record "Receipt Allocation";
                        RunBal: Decimal;
                        Datefilter: Text;
                    begin

                        /*TESTFIELD(Posted,FALSE);
                        TESTFIELD("Account No.");
                        TESTFIELD(Amount);
                        // ,Registration Fee,Share Capital,Interest Paid,Loan Repayment,Deposit Contribution,Insurance Contribution,Benevolent Fund,Loan,Unallocated Funds,Dividend,FOSA Account
                        GenSetup.GET();
                        ObjTransactions.RESET;
                        ObjTransactions.SETRANGE(ObjTransactions."Document No",Rec."Transaction No.");
                        IF ObjTransactions.FIND('-') THEN
                        ObjTransactions.DELETEALL;
                            Datefilter:='..'+FORMAT("Transaction Date");*/

                        //DateDifference:=TODAY-"Registration Date";
                        /* RunBal:=0;
                         RunBal:=Amount;
                         RunBal:=FnRunEntranceFee(Rec,RunBal);
                     //    IF "Registration Date"<>0D THEN
                     //    RefDate:=CALCDATE('<+'+GenSetup."Share Capital Period"+'>',"Registration Date");
                     //    IF RefDate>TODAY THEN BEGIN
                     //    RunBal:=FnRunShareCapital(Rec,RunBal);//Joel
                     //    END;
                         RunBal:=FnRunBenevolentFund(Rec,RunBal);
                         RunBal:=FnRunShareCapital(Rec,RunBal);
                         RunBal:=FnRunLoanInsurance(Rec,RunBal);
                         RunBal:=FnRunInterest(Rec,RunBal);
                         RunBal:=FnRunPrinciple(Rec,RunBal);
                         RunBal:=FnRunDepositContribution(Rec,RunBal);
                         //RunBal:=FnRunSavingsContribution(Rec,RunBal);*/

                        /*IF RunBal >0 THEN BEGIN
                        IF CONFIRM('Excess Money will allocated to '+FORMAT("Excess Transaction Type")+'.Do you want to Continue?',TRUE)=FALSE THEN
                        EXIT;
                        CASE "Excess Transaction Type" OF
                         "Excess Transaction Type"::"Deposit Contribution":
                           FnRunDepositContributionFromExcess(Rec,RunBal);
                    //      "Excess Transaction Type"::"Deposit Contribution":
                    //        FnRunSavingsProductExcess(Rec,RunBal,'JIOKOE');
                          {"Excess Transaction Type"::"Unallocated Funds":
                            FnRunUnallocatedFromExcess(Rec,RunBal);}
                        END;
                    END;

                    CALCFIELDS("Allocated Amount");
                    "Un allocated Amount":=(Amount-"Allocated Amount");
                    MODIFY;*/
                        Rec.TestField(Posted, false);
                        Rec.TestField("Account No.");
                        Rec.TestField(Amount);
                        // ,Registration Fee,Share Capital,Interest Paid,Loan Repayment,Deposit Contribution,Insurance Contribution,Benevolent Fund,Loan,Unallocated Funds,Dividend,FOSA Account
                        GenSetup.Get();
                        ObjTransactions.Reset;
                        ObjTransactions.SetRange(ObjTransactions."Document No", Rec."Transaction No.");
                        if ObjTransactions.Find('-') then
                            ObjTransactions.DeleteAll;
                        Datefilter := '..' + Format(Rec."Transaction Date");

                        //DateDifference:=TODAY-"Registration Date";
                        RunBal := 0;
                        RunBal := Rec.Amount;
                        RunBal := FnRunEntranceFee(Rec, RunBal);
                        //    IF "Registration Date"<>0D THEN
                        //    RefDate:=CALCDATE('<+'+GenSetup."Share Capital Period"+'>',"Registration Date");
                        //    IF RefDate>TODAY THEN BEGIN
                        RunBal := FnRunShareCapital(Rec, RunBal);//Joel
                                                                 //    END;

                        RunBal := FnRunLoanInsurance(Rec, RunBal);

                        RunBal := FnRunInterest(Rec, RunBal);


                        RunBal := FnRunPrinciple(Rec, RunBal);
                        RunBal := FnRunDepositContribution(Rec, RunBal);
                        RunBal := FnRunSavingsContribution(Rec, RunBal);

                        if RunBal > 0 then begin
                            if Confirm('Excess Money will allocated to ' + Format(Rec."Excess Transaction Type") + '.Do you want to Continue?', true) = false then
                                exit;
                            case Rec."Excess Transaction Type" of
                                Rec."excess transaction type"::"Deposit Contribution":
                                    FnRunDepositContributionFromExcess(Rec, RunBal);
                                //      "Excess Transaction Type"::"Deposit Contribution":
                                //        FnRunSavingsProductExcess(Rec,RunBal,'JIOKOE');
                                Rec."excess transaction type"::"Unallocated Funds":
                                    FnRunUnallocatedFromExcess(Rec, RunBal);
                            end;
                        end;

                        Rec.CalcFields("Allocated Amount");
                        Rec."Un allocated Amount" := (Rec.Amount - Rec."Allocated Amount");
                        Rec.Modify;

                    end;
                }
                action("Introducer Fee")
                {
                    ApplicationArea = Basic;
                    Image = Interaction;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Visible = false;

                    trigger OnAction()
                    begin
                        if Rec.Posted = false then begin
                            Error('The member has not been receipted.');
                        end;
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."Account No.");
                        if Cust.Find('-') then begin
                            if Cust."Recruited By" <> '' then
                                Recruiter := Cust."Recruited By";

                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                            GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
                            GenJournalLine.DeleteAll;

                            if Cust."Registration Fee Paid" = 1000 then
                                LineNo := LineNo + 10000;

                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := Rec."Transaction No.";
                            GenJournalLine."External Document No." := Rec."Cheque No.";
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                            GenJournalLine."Account No." := Rec."Account No.";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                            ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Registration Fee";
                            GenJournalLine.Amount := 500;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            LineNo := LineNo + 10000;

                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'GENERAL';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := Rec."Transaction No.";
                            GenJournalLine."External Document No." := Rec."Cheque No.";
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                            GenJournalLine."Account No." := Recruiter;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                            ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Benevolent Fund";
                            GenJournalLine.Amount := -500;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;
                        end;
                        Message('Recruiter fee transfered successfully');
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
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    /*IF ("Receipt Mode"="Receipt Mode"::Cash) AND ("Transaction Date"<> TODAY) THEN
                    ERROR('You cannot post cash transactions with a date not today');
                    */
                    if Rec.Posted then
                        Error('This receipt is already posted');

                    Rec.TestField("Account No.");
                    Rec.TestField(Amount);
                    Rec.TestField("Employer No.");
                    Rec.TestField("Cheque No.");
                    Rec.TestField("Cheque Date");
                    Rec.TestField(Remarks);

                    if (Rec."Account Type" = Rec."account type"::"G/L Account") or
                       (Rec."Account Type" = Rec."account type"::Debtor) then
                        TransType := 'Withdrawal'
                    else
                        TransType := 'Deposit';

                    ReceiptAllocations.Reset;
                    ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                    ReceiptAllocations.SetRange(ReceiptAllocations."Transaction Type", ReceiptAllocations."transaction type"::"Unallocated Funds");
                    if ReceiptAllocations.Find('-') then begin
                        Error('Unallocated Amount %1', ReceiptAllocations.Amount);

                    end;
                    ////***************************************************************************8
                    IntDate := Rec."Cheque Date";
                    //MESSAGE(FORMAT(IntDate));
                    //MESSAGE('here 1');
                    ReceiptAllocations.Reset;
                    ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                    if ReceiptAllocations.Find('-') then begin
                        Loans.Reset;
                        Loans.SetRange(Loans."Loan  No.", ReceiptAllocations."Loan No.");
                        //Loans.SETFILTER(Loans."Outstanding Balance",'>%1',0);
                        if Loans.Find('-') then begin
                            repeat
                                Loans.CalcFields("Outstanding Balance");
                                if Loans."Outstanding Balance" > 0 then
                                    Message('Loan No is %1', Loans."Loan  No.");

                                CLedger.Reset;
                                CLedger.SetRange(CLedger."Loan No", Loans."Loan  No.");
                                CLedger.SetRange("Transaction Type", CLedger."transaction type"::"Interest Due");
                                CLedger.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', IntDate), CalcDate('CM', IntDate));
                                CLedger.SetRange(Reversed, false);
                                if CLedger.Find('-') then begin
                                    Message('Loan1212 %1| as Interest Changed is %2', CLedger."Loan No", CLedger.Amount);

                                    if CLedger.Amount < 0 then
                                        Error('Kindly Run Loan interest Due');

                                end;
                            until Loans.Next = 0;
                        end;

                    end;
                    ///  MESSAGE('here 2');


                    //******************************************************************************8888888888888888

                    BOSABank := Rec."Employer No.";
                    if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::"FOSA Loan") or (Rec."Account Type" = Rec."account type"::Micro) then begin

                        if Rec.Amount <> Rec."Allocated Amount" then
                            Error('Receipt amount must be equal to the allocated amount.');
                    end;

                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
                    GenJournalLine.DeleteAll;


                    LineNo := LineNo + 10000;

                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := 'GENERAL';
                    GenJournalLine."Journal Batch Name" := 'FTRANS';
                    GenJournalLine."Document No." := Rec."Transaction No.";
                    GenJournalLine."External Document No." := Rec."Cheque No.";
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                    GenJournalLine."Account No." := Rec."Employer No.";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Posting Date" := Rec."Cheque Date";
                    //GenJournalLine."Posting Date":="Transaction Date";
                    GenJournalLine.Description := 'MNO' + Rec."Account No." + ' ' + Rec.Name + '-' + Rec.Remarks;
                    //GenJournalLine.Description:='MNO'+"Account No."+'-'+Remarks;
                    GenJournalLine.Validate(GenJournalLine."Currency Code");
                    ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                    ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                    if TransType = 'Withdrawal' then
                        GenJournalLine.Amount := -Rec.Amount
                    else
                        GenJournalLine.Amount := Rec.Amount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;

                    if (Rec."Account Type" <> Rec."account type"::Member) and (Rec."Account Type" <> Rec."account type"::"FOSA Loan") and (Rec."Account Type" <> Rec."account type"::Vendor) and
                     (Rec."Account Type" <> Rec."account type"::Micro) then begin
                        LineNo := LineNo + 10000;
                        GenJournalLine.Init;
                        GenJournalLine."Journal Template Name" := 'GENERAL';
                        GenJournalLine."Journal Batch Name" := 'FTRANS';
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
                            GenJournalLine."Account Type" := Rec."Account Type"
                        else if Rec."Account Type" = Rec."account type"::Micro then
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
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
                        ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                        ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                        if GenJournalLine.Amount <> 0 then
                            GenJournalLine.Insert;
                    end;

                    GenSetup.Get();

                    if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::Vendor) or
                     (Rec."Account Type" = Rec."account type"::Micro) then begin
                        if (Rec."Receipt Mode" = Rec."receipt mode"::Cheque) or (Rec."Receipt Mode" = Rec."receipt mode"::"Deposit Slip") or (Rec."Receipt Mode" = Rec."receipt mode"::EFT) or (Rec."Receipt Mode" = Rec."receipt mode"::Mpesa) or (Rec."Receipt Mode" = Rec."receipt mode"::"Standing order")
                            then begin
                            ReceiptAllocations.Reset;
                            ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                            if ReceiptAllocations.Find('-') then begin
                                repeat
                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'GENERAL';
                                    GenJournalLine."Journal Batch Name" := 'FTRANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := Rec."Transaction No.";
                                    GenJournalLine."External Document No." := Rec."Cheque No.";
                                    GenJournalLine."Posting Date" := Rec."Cheque Date";
                                    //        GenJournalLine."Posting Date":="Transaction Date";
                                    if ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Mwanangu Savings" then begin
                                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                        GenJournalLine."Account No." := ReceiptAllocations."Account No";
                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                        GenJournalLine.Description := 'BT-' + Rec.Name + '-' + Rec."Account No." + '-' + Rec.Remarks;
                                        ReceiptAllocations."Global Dimension 1 Code" := 'FOSA';
                                        ReceiptAllocations."Global Dimension 2 Code" := SwizzsoftFactory.FnGetUserBranch();
                                    end else begin
                                        if Rec."Account Type" = Rec."account type"::Vendor then begin
                                            //                GenJournalLine."Posting Date":="Transaction Date";
                                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                                            GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                                            GenJournalLine."Shortcut Dimension 2 Code" := SwizzsoftFactory.FnGetUserBranch();
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                            GenJournalLine."Account No." := ReceiptAllocations."Member No";
                                            GenJournalLine.Validate(GenJournalLine."Account No.");
                                            if (Rec."Receipt Mode" = Rec."receipt mode"::"Standing order") and (ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Mwanangu Savings") then begin
                                                GenJournalLine.Amount := -Rec.Amount;
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                                GenJournalLine."Account No." := GenSetup."FOSA MPESA COmm A/C";
                                                GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::Vendor;
                                                GenJournalLine."Bal. Account No." := Rec."Account No.";
                                            end;
                                        end;
                                        if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::Micro) then begin
                                            //                GenJournalLine."Posting Date":="Transaction Date";
                                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                                            ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                                            ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                                            GenJournalLine."Account No." := ReceiptAllocations."Member No";
                                            GenJournalLine.Validate(GenJournalLine."Account No.");
                                            if (Rec."Receipt Mode" = Rec."receipt mode"::"Standing order") and (ReceiptAllocations."Transaction Type" = ReceiptAllocations."transaction type"::"Mwanangu Savings") then begin
                                                GenJournalLine.Amount := -Rec.Amount;
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                                GenJournalLine."Account No." := GenSetup."FOSA MPESA COmm A/C";
                                            end;
                                        end;
                                    end;
                                    GenJournalLine.Amount := -ReceiptAllocations.Amount;
                                    GenJournalLine."Shortcut Dimension 1 Code" := ReceiptAllocations."Global Dimension 1 Code";
                                    GenJournalLine."Shortcut Dimension 2 Code" := ReceiptAllocations."Global Dimension 2 Code";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine.Description := Format(ReceiptAllocations."Transaction Type") + '-' + Rec.Remarks + '-' + Rec.Name + '-' + Rec."Account No.";
                                    GenJournalLine."Transaction Type" := ReceiptAllocations."Transaction Type";
                                    GenJournalLine."Loan No" := ReceiptAllocations."Loan No.";
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;
                                until ReceiptAllocations.Next = 0;
                            end;
                        end;

                        //*************************************************************External reciept mode
                        ChargeAmount := 0;
                        if (Rec."Account Type" = Rec."account type"::Member) or (Rec."Account Type" = Rec."account type"::Vendor) or
                         (Rec."Account Type" = Rec."account type"::Micro) then begin
                            if Rec."Receipt Mode" = Rec."receipt mode"::"5" then begin
                                ReceiptAllocations.Reset;
                                ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec."Transaction No.");
                                ReceiptAllocations.SetFilter(ReceiptAllocations."Transaction Type", '%1', ReceiptAllocations."transaction type"::"Loan Repayment");
                                if ReceiptAllocations.Find('-') then begin
                                    repeat
                                        Loans.Reset;
                                        Loans.SetRange(Loans."Loan  No.", ReceiptAllocations."Loan No.");
                                        if Loans.Find('-') then begin
                                            Loans.CalcFields("Outstanding Balance");
                                            ChargeAmount := ROUND((Loans."Outstanding Balance") * (GenSetup."External Charge (%)" / 100));
                                            //********************************credit external Gl Account

                                            LineNo := LineNo + 10000;
                                            GenJournalLine.Init;
                                            GenJournalLine."Journal Template Name" := 'GENERAL';
                                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                                            GenJournalLine."Document No." := Rec."Transaction No.";
                                            GenJournalLine."Line No." := LineNo;
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                            GenJournalLine."Account No." := '400102';//insrt Gl Account No
                                            GenJournalLine.Validate(GenJournalLine."Account No.");
                                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                                            GenJournalLine.Description := 'External source amount charged on repayment' + Loans."Loan  No." + Loans."Client Code";
                                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                                            ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                                            ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                                            GenJournalLine."Transaction Type" := ReceiptAllocations."Transaction Type";
                                            GenJournalLine.Amount := -ChargeAmount;
                                            GenJournalLine.Validate(GenJournalLine.Amount);
                                            if GenJournalLine.Amount <> 0 then
                                                GenJournalLine.Insert;

                                            //********************************end credit external Gl Account
                                            //*******************************credit loan Account
                                            LineNo := LineNo + 10000;
                                            GenJournalLine.Init;
                                            GenJournalLine."Journal Template Name" := 'GENERAL';
                                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                                            GenJournalLine."Document No." := Rec."Transaction No.";
                                            GenJournalLine."Line No." := LineNo;
                                            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                                            GenJournalLine."Account No." := Rec."Account No.";
                                            GenJournalLine.Validate(GenJournalLine."Account No.");
                                            GenJournalLine."Loan No" := Loans."Loan  No.";
                                            GenJournalLine."Posting Date" := Rec."Cheque Date";
                                            GenJournalLine.Description := 'Loan repayment' + Loans."Loan  No." + Loans."Client Code";
                                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                                            ReceiptAllocations."Global Dimension 1 Code" := Rec."Global Dimension 1 Code";
                                            ReceiptAllocations."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                                            //GenJournalLine."Transaction Type":=ReceiptAllocations."Transaction Type";
                                            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                                            GenJournalLine.Amount := -(ReceiptAllocations.Amount - ChargeAmount);
                                            GenJournalLine.Validate(GenJournalLine.Amount);
                                            if GenJournalLine.Amount <> 0 then
                                                GenJournalLine.Insert;
                                        end;
                                    //*******************************end credit loan Account
                                    until ReceiptAllocations.Next = 0;
                                end;
                            end;
                        end;
                        //**************************************************************End External reciept mode
                    end;

                    //Post New
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
                    GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
                    if GenJournalLine.Find('-') then begin
                        Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
                    end;
                    //Post New
                    Message('Transaction posted successfully');
                    Rec.Posted := true;
                    Rec.Modify;
                    Commit;
                    BOSARcpt.Reset;
                    BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                    if BOSARcpt.Find('-') then
                        if/* ("Mode of Payment"<>"Mode of Payment"::"Standing order") AND */
                          //("Mode of Payment"<>"Mode of Payment"::"Direct Debit") AND
                           (Rec."Receipt Mode" <> Rec."receipt mode"::"Standing order") then begin

                            BOSARcpt.Reset;
                            BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                            if BOSARcpt.Find('-') then
                                Report.Run(51516486, true, true, BOSARcpt);

                        end;

                    CurrPage.Close;

                end;
            }
            action("Reprint Frecipt")
            {
                ApplicationArea = Basic;
                Caption = 'Reprint Receipt';
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    Rec.TestField(Posted);

                    BOSARcpt.Reset;
                    BOSARcpt.SetRange(BOSARcpt."Transaction No.", Rec."Transaction No.");
                    if BOSARcpt.Find('-') then
                        Report.Run(51516486, true, true, BOSARcpt)
                end;
            }
            action("Process Interest Due")
            {
                ApplicationArea = Basic;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    //TESTFIELD ("Loan Amount");
                    FnProcessingDailyInterestDue()
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        Rec.CalcFields("Allocated Amount");
        Rec."Un allocated Amount" := Rec.Amount - Rec."Allocated Amount";
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        BOSARcpt.Reset;
        BOSARcpt.SetRange(BOSARcpt.Posted, false);
        BOSARcpt.SetRange(BOSARcpt."User ID", UserId);
        if BOSARcpt.Find('-') then begin
            if BOSARcpt."Account No." = '' then begin
                if BOSARcpt.Count >= 2 then begin
                    Error('There are still some Unused Receipt Nos. Please utilise them first');
                end;
            end;
        end;
    end;

    var
        startDateS: Text;
        StartDate: Text;
        StartDateshare: Date;
        LoanRec: Record "Loans Register";
        CLedger: Record "Member Ledger Entry";
        RSchedule: Record "Loan Repayment Schedule";
        LastDate: Date;
        IntAmount: Decimal;
        LoanBalance: Decimal;
        BalDate: Date;
        IntDate: Date;
        CheckExistingBill: Boolean;
        InterestAmount: Decimal;
        ManagePrint: Codeunit ApplicationManagement;
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
        ShareCapDefecit: Decimal;
        LoanApp: Record "Loans Register";
        Datefilter: Text;
        SwizzsoftFactory: Codeunit 51516007;
        RefDate: Date;
        Recruiter: Code[20];
        ChargeAmount: Decimal;
        loanapps: Record "Loans Register";

    local procedure AllocatedAmountOnDeactivate()
    begin
        CurrPage.Update := true;
    end;

    local procedure FnRunInterest(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
    begin
        if RunningBalance > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No", "Employer Code");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Account No.");
            LoanApp.SetFilter(LoanApp."Date filter", Datefilter);
            if LoanApp.Find('-') then begin
                repeat
                    LoanApp.CalcFields(LoanApp."Oustanding Interest", "Outstanding Balance");
                    if LoanApp."Outstanding Balance" > 0 then
                        if LoanApp."Oustanding Interest" > 0 then begin

                            if RunningBalance > 0 then begin
                                AmountToDeduct := 0;
                                AmountToDeduct := ROUND(LoanApp."Oustanding Interest", 0.05, '>');
                                if RunningBalance <= AmountToDeduct then
                                    AmountToDeduct := RunningBalance;
                                ObjReceiptTransactions.Init;
                                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Interest Paid";
                                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                                ObjReceiptTransactions."Loan No." := LoanApp."Loan  No.";
                                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Loan No.");

                                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                                ObjReceiptTransactions.Amount := AmountToDeduct;
                                if ObjReceiptTransactions.Amount > 0 then
                                    ObjReceiptTransactions.Insert(true);
                                RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
                            end;
                        end;
                until LoanApp.Next = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunPrinciple(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
    begin
        if RunningBalance > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No", "Employer Code");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Account No.");
            LoanApp.SetFilter(LoanApp."Date filter", Datefilter);

            if LoanApp.Find('-') then begin
                repeat
                    AmountToDeduct := 0;

                    if RunningBalance > 0 then begin
                        LoanApp.CalcFields(LoanApp."Outstanding Balance");
                        if LoanApp."Outstanding Balance" > 0 then begin
                            AmountToDeduct := LoanApp."Loan Principle Repayment";
                            if AmountToDeduct > 0 then begin
                                if AmountToDeduct > LoanApp."Outstanding Balance" then
                                    AmountToDeduct := LoanApp."Outstanding Balance";
                                if AmountToDeduct > RunningBalance then
                                    AmountToDeduct := RunningBalance;
                                ObjReceiptTransactions.Init;
                                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                                ObjReceiptTransactions."Account Type" := ObjReceiptTransactions."account type"::Member;
                                ObjReceiptTransactions."Member No" := LoanApp."Client Code";
                                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Loan Repayment";
                                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                                ObjReceiptTransactions."Loan No." := LoanApp."Loan  No.";
                                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Loan No.");
                                ObjReceiptTransactions."Global Dimension 1 Code" := Format(LoanApp.Source);
                                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                                ObjReceiptTransactions.Amount := AmountToDeduct;
                                if ObjReceiptTransactions.Amount > 0 then
                                    ObjReceiptTransactions.Insert(true);
                                RunningBalance := RunningBalance - AmountToDeduct;
                            end;
                        end;
                    end;
                until LoanApp.Next = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunEntranceFee(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record 51516364;
    begin
        if RunningBalance > 0 then begin
            GenSetup.Get();
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            //ObjMember.SETFILTER(ObjMember."Registration Date",'>%1',20190110D); //To Ensure deduction is for New Members Only
            if ObjMember.Find('-') then begin
                ObjMember.CalcFields(ObjMember."Registration Fee Paid");
                if ObjMember."Registration Fee Paid" < 0 then begin
                    //IF ObjMember."Registration Date" <>0D THEN
                    // BEGIN

                    AmountToDeduct := 0;
                    //AmountToDeduct:=ABS(ObjMember."Registration Fee Paid");
                    AmountToDeduct := Abs(GenSetup."BOSA Registration Fee Amount");
                    if RunningBalance <= AmountToDeduct then
                        AmountToDeduct := RunningBalance;
                    ObjReceiptTransactions.Init;
                    ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                    ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                    ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Registration Fee";
                    ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                    ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                    ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                    ObjReceiptTransactions.Amount := AmountToDeduct;
                    if ObjReceiptTransactions.Amount <> 0 then
                        ObjReceiptTransactions.Insert(true);
                    RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
                    // END;
                end;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunShareCapital(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record 51516364;
        SharesCap: Decimal;
        DIFF: Decimal;
    begin
        if RunningBalance > 0 then begin
            SharesCap := 0;
            GenSetup.Get();
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
            if ObjMember.Find('-') then begin
                //REPEAT Deducted once unless otherwise advised
                ObjMember.CalcFields(ObjMember."Shares Retained");
                // IF  SharesCap =  ' ' THEN
                SharesCap := 417;
                if ObjMember."Shares Retained" >= 20000 then
                    SharesCap := 0;

                StartDate := Format(20230101D) + '..' + Format(Today);
                Message(Format(StartDate));
                ObjMember.Reset;
                ObjMember.SetRange(ObjMember."No.", ObjMember."No.");
                ObjMember.SetFilter(ObjMember."Registration Date", StartDate);
                if ObjMember.Find('-') then begin
                    SharesCap := 1000;
                end else
                    startDateS := Format(20000101D) + '..' + Format(20221231D);
                ObjMember.Reset;
                ObjMember.SetRange(ObjMember."No.", ObjMember."No.");
                ObjMember.SetFilter(ObjMember."Registration Date", startDateS);
                if ObjMember.Find('-') then begin
                    SharesCap := 417;
                end;

                AmountToDeduct := SharesCap;

                Message(Format(AmountToDeduct));
                if RunningBalance <= AmountToDeduct then
                    AmountToDeduct := RunningBalance;

                ObjReceiptTransactions.Init;
                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Share Capital";
                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                ObjReceiptTransactions.Amount := AmountToDeduct;
                if ObjReceiptTransactions.Amount <> 0 then
                    ObjReceiptTransactions.Insert(true);
                RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
            end;
        end;
        //END;
        //UNTIL RcptBufLines.NEXT=0;
        //END;

        exit(RunningBalance);
        //
        //END;
    end;

    local procedure FnRunDepositContribution(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        SharesCap: Decimal;
        DIFF: Decimal;
    begin
        if RunningBalance > 0 then begin
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
            if ObjMember.Find('-') then begin
                AmountToDeduct := 0;
                AmountToDeduct := ROUND(ObjMember."Monthly Contribution", 0.05, '>');
                if RunningBalance <= AmountToDeduct then
                    AmountToDeduct := RunningBalance;

                ObjReceiptTransactions.Init;
                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Deposit Contribution";
                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                ObjReceiptTransactions.Amount := AmountToDeduct;
                if ObjReceiptTransactions.Amount <> 0 then
                    ObjReceiptTransactions.Insert(true);
                RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
            end;

            exit(RunningBalance);
        end;
    end;

    local procedure FnRunLoanInsurance(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
    begin
        GenSetup.Get();
        if RunningBalance > 0 then begin
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            if ObjMember.Find('-') then begin
                ObjMember.CalcFields(ObjMember."Insurance Fund");
                // AmountToDeduct:=0;
                AmountToDeduct := 200;//-ObjMember."Insurance Fund";
                if AmountToDeduct < 0 then
                    AmountToDeduct := 0;
                if RunningBalance <= AmountToDeduct then
                    AmountToDeduct := RunningBalance;
                ObjReceiptTransactions.Init;
                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Loan Insurance Paid";
                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                ObjReceiptTransactions.Amount := AmountToDeduct;
                if ObjReceiptTransactions.Amount <> 0 then
                    ObjReceiptTransactions.Insert(true);
                RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunBenevolentFund(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
    begin
        if RunningBalance > 0 then begin
            GenSetup.Get();
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            if ObjMember.Find('-') then begin
                if ObjMember."Registration Date" <> 0D then begin

                    AmountToDeduct := 0;
                    AmountToDeduct := GenSetup."Insurance Contribution";
                    if RunningBalance <= AmountToDeduct then
                        AmountToDeduct := RunningBalance;
                    ObjReceiptTransactions.Init;
                    ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                    ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                    ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Benevolent Fund";
                    ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                    ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                    ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                    ObjReceiptTransactions.Amount := AmountToDeduct;
                    if ObjReceiptTransactions.Amount <> 0 then
                        ObjReceiptTransactions.Insert(true);
                    RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
                end;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunUnallocatedAmount(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
    begin
        ObjMember.Reset;
        ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
        if ObjMember.Find('-') then begin
            begin
                AmountToDeduct := 0;
                AmountToDeduct := RunningBalance;
                ObjReceiptTransactions.Init;
                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Unallocated Funds";
                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                ObjReceiptTransactions.Amount := AmountToDeduct;
                if ObjReceiptTransactions.Amount <> 0 then
                    ObjReceiptTransactions.Insert(true);
            end;
        end;
    end;

    local procedure FnRunUnallocatedFromExcess(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        SharesCap: Decimal;
        DIFF: Decimal;
        TransType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account";
    begin

        ObjMember.Reset;
        ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
        ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
        if ObjMember.Find('-') then begin
            AmountToDeduct := 0;
            AmountToDeduct := RunningBalance + FnReturnAmountToClear(Transtype::"Unallocated Funds");
            ObjReceiptTransactions.Init;
            ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
            ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
            ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Unallocated Funds";
            ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
            ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
            ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
            ObjReceiptTransactions.Amount := AmountToDeduct;
            if ObjReceiptTransactions.Amount <> 0 then
                ObjReceiptTransactions.Insert(true);
        end;
    end;

    local procedure FnReturnAmountToClear(TransType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account") AmountReturned: Decimal
    var
        ObjReceiptAllocation: Record "Receipt Allocation";
    begin
        ObjReceiptAllocation.Reset;
        ObjReceiptAllocation.SetRange("Document No", Rec."Transaction No.");
        ObjReceiptAllocation.SetRange("Transaction Type", TransType);
        if ObjReceiptAllocation.Find('-') then begin
            AmountReturned := ObjReceiptAllocation.Amount;
            ObjReceiptAllocation.Delete;
        end;
        exit;
    end;

    local procedure FnRunSavingsProductExcess(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal; SavingsProduct: Code[100]): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        SharesCap: Decimal;
        DIFF: Decimal;
        TransType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"Mwanangu Savings","Loan Insurance Charged","Loan Insurance Paid","Recovery Account","FOSA Shares","Additional Shares","Interest Due","Jiokoe Savings";
    begin
        ObjMember.Reset;
        ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
        ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
        if ObjMember.Find('-') then begin
            AmountToDeduct := 0;
            AmountToDeduct := RunningBalance + FnReturnAmountToClear(Transtype::"Unallocated Funds");
            ObjReceiptTransactions.Init;
            ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
            ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
            ObjReceiptTransactions."Account No" := ObjRcptBuffer."Account No.";
            ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Unallocated Funds";
            ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
            ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
            ObjReceiptTransactions.Amount := AmountToDeduct;
            if ObjReceiptTransactions.Amount <> 0 then
                ObjReceiptTransactions.Insert(true);
        end;
    end;

    local procedure FnRunDepositContributionFromExcess(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        SharesCap: Decimal;
        DIFF: Decimal;
        TransType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account";
    begin

        ObjMember.Reset;
        ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
        ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
        if ObjMember.Find('-') then begin
            AmountToDeduct := 0;
            AmountToDeduct := RunningBalance + FnReturnAmountToClear(Transtype::"Deposit Contribution");
            ObjReceiptTransactions.Init;
            ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
            ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
            ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Deposit Contribution";
            ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
            ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
            ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
            ObjReceiptTransactions.Amount := AmountToDeduct;
            if ObjReceiptTransactions.Amount <> 0 then
                ObjReceiptTransactions.Insert(true);
        end;
    end;

    local procedure FnRunSavingsContribution(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        SharesCap: Decimal;
        DIFF: Decimal;
    begin
        if RunningBalance > 0 then begin
            ObjMember.Reset;
            ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Account No.");
            ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
            if ObjMember.Find('-') then begin
                AmountToDeduct := 0;
                //          AmountToDeduct:=ROUND(ObjMember."Monthly Contribution",0.05,'>');
                //          IF RunningBalance <= AmountToDeduct THEN
                AmountToDeduct := RunningBalance;

                ObjReceiptTransactions.Init;
                ObjReceiptTransactions."Document No" := ObjRcptBuffer."Transaction No.";
                ObjReceiptTransactions."Member No" := ObjRcptBuffer."Account No.";
                ObjReceiptTransactions."Transaction Type" := ObjReceiptTransactions."transaction type"::"Unallocated Funds";
                ObjReceiptTransactions.Validate(ObjReceiptTransactions."Transaction Type");
                ObjReceiptTransactions."Global Dimension 1 Code" := 'BOSA';
                ObjReceiptTransactions."Global Dimension 2 Code" := SwizzsoftFactory.FnGetMemberBranch(ObjRcptBuffer."Account No.");
                ObjReceiptTransactions.Amount := AmountToDeduct;
                if ObjReceiptTransactions.Amount <> 0 then
                    ObjReceiptTransactions.Insert(true);
                RunningBalance := RunningBalance - Abs(ObjReceiptTransactions.Amount);
            end;

            exit(RunningBalance);
        end;
    end;

    local procedure FnRunRegistrationFee(ObjRcptBuffer: Record "Receipts & Payments"; RunningBalance: Decimal)
    var
        AmountToDeduct: Decimal;
        ObjReceiptTransactions: Record "Receipt Allocation";
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        PRpayment: Decimal;
        ObjMember: Record "Member Register";
        RegFee: Decimal;
    begin
        /*IF RunningBalance > 0 THEN
          BEGIN
            GenSetup.GET();
            ObjMember.RESET;
            ObjMember.SETRANGE(ObjMember."No.",ObjRcptBuffer."Account No.");
            ObjMember.SETRANGE(ObjMember."Customer Type",ObjMember."Customer Type"::Member);
            IF ObjMember.FIND('-') THEN
               BEGIN
                  //REPEAT Deducted once unless otherwise advised
                    ObjMember.CALCFIELDS (ObjMember."Registration Fee Paid");
                    RegFee:=0;
                    IF ObjMember."Member Share Class"=ObjMember."Member Share Class"::"Class A" THEN BEGIN
                    RegFee:=GenSetup."Registration Fee CLass A";
                    END  ELSE IF ObjMember."Member Share Class"=ObjMember."Member Share Class"::"Class B" THEN BEGIN
                    RegFee:=GenSetup."Registration Fee Class B";
                    END;
        
        
                    IF  ObjMember."Registration Fee Paid" < RegFee THEN
                    BEGIN
                      SharesCap:=RegFee;
                      DIFF:=SharesCap-ObjMember."Registration Fee Paid";
        
                      IF  DIFF > 1 THEN
                          BEGIN
                          IF RunningBalance > 0 THEN
                            BEGIN
                             AmountToDeduct:=0;
                                  AmountToDeduct:=DIFF;
                                  IF DIFF > 1 THEN
                                    AmountToDeduct:=DIFF;
                             IF RunningBalance <= AmountToDeduct THEN
                             AmountToDeduct:=RunningBalance;
                             */

    end;

    local procedure FnProcessingDailyInterestDue()
    var
        MemberLedgerEntry: Record "Member Ledger Entry";
        GenBatches: Record "Gen. Journal Batch";
        PDate: Date;
        LoanType: Record "Loan Products Setup";
        PostDate: Date;
        Cust: Record "Member Register";
        LineNo: Integer;
        DocNo: Code[20];
        GenJournalLine: Record "Gen. Journal Line";
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        EndDate: Date;
        DontCharge: Boolean;
        Temp: Record "Funds User Setup";
        JBatch: Code[10];
        Jtemplate: Code[10];
        CustLedger: Record "Member Ledger Entry";
        AccountingPeriod: Record "Interest Due Period";
        FiscalYearStartDate: Date;
        "ExtDocNo.": Text[30];
        loanapp: Record "Loans Register";
        SDATE: Text[30];
        Objrepaymentschedule: Record "Loan Repayment Schedule";
        Varbeginmonth: Date;
        DateTest: Date;
        VarAmount: Decimal;
        ObjCust: Record "Member Register";
        Date_OutBal: Date;
        OutBal: Decimal;
        BeginMonth_Date: Date;
        EndMonth_Date: Date;
        PayDateNo: Integer;
        Month: Code[10];
        Days: Integer;
        varDays: Integer;
        ReceiptsPayments: Record "Receipts & Payments";
        DaysValue: Integer;
        DaysInMonth: Integer;
    begin

        Date_OutBal := Rec."Cheque Date";
        IntDate := Rec."Cheque Date";
        BalDate := Rec."Cheque Date";
        PostDate := CalcDate('CM', Rec."Cheque Date");
        //MESSAGE('date to post is %1',IntDate  );

        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        GenJournalLine.SetRange("Journal Batch Name", 'INT DUE');
        GenJournalLine.DeleteAll;
        loanapp.Reset;
        loanapp.SetRange(loanapp."Client Code", Rec."Account No.");
        loanapp.SetFilter(loanapp."Outstanding Balance", '>%1', 0);
        loanapp.SetFilter(loanapp."Loan Product Type", '<>%1', '24');
        //loanapp.SETFILTER( loanapp."Date filter",'<=%1',Date_OutBal);
        if loanapp.Find('-') then begin
            repeat
                Message('loan no is %1', loanapp."Loan  No.");
                CLedger.Reset;
                CLedger.SetRange(CLedger."Loan No", loanapp."Loan  No.");
                CLedger.SetRange("Transaction Type", CLedger."transaction type"::"Interest Due");
                CLedger.SetFilter("Posting Date", '%1..%2', CalcDate('-CM', IntDate), CalcDate('CM', IntDate));
                CLedger.SetFilter(Amount, '>0');
                CLedger.SetRange(Reversed, false);
                if CLedger.Find('-') then begin
                    // MESSAGE('cl');
                    //  MESSAGE ('Loan %1| as Interest Changed is %2',CLedger."Loan No",CLedger.Amount);
                    Error('Loan as Interest Due');
                end;

                LoanBalance := 0;
                IntAmount := 0;

                LoanRec.Reset;
                LoanRec.SetRange("Loan  No.", loanapp."Loan  No.");
                LoanRec.SetFilter("Date filter", '..%1', BalDate);
                if LoanRec.Find('-') then begin

                    LoanRec.CalcFields("Outstanding Balance");
                    LoanBalance := LoanRec."Outstanding Balance";
                    //  MESSAGE('LoanBalance %1',LoanBalance);

                    if LoanBalance < 0 then
                        LoanBalance := 0;


                    if (LoanRec."Loan Product Type" = '15') or (LoanRec."Loan Product Type" = '16') then
                        IntAmount := ROUND(LoanRec."Approved Amount" * LoanRec.Interest / 1200, 1, '>')
                    else
                        IntAmount := ROUND(LoanBalance * LoanRec.Interest / 1200, 1, '>');


                end;
                // MESSAGE('int amount %1',IntAmount);
                InterestAmount := IntAmount;
                //  MESSAGE ('InterestAmount IS %1',InterestAmount);
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := 'GENERAL';
                GenJournalLine."Journal Batch Name" := 'INT DUE';
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                GenJournalLine."Account No." := loanapp."Client Code";
                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Due";
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Document No." := 'INT';
                GenJournalLine."Posting Date" := PostDate;
                GenJournalLine.Description := 'Interest charged';

                GenJournalLine.Amount := ROUND(InterestAmount, 1, '=');

                //MESSAGE(FORMAT(GenJournalLine.Amount));

                GenJournalLine.Validate(GenJournalLine.Amount);
                if LoanType.Get(loanapp."Loan Product Type") then begin
                    GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                    GenJournalLine."Bal. Account No." := LoanType."Loan Interest Account";
                    GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                end;
                if loanapp.Source = loanapp.Source::" " then begin
                    GenJournalLine."Shortcut Dimension 2 Code" := loanapp."Branch Code";
                end;
                if loanapp.Source = loanapp.Source::BOSA then begin
                    GenJournalLine."Shortcut Dimension 2 Code" := loanapp."Branch Code";
                end;
                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                GenJournalLine."Loan No" := loanapp."Loan  No.";
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;


            until loanapp.Next = 0;
        end;
        // // // //
        // //  //*****************************
        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        GenJournalLine.SetRange("Journal Batch Name", 'INT DUE');
        if GenJournalLine.Find('-') then begin
            Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
        end;
        //********************************************************************************************************Postmodifly
        //       loanapp.RESET;
        //       loanapp.SETRANGE(loanapp."Client Code","Account No.");
        //       IF loanapp.FIND('-') THEN BEGIN
        //         REPEAT
        //          loanapp."Daily Interest Due" := "Transaction Date";
        //           loanapp.MODIFY;
        //           UNTIL loanapp.NEXT =0;
        //         END;
        //         //"Interest cal" := TRUE;
        //         MODIFY;
    end;
}

