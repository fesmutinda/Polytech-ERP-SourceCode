#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000807 "Standard Task Descript. Sheet"
{
    AutoSplitKey = true;
    Caption = 'Standard Task Descript. Sheet';
    DataCaptionFields = "Standard Task Code";
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Standard Task Description";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Text;Text)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the text for the standard task description.';
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

