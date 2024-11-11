#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000922 "Production Forecast Entries"
{
    Caption = 'Production Forecast Entries';
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Production Forecast Entry";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Production Forecast Name";"Production Forecast Name")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the name of the production forecast to which the entry belongs.';
                }
                field("Item No.";"Item No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the item identification number of the entry.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a brief description of your forecast.';
                }
                field("Forecast Quantity (Base)";"Forecast Quantity (Base)")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the quantity of the entry stated, in base units of measure.';
                }
                field("Forecast Date";"Forecast Date")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the date of the production forecast to which the entry belongs.';
                }
                field("Forecast Quantity";"Forecast Quantity")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the quantities you have entered in the production forecast within the selected time interval.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Qty. per Unit of Measure";"Qty. per Unit of Measure")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the valid number of units that the unit of measure code represents for the production forecast entry.';
                }
                field("Location Code";"Location Code")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the code for the location that is linked to the entry.';
                }
                field("Component Forecast";"Component Forecast")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies that the forecast entry is for a component item.';
                }
                field("Entry No.";"Entry No.")
                {
                    ApplicationArea = Manufacturing;
                    Editable = false;
                    ToolTip = 'Specifies the entry number of the production forecast line.';
                    Visible = false;
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

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Production Forecast Name" := xRec."Production Forecast Name";
        "Item No." := xRec."Item No.";
        "Forecast Date" := xRec."Forecast Date";
    end;
}

