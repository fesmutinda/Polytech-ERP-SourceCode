/* Codeunit 51112 "Custom Workflow Responses New"
{

    trigger OnRun()
    begin

    end;
    //..........................................................................................................


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, true)]
    procedure SetStatusToPendingApproval(var Variant: Variant)
    var
        RecRef: RecordRef;
        IsHandled: Boolean;
        MemberApplication: Record "Membership Applications";
    begin
        case RecRef.Number of
            //Member Application
            Database::"Membership Applications":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Validate(Status, MemberApplication.Status::"Pending Approval");
                    MemberApplication.Modify(true);
                    Variant := MemberApplication;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        MemberApplication: Record "Membership Applications";

    begin
        case RecRef.Number of
            //Member Application
            Database::"Membership Applications":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Status := MemberApplication.Status::Open;// New;
                    MemberApplication.Modify(true);
                    Handled := true;
                end;

        end

    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        MemberApplication: Record "Membership Applications";
    begin
        RecRef.GetTable(Variant);
        case RecRef.Number of
            //Member Application
            Database::"Membership Applications":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Validate(Status, MemberApplication.Status::"Pending Approval");
                    MemberApplication.Modify(true);
                    IsHandled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', true, true)]
    local procedure SetRecStatusToPendingApproval(var Variant: Variant)
    var
        RecRef: RecordRef;
        MemberApplication: Record "Membership Applications";
    begin
        case RecRef.Number of
            //Member Application
            Database::"Membership Applications":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Validate(Status, MemberApplication.Status::"Pending Approval");
                    MemberApplication.Modify(true);
                    Variant := MemberApplication;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        MemberApplication: Record "Membership Applications";
    begin
        case RecRef.Number of
            //Member applications
            Database::"Membership Applications":
                begin
                    RecRef.SetTable(MemberApplication);
                    MemberApplication.Status := MemberApplication.Status::Approved;
                    MemberApplication.Modify(true);
                    Handled := true;
                end;
        end;
    end;
    //..........................................................................................................
    var
        WFEventHandler: Codeunit "Workflow Event Handling";
        SurestepWFEvents: Codeunit "Custom Workflow Events New";
        WFResponseHandler: Codeunit "Workflow Response Handling";
        MsgToSend: Text[250];
        CompanyInfo: Record "Company Information";
} */