#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516975 "Collateral Movement Register"
{
    PageType = List;
    SourceTable = 51516922;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; "Entry No")
                {
                    ApplicationArea = Basic;
                }
                field("Document No"; "Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Current Location"; "Current Location")
                {
                    ApplicationArea = Basic;
                }
                field("Date Actioned"; "Date Actioned")
                {
                    ApplicationArea = Basic;
                }
                field("Action By"; "Action By")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

