#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130402 "CAL Test Codeunits"
{
    Caption = 'CAL Test Codeunits';
    Editable = false;
    PageType = List;
    SourceTable = AllObjWithCaption;
    SourceTableView = where("Object Type"=const(Codeunit),
                            "Object Subtype"=const('Test'));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Object ID";"Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name";"Object Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

