#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000820 "Prod. Order Capacity Need"
{
    Caption = 'Prod. Order Capacity Need';
    DataCaptionFields = Status,"Prod. Order No.";
    Editable = false;
    PageType = List;
    SourceTable = "Prod. Order Capacity Need";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Prod. Order No.";"Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the related production order.';
                    Visible = false;
                }
                field(Type;Type)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the type of capacity need.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the machine center or work center, depending on the entry in the Type field.';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the capacity need.';
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the starting time, which are combined in a format called "starting date-time".';
                    Visible = false;
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the capacity need.';
                }
                field("Ending Date-Time";"Ending Date-Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date and the ending time, which are combined in a format called "ending date-time".';
                    Visible = false;
                }
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date when this capacity need occurred.';
                }
                field("Send-Ahead Type";"Send-Ahead Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies if the send-ahead quantity is of type Input, Output, or Both.';
                }
                field("Time Type";"Time Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the time type of the capacity need.';
                }
                field("Allocated Time";"Allocated Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the capacity need of planned operations.';
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

