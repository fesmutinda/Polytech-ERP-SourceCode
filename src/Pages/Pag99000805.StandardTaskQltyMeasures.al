#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000805 "Standard Task Qlty Measures"
{
    AutoSplitKey = true;
    Caption = 'Standard Task Qlty Measures';
    DataCaptionFields = "Standard Task Code";
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Standard Task Quality Measure";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Qlty Measure Code";"Qlty Measure Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the code of the quality measure.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the quality measure description.';
                }
                field("Min. Value";"Min. Value")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the minimum value that must be met.';
                }
                field("Max. Value";"Max. Value")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the maximum value that may be achieved.';
                }
                field("Mean Tolerance";"Mean Tolerance")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the mean tolerance.';
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

