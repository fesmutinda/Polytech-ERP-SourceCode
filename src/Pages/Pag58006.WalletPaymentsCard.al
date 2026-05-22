Page 58006 "Wallet Payments Card"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Wallet Transactions";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic;
                    Editable = TransactionDateEditable;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                    Editable = RemarkEditable;
                }
                field("Source Account No"; Rec."Source Account No")
                {
                    ApplicationArea = Basic;
                    Editable = SourceAccountNoEditbale;
                }
                field("Source Account Name"; Rec."Source Account Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Schedule Total"; Rec."Schedule Total")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Approved; Rec.Approved)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            part(Control1102760014; "Wallet Transaction Schedule")
            {
                SubPageLink = "No." = field(No);
            }
        }
    }

    actions
    {
        area(processing)
        {

            action("Import Lines")
            {
                ApplicationArea = BAsic;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;

                RunObject = xmlport "Wallet Transactions Import";
            }
            // 2. Validate Receipts
            action("Validate Receipts")
            {
                ApplicationArea = Basic;
                Caption = 'Validate Receipts';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RcptBufLines: Record "Wallet Transaction Schedule";
                    Memb: Record Customer;
                    vendorTable: Record Vendor;
                begin
                    RcptBufLines.Reset;
                    RcptBufLines.SetRange(RcptBufLines."No.", Rec.No);
                    if RcptBufLines.Find('-') then begin
                        repeat

                            Memb.Reset();
                            Memb.SetRange(Memb."No.", RcptBufLines."Member Number");
                            // Memb.SetRange(Memb."Personal No", RcptBufLines."Payroll Number");
                            //Memb.SETRANGE(Memb."Employer Code",RcptBufLines."Employer Code");
                            if Memb.Find('-') then begin

                                vendorTable.Reset();
                                vendorTable.SetRange("BOSA Account No", Memb."No.");
                                if vendorTable.Find('-') then begin
                                    RcptBufLines."Destination Account Name" := vendorTable.Name;
                                    RcptBufLines."Destination Account No." := vendorTable."No.";
                                    RcptBufLines.Description := 'Member Sitting Allowance';
                                    RcptBufLines.Modify;
                                end;
                            end;
                        until RcptBufLines.Next = 0;
                    end;
                    Message('Successfully validated');
                end;
            }
            // 3. Refresh Page
            action(RefreshPage)
            {
                Caption = 'Refresh page';
                Promoted = true;
                PromotedCategory = Process;
                Image = Refresh;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    // Message('Refreshing...');
                    CurrPage.Update; // Refresh the current page UI
                    Rec.Validate("Schedule Total");
                    Rec.Modify(true);
                    Message('Page refreshed and data updated.');
                end;
            }
            group(Posting)
            {
                Caption = 'Posting';

                action("Send Approval Request")
                {
                    Visible = false;
                    ApplicationArea = Basic;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = process;

                    trigger OnAction()
                    var
                        Approvals: Codeunit SwizzsoftApprovalsCodeUnit;
                    begin
                        if Confirm('Send Approval Request ?', false) = false then begin
                            exit;
                        end else begin
                            // Approvals.SendInternalTransfersTransactionsRequestForApproval(rec.No, Rec);
                            Rec.Approved := true;
                            Rec."Approved By" := UserId;
                            Rec.Status := Rec.Status::Approved;
                            Rec.Modify();

                            CurrPage.Close();
                        end;
                    end;
                }
                action("Cancel Approval Request")
                {
                    Visible = false;
                    ApplicationArea = Basic;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = process;

                    trigger OnAction()
                    var
                        Approvals: Codeunit SwizzsoftApprovalsCodeUnit;
                    begin
                        if Confirm('Cancel Approval Request ?', false) = false then begin
                            exit;
                        end else begin
                            // Approvals.CancelInternalTransfersTransactionsRequestForApproval(rec.No, Rec);
                            // Rec.Approved:=Rec.Approved:
                            CurrPage.Close();
                        end;
                    end;
                }

                action(PostNav)
                {
                    ApplicationArea = Basic;
                    Caption = 'Post';
                    Image = Post;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    trigger OnAction()
                    var
                        ObjVendors: Record Vendor;
                        swizzMobile: Codeunit SwizzKashMobile;
                        message: Text[1000];
                        Member: Record Customer;
                    begin
                        Jtemplate := 'GENERAL';
                        Jbatch := 'WalletTran';

                        IF Rec.Posted = TRUE THEN
                            ERROR('This Shedule is already posted');

                        if Rec.Remarks = '' then
                            Error('Please enter the Transaction remarks');

                        IF CONFIRM('Are you sure you want to transfer schedule?', FALSE) = TRUE THEN BEGIN

                            Rec.CalcFields("Schedule Total");
                            if Rec."Schedule Total" <> Rec."Total Amount" then
                                Error('Please Confirm the Total Amounts as they dont match the Scheduled Amount');

                            //IF Approved=FALSE THEN
                            //ERROR('This schedule is not approved');

                            swizzMobile.PrepareGLJournalBatch(Jtemplate, Jbatch, 'MOBILE M-Wallet Transactions');
                            swizzMobile.ClearGLJournal(Jtemplate, Jbatch);


                            // DELETE ANY LINE ITEM THAT MAY BE PRESENT
                            GenJournalLine.RESET;
                            GenJournalLine.SETRANGE(GenJournalLine."Journal Template Name", Jtemplate);
                            GenJournalLine.SETRANGE(GenJournalLine."Journal Batch Name", Jbatch);
                            GenJournalLine.DeleteAll();

                            //POSTING MAIN TRANSACTION

                            //window.OPEN('Posting:,#1######################');
                            BSched.RESET;
                            BSched.SETRANGE(BSched."No.", Rec.No);

                            // UPDATE Source Account
                            GenJournalLine.INIT;
                            GenJournalLine."Journal Template Name" := Jtemplate;
                            GenJournalLine."Journal Batch Name" := Jbatch;
                            GenJournalLine."Document No." := Rec.No;
                            GenJournalLine.Description := BSched."Description" + ' ' + Rec."Source Account No";
                            GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                            GenJournalLine."Shortcut Dimension 2 Code" := BTRANS."Global Dimension 2 Code";
                            GenJournalLine."Account No." := Rec."Source Account No";

                            GenJournalLine."Posting Date" := Rec."Transaction Date";
                            GenJournalLine.Description := Rec.Remarks;// BSched."Description" + ' ' + Rec."Source Account No";
                            Rec.CALCFIELDS("Schedule Total");
                            GenJournalLine.Amount := Rec."Schedule Total";
                            GenJournalLine.INSERT;


                            BSched.RESET;
                            BSched.SETRANGE(BSched."No.", Rec.No);
                            IF BSched.FIND('-') THEN BEGIN
                                REPEAT

                                    GenJournalLine.Init();
                                    message := '';

                                    GenJournalLine."Journal Template Name" := Jtemplate;
                                    GenJournalLine."Journal Batch Name" := Jbatch;
                                    GenJournalLine."Document No." := Rec.No;
                                    GenJournalLine."Line No." := GenJournalLine."Line No." + 10000;

                                    GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                                    GenJournalLine."Account No." := BSched."Destination Account No.";

                                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                                    GenJournalLine."Posting Date" := Rec."Transaction Date";
                                    GenJournalLine.Description := BSched."Description" + ' ' + BSched."Destination Account Name";
                                    GenJournalLine.Amount := -BSched.Amount;
                                    //GenJournalLine.VALIDATE(GenJournalLine.Amount);
                                    GenJournalLine.INSERT;

                                    //send SMS Messages
                                    Member.Get(BSched."Member Number");
                                    message := 'Dear ' + BSched."Destination Account Name"
                                    + ', Your M-Wallet Account has been credited Kes.' + Format(BSched.Amount) + ' '
                                    + BSched.Description + '. Thank you for Choosing Polytech Sacco';

                                    swizzMobile.SMSMessage(Rec.No, BSched."Destination Account No.",
                                    Member."Mobile Phone No",
                                    message);
                                UNTIL BSched.NEXT = 0;
                            END;
                            // exit;

                            //Post
                            GenJournalLine.Reset();
                            GenJournalLine.SETRANGE("Journal Template Name", Jtemplate);
                            GenJournalLine.SETRANGE("Journal Batch Name", Jbatch);
                            IF GenJournalLine.FIND('-') THEN BEGIN
                                CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post", GenJournalLine);
                            END;

                            //Post
                            Rec.Posted := TRUE;
                            Rec.MODIFY;
                            MESSAGE('Transaction posted succesfully');

                        END;
                    end;
                }
                action(Print)
                {
                    ApplicationArea = Basic;
                    Caption = 'Print';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    begin
                        BTRANS.Reset;
                        BTRANS.SetRange(BTRANS.No, Rec.No);
                        if BTRANS.Find('-') then begin
                            Report.Run(51516902, true, true, BTRANS);
                        end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        AddRecordRestriction();
    end;

    trigger OnAfterGetRecord()
    begin
        AddRecordRestriction();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Error('Not Allowed!');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        // Rec."Source Account Type" := Rec."source account type"::Fosa;
    end;

    trigger OnOpenPage()
    begin
        // Rec."Source Account Type" := Rec."source account type"::Fosa;
        AddRecordRestriction();
    end;

    var
        users: Record User;
        GenJournalLine: Record "Gen. Journal Line";
        DefaultBatch: Record "Gen. Journal Batch";
        BSched: Record "Wallet Transaction Schedule";// "Sacco Transfers Schedule";
        BTRANS: Record "Wallet Transactions";// "Sacco Transfers";
        DActivity: Code[20];
        DBranch: Code[20];
        UsersID: Record User;
        FundsUSer: Record "Funds User Setup";
        Jtemplate: Code[10];
        Jbatch: Code[10];
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal,ATMCard,GuarantorRecovery,ChangeRequest,TreasuryTransactions,FundsTransfer,SaccoTransfers;
        SourceAccountNoEditbale: Boolean;
        SourceAccountNameEditable: Boolean;
        SourceAccountTypeEditable: Boolean;
        SourceTransactionType: Boolean;
        SourceLoanNoEditable: Boolean;
        RemarkEditable: Boolean;
        TransactionDateEditable: Boolean;
        Vend: Record Vendor;
        // Audit: Record "Audit Entries";
        EntryNos: Integer;

    local procedure AddRecordRestriction()
    begin
        if Rec.Status = Rec.Status::Open then begin
            SourceAccountNoEditbale := true;
            SourceAccountNameEditable := true;
            SourceAccountTypeEditable := true;
            SourceLoanNoEditable := true;
            SourceTransactionType := true;
            TransactionDateEditable := true;
            RemarkEditable := true
        end else
            if Rec.Status = Rec.Status::pending then begin
                SourceAccountNoEditbale := false;
                SourceAccountNameEditable := false;
                SourceAccountTypeEditable := false;
                SourceLoanNoEditable := false;
                SourceTransactionType := false;
                TransactionDateEditable := false;
                RemarkEditable := false
            end else
                if Rec.Status = Rec.Status::Approved then begin
                    SourceAccountNoEditbale := false;
                    SourceAccountNameEditable := false;
                    SourceAccountTypeEditable := false;
                    SourceLoanNoEditable := false;
                    SourceTransactionType := false;
                    TransactionDateEditable := false;
                    RemarkEditable := false;
                end;
    end;
}

