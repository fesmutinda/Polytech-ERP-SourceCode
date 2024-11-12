#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516615 "Loan Recovery List"
{
    CardPageID = "Loan Recovery Header";
    Editable = false;
    PageType = List;
    SourceTable = 51516550;
    SourceTableView = where(Posted = filter(No));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; "Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Application Date"; "Application Date")
                {
                    ApplicationArea = Basic;
                }
                field("Created By"; "Created By")
                {
                    ApplicationArea = Basic;
                }
                field("Personal No"; "Personal No")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        SetRange("Created By", UserId);
    end;

    var
        ObjLoanRecoveryH: Record 51516550;
}

