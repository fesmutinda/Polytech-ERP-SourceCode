#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000752 "Shop Calendar Working Days"
{
    Caption = 'Shop Calendar Working Days';
    DataCaptionFields = "Shop Calendar Code";
    PageType = List;
    SourceTable = "Shop Calendar Working Days";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Day;Day)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies your working days of the week.';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the shift for this working day.';
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the shift for this working day.';
                }
                field("Work Shift Code";"Work Shift Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the work shift that this working day refers to.';
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

