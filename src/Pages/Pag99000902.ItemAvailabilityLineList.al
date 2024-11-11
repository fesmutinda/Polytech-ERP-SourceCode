#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000902 "Item Availability Line List"
{
    Caption = 'Item Availability Line List';
    Editable = false;
    PageType = List;
    SourceTable = "Item Availability Line";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name;Name)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the name for this entry.';
                }
                field(Quantity;Quantity)
                {
                    ApplicationArea = Basic,Suite;
                    ToolTip = 'Specifies the quantity for this entry.';

                    trigger OnDrillDown()
                    begin
                        LookupEntries;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        DeleteAll;
        MakeWhat;
    end;

    var
        Text000: label '%1 Receipt';
        Text001: label '%1 Release';
        Text002: label 'Firm planned %1';
        Text003: label 'Released %1';
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        SalesLine: Record "Sales Line";
        ServLine: Record "Service Line";
        JobPlanningLine: Record "Job Planning Line";
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        ReqLine: Record "Requisition Line";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComp: Record "Prod. Order Component";
        PlanningComponent: Record "Planning Component";
        AssemblyHeader: Record "Assembly Header";
        AssemblyLine: Record "Assembly Line";
        AvailType: Option "Gross Requirement","Planned Order Receipt","Scheduled Order Receipt","Planned Order Release",All;
        Sign: Integer;

    procedure Init(NewType: Option "Gross Requirement","Planned Order Receipt","Scheduled Order Receipt","Planned Order Release",All;var NewItem: Record Item)
    begin
        AvailType := NewType;
        Item.Copy(NewItem);
    end;

    local procedure MakeEntries()
    begin
        case AvailType of
          Availtype::"Gross Requirement":
            begin
              InsertEntry(
                Database::"Sales Line",
                Item.FieldNo("Qty. on Sales Order"),
                SalesLine.TableCaption,
                Item."Qty. on Sales Order");
              InsertEntry(
                Database::"Service Line",
                Item.FieldNo("Qty. on Service Order"),
                ServLine.TableCaption,
                Item."Qty. on Service Order");
              InsertEntry(
                Database::"Job Planning Line",
                Item.FieldNo("Qty. on Job Order"),
                JobPlanningLine.TableCaption,
                Item."Qty. on Job Order");
              InsertEntry(
                Database::"Prod. Order Component",
                Item.FieldNo("Scheduled Need (Qty.)"),
                ProdOrderComp.TableCaption,
                Item."Scheduled Need (Qty.)");
              InsertEntry(
                Database::"Planning Component",
                Item.FieldNo("Planning Issues (Qty.)"),
                PlanningComponent.TableCaption,
                Item."Planning Issues (Qty.)");
              InsertEntry(
                Database::"Transfer Line",
                Item.FieldNo("Trans. Ord. Shipment (Qty.)"),
                Item.FieldCaption("Trans. Ord. Shipment (Qty.)"),
                Item."Trans. Ord. Shipment (Qty.)");
              InsertEntry(
                Database::"Purchase Line",
                0,
                PurchLine.TableCaption,
                Item."Qty. on Purch. Return");
              InsertEntry(
                Database::"Assembly Line",
                Item.FieldNo("Qty. on Asm. Component"),
                AssemblyLine.TableCaption,
                Item."Qty. on Asm. Component");
            end;
          Availtype::"Planned Order Receipt":
            begin
              InsertEntry(
                Database::"Requisition Line",
                Item.FieldNo("Purch. Req. Receipt (Qty.)"),
                ReqLine.TableCaption,
                Item."Purch. Req. Receipt (Qty.)");
              InsertEntry(
                Database::"Prod. Order Line",
                Item.FieldNo("Planned Order Receipt (Qty.)"),
                StrSubstNo(Text000,ProdOrderLine.TableCaption),
                Item."Planned Order Receipt (Qty.)");
            end;
          Availtype::"Planned Order Release":
            begin
              InsertEntry(
                Database::"Requisition Line",
                Item.FieldNo("Purch. Req. Release (Qty.)"),
                ReqLine.TableCaption,
                Item."Purch. Req. Release (Qty.)");
              InsertEntry(
                Database::"Prod. Order Line",
                Item.FieldNo("Planned Order Release (Qty.)"),
                StrSubstNo(Text001,ProdOrderLine.TableCaption),
                Item."Planned Order Release (Qty.)");
              InsertEntry(
                Database::"Requisition Line",
                Item.FieldNo("Planning Release (Qty.)"),
                ReqLine.TableCaption,
                Item."Planning Release (Qty.)");
            end;
          Availtype::"Scheduled Order Receipt":
            begin
              InsertEntry(
                Database::"Purchase Line",
                Item.FieldNo("Qty. on Purch. Order"),
                PurchLine.TableCaption,
                Item."Qty. on Purch. Order");
              InsertEntry(
                Database::"Prod. Order Line",
                Item.FieldNo("FP Order Receipt (Qty.)"),
                StrSubstNo(Text002,ProdOrderLine.TableCaption),
                Item."FP Order Receipt (Qty.)");
              InsertEntry(
                Database::"Prod. Order Line",
                Item.FieldNo("Rel. Order Receipt (Qty.)"),
                StrSubstNo(Text003,ProdOrderLine.TableCaption),
                Item."Rel. Order Receipt (Qty.)");
              InsertEntry(
                Database::"Transfer Line",
                Item.FieldNo("Qty. in Transit"),
                Item.FieldCaption("Qty. in Transit"),
                Item."Qty. in Transit");
              InsertEntry(
                Database::"Transfer Line",
                Item.FieldNo("Trans. Ord. Receipt (Qty.)"),
                Item.FieldCaption("Trans. Ord. Receipt (Qty.)"),
                Item."Trans. Ord. Receipt (Qty.)");
              InsertEntry(
                Database::"Sales Line",
                0,
                SalesLine.TableCaption,
                Item."Qty. on Sales Return");
              InsertEntry(
                Database::"Assembly Header",
                Item.FieldNo("Qty. on Assembly Order"),
                AssemblyHeader.TableCaption,
                Item."Qty. on Assembly Order");
            end;
        end;
    end;

    local procedure MakeWhat()
    begin
        Sign := 1;
        if AvailType <> Availtype::All then
          MakeEntries
        else begin
          Item.SetRange("Date Filter",0D,Item.GetRangemax("Date Filter"));
          OnItemSetFilter(Item);
          Item.CalcFields(
            "Qty. on Purch. Order",
            "Qty. on Sales Order",
            "Qty. on Service Order",
            "Qty. on Job Order",
            "Net Change",
            "Scheduled Receipt (Qty.)",
            "Scheduled Need (Qty.)",
            "Planned Order Receipt (Qty.)",
            "FP Order Receipt (Qty.)",
            "Rel. Order Receipt (Qty.)",
            "Planned Order Release (Qty.)",
            "Purch. Req. Receipt (Qty.)",
            "Planning Issues (Qty.)",
            "Purch. Req. Release (Qty.)",
            "Qty. in Transit");
          Item.CalcFields(
            "Trans. Ord. Shipment (Qty.)",
            "Trans. Ord. Receipt (Qty.)",
            "Qty. on Assembly Order",
            "Qty. on Asm. Component",
            "Qty. on Purch. Return",
            "Qty. on Sales Return");

          OnItemCalcFields(Item);

          if Item.Inventory <> 0 then begin
            "Table No." := Database::"Item Ledger Entry";
            QuerySource := Item.FieldNo(Inventory);
            Name := ItemLedgerEntry.TableCaption;
            Quantity := Item.Inventory;
            Insert;
          end;
          AvailType := Availtype::"Gross Requirement";
          Sign := -1;
          MakeEntries;
          AvailType := Availtype::"Planned Order Receipt";
          Sign := 1;
          MakeEntries;
          AvailType := Availtype::"Scheduled Order Receipt";
          Sign := 1;
          MakeEntries;
          AvailType := Availtype::All;
        end;
    end;

    local procedure LookupEntries()
    begin
        case "Table No." of
          Database::"Item Ledger Entry":
            begin
              ItemLedgerEntry.SetCurrentkey("Item No.","Entry Type","Variant Code","Drop Shipment","Location Code","Posting Date");
              ItemLedgerEntry.SetRange("Item No.",Item."No.");
              ItemLedgerEntry.SetFilter("Variant Code",Item.GetFilter("Variant Filter"));
              ItemLedgerEntry.SetFilter("Drop Shipment",Item.GetFilter("Drop Shipment Filter"));
              ItemLedgerEntry.SetFilter("Location Code",Item.GetFilter("Location Filter"));
              ItemLedgerEntry.SetFilter("Global Dimension 1 Code",Item.GetFilter("Global Dimension 1 Filter"));
              ItemLedgerEntry.SetFilter("Global Dimension 2 Code",Item.GetFilter("Global Dimension 2 Filter"));
              OnItemLedgerEntrySetFilter(ItemLedgerEntry);
              Page.RunModal(0,ItemLedgerEntry);
            end;
          Database::"Sales Line":
            begin
              if QuerySource > 0 then
                SalesLine.FindLinesWithItemToPlan(Item,SalesLine."document type"::Order)
              else
                SalesLine.FindLinesWithItemToPlan(Item,SalesLine."document type"::"Return Order");
              SalesLine.SetRange("Drop Shipment",false);
              Page.RunModal(0,SalesLine);
            end;
          Database::"Service Line":
            begin
              ServLine.FindLinesWithItemToPlan(Item);
              Page.RunModal(0,ServLine);
            end;
          Database::"Job Planning Line":
            begin
              JobPlanningLine.FindLinesWithItemToPlan(Item);
              Page.RunModal(0,JobPlanningLine);
            end;
          Database::"Purchase Line":
            begin
              PurchLine.SetCurrentkey("Document Type",Type,"No.");
              if QuerySource > 0 then
                PurchLine.FindLinesWithItemToPlan(Item,PurchLine."document type"::Order)
              else
                PurchLine.FindLinesWithItemToPlan(Item,PurchLine."document type"::"Return Order");
              PurchLine.SetRange("Drop Shipment",false);
              Page.RunModal(0,PurchLine);
            end;
          Database::"Transfer Line":
            begin
              case QuerySource of
                Item.FieldNo("Trans. Ord. Shipment (Qty.)"):
                  TransLine.FindLinesWithItemToPlan(Item,false,false);
                Item.FieldNo("Trans. Ord. Receipt (Qty.)"),Item.FieldNo("Qty. in Transit"):
                  TransLine.FindLinesWithItemToPlan(Item,true,false);
              end;
              Page.RunModal(0,TransLine);
            end;
          Database::"Planning Component":
            begin
              PlanningComponent.FindLinesWithItemToPlan(Item);
              Page.RunModal(0,PlanningComponent);
            end;
          Database::"Prod. Order Component":
            begin
              ProdOrderComp.FindLinesWithItemToPlan(Item,true);
              Page.RunModal(0,ProdOrderComp);
            end;
          Database::"Requisition Line":
            begin
              ReqLine.FindLinesWithItemToPlan(Item);
              case QuerySource of
                Item.FieldNo("Purch. Req. Receipt (Qty.)"):
                  Item.Copyfilter("Date Filter",ReqLine."Due Date");
                Item.FieldNo("Purch. Req. Release (Qty.)"):
                  begin
                    Item.Copyfilter("Date Filter",ReqLine."Order Date");
                    ReqLine.SetFilter("Planning Line Origin",'%1|%2',
                      ReqLine."planning line origin"::" ",ReqLine."planning line origin"::Planning);
                  end;
              end;
              Page.RunModal(0,ReqLine);
            end;
          Database::"Prod. Order Line":
            begin
              ProdOrderLine.Reset;
              ProdOrderLine.SetCurrentkey(Status,"Item No.");
              case QuerySource of
                Item.FieldNo("Planned Order Receipt (Qty.)"):
                  begin
                    ProdOrderLine.SetRange(Status,ProdOrderLine.Status::Planned);
                    Item.Copyfilter("Date Filter",ProdOrderLine."Due Date");
                  end;
                Item.FieldNo("Planned Order Release (Qty.)"):
                  begin
                    ProdOrderLine.SetRange(Status,ProdOrderLine.Status::Planned);
                    Item.Copyfilter("Date Filter",ProdOrderLine."Starting Date");
                  end;
                Item.FieldNo("FP Order Receipt (Qty.)"):
                  begin
                    ProdOrderLine.SetRange(Status,ProdOrderLine.Status::"Firm Planned");
                    Item.Copyfilter("Date Filter",ProdOrderLine."Due Date");
                  end;
                Item.FieldNo("Rel. Order Receipt (Qty.)"):
                  begin
                    ProdOrderLine.SetRange(Status,ProdOrderLine.Status::Released);
                    Item.Copyfilter("Date Filter",ProdOrderLine."Due Date");
                  end;
              end;
              ProdOrderLine.SetRange("Item No.",Item."No.");
              Item.Copyfilter("Variant Filter",ProdOrderLine."Variant Code");
              Item.Copyfilter("Location Filter",ProdOrderLine."Location Code");
              Item.Copyfilter("Global Dimension 1 Filter",ProdOrderLine."Shortcut Dimension 1 Code");
              Item.Copyfilter("Global Dimension 2 Filter",ProdOrderLine."Shortcut Dimension 2 Code");
              Page.RunModal(0,ProdOrderLine);
            end;
          Database::"Assembly Header":
            begin
              AssemblyHeader.FindLinesWithItemToPlan(Item,AssemblyHeader."document type"::Order);
              Page.RunModal(0,AssemblyHeader);
            end;
          Database::"Assembly Line":
            begin
              AssemblyLine.FindLinesWithItemToPlan(Item,AssemblyHeader."document type"::Order);
              Page.RunModal(0,AssemblyLine);
            end;
        end;
    end;

    local procedure InsertEntry("Table": Integer;"Field": Integer;TableName: Text[100];Qty: Decimal)
    begin
        if Qty = 0 then
          exit;

        "Table No." := Table;
        QuerySource := Field;
        Name := CopyStr(TableName,1,MaxStrLen(Name));
        Quantity := Qty * Sign;
        Insert;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemCalcFields(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemSetFilter(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemLedgerEntrySetFilter(var ItemLedgerEntry: Record "Item Ledger Entry")
    begin
    end;
}

