#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000863 "Planning Routing"
{
    Caption = 'Planning Routing';
    DataCaptionExpression = Caption;
    DataCaptionFields = "Worksheet Batch Name","Worksheet Line No.";
    PageType = List;
    SourceTable = "Planning Routing Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Operation No.";"Operation No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the operation number for this planning routing line.';
                }
                field("Previous Operation No.";"Previous Operation No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the previous operation number and shows the operation that is run directly before the operation.';
                    Visible = false;
                }
                field("Next Operation No.";"Next Operation No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the next operation number if you use parallel routings.';
                    Visible = false;
                }
                field(Type;Type)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the type of operation.';
                }
                field("No.";"No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a work center or machine center number, depending on the operation type you have entered.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a description of the task related to this routing line.';
                }
                field("Starting Date-Time";"Starting Date-Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the starting date and the starting time, which are combined in a format called "starting date-time".';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the starting time for the operation for this planning routing line.';
                    Visible = false;
                }
                field("Starting Date";"Starting Date")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the starting date for the operation for this planning routing line.';
                    Visible = false;
                }
                field("Ending Date-Time";"Ending Date-Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the ending date and the ending time, which are combined in a format called "ending date-time".';
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the ending time of the operation for this planning routing line.';
                    Visible = false;
                }
                field("Ending Date";"Ending Date")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the ending date of the operation for this planning routing line.';
                    Visible = false;
                }
                field("Setup Time";"Setup Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the setup time using the unit of measure from the Setup Time Unit of Measure field on the work or machine center card.';
                }
                field("Run Time";"Run Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the run time of the operation.';
                }
                field("Wait Time";"Wait Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the wait time.';
                }
                field("Move Time";"Move Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the move time using the unit of measure in the Move Time Unit of Measure field on the machine or work center card.';
                }
                field("Fixed Scrap Quantity";"Fixed Scrap Quantity")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies a fixed scrap quantity for this routing line.';
                    Visible = false;
                }
                field("Scrap Factor %";"Scrap Factor %")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the scrap factor as a percentage.';
                    Visible = false;
                }
                field("Send-Ahead Quantity";"Send-Ahead Quantity")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the output of the operation that must be completed before the next operation can be started.';
                    Visible = false;
                }
                field("Concurrent Capacities";"Concurrent Capacities")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the quantity of machines or personnel that can perform their expected functions simultaneously.';
                    Visible = false;
                }
                field("Unit Cost per";"Unit Cost per")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the unit cost for this operation if it is different than the unit cost on the work center or machine center card.';
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
        area(navigation)
        {
            group("&Routing")
            {
                Caption = '&Routing';
                Image = Route;
                action("Allocated Capacity")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Allocated Capacity';
                    Image = AllocatedCapacity;
                    ToolTip = 'View the capacity need, which is the sum of the setup time and the run time. The run time is equal to the run time per piece multiplied by the number of pieces in the production order.';

                    trigger OnAction()
                    var
                        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
                    begin
                        ProdOrderCapNeed.SetCurrentkey(Type,"No.","Starting Date-Time");
                        ProdOrderCapNeed.SetRange(Type,Type);
                        ProdOrderCapNeed.SetRange("No.","No.");
                        ProdOrderCapNeed.SetRange(Date,"Starting Date","Ending Date");
                        ProdOrderCapNeed.SetRange("Worksheet Template Name","Worksheet Template Name");
                        ProdOrderCapNeed.SetRange("Worksheet Batch Name","Worksheet Batch Name");
                        ProdOrderCapNeed.SetRange("Worksheet Line No.","Worksheet Line No.");
                        ProdOrderCapNeed.SetRange("Operation No.","Operation No.");

                        Page.RunModal(0,ProdOrderCapNeed);
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Order &Tracking")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    var
                        ReqLine: Record "Requisition Line";
                        TrackingForm: Page "Order Tracking";
                    begin
                        ReqLine.Get(
                          "Worksheet Template Name",
                          "Worksheet Batch Name",
                          "Worksheet Line No.");

                        TrackingForm.SetReqLine(ReqLine);
                        TrackingForm.RunModal;
                    end;
                }
            }
        }
    }
}

