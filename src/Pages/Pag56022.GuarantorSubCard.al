#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
Page 56022 "Guarantor Sub Card"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Guarantorship Substitution H";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic;
                }
                field("Loanee Member No"; Rec."Loanee Member No")
                {
                    ApplicationArea = Basic;
                    Editable = LoaneeNoEditable;
                }
                field("Loanee Name"; Rec."Loanee Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan Guaranteed"; Rec."Loan Guaranteed")
                {
                    ApplicationArea = Basic;
                    Editable = LoanGuaranteedEditable;
                }
                field("Substituting Member"; Rec."Substituting Member")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member to be substuted';
                    Editable = SubMemberEditable;
                }
                field("Substituting Member Name"; Rec."Substituting Member Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Substituted; Rec.Substituted)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Date Substituted"; Rec."Date Substituted")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Substituted By"; Rec."Substituted By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
            part(Control1000000014; "Guarantor Sub Subform")
            {
                SubPageLink = "Document No" = field("Document No"),
                              "Member No" = field("Substituting Member"),
                              "Loan No." = field("Loan Guaranteed");
            }
        }
    }

    actions
    {

        area(navigation)
        {
            group(Approvals)
            {
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = SendApproval;

                    trigger OnAction()
                    var
                        SrestepApprovalsCodeUnit: Codeunit SurestepApprovalsCodeUnit;
                        text001: label 'This batch is already pending approval';
                        GuarantorshipSubstitutionL: Record "Guarantorship Substitution L";
                    begin
                        if Rec.Status <> Rec.Status::Open then
                            Error('Status must be open.');

                        Rec.TestField("Loanee Member No");
                        Rec.TestField("Loan Guaranteed");

                        GuarantorshipSubstitutionL.Reset;
                        GuarantorshipSubstitutionL.SetRange("Document No", Rec."Document No");
                        GuarantorshipSubstitutionL.FindFirst;


                        LGuarantor.Reset;
                        LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                        LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                        if LGuarantor.FindSet then begin
                            //Add All Replaced Amounts
                            TotalReplaced := 0;
                            GSubLine.Reset;
                            GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                            GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                            if GSubLine.FindSet then begin
                                repeat
                                    TotalReplaced := TotalReplaced + GSubLine."Sub Amount Guaranteed";
                                until GSubLine.Next = 0;
                            end;
                            //End Add All Replaced Amounts
                            Commited := LGuarantor."Amont Guaranteed";
                            if TotalReplaced < Commited then
                                Error('Guarantors replaced do not cover the whole amount');
                        end;

                        //Approval code  here
                        if Confirm('Send Approval Request?', false) = true then begin
                            SrestepApprovalsCodeUnit.SendGuarantorSubRequestForApproval(rec."Document No", Rec);
                            Message('Approval Request Successfully sent!');
                            CurrPage.Close();
                        end;
                        //...................
                    end;
                }

                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cancel Approval Request';
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = CancelApproval;

                    trigger OnAction()
                    var
                        text001: label 'This batch is already pending approval';
                        SrestepApprovalsCodeUnit: Codeunit SwizzsoftApprovalsCodeUnit;
                    begin
                        if Rec.Status <> Rec.Status::Pending then
                            Error(text001);
                        //Approval here
                        if Confirm('Cancel Approval Request?', false) = true then begin
                            SrestepApprovalsCodeUnit.CancelGuarantorSubRequestForApproval(Rec."Document No", Rec);
                        end;
                    end;
                }


                action("Process Substitution Old")
                {
                    ApplicationArea = Basic;
                    Image = Apply;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = AllowPosting;
                    Visible = false;
                    trigger OnAction()
                    begin

                        Rec.TestField(Status, Rec.Status::Approved);
                        if Rec."Created By" <> UserId then begin
                            Error('Restricted! you can only process a record you created!');
                        end;
                        LGuarantor.Reset;
                        LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                        LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                        if LGuarantor.FindSet then begin
                            //Add All Replaced Amounts
                            if LGuarantor.Substituted = true then begin
                                Error('The Guarantor has already been Substituted');
                            end;

                            TotalReplaced := 0;
                            GSubLine.Reset;
                            GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                            GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                            if GSubLine.FindSet then begin
                                repeat
                                    TotalReplaced := TotalReplaced + GSubLine."Sub Amount Guaranteed";
                                until GSubLine.Next = 0;
                            end;
                            //End Add All Replaced Amounts

                            //Compare with committed shares
                            Commited := LGuarantor."Amont Guaranteed";
                            if TotalReplaced < Commited then
                                Message('Guarantors replaced do not cover the whole amount');
                            //End Compare with committed Shares

                            //Create Lines
                            GSubLine.Reset;
                            GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                            GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                            if GSubLine.FindSet then begin
                                repeat
                                    NewLGuar.Init;
                                    NewLGuar."Loan No" := Rec."Loan Guaranteed";
                                    NewLGuar."Member No" := GSubLine."Substitute Member";
                                    NewLGuar.Validate(NewLGuar."Member No");
                                    NewLGuar.Name := GSubLine."Substitute Member Name";
                                    NewLGuar."Amont Guaranteed" := CalculateAmountGuaranteed(GSubLine."Sub Amount Guaranteed", TotalReplaced, GSubLine."Amount Guaranteed");
                                    NewLGuar."Substituted Guarantor" := GSubLine."Member No";
                                    NewLGuar.Shares := GSubLine."Substitute Member Deposits";

                                    NewLGuar.Insert();
                                until GSubLine.Next = 0;
                            end;
                            //End Create Lines

                            LGuarantor.Substituted := true;
                            if LGuarantor.Modify() = true then
                                Message('LGuarantor substituted %1', LGuarantor."Member No");

                            Rec.Substituted := true;
                            Rec."Date Substituted" := Today;
                            Rec."Substituted By" := UserId;
                            Rec.Status := Rec.Status::Closed;
                            if Rec.Modify() = true then begin
                                Message('Guarantor Substituted Succesfully');
                            end;


                        end;
                    end;
                }
                action("Process Substitution")
                {
                    ApplicationArea = Basic;
                    Image = Apply;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = AllowPosting;

                    trigger OnAction()
                    begin
                        Rec.TestField(Status, Rec.Status::Approved);
                        if Rec."Created By" <> UserId then begin
                            Error('Restricted! you can only process a record you created!');
                        end;
                        LGuarantor.Reset;
                        LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                        LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                        if LGuarantor.FindSet then begin
                            //Add All Replaced Amounts
                            TotalReplaced := 0;
                            GSubLine.Reset;
                            GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                            GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                            if GSubLine.FindSet then begin
                                repeat
                                    TotalReplaced := TotalReplaced + GSubLine."Sub Amount Guaranteed";
                                until GSubLine.Next = 0;
                            end;
                            //End Add All Replaced Amounts

                            //Compare with committed shares
                            Commited := LGuarantor."Committed Shares";
                            if TotalReplaced < Commited then
                                Error('Guarantors replaced do not cover the whole amount');
                            //End Compare with committed Shares

                            //Create Lines
                            GSubLine.Reset;
                            GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                            GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                            if GSubLine.FindSet then begin
                                repeat
                                    NewLGuar.Init;
                                    NewLGuar."Loan No" := Rec."Loan Guaranteed";
                                    NewLGuar."Guar Sub Doc No." := Rec."Document No";
                                    NewLGuar."Member No" := GSubLine."Substitute Member";
                                    NewLGuar.Validate(NewLGuar."Member No");
                                    NewLGuar.Name := GSubLine."Substitute Member Name";
                                    NewLGuar."Committed Shares" := GSubLine."Sub Amount Guaranteed";
                                    NewLGuar."Amont Guaranteed" := CalculateAmountGuaranteed(GSubLine."Sub Amount Guaranteed", TotalReplaced, GSubLine."Amount Guaranteed");
                                    NewLGuar.Insert;

                                    //Audit Entries
                                    if (UserId <> 'MOBILE') and (UserId <> 'ATM') and (UserId <> 'AGENCY') then begin
                                        EntryNos := 0;
                                        if Audit.FindLast then
                                            EntryNos := 1 + Audit."Entry No";
                                        Audit.Init;
                                        Audit."Entry No" := EntryNos;
                                        Audit."Transaction Type" := 'Guarantor Substitution';
                                        Audit."Loan Number" := Rec."Loan Guaranteed";
                                        Audit."Document Number" := Rec."Document No";
                                        Audit."Account Number" := GSubLine."Substitute Member";
                                        Audit.UsersId := UserId;
                                        Audit.Amount := GSubLine."Sub Amount Guaranteed";
                                        Audit.Date := Today;
                                        Audit.Time := Time;
                                        Audit.Source := 'GUARANTOR SUBSTITUTION';
                                        Audit.Insert;
                                        Commit();
                                    end;
                                //End Audit Entries
                                until GSubLine.Next = 0;
                            end;
                            //End Create Lines

                            //Edit Loan Guar
                            LGuarantor.Substituted := true;
                            LGuarantor."Amont Guaranteed" := 0;
                            LGuarantor."Committed Shares" := 0;
                            LGuarantor."Guar Sub Doc No." := Rec."Document No";
                            LGuarantor.Modify(true);
                            //End Edit Loan Guar

                            Rec.Substituted := true;
                            Rec."Date Substituted" := Today;
                            Rec."Substituted By" := UserId;
                            Rec.Modify(true);

                            Message('Guarantor Substituted Succesfully');
                        end;
                    end;
                }
            }

        }
    }


    trigger OnAfterGetCurrRecord()
    begin
        FNAddRecordRestriction();
        Controls();
    end;

    trigger OnAfterGetRecord()
    begin
        FNAddRecordRestriction();
        Controls();
    end;

    trigger OnOpenPage()
    begin
        Rec."Application Date" := Today;
        Controls();
    end;

    var
        LGuarantor: Record "Loans Guarantee Details";
        GSubLine: Record "Guarantorship Substitution L";
        LoaneeNoEditable: Boolean;
        LoanGuaranteedEditable: Boolean;
        SubMemberEditable: Boolean;
        TotalReplaced: Decimal;
        Commited: Decimal;
        SendApproval: Boolean;
        AllowPosting: Boolean;
        CancelApproval: Boolean;
        NewLGuar: Record "Loans Guarantee Details";
        Audit: Record "Audit Entries";
        EntryNos: Integer;

    local procedure FNAddRecordRestriction()
    begin
        if Rec.Status = Rec.Status::Open then begin
            LoaneeNoEditable := true;
            LoanGuaranteedEditable := true;
            SubMemberEditable := true

        end else
            if Rec.Status = Rec.Status::Pending then begin
                LoaneeNoEditable := false;
                LoanGuaranteedEditable := false;
                SubMemberEditable := false
            end else
                if Rec.Status = Rec.Status::Approved then begin
                    LoaneeNoEditable := false;
                    LoanGuaranteedEditable := false;
                    SubMemberEditable := false;
                end;
    end;

    local procedure CalculateAmountGuaranteed(AmountReplaced: Decimal; TotalAmount: Decimal; AmountGuaranteed: Decimal) AmtGuar: Decimal
    begin
        AmtGuar := ((AmountReplaced / TotalAmount) * AmountGuaranteed);

        exit(AmtGuar);
    end;

    local procedure Controls()
    begin
        if Rec.Status = Rec.Status::Open THEN begin
            AllowPosting := false;
            CancelApproval := false;
            SendApproval := true;
        end ELSE
            if Rec.Status = Rec.Status::Pending THEN begin
                AllowPosting := false;
                CancelApproval := true;
                SendApproval := false;
            end ELSE
                if Rec.Status = Rec.Status::Approved THEN begin
                    AllowPosting := true;
                    CancelApproval := false;
                    SendApproval := false;
                end
                ELSE
                    if Rec.Status = Rec.Status::Closed THEN begin
                        AllowPosting := false;
                        CancelApproval := false;
                        SendApproval := false;
                    end;
    end;
}

