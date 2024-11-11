#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000772 "Capacity Absence"
{
    Caption = 'Capacity Absence';
    DataCaptionExpression = Caption;
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Calendar Absence Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date associated with this absence entry.';
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the starting time, which are combined in a format called "starting date-time".';
                    Visible = false;
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the absence entry.';
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
                    ToolTip = 'Specifies the ending time of the absence entry.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description for the absence entry, for example, holiday or vacation"';
                }
                field(Capacity;Capacity)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the capacity of the absence entry, which was planned for this work center or machine center.';
                }
                field(Updated;Updated)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the calendar has been updated with this absence entry.';
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
            group("&Absence")
            {
                Caption = '&Absence';
                Image = Absence;
                action(Update)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Update';
                    Image = Refresh;
                    ToolTip = 'Update the calendar with any new absence entries.';

                    trigger OnAction()
                    var
                        CalendarAbsenceEntry: Record "Calendar Absence Entry";
                    begin
                        CalendarAbsenceEntry.Copy(Rec);
                        CalendarAbsenceEntry.SetRange(Updated,false);
                        if CalendarAbsenceEntry.Find then
                          CalAbsenceMgt.UpdateAbsence(CalendarAbsenceEntry);
                    end;
                }
            }
        }
    }

    var
        CalAbsenceMgt: Codeunit "Calendar Absence Management";
}

