#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000806 "Quality Measures"
{
    Caption = 'Quality Measures';
    PageType = List;
    SourceTable = "Quality Measure";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code";Code)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the quality measure code.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a description for the quality measure.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

