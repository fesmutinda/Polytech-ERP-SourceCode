#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000862 "Planning Components"
{
    AutoSplitKey = true;
    Caption = 'Planning Components';
    DataCaptionExpression = Caption;
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Planning Component";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No.";"Item No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the item number of the component.';
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Due Date-Time";"Due Date-Time")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the due date and the due time, which are combined in a format called "due date-time".';
                    Visible = false;
                }
                field("Due Date";"Due Date")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the date when this planning component must be finished.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the description of the component.';
                }
                field("Scrap %";"Scrap %")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the percentage of the item that you expect to be scrapped in the production process.';
                    Visible = false;
                }
                field("Calculation Formula";"Calculation Formula")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies how to calculate the Quantity field.';
                    Visible = false;
                }
                field(Length;Length)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the length of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field(Width;Width)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the width of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field(Depth;Depth)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the depth of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field(Weight;Weight)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the weight of one item unit when measured in the specified unit of measure.';
                    Visible = false;
                }
                field("Quantity per";"Quantity per")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies how many units of the component are required to produce the parent item.';
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Expected Quantity";"Expected Quantity")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the expected quantity of this planning component line.';
                }
                field("Reserved Quantity";"Reserved Quantity")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the quantity of units that are reserved.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        ShowReservationEntries(true);
                    end;
                }
                field("Shortcut Dimension 1 Code";"Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code";"Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = false;
                }
                field("Routing Link Code";"Routing Link Code")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a routing link code to link a planning component with a specific operation.';
                    Visible = false;
                }
                field("Location Code";"Location Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the code for the inventory location, where the item on the planning component line will be registered.';
                    Visible = false;
                }
                field("Unit Cost";"Unit Cost")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the unit cost for the planning component line.';
                }
                field("Cost Amount";"Cost Amount")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the total cost for this planning component line.';
                    Visible = false;
                }
                field(Position;Position)
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the position of the component on the bill of material.';
                    Visible = false;
                }
                field("Position 2";"Position 2")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the second reference number for the component position, such as the alternate position number of a component on a circuit board.';
                    Visible = false;
                }
                field("Position 3";"Position 3")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the third reference number for the component position on a bill of material, such as the alternate position number of a component on a print card.';
                    Visible = false;
                }
                field("Lead-Time Offset";"Lead-Time Offset")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the lead-time offset for the planning component.';
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
            group("&Component")
            {
                Caption = '&Component';
                Image = Components;
                group("&Item Availability by")
                {
                    Caption = '&Item Availability by';
                    Image = ItemAvailability;
                    action("Event")
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Event';
                        Image = "Event";
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time according to supply and demand events.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPlanningComp(Rec,ItemAvailFormsMgt.ByEvent);
                        end;
                    }
                    action("&Period")
                    {
                        ApplicationArea = Planning;
                        Caption = '&Period';
                        Image = Period;
                        ToolTip = 'View how the actual and the projected available balance of an item will develop over time.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPlanningComp(Rec,ItemAvailFormsMgt.ByPeriod);
                        end;
                    }
                    action("&Variant")
                    {
                        ApplicationArea = Advanced;
                        Caption = '&Variant';
                        Image = ItemVariant;
                        ToolTip = 'View any variants that exist for the item.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPlanningComp(Rec,ItemAvailFormsMgt.ByVariant);
                        end;
                    }
                    action("&Location")
                    {
                        AccessByPermission = TableData Location=R;
                        ApplicationArea = Location;
                        Caption = '&Location';
                        Image = Warehouse;
                        ToolTip = 'View detailed information about the location where the component exists.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPlanningComp(Rec,ItemAvailFormsMgt.ByLocation);
                        end;
                    }
                    action("BOM Level")
                    {
                        ApplicationArea = Advanced;
                        Caption = 'BOM Level';
                        Image = BOMLevel;
                        ToolTip = 'View availability figures for items on bills of materials that show how many units of a parent item you can make based on the availability of child items.';

                        trigger OnAction()
                        begin
                            ItemAvailFormsMgt.ShowItemAvailFromPlanningComp(Rec,ItemAvailFormsMgt.ByBOM);
                        end;
                    }
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension=R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        ShowDimensions;
                        CurrPage.SaveRecord;
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Shift+Ctrl+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        OpenItemTrackingLines;
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
                action("&Reserve")
                {
                    ApplicationArea = Advanced;
                    Caption = '&Reserve';
                    Image = Reserve;
                    ToolTip = 'Reserve the quantity that is required on the document line that you opened this window for.';

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord;
                        ShowReservation;
                    end;
                }
                action(OrderTracking)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    var
                        TrackingForm: Page "Order Tracking";
                    begin
                        TrackingForm.SetPlanningComponent(Rec);
                        TrackingForm.RunModal;
                    end;
                }
            }
        }
    }

    var
        ItemAvailFormsMgt: Codeunit "Item Availability Forms Mgt";
}

