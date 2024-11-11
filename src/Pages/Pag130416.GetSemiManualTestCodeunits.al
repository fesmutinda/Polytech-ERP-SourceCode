#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130416 "Get Semi-Manual Test Codeunits"
{
    Caption = 'Get Semi-Manual Test Codeunits';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = AllObjWithCaption;
    SourceTableView = where("Object Type" = const(Codeunit));

    layout
    {
        area(content)
        {
            repeater(Control4)
            {
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object ID number for the object named in the codeunit.';
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the object name in the codeunit.';
                }
            }
        }
    }

    actions
    {
    }
}

