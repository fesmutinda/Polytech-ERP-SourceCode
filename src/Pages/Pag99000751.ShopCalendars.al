#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000751 "Shop Calendars"
{
    Caption = 'Shop Calendars';
    PageType = List;
    SourceTable = "Shop Calendar";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code";Code)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a code to identify for this shop calendar.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the shop calendar.';
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
            group("&Shop Cal.")
            {
                Caption = '&Shop Cal.';
                Image = Calendar;
                action("Working Days")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Working Days';
                    Image = Workdays;
                    RunObject = Page "Shop Calendar Working Days";
                    RunPageLink = "Shop Calendar Code"=field(Code);
                    ToolTip = 'View or edit the calendar days that are working days and at what time they start and end.';
                }
                action(Holidays)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Holidays';
                    Image = Holiday;
                    RunObject = Page "Shop Calendar Holidays";
                    RunPageLink = "Shop Calendar Code"=field(Code);
                    ToolTip = 'View or edit days that are registered as holidays. ';
                }
            }
        }
    }
}

