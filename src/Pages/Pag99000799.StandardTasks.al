#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000799 "Standard Tasks"
{
    Caption = 'Standard Tasks';
    PageType = List;
    SourceTable = "Standard Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code";Code)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the standard task code.';
                }
                field(Control4;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the standard task.';
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
        area(navigation)
        {
            group("&Std. Task")
            {
                Caption = '&Std. Task';
                Image = Tools;
                action(Tools)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Tools';
                    Image = Tools;
                    RunObject = Page "Standard Task Tools";
                    RunPageLink = "Standard Task Code"=field(Code);
                    ToolTip = 'View or edit information about tools that apply to operations that represent the standard task.';
                }
                action(Personnel)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Personnel';
                    Image = User;
                    RunObject = Page "Standard Task Personnel";
                    RunPageLink = "Standard Task Code"=field(Code);
                    ToolTip = 'View or edit information about personnel that applies to operations that represent the standard task.';
                }
                action(Description)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Description';
                    Image = Description;
                    RunObject = Page "Standard Task Descript. Sheet";
                    RunPageLink = "Standard Task Code"=field(Code);
                    ToolTip = 'View or edit a special description that applies to operations that represent the standard task. ';
                }
                action("Quality Measures")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Quality Measures';
                    Image = TaskQualityMeasure;
                    RunObject = Page "Standard Task Qlty Measures";
                    RunPageLink = "Standard Task Code"=field(Code);
                    ToolTip = 'View or edit information about quality measures that apply to operations that represent the standard task.';
                }
            }
        }
    }
}

