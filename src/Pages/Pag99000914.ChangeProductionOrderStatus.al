#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000914 "Change Production Order Status"
{
    Caption = 'Change Production Order Status';
    PageType = Worksheet;
    SourceTable = "Production Order";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ProdOrderStatus;ProdOrderStatus)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Status Filter';
                    OptionCaption = 'Simulated,Planned,Firm Planned,Released';
                    ToolTip = 'Specifies the status of the production orders to define a filter on the lines.';

                    trigger OnValidate()
                    begin
                        ProdOrderStatusOnAfterValidate;
                    end;
                }
                field(StartingDate;StartingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Must Start Before';
                    ToolTip = 'Specifies a date to define a filter on the lines.';

                    trigger OnValidate()
                    begin
                        StartingDateOnAfterValidate;
                    end;
                }
                field(EndingDate;EndingDate)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Ends Before';
                    ToolTip = 'Specifies a date to define a filter on the lines.';

                    trigger OnValidate()
                    begin
                        EndingDateOnAfterValidate;
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the production order.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the description of the production order.';
                }
                field("Creation Date";"Creation Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the date on which you created the production order.';
                }
                field("Source Type";"Source Type")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the source type of the production order.';
                }
                field("Source No.";"Source No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the source number of the production order.';
                }
                field("Starting Time";"Starting Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting time of the production order.';
                }
                field("Starting Date";"Starting Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the starting date of the production order.';
                }
                field("Ending Time";"Ending Time")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending time of the production order.';
                }
                field("Ending Date";"Ending Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the ending date of the production order.';
                }
                field("Due Date";"Due Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the due date of the production order.';
                }
                field("Finished Date";"Finished Date")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the actual finishing date of a finished production order.';
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
            group("Pro&d. Order")
            {
                Caption = 'Pro&d. Order';
                Image = "Order";
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Item Ledger E&ntries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Item Ledger E&ntries';
                        Image = ItemLedger;
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the item ledger entries of the item on the document or journal line.';

                        trigger OnAction()
                        var
                            ItemLedgEntry: Record "Item Ledger Entry";
                        begin
                            if Status <> Status::Released then
                              exit;

                            ItemLedgEntry.Reset;
                            ItemLedgEntry.SetCurrentkey("Order Type","Order No.");
                            ItemLedgEntry.SetRange("Order Type",ItemLedgEntry."order type"::Production);
                            ItemLedgEntry.SetRange("Order No.","No.");
                            Page.RunModal(0,ItemLedgEntry);
                        end;
                    }
                    action("Capacity Ledger Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Capacity Ledger Entries';
                        Image = CapacityLedger;
                        ToolTip = 'View the capacity ledger entries of the involved production order. Capacity is recorded either as time (run time, stop time, or setup time) or as quantity (scrap quantity or output quantity).';

                        trigger OnAction()
                        var
                            CapLedgEntry: Record "Capacity Ledger Entry";
                        begin
                            if Status <> Status::Released then
                              exit;

                            CapLedgEntry.Reset;
                            CapLedgEntry.SetCurrentkey("Order Type","Order No.");
                            CapLedgEntry.SetRange("Order Type",CapLedgEntry."order type"::Production);
                            CapLedgEntry.SetRange("Order No.","No.");
                            Page.RunModal(0,CapLedgEntry);
                        end;
                    }
                    action("Value Entries")
                    {
                        ApplicationArea = Manufacturing;
                        Caption = 'Value Entries';
                        Image = ValueLedger;
                        ToolTip = 'View the value entries of the item on the document or journal line.';

                        trigger OnAction()
                        var
                            ValueEntry: Record "Value Entry";
                        begin
                            if Status <> Status::Released then
                              exit;

                            ValueEntry.Reset;
                            ValueEntry.SetCurrentkey("Order Type","Order No.");
                            ValueEntry.SetRange("Order Type",ValueEntry."order type"::Production);
                            ValueEntry.SetRange("Order No.","No.");
                            Page.RunModal(0,ValueEntry);
                        end;
                    }
                }
                action("Co&mments")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Prod. Order Comment Sheet";
                    RunPageLink = Status=field(Status),
                                  "Prod. Order No."=field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
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
                        ShowDocDim;
                        CurrPage.SaveRecord;
                    end;
                }
                action(Statistics)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Statistics';
                    Image = Statistics;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Production Order Statistics";
                    RunPageLink = Status=field(Status),
                                  "No."=field("No."),
                                  "Date Filter"=field("Date Filter");
                    ShortCutKey = 'F7';
                    ToolTip = 'View statistical information, such as the value of posted entries, for the record.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Change &Status")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Change &Status';
                    Ellipsis = true;
                    Image = ChangeStatus;
                    ToolTip = 'Change the production order to another status, such as Released.';

                    trigger OnAction()
                    var
                        ProdOrderStatusMgt: Codeunit "Prod. Order Status Management";
                        ChangeStatusForm: Page "Change Status on Prod. Order";
                        Window: Dialog;
                        NewStatus: Option Simulated,Planned,"Firm Planned",Released,Finished;
                        NewPostingDate: Date;
                        NewUpdateUnitCost: Boolean;
                        NoOfRecords: Integer;
                        POCount: Integer;
                        LocalText000: label 'Simulated,Planned,Firm Planned,Released,Finished';
                    begin
                        ChangeStatusForm.Set(Rec);

                        if ChangeStatusForm.RunModal <> Action::Yes then
                          exit;

                        ChangeStatusForm.ReturnPostingInfo(NewStatus,NewPostingDate,NewUpdateUnitCost);

                        NoOfRecords := Count;

                        Window.Open(
                          StrSubstNo(Text000,SelectStr(NewStatus + 1,LocalText000)) +
                          Text001);

                        POCount := 0;

                        if Find('-') then
                          repeat
                            POCount := POCount + 1;
                            Window.Update(1,"No.");
                            Window.Update(2,ROUND(POCount / NoOfRecords * 10000,1));
                            ProdOrderStatusMgt.ChangeStatusOnProdOrder(
                              Rec,NewStatus,NewPostingDate,NewUpdateUnitCost);
                            Commit;
                          until Next = 0;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        BuildForm;
    end;

    var
        Text000: label 'Changing status to %1...\\';
        Text001: label 'Prod. Order #1###### @2@@@@@@@@@@@@@';
        ProdOrderStatus: Option Simulated,Planned,"Firm Planned",Released;
        StartingDate: Date;
        EndingDate: Date;

    local procedure BuildForm()
    begin
        FilterGroup(2);
        SetRange(Status,ProdOrderStatus);
        FilterGroup(0);

        if StartingDate <> 0D then
          SetFilter("Starting Date",'..%1',StartingDate)
        else
          SetRange("Starting Date");

        if EndingDate <> 0D then
          SetFilter("Ending Date",'..%1',EndingDate)
        else
          SetRange("Ending Date");

        CurrPage.Update(false);
    end;

    local procedure ProdOrderStatusOnAfterValidate()
    begin
        BuildForm;
    end;

    local procedure StartingDateOnAfterValidate()
    begin
        BuildForm;
    end;

    local procedure EndingDateOnAfterValidate()
    begin
        BuildForm;
    end;
}

