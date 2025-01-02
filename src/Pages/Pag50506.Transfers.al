Page 50506 "Transfers"
{
    ApplicationArea = Basic;
    DeleteAllowed = true;
    Editable = true;
    PageType = Card;
    SourceTable = "BOSA Transfers";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = TransfersEditable;

                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                    visible = false;
                }
                field("Schedule Total"; Rec."Schedule Total")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Captured By"; Rec."Captured By")
                {
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if Rec.Status = Rec.Status::Approved then Rec.Approved := true;
                        Rec.Modify;
                        if Rec.Status <> Rec.Status::Open then
                            TransfersEditable := false
                        else
                            TransfersEditable := true;
                    end;
                }
            }
            part(Control1102760014; "Transfer Schedule")
            {
                Editable = TransfersEditable;
                SubPageLink = "No." = field(No);
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            group(Posting)
            {
                Caption = 'Posting';

                action(Post)
                {
                    ApplicationArea = Basic;
                    Caption = 'Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        DBranch := BSched."Branch Code";
                        // TestField(Status, Status::Approved);
                        if FundsUSer.Get(UserId) then begin
                            Jtemplate := FundsUSer."Payment Journal Template";
                            Jbatch := FundsUSer."Payment Journal Batch";
                        end;
                        if Rec.Posted = true then Error('This Schedule is already posted');
                        if Confirm('Are you sure you want to transfer schedule?', false) = true then begin
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange(GenJournalLine."Journal Template Name", Jtemplate);
                            GenJournalLine.SetRange(GenJournalLine."Journal Batch Name", Jbatch);
                            GenJournalLine.DeleteAll;
                            //...................................................................
                            FnCreatePostingGLlines();
                            //...................................................................
                            //Post
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", Jtemplate);
                            GenJournalLine.SetRange("Journal Batch Name", Jbatch);
                            if GenJournalLine.Find('-') then begin
                                Codeunit.Run(Codeunit::"Gen. Jnl.-Post Batch", GenJournalLine);
                            end;
                            //Post
                            Rec.Posted := true;
                            Rec.Modify;
                            Message('Transfer posted successfully');
                        end;
                        Commit;
                    end;
                }
                action(Print)
                {
                    ApplicationArea = Basic;
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    visible = false;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        BTRANS.Reset;
                        BTRANS.SetRange(BTRANS.No, Rec.No);
                        if BTRANS.Find('-') then begin
                            Report.Run(50293, true, true, BTRANS);
                        end;
                    end;
                }
                separator(Action1000000005)
                {
                }
                action(Refresh)
                {
                    ApplicationArea = Basic;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Image = Refresh;

                    trigger OnAction()
                    begin
                        CurrPage.Update();
                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    Visible = false;

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Approvals Mgmt.";
                        Text001: label 'This batch is already pending approval';
                        NoSeriesMgt: Codeunit NoSeriesManagement;
                        SrestepApprovalsCodeUnit: Codeunit SurestepApprovalsCodeUnit;
                    begin
                        if Rec.Status <> Rec.Status::Open then Error(Text001);
                        SrestepApprovalsCodeUnit.SendBOSATransForApproval(rec.No, Rec);
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = process;
                    Visible = false;

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Approvals Mgmt.";
                        SrestepApprovalsCodeUnit: Codeunit SurestepApprovalsCodeUnit;
                    begin
                        if Confirm('Cancel Approval?', false) = true then begin
                            SrestepApprovalsCodeUnit.CancelBOSATransRequestForApproval(rec.No, Rec);
                        end;
                    end;
                }
                separator(Action1000000001)
                {
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if Rec.Status <> Rec.Status::Open then
            TransfersEditable := false
        else
            TransfersEditable := true;
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Error('Not Allowed!');
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Transactions.Reset;
        Transactions.SetRange(Transactions.Posted, false);
        Transactions.SetRange(Transactions.Approved, false);
        //Transactions.SETRANGE(CashierTrans.Cashier,USERID);
        /*
            IF Transactions.COUNT >0 THEN BEGIN
              IF Transactions.No='' THEN BEGIN
                IF CONFIRM(text002,TRUE)=TRUE THEN
                  ERROR(text003)
                ELSE
                ERROR(text003);
                  END;
                  END;
            */
    end;

    trigger OnOpenPage()
    begin
        Rec."Captured By" := UserId;
        if Rec.Status <> Rec.Status::Open then
            TransfersEditable := false
        else
            TransfersEditable := true;
    end;

    local procedure FnCreatePostingGLlines()
    begin
        BSched.Reset();
        BSched.SetRange(BSched."No.", Rec.No);
        if BSched.Find('-') then begin
            repeat
                if BSched."Line Description" = '' then begin
                    Error('Line description cannot be empty');
                end;
            until BSched.Next = 0;
        end;
        //..........................................................
        BSched.Reset();
        BSched.SetRange(BSched."No.", Rec.No);
        if BSched.Find('-') then begin
            repeat
                GenJournalLine.Init();
                GenJournalLine."Journal Template Name" := Jtemplate;
                GenJournalLine."Journal Batch Name" := Jbatch;
                GenJournalLine."Document No." := Rec.No;
                GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                if BSched."Source Type" = BSched."Source Type"::Member then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Transaction Type" := BSched."Transaction Type";
                    GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                    GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Account No." := BSched."Source Account No.";
                    GenJournalLine."Loan No" := BSched.Loan;
                end
                else if BSched."Source Type" = BSched."Source Type"::Vendor then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                    GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Account No." := BSched."Source Account No.";
                end
                else if BSched."Source Type" = BSched."Source Type"::"G/L ACCOUNT" then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Transaction Type" := BSched."Transaction Type";
                    GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Account No." := BSched."Source Account No.";
                    GenJournalLine."Loan No" := BSched.Loan;
                end
                else if BSched."Source Type" = BSched."Source Type"::Bank then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Account No." := BSched."Source Account No.";
                end;
                GenJournalLine."Posting Date" := Rec."Transaction Date";
                GenJournalLine.Description := BSched."Line Description";
                GenJournalLine.Amount := BSched.Amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                GenJournalLine.Insert();
                //......................................................................Source is vendor
                // if BSched."Source Type" = BSched."Source Type"::Vendor then begin
                //     if BSched."Charge Type" = BSched."Charge Type"::Milk then begin
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'Milk Transfer Charges';
                //         GenJournalLine.Amount := BSched."Charge Amount";
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '5421';
                //         GenJournalLine.Insert();
                //         //.....................................................
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'Milk Transfer Charges Excise Duty';
                //         GenJournalLine.Amount := BSched."Charge Amount" * 0.2;
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '3326';
                //         GenJournalLine.Insert(true);
                //     end;
                //     //......................................................................
                //     if BSched."Charge Type" = BSched."Charge Type"::"BOSA Transfer" then begin
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'BOSA Transfer Charges';
                //         GenJournalLine.Amount := BSched."Charge Amount";
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '5421';
                //         GenJournalLine.Insert();
                //         //.....................................................
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'BOSA Transfer Charges Excise Duty';
                //         GenJournalLine.Amount := BSched."Charge Amount" * 0.2;
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '3326';
                //         GenJournalLine.Insert();
                //     end;
                //     //..........................................................................
                //     if BSched."Charge Type" = BSched."Charge Type"::Salary then begin
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'Salary Charges';
                //         GenJournalLine.Amount := BSched."Charge Amount";
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '5421';
                //         GenJournalLine.Insert();
                //         //.....................................................
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'Salary Charges Excise Duty';
                //         GenJournalLine.Amount := BSched."Charge Amount" * 0.2;
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '3326';
                //         GenJournalLine.Insert();
                //     end;
                //     if BSched."Charge Type" = BSched."Charge Type"::FDR then begin
                //         GenJournalLine.Init();
                //         GenJournalLine."Journal Template Name" := Jtemplate;
                //         GenJournalLine."Journal Batch Name" := Jbatch;
                //         GenJournalLine."Document No." := No;
                //         GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                //         GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                //         GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                //         GenJournalLine."Shortcut Dimension 2 Code" := BSched."Branch Code";
                //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                //         GenJournalLine."Account No." := BSched."Source Account No.";
                //         GenJournalLine."Posting Date" := "Transaction Date";
                //         GenJournalLine.Description := 'FDR Transfer Charges';
                //         GenJournalLine.Amount := BSched."Charge Amount";
                //         GenJournalLine.Validate(GenJournalLine.Amount);
                //         GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
                //         GenJournalLine."Bal. Account No." := '5421';
                //         GenJournalLine.Insert();
                //     end;
                // end;
                //...................................................................
                GenJournalLine."Journal Template Name" := Jtemplate;
                GenJournalLine."Journal Batch Name" := Jbatch;
                GenJournalLine."Document No." := Rec.No;
                GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                if BSched."Destination Account Type" = BSched."Destination Account Type"::Member then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                    GenJournalLine."Transaction Type" := BSched."Destination Type";
                    GenJournalLine."Account No." := BSched."Destination Account No.";
                    GenJournalLine."Loan No" := BSched."Destination Loan";
                    GenJournalLine.Validate(GenJournalLine."Loan No");
                end
                else if BSched."Destination Account Type" = BSched."Destination Account Type"::Vendor then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                    GenJournalLine."Transaction Type" := BSched."Destination Type";
                    GenJournalLine."Account No." := BSched."Destination Account No.";
                end
                else if BSched."Destination Account Type" = BSched."Destination Account Type"::"G/L ACCOUNT" then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
                    GenJournalLine."Account No." := BSched."Destination Account No.";
                end
                else if BSched."Destination Account Type" = BSched."Destination Account Type"::Bank then begin
                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                    GenJournalLine."Account No." := BSched."Destination Account No.";
                end;
                GenJournalLine."Posting Date" := Rec."Transaction Date";
                GenJournalLine.Description := BSched."Line Description";
                GenJournalLine.Amount := -BSched.Amount;
                GenJournalLine.Validate(GenJournalLine.Amount);
                GenJournalLine."Bal. Account No." := '';
                GenJournalLine.Insert();
            until BSched.Next = 0;
        end;
    end;

    var
        users: Record User;
        GenJournalLine: Record "Gen. Journal Line";
        DefaultBatch: Record "Gen. Journal Batch";
        BSched: Record "BOSA Transfer Schedule";
        BTRANS: Record "BOSA Transfers";
        DActivity: Code[20];
        DBranch: Code[20];
        UsersID: Record User;
        FundsUSer: Record "Funds User Setup";
        Jtemplate: Code[10];
        Jbatch: Code[10];
        Doc_Type: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","None",JV,"Member Closure","Account Opening",Batches,"Payment Voucher","Petty Cash",Requisition,Loan,Interbank,Imprest,Checkoff,"FOSA Account Opening",StandingOrder,HRJob,HRLeave,"HRTransport Request",HRTraining,"HREmp Requsition",MicroTrans,"Account Reactivation","Overdraft ",BLA,"Member Editable","FOSA Opening","Loan Batching",Leave,"Imprest Requisition","Imprest Surrender","Stores Requisition","Funds Transfer","Change Request","Staff Claims","BOSA Transfer","Loan Tranche","Loan TopUp","Memb Opening","Member Withdrawal";
        ApprovalMgt: Codeunit "Approvals Mgmt.";
        TransfersEditable: Boolean;
        Transactions: Record "BOSA Transfers";
        text002: label 'There are unused transactions. Do you wish to continue?';
        text003: label 'Please Utilize the unused transactions first';
}
