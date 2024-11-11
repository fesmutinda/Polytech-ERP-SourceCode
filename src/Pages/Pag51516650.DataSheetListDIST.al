#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516650 "Data Sheet List-DIST"
{
    CardPageID = "Data Sheet Header-Dist";
    Editable = true;
    PageType = List;
    SourceTable = 51516650;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = Basic;
                }
                field("Period Month"; "Period Month")
                {
                    ApplicationArea = Basic;
                }
                field("Period Code"; "Period Code")
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = Basic;
                }
                field("Total Schedule Amount"; "Total Schedule Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Total Schedule Amount P"; "Total Schedule Amount P")
                {
                    ApplicationArea = Basic;
                }
                field("Total Schedule Amount I"; "Total Schedule Amount I")
                {
                    ApplicationArea = Basic;
                }
                field("Total Schedule Amount D"; "Total Schedule Amount D")
                {
                    ApplicationArea = Basic;
                }
                field(Closed; Closed)
                {
                    ApplicationArea = Basic;
                }
                field("Employer Code"; "Employer Code")
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

