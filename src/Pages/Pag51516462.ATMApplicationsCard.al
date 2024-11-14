#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516462 "ATM Applications Card"
{
    PageType = Card;
    SourceTable = "Members Nominee Temp";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                    Editable = AccountNoEditable;
                }
                field(Beneficiary; Rec.Beneficiary)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Account Category"; Rec."Account Category")
                {
                    ApplicationArea = Basic;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic;
                }
                field("New Upload(New)"; Rec."New Upload(New)")
                {
                    ApplicationArea = Basic;
                }
                field("ID No"; Rec."ID No")
                {
                    ApplicationArea = Basic;
                }
                field("NOK Residence"; Rec."NOK Residence")
                {
                    ApplicationArea = Basic;
                    Editable = CardNoEditable;

                    trigger OnValidate()
                    begin


                        if StrLen(Rec."NOK Residence") <> 16 then
                            Error('ATM No. cannot contain More or less than 16 Characters.');
                    end;
                }
                field("Total Allocation"; Rec."Total Allocation")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Maximun Allocation %"; Rec."Maximun Allocation %")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Existing; Rec.Existing)
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field(Guardian; Rec.Guardian)
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            group("Other Details")
            {
                Caption = 'Other Details';
                field("Order ATM Card"; Rec."Order ATM Card")
                {
                    ApplicationArea = Basic;
                    Caption = 'Order';
                    Editable = false;
                }
                field("Ordered By"; Rec."Ordered By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Ordered On"; Rec."Ordered On")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Card Received"; Rec."Card Received")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = Basic;
                    Caption = 'Received';
                    Editable = false;
                }
                field("Received On"; Rec."Received On")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("NOK Residence(New)"; Rec."NOK Residence(New)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Guardian(New)"; Rec."Guardian(New)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Next Of Kin Type(New)"; Rec."Next Of Kin Type(New)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Issued to"; Rec."Issued to")
                {
                    ApplicationArea = Basic;
                    Editable = IssuedtoEditable;
                }
                field(Remove; Rec.Remove)
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Date Created"; Rec."Date Created")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Next Of Kin Type"; Rec."Next Of Kin Type")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Relationship(New)"; Rec."Relationship(New)")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Beneficiary(New)"; Rec."Beneficiary(New)")
                {
                    ApplicationArea = Basic;
                }
                field("Date of Birth(New)"; Rec."Date of Birth(New)")
                {
                    ApplicationArea = Basic;
                }
                field("Add New"; Rec."Add New")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Fee Charged"; Rec."ATM Card Fee Charged")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Fee Charged On"; Rec."ATM Card Fee Charged On")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Fee Charged By"; Rec."ATM Card Fee Charged By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Linked"; Rec."ATM Card Linked")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Linked By"; Rec."ATM Card Linked By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ATM Card Linked On"; Rec."ATM Card Linked On")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Pesa Point ATM Card")
            {
                Caption = 'Pesa Point ATM Card';
                action("Link ATM Card")
                {
                    ApplicationArea = Basic;
                    Caption = 'Link ATM Card';
                    Image = Link;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if Rec.Status <> Rec.Status::"2" then
                            Error('This ATM Card application has not been approved');

                        if Rec."ATM Card Fee Charged" = false then
                            Error('ATM Card Fee has not been Charged on this Application');

                        //Linking Details*******************************************************************************
                        if Confirm('Are you sure you want to link this ATM Card to the Account', false) = true then begin
                            if ObjAccount.Get(Rec.Name) then begin

                                ObjATMCardsBuffer.Init;
                                ObjATMCardsBuffer."Account No" := Rec.Name;
                                ObjATMCardsBuffer."Account Name" := Rec."Date of Birth";
                                ObjATMCardsBuffer."Account Type" := Rec."Address(New)";
                                ObjATMCardsBuffer."ATM Card No" := Rec."NOK Residence";
                                ObjATMCardsBuffer."ID No" := Rec."ID No";
                                ObjATMCardsBuffer.Status := ObjATMCardsBuffer.Status::Active;
                                ObjATMCardsBuffer.Insert;
                                //ObjAccount."ATM No.":="Card No";
                                //ObjAccount.MODIFY;
                            end;
                            Rec."ATM Card Linked" := true;
                            Rec."ATM Card Linked By" := UserId;
                            Rec."ATM Card Linked On" := Today;
                            Modify;
                        end;
                        Message('ATM Card linked to Succesfuly to Account No %1', Rec.Name);
                        //End Linking Details****************************************************************************

                        //Collection Details***********************************
                        Rec."NOK Residence(New)" := true;
                        Rec."Guardian(New)" := Today;
                        Rec."Next Of Kin Type(New)" := UserId;
                        Rec."Date Created" := "date created"::"1";
                        Rec.Modify;
                        //End Collection Details******************************



                        Vend.Get(Rec.Name);
                        Vend."ATM No." := Rec."NOK Residence";
                        Vend."Atm card ready" := true;
                        Vend.Modify;

                        GeneralSetup.Get();
                        Existing := CalcDate(GeneralSetup."ATM Expiry Duration", Today);
                    end;
                }
                action("Disable ATM Card")
                {
                    ApplicationArea = Basic;
                    Caption = 'Disable ATM Card';
                    Image = DisableAllBreakpoints;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if Rec.Status <> Rec.Status::"2" then
                            Error('This ATM Card application has not been approved');


                        if Rec."Date Created" <> Rec."date created"::"1" then
                            Error('Card is not active');


                        Vend.Get(Rec.Name);
                        if Confirm('Are you sure you want to disable this account from ATM transactions  ?', false) = true then
                            Vend."ATM No." := '';
                        //Vend.Blocked:=Vend.Blocked::Payment;
                        //Vend."Account Frozen":=TRUE;
                        Vend.Modify;
                    end;
                }
                action("Enable ATM Card")
                {
                    ApplicationArea = Basic;
                    Image = EnableAllBreakpoints;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if Rec.Status <> Rec.Status::"2" then
                            Error('This ATM Card application has not been approved');


                        Vend.Get(Rec.Name);
                        if Confirm('Are you sure you want to Enable ATM no. for this account  ?', true) = true then
                            Vend."ATM No." := Rec."NOK Residence";
                        //Vend.Blocked:=Vend.Blocked::Payment;
                        //Vend."Account Frozen":=TRUE;
                        Vend.Modify;

                        Rec."Date Created" := Rec."date created"::"1";
                        Rec.Modify;
                    end;
                }
                action("Charge ATM Card Fee")
                {
                    ApplicationArea = Basic;
                    Image = PostDocument;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        if Rec.Status <> Rec.Status::"2" then
                            Error('This ATM Card application has not been approved');

                        if Rec."NOK Residence(New)" = true then
                            Error('The ATM Card has already been collected');

                        if Confirm('Are you sure you want to charge this ATM Card Application?', true) = true then begin

                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
                            GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
                            GenJournalLine.DeleteAll;

                            //Customer Deduction***************************************************
                            GeneralSetup.Get;

                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'PURCHASES';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := 'ATMFEE';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
                            GenJournalLine."Account No." := Rec.Name;
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Today;
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Description := 'ATM Card Fee-Replacement_' + Format(Name)
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Description := 'ATM Card Fee-New_' + Format(Name)
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Description := 'ATM Card Fee-Renewal_' + Format(Name);

                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Amount := GeneralSetup."ATM Card Fee-Replacement"
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Amount := GeneralSetup."ATM Card Fee New"
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Amount := GeneralSetup."ATM Card Fee-Replacement";
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                            GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //Bank Charge**********************************************************
                            GeneralSetup.Get;

                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'PURCHASES';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := 'ATMFEE';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
                            GenJournalLine."Account No." := GeneralSetup."ATM Card Fee Co-op Bank";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Today;
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Description := 'ATM Card Fee-Replacement_' + Format(Name)
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Description := 'ATM Card Fee-New_' + Format(Name)
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Description := 'ATM Card Fee-Renewal_' + Format(Name);

                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Amount := GeneralSetup."ATM Card Fee-Replacement" * -1
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Amount := GeneralSetup."ATM Card Fee-New Coop" * -1
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Amount := GeneralSetup."ATM Card Renewal Fee Bank" * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                            GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //SACCO Charge*************************************************
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'PURCHASES';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := 'ATMFEE';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := GeneralSetup."ATM Card Fee-Account";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Today;
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Description := 'ATM Card Fee-Replacement_' + Format(Name)
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Description := 'ATM Card Fee-New_' + Format(Name)
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Description := 'ATM Card Fee-Renewal_' + Format(Name);

                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Amount := GeneralSetup."ATM Card Renewal Fee Sacco" * -1
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Amount := GeneralSetup."ATM Card Fee-New Sacco" * -1
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Amount := GeneralSetup."ATM Card Renewal Fee Sacco" * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                            GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //Excise Duty on SACCO Comission**************************
                            LineNo := LineNo + 10000;
                            GenJournalLine.Init;
                            GenJournalLine."Journal Template Name" := 'PURCHASES';
                            GenJournalLine."Journal Batch Name" := 'FTRANS';
                            GenJournalLine."Document No." := 'ATMFEE';
                            GenJournalLine."Line No." := LineNo;
                            GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
                            GenJournalLine."Account No." := GeneralSetup."Excise Duty Account";
                            GenJournalLine.Validate(GenJournalLine."Account No.");
                            GenJournalLine."Posting Date" := Today;
                            GenJournalLine.Description := 'Excise Duty on ATM Card Fee_' + Format(Name);
                            GenJournalLine.Validate(GenJournalLine."Currency Code");
                            if Rec."Total Allocation" = Rec."total allocation"::"1" then
                                GenJournalLine.Amount := (GeneralSetup."ATM Card Renewal Fee Sacco" * GeneralSetup."Excise Duty(%)" / 100) * -1
                            else
                                if Rec."Total Allocation" = Rec."total allocation"::"0" then
                                    GenJournalLine.Amount := (GeneralSetup."ATM Card Fee-New Sacco" * GeneralSetup."Excise Duty(%)" / 100) * -1
                                else
                                    if Rec."Total Allocation" = Rec."total allocation"::"2" then
                                        GenJournalLine.Amount := (GeneralSetup."ATM Card Renewal Fee Sacco" * GeneralSetup."Excise Duty(%)" / 100) * -1;
                            GenJournalLine.Validate(GenJournalLine.Amount);
                            GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
                            GenJournalLine."Shortcut Dimension 2 Code" := FnGetUserBranch();
                            if GenJournalLine.Amount <> 0 then
                                GenJournalLine.Insert;

                            //Post New
                            GenJournalLine.Reset;
                            GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
                            GenJournalLine.SetRange("Journal Batch Name", 'Ftrans');
                            if GenJournalLine.Find('-') then begin

                                Codeunit.Run(Codeunit::"Gen. Jnl.-Post", GenJournalLine);

                                //window.OPEN('Posting:,#1######################');
                            end;
                        end;

                        Rec."ATM Card Fee Charged" := true;
                        Rec."ATM Card Fee Charged By" := UserId;
                        Rec."ATM Card Fee Charged On" := Today;
                        Message('ATM Card Charge Posted Succesfully');
                    end;
                }
            }
            group(Approvals)
            {
                action(Approval)
                {
                    ApplicationArea = Basic;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                    begin
                        DocumentType := Documenttype::ATMCard;
                        ApprovalEntries.Setfilters(Database::"Members Nominee Temp", DocumentType, "No.");
                        ApprovalEntries.Run;
                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Text001: label 'This request is already pending approval';
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if ApprovalsMgmt.CheckATMCardApprovalsWorkflowEnabled(Rec) then
                            ApprovalsMgmt.OnSendATMCardForApproval(Rec);
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cancel Approval Request';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Approvalmgt: Codeunit "Approvals Mgmt.";
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin

                        if ApprovalsMgmt.CheckATMCardApprovalsWorkflowEnabled(Rec) then
                            ApprovalsMgmt.OnCancelATMCardApprovalRequest(Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FnAddRecRestriction();
    end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        DefaultBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
        AccountHolders: Record Vendor;
        window: Dialog;
        PostingCode: Codeunit "Gen. Jnl.-Post Line";
        CalendarMgmt: Codeunit "Calendar Management";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        CustomizedCalEntry: Record "Office/Group";
        PictureExists: Boolean;
        AccountTypes: Record "Account Types-Saving Products";
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        StatusPermissions: Record "Status Change Permision";
        Charges: Record Charges;
        ForfeitInterest: Boolean;
        InterestBuffer: Record "Interest Buffer";
        FDType: Record "Fixed Deposit Type";
        Vend: Record Vendor;
        Cust: Record Customer;
        UsersID: Record User;
        Bal: Decimal;
        AtmTrans: Decimal;
        UnCheques: Decimal;
        AvBal: Decimal;
        Minbal: Decimal;
        GeneralSetup: Record "Sacco General Set-Up";
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal,ATMCard,GuarantorRecovery,ChangeRequest;
        AccountNoEditable: Boolean;
        CardNoEditable: Boolean;
        CardTypeEditable: Boolean;
        RequestTypeEditable: Boolean;
        ReplacementCardNoEditable: Boolean;
        IssuedtoEditable: Boolean;
        ObjAccount: Record Vendor;
        ObjATMCardsBuffer: Record "ATM Card Nos Buffer";

    local procedure FnGetUserBranch() branchCode: Code[50]
    var
        UserSetup: Record User;
    begin
        UserSetup.Reset;
        UserSetup.SetRange(UserSetup."User Name", UserId);
        if UserSetup.Find('-') then begin
            branchCode := UserSetup."Branch Code";
        end;
        exit(branchCode);
    end;

    local procedure FnAddRecRestriction()
    begin
        if Rec.Status = Rec.Status::"0" then begin
            AccountNoEditable := true;
            CardNoEditable := false;
            CardTypeEditable := true;
            ReplacementCardNoEditable := false;
            IssuedtoEditable := false;
        end else
            if Rec.Status = Rec.Status::"1" then begin
                AccountNoEditable := false;
                CardNoEditable := false;
                CardTypeEditable := false;
                ReplacementCardNoEditable := false;
                IssuedtoEditable := false
            end else
                if Rec.Status = Rec.Status::"2" then begin
                    AccountNoEditable := false;
                    CardNoEditable := true;
                    CardTypeEditable := false;
                    ReplacementCardNoEditable := true;
                    IssuedtoEditable := true;
                end;
    end;
}

