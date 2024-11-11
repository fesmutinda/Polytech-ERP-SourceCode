#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000837 "Routing Quality Measures"
{
    AutoSplitKey = true;
    Caption = 'Routing Quality Measures';
    DataCaptionExpression = Caption;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Routing Quality Measure";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Qlty Measure Code";"Qlty Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quality measure code.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description of the quality measure.';
                }
                field("Min. Value";"Min. Value")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the minimum value that must be met.';
                }
                field("Max. Value";"Max. Value")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the maximum value that may be achieved.';
                }
                field("Mean Tolerance";"Mean Tolerance")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the acceptable mean tolerance.';
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

