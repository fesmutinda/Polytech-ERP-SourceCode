#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516395 "Loans Disbursment Batch List"
{
    CardPageID = "Loan Disburesment Batch Card";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = 51516377;
    SourceTableView = where(Posted = filter(No));

    layout
    {
        area(content)
        {
            repeater(Control1102760000)
            {
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Source; Source)
                {
                    ApplicationArea = Basic;
                }
                field("Description/Remarks"; "Description/Remarks")
                {
                    ApplicationArea = Basic;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic;
                }
                field("No of Loans"; "No of Loans")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Mode Of Disbursement"; "Mode Of Disbursement")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(LoansB)
            {
                Caption = 'Batch';
                action("Loans Schedule")
                {
                    ApplicationArea = Basic;
                    Caption = 'Loans Schedule';
                    Image = SuggestPayment;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        /*LoansBatch.RESET;
                        LoansBatch.SETRANGE(LoansBatch."Batch No.","Batch No.");
                        IF LoansBatch.FIND('-') THEN BEGIN
                        REPORT.RUN(,TRUE,FALSE,LoansBatch);
                        END;
                        */

                    end;
                }
                separator(Action1102755008)
                {
                }
                action("Member Card")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member Card';
                    Image = Customer;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        /*
                        LoanApp.RESET;
                        LoanApp.SETRANGE(LoanApp."Loan  No.",CurrPage.LoansSubForm.GetLoanNo);
                        IF LoanApp.FIND('-') THEN BEGIN
                        Cust.RESET;
                        Cust.SETRANGE(Cust."No.",LoanApp."Client Code");
                        IF Cust.FIND('-') THEN
                        PAGE.RUNMODAL(,Cust);
                        END;
                        */

                    end;
                }
                action("Loan Application")
                {
                    ApplicationArea = Basic;
                    Caption = 'Loan Application Card';
                    Image = Loaners;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        /*
                        LoanApp.RESET;
                        //LoanApp.SETRANGE(LoanApp."Loan  No.",CurrPage.LoansSubForm.PAGE.GetLoanNo);
                        IF LoanApp.FIND('-') THEN
                        PAGE.RUNMODAL(,LoanApp);
                         */

                    end;
                }
                action("Loan Appraisal")
                {
                    ApplicationArea = Basic;
                    Caption = 'Loan Appraisal';
                    Image = Statistics;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        /*
                        LoanApp.RESET;
                        //LoanApp.SETRANGE(LoanApp."Loan  No.",CurrPage.LoansSubForm.PAGE.GetLoanNo);
                        IF LoanApp.FIND('-') THEN BEGIN
                        IF COPYSTR(LoanApp."Loan Product Type",1,2) = 'PL' THEN
                        REPORT.RUN(,TRUE,FALSE,LoanApp)
                        ELSE
                        REPORT.RUN(,TRUE,FALSE,LoanApp);
                        END;
                        */

                    end;
                }
                separator(Action1102755004)
                {
                }
                action(Post)
                {
                    ApplicationArea = Basic;
                    Caption = 'Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    Visible = false;

                    trigger OnAction()
                    var
                        Text001: label 'The Batch need to be approved.';
                    begin
                        if Posted = true then
                            Error('Batch already posted.');

                        if Status <> Status::Approved then
                            Error(Format(Text001));

                        CalcFields(Location);
                        if Confirm('Are you sure you want to post this batch?', true) = false then
                            exit;
                        TestField("Description/Remarks");
                        TestField("Posting Date");
                        TestField("Document No.");
                        GenJournalLine.Reset;
                        GenJournalLine.SetRange("Journal Template Name", 'Payments');
                        GenJournalLine.SetRange("Journal Batch Name", 'LOANS');
                        GenJournalLine.DeleteAll;


                        GenSetUp.Get();

                        DActivity := '';
                        DBranch := '';


                        // fosa posting
                        if "Mode Of Disbursement" = "mode of disbursement"::MPESA then begin
                            LoanApps.Reset;
                            LoanApps.SetRange(LoanApps."Batch No.", "Batch No.");
                            LoanApps.SetRange(LoanApps."System Created", false);
                            LoanApps.SetFilter(LoanApps."Loan Status", '<>Rejected');
                            if LoanApps.Find('-') then begin
                                repeat

                                    LoanApps.CalcFields(LoanApps."Top Up Amount");
                                    TCharges := 0;
                                    TopUpComm := 0;
                                    TotalTopupComm := 0;

                                    // /

                                    //END;

                                    if LoanApps."Top Up Amount" > 0 then begin
                                        LoanTopUp.Reset;
                                        LoanTopUp.SetRange(LoanTopUp."Loan No.", LoanApps."Loan  No.");
                                        if LoanTopUp.Find('-') then begin
                                            repeat
                                                //Principle
                                                LineNo := LineNo + 10000;
                                                GenJournalLine.Init;
                                                GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                GenJournalLine."Journal Batch Name" := 'LOANS';
                                                GenJournalLine."Line No." := LineNo;
                                                GenJournalLine."Document No." := "Document No.";
                                                GenJournalLine."Posting Date" := "Posting Date";
                                                GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                                GenJournalLine."Account No." := LoanApps."Client Code";
                                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                                GenJournalLine.Description := 'Off Set By - ' + LoanApps."Loan  No.";
                                                GenJournalLine.Amount := LoanTopUp."Principle Top Up" * -1;
                                                GenJournalLine.Validate(GenJournalLine.Amount);
                                                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                                                GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                if GenJournalLine.Amount <> 0 then
                                                    GenJournalLine.Insert;


                                                //Interest (Reversed if top up)
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    LineNo := LineNo + 10000;
                                                    GenJournalLine.Init;
                                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                                    GenJournalLine."Line No." := LineNo;
                                                    GenJournalLine."Account Type" := GenJournalLine."bal. account type"::Employee;
                                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                                    GenJournalLine."Document No." := "Document No.";
                                                    GenJournalLine."Posting Date" := "Posting Date";
                                                    GenJournalLine.Description := 'Interest Due Paid on top up ' + LoanApps."Loan Product Type Name";
                                                    GenJournalLine.Amount := -LoanTopUp."Interest Top Up";
                                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                                    GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                                    GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                    if GenJournalLine.Amount <> 0 then
                                                        GenJournalLine.Insert;
                                                end;
                                                //Commision
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    if LoanType."Top Up Commision" > 0 then begin
                                                        LineNo := LineNo + 10000;
                                                        GenJournalLine.Init;
                                                        GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                        GenJournalLine."Journal Batch Name" := 'LOANS';
                                                        GenJournalLine."Line No." := LineNo;
                                                        GenJournalLine."Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                                        GenJournalLine."Account No." := LoanType."Top Up Commision Account";
                                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                                        GenJournalLine."Document No." := "Document No.";
                                                        GenJournalLine."Posting Date" := "Posting Date";
                                                        GenJournalLine.Description := 'Levy on Bridging';
                                                        TopUpComm := LoanTopUp.Commision;
                                                        TotalTopupComm := TotalTopupComm + TopUpComm;
                                                        GenJournalLine.Amount := TopUpComm * -1;
                                                        GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                                        GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                        GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                        if GenJournalLine.Amount <> 0 then
                                                            GenJournalLine.Insert;
                                                    end;
                                                end;

                                            until LoanTopUp.Next = 0;
                                        end;
                                    end;

                                    LoanApps.CalcFields(LoanApps."Top Up Amount");
                                    TCharges := 0;
                                    TopUpComm := 0;
                                    TotalTopupComm := 0;



                                    if LoanApps."Top Up Amount" > 0 then begin
                                        LoanTopUp.Reset;
                                        LoanTopUp.SetRange(LoanTopUp."Loan No.", LoanApps."Loan  No.");
                                        if LoanTopUp.Find('-') then begin
                                            repeat
                                                //Principle
                                                LineNo := LineNo + 10000;
                                                GenJournalLine.Init;
                                                GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                GenJournalLine."Journal Batch Name" := 'LOANS';
                                                GenJournalLine."Line No." := LineNo;
                                                GenJournalLine."Document No." := "Document No.";
                                                GenJournalLine."Posting Date" := "Posting Date";
                                                GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                                GenJournalLine."Account No." := LoanApps."Client Code";
                                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                                GenJournalLine.Description := 'Off Set By - ' + LoanApps."Loan  No.";
                                                GenJournalLine.Amount := LoanTopUp."Principle Top Up";
                                                GenJournalLine.Validate(GenJournalLine.Amount);
                                                GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                if GenJournalLine.Amount <> 0 then
                                                    GenJournalLine.Insert;


                                                //Interest (Reversed if top up)
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    LineNo := LineNo + 10000;
                                                    GenJournalLine.Init;
                                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                                    GenJournalLine."Line No." := LineNo;
                                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                                    GenJournalLine."Document No." := "Document No.";
                                                    GenJournalLine."Posting Date" := "Posting Date";
                                                    GenJournalLine.Description := 'Interest Due Paid on top up ' + LoanApps."Loan Product Type Name";
                                                    GenJournalLine.Amount := -LoanTopUp."Interest Top Up";
                                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                    if GenJournalLine.Amount <> 0 then
                                                        GenJournalLine.Insert;
                                                end;
                                                //Commision
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    if LoanType."Top Up Commision" > 0 then begin
                                                        LineNo := LineNo + 10000;
                                                        GenJournalLine.Init;
                                                        GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                        GenJournalLine."Journal Batch Name" := 'LOANS';
                                                        GenJournalLine."Line No." := LineNo;
                                                        GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                                        GenJournalLine."Account No." := LoanApps."Client Code";
                                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                                        GenJournalLine."Document No." := "Document No.";
                                                        GenJournalLine."Posting Date" := "Posting Date";
                                                        GenJournalLine.Description := 'Levy on Bridging';
                                                        TopUpComm := LoanTopUp.Commision;
                                                        TotalTopupComm := TotalTopupComm + TopUpComm;
                                                        GenJournalLine.Amount := TopUpComm * -1;
                                                        GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                                        GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                        GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                        if GenJournalLine.Amount <> 0 then
                                                            GenJournalLine.Insert;
                                                    end;
                                                end;

                                            until LoanTopUp.Next = 0;
                                        end;
                                    end;


                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    GenJournalLine.Description := 'transfer to fosa comm';
                                    GenJournalLine.Amount := GenSetUp."Loan Trasfer Fee-FOSA";
                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                    GenJournalLine."Bal. Account No." := GenSetUp."Loan Trasfer Fee A/C-FOSA";
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;
                                until LoanApps.Next = 0;
                            end;
                        end;

                        // end of fosa posting


                        // eft posting
                        if "Mode Of Disbursement" = "mode of disbursement"::RTGS then begin
                            LoanApps.Reset;
                            LoanApps.SetRange(LoanApps."Batch No.", "Batch No.");
                            LoanApps.SetRange(LoanApps."System Created", false);
                            LoanApps.SetFilter(LoanApps."Loan Status", '<>Rejected');
                            if LoanApps.Find('-') then begin
                                repeat

                                    LoanApps.CalcFields(LoanApps."Top Up Amount");
                                    TCharges := 0;
                                    TopUpComm := 0;
                                    TotalTopupComm := 0;

                                    DActivity := 'BOSA';
                                    DBranch := 'NAIROBI';


                                    if LoanApps."Top Up Amount" > 0 then begin
                                        LoanTopUp.Reset;
                                        LoanTopUp.SetRange(LoanTopUp."Loan No.", LoanApps."Loan  No.");
                                        if LoanTopUp.Find('-') then begin
                                            repeat
                                                //Principle
                                                LineNo := LineNo + 10000;
                                                GenJournalLine.Init;
                                                GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                GenJournalLine."Journal Batch Name" := 'LOANS';
                                                GenJournalLine."Line No." := LineNo;
                                                GenJournalLine."Document No." := "Document No.";
                                                GenJournalLine."Posting Date" := "Posting Date";
                                                GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                                GenJournalLine."Account No." := LoanApps."Client Code";
                                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                                GenJournalLine.Description := 'Off Set By - ' + LoanApps."Loan  No.";
                                                GenJournalLine.Amount := LoanTopUp."Principle Top Up" * -1;
                                                GenJournalLine.Validate(GenJournalLine.Amount);
                                                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                                                GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                if GenJournalLine.Amount <> 0 then
                                                    GenJournalLine.Insert;


                                                //Interest (Reversed if top up)
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    LineNo := LineNo + 10000;
                                                    GenJournalLine.Init;
                                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                                    GenJournalLine."Line No." := LineNo;
                                                    GenJournalLine."Account Type" := GenJournalLine."bal. account type"::Employee;
                                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                                    GenJournalLine."Document No." := "Document No.";
                                                    GenJournalLine."Posting Date" := "Posting Date";
                                                    GenJournalLine.Description := 'Interest Due Paid on top up ' + LoanApps."Loan Product Type Name";
                                                    GenJournalLine.Amount := -LoanTopUp."Interest Top Up";
                                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                                    GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                                    GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                    if GenJournalLine.Amount <> 0 then
                                                        GenJournalLine.Insert;
                                                end;
                                                //Commision
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    if LoanType."Top Up Commision" > 0 then begin
                                                        LineNo := LineNo + 10000;
                                                        GenJournalLine.Init;
                                                        GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                        GenJournalLine."Journal Batch Name" := 'LOANS';
                                                        GenJournalLine."Line No." := LineNo;
                                                        GenJournalLine."Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                                        GenJournalLine."Account No." := LoanType."Top Up Commision Account";
                                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                                        GenJournalLine."Document No." := "Document No.";
                                                        GenJournalLine."Posting Date" := "Posting Date";
                                                        GenJournalLine.Description := 'Levy on Bridging';
                                                        TopUpComm := LoanTopUp.Commision;
                                                        TotalTopupComm := TotalTopupComm + TopUpComm;
                                                        GenJournalLine.Amount := TopUpComm * -1;
                                                        GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                                        GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                        GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                        if GenJournalLine.Amount <> 0 then
                                                            GenJournalLine.Insert;
                                                    end;
                                                end;

                                                BatchTopUpAmount := BatchTopUpAmount + LoanApps."Top Up Amount" + LoanTopUp."Interest Top Up";
                                                BatchTopUpComm := BatchTopUpComm + TotalTopupComm;


                                            until LoanTopUp.Next = 0;
                                        end;
                                    end;






                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                    GenJournalLine."Account No." := GenSetUp."Loan Trasfer Fee A/C-EFT";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    GenJournalLine.Description := 'EFT COMMision';
                                    GenJournalLine.Amount := GenSetUp."Loan Trasfer Fee-EFT" * -1;
                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                                    GenJournalLine."Account No." := "BOSA Bank Account";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount" * -1 + (GenSetUp."Loan Trasfer Fee-EFT" + BatchTopUpAmount + BatchTopUpComm);
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;


                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Loan;
                                    GenJournalLine."Loan No" := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                until LoanApps.Next = 0;
                            end;
                        end;
                        // end of eft
                        // cheque posting
                        if "Mode Of Disbursement" = "mode of disbursement"::Cheque then begin
                            LoanApps.Reset;
                            LoanApps.SetRange(LoanApps."Batch No.", "Batch No.");
                            LoanApps.SetRange(LoanApps."System Created", false);
                            LoanApps.SetFilter(LoanApps."Loan Status", '<>Rejected');
                            if LoanApps.Find('-') then begin
                                repeat

                                    LoanApps.CalcFields(LoanApps."Top Up Amount");
                                    TCharges := 0;
                                    TopUpComm := 0;
                                    TotalTopupComm := 0;

                                    DActivity := 'BOSA';
                                    DBranch := 'NAIROBI';


                                    if LoanApps."Top Up Amount" > 0 then begin
                                        LoanTopUp.Reset;
                                        LoanTopUp.SetRange(LoanTopUp."Loan No.", LoanApps."Loan  No.");
                                        if LoanTopUp.Find('-') then begin
                                            repeat
                                                //Principle
                                                LineNo := LineNo + 10000;
                                                GenJournalLine.Init;
                                                GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                GenJournalLine."Journal Batch Name" := 'LOANS';
                                                GenJournalLine."Line No." := LineNo;
                                                GenJournalLine."Document No." := "Document No.";
                                                GenJournalLine."Posting Date" := "Posting Date";
                                                GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                                GenJournalLine."Account No." := LoanApps."Client Code";
                                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                                GenJournalLine.Description := 'Off Set By - ' + LoanApps."Loan  No.";
                                                GenJournalLine.Amount := LoanTopUp."Principle Top Up" * -1;
                                                GenJournalLine.Validate(GenJournalLine.Amount);
                                                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                                                GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                if GenJournalLine.Amount <> 0 then
                                                    GenJournalLine.Insert;


                                                //Interest (Reversed if top up)
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    LineNo := LineNo + 10000;
                                                    GenJournalLine.Init;
                                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                                    GenJournalLine."Line No." := LineNo;
                                                    GenJournalLine."Account Type" := GenJournalLine."bal. account type"::Employee;
                                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                                    GenJournalLine."Document No." := "Document No.";
                                                    GenJournalLine."Posting Date" := "Posting Date";
                                                    GenJournalLine.Description := 'Interest Due Paid on top up ' + LoanApps."Loan Product Type Name";
                                                    GenJournalLine.Amount := -LoanTopUp."Interest Top Up";
                                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                                    GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                                    GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                    if GenJournalLine.Amount <> 0 then
                                                        GenJournalLine.Insert;
                                                end;
                                                //Commision
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    if LoanType."Top Up Commision" > 0 then begin
                                                        LineNo := LineNo + 10000;
                                                        GenJournalLine.Init;
                                                        GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                        GenJournalLine."Journal Batch Name" := 'LOANS';
                                                        GenJournalLine."Line No." := LineNo;
                                                        GenJournalLine."Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                                        GenJournalLine."Account No." := LoanType."Top Up Commision Account";
                                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                                        GenJournalLine."Document No." := "Document No.";
                                                        GenJournalLine."Posting Date" := "Posting Date";
                                                        GenJournalLine.Description := 'Levy on Bridging';
                                                        TopUpComm := LoanTopUp.Commision;
                                                        TotalTopupComm := TotalTopupComm + TopUpComm;
                                                        GenJournalLine.Amount := TopUpComm * -1;
                                                        GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                                        GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                        GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                        if GenJournalLine.Amount <> 0 then
                                                            GenJournalLine.Insert;
                                                    end;
                                                end;

                                                BatchTopUpAmount := BatchTopUpAmount + LoanApps."Top Up Amount" + LoanTopUp."Interest Top Up";
                                                BatchTopUpComm := BatchTopUpComm + TotalTopupComm;


                                            until LoanTopUp.Next = 0;
                                        end;
                                    end;






                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                    GenJournalLine."Account No." := GenSetUp."Loan Trasfer Fee A/C-Cheque";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    GenJournalLine.Description := 'EFT COMM';
                                    GenJournalLine.Amount := GenSetUp."Loan Trasfer Fee-Cheque" * -1;
                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                                    GenJournalLine."Account No." := "BOSA Bank Account";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount" * -1 + (GenSetUp."Loan Trasfer Fee-Cheque" + BatchTopUpAmount + BatchTopUpComm);
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;


                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Loan;
                                    GenJournalLine."Loan No" := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                until LoanApps.Next = 0;
                            end;
                        end;

                        //rtgs
                        if "Mode Of Disbursement" = "mode of disbursement"::"5" then begin
                            LoanApps.Reset;
                            LoanApps.SetRange(LoanApps."Batch No.", "Batch No.");
                            LoanApps.SetRange(LoanApps."System Created", false);
                            LoanApps.SetFilter(LoanApps."Loan Status", '<>Rejected');
                            if LoanApps.Find('-') then begin
                                repeat

                                    LoanApps.CalcFields(LoanApps."Top Up Amount");
                                    TCharges := 0;
                                    TopUpComm := 0;
                                    TotalTopupComm := 0;

                                    DActivity := 'BOSA';
                                    DBranch := 'NAIROBI';


                                    if LoanApps."Top Up Amount" > 0 then begin
                                        LoanTopUp.Reset;
                                        LoanTopUp.SetRange(LoanTopUp."Loan No.", LoanApps."Loan  No.");
                                        if LoanTopUp.Find('-') then begin
                                            repeat
                                                //Principle
                                                LineNo := LineNo + 10000;
                                                GenJournalLine.Init;
                                                GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                GenJournalLine."Journal Batch Name" := 'LOANS';
                                                GenJournalLine."Line No." := LineNo;
                                                GenJournalLine."Document No." := "Document No.";
                                                GenJournalLine."Posting Date" := "Posting Date";
                                                GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                                GenJournalLine."Account No." := LoanApps."Client Code";
                                                GenJournalLine.Validate(GenJournalLine."Account No.");
                                                GenJournalLine.Description := 'Off Set By - ' + LoanApps."Loan  No.";
                                                GenJournalLine.Amount := LoanTopUp."Principle Top Up" * -1;
                                                GenJournalLine.Validate(GenJournalLine.Amount);
                                                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                                                GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                if GenJournalLine.Amount <> 0 then
                                                    GenJournalLine.Insert;


                                                //Interest (Reversed if top up)
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    LineNo := LineNo + 10000;
                                                    GenJournalLine.Init;
                                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                                    GenJournalLine."Line No." := LineNo;
                                                    GenJournalLine."Account Type" := GenJournalLine."bal. account type"::Employee;
                                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                                    GenJournalLine."Document No." := "Document No.";
                                                    GenJournalLine."Posting Date" := "Posting Date";
                                                    GenJournalLine.Description := 'Interest Due Paid on top up ' + LoanApps."Loan Product Type Name";
                                                    GenJournalLine.Amount := -LoanTopUp."Interest Top Up";
                                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                                    GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
                                                    GenJournalLine."Loan No" := LoanTopUp."Loan Top Up";
                                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                    if GenJournalLine.Amount <> 0 then
                                                        GenJournalLine.Insert;
                                                end;
                                                //Commision
                                                if LoanType.Get(LoanApps."Loan Product Type") then begin
                                                    if LoanType."Top Up Commision" > 0 then begin
                                                        LineNo := LineNo + 10000;
                                                        GenJournalLine.Init;
                                                        GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                                        GenJournalLine."Journal Batch Name" := 'LOANS';
                                                        GenJournalLine."Line No." := LineNo;
                                                        GenJournalLine."Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                                        GenJournalLine."Account No." := LoanType."Top Up Commision Account";
                                                        GenJournalLine.Validate(GenJournalLine."Account No.");
                                                        GenJournalLine."Document No." := "Document No.";
                                                        GenJournalLine."Posting Date" := "Posting Date";
                                                        GenJournalLine.Description := 'Levy on Bridging';
                                                        TopUpComm := LoanTopUp.Commision;
                                                        TotalTopupComm := TotalTopupComm + TopUpComm;
                                                        GenJournalLine.Amount := TopUpComm * -1;
                                                        GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                                        GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                                        GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                                        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                                        if GenJournalLine.Amount <> 0 then
                                                            GenJournalLine.Insert;
                                                    end;
                                                end;

                                                BatchTopUpAmount := BatchTopUpAmount + LoanApps."Top Up Amount" + LoanTopUp."Interest Top Up";
                                                BatchTopUpComm := BatchTopUpComm + TotalTopupComm;


                                            until LoanTopUp.Next = 0;
                                        end;
                                    end;






                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                                    GenJournalLine."Account No." := GenSetUp."Loan Trasfer Fee A/C-RTGS";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    GenJournalLine.Description := 'EFT COMM';
                                    GenJournalLine.Amount := GenSetUp."Loan Trasfer Fee-RTGS" * -1;
                                    GenJournalLine."External Document No." := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                                    GenJournalLine."Account No." := "BOSA Bank Account";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount" * -1 + (GenSetUp."Loan Trasfer Fee-RTGS" + BatchTopUpAmount + BatchTopUpComm);
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;


                                    GenJournalLine.Init;
                                    LineNo := LineNo + 10000;
                                    GenJournalLine."Journal Template Name" := 'PAYMENTS';
                                    GenJournalLine."Journal Batch Name" := 'LOANS';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Document No." := "Document No.";
                                    GenJournalLine."Posting Date" := "Posting Date";
                                    LoanApps.TestField(LoanApps."Client Code");
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Employee;
                                    GenJournalLine."Account No." := LoanApps."Client Code";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine.Description := 'loans';
                                    GenJournalLine.Amount := LoanApps."Approved Amount";
                                    GenJournalLine.Validate(GenJournalLine.Amount);
                                    GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
                                    GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Loan;
                                    GenJournalLine."Loan No" := LoanApps."Loan  No.";
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;

                                until LoanApps.Next = 0;
                            end;
                        end;

                        /*
                        //Post New
                        GenJournalLine.RESET;
                        GenJournalLine.SETRANGE("Journal Template Name",'PAYMENTS');
                        GenJournalLine.SETRANGE("Journal Batch Name",'LOANS');
                        IF GenJournalLine.FIND('-') THEN BEGIN
                        CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post B",GenJournalLine);
                        END;
                        LoanApps.Posted:=TRUE;
                        LoanApps.MODIFY;
                        Posted:=TRUE;
                        MODIFY;
                        
                        
                         */
                        Message('Batch posted successfully.');

                    end;
                }
            }
        }
    }

    var
        MovementTracker: Record UnknownRecord51516395;
        FileMovementTracker: Record UnknownRecord51516395;
        NextStage: Integer;
        EntryNo: Integer;
        NextLocation: Text[100];
        LoansBatch: Record UnknownRecord51516377;
        i: Integer;
        LoanType: Record UnknownRecord51516381;
        PeriodDueDate: Date;
        ScheduleRep: Record UnknownRecord51516375;
        RunningDate: Date;
        G: Integer;
        IssuedDate: Date;
        GracePeiodEndDate: Date;
        InstalmentEnddate: Date;
        GracePerodDays: Integer;
        InstalmentDays: Integer;
        NoOfGracePeriod: Integer;
        NewSchedule: Record UnknownRecord51516375;
        RSchedule: Record UnknownRecord51516375;
        GP: Text[30];
        ScheduleCode: Code[20];
        PreviewShedule: Record UnknownRecord51516375;
        PeriodInterval: Code[10];
        CustomerRecord: Record UnknownRecord51516364;
        Gnljnline: Record "Gen. Journal Line";
        Jnlinepost: Codeunit "Gen. Jnl.-Post Line";
        CumInterest: Decimal;
        NewPrincipal: Decimal;
        PeriodPrRepayment: Decimal;
        GenBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
        GnljnlineCopy: Record "Gen. Journal Line";
        NewLNApplicNo: Code[10];
        Cust: Record UnknownRecord51516364;
        LoanApp: Record UnknownRecord51516371;
        TestAmt: Decimal;
        CustRec: Record UnknownRecord51516364;
        CustPostingGroup: Record "Customer Posting Group";
        GenSetUp: Record UnknownRecord51516398;
        PCharges: Record UnknownRecord51516383;
        TCharges: Decimal;
        LAppCharges: Record UnknownRecord51516385;
        Loans: Record UnknownRecord51516371;
        LoanAmount: Decimal;
        InterestRate: Decimal;
        RepayPeriod: Integer;
        LBalance: Decimal;
        RunDate: Date;
        InstalNo: Decimal;
        RepayInterval: DateFormula;
        TotalMRepay: Decimal;
        LInterest: Decimal;
        LPrincipal: Decimal;
        RepayCode: Code[40];
        GrPrinciple: Integer;
        GrInterest: Integer;
        QPrinciple: Decimal;
        QCounter: Integer;
        InPeriod: DateFormula;
        InitialInstal: Integer;
        InitialGraceInt: Integer;
        GenJournalLine: Record "Gen. Journal Line";
        FOSAComm: Decimal;
        BOSAComm: Decimal;
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        LoanTopUp: Record UnknownRecord51516376;
        Vend: Record Vendor;
        BOSAInt: Decimal;
        TopUpComm: Decimal;
        DActivity: Code[20];
        DBranch: Code[20];
        UsersID: Record User;
        TotalTopupComm: Decimal;
        CustE: Record UnknownRecord51516364;
        DocN: Text[50];
        DocM: Text[100];
        DNar: Text[250];
        DocF: Text[50];
        MailBody: Text[250];
        ccEmail: Text[250];
        LoanG: Record UnknownRecord51516372;
        SpecialComm: Decimal;
        LoanApps: Record UnknownRecord51516371;
        Banks: Record "Bank Account";
        BatchTopUpAmount: Decimal;
        BatchTopUpComm: Decimal;
        TotalSpecialLoan: Decimal;
        SpecialLoanCl: Record UnknownRecord51516379;
        Loans2: Record UnknownRecord51516371;
        DActivityBOSA: Code[20];
        DBranchBOSA: Code[20];
        Refunds: Record UnknownRecord51516381;
        TotalRefunds: Decimal;
        WithdrawalFee: Decimal;
        NetPayable: Decimal;
        NetRefund: Decimal;
        FWithdrawal: Decimal;
        OutstandingInt: Decimal;
        TSC: Decimal;
        LoanDisbAmount: Decimal;
        NegFee: Decimal;
        DValue: Record "Dimension Value";
        ChBank: Code[20];
        Trans: Record UnknownRecord51516441;
        TransactionCharges: Record UnknownRecord51516442;
        BChequeRegister: Record UnknownRecord51516456;
        OtherCommitments: Record UnknownRecord51516403;
        BoostingComm: Decimal;
        BoostingCommTotal: Decimal;
        BridgedLoans: Record UnknownRecord51516379;
        InterestDue: Decimal;
        ContractualShares: Decimal;
        BridgingChanged: Boolean;
        BankersChqNo: Code[20];
        LastPayee: Text[100];
        RunningAmount: Decimal;
        BankersChqNo2: Code[20];
        BankersChqNo3: Code[20];
        EndMonth: Date;
        RemainingDays: Integer;
        PrincipalRepay: Decimal;
        InterestRepay: Decimal;
        TMonthDays: Integer;
        SMSMessage: Record UnknownRecord51516373;
        iEntryNo: Integer;
        Temp: Record Customer;
        Jtemplate: Code[30];
        JBatch: Code[30];
        LBatches: Record UnknownRecord51516377;
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","None",JV,"Member Closure","Account Opening",Batches,"Payment Voucher","Petty Cash",Requisition,Loan,Imprest,ImprestSurrender,Interbank;
}

