#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000759 "Calendar Entries"
{
    Caption = 'Calendar Entries';
    DataCaptionExpression = Caption;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Calendar Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Capacity Type";"Capacity Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the type of capacity for the calendar entry.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the machine center or work center entered in the Capacity Type field.';
                }
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when this capacity refers to.';
                    Visible = false;
                }
                field("Work Shift Code";"Work Shift Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies code for the work shift that the capacity refers to.';
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the starting time, which are combined in a format called "starting date-time".';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of this calendar entry.';
                    Visible = false;
                }
                field("Ending Date-Time";"Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the ending time, which are combined in a format called "ending date-time".';
                    Visible = false;
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of this calendar entry.';
                }
                field(Efficiency;Efficiency)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the efficiency of this calendar entry.';
                }
                field(Capacity;Capacity)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the capacity of this calendar entry.';
                }
                field("Capacity (Total)";"Capacity (Total)")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the total capacity of this calendar entry.';
                }
                field("Capacity (Effective)";"Capacity (Effective)")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the effective capacity of this calendar entry.';
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

