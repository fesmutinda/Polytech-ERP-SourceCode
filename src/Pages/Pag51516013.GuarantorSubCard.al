#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516013 "Guarantor Sub Card"
{
    PageType = Card;
    SourceTable = 51516563;

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
                    Editable = false;
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
        area(creation)
        {
            action(Approvals)
            {
                ApplicationArea = Basic;
                Caption = 'Approvals';
                Image = Approvals;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    ApprovalEntries: Page "Approval Entries";
                begin
                    // DocumentType:=DocumentType::GuarantorSubstitution;
                    //
                    // ApprovalEntries.Setfilters(DATABASE::"Guarantorship Substitution H",DocumentType,"Document No");
                    // ApprovalEntries.RUN;
                    ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                end;
            }
            action("Send Approval Request")
            {
                ApplicationArea = Basic;
                Caption = 'Send A&pproval Request';
                Image = SendApprovalRequest;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    text001: label 'This batch is already pending approval';
                    ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                begin
                    if Rec.Status <> Rec.Status::Open then
                        Error('Status must be open.');

                    if ApprovalsMgmt.CheckGuarSubApprovalWorkflowEnabled(Rec) then
                        ApprovalsMgmt.OnSendGuarSubForApproval(Rec);

                    //Status:=Status::Approved;
                    //MODIFY;
                    //MESSAGE('Successful!!');
                end;
            }
            action("Cancel Approval Request")
            {
                ApplicationArea = Basic;
                Caption = 'Cancel A&pproval Request';
                Image = Cancel;
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    text001: label 'This batch is already pending approval';
                    ApprovalMgt: Codeunit "Approvals Mgmt.";
                begin
                    if Rec.Status <> Rec.Status::Pending then
                        Error(text001);

                    if ApprovalsMgmt.CheckGuarSubApprovalWorkflowEnabled(Rec) then
                        ApprovalsMgmt.OnCancelGuarSubApprovalRequest(Rec);
                end;
            }
            action("Process Substitution")
            {
                ApplicationArea = Basic;
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.Status <> Rec.Status::Approved then
                        Error('This Application has to be Approved');

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
                        Commited := LGuarantor."Amont Guaranteed";
                        if TotalReplaced < Commited then
                            //ERROR('Guarantors replaced do not cover the whole amount');
                            //End Compare with committed Shares

                            //Create Lines
                            ///....self sub

                            SubGAmount := 0;
                        GSubLine.Reset;
                        GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                        GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                        if GSubLine.FindSet then begin

                            NewLGuar.Reset;
                            NewLGuar.SetRange(NewLGuar."Member No", Rec."Substituting Member");
                            NewLGuar.SetRange(NewLGuar."Loan No", Rec."Loan Guaranteed");
                            if NewLGuar.Find('-') then
                                SubGAmount := NewLGuar."Amont Guaranteed" + GSubLine."Sub Amount Guaranteed";
                            Message('new amount is %1', SubGAmount);
                            //MESSAGE('here');
                            NewLGuar."Amont Guaranteed" := SubGAmount;

                            //SubGAmount:=NewLGuar."Amont Guaranteed";
                            //NewLGuar.MODIFY;
                            //MESSAGE(FORMAT(NewLGuar."Amont Guaranteed"));
                            //GSubLine."self  substitute":=TRUE;
                            //GSubLine.MODIFY;
                        end;


                        // //
                        // //  //Edit Loan Guar
                        // //    LGuarantor.Substituted:=TRUE;
                        // //    LGuarantor."Committed Shares" := 0;
                        // //    LGuarantor."Guar Sub Doc No.":="Document No";
                        // //    LGuarantor.MODIFY;
                        // //    //End Edit Loan Guar
                        // //
                        // //  Substituted:=TRUE;
                        // //  "Date Substituted":=TODAY;
                        // //  "Substituted By":=USERID;
                        // //  MODIFY;
                        // // END;
                        //.....
                        /*
                        NewLGuar.RESET;
                        NewLGuar.SETRANGE(NewLGuar."Member No",GSubLine."Substitute Member");
                        NewLGuar.SETRANGE(NewLGuar."Loan No",GSubLine."Loan No.");
                        IF NewLGuar.FIND('-') THEN BEGIN
                         SubGAmount:=NewLGuar."Amont Guaranteed"+GSubLine."Sub Amount Guaranteed";

                         NewLGuar."Amont Guaranteed":=SubGAmount;
                         NewLGuar.MODIFY;
                         MESSAGE(FORMAT(NewLGuar."Amont Guaranteed"));
                        //GSubLine."self  substitute":=TRUE;
                        //GSubLine.MODIFY;
                          END;
                          */


                        GSubLine.Reset;
                        GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                        GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                        if GSubLine.FindSet then begin
                            if GSubLine."self  substitute" = false then
                                repeat
                                    NewLGuar.Init;
                                    NewLGuar."Loan No" := Rec."Loan Guaranteed";
                                    NewLGuar."Guar Sub Doc No." := Rec."Document No";
                                    NewLGuar."Member No" := GSubLine."Substitute Member";
                                    NewLGuar.Validate(NewLGuar."Member No");
                                    NewLGuar.Name := GSubLine."Substitute Member Name";
                                    NewLGuar."Committed Shares" := GSubLine."Sub Amount Guaranteed";
                                    //NewLGuar."Amont Guaranteed":=CalculateAmountGuaranteed(GSubLine."Sub Amount Guaranteed",TotalReplaced,GSubLine."Amount Guaranteed");
                                    NewLGuar."Amont Guaranteed" := GSubLine."Sub Amount Guaranteed";
                                    NewLGuar."Substituted Guarantor" := GSubLine."Member No";
                                    NewLGuar.Insert;
                                until GSubLine.Next = 0;
                        end;
                        //End Create Lines
                        //MESSAGE('here');
                        //Edit Loan Guar

                        /* LGuarantor.Substituted:=TRUE;
                         LGuarantor."Committed Shares" := 0;
                         LGuarantor."Guar Sub Doc No.":="Document No";
                         CurrPage.UPDATE(FALSE);
                         LGuarantor.MODIFY;*/
                        //End Edit Loan Guar

                        Rec.Substituted := true;
                        Rec."Date Substituted" := Today;
                        Rec."Substituted By" := UserId;
                        Rec.Modify;

                        Message('Guarantor Substituted Succesfully');
                    end;
                    LGuarantor.Reset;
                    LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                    LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                    if LGuarantor.FindSet then begin
                        LGuarantor.Substituted := true;
                        LGuarantor."Committed Shares" := 0;
                        LGuarantor."Guar Sub Doc No." := Rec."Document No";
                        //CurrPage.UPDATE(FALSE);
                        LGuarantor.Modify;
                    end;

                end;
            }
            action("Process self_Substitution")
            {
                ApplicationArea = Basic;
                Image = PostApplication;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Rec.Status <> Rec.Status::Approved then
                        Error('This Application has to be Approved');

                    LGuarantor.Reset;
                    LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                    LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                    if LGuarantor.FindSet then begin
                        Message(Format(LGuarantor."Loan No"));
                        TotalReplaced := 0;
                        GSubLine.Reset;
                        GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                        GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                        if GSubLine.FindSet then begin
                            repeat
                                TotalReplaced := TotalReplaced + GSubLine."Sub Amount Guaranteed";
                            until GSubLine.Next = 0;
                        end;
                        ////End Add All Replaced Amounts
                        Message('total amount is %', TotalReplaced);
                        //Compare with committed shares
                        Commited := LGuarantor."Amont Guaranteed";
                        if TotalReplaced < Commited then
                            //ERROR('Guarantors replaced do not cover the whole amount');
                            //End Compare with committed Shares

                            //Create Lines
                            ///....self sub

                            SubGAmount := 0;
                        GSubLine.Reset;
                        GSubLine.SetRange(GSubLine."Document No", Rec."Document No");
                        GSubLine.SetRange(GSubLine."Member No", Rec."Substituting Member");
                        if GSubLine.FindSet then begin

                            NewLGuar.Reset;
                            NewLGuar.SetRange(NewLGuar."Member No", Rec."Substituting Member");
                            NewLGuar.SetRange(NewLGuar."Loan No", Rec."Loan Guaranteed");
                            if NewLGuar.Find('-') then
                                SubGAmount := NewLGuar."Amont Guaranteed" + GSubLine."Sub Amount Guaranteed";
                            Message('new amount is %1', SubGAmount);
                            //MESSAGE('here');
                            NewLGuar."Amont Guaranteed" := SubGAmount;

                            //SubGAmount:=NewLGuar."Amont Guaranteed";
                            //NewLGuar.MODIFY;
                            //MESSAGE(FORMAT(NewLGuar."Amont Guaranteed"));
                            //GSubLine."self  substitute":=TRUE;
                            //GSubLine.MODIFY;
                        end;


                        // //
                        // //  //Edit Loan Guar
                        LGuarantor.Substituted := true;
                        LGuarantor."Committed Shares" := 0;
                        LGuarantor."Guar Sub Doc No." := Rec."Document No";
                        LGuarantor.Modify;
                        //End Edit Loan Guar

                        Rec.Substituted := true;
                        Rec."Date Substituted" := Today;
                        Rec."Substituted By" := UserId;
                        Rec.Modify;
                    end;
                    //.....

                    NewLGuar.Reset;
                    NewLGuar.SetRange(NewLGuar."Member No", GSubLine."Substitute Member");
                    NewLGuar.SetRange(NewLGuar."Loan No", GSubLine."Loan No.");
                    if NewLGuar.Find('-') then begin
                        SubGAmount := NewLGuar."Amont Guaranteed" + GSubLine."Sub Amount Guaranteed";

                        NewLGuar."Amont Guaranteed" := SubGAmount;
                        NewLGuar.Modify;
                        Message(Format(NewLGuar."Amont Guaranteed"));
                        GSubLine."self  substitute" := true;
                        GSubLine.Modify;
                        // END;



                        // // //  GSubLine.RESET;
                        // // //  GSubLine.SETRANGE(GSubLine."Document No","Document No");
                        // // //  GSubLine.SETRANGE(GSubLine."Member No","Substituting Member");
                        // // //  IF GSubLine.FINDSET THEN BEGIN
                        // // //    IF GSubLine."self  substitute"= FALSE THEN
                        // // //
                        // // //    REPEAT
                        // // //      NewLGuar.INIT;
                        // // //      NewLGuar."Loan No":="Loan Guaranteed";
                        // // //      NewLGuar."Guar Sub Doc No.":="Document No";
                        // // //      NewLGuar."Member No":=GSubLine."Substitute Member";
                        // // //      NewLGuar.VALIDATE(NewLGuar."Member No");
                        // // //      NewLGuar.Name:=GSubLine."Substitute Member Name";
                        // // //      NewLGuar."Committed Shares":=GSubLine."Sub Amount Guaranteed";
                        // // //      //NewLGuar."Amont Guaranteed":=CalculateAmountGuaranteed(GSubLine."Sub Amount Guaranteed",TotalReplaced,GSubLine."Amount Guaranteed");
                        // // //      NewLGuar."Amont Guaranteed":=GSubLine."Sub Amount Guaranteed";
                        // // //      NewLGuar."Substituted Guarantor":=GSubLine."Member No";
                        // // //      NewLGuar.INSERT;
                        // // //      UNTIL GSubLine.NEXT=0;
                        // // //    END;
                        // // //  //End Create Lines
                        //MESSAGE('here');
                        //Edit Loan Guar

                        /* LGuarantor.Substituted:=TRUE;
                         LGuarantor."Committed Shares" := 0;
                         LGuarantor."Guar Sub Doc No.":="Document No";
                         CurrPage.UPDATE(FALSE);
                         LGuarantor.MODIFY;*/
                        //End Edit Loan Guar

                        Rec.Substituted := true;
                        Rec."Date Substituted" := Today;
                        Rec."Substituted By" := UserId;
                        Rec.Modify;

                        Message('Guarantor Substituted Succesfully');
                    end;
                    LGuarantor.Reset;
                    LGuarantor.SetRange(LGuarantor."Loan No", Rec."Loan Guaranteed");
                    LGuarantor.SetRange(LGuarantor."Member No", Rec."Substituting Member");
                    if LGuarantor.FindSet then begin
                        LGuarantor.Substituted := true;
                        LGuarantor."Committed Shares" := 0;
                        LGuarantor."Guar Sub Doc No." := Rec."Document No";
                        //CurrPage.UPDATE(FALSE);
                        LGuarantor.Modify;
                    end;

                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FNAddRecordRestriction();
    end;

    trigger OnAfterGetRecord()
    begin
        FNAddRecordRestriction();
    end;

    var
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal,ATMCard,GuarantorRecovery,ChangeRequest,TreasuryTransactions,FundsTransfer,SaccoTransfers,ChequeDiscounting,ImprestRequisition,ImprestSurrender,LeaveApplication,GuarantorSubstitution;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        LGuarantor: Record 51516372;
        GSubLine: Record 51516564;
        LoaneeNoEditable: Boolean;
        LoanGuaranteedEditable: Boolean;
        SubMemberEditable: Boolean;
        TotalReplaced: Decimal;
        Commited: Decimal;
        NewLGuar: Record 51516372;
        SubGAmount: Decimal;

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
}

