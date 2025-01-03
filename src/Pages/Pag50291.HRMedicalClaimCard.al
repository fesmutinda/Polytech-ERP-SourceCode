#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50291 "HR Medical Claim Card"
{
    PageType = Card;
    SourceTable = "HR Medical Claims";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Claim No"; Rec."Claim No")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        CurrPage.Update;
                    end;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Employee No.';
                }
                field("Claim Type"; Rec."Claim Type")
                {
                    ApplicationArea = Basic;
                }
                field("Claim Date"; Rec."Claim Date")
                {
                    ApplicationArea = Basic;
                }
                field("Patient Name"; Rec."Patient Name")
                {
                    ApplicationArea = Basic;
                }
                field("Document Ref"; Rec."Document Ref")
                {
                    ApplicationArea = Basic;
                    Caption = 'Document No.(From Hospital)';
                }
                field("Date of Service"; Rec."Date of Service")
                {
                    ApplicationArea = Basic;
                    Caption = 'Visit Date(Hospital)';
                }
                field("Attended By"; Rec."Attended By")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(Comments; Rec.Comments)
                {
                    ApplicationArea = Basic;
                }
                field(Dependants; Rec.Dependants)
                {
                    ApplicationArea = Basic;
                }
                field("Amount Charged"; Rec."Amount Charged")
                {
                    ApplicationArea = Basic;
                }
                field("Amount Claimed"; Rec."Amount Claimed")
                {
                    ApplicationArea = Basic;
                }
                field("Hospital/Medical Centre"; Rec."Hospital/Medical Centre")
                {
                    ApplicationArea = Basic;
                }
                field("Claim Limit"; Rec."Claim Limit")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Functions")
            {
                Caption = '&Functions';
                action(Post)
                {
                    ApplicationArea = Basic;
                    Caption = 'Post Claim';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin



                        Rec.TestField("Claim Date");
                        Rec.TestField("Amount Claimed");

                        if Confirm('Do you Wish to Post this transaction?', false) = false then begin exit end;


                        ClaimJNL.Init;
                        ClaimJNL."Document No." := Rec."Document Ref";
                        ClaimJNL."Claim No" := Rec."Claim No";
                        ClaimJNL."Employee No" := Rec."Member No";
                        ClaimJNL."Employee Name" := Rec."Patient Name";
                        ClaimJNL."Claim Date" := Rec."Claim Date";
                        ClaimJNL."Hospital Visit Date" := Rec."Date of Service";
                        ClaimJNL."Claim Limit" := Rec."Claim Limit";
                        ClaimJNL."Balance Claim Amount" := Rec.Balance;
                        ClaimJNL."Amount Charged" := Rec."Amount Charged";
                        ClaimJNL."Amount Claimed" := Rec."Amount Claimed";
                        ClaimJNL.Comments := Rec.Comments;
                        ClaimJNL."USER ID" := UserId;
                        ClaimJNL."Date Posted" := Today;
                        ClaimJNL."Time Posted" := Time;
                        ClaimJNL.Posted := true;
                        ClaimJNL.Insert;



                        Rec."Date Posted" := Today;
                        Rec."Time Posted" := Time;
                        Rec.Posted := true;
                        Rec."Posted By" := UserId;

                        Message('Transaction Posted Successfully');
                    end;
                }
                separator(Action1000000024)
                {
                }
                action(PrintNew)
                {
                    ApplicationArea = Basic;
                    Caption = 'Print/Preview';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        //TESTFIELD(Status,Status::Approved);
                        /*IF (Status=Status::Pending) OR  (Status=Status::"Pending Approval") THEN
                           ERROR('You cannot Print until the document is Approved'); */

                        PHeader2.Reset;
                        PHeader2.SetRange(PHeader2."Member No", Rec."Member No");
                        if PHeader2.FindFirst then
                            Report.Run(51516199, true, true, PHeader2);

                        /*RESET;
                        SETRANGE("No.","No.");
                        IF "No." = '' THEN
                          REPORT.RUNMODAL(51516000,TRUE,TRUE,Rec)
                        ELSE
                          REPORT.RUNMODAL(51516344,TRUE,TRUE,Rec);
                        RESET;
                        */

                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = Basic;
                    Caption = 'Approvals';
                    Image = Approval;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                    begin

                        if Confirm('Do you Wish to Cancel the approval request', false) = false then begin exit end;/*DocumentType:=DocumentType::ImprestRequisition;
                        ApprovalEntries.Setfilters(DATABASE::"Imprest Header",DocumentType,"No.");
                        ApprovalEntries.RUN;
                        */

                    end;
                }
                action("Send A&pproval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Send A&pproval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Text001: label 'This Batch is already pending approval';
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        if Confirm('Do you Wish to send this transaction for Approval', false) = false then begin exit end;


                        /*
                        IF ApprovalsMgmt.CheckImprestRequisitionApprovalsWorkflowEnabled(Rec) THEN
                          ApprovalsMgmt.OnSendImprestRequisitionForApproval(Rec);
                        */

                    end;
                }
                action("Canel Approval Request")
                {
                    ApplicationArea = Basic;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ApprovalMgt: Codeunit "Approvals Mgmt.";
                    begin
                        //IF ApprovalMgt.CancelBatchAppr(Rec,TRUE,TRUE) THEN;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //TO PREVENT USER FROM SEEING OTHER PEOPLES LEAVE APPLICATIONS
        Rec.SetFilter("User ID", UserId);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        //"Claim Type"='Outpatient';
    end;

    var
        PHeader2: Record 51278;
        HREmp: Record 51160;
        EmpName: Text;
        EmpDept: Text;
        ClaimJNL: Record 51294;

    local procedure FillVariables()
    begin
        //GET THE APPLICANT DETAILS

        HREmp.Reset;
        if HREmp.Get(Rec."Member No") then begin
            EmpName := HREmp.FullName;
            EmpDept := HREmp."Global Dimension 2 Code";
        end else begin
            EmpDept := '';
        end;
    end;
}

