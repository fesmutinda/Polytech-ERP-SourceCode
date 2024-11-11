#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000854 "Inventory Profile Offsetting"
{
    Permissions = TableData "Reservation Entry"=id,
                  TableData "Prod. Order Capacity Need"=rmd;

    trigger OnRun()
    begin
    end;

    var
        ReqLine: Record "Requisition Line";
        ItemLedgEntry: Record "Item Ledger Entry";
        TempSKU: Record "Stockkeeping Unit" temporary;
        TempTransferSKU: Record "Stockkeeping Unit" temporary;
        ManufacturingSetup: Record "Manufacturing Setup";
        InvtSetup: Record "Inventory Setup";
        ReservEntry: Record "Reservation Entry";
        TempTrkgReservEntry: Record "Reservation Entry" temporary;
        TempItemTrkgEntry: Record "Reservation Entry" temporary;
        ActionMsgEntry: Record "Action Message Entry";
        TempPlanningCompList: Record "Planning Component" temporary;
        DummyInventoryProfileTrackBuffer: Record "Inventory Profile Track Buffer";
        CustomizedCalendarChange: Record "Customized Calendar Change";
        CalendarManagement: Codeunit "Calendar Management";
        LeadTimeMgt: Codeunit "Lead-Time Management";
        PlngLnMgt: Codeunit "Planning Line Management";
        PlanningTransparency: Codeunit "Planning Transparency";
        BucketSize: DateFormula;
        ExcludeForecastBefore: Date;
        ScheduleDirection: Option Forward,Backward;
        PlanningLineStage: Option " ","Line Created","Routing Created",Exploded,Obsolete;
        SurplusType: Option "None",Forecast,BlanketOrder,SafetyStock,ReorderPoint,MaxInventory,FixedOrderQty,MaxOrder,MinOrder,OrderMultiple,DampenerQty,PlanningFlexibility,Undefined,EmergencyOrder;
        CurrWorksheetType: Option Requisition,Planning;
        DampenerQty: Decimal;
        FutureSupplyWithinLeadtime: Decimal;
        LineNo: Integer;
        DampenersDays: Integer;
        BucketSizeInDays: Integer;
        CurrTemplateName: Code[10];
        CurrWorksheetName: Code[10];
        CurrForecast: Code[10];
        PlanMRP: Boolean;
        SpecificLotTracking: Boolean;
        SpecificSNTracking: Boolean;
        Text001: label 'Assertion failed: %1.';
        UseParm: Boolean;
        PlanningResilicency: Boolean;
        Text002: label 'The %1 from ''%2'' to ''%3'' does not exist.';
        Text003: label 'The %1 for %2 %3 %4 %5 does not exist.';
        Text004: label '%1 must not be %2 in %3 %4 %5 %6 when %7 is %8.';
        Text005: label '%1 must not be %2 in %3 %4 when %5 is %6.';
        Text006: label '%1: The projected available inventory is %2 on the planning starting date %3.';
        Text007: label '%1: The projected available inventory is below %2 %3 on %4.';
        Text008: label '%1: The %2 %3 is before the work date %4.';
        Text009: label '%1: The %2 of %3 %4 is %5.';
        Text010: label 'The projected inventory %1 is higher than the overflow level %2 on %3.';
        PlanToDate: Date;
        OverflowLevel: Decimal;
        ExceedROPqty: Decimal;
        NextStateTxt: label 'StartOver,MatchDates,MatchQty,CreateSupply,ReduceSupply,CloseDemand,CloseSupply,CloseLoop';
        NextState: Option StartOver,MatchDates,MatchQty,CreateSupply,ReduceSupply,CloseDemand,CloseSupply,CloseLoop;
        LotAccumulationPeriodStartDate: Date;


    procedure CalculatePlanFromWorksheet(var Item: Record Item;ManufacturingSetup2: Record "Manufacturing Setup";TemplateName: Code[10];WorksheetName: Code[10];OrderDate: Date;ToDate: Date;MRPPlanning: Boolean;RespectPlanningParm: Boolean)
    var
        InventoryProfile: array [2] of Record "Inventory Profile" temporary;
    begin
        OnBeforeCalculatePlanFromWorksheet(
          Item,ManufacturingSetup2,TemplateName,WorksheetName,OrderDate,ToDate,MRPPlanning,RespectPlanningParm);

        PlanToDate := ToDate;
        InitVariables(InventoryProfile[1],ManufacturingSetup2,Item,TemplateName,WorksheetName,MRPPlanning);
        DemandToInvtProfile(InventoryProfile[1],Item,ToDate);
        OrderDate := ForecastConsumption(InventoryProfile[1],Item,OrderDate,ToDate);
        BlanketOrderConsump(InventoryProfile[1],Item,ToDate);
        SupplytoInvProfile(InventoryProfile[1],Item,ToDate);
        UnfoldItemTracking(InventoryProfile[1],InventoryProfile[2]);
        FindCombination(InventoryProfile[1],InventoryProfile[2],Item);
        PlanItem(InventoryProfile[1],InventoryProfile[2],OrderDate,ToDate,RespectPlanningParm);
        CommitTracking;
    end;

    local procedure InitVariables(var InventoryProfile: Record "Inventory Profile";ManufacturingSetup2: Record "Manufacturing Setup";Item: Record Item;TemplateName: Code[10];WorksheetName: Code[10];MRPPlanning: Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ManufacturingSetup := ManufacturingSetup2;
        InvtSetup.Get;
        CurrTemplateName := TemplateName;
        CurrWorksheetName := WorksheetName;
        InventoryProfile.Reset;
        InventoryProfile.DeleteAll;
        TempSKU.Reset;
        TempSKU.DeleteAll;
        Clear(TempSKU);
        TempTransferSKU.Reset;
        TempTransferSKU.DeleteAll;
        Clear(TempTransferSKU);
        TempTrkgReservEntry.Reset;
        TempTrkgReservEntry.DeleteAll;
        TempItemTrkgEntry.Reset;
        TempItemTrkgEntry.DeleteAll;
        PlanMRP := MRPPlanning;
        if Item."Item Tracking Code" <> '' then begin
          ItemTrackingCode.Get(Item."Item Tracking Code");
          SpecificLotTracking := ItemTrackingCode."Lot Specific Tracking";
          SpecificSNTracking := ItemTrackingCode."SN Specific Tracking";
        end else begin
          SpecificLotTracking := false;
          SpecificSNTracking := false;
        end;
        LineNo := 0; // Global variable
        PlanningTransparency.SetTemplAndWorksheet(CurrTemplateName,CurrWorksheetName);
    end;

    local procedure CreateTempSKUForLocation(ItemNo: Code[20];LocationCode: Code[10])
    begin
        TempSKU.Init;
        TempSKU."Item No." := ItemNo;
        TransferPlanningParameters(TempSKU);
        TempSKU."Location Code" := LocationCode;
        TempSKU.Insert;
    end;

    local procedure DemandToInvtProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        CopyOfItem: Record Item;
    begin
        InventoryProfile.SetCurrentkey("Line No.");

        CopyOfItem.Copy(Item);
        Item.SetRange("Date Filter",0D,ToDate);

        TransSalesLineToProfile(InventoryProfile,Item);
        TransServLineToProfile(InventoryProfile,Item);
        TransJobPlanningLineToProfile(InventoryProfile,Item);
        TransProdOrderCompToProfile(InventoryProfile,Item);
        TransAsmLineToProfile(InventoryProfile,Item);
        TransPlanningCompToProfile(InventoryProfile,Item);
        TransTransReqLineToProfile(InventoryProfile,Item,ToDate);
        TransShptTransLineToProfile(InventoryProfile,Item);

        OnAfterDemandToInvProfile(InventoryProfile,Item,TempItemTrkgEntry,LineNo);

        Item.Copy(CopyOfItem);
    end;

    local procedure SupplytoInvProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        CopyOfItem: Record Item;
    begin
        InventoryProfile.Reset;
        ItemLedgEntry.Reset;
        InventoryProfile.SetCurrentkey("Line No.");

        CopyOfItem.Copy(Item);
        Item.SetRange("Date Filter");

        TransItemLedgEntryToProfile(InventoryProfile,Item);
        TransReqLineToProfile(InventoryProfile,Item,ToDate);
        TransPurchLineToProfile(InventoryProfile,Item,ToDate);
        TransProdOrderToProfile(InventoryProfile,Item,ToDate);
        TransAsmHeaderToProfile(InventoryProfile,Item,ToDate);
        TransRcptTransLineToProfile(InventoryProfile,Item,ToDate);

        OnAfterSupplyToInvProfile(InventoryProfile,Item,ToDate,TempItemTrkgEntry,LineNo);

        Item.Copy(CopyOfItem);
    end;

    local procedure InsertSupplyProfile(var InventoryProfile: Record "Inventory Profile";ToDate: Date)
    begin
        if InventoryProfile.IsSupply then begin
          if InventoryProfile."Due Date" > ToDate then
            InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
          InventoryProfile.Insert;
        end else
          if InventoryProfile."Due Date" <= ToDate then begin
            InventoryProfile.ChangeSign;
            InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
            InventoryProfile.Insert;
          end;
    end;

    local procedure TransSalesLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        SalesLine: Record "Sales Line";
    begin
        if SalesLine.FindLinesWithItemToPlan(Item,SalesLine."document type"::Order) then
          repeat
            if SalesLine."Shipment Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromSalesLine(SalesLine,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              InventoryProfile."MPS Order" := true;
              InventoryProfile.Insert;
            end;
          until SalesLine.Next = 0;

        if SalesLine.FindLinesWithItemToPlan(Item,SalesLine."document type"::"Return Order") then
          repeat
            if SalesLine."Shipment Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromSalesLine(SalesLine,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              InventoryProfile.Insert;
            end;
          until SalesLine.Next = 0;
    end;

    local procedure TransServLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        ServLine: Record "Service Line";
    begin
        if ServLine.FindLinesWithItemToPlan(Item) then
          repeat
            if ServLine."Needed by Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromServLine(ServLine,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              InventoryProfile.Insert;
            end;
          until ServLine.Next = 0;
    end;

    local procedure TransJobPlanningLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        JobPlanningLine: Record "Job Planning Line";
    begin
        if JobPlanningLine.FindLinesWithItemToPlan(Item) then
          repeat
            if JobPlanningLine."Planning Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromJobPlanningLine(JobPlanningLine,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              InventoryProfile.Insert;
            end;
          until JobPlanningLine.Next = 0;
    end;

    local procedure TransProdOrderCompToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        ProdOrderComp: Record "Prod. Order Component";
    begin
        if ProdOrderComp.FindLinesWithItemToPlan(Item,true) then
          repeat
            if ProdOrderComp."Due Date" <> 0D then begin
              ReqLine.SetRefFilter(
                ReqLine."ref. order type"::"Prod. Order",ProdOrderComp.Status,
                ProdOrderComp."Prod. Order No.",ProdOrderComp."Prod. Order Line No.");
              ReqLine.SetRange("Operation No.",'');
              if not ReqLine.FindFirst then begin
                InventoryProfile.Init;
                InventoryProfile."Line No." := NextLineNo;
                InventoryProfile.TransferFromComponent(ProdOrderComp,TempItemTrkgEntry);
                if InventoryProfile.IsSupply then
                  InventoryProfile.ChangeSign;
                InventoryProfile.Insert;
              end;
            end;
          until ProdOrderComp.Next = 0;
    end;

    local procedure TransPlanningCompToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        PlanningComponent: Record "Planning Component";
    begin
        if not PlanMRP then
          exit;

        if PlanningComponent.FindLinesWithItemToPlan(Item) then
          repeat
            if PlanningComponent."Due Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile."Item No." := Item."No.";
              InventoryProfile.TransferFromPlanComponent(PlanningComponent,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              InventoryProfile.Insert;
            end;
          until PlanningComponent.Next = 0;
    end;

    local procedure TransAsmLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        AsmHeader: Record "Assembly Header";
        AsmLine: Record "Assembly Line";
        RemRatio: Decimal;
    begin
        if AsmLine.FindLinesWithItemToPlan(Item,AsmLine."document type"::Order) then
          repeat
            if AsmLine."Due Date" <> 0D then begin
              ReqLine.SetRefFilter(
                ReqLine."ref. order type"::Assembly,AsmLine."Document Type",AsmLine."Document No.",0);
              ReqLine.SetRange("Operation No.",'');
              if not ReqLine.FindFirst then
                InsertAsmLineToProfile(InventoryProfile,AsmLine,1);
            end;
          until AsmLine.Next = 0;

        if AsmLine.FindLinesWithItemToPlan(Item,AsmLine."document type"::"Blanket Order") then
          repeat
            if AsmLine."Due Date" <> 0D then begin
              ReqLine.SetRefFilter(ReqLine."ref. order type"::Assembly,AsmLine."Document Type",AsmLine."Document No.",0);
              ReqLine.SetRange("Operation No.",'');
              if not ReqLine.FindFirst then begin
                AsmHeader.Get(AsmLine."Document Type",AsmLine."Document No.");
                RemRatio := (AsmHeader."Quantity (Base)" - CalcSalesOrderQty(AsmLine)) / AsmHeader."Quantity (Base)";
                InsertAsmLineToProfile(InventoryProfile,AsmLine,RemRatio);
              end;
            end;
          until AsmLine.Next = 0;
    end;

    local procedure TransTransReqLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        TransferReqLine: Record "Requisition Line";
    begin
        TransferReqLine.SetCurrentkey("Replenishment System",Type,"No.","Variant Code","Transfer-from Code","Transfer Shipment Date");
        TransferReqLine.SetRange("Replenishment System",TransferReqLine."replenishment system"::Transfer);
        TransferReqLine.SetRange(Type,TransferReqLine.Type::Item);
        TransferReqLine.SetRange("No.",Item."No.");
        Item.Copyfilter("Location Filter",TransferReqLine."Transfer-from Code");
        Item.Copyfilter("Variant Filter",TransferReqLine."Variant Code");
        TransferReqLine.SetFilter("Transfer Shipment Date",'>%1&<=%2',0D,ToDate);
        if TransferReqLine.FindSet then
          repeat
            InventoryProfile.Init;
            InventoryProfile."Line No." := NextLineNo;
            InventoryProfile."Item No." := Item."No.";
            InventoryProfile.TransferFromOutboundTransfPlan(TransferReqLine,TempItemTrkgEntry);
            if InventoryProfile.IsSupply then
              InventoryProfile.ChangeSign;
            InventoryProfile.Insert;
          until TransferReqLine.Next = 0;
    end;

    local procedure TransShptTransLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    var
        TransLine: Record "Transfer Line";
        FilterIsSetOnLocation: Boolean;
    begin
        FilterIsSetOnLocation := Item.GetFilter("Location Filter") <> '';
        if TransLine.FindLinesWithItemToPlan(Item,false,true) then
          repeat
            if TransLine."Shipment Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile."Item No." := Item."No.";
              InventoryProfile.TransferFromOutboundTransfer(TransLine,TempItemTrkgEntry);
              if InventoryProfile.IsSupply then
                InventoryProfile.ChangeSign;
              if FilterIsSetOnLocation then
                InventoryProfile."Transfer Location Not Planned" := TransferLocationIsFilteredOut(Item,TransLine);
              SyncTransferDemandWithReqLine(InventoryProfile,TransLine."Transfer-to Code");
              InventoryProfile.Insert;
            end;
          until TransLine.Next = 0;
    end;

    local procedure TransItemLedgEntryToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item)
    begin
        if ItemLedgEntry.FindLinesWithItemToPlan(Item,false) then
          repeat
            InventoryProfile.Init;
            InventoryProfile."Line No." := NextLineNo;
            InventoryProfile.TransferFromItemLedgerEntry(ItemLedgEntry,TempItemTrkgEntry);
            InventoryProfile."Due Date" := 0D;
            if not InventoryProfile.IsSupply then
              InventoryProfile.ChangeSign;
            InventoryProfile.Insert;
          until ItemLedgEntry.Next = 0;
    end;

    local procedure TransReqLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        ReqLine: Record "Requisition Line";
    begin
        if ReqLine.FindLinesWithItemToPlan(Item) then
          repeat
            if ReqLine."Due Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile."Item No." := Item."No.";
              InventoryProfile.TransferFromRequisitionLine(ReqLine,TempItemTrkgEntry);
              InsertSupplyProfile(InventoryProfile,ToDate);
            end;
          until ReqLine.Next = 0;
    end;

    local procedure TransPurchLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        PurchLine: Record "Purchase Line";
    begin
        if PurchLine.FindLinesWithItemToPlan(Item,PurchLine."document type"::Order) then
          repeat
            if PurchLine."Expected Receipt Date" <> 0D then
              if PurchLine."Prod. Order No." = '' then
                InsertPurchLineToProfile(InventoryProfile,PurchLine,ToDate);
          until PurchLine.Next = 0;

        if PurchLine.FindLinesWithItemToPlan(Item,PurchLine."document type"::"Return Order") then
          repeat
            if PurchLine."Expected Receipt Date" <> 0D then
              if PurchLine."Prod. Order No." = '' then
                InsertPurchLineToProfile(InventoryProfile,PurchLine,ToDate);
          until PurchLine.Next = 0;
    end;

    local procedure TransProdOrderToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        ProdOrderLine: Record "Prod. Order Line";
        CapLedgEntry: Record "Capacity Ledger Entry";
        ProdOrderComp: Record "Prod. Order Component";
    begin
        if ProdOrderLine.FindLinesWithItemToPlan(Item,true) then
          repeat
            if ProdOrderLine."Due Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromProdOrderLine(ProdOrderLine,TempItemTrkgEntry);
              if (ProdOrderLine."Planning Flexibility" = ProdOrderLine."planning flexibility"::Unlimited) and
                 (ProdOrderLine.Status = ProdOrderLine.Status::Released)
              then begin
                CapLedgEntry.SetCurrentkey("Order Type","Order No.");
                CapLedgEntry.SetRange("Order Type",CapLedgEntry."order type"::Production);
                CapLedgEntry.SetRange("Order No.",ProdOrderLine."Prod. Order No.");
                ItemLedgEntry.Reset;
                ItemLedgEntry.SetCurrentkey("Order Type","Order No.");
                ItemLedgEntry.SetRange("Order Type",ItemLedgEntry."order type"::Production);
                ItemLedgEntry.SetRange("Order No.",ProdOrderLine."Prod. Order No.");
                if not (CapLedgEntry.IsEmpty and ItemLedgEntry.IsEmpty) then
                  InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None
                else begin
                  ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
                  ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
                  ProdOrderComp.SetRange("Prod. Order Line No.",ProdOrderLine."Line No.");
                  ProdOrderComp.SetFilter("Qty. Picked (Base)",'>0');
                  if not ProdOrderComp.IsEmpty then
                    InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
                end;
              end;
              InsertSupplyProfile(InventoryProfile,ToDate);
            end;
          until ProdOrderLine.Next = 0;
    end;

    local procedure TransAsmHeaderToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        AsmHeader: Record "Assembly Header";
    begin
        if AsmHeader.FindLinesWithItemToPlan(Item,AsmHeader."document type"::Order) then
          repeat
            if AsmHeader."Due Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromAsmHeader(AsmHeader,TempItemTrkgEntry);
              if InventoryProfile."Finished Quantity" > 0 then
                InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
              InsertSupplyProfile(InventoryProfile,ToDate);
            end;
          until AsmHeader.Next = 0;
    end;

    local procedure TransRcptTransLineToProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        TransLine: Record "Transfer Line";
        WhseEntry: Record "Warehouse Entry";
        FilterIsSetOnLocation: Boolean;
    begin
        FilterIsSetOnLocation := Item.GetFilter("Location Filter") <> '';
        if TransLine.FindLinesWithItemToPlan(Item,true,true) then
          repeat
            if TransLine."Receipt Date" <> 0D then begin
              InventoryProfile.Init;
              InventoryProfile."Line No." := NextLineNo;
              InventoryProfile.TransferFromInboundTransfer(TransLine,TempItemTrkgEntry);
              if TransLine."Planning Flexibility" = TransLine."planning flexibility"::Unlimited then
                if (InventoryProfile."Finished Quantity" > 0) or
                   (TransLine."Quantity Shipped" > 0) or (TransLine."Derived From Line No." > 0)
                then
                  InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None
                else begin
                  WhseEntry.SetSourceFilter(
                    Database::"Transfer Line",0,InventoryProfile."Source ID",InventoryProfile."Source Ref. No.",true);
                  if not WhseEntry.IsEmpty then
                    InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
                end;
              if FilterIsSetOnLocation then
                InventoryProfile."Transfer Location Not Planned" := TransferLocationIsFilteredOut(Item,TransLine);
              InsertSupplyProfile(InventoryProfile,ToDate);
              InsertTempTransferSKU(TransLine);
            end;
          until TransLine.Next = 0;
    end;

    local procedure TransferLocationIsFilteredOut(var Item: Record Item;var TransLine: Record "Transfer Line"): Boolean
    var
        TempTransLine: Record "Transfer Line" temporary;
    begin
        TempTransLine := TransLine;
        TempTransLine.Insert;
        Item.Copyfilter("Location Filter",TempTransLine."Transfer-from Code");
        Item.Copyfilter("Location Filter",TempTransLine."Transfer-to Code");
        exit(TempTransLine.IsEmpty);
    end;

    local procedure InsertPurchLineToProfile(var InventoryProfile: Record "Inventory Profile";PurchLine: Record "Purchase Line";ToDate: Date)
    begin
        InventoryProfile.Init;
        InventoryProfile."Line No." := NextLineNo;
        InventoryProfile.TransferFromPurchaseLine(PurchLine,TempItemTrkgEntry);
        if InventoryProfile."Finished Quantity" > 0 then
          InventoryProfile."Planning Flexibility" := InventoryProfile."planning flexibility"::None;
        InsertSupplyProfile(InventoryProfile,ToDate);
    end;

    local procedure InsertAsmLineToProfile(var InventoryProfile: Record "Inventory Profile";AsmLine: Record "Assembly Line";RemRatio: Decimal)
    begin
        InventoryProfile.Init;
        InventoryProfile."Line No." := NextLineNo;
        InventoryProfile.TransferFromAsmLine(AsmLine,TempItemTrkgEntry);
        if RemRatio <> 1 then begin
          InventoryProfile."Untracked Quantity" := ROUND(InventoryProfile."Untracked Quantity" * RemRatio,0.00001);
          InventoryProfile."Remaining Quantity (Base)" := InventoryProfile."Untracked Quantity";
        end;
        if InventoryProfile.IsSupply then
          InventoryProfile.ChangeSign;
        InventoryProfile.Insert;
    end;

    local procedure ForecastConsumption(var DemandInvtProfile: Record "Inventory Profile";var Item: Record Item;OrderDate: Date;ToDate: Date) UpdatedOrderDate: Date
    var
        ForecastEntry: Record "Production Forecast Entry";
        ForecastEntry2: Record "Production Forecast Entry";
        NextForecast: Record "Production Forecast Entry";
        TotalForecastQty: Decimal;
        ReplenishmentLocation: Code[10];
        ForecastExist: Boolean;
        NextForecastExist: Boolean;
        ReplenishmentLocationFound: Boolean;
        ComponentForecast: Boolean;
        ComponentForecastFrom: Boolean;
    begin
        UpdatedOrderDate := OrderDate;
        ComponentForecastFrom := false;
        if not ManufacturingSetup."Use Forecast on Locations" then begin
          ReplenishmentLocationFound := FindReplishmentLocation(ReplenishmentLocation,Item);
          if InvtSetup."Location Mandatory" and not ReplenishmentLocationFound then
            ComponentForecastFrom := true;

          ForecastEntry.SetCurrentkey(
            "Production Forecast Name","Item No.","Component Forecast","Forecast Date","Location Code");
        end else
          ForecastEntry.SetCurrentkey(
            "Production Forecast Name","Item No.","Location Code","Forecast Date","Component Forecast");

        ItemLedgEntry.Reset;
        ItemLedgEntry.SetCurrentkey("Item No.",Open,"Variant Code",Positive,"Location Code");
        DemandInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date");

        NextForecast.Copy(ForecastEntry);

        if not UseParm then
          CurrForecast := ManufacturingSetup."Current Production Forecast";

        ForecastEntry.SetRange("Production Forecast Name",CurrForecast);
        ForecastEntry.SetRange("Forecast Date",ExcludeForecastBefore,ToDate);

        ForecastEntry.SetRange("Item No.",Item."No.");
        ForecastEntry2.Copy(ForecastEntry);
        Item.Copyfilter("Location Filter",ForecastEntry2."Location Code");

        for ComponentForecast := ComponentForecastFrom to true do begin
          if ComponentForecast then begin
            ReplenishmentLocation := ManufacturingSetup."Components at Location";
            if InvtSetup."Location Mandatory" and (ReplenishmentLocation = '') then
              exit;
          end;
          ForecastEntry.SetRange("Component Forecast",ComponentForecast);
          ForecastEntry2.SetRange("Component Forecast",ComponentForecast);
          if ForecastEntry2.Find('-') then
            repeat
              if ManufacturingSetup."Use Forecast on Locations" then begin
                ForecastEntry2.SetRange("Location Code",ForecastEntry2."Location Code");
                ItemLedgEntry.SetRange("Location Code",ForecastEntry2."Location Code");
                DemandInvtProfile.SetRange("Location Code",ForecastEntry2."Location Code");
              end else begin
                Item.Copyfilter("Location Filter",ForecastEntry2."Location Code");
                Item.Copyfilter("Location Filter",ItemLedgEntry."Location Code");
                Item.Copyfilter("Location Filter",DemandInvtProfile."Location Code");
              end;
              ForecastEntry2.Find('+');
              ForecastEntry2.Copyfilter("Location Code",ForecastEntry."Location Code");
              Item.Copyfilter("Location Filter",ForecastEntry2."Location Code");

              ForecastExist := CheckForecastExist(ForecastEntry,OrderDate,ToDate);

              if ForecastExist then
                repeat
                  ForecastEntry.SetRange("Forecast Date",ForecastEntry."Forecast Date");
                  ForecastEntry.CalcSums("Forecast Quantity (Base)");
                  TotalForecastQty := ForecastEntry."Forecast Quantity (Base)";
                  ForecastEntry.Find('+');
                  NextForecast.CopyFilters(ForecastEntry);
                  NextForecast.SetRange("Forecast Date",ForecastEntry."Forecast Date" + 1,ToDate);
                  if not NextForecast.FindFirst then
                    NextForecast."Forecast Date" := ToDate + 1
                  else
                    repeat
                      NextForecast.SetRange("Forecast Date",NextForecast."Forecast Date");
                      NextForecast.CalcSums("Forecast Quantity (Base)");
                      if NextForecast."Forecast Quantity (Base)" = 0 then begin
                        NextForecast.SetRange("Forecast Date",NextForecast."Forecast Date" + 1,ToDate);
                        if not NextForecast.FindFirst then
                          NextForecast."Forecast Date" := ToDate + 1
                      end else
                        NextForecastExist := true
                    until (NextForecast."Forecast Date" = ToDate + 1) or NextForecastExist;
                  NextForecastExist := false;

                  ItemLedgEntry.SetRange("Item No.",Item."No.");
                  ItemLedgEntry.SetRange(Positive,false);
                  ItemLedgEntry.SetRange(Open);
                  ItemLedgEntry.SetRange(
                    "Posting Date",ForecastEntry."Forecast Date",NextForecast."Forecast Date" - 1);
                  Item.Copyfilter("Variant Filter",ItemLedgEntry."Variant Code");
                  if ComponentForecast then begin
                    ItemLedgEntry.SetRange("Entry Type",ItemLedgEntry."entry type"::Consumption);
                    ItemLedgEntry.CalcSums(Quantity);
                    TotalForecastQty += ItemLedgEntry.Quantity;
                  end else begin
                    ItemLedgEntry.SetRange("Entry Type",ItemLedgEntry."entry type"::Sale);
                    ItemLedgEntry.SetRange("Derived from Blanket Order",false);
                    ItemLedgEntry.CalcSums(Quantity);
                    TotalForecastQty += ItemLedgEntry.Quantity;
                    ItemLedgEntry.SetRange("Derived from Blanket Order");
                    // Undo shipment shall neutralize consumption from sales
                    ItemLedgEntry.SetRange(Positive,true);
                    ItemLedgEntry.SetRange(Correction,true);
                    ItemLedgEntry.CalcSums(Quantity);
                    TotalForecastQty += ItemLedgEntry.Quantity;
                    ItemLedgEntry.SetRange(Correction);
                  end;

                  DemandInvtProfile.SetRange("Item No.",ForecastEntry."Item No.");
                  DemandInvtProfile.SetRange(
                    "Due Date",ForecastEntry."Forecast Date",NextForecast."Forecast Date" - 1);
                  if ComponentForecast then
                    DemandInvtProfile.SetFilter(
                      "Source Type",
                      '%1|%2|%3',
                      Database::"Prod. Order Component",
                      Database::"Planning Component",
                      Database::"Assembly Line")
                  else
                    DemandInvtProfile.SetFilter(
                      "Source Type",
                      '%1|%2',
                      Database::"Sales Line",
                      Database::"Service Line");
                  if DemandInvtProfile.Find('-') then
                    repeat
                      if not (DemandInvtProfile.IsSupply or DemandInvtProfile."Derived from Blanket Order")
                      then
                        TotalForecastQty := TotalForecastQty - DemandInvtProfile."Remaining Quantity (Base)";
                    until (DemandInvtProfile.Next = 0) or (TotalForecastQty < 0);
                  if TotalForecastQty > 0 then begin
                    ForecastInitDemand(DemandInvtProfile,ForecastEntry,Item."No.",ReplenishmentLocation,TotalForecastQty);
                    DemandInvtProfile."Due Date" :=
                      CalendarManagement.CalcDateBOC2(
                        '<0D>',ForecastEntry."Forecast Date",
                        CustomizedCalendarChange."source type"::Location,DemandInvtProfile."Location Code",'',
                        CustomizedCalendarChange."source type"::Location,DemandInvtProfile."Location Code",'',false);
                    if DemandInvtProfile."Due Date" < UpdatedOrderDate then
                      UpdatedOrderDate := DemandInvtProfile."Due Date";
                    DemandInvtProfile.Insert;
                  end;
                  ForecastEntry.SetRange("Forecast Date",ExcludeForecastBefore,ToDate);
                until ForecastEntry.Next = 0;
            until ForecastEntry2.Next = 0;
        end;
    end;

    local procedure BlanketOrderConsump(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;ToDate: Date)
    var
        BlanketSalesLine: Record "Sales Line";
        QtyReleased: Decimal;
    begin
        InventoryProfile.Reset;
        with BlanketSalesLine do begin
          SetCurrentkey("Document Type","Document No.",Type,"No.");
          SetRange("Document Type","document type"::"Blanket Order");
          SetRange(Type,Type::Item);
          SetRange("No.",Item."No.");
          Item.Copyfilter("Location Filter","Location Code");
          Item.Copyfilter("Variant Filter","Variant Code");
          SetFilter("Outstanding Qty. (Base)",'<>0');
          SetFilter("Shipment Date",'>%1&<=%2',0D,ToDate);
          OnBeforeBlanketOrderConsumpFind(BlanketSalesLine);
          if Find('-') then
            repeat
              QtyReleased += CalcInventoryProfileRemainingQty(InventoryProfile,"Document No.");
              SetRange("Document No.","Document No.");
              BlanketSalesOrderLinesToProfile(InventoryProfile,BlanketSalesLine,QtyReleased);
              SetRange("Document No.");
            until Next = 0;
        end;
    end;

    local procedure BlanketSalesOrderLinesToProfile(var InventoryProfile: Record "Inventory Profile";var BlanketSalesLine: Record "Sales Line";var QtyReleased: Decimal)
    var
        IsSalesOrderLineCreated: Boolean;
    begin
        with BlanketSalesLine do
          for IsSalesOrderLineCreated := true downto false do begin
            Find('-');
            repeat
              if "Quantity (Base)" <> "Qty. to Asm. to Order (Base)" then
                if DoProcessBlanketLine("Document No.","Line No.",IsSalesOrderLineCreated) then
                  if "Outstanding Qty. (Base)" - "Qty. to Asm. to Order (Base)" > QtyReleased then begin
                    InventoryProfile.Init;
                    InventoryProfile."Line No." := NextLineNo;
                    InventoryProfile.TransferFromSalesLine(BlanketSalesLine,TempItemTrkgEntry);
                    InventoryProfile."Untracked Quantity" := "Outstanding Qty. (Base)" - QtyReleased;
                    InventoryProfile."Remaining Quantity (Base)" := InventoryProfile."Untracked Quantity";
                    QtyReleased := 0;
                    InventoryProfile.Insert;
                  end else
                    QtyReleased -= "Outstanding Qty. (Base)";
            until Next = 0;
          end;
    end;

    local procedure DoProcessBlanketLine(BlanketOrderNo: Code[20];BlanketOrderLineNo: Integer;IsSalesOrderLineCreated: Boolean): Boolean
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetRange("Blanket Order No.",BlanketOrderNo);
        SalesLine.SetRange("Blanket Order Line No.",BlanketOrderLineNo);
        exit(not SalesLine.IsEmpty = IsSalesOrderLineCreated)
    end;

    local procedure CheckForecastExist(var ForecastEntry: Record "Production Forecast Entry";OrderDate: Date;ToDate: Date): Boolean
    var
        ForecastExist: Boolean;
    begin
        ForecastEntry.SetRange("Forecast Date",ExcludeForecastBefore,OrderDate);
        if ForecastEntry.Find('+') then
          repeat
            ForecastEntry.SetRange("Forecast Date",ForecastEntry."Forecast Date");
            ForecastEntry.CalcSums("Forecast Quantity (Base)");
            if ForecastEntry."Forecast Quantity (Base)" <> 0 then
              ForecastExist := true
            else
              ForecastEntry.SetRange("Forecast Date",ExcludeForecastBefore,ForecastEntry."Forecast Date" - 1);
          until (not ForecastEntry.Find('+')) or ForecastExist;

        if not ForecastExist then begin
          if ExcludeForecastBefore > OrderDate then
            ForecastEntry.SetRange("Forecast Date",ExcludeForecastBefore,ToDate)
          else
            ForecastEntry.SetRange("Forecast Date",OrderDate + 1,ToDate);
          if ForecastEntry.Find('-') then
            repeat
              ForecastEntry.SetRange("Forecast Date",ForecastEntry."Forecast Date");
              ForecastEntry.CalcSums("Forecast Quantity (Base)");
              if ForecastEntry."Forecast Quantity (Base)" <> 0 then
                ForecastExist := true
              else
                ForecastEntry.SetRange("Forecast Date",ForecastEntry."Forecast Date" + 1,ToDate);
            until (not ForecastEntry.Find('-')) or ForecastExist
        end;
        exit(ForecastExist);
    end;

    local procedure FindReplishmentLocation(var ReplenishmentLocation: Code[10];var Item: Record Item): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        ReplenishmentLocation := '';
        SKU.SetCurrentkey("Item No.","Location Code","Variant Code");
        SKU.SetRange("Item No.",Item."No.");
        Item.Copyfilter("Location Filter",SKU."Location Code");
        Item.Copyfilter("Variant Filter",SKU."Variant Code");
        SKU.SetRange("Replenishment System",Item."replenishment system"::Purchase,Item."replenishment system"::"Prod. Order");
        SKU.SetFilter("Reordering Policy",'<>%1',SKU."reordering policy"::" ");
        if SKU.Find('-') then
          if SKU.Next = 0 then
            ReplenishmentLocation := SKU."Location Code";
        exit(ReplenishmentLocation <> '');
    end;

    local procedure FindCombination(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile";var Item: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
        Location: Record Location;
        PlanningGetParameters: Codeunit "Planning-Get Parameters";
        WMSManagement: Codeunit "WMS Management";
        VersionManagement: Codeunit VersionManagement;
        State: Option DemandExist,SupplyExist,BothExist;
        DemandBool: Boolean;
        SupplyBool: Boolean;
        TransitLocation: Boolean;
    begin
        CreateTempSKUForComponentsLocation(Item);

        SKU.SetCurrentkey("Item No.","Location Code","Variant Code");
        SKU.SetRange("Item No.",Item."No.");
        Item.Copyfilter("Variant Filter",SKU."Variant Code");
        Item.Copyfilter("Location Filter",SKU."Location Code");

        if SKU.FindSet then begin
          repeat
            PlanningGetParameters.AdjustInvalidSettings(SKU);
            if (SKU."Safety Stock Quantity" <> 0) or (SKU."Reorder Point" <> 0) or
               (SKU."Reorder Quantity" <> 0) or (SKU."Maximum Inventory" <> 0)
            then begin
              TempSKU.TransferFields(SKU);
              if TempSKU.Insert then ;
              while (TempSKU."Replenishment System" = TempSKU."replenishment system"::Transfer) and
                    (TempSKU."Reordering Policy" <> TempSKU."reordering policy"::" ")
              do begin
                TempSKU."Location Code" := TempSKU."Transfer-from Code";
                TransferPlanningParameters(TempSKU);
                if TempSKU."Reordering Policy" <> TempSKU."reordering policy"::" " then
                  InsertTempSKU;
              end;
            end;
          until SKU.Next = 0;
        end else
          if (not InvtSetup."Location Mandatory") and (ManufacturingSetup."Components at Location" = '') then
            CreateTempSKUForLocation(
              Item."No.",
              WMSManagement.GetLastOperationLocationCode(
                Item."Routing No.",VersionManagement.GetRtngVersion(Item."Routing No.",SupplyInvtProfile."Due Date",true)));

        Clear(DemandInvtProfile);
        Clear(SupplyInvtProfile);
        DemandInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");
        SupplyInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");
        DemandInvtProfile.SetRange(IsSupply,false);
        SupplyInvtProfile.SetRange(IsSupply,true);
        DemandBool := DemandInvtProfile.Find('-');
        SupplyBool := SupplyInvtProfile.Find('-');

        while DemandBool or SupplyBool do begin
          if  DemandBool then begin
            TempSKU."Item No." := DemandInvtProfile."Item No.";
            TempSKU."Variant Code" := DemandInvtProfile."Variant Code";
            TempSKU."Location Code" := DemandInvtProfile."Location Code";
            OnFindCombinationAfterAssignTempSKU(TempSKU,DemandInvtProfile);
          end else begin
            TempSKU."Item No." := SupplyInvtProfile."Item No.";
            TempSKU."Variant Code" := SupplyInvtProfile."Variant Code";
            TempSKU."Location Code" := SupplyInvtProfile."Location Code";
            OnFindCombinationAfterAssignTempSKU(TempSKU,SupplyInvtProfile);
          end;

          if DemandBool and SupplyBool then
            State := State::BothExist
          else
            if DemandBool then
              State := State::DemandExist
            else
              State := State::SupplyExist;

          case State of
            State::DemandExist:
              DemandBool := FindNextSKU(DemandInvtProfile);
            State::SupplyExist:
              SupplyBool := FindNextSKU(SupplyInvtProfile);
            State::BothExist:
              if DemandInvtProfile."Variant Code" = SupplyInvtProfile."Variant Code" then begin
                if DemandInvtProfile."Location Code" = SupplyInvtProfile."Location Code" then begin
                  DemandBool := FindNextSKU(DemandInvtProfile);
                  SupplyBool := FindNextSKU(SupplyInvtProfile);
                end else
                  if DemandInvtProfile."Location Code" < SupplyInvtProfile."Location Code" then
                    DemandBool := FindNextSKU(DemandInvtProfile)
                  else
                    SupplyBool := FindNextSKU(SupplyInvtProfile)
              end else
                if DemandInvtProfile."Variant Code" < SupplyInvtProfile."Variant Code" then
                  DemandBool := FindNextSKU(DemandInvtProfile)
                else
                  SupplyBool := FindNextSKU(SupplyInvtProfile);
          end;

          if TempSKU."Location Code" <> '' then begin
            Location.Get(TempSKU."Location Code"); // Assert: will fail if location cannot be found.
            TransitLocation := Location."Use As In-Transit";
          end else
            TransitLocation := false; // Variant SKU only - no location code involved.

          if not TransitLocation then begin
            TransferPlanningParameters(TempSKU);
            InsertTempSKU;
            while (TempSKU."Replenishment System" = TempSKU."replenishment system"::Transfer) and
                  (TempSKU."Reordering Policy" <> TempSKU."reordering policy"::" ")
            do begin
              TempSKU."Location Code" := TempSKU."Transfer-from Code";
              TransferPlanningParameters(TempSKU);
              if TempSKU."Reordering Policy" <> TempSKU."reordering policy"::" " then
                InsertTempSKU;
            end;
          end;
        end;

        Item.Copyfilter("Location Filter",TempSKU."Location Code");
        Item.Copyfilter("Variant Filter",TempSKU."Variant Code");
    end;

    local procedure InsertTempSKU()
    var
        SKU2: Record "Stockkeeping Unit";
        PlanningGetParameters: Codeunit "Planning-Get Parameters";
    begin
        with TempSKU do
          if not Find('=') then begin
            PlanningGetParameters.SetLotForLot;
            PlanningGetParameters.AtSKU(SKU2,"Item No.","Variant Code","Location Code");
            TempSKU := SKU2;
            if "Reordering Policy" <> "reordering policy"::" " then
              Insert;
          end;
    end;

    local procedure FindNextSKU(var InventoryProfile: Record "Inventory Profile"): Boolean
    begin
        TempSKU."Variant Code" := InventoryProfile."Variant Code";
        TempSKU."Location Code" := InventoryProfile."Location Code";

        InventoryProfile.SetRange("Variant Code",TempSKU."Variant Code");
        InventoryProfile.SetRange("Location Code",TempSKU."Location Code");
        InventoryProfile.FindLast;
        InventoryProfile.SetRange("Variant Code");
        InventoryProfile.SetRange("Location Code");
        exit(InventoryProfile.Next <> 0);
    end;

    local procedure TransferPlanningParameters(var SKU: Record "Stockkeeping Unit")
    var
        SKU2: Record "Stockkeeping Unit";
        PlanningGetParameters: Codeunit "Planning-Get Parameters";
    begin
        PlanningGetParameters.AtSKU(SKU2,SKU."Item No.",SKU."Variant Code",SKU."Location Code");
        SKU := SKU2;
    end;

    local procedure DeleteTracking(var SKU: Record "Stockkeeping Unit";ToDate: Date;var SupplyInventoryProfile: Record "Inventory Profile")
    var
        Item: Record Item;
        ReservEntry1: Record "Reservation Entry";
        ResEntryWasDeleted: Boolean;
    begin
        ActionMsgEntry.SetCurrentkey("Reservation Entry");

        with ReservEntry do begin
          Reset;
          SetCurrentkey("Item No.","Variant Code","Location Code");
          SetRange("Item No.",SKU."Item No.");
          SetRange("Variant Code",SKU."Variant Code");
          SetRange("Location Code",SKU."Location Code");
          SetFilter("Reservation Status",'<>%1',"reservation status"::Prospect);
          if Find('-') then
            repeat
              Item.Get("Item No.");
              if not IsTrkgForSpecialOrderOrDropShpt(ReservEntry) then begin
                if ShouldDeleteReservEntry(ReservEntry,ToDate) then begin
                  ResEntryWasDeleted := true;
                  if ("Source Type" = Database::"Item Ledger Entry") and
                     ("Reservation Status" = "reservation status"::Tracking)
                  then
                    if ReservEntry1.Get("Entry No.",not Positive) then
                      ReservEntry1.Delete;
                  Delete;
                end else
                  ResEntryWasDeleted := CloseTracking(ReservEntry,SupplyInventoryProfile,ToDate);

                if ResEntryWasDeleted then begin
                  ActionMsgEntry.SetRange("Reservation Entry","Entry No.");
                  ActionMsgEntry.DeleteAll;
                end;
              end;
            until Next = 0;
        end;
    end;

    local procedure ShouldDeleteReservEntry(ReservEntry: Record "Reservation Entry";ToDate: Date): Boolean
    var
        Item: Record Item;
        IsReservedForProdComponent: Boolean;
    begin
        IsReservedForProdComponent := ReservedForProdComponent(ReservEntry);
        if IsReservedForProdComponent and IsProdOrderPlanned(ReservEntry) and
           (ReservEntry."Reservation Status" > ReservEntry."reservation status"::Tracking)
        then
          exit(false);

        Item.Get(ReservEntry."Item No.");
        with ReservEntry do
          exit(
            (("Reservation Status" <> "reservation status"::Reservation) and
             ("Expected Receipt Date" <= ToDate) and
             ("Shipment Date" <= ToDate)) or
            ((Binding = Binding::"Order-to-Order") and ("Shipment Date" <= ToDate) and
             (Item."Manufacturing Policy" = Item."manufacturing policy"::"Make-to-Stock") and
             (Item."Replenishment System" = Item."replenishment system"::"Prod. Order") and
             (not IsReservedForProdComponent)));
    end;

    local procedure IsProdOrderPlanned(ReservationEntry: Record "Reservation Entry"): Boolean
    var
        ProdOrderComp: Record "Prod. Order Component";
        RequisitionLine: Record "Requisition Line";
    begin
        if not ProdOrderComp.Get(
             ReservationEntry."Source Subtype",ReservationEntry."Source ID",
             ReservationEntry."Source Prod. Order Line",ReservationEntry."Source Ref. No.")
        then
          exit;

        RequisitionLine.SetRefFilter(
          RequisitionLine."ref. order type"::"Prod. Order",ProdOrderComp.Status,
          ProdOrderComp."Prod. Order No.",ProdOrderComp."Prod. Order Line No.");
        RequisitionLine.SetRange("Operation No.",'');

        exit(not RequisitionLine.IsEmpty);
    end;

    local procedure RemoveOrdinaryInventory(var Supply: Record "Inventory Profile")
    var
        Supply2: Record "Inventory Profile";
    begin
        Supply2.Copy(Supply);
        with Supply do begin
          SetRange(IsSupply);
          SetRange("Source Type",Database::"Item Ledger Entry");
          SetFilter(Binding,'<>%1',Supply2.Binding::"Order-to-Order");
          DeleteAll;
          Copy(Supply2);
        end;
    end;

    local procedure UnfoldItemTracking(var ParentInvProfile: Record "Inventory Profile";var ChildInvProfile: Record "Inventory Profile")
    begin
        ParentInvProfile.Reset;
        TempItemTrkgEntry.Reset;
        if not TempItemTrkgEntry.Find('-') then
          exit;
        ParentInvProfile.SetFilter("Source Type",'<>%1',Database::"Item Ledger Entry");
        ParentInvProfile.SetRange("Tracking Reference",0);
        if ParentInvProfile.Find('-') then
          repeat
            TempItemTrkgEntry.Reset;
            TempItemTrkgEntry.SetSourceFilter(
              ParentInvProfile."Source Type",ParentInvProfile."Source Order Status",ParentInvProfile."Source ID",
              ParentInvProfile."Source Ref. No.",false);
            TempItemTrkgEntry.SetSourceFilter2(ParentInvProfile."Source Batch Name",ParentInvProfile."Source Prod. Order Line");
            if TempItemTrkgEntry.Find('-') then begin
              if ParentInvProfile.IsSupply and
                 (ParentInvProfile.Binding <> ParentInvProfile.Binding::"Order-to-Order")
              then
                ParentInvProfile."Planning Flexibility" := ParentInvProfile."planning flexibility"::None;
              repeat
                ChildInvProfile := ParentInvProfile;
                ChildInvProfile."Line No." := NextLineNo;
                ChildInvProfile."Tracking Reference" := ParentInvProfile."Line No.";
                ChildInvProfile."Lot No." := TempItemTrkgEntry."Lot No.";
                ChildInvProfile."Serial No." := TempItemTrkgEntry."Serial No.";
                ChildInvProfile."Expiration Date" := TempItemTrkgEntry."Expiration Date";
                ChildInvProfile.TransferQtyFromItemTrgkEntry(TempItemTrkgEntry);
                OnAfterTransToChildInvProfile(TempItemTrkgEntry,ChildInvProfile);
                ChildInvProfile.Insert;
                ParentInvProfile.ReduceQtyByItemTracking(ChildInvProfile);
                ParentInvProfile.Modify;
              until TempItemTrkgEntry.Next = 0;
            end;
          until ParentInvProfile.Next = 0;
    end;

    local procedure MatchAttributes(var SupplyInvtProfile: Record "Inventory Profile";var DemandInvtProfile: Record "Inventory Profile";RespectPlanningParm: Boolean)
    var
        xDemandInvtProfile: Record "Inventory Profile";
        xSupplyInvtProfile: Record "Inventory Profile";
        NewSupplyDate: Date;
        SupplyExists: Boolean;
        CanBeRescheduled: Boolean;
        ItemInventoryExists: Boolean;
    begin
        xDemandInvtProfile.CopyFilters(DemandInvtProfile);
        xSupplyInvtProfile.CopyFilters(SupplyInvtProfile);
        ItemInventoryExists := CheckItemInventoryExists(SupplyInvtProfile);
        DemandInvtProfile.SetRange("Attribute Priority",1,7);
        DemandInvtProfile.SetFilter("Source Type",'<>%1',Database::"Requisition Line");
        if DemandInvtProfile.FindSet(true) then
          repeat
            SupplyInvtProfile.SetRange(Binding,DemandInvtProfile.Binding);
            SupplyInvtProfile.SetRange("Primary Order Status",DemandInvtProfile."Primary Order Status");
            SupplyInvtProfile.SetRange("Primary Order No.",DemandInvtProfile."Primary Order No.");
            SupplyInvtProfile.SetRange("Primary Order Line",DemandInvtProfile."Primary Order Line");
            if (DemandInvtProfile."Ref. Order Type" = DemandInvtProfile."ref. order type"::Assembly) and
               (DemandInvtProfile.Binding = DemandInvtProfile.Binding::"Order-to-Order") and
               (DemandInvtProfile."Primary Order No." = '')
            then
              SupplyInvtProfile.SetRange("Source Prod. Order Line",DemandInvtProfile."Source Prod. Order Line");

            SupplyInvtProfile.SetTrackingFilter(DemandInvtProfile);
            SupplyExists := SupplyInvtProfile.FindFirst;
            OnBeforeMatchAttributesDemandApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists);
            while (DemandInvtProfile."Untracked Quantity" > 0) and
                  (not ApplyUntrackedQuantityToItemInventory(SupplyExists,ItemInventoryExists))
            do begin
              OnStartOfMatchAttributesDemandApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists);
              if SupplyExists and (DemandInvtProfile.Binding = DemandInvtProfile.Binding::"Order-to-Order") then begin
                NewSupplyDate := SupplyInvtProfile."Due Date";
                CanBeRescheduled :=
                  (SupplyInvtProfile."Fixed Date" = 0D) and
                  ((SupplyInvtProfile."Due Date" <> DemandInvtProfile."Due Date") or
                   (SupplyInvtProfile."Due Time" <> DemandInvtProfile."Due Time"));
                if CanBeRescheduled then
                  if (SupplyInvtProfile."Due Date" > DemandInvtProfile."Due Date") or
                     (SupplyInvtProfile."Due Time" > DemandInvtProfile."Due Time")
                  then
                    CanBeRescheduled := CheckScheduleIn(SupplyInvtProfile,DemandInvtProfile."Due Date",NewSupplyDate,false)
                  else
                    CanBeRescheduled := CheckScheduleOut(SupplyInvtProfile,DemandInvtProfile."Due Date",NewSupplyDate,false);
                if CanBeRescheduled and
                   ((NewSupplyDate <> SupplyInvtProfile."Due Date") or (SupplyInvtProfile."Planning Level Code" > 0))
                then begin
                  Reschedule(SupplyInvtProfile,DemandInvtProfile."Due Date",DemandInvtProfile."Due Time");
                  SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date";
                end;
              end;
              if not SupplyExists or (SupplyInvtProfile."Due Date" > DemandInvtProfile."Due Date") then begin
                InitSupply(SupplyInvtProfile,DemandInvtProfile."Untracked Quantity",DemandInvtProfile."Due Date");
                TransferAttributes(SupplyInvtProfile,DemandInvtProfile);
                SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date";
                SupplyInvtProfile.Insert;
                SupplyExists := true;
              end;

              if DemandInvtProfile.Binding = DemandInvtProfile.Binding::"Order-to-Order" then
                if (DemandInvtProfile."Untracked Quantity" > SupplyInvtProfile."Untracked Quantity") and
                   (SupplyInvtProfile."Due Date" <= DemandInvtProfile."Due Date")
                then
                  IncreaseQtyToMeetDemand(SupplyInvtProfile,DemandInvtProfile,false,RespectPlanningParm,false);

              if SupplyInvtProfile."Untracked Quantity" < DemandInvtProfile."Untracked Quantity" then
                SupplyExists := CloseSupply(DemandInvtProfile,SupplyInvtProfile)
              else
                CloseDemand(DemandInvtProfile,SupplyInvtProfile);
              OnEndMatchAttributesDemandApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists);
            end;
          until DemandInvtProfile.Next = 0;

        // Neutralize or generalize excess Order-To-Order Supply
        SupplyInvtProfile.CopyFilters(xSupplyInvtProfile);
        SupplyInvtProfile.SetRange(Binding,SupplyInvtProfile.Binding::"Order-to-Order");
        SupplyInvtProfile.SetFilter("Untracked Quantity",'>=0');
        if SupplyInvtProfile.FindSet then
          repeat
            if SupplyInvtProfile."Untracked Quantity" > 0 then begin
              if DecreaseQty(SupplyInvtProfile,SupplyInvtProfile."Untracked Quantity") then begin
                // Assertion: New specific Supply shall match the Demand exactly and must not update
                // the Planning Line again since that will double the derived demand in case of transfers
                if SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::New then
                  SupplyInvtProfile.FieldError("Action Message");
                MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::Exploded,Scheduledirection::Backward)
              end else begin
                // Evaluate excess supply
                if TempSKU."Include Inventory" then begin
                  // Release the remaining Untracked Quantity
                  SupplyInvtProfile.Binding := SupplyInvtProfile.Binding::" ";
                  SupplyInvtProfile."Primary Order Type" := 0;
                  SupplyInvtProfile."Primary Order Status" := 0;
                  SupplyInvtProfile."Primary Order No." := '';
                  SupplyInvtProfile."Primary Order Line" := 0;
                  SetAttributePriority(SupplyInvtProfile);
                end else
                  SupplyInvtProfile."Untracked Quantity" := 0;
              end;
              // Ensure that the directly allocated quantity will not be part of Projected Inventory
              if SupplyInvtProfile."Untracked Quantity" <> 0 then begin
                UpdateQty(SupplyInvtProfile,SupplyInvtProfile."Untracked Quantity");
                SupplyInvtProfile.Modify;
              end;
            end;
            if SupplyInvtProfile."Untracked Quantity" = 0 then
              SupplyInvtProfile.Delete;
          until SupplyInvtProfile.Next = 0;

        DemandInvtProfile.CopyFilters(xDemandInvtProfile);
        SupplyInvtProfile.CopyFilters(xSupplyInvtProfile);
    end;

    local procedure MatchReservationEntries(var FromTrkgReservEntry: Record "Reservation Entry";var ToTrkgReservEntry: Record "Reservation Entry")
    begin
        if (FromTrkgReservEntry."Reservation Status" = FromTrkgReservEntry."reservation status"::Reservation) xor
           (ToTrkgReservEntry."Reservation Status" = ToTrkgReservEntry."reservation status"::Reservation)
        then begin
          SwitchTrackingToReservationStatus(FromTrkgReservEntry);
          SwitchTrackingToReservationStatus(ToTrkgReservEntry);
        end;
    end;

    local procedure SwitchTrackingToReservationStatus(var ReservEntry: Record "Reservation Entry")
    begin
        if ReservEntry."Reservation Status" = ReservEntry."reservation status"::Tracking then
          ReservEntry."Reservation Status" := ReservEntry."reservation status"::Reservation;
    end;

    local procedure PlanItem(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile";PlanningStartDate: Date;ToDate: Date;RespectPlanningParm: Boolean)
    var
        InvChangeReminder: Record "Inventory Profile" temporary;
        PlanningGetParameters: Codeunit "Planning-Get Parameters";
        OriginalSupplyDate: Date;
        NewSupplyDate: Date;
        LatestBucketStartDate: Date;
        LastProjectedInventory: Decimal;
        LastAvailableInventory: Decimal;
        SupplyWithinLeadtime: Decimal;
        DemandExists: Boolean;
        SupplyExists: Boolean;
        PlanThisSKU: Boolean;
        ROPHasBeenCrossed: Boolean;
        NewSupplyHasTakenOver: Boolean;
        WeAreSureThatDatesMatch: Boolean;
        IsReorderPointPlanning: Boolean;
        IsExceptionOrder: Boolean;
        SupplyAvailableWithinLeadTime: Decimal;
        NeedOfPublishSurplus: Boolean;
        InitialProjectedInventory: Decimal;
    begin
        ReqLine.Reset;
        ReqLine.SetRange("Worksheet Template Name",CurrTemplateName);
        ReqLine.SetRange("Journal Batch Name",CurrWorksheetName);
        ReqLine.LockTable;
        if ReqLine.FindLast then;

        if PlanningResilicency then
          ReqLine.SetResiliencyOn(CurrTemplateName,CurrWorksheetName,TempSKU."Item No.");

        DemandInvtProfile.Reset;
        SupplyInvtProfile.Reset;
        DemandInvtProfile.SetRange(IsSupply,false);
        SupplyInvtProfile.SetRange(IsSupply,true);

        UpdateTempSKUTransferLevels;

        TempSKU.SetCurrentkey("Item No.","Transfer-Level Code");
        DemandInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");
        SupplyInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");
        InvChangeReminder.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date");

        SupplyInvtProfile.SetRange("Drop Shipment",false);
        SupplyInvtProfile.SetRange("Special Order",false);
        DemandInvtProfile.SetRange("Drop Shipment",false);
        DemandInvtProfile.SetRange("Special Order",false);

        ExceedROPqty := 0.000000001;

        if TempSKU.Find('-') then
          repeat
            IsReorderPointPlanning :=
              (TempSKU."Reorder Point" > TempSKU."Safety Stock Quantity") or
              (TempSKU."Reordering Policy" = TempSKU."reordering policy"::"Maximum Qty.") or
              (TempSKU."Reordering Policy" = TempSKU."reordering policy"::"Fixed Reorder Qty.");

            BucketSize := TempSKU."Time Bucket";
            // Minimum bucket size is 1 day:
            if CalcDate(BucketSize) <= Today then
              Evaluate(BucketSize,'<1D>');
            BucketSizeInDays := CalcDate(BucketSize) - Today;

            FilterDemandSupplyRelatedToSKU(DemandInvtProfile);
            FilterDemandSupplyRelatedToSKU(SupplyInvtProfile);

            DampenersDays := PlanningGetParameters.CalcDampenerDays(TempSKU);
            DampenerQty := PlanningGetParameters.CalcDampenerQty(TempSKU);
            OverflowLevel := PlanningGetParameters.CalcOverflowLevel(TempSKU);

            if not TempSKU."Include Inventory" then
              RemoveOrdinaryInventory(SupplyInvtProfile);
            InsertSafetyStockDemands(DemandInvtProfile,PlanningStartDate);
            UpdatePriorities(SupplyInvtProfile,IsReorderPointPlanning,ToDate);

            DemandExists := DemandInvtProfile.FindSet;
            SupplyExists := SupplyInvtProfile.FindSet;
            LatestBucketStartDate := PlanningStartDate;
            LastProjectedInventory := 0;
            LastAvailableInventory := 0;
            PlanThisSKU := CheckPlanSKU(TempSKU,DemandExists,SupplyExists,IsReorderPointPlanning);

            if PlanThisSKU then begin
              PrepareDemand(DemandInvtProfile,IsReorderPointPlanning,ToDate);
              PlanThisSKU :=
                not (DemandMatchedSupply(DemandInvtProfile,SupplyInvtProfile,TempSKU) and
                     DemandMatchedSupply(SupplyInvtProfile,DemandInvtProfile,TempSKU));
            end;
            if PlanThisSKU then begin
              // Preliminary clean of tracking
              if DemandExists or SupplyExists then
                DeleteTracking(TempSKU,ToDate,SupplyInvtProfile);

              MatchAttributes(SupplyInvtProfile,DemandInvtProfile,RespectPlanningParm);

              // Calculate initial inventory
              PlanItemCalcInitialInventory(
                DemandInvtProfile,SupplyInvtProfile,PlanningStartDate,DemandExists,SupplyExists,LastProjectedInventory);

              OnBeforePrePlanDateDemandProc(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);
              while DemandExists do begin
                LastProjectedInventory -= DemandInvtProfile."Remaining Quantity (Base)";
                LastAvailableInventory -= DemandInvtProfile."Untracked Quantity";
                DemandInvtProfile."Untracked Quantity" := 0;
                DemandInvtProfile.Modify;
                DemandExists := DemandInvtProfile.Next <> 0;
              end;

              OnBeforePrePlanDateSupplyProc(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);
              while SupplyExists do begin
                LastProjectedInventory += SupplyInvtProfile."Remaining Quantity (Base)";
                LastAvailableInventory += SupplyInvtProfile."Untracked Quantity";
                SupplyInvtProfile."Planning Flexibility" := SupplyInvtProfile."planning flexibility"::None;
                SupplyInvtProfile.Modify;
                SupplyExists := SupplyInvtProfile.Next <> 0;
              end;
              OnAfterPrePlanDateSupplyProc(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);

              if LastAvailableInventory < 0 then begin // Emergency order
                // Insert Supply
                InitSupply(SupplyInvtProfile,-LastAvailableInventory,PlanningStartDate - 1);
                SupplyInvtProfile."Planning Flexibility" := SupplyInvtProfile."planning flexibility"::None;
                SupplyInvtProfile.Insert;
                MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::Exploded,Scheduledirection::Backward);
                Track(SupplyInvtProfile,DemandInvtProfile,true,false,SupplyInvtProfile.Binding::" ");
                LastProjectedInventory += SupplyInvtProfile."Remaining Quantity (Base)";
                LastAvailableInventory += SupplyInvtProfile."Untracked Quantity";
                PlanningTransparency.LogSurplus(
                  SupplyInvtProfile."Line No.",SupplyInvtProfile."Line No.",0,'',
                  SupplyInvtProfile."Untracked Quantity",Surplustype::EmergencyOrder);
                SupplyInvtProfile."Untracked Quantity" := 0;
                if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
                  ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
                PlanningTransparency.PublishSurplus(SupplyInvtProfile,TempSKU,ReqLine,TempTrkgReservEntry);
                DummyInventoryProfileTrackBuffer."Warning Level" := DummyInventoryProfileTrackBuffer."warning level"::Emergency;
                PlanningTransparency.LogWarning(
                  0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                  StrSubstNo(
                    Text006,DummyInventoryProfileTrackBuffer."Warning Level",-SupplyInvtProfile."Remaining Quantity (Base)",
                    PlanningStartDate));
                SupplyInvtProfile.Delete;
              end;

              if LastAvailableInventory < TempSKU."Safety Stock Quantity" then begin // Initial Safety Stock Warning
                SupplyAvailableWithinLeadTime := SumUpAvailableSupply(SupplyInvtProfile,PlanningStartDate,PlanningStartDate);
                InitialProjectedInventory := LastAvailableInventory + SupplyAvailableWithinLeadTime;
                if InitialProjectedInventory < TempSKU."Safety Stock Quantity" then
                  CreateSupplyForInitialSafetyStockWarning(
                    SupplyInvtProfile,
                    InitialProjectedInventory,LastProjectedInventory,LastAvailableInventory,
                    PlanningStartDate,RespectPlanningParm,IsReorderPointPlanning);
              end;

              if IsReorderPointPlanning then begin
                SupplyWithinLeadtime :=
                  SumUpProjectedSupply(SupplyInvtProfile,PlanningStartDate,PlanningStartDate + BucketSizeInDays - 1);

                if LastProjectedInventory + SupplyWithinLeadtime <= TempSKU."Reorder Point" then begin
                  InitSupply(SupplyInvtProfile,0,0D);
                  if LastAvailableInventory < TempSKU."Safety Stock Quantity" then
                    CreateSupplyForward(SupplyInvtProfile,PlanningStartDate,
                      TempSKU."Safety Stock Quantity" - LastAvailableInventory + LastProjectedInventory,
                      NewSupplyHasTakenOver,DemandInvtProfile."Due Date")
                  else
                    CreateSupplyForward(
                      SupplyInvtProfile,PlanningStartDate,LastProjectedInventory,NewSupplyHasTakenOver,DemandInvtProfile."Due Date");

                  NeedOfPublishSurplus := SupplyInvtProfile."Due Date" > ToDate;
                end;
              end;

              // Common balancing
              DemandInvtProfile.SetRange("Due Date",PlanningStartDate,ToDate);

              DemandExists := DemandInvtProfile.FindSet;
              DemandInvtProfile.SetRange("Due Date");

              SupplyInvtProfile.SetFilter("Untracked Quantity",'>=0');
              SupplyExists := SupplyInvtProfile.FindSet;

              SupplyInvtProfile.SetRange("Untracked Quantity");
              SupplyInvtProfile.SetRange("Due Date");

              if not SupplyExists then
                if not SupplyInvtProfile.IsEmpty then begin
                  SupplyInvtProfile.SetRange("Due Date",PlanningStartDate,ToDate);
                  SupplyExists := SupplyInvtProfile.FindSet;
                  SupplyInvtProfile.SetRange("Due Date");
                  if NeedOfPublishSurplus and not (DemandExists or SupplyExists) then begin
                    Track(SupplyInvtProfile,DemandInvtProfile,true,false,SupplyInvtProfile.Binding::" ");
                    PlanningTransparency.PublishSurplus(SupplyInvtProfile,TempSKU,ReqLine,TempTrkgReservEntry);
                  end;
                end;

              if IsReorderPointPlanning then
                ChkInitialOverflow(DemandInvtProfile,SupplyInvtProfile,
                  OverflowLevel,LastProjectedInventory,PlanningStartDate,ToDate);

              CheckSupplyWithSKU(SupplyInvtProfile,TempSKU);

              LotAccumulationPeriodStartDate := 0D;
              NextState := Nextstate::StartOver;
              while PlanThisSKU do
                case NextState of
                  Nextstate::StartOver:
                    begin
                      if DemandExists and (DemandInvtProfile."Source Type" = Database::"Transfer Line") then
                        while CancelTransfer(SupplyInvtProfile,DemandInvtProfile,DemandExists) do
                          DemandExists := DemandInvtProfile.Next <> 0;

                      OnBeforePlanStepSettingOnStartOver(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);

                      if DemandExists then
                        if DemandInvtProfile."Untracked Quantity" = 0 then
                          NextState := Nextstate::CloseDemand
                        else
                          if SupplyExists then
                            NextState := Nextstate::MatchDates
                          else
                            NextState := Nextstate::CreateSupply
                      else
                        if SupplyExists then
                          NextState := Nextstate::ReduceSupply
                        else
                          NextState := Nextstate::CloseLoop;
                    end;
                  Nextstate::MatchDates:
                    begin
                      OriginalSupplyDate := SupplyInvtProfile."Due Date";
                      NewSupplyDate := SupplyInvtProfile."Due Date";
                      WeAreSureThatDatesMatch := false;

                      if DemandInvtProfile."Due Date" < SupplyInvtProfile."Due Date" then begin
                        if CheckScheduleIn(SupplyInvtProfile,DemandInvtProfile."Due Date",NewSupplyDate,true) then
                          WeAreSureThatDatesMatch := true
                        else
                          NextState := Nextstate::CreateSupply;
                      end else
                        if DemandInvtProfile."Due Date" > SupplyInvtProfile."Due Date" then begin
                          if CheckScheduleOut(SupplyInvtProfile,DemandInvtProfile."Due Date",NewSupplyDate,true) then
                            WeAreSureThatDatesMatch := not ScheduleAllOutChangesSequence(SupplyInvtProfile,NewSupplyDate)
                          else
                            NextState := Nextstate::ReduceSupply;
                        end else
                          WeAreSureThatDatesMatch := true;

                      if WeAreSureThatDatesMatch and IsReorderPointPlanning then begin
                        // Now we know the final position on the timeline of the SupplyInvtProfile.
                        MaintainProjectedInv(
                          InvChangeReminder,NewSupplyDate,LastProjectedInventory,LatestBucketStartDate,ROPHasBeenCrossed);
                        if ROPHasBeenCrossed then begin
                          CreateSupplyForward(SupplyInvtProfile,LatestBucketStartDate,
                            LastProjectedInventory,NewSupplyHasTakenOver,DemandInvtProfile."Due Date");
                          if NewSupplyHasTakenOver then begin
                            WeAreSureThatDatesMatch := false;
                            NextState := Nextstate::MatchDates;
                          end;
                        end;
                      end;

                      if WeAreSureThatDatesMatch then begin
                        if NewSupplyDate <> OriginalSupplyDate then
                          Reschedule(SupplyInvtProfile,NewSupplyDate,0T);
                        SupplyInvtProfile.TestField("Due Date",NewSupplyDate);
                        SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date"; // We note the latest possible date on the SupplyInvtProfile.
                        NextState := Nextstate::MatchQty;
                      end;
                    end;
                  Nextstate::MatchQty:
                    PlanItemNextStateMatchQty(
                      DemandInvtProfile,SupplyInvtProfile,LastProjectedInventory,IsReorderPointPlanning,RespectPlanningParm);
                  Nextstate::CreateSupply:
                    begin
                      WeAreSureThatDatesMatch := true; // We assume this is true at this point.....
                      if FromLotAccumulationPeriodStartDate(LotAccumulationPeriodStartDate,DemandInvtProfile."Due Date") then
                        NewSupplyDate := LotAccumulationPeriodStartDate
                      else begin
                        NewSupplyDate := DemandInvtProfile."Due Date";
                        LotAccumulationPeriodStartDate := 0D;
                      end;
                      if (NewSupplyDate >= LatestBucketStartDate) and IsReorderPointPlanning then
                        MaintainProjectedInv(
                          InvChangeReminder,NewSupplyDate,LastProjectedInventory,LatestBucketStartDate,ROPHasBeenCrossed);
                      if ROPHasBeenCrossed then begin
                        CreateSupplyForward(SupplyInvtProfile,LatestBucketStartDate,LastProjectedInventory,
                          NewSupplyHasTakenOver,DemandInvtProfile."Due Date");
                        if NewSupplyHasTakenOver then begin
                          SupplyExists := true;
                          WeAreSureThatDatesMatch := false;
                          NextState := Nextstate::MatchDates;
                        end;
                      end;

                      if WeAreSureThatDatesMatch then begin
                        IsExceptionOrder := IsReorderPointPlanning;
                        CreateSupply(SupplyInvtProfile,DemandInvtProfile,
                          LastProjectedInventory +
                          QtyFromPendingReminders(InvChangeReminder,DemandInvtProfile."Due Date",LatestBucketStartDate) -
                          DemandInvtProfile."Remaining Quantity (Base)",
                          IsExceptionOrder,RespectPlanningParm);
                        SupplyInvtProfile."Due Date" := NewSupplyDate;
                        SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date"; // We note the latest possible date on the SupplyInvtProfile.
                        SupplyExists := true;
                        if IsExceptionOrder then begin
                          DummyInventoryProfileTrackBuffer."Warning Level" :=
                            DummyInventoryProfileTrackBuffer."warning level"::Exception;
                          PlanningTransparency.LogWarning(
                            SupplyInvtProfile."Line No.",ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                            StrSubstNo(Text007,DummyInventoryProfileTrackBuffer."Warning Level",
                              TempSKU.FieldCaption("Safety Stock Quantity"),TempSKU."Safety Stock Quantity",
                              DemandInvtProfile."Due Date"));
                        end;
                        NextState := Nextstate::MatchQty;
                      end;
                    end;
                  Nextstate::ReduceSupply:
                    begin
                      if IsReorderPointPlanning and (SupplyInvtProfile."Due Date" >= LatestBucketStartDate) then
                        MaintainProjectedInv(
                          InvChangeReminder,SupplyInvtProfile."Due Date",LastProjectedInventory,LatestBucketStartDate,
                          ROPHasBeenCrossed);
                      NewSupplyHasTakenOver := false;
                      if ROPHasBeenCrossed then begin
                        CreateSupplyForward(
                          SupplyInvtProfile,LatestBucketStartDate,LastProjectedInventory,NewSupplyHasTakenOver,
                          SupplyInvtProfile."Due Date");
                        if NewSupplyHasTakenOver then begin
                          if DemandExists then
                            NextState := Nextstate::MatchDates
                          else
                            NextState := Nextstate::CloseSupply;
                        end;
                      end;

                      if not NewSupplyHasTakenOver then
                        if DecreaseQty(SupplyInvtProfile,SupplyInvtProfile."Untracked Quantity") then
                          NextState := Nextstate::CloseSupply
                        else begin
                          SupplyInvtProfile."Max. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
                          if DemandExists then
                            NextState := Nextstate::MatchQty
                          else
                            NextState := Nextstate::CloseSupply;
                        end;
                    end;
                  Nextstate::CloseDemand:
                    begin
                      if DemandInvtProfile."Due Date" < PlanningStartDate then
                        Error(Text001,DemandInvtProfile.FieldCaption("Due Date"));

                      if DemandInvtProfile."Order Relation" = DemandInvtProfile."order relation"::"Safety Stock" then begin
                        AllocateSafetystock(SupplyInvtProfile,DemandInvtProfile."Untracked Quantity",DemandInvtProfile."Due Date");
                        if IsReorderPointPlanning and (SupplyInvtProfile."Due Date" >= LatestBucketStartDate) then
                          PostInvChgReminder(InvChangeReminder,SupplyInvtProfile,true);
                      end else begin
                        if IsReorderPointPlanning then
                          PostInvChgReminder(InvChangeReminder,DemandInvtProfile,false);

                        if DemandInvtProfile."Untracked Quantity" <> 0 then begin
                          SupplyInvtProfile."Untracked Quantity" -= DemandInvtProfile."Untracked Quantity";

                          if SupplyInvtProfile."Untracked Quantity" < SupplyInvtProfile."Safety Stock Quantity" then
                            SupplyInvtProfile."Safety Stock Quantity" := SupplyInvtProfile."Untracked Quantity";

                          if SupplyInvtProfile."Action Message" <> SupplyInvtProfile."action message"::" " then
                            MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::"Line Created",Scheduledirection::Backward);
                          SupplyInvtProfile.Modify;

                          if IsReorderPointPlanning and (SupplyInvtProfile."Due Date" >= LatestBucketStartDate) then
                            PostInvChgReminder(InvChangeReminder,SupplyInvtProfile,true);

                          CheckSupplyAndTrack(DemandInvtProfile,SupplyInvtProfile);
                          SurplusType := PlanningTransparency.FindReason(DemandInvtProfile);
                          if SurplusType <> Surplustype::None then
                            PlanningTransparency.LogSurplus(
                              SupplyInvtProfile."Line No.",DemandInvtProfile."Line No.",
                              DemandInvtProfile."Source Type",DemandInvtProfile."Source ID",
                              DemandInvtProfile."Untracked Quantity",SurplusType);
                        end;
                      end;

                      DemandInvtProfile.Delete;

                      // If just handled demand was safetystock
                      if DemandInvtProfile."Order Relation" = DemandInvtProfile."order relation"::"Safety Stock" then
                        SupplyExists := SupplyInvtProfile.FindSet(true); // We assume that next profile is NOT safety stock

                      DemandExists := DemandInvtProfile.Next <> 0;
                      NextState := Nextstate::StartOver;
                    end;
                  Nextstate::CloseSupply:
                    begin
                      if DemandExists and (SupplyInvtProfile."Untracked Quantity" > 0) then begin
                        DemandInvtProfile."Untracked Quantity" -= SupplyInvtProfile."Untracked Quantity";
                        DemandInvtProfile.Modify;
                      end;

                      if DemandExists and
                         (DemandInvtProfile."Order Relation" = DemandInvtProfile."order relation"::"Safety Stock")
                      then begin
                        AllocateSafetystock(SupplyInvtProfile,SupplyInvtProfile."Untracked Quantity",DemandInvtProfile."Due Date");
                        if IsReorderPointPlanning and (SupplyInvtProfile."Due Date" >= LatestBucketStartDate) then
                          PostInvChgReminder(InvChangeReminder,SupplyInvtProfile,true);
                      end else begin
                        if IsReorderPointPlanning and (SupplyInvtProfile."Due Date" >= LatestBucketStartDate) then
                          PostInvChgReminder(InvChangeReminder,SupplyInvtProfile,false);

                        if SupplyInvtProfile."Action Message" <> SupplyInvtProfile."action message"::" " then
                          MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::Exploded,Scheduledirection::Backward)
                        else
                          SupplyInvtProfile.TestField("Planning Line No.",0);

                        if (SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::New) or
                           (SupplyInvtProfile."Due Date" <= ToDate)
                        then
                          if DemandExists then
                            Track(SupplyInvtProfile,DemandInvtProfile,false,false,SupplyInvtProfile.Binding)
                          else
                            Track(SupplyInvtProfile,DemandInvtProfile,true,false,SupplyInvtProfile.Binding::" ");
                        SupplyInvtProfile.Delete;

                        // Planning Transparency
                        if DemandExists then begin
                          SurplusType := PlanningTransparency.FindReason(DemandInvtProfile);
                          if SurplusType <> Surplustype::None then
                            PlanningTransparency.LogSurplus(SupplyInvtProfile."Line No.",DemandInvtProfile."Line No.",
                              DemandInvtProfile."Source Type",DemandInvtProfile."Source ID",
                              SupplyInvtProfile."Untracked Quantity",SurplusType);
                        end;
                        if SupplyInvtProfile."Planning Line No." <> 0 then begin
                          if SupplyInvtProfile."Safety Stock Quantity" > 0 then
                            PlanningTransparency.LogSurplus(SupplyInvtProfile."Line No.",SupplyInvtProfile."Line No.",0,'',
                              SupplyInvtProfile."Safety Stock Quantity",Surplustype::SafetyStock);
                          if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
                            ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
                          PlanningTransparency.PublishSurplus(SupplyInvtProfile,TempSKU,ReqLine,TempTrkgReservEntry);
                        end else
                          PlanningTransparency.CleanLog(SupplyInvtProfile."Line No.");
                      end;
                      if TempSKU."Maximum Order Quantity" > 0 then
                        CheckSupplyRemQtyAndUntrackQty(SupplyInvtProfile);
                      SupplyExists := SupplyInvtProfile.Next <> 0;
                      NextState := Nextstate::StartOver;
                    end;
                  Nextstate::CloseLoop:
                    begin
                      if IsReorderPointPlanning then
                        MaintainProjectedInv(
                          InvChangeReminder,ToDate,LastProjectedInventory,LatestBucketStartDate,ROPHasBeenCrossed);
                      if ROPHasBeenCrossed then begin
                        CreateSupplyForward(
                          SupplyInvtProfile,LatestBucketStartDate,LastProjectedInventory,NewSupplyHasTakenOver,
                          DemandInvtProfile."Due Date");
                        SupplyExists := true;
                        NextState := Nextstate::StartOver;
                      end else
                        PlanThisSKU := false;
                    end;
                  else
                    Error(Text001,SelectStr(NextState + 1,NextStateTxt));
                end;
            end;
          until TempSKU.Next = 0;
        SetAcceptAction(TempSKU."Item No.");
    end;

    local procedure PlanItemCalcInitialInventory(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile";PlanningStartDate: Date;var DemandExists: Boolean;var SupplyExists: Boolean;var LastProjectedInventory: Decimal)
    begin
        DemandInvtProfile.SetRange("Due Date",0D,PlanningStartDate - 1);
        SupplyInvtProfile.SetRange("Due Date",0D,PlanningStartDate - 1);
        DemandExists := DemandInvtProfile.FindSet;
        SupplyExists := SupplyInvtProfile.FindSet;
        OnBeforePrePlanDateApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);
        while DemandExists and SupplyExists do begin
          OnStartOfPrePlanDateApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);
          if DemandInvtProfile."Untracked Quantity" > SupplyInvtProfile."Untracked Quantity" then begin
            LastProjectedInventory += SupplyInvtProfile."Remaining Quantity (Base)";
            DemandInvtProfile."Untracked Quantity" -= SupplyInvtProfile."Untracked Quantity";
            FrozenZoneTrack(SupplyInvtProfile,DemandInvtProfile);
            SupplyInvtProfile."Untracked Quantity" := 0;
            SupplyInvtProfile.Modify;
            SupplyExists := SupplyInvtProfile.Next <> 0;
          end else begin
            LastProjectedInventory -= DemandInvtProfile."Remaining Quantity (Base)";
            SupplyInvtProfile."Untracked Quantity" -= DemandInvtProfile."Untracked Quantity";
            FrozenZoneTrack(DemandInvtProfile,SupplyInvtProfile);
            DemandInvtProfile."Untracked Quantity" := 0;
            DemandInvtProfile.Modify;
            DemandExists := DemandInvtProfile.Next <> 0;
            if not DemandExists then
              SupplyInvtProfile.Modify;
          end;
          OnEndOfPrePlanDateApplicationLoop(SupplyInvtProfile,DemandInvtProfile,SupplyExists,DemandExists);
        end;
    end;

    local procedure PlanItemNextStateMatchQty(var DemandInventoryProfile: Record "Inventory Profile";var SupplyInventoryProfile: Record "Inventory Profile";var LastProjectedInventory: Decimal;IsReorderPointPlanning: Boolean;RespectPlanningParm: Boolean)
    begin
        case true of
          SupplyInventoryProfile."Untracked Quantity" >= DemandInventoryProfile."Untracked Quantity":
            NextState := Nextstate::CloseDemand;
          ShallSupplyBeClosed(SupplyInventoryProfile,DemandInventoryProfile."Due Date",IsReorderPointPlanning):
            NextState := Nextstate::CloseSupply;
          IncreaseQtyToMeetDemand(
            SupplyInventoryProfile,DemandInventoryProfile,true,RespectPlanningParm,
            not SKURequiresLotAccumulation(TempSKU)):
            begin
              NextState := Nextstate::CloseDemand;
              // initial Safety Stock can be changed to normal, if we can increase qty for normal demand
              if (SupplyInventoryProfile."Order Relation" = SupplyInventoryProfile."order relation"::"Safety Stock") and
                 (DemandInventoryProfile."Order Relation" = DemandInventoryProfile."order relation"::Normal)
              then begin
                SupplyInventoryProfile."Order Relation" := SupplyInventoryProfile."order relation"::Normal;
                LastProjectedInventory -= TempSKU."Safety Stock Quantity";
              end;
            end;
          else begin
            NextState := Nextstate::CloseSupply;
            if TempSKU."Maximum Order Quantity" > 0 then
              LotAccumulationPeriodStartDate := SupplyInventoryProfile."Due Date";
          end;
        end;
    end;

    local procedure FilterDemandSupplyRelatedToSKU(var InventoryProfile: Record "Inventory Profile")
    begin
        InventoryProfile.SetRange("Item No.",TempSKU."Item No.");
        InventoryProfile.SetRange("Variant Code",TempSKU."Variant Code");
        InventoryProfile.SetRange("Location Code",TempSKU."Location Code");
    end;

    local procedure ScheduleForward(var SupplyInvtProfile: Record "Inventory Profile";StartingDate: Date)
    begin
        SupplyInvtProfile."Starting Date" := StartingDate;
        MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::"Routing Created",Scheduledirection::Forward);
        if (SupplyInvtProfile."Fixed Date" > 0D) and
           (SupplyInvtProfile."Fixed Date" < SupplyInvtProfile."Due Date")
        then
          SupplyInvtProfile."Due Date" := SupplyInvtProfile."Fixed Date"
        else
          SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date";
    end;

    local procedure IncreaseQtyToMeetDemand(var SupplyInvtProfile: Record "Inventory Profile";DemandInvtProfile: Record "Inventory Profile";LimitedHorizon: Boolean;RespectPlanningParm: Boolean;CheckSourceType: Boolean): Boolean
    var
        TotalDemandedQty: Decimal;
    begin
        if SupplyInvtProfile."Planning Flexibility" <> SupplyInvtProfile."planning flexibility"::Unlimited then
          exit(false);

        if CheckSourceType then
          if (DemandInvtProfile."Source Type" = Database::"Planning Component") and
             (SupplyInvtProfile."Source Type" = Database::"Prod. Order Line")
          then
            exit(false);

        if (SupplyInvtProfile."Max. Quantity" > 0) or
           (SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::Cancel)
        then
          if SupplyInvtProfile."Max. Quantity" <= SupplyInvtProfile."Remaining Quantity (Base)" then
            exit(false);

        if LimitedHorizon then
          if not AllowLotAccumulation(SupplyInvtProfile,DemandInvtProfile."Due Date") then
            exit(false);

        TotalDemandedQty := DemandInvtProfile."Untracked Quantity";
        IncreaseQty(
          SupplyInvtProfile,DemandInvtProfile."Untracked Quantity" - SupplyInvtProfile."Untracked Quantity",RespectPlanningParm);
        exit(TotalDemandedQty <= SupplyInvtProfile."Untracked Quantity");
    end;

    local procedure IncreaseQty(var SupplyInvtProfile: Record "Inventory Profile";NeededQty: Decimal;RespectPlanningParm: Boolean)
    var
        TempQty: Decimal;
    begin
        TempQty := SupplyInvtProfile."Remaining Quantity (Base)";

        if not SupplyInvtProfile."Is Exception Order" or RespectPlanningParm then
          SupplyInvtProfile."Remaining Quantity (Base)" += NeededQty +
            AdjustReorderQty(
              SupplyInvtProfile."Remaining Quantity (Base)" + NeededQty,TempSKU,SupplyInvtProfile."Line No.",
              SupplyInvtProfile."Min. Quantity")
        else
          SupplyInvtProfile."Remaining Quantity (Base)" += NeededQty;

        if TempSKU."Maximum Order Quantity" > 0 then
          if SupplyInvtProfile."Remaining Quantity (Base)" > TempSKU."Maximum Order Quantity" then
            SupplyInvtProfile."Remaining Quantity (Base)" := TempSKU."Maximum Order Quantity";
        if (SupplyInvtProfile."Action Message" <> SupplyInvtProfile."action message"::New) and
           (SupplyInvtProfile."Remaining Quantity (Base)" <> TempQty)
        then begin
          if SupplyInvtProfile."Original Quantity" = 0 then
            SupplyInvtProfile."Original Quantity" := SupplyInvtProfile.Quantity;
          if SupplyInvtProfile."Original Due Date" = 0D then
            SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Change Qty."
          else
            SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Resched.& Chg. Qty.";
        end;

        SupplyInvtProfile."Untracked Quantity" :=
          SupplyInvtProfile."Untracked Quantity" +
          SupplyInvtProfile."Remaining Quantity (Base)" -
          TempQty;

        SupplyInvtProfile."Quantity (Base)" :=
          SupplyInvtProfile."Quantity (Base)" +
          SupplyInvtProfile."Remaining Quantity (Base)" -
          TempQty;
        SupplyInvtProfile.Modify;
    end;

    local procedure DecreaseQty(var SupplyInvtProfile: Record "Inventory Profile";ReduceQty: Decimal): Boolean
    var
        TempQty: Decimal;
    begin
        if not CanDecreaseSupply(SupplyInvtProfile,ReduceQty) then begin
          if (ReduceQty <= DampenerQty) and (SupplyInvtProfile."Planning Level Code" = 0) then
            PlanningTransparency.LogSurplus(
              SupplyInvtProfile."Line No.",0,
              Database::"Manufacturing Setup",SupplyInvtProfile."Source ID",
              DampenerQty,Surplustype::DampenerQty);
          exit(false);
        end;

        if ReduceQty > 0 then begin
          TempQty := SupplyInvtProfile."Remaining Quantity (Base)";

          SupplyInvtProfile."Remaining Quantity (Base)" :=
            SupplyInvtProfile."Remaining Quantity (Base)" - ReduceQty +
            AdjustReorderQty(
              SupplyInvtProfile."Remaining Quantity (Base)" - ReduceQty,TempSKU,SupplyInvtProfile."Line No.",
              SupplyInvtProfile."Min. Quantity");

          if TempSKU."Maximum Order Quantity" > 0 then
            if SupplyInvtProfile."Remaining Quantity (Base)" > TempSKU."Maximum Order Quantity" then
              SupplyInvtProfile."Remaining Quantity (Base)" := TempSKU."Maximum Order Quantity";
          if (SupplyInvtProfile."Action Message" <> SupplyInvtProfile."action message"::New) and
             (TempQty <> SupplyInvtProfile."Remaining Quantity (Base)")
          then begin
            if SupplyInvtProfile."Original Quantity" = 0 then
              SupplyInvtProfile."Original Quantity" := SupplyInvtProfile.Quantity;
            if SupplyInvtProfile."Remaining Quantity (Base)" = 0 then
              SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::Cancel
            else
              if SupplyInvtProfile."Original Due Date" = 0D then
                SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Change Qty."
              else
                SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Resched.& Chg. Qty.";
          end;

          SupplyInvtProfile."Untracked Quantity" :=
            SupplyInvtProfile."Untracked Quantity" -
            TempQty +
            SupplyInvtProfile."Remaining Quantity (Base)";

          SupplyInvtProfile."Quantity (Base)" :=
            SupplyInvtProfile."Quantity (Base)" -
            TempQty +
            SupplyInvtProfile."Remaining Quantity (Base)";

          SupplyInvtProfile.Modify;
        end;

        exit(SupplyInvtProfile."Untracked Quantity" = 0);
    end;

    local procedure CanDecreaseSupply(InventoryProfileSupply: Record "Inventory Profile";var ReduceQty: Decimal): Boolean
    var
        TrackedQty: Decimal;
    begin
        with InventoryProfileSupply do begin
          if ReduceQty > "Untracked Quantity" then
            ReduceQty := "Untracked Quantity";
          if "Min. Quantity" > "Remaining Quantity (Base)" - ReduceQty then
            ReduceQty := "Remaining Quantity (Base)" - "Min. Quantity";

          // Ensure leaving enough untracked qty. to cover the safety stock
          TrackedQty := "Remaining Quantity (Base)" - "Untracked Quantity";
          if TrackedQty + "Safety Stock Quantity" > "Remaining Quantity (Base)" - ReduceQty then
            ReduceQty := "Remaining Quantity (Base)" - (TrackedQty + "Safety Stock Quantity");

          // Planning Transparency
          if (ReduceQty <= DampenerQty) and ("Planning Level Code" = 0) then
            exit(false);

          if ("Planning Flexibility" = "planning flexibility"::None) or
             ((ReduceQty <= DampenerQty) and
              ("Planning Level Code" = 0))
          then
            exit(false);

          exit(true);
        end;
    end;

    local procedure CreateSupply(var SupplyInvtProfile: Record "Inventory Profile";var DemandInvtProfile: Record "Inventory Profile";ProjectedInventory: Decimal;IsExceptionOrder: Boolean;RespectPlanningParm: Boolean)
    var
        ReorderQty: Decimal;
    begin
        InitSupply(SupplyInvtProfile,0,DemandInvtProfile."Due Date");
        ReorderQty := DemandInvtProfile."Untracked Quantity";
        if (not IsExceptionOrder) or RespectPlanningParm then begin
          if not RespectPlanningParm then
            ReorderQty := CalcReorderQty(ReorderQty,ProjectedInventory,SupplyInvtProfile."Line No.")
          else
            if IsExceptionOrder then begin
              if DemandInvtProfile."Order Relation" =
                 DemandInvtProfile."order relation"::"Safety Stock"
              then // Compensate for Safety Stock offset
                ProjectedInventory := ProjectedInventory + DemandInvtProfile."Remaining Quantity (Base)";
              ReorderQty := CalcReorderQty(ReorderQty,ProjectedInventory,SupplyInvtProfile."Line No.");
              if ReorderQty < -ProjectedInventory then
                ReorderQty :=
                  ROUND(-ProjectedInventory / TempSKU."Reorder Quantity" + ExceedROPqty,1,'>') *
                  TempSKU."Reorder Quantity";
            end;

          ReorderQty += AdjustReorderQty(ReorderQty,TempSKU,SupplyInvtProfile."Line No.",SupplyInvtProfile."Min. Quantity");
          SupplyInvtProfile."Max. Quantity" := TempSKU."Maximum Order Quantity";
        end;
        UpdateQty(SupplyInvtProfile,ReorderQty);
        if TempSKU."Maximum Order Quantity" > 0 then begin
          if SupplyInvtProfile."Remaining Quantity (Base)" > TempSKU."Maximum Order Quantity" then
            SupplyInvtProfile."Remaining Quantity (Base)" := TempSKU."Maximum Order Quantity";
          if SupplyInvtProfile."Untracked Quantity" >= TempSKU."Maximum Order Quantity" then
            SupplyInvtProfile."Untracked Quantity" :=
              SupplyInvtProfile."Untracked Quantity" -
              ReorderQty +
              SupplyInvtProfile."Remaining Quantity (Base)";
        end;
        SupplyInvtProfile."Min. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
        TransferAttributes(SupplyInvtProfile,DemandInvtProfile);
        SupplyInvtProfile."Is Exception Order" := IsExceptionOrder;
        SupplyInvtProfile.Insert;
        if (not IsExceptionOrder or RespectPlanningParm) and (OverflowLevel > 0) then
          // the new supply might cause overflow in inventory since
          // it wasn't considered when Overflow was calculated
          CheckNewOverflow(SupplyInvtProfile,ProjectedInventory + ReorderQty,ReorderQty,SupplyInvtProfile."Due Date");
    end;

    local procedure CreateDemand(var DemandInvtProfile: Record "Inventory Profile";var SKU: Record "Stockkeeping Unit";NeededQuantity: Decimal;NeededDueDate: Date;OrderRelation: Option Normal,"Safety Stock","Reorder Point")
    begin
        DemandInvtProfile.Init;
        DemandInvtProfile."Line No." := NextLineNo;
        DemandInvtProfile."Item No." := SKU."Item No.";
        DemandInvtProfile."Variant Code" := SKU."Variant Code";
        DemandInvtProfile."Location Code" := SKU."Location Code";
        DemandInvtProfile."Quantity (Base)" := NeededQuantity;
        DemandInvtProfile."Remaining Quantity (Base)" := NeededQuantity;
        DemandInvtProfile.IsSupply := false;
        DemandInvtProfile."Order Relation" := OrderRelation;
        DemandInvtProfile."Source Type" := 0;
        DemandInvtProfile."Untracked Quantity" := NeededQuantity;
        DemandInvtProfile."Due Date" := NeededDueDate;
        DemandInvtProfile."Planning Flexibility" := DemandInvtProfile."planning flexibility"::None;
        OnBeforeDemandInvtProfileInsert(DemandInvtProfile,SKU);
        DemandInvtProfile.Insert;
    end;

    local procedure Track(FromProfile: Record "Inventory Profile";ToProfile: Record "Inventory Profile";IsSurplus: Boolean;IssueActionMessage: Boolean;Binding: Option " ","Order-to-Order")
    var
        TrkgReservEntryArray: array [6] of Record "Reservation Entry";
        SplitState: Option NoSplit,SplitFromProfile,SplitToProfile,Cancel;
        SplitQty: Decimal;
        SplitQty2: Decimal;
        TrackQty: Decimal;
        DecreaseSupply: Boolean;
    begin
        DecreaseSupply :=
          FromProfile.IsSupply and
          (FromProfile."Action Message" in [FromProfile."action message"::"Change Qty.",
                                            FromProfile."action message"::"Resched.& Chg. Qty."]) and
          (FromProfile."Quantity (Base)" < FromProfile."Original Quantity" * FromProfile."Qty. per Unit of Measure");

        if ((FromProfile."Action Message" = FromProfile."action message"::Cancel) and
            (FromProfile."Untracked Quantity" = 0)) or (DecreaseSupply and IsSurplus)
        then begin
          IsSurplus := false;
          if DecreaseSupply then
            FromProfile."Untracked Quantity" :=
              FromProfile."Original Quantity" * FromProfile."Qty. per Unit of Measure" - FromProfile."Quantity (Base)"
          else
            if FromProfile.IsSupply then
              FromProfile."Untracked Quantity" := FromProfile."Remaining Quantity" * FromProfile."Qty. per Unit of Measure"
            else
              FromProfile."Untracked Quantity" := -FromProfile."Remaining Quantity" * FromProfile."Qty. per Unit of Measure";
          FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[1],false);
          TrkgReservEntryArray[3] := TrkgReservEntryArray[1];
          ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[3],true);
          if FromProfile.IsSupply then
            TrkgReservEntryArray[3]."Shipment Date" := FromProfile."Due Date"
          else
            TrkgReservEntryArray[3]."Expected Receipt Date" := FromProfile."Due Date";
          SplitState := Splitstate::Cancel;
        end else begin
          TrackQty := FromProfile."Untracked Quantity";

          if FromProfile.IsSupply then begin
            if not ((FromProfile."Original Quantity" * FromProfile."Qty. per Unit of Measure" > FromProfile."Quantity (Base)") or
                    (FromProfile."Untracked Quantity" > 0))
            then
              exit;

            SplitQty := FromProfile."Original Quantity" * FromProfile."Qty. per Unit of Measure" +
              FromProfile."Untracked Quantity" - FromProfile."Quantity (Base)";

            case FromProfile."Action Message" of
              FromProfile."action message"::"Resched.& Chg. Qty.",
              FromProfile."action message"::Reschedule,
              FromProfile."action message"::New,
              FromProfile."action message"::"Change Qty.":
                begin
                  if (SplitQty > 0) and (SplitQty < TrackQty) then begin
                    SplitState := Splitstate::SplitFromProfile;
                    FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[1],
                      (FromProfile."Action Message" = FromProfile."action message"::Reschedule) or
                      (FromProfile."Action Message" = FromProfile."action message"::"Resched.& Chg. Qty."));
                    TrkgReservEntryArray[3] := TrkgReservEntryArray[1];
                    ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[3],true);
                    if IsSurplus then begin
                      TrkgReservEntryArray[3]."Quantity (Base)" := TrackQty - SplitQty;
                      TrkgReservEntryArray[1]."Quantity (Base)" := SplitQty;
                    end else begin
                      TrkgReservEntryArray[1]."Quantity (Base)" := TrackQty - SplitQty;
                      TrkgReservEntryArray[3]."Quantity (Base)" := SplitQty;
                    end;
                    TrkgReservEntryArray[1].Quantity :=
                      ROUND(TrkgReservEntryArray[1]."Quantity (Base)" / TrkgReservEntryArray[1]."Qty. per Unit of Measure",0.00001);
                    TrkgReservEntryArray[3].Quantity :=
                      ROUND(TrkgReservEntryArray[3]."Quantity (Base)" / TrkgReservEntryArray[3]."Qty. per Unit of Measure",0.00001);
                  end else begin
                    FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[1],false);
                    ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[1],true);
                  end;
                  if IsSurplus then begin
                    TrkgReservEntryArray[4] := TrkgReservEntryArray[1];
                    ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[4],true);
                    TrkgReservEntryArray[4]."Shipment Date" := ReqLine."Due Date";
                  end;
                  ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[2],false);
                end;
              else
                FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[1],false);
                ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[2],
                  (ToProfile."Source Type" = Database::"Planning Component") and
                  (ToProfile."Primary Order Status" > 1)); // Firm Planned, Released Prod.Order
            end;
          end else begin
            ToProfile.TestField(IsSupply,true);
            SplitQty := ToProfile."Remaining Quantity" * ToProfile."Qty. per Unit of Measure" + ToProfile."Untracked Quantity" +
              FromProfile."Untracked Quantity" - ToProfile."Quantity (Base)";

            if FromProfile."Source Type" = Database::"Planning Component" then begin
              SplitQty2 := FromProfile."Original Quantity" * FromProfile."Qty. per Unit of Measure";
              if FromProfile."Untracked Quantity" < SplitQty2 then
                SplitQty2 := FromProfile."Untracked Quantity";
              if SplitQty2 > SplitQty then
                SplitQty2 := SplitQty;
            end;

            if SplitQty2 > 0 then begin
              ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[5],false);
              if ToProfile."Action Message" = ToProfile."action message"::New then begin
                ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[5],true);
                FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[6],false);
              end else
                FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[6],true);
              TrkgReservEntryArray[5]."Quantity (Base)" := SplitQty2;
              TrkgReservEntryArray[5].Quantity :=
                ROUND(TrkgReservEntryArray[5]."Quantity (Base)" / TrkgReservEntryArray[5]."Qty. per Unit of Measure",0.00001);
              FromProfile."Untracked Quantity" := FromProfile."Untracked Quantity" - SplitQty2;
              TrackQty := TrackQty - SplitQty2;
              SplitQty := SplitQty - SplitQty2;
              PrepareTempTracking(TrkgReservEntryArray[5],TrkgReservEntryArray[6],IsSurplus,IssueActionMessage,Binding);
            end;

            if (ToProfile."Action Message" <> ToProfile."action message"::" ") and
               (SplitQty < TrackQty)
            then begin
              if (SplitQty > 0) and (SplitQty < TrackQty) then begin
                SplitState := Splitstate::SplitToProfile;
                ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[2],
                  (FromProfile."Action Message" = FromProfile."action message"::Reschedule) or
                  (FromProfile."Action Message" = FromProfile."action message"::"Resched.& Chg. Qty."));
                TrkgReservEntryArray[3] := TrkgReservEntryArray[2];
                ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[2],true);
                TrkgReservEntryArray[2]."Quantity (Base)" := TrackQty - SplitQty;
                TrkgReservEntryArray[3]."Quantity (Base)" := SplitQty;
                TrkgReservEntryArray[2].Quantity :=
                  ROUND(TrkgReservEntryArray[2]."Quantity (Base)" / TrkgReservEntryArray[2]."Qty. per Unit of Measure",0.00001);
                TrkgReservEntryArray[3].Quantity :=
                  ROUND(TrkgReservEntryArray[3]."Quantity (Base)" / TrkgReservEntryArray[3]."Qty. per Unit of Measure",0.00001);
              end else begin
                ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[2],false);
                ReqLine.TransferToTrackingEntry(TrkgReservEntryArray[2],true);
              end;
            end else
              ToProfile.TransferToTrackingEntry(TrkgReservEntryArray[2],false);
            FromProfile.TransferToTrackingEntry(TrkgReservEntryArray[1],false);
          end;
        end;

        case SplitState of
          Splitstate::NoSplit:
            PrepareTempTracking(TrkgReservEntryArray[1],TrkgReservEntryArray[2],IsSurplus,IssueActionMessage,Binding);
          Splitstate::SplitFromProfile:
            if IsSurplus then begin
              PrepareTempTracking(TrkgReservEntryArray[1],TrkgReservEntryArray[4],false,IssueActionMessage,Binding);
              PrepareTempTracking(TrkgReservEntryArray[3],TrkgReservEntryArray[4],true,IssueActionMessage,Binding);
            end else begin
              TrkgReservEntryArray[4] := TrkgReservEntryArray[2];
              PrepareTempTracking(TrkgReservEntryArray[1],TrkgReservEntryArray[2],IsSurplus,IssueActionMessage,Binding);
              PrepareTempTracking(TrkgReservEntryArray[3],TrkgReservEntryArray[4],IsSurplus,IssueActionMessage,Binding);
            end;
          Splitstate::SplitToProfile:
            begin
              TrkgReservEntryArray[4] := TrkgReservEntryArray[1];
              PrepareTempTracking(TrkgReservEntryArray[2],TrkgReservEntryArray[1],IsSurplus,IssueActionMessage,Binding);
              PrepareTempTracking(TrkgReservEntryArray[3],TrkgReservEntryArray[4],IsSurplus,IssueActionMessage,Binding);
            end;
          Splitstate::Cancel:
            PrepareTempTracking(TrkgReservEntryArray[1],TrkgReservEntryArray[3],IsSurplus,IssueActionMessage,Binding);
        end;
    end;

    local procedure PrepareTempTracking(var FromTrkgReservEntry: Record "Reservation Entry";var ToTrkgReservEntry: Record "Reservation Entry";IsSurplus: Boolean;IssueActionMessage: Boolean;Binding: Option " ","Order-to-Order")
    begin
        if not IsSurplus then begin
          ToTrkgReservEntry."Quantity (Base)" := -FromTrkgReservEntry."Quantity (Base)";
          ToTrkgReservEntry.Quantity :=
            ROUND(ToTrkgReservEntry."Quantity (Base)" / ToTrkgReservEntry."Qty. per Unit of Measure",0.00001);
        end else
          ToTrkgReservEntry."Suppressed Action Msg." := not IssueActionMessage;

        ToTrkgReservEntry.Positive := ToTrkgReservEntry."Quantity (Base)" > 0;
        FromTrkgReservEntry.Positive := FromTrkgReservEntry."Quantity (Base)" > 0;

        FromTrkgReservEntry.Binding := Binding;
        ToTrkgReservEntry.Binding := Binding;

        if IsSurplus or (ToTrkgReservEntry."Reservation Status" = ToTrkgReservEntry."reservation status"::Surplus) then begin
          FromTrkgReservEntry."Reservation Status" := FromTrkgReservEntry."reservation status"::Surplus;
          FromTrkgReservEntry."Suppressed Action Msg." := ToTrkgReservEntry."Suppressed Action Msg.";
          InsertTempTracking(FromTrkgReservEntry,ToTrkgReservEntry);
          exit;
        end;

        if FromTrkgReservEntry."Reservation Status" = FromTrkgReservEntry."reservation status"::Surplus then begin
          ToTrkgReservEntry."Reservation Status" := ToTrkgReservEntry."reservation status"::Surplus;
          ToTrkgReservEntry."Suppressed Action Msg." := FromTrkgReservEntry."Suppressed Action Msg.";
          InsertTempTracking(ToTrkgReservEntry,FromTrkgReservEntry);
          exit;
        end;

        InsertTempTracking(FromTrkgReservEntry,ToTrkgReservEntry);
    end;

    local procedure InsertTempTracking(var FromTrkgReservEntry: Record "Reservation Entry";var ToTrkgReservEntry: Record "Reservation Entry")
    var
        NextEntryNo: Integer;
        ShouldInsert: Boolean;
    begin
        if FromTrkgReservEntry."Quantity (Base)" = 0 then
          exit;
        NextEntryNo := TempTrkgReservEntry."Entry No." + 1;

        if FromTrkgReservEntry."Reservation Status" = FromTrkgReservEntry."reservation status"::Surplus then begin
          TempTrkgReservEntry := FromTrkgReservEntry;
          TempTrkgReservEntry."Entry No." := NextEntryNo;
          SetQtyToHandle(TempTrkgReservEntry);
          TempTrkgReservEntry.Insert;
        end else begin
          MatchReservationEntries(FromTrkgReservEntry,ToTrkgReservEntry);
          if FromTrkgReservEntry.Positive then begin
            FromTrkgReservEntry."Shipment Date" := ToTrkgReservEntry."Shipment Date";
            if ToTrkgReservEntry."Source Type" = Database::"Item Ledger Entry" then
              ToTrkgReservEntry."Shipment Date" := Dmy2date(31,12,9999);
            ToTrkgReservEntry."Expected Receipt Date" := FromTrkgReservEntry."Expected Receipt Date";
          end else begin
            ToTrkgReservEntry."Shipment Date" := FromTrkgReservEntry."Shipment Date";
            if FromTrkgReservEntry."Source Type" = Database::"Item Ledger Entry" then
              FromTrkgReservEntry."Shipment Date" := Dmy2date(31,12,9999);
            FromTrkgReservEntry."Expected Receipt Date" := ToTrkgReservEntry."Expected Receipt Date";
          end;

          if FromTrkgReservEntry.Positive then
            ShouldInsert := ShouldInsertTrackingEntry(FromTrkgReservEntry)
          else
            ShouldInsert := ShouldInsertTrackingEntry(ToTrkgReservEntry);

          if ShouldInsert then begin
            TempTrkgReservEntry := FromTrkgReservEntry;
            TempTrkgReservEntry."Entry No." := NextEntryNo;
            SetQtyToHandle(TempTrkgReservEntry);
            TempTrkgReservEntry.Insert;

            TempTrkgReservEntry := ToTrkgReservEntry;
            TempTrkgReservEntry."Entry No." := NextEntryNo;
            SetQtyToHandle(TempTrkgReservEntry);
            TempTrkgReservEntry.Insert;
          end;
        end;
    end;

    local procedure SetQtyToHandle(var TrkgReservEntry: Record "Reservation Entry")
    var
        PickedQty: Decimal;
    begin
        if not TrkgReservEntry.TrackingExists then
          exit;

        PickedQty := QtyPickedForSourceDocument(TrkgReservEntry);

        if PickedQty <> 0 then begin
          TrkgReservEntry."Qty. to Handle (Base)" := PickedQty;
          TrkgReservEntry."Qty. to Invoice (Base)" := PickedQty;
        end else begin
          TrkgReservEntry."Qty. to Handle (Base)" := TrkgReservEntry."Quantity (Base)";
          TrkgReservEntry."Qty. to Invoice (Base)" := TrkgReservEntry."Quantity (Base)";
        end;
    end;

    local procedure CommitTracking()
    var
        PrevTempEntryNo: Integer;
        PrevInsertedEntryNo: Integer;
    begin
        if not TempTrkgReservEntry.Find('-') then
          exit;

        repeat
          ReservEntry := TempTrkgReservEntry;
          if TempTrkgReservEntry."Entry No." = PrevTempEntryNo then
            ReservEntry."Entry No." := PrevInsertedEntryNo
          else
            ReservEntry."Entry No." := 0;
          ReservEntry.UpdateItemTracking;
          UpdateAppliedItemEntry(ReservEntry);
          ReservEntry.Insert;
          PrevTempEntryNo := TempTrkgReservEntry."Entry No.";
          PrevInsertedEntryNo := ReservEntry."Entry No.";
          TempTrkgReservEntry.Delete;
        until TempTrkgReservEntry.Next = 0;
        Clear(TempTrkgReservEntry);
    end;

    local procedure MaintainPlanningLine(var SupplyInvtProfile: Record "Inventory Profile";NewPhase: Option " ","Line Created","Routing Created",Exploded,Obsolete;Direction: Option Forward,Backward)
    var
        PurchaseLine: Record "Purchase Line";
        ProdOrderLine: Record "Prod. Order Line";
        AsmHeader: Record "Assembly Header";
        TransLine: Record "Transfer Line";
        CrntSupplyInvtProfile: Record "Inventory Profile";
        PlanLineNo: Integer;
        RecalculationRequired: Boolean;
    begin
        if (NewPhase = Newphase::"Line Created") or
           (SupplyInvtProfile."Planning Line Phase" < SupplyInvtProfile."planning line phase"::"Line Created")
        then
          if SupplyInvtProfile."Planning Line No." = 0 then
            with ReqLine do begin
              BlockDynamicTracking(true);
              if FindLast then
                PlanLineNo := "Line No." + 10000
              else
                PlanLineNo := 10000;
              Init;
              "Worksheet Template Name" := CurrTemplateName;
              "Journal Batch Name" := CurrWorksheetName;
              "Line No." := PlanLineNo;
              Type := Type::Item;
              "No." := SupplyInvtProfile."Item No.";
              "Variant Code" := SupplyInvtProfile."Variant Code";
              "Location Code" := SupplyInvtProfile."Location Code";
              "Bin Code" := SupplyInvtProfile."Bin Code";
              "Planning Line Origin" := "planning line origin"::Planning;
              if SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::New
              then begin
                "Order Date" := SupplyInvtProfile."Due Date";
                "Planning Level" := SupplyInvtProfile."Planning Level Code";
                case TempSKU."Replenishment System" of
                  TempSKU."replenishment system"::Purchase:
                    "Ref. Order Type" := "ref. order type"::Purchase;
                  TempSKU."replenishment system"::"Prod. Order":
                    begin
                      "Ref. Order Type" := "ref. order type"::"Prod. Order";
                      if "Planning Level" > 0 then begin
                        "Ref. Order Status" := SupplyInvtProfile."Primary Order Status";
                        "Ref. Order No." := SupplyInvtProfile."Primary Order No.";
                      end;
                    end;
                  TempSKU."replenishment system"::Assembly:
                    "Ref. Order Type" := "ref. order type"::Assembly;
                  TempSKU."replenishment system"::Transfer:
                    "Ref. Order Type" := "ref. order type"::Transfer;
                end;
                Validate("No.");
                Validate("Variant Code");
                Validate("Unit of Measure Code",SupplyInvtProfile."Unit of Measure Code");
                "Starting Time" := ManufacturingSetup."Normal Starting Time";
                "Ending Time" := ManufacturingSetup."Normal Ending Time";
              end else
                case SupplyInvtProfile."Source Type" of
                  Database::"Purchase Line":
                    SetPurchase(PurchaseLine,SupplyInvtProfile);
                  Database::"Prod. Order Line":
                    SetProdOrder(ProdOrderLine,SupplyInvtProfile);
                  Database::"Assembly Header":
                    SetAssembly(AsmHeader,SupplyInvtProfile);
                  Database::"Transfer Line":
                    SetTransfer(TransLine,SupplyInvtProfile);
                end;
              AdjustPlanLine(SupplyInvtProfile);
              "Accept Action Message" := true;
              "Routing Reference No." := "Line No.";
              UpdateDatetime;
              "MPS Order" := SupplyInvtProfile."MPS Order";
              Insert;
              SupplyInvtProfile."Planning Line No." := "Line No.";
              if NewPhase = Newphase::"Line Created" then
                SupplyInvtProfile."Planning Line Phase" := SupplyInvtProfile."planning line phase"::"Line Created";
            end else begin
            if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
              ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
            ReqLine.BlockDynamicTracking(true);
            AdjustPlanLine(SupplyInvtProfile);
            if NewPhase = Newphase::"Line Created" then
              ReqLine.Modify;
          end;

        if (NewPhase = Newphase::"Routing Created") or
           ((NewPhase > Newphase::"Routing Created") and
            (SupplyInvtProfile."Planning Line Phase" < SupplyInvtProfile."planning line phase"::"Routing Created"))
        then begin
          ReqLine.BlockDynamicTracking(true);
          if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
            ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
          AdjustPlanLine(SupplyInvtProfile);
          if ReqLine.Quantity > 0 then begin
            if SupplyInvtProfile."Starting Date" <> 0D then
              ReqLine."Starting Date" := SupplyInvtProfile."Starting Date"
            else
              ReqLine."Starting Date" := SupplyInvtProfile."Due Date";
            GetRouting(ReqLine);
            RecalculationRequired := true;
            if NewPhase = Newphase::"Routing Created" then
              SupplyInvtProfile."Planning Line Phase" := SupplyInvtProfile."planning line phase"::"Routing Created";
          end;
          ReqLine.Modify;
        end;

        if NewPhase = Newphase::Exploded then begin
          if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
            ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
          ReqLine.BlockDynamicTracking(true);
          AdjustPlanLine(SupplyInvtProfile);
          if ReqLine.Quantity = 0 then
            if ReqLine."Action Message" = ReqLine."action message"::New then begin
              ReqLine.BlockDynamicTracking(true);
              ReqLine.Delete(true);

              RecalculationRequired := false;
            end else
              DisableRelations
          else begin
            GetComponents(ReqLine);
            RecalculationRequired := true;
          end;

          if (ReqLine."Ref. Order Type" = ReqLine."ref. order type"::Transfer) and
             not ((ReqLine.Quantity = 0) and (ReqLine."Action Message" = ReqLine."action message"::New))
          then begin
            AdjustTransferDates(ReqLine);
            if ReqLine."Action Message" = ReqLine."action message"::New then begin
              CrntSupplyInvtProfile.Copy(SupplyInvtProfile);
              SupplyInvtProfile.Init;
              SupplyInvtProfile."Line No." := NextLineNo;
              SupplyInvtProfile."Item No." := ReqLine."No.";
              SupplyInvtProfile.TransferFromOutboundTransfPlan(ReqLine,TempItemTrkgEntry);
              SupplyInvtProfile."Lot No." := CrntSupplyInvtProfile."Lot No.";
              SupplyInvtProfile."Serial No." := CrntSupplyInvtProfile."Serial No.";
              if SupplyInvtProfile.IsSupply then
                SupplyInvtProfile.ChangeSign;
              SupplyInvtProfile.Insert;

              SupplyInvtProfile.Copy(CrntSupplyInvtProfile);
            end else
              SynchronizeTransferProfiles(SupplyInvtProfile,ReqLine);
          end;
        end;

        if RecalculationRequired then begin
          Recalculate(ReqLine,Direction);
          ReqLine.UpdateDatetime;
          ReqLine.Modify;

          SupplyInvtProfile."Starting Date" := ReqLine."Starting Date";
          SupplyInvtProfile."Due Date" := ReqLine."Due Date";
        end;

        if NewPhase = Newphase::Obsolete then begin
          if SupplyInvtProfile."Planning Line No." <> ReqLine."Line No." then
            ReqLine.Get(CurrTemplateName,CurrWorksheetName,SupplyInvtProfile."Planning Line No.");
          ReqLine.Delete(true);
          SupplyInvtProfile."Planning Line No." := 0;
          SupplyInvtProfile."Planning Line Phase" := SupplyInvtProfile."planning line phase"::" ";
        end;

        SupplyInvtProfile.Modify;
    end;

    procedure AdjustReorderQty(OrderQty: Decimal;SKU: Record "Stockkeeping Unit";SupplyLineNo: Integer;MinQty: Decimal): Decimal
    var
        DeltaQty: Decimal;
        Rounding: Decimal;
    begin
        // Copy of this procedure exists in COD5400- Available Management
        if OrderQty <= 0 then
          exit(0);

        if (SKU."Maximum Order Quantity" < OrderQty) and
           (SKU."Maximum Order Quantity" <> 0) and
           (SKU."Maximum Order Quantity" > MinQty)
        then begin
          DeltaQty := SKU."Maximum Order Quantity" - OrderQty;
          PlanningTransparency.LogSurplus(
            SupplyLineNo,0,Database::Item,TempSKU."Item No.",
            DeltaQty,Surplustype::MaxOrder);
        end else
          DeltaQty := 0;
        if SKU."Minimum Order Quantity" > (OrderQty + DeltaQty) then begin
          DeltaQty := SKU."Minimum Order Quantity" - OrderQty;
          PlanningTransparency.LogSurplus(
            SupplyLineNo,0,Database::Item,TempSKU."Item No.",
            SKU."Minimum Order Quantity",Surplustype::MinOrder);
        end;
        if SKU."Order Multiple" <> 0 then begin
          Rounding := ROUND(OrderQty + DeltaQty,SKU."Order Multiple",'>') - (OrderQty + DeltaQty);
          DeltaQty += Rounding;
          if DeltaQty <> 0 then
            PlanningTransparency.LogSurplus(
              SupplyLineNo,0,Database::Item,TempSKU."Item No.",
              Rounding,Surplustype::OrderMultiple);
        end;
        exit(DeltaQty);
    end;

    local procedure CalcInventoryProfileRemainingQty(var InventoryProfile: Record "Inventory Profile";DocumentNo: Code[20]): Decimal
    begin
        with InventoryProfile do begin
          SetRange("Source Type",Database::"Sales Line");
          SetRange("Ref. Blanket Order No.",DocumentNo);
          CalcSums("Remaining Quantity (Base)");
          exit("Remaining Quantity (Base)");
        end;
    end;

    local procedure CalcReorderQty(NeededQty: Decimal;ProjectedInventory: Decimal;SupplyLineNo: Integer) QtyToOrder: Decimal
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        // Calculate qty to order:
        // If Max:   QtyToOrder = MaxInv - ProjInvLevel
        // If Fixed: QtyToOrder = FixedReorderQty
        // Copy of this procedure exists in COD5400- Available Management
        case TempSKU."Reordering Policy" of
          TempSKU."reordering policy"::"Maximum Qty.":
            begin
              if TempSKU."Maximum Inventory" <= TempSKU."Reorder Point" then begin
                if PlanningResilicency then
                  if SKU.Get(TempSKU."Location Code",TempSKU."Item No.",TempSKU."Variant Code") then
                    ReqLine.SetResiliencyError(
                      StrSubstNo(
                        Text004,SKU.FieldCaption("Maximum Inventory"),SKU."Maximum Inventory",SKU.TableCaption,
                        SKU."Location Code",SKU."Item No.",SKU."Variant Code",
                        SKU.FieldCaption("Reorder Point"),SKU."Reorder Point"),
                      Database::"Stockkeeping Unit",SKU.GetPosition)
                  else
                    if Item.Get(TempSKU."Item No.") then
                      ReqLine.SetResiliencyError(
                        StrSubstNo(
                          Text005,Item.FieldCaption("Maximum Inventory"),Item."Maximum Inventory",Item.TableCaption,
                          Item."No.",Item.FieldCaption("Reorder Point"),Item."Reorder Point"),
                        Database::Item,Item.GetPosition);
                TempSKU.TestField("Maximum Inventory",TempSKU."Reorder Point" + 1); // Assertion
              end;

              QtyToOrder := TempSKU."Maximum Inventory" - ProjectedInventory;
              PlanningTransparency.LogSurplus(
                SupplyLineNo,0,Database::Item,TempSKU."Item No.",
                QtyToOrder,Surplustype::MaxInventory);
            end;
          TempSKU."reordering policy"::"Fixed Reorder Qty.":
            begin
              if PlanningResilicency and (TempSKU."Reorder Quantity" = 0) then
                if SKU.Get(TempSKU."Location Code",TempSKU."Item No.",TempSKU."Variant Code") then
                  ReqLine.SetResiliencyError(
                    StrSubstNo(
                      Text004,SKU.FieldCaption("Reorder Quantity"),0,SKU.TableCaption,
                      SKU."Location Code",SKU."Item No.",SKU."Variant Code",
                      SKU.FieldCaption("Reordering Policy"),SKU."Reordering Policy"),
                    Database::"Stockkeeping Unit",SKU.GetPosition)
                else
                  if Item.Get(TempSKU."Item No.") then
                    ReqLine.SetResiliencyError(
                      StrSubstNo(
                        Text005,Item.FieldCaption("Reorder Quantity"),0,Item.TableCaption,
                        Item."No.",Item.FieldCaption("Reordering Policy"),Item."Reordering Policy"),
                      Database::Item,Item.GetPosition);

              TempSKU.TestField("Reorder Quantity"); // Assertion
              QtyToOrder := TempSKU."Reorder Quantity";
              PlanningTransparency.LogSurplus(
                SupplyLineNo,0,Database::Item,TempSKU."Item No.",
                QtyToOrder,Surplustype::FixedOrderQty);
            end;
          else
            QtyToOrder := NeededQty;
        end;
    end;

    local procedure CalcOrderQty(NeededQty: Decimal;ProjectedInventory: Decimal;SupplyLineNo: Integer) QtyToOrder: Decimal
    begin
        QtyToOrder := CalcReorderQty(NeededQty,ProjectedInventory,SupplyLineNo);
        // Ensure that QtyToOrder is large enough to exceed ROP:
        if QtyToOrder <= (TempSKU."Reorder Point" - ProjectedInventory) then
          QtyToOrder :=
            ROUND((TempSKU."Reorder Point" - ProjectedInventory) / TempSKU."Reorder Quantity" + 0.000000001,1,'>') *
            TempSKU."Reorder Quantity";
    end;

    local procedure CalcSalesOrderQty(AsmLine: Record "Assembly Line") QtyOnSalesOrder: Decimal
    var
        SalesOrderLine: Record "Sales Line";
        ATOLink: Record "Assemble-to-Order Link";
    begin
        QtyOnSalesOrder := 0;
        ATOLink.Get(AsmLine."Document Type",AsmLine."Document No.");
        SalesOrderLine.SetCurrentkey("Document Type","Blanket Order No.","Blanket Order Line No.");
        SalesOrderLine.SetRange("Document Type",SalesOrderLine."document type"::Order);
        SalesOrderLine.SetRange("Blanket Order No.",ATOLink."Document No.");
        SalesOrderLine.SetRange("Blanket Order Line No.",ATOLink."Document Line No.");
        if SalesOrderLine.Find('-') then
          repeat
            QtyOnSalesOrder += SalesOrderLine."Quantity (Base)";
          until SalesOrderLine.Next = 0;
    end;

    local procedure AdjustPlanLine(var Supply: Record "Inventory Profile")
    begin
        with Supply do begin
          ReqLine."Action Message" := "Action Message";
          ReqLine.BlockDynamicTracking(true);
          if "Action Message" in
             ["action message"::New,
              "action message"::"Change Qty.",
              "action message"::Reschedule,
              "action message"::"Resched.& Chg. Qty.",
              "action message"::Cancel]
          then begin
            if "Qty. per Unit of Measure" = 0 then
              "Qty. per Unit of Measure" := 1;
            ReqLine.Validate(
              Quantity,
              ROUND("Remaining Quantity (Base)" / "Qty. per Unit of Measure",0.00001));
            ReqLine."Original Quantity" := "Original Quantity";
            ReqLine."Net Quantity (Base)" :=
              (ReqLine."Remaining Quantity" - ReqLine."Original Quantity") *
              ReqLine."Qty. per Unit of Measure";
          end;
          ReqLine."Original Due Date" := "Original Due Date";
          ReqLine."Due Date" := "Due Date";
          if "Planning Level Code" = 0 then
            ReqLine."Ending Date" :=
              LeadTimeMgt.PlannedEndingDate(
                "Item No.","Location Code","Variant Code","Due Date",'',ReqLine."Ref. Order Type")
          else begin
            ReqLine."Ending Date" := "Due Date";
            ReqLine."Ending Time" := "Due Time";
          end;
          if (ReqLine."Starting Date" = 0D) or
             (ReqLine."Starting Date" > ReqLine."Ending Date")
          then
            ReqLine."Starting Date" := ReqLine."Ending Date";
        end;
    end;

    local procedure DisableRelations()
    var
        PlanningComponent: Record "Planning Component";
        PlanningRtngLine: Record "Planning Routing Line";
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
    begin
        if ReqLine.Type <> ReqLine.Type::Item then
          exit;
        PlanningComponent.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningComponent.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningComponent.SetRange("Worksheet Line No.",ReqLine."Line No.");
        if PlanningComponent.Find('-') then
          repeat
            PlanningComponent.BlockDynamicTracking(false);
            PlanningComponent.Delete(true);
          until PlanningComponent.Next = 0;

        PlanningRtngLine.SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
        PlanningRtngLine.SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
        PlanningRtngLine.SetRange("Worksheet Line No.",ReqLine."Line No.");
        PlanningRtngLine.DeleteAll;

        with ProdOrderCapNeed do begin
          SetCurrentkey("Worksheet Template Name","Worksheet Batch Name","Worksheet Line No.");
          SetRange("Worksheet Template Name",ReqLine."Worksheet Template Name");
          SetRange("Worksheet Batch Name",ReqLine."Journal Batch Name");
          SetRange("Worksheet Line No.",ReqLine."Line No.");
          DeleteAll;
          Reset;
          SetCurrentkey(Status,"Prod. Order No.",Active);
          SetRange(Status,ReqLine."Ref. Order Status");
          SetRange("Prod. Order No.",ReqLine."Ref. Order No.");
          SetRange(Active,true);
          ModifyAll(Active,false);
        end
    end;

    local procedure SynchronizeTransferProfiles(var InventoryProfile: Record "Inventory Profile";var TransferReqLine: Record "Requisition Line")
    var
        SupplyInvtProfile: Record "Inventory Profile";
    begin
        if InventoryProfile."Transfer Location Not Planned" then
          exit;
        SupplyInvtProfile.Copy(InventoryProfile);
        if GetTransferSisterProfile(SupplyInvtProfile,InventoryProfile) then begin
          TransferReqLineToInvProfiles(InventoryProfile,TransferReqLine);
          InventoryProfile.Modify;
        end;
        InventoryProfile.Copy(SupplyInvtProfile);
    end;

    local procedure TransferReqLineToInvProfiles(var InventoryProfile: Record "Inventory Profile";var TransferReqLine: Record "Requisition Line")
    begin
        with InventoryProfile do begin
          TestField("Location Code",TransferReqLine."Transfer-from Code");

          "Min. Quantity" := "Remaining Quantity (Base)";
          "Original Quantity" := TransferReqLine."Original Quantity";
          Quantity := TransferReqLine.Quantity;
          "Remaining Quantity" := TransferReqLine.Quantity;
          "Quantity (Base)" := TransferReqLine."Quantity (Base)";
          "Remaining Quantity (Base)" := TransferReqLine."Quantity (Base)";
          "Untracked Quantity" := TransferReqLine."Quantity (Base)";
          "Unit of Measure Code" := TransferReqLine."Unit of Measure Code";
          "Qty. per Unit of Measure" := TransferReqLine."Qty. per Unit of Measure";
          "Due Date" := TransferReqLine."Transfer Shipment Date";
        end;
    end;

    local procedure SyncTransferDemandWithReqLine(var InventoryProfile: Record "Inventory Profile";LocationCode: Code[10])
    var
        TransferReqLine: Record "Requisition Line";
    begin
        with TransferReqLine do begin
          SetRange("Ref. Order Type","ref. order type"::Transfer);
          SetRange("Ref. Order No.",InventoryProfile."Source ID");
          SetRange("Ref. Line No.",InventoryProfile."Source Ref. No.");
          SetRange("Transfer-from Code",InventoryProfile."Location Code");
          SetRange("Location Code",LocationCode);
          SetFilter("Action Message",'<>%1',"action message"::New);
          if FindFirst then
            TransferReqLineToInvProfiles(InventoryProfile,TransferReqLine);
        end;
    end;

    local procedure GetTransferSisterProfile(CurrInvProfile: Record "Inventory Profile";var SisterInvProfile: Record "Inventory Profile") Ok: Boolean
    begin
        // Finds the invprofile which represents the opposite side of a transfer order.
        if (CurrInvProfile."Source Type" <> Database::"Transfer Line") or
           (CurrInvProfile."Action Message" = CurrInvProfile."action message"::New)
        then
          exit(false);

        with SisterInvProfile do begin
          Clear(SisterInvProfile);
          SetRange("Source Type",Database::"Transfer Line");
          SetRange("Source ID",CurrInvProfile."Source ID");
          SetRange("Source Ref. No.",CurrInvProfile."Source Ref. No.");
          SetRange("Lot No.",CurrInvProfile."Lot No.");
          SetRange("Serial No.",CurrInvProfile."Serial No.");
          SetRange(IsSupply,not CurrInvProfile.IsSupply);

          Ok := Find('-');

          // Assertion: only 1 outbound transfer record may exist:
          if Ok then
            if Next <> 0 then
              Error(Text001,TableCaption);

          exit;
        end;
    end;

    local procedure AdjustTransferDates(var TransferReqLine: Record "Requisition Line")
    var
        TransferRoute: Record "Transfer Route";
        ShippingAgentServices: Record "Shipping Agent Services";
        Location: Record Location;
        SKU: Record "Stockkeeping Unit";
        ShippingTime: DateFormula;
        OutboundWhseTime: DateFormula;
        InboundWhseTime: DateFormula;
        OK: Boolean;
    begin
        // Used for planning lines handling transfer orders.
        // "Ending Date", Starting Date and "Transfer Shipment Date" are calculated backwards from "Due Date".

        TransferReqLine.TestField("Ref. Order Type",TransferReqLine."ref. order type"::Transfer);
        with TransferReqLine do begin
          OK := Location.Get("Transfer-from Code");
          if PlanningResilicency and not OK then
            if SKU.Get("Location Code","No.","Variant Code") then
              ReqLine.SetResiliencyError(
                StrSubstNo(
                  Text003,SKU.FieldCaption("Transfer-from Code"),SKU.TableCaption,
                  SKU."Location Code",SKU."Item No.",SKU."Variant Code"),
                Database::"Stockkeeping Unit",SKU.GetPosition);
          if not OK then
            Location.Get("Transfer-from Code");
          OutboundWhseTime := Location."Outbound Whse. Handling Time";

          Location.Get("Location Code");
          InboundWhseTime := Location."Inbound Whse. Handling Time";

          OK := TransferRoute.Get("Transfer-from Code","Location Code");
          if PlanningResilicency and not OK then
            ReqLine.SetResiliencyError(
              StrSubstNo(
                Text002,TransferRoute.TableCaption,
                "Transfer-from Code","Location Code"),
              Database::"Transfer Route",'');
          if not OK then
            TransferRoute.Get("Transfer-from Code","Location Code");

          if ShippingAgentServices.Get(TransferRoute."Shipping Agent Code",TransferRoute."Shipping Agent Service Code") then
            ShippingTime := ShippingAgentServices."Shipping Time"
          else
            Evaluate(ShippingTime,'');

          // The calculation will run through the following steps:
          // ShipmentDate <- PlannedShipmentDate <- PlannedReceiptDate <- ReceiptDate

          // Calc Planned Receipt Date (Ending Date) backward from ReceiptDate
          TransferRoute.CalcPlanReceiptDateBackward(
            "Ending Date","Due Date",InboundWhseTime,
            "Location Code",TransferRoute."Shipping Agent Code",TransferRoute."Shipping Agent Service Code");

          // Calc Planned Shipment Date (Starting Date) backward from Planned ReceiptDate (Ending Date)
          TransferRoute.CalcPlanShipmentDateBackward(
            "Starting Date","Ending Date",ShippingTime,
            "Transfer-from Code",TransferRoute."Shipping Agent Code",TransferRoute."Shipping Agent Service Code");

          // Calc Shipment Date backward from Planned Shipment Date (Starting Date)
          TransferRoute.CalcShipmentDateBackward(
            "Transfer Shipment Date","Starting Date",OutboundWhseTime,"Transfer-from Code");

          UpdateDatetime;
          Modify;
        end;
    end;

    local procedure InsertTempTransferSKU(var TransLine: Record "Transfer Line")
    var
        SKU: Record "Stockkeeping Unit";
    begin
        TempTransferSKU.Init;
        TempTransferSKU."Item No." := TransLine."Item No.";
        TempTransferSKU."Variant Code" := TransLine."Variant Code";
        if TransLine.Quantity > 0 then
          TempTransferSKU."Location Code" := TransLine."Transfer-to Code"
        else
          TempTransferSKU."Location Code" := TransLine."Transfer-from Code";
        if SKU.Get(TempTransferSKU."Location Code",TempTransferSKU."Item No.",TempTransferSKU."Variant Code") then
          TempTransferSKU."Transfer-from Code" := SKU."Transfer-from Code"
        else
          TempTransferSKU."Transfer-from Code" := '';
        if TempTransferSKU.Insert then;
    end;

    local procedure UpdateTempSKUTransferLevels()
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.Copy(TempSKU);
        with TempTransferSKU do begin
          Reset;
          if Find('-') then
            repeat
              TempSKU.Reset;
              if TempSKU.Get("Location Code","Item No.","Variant Code") then
                if TempSKU."Transfer-from Code" = '' then begin
                  TempSKU.SetRange("Location Code","Transfer-from Code");
                  TempSKU.SetRange("Item No.","Item No.");
                  TempSKU.SetRange("Variant Code","Variant Code");
                  if not TempSKU.Find('-') then
                    "Transfer-Level Code" := -1
                  else
                    "Transfer-Level Code" := TempSKU."Transfer-Level Code" - 1;
                  TempSKU.Get("Location Code","Item No.","Variant Code");
                  TempSKU."Transfer-from Code" := "Transfer-from Code";
                  TempSKU."Transfer-Level Code" := "Transfer-Level Code";
                  TempSKU.Modify;
                  TempSKU.UpdateTempSKUTransferLevels(TempSKU,TempSKU,TempSKU."Transfer-from Code");
                end;
            until Next = 0;
        end;
        TempSKU.Copy(SKU);
    end;

    local procedure CancelTransfer(var SupplyInvtProfile: Record "Inventory Profile";var DemandInvtProfile: Record "Inventory Profile";DemandExists: Boolean) Cancel: Boolean
    var
        xSupply2: Record "Inventory Profile";
    begin
        // Used to handle transfers where supply is planned with a higher Transfer Level Code than DemandInvtProfile.
        // If you encounter the demand before the SupplyInvtProfile, the supply must be removed.

        if not DemandExists then
          exit(false);
        if DemandInvtProfile."Source Type" <> Database::"Transfer Line" then
          exit(false);

        DemandInvtProfile.TestField(IsSupply,false);

        xSupply2.Copy(SupplyInvtProfile);
        if GetTransferSisterProfile(DemandInvtProfile,SupplyInvtProfile) then begin
          if SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::New then
            SupplyInvtProfile.FieldError("Action Message");

          if SupplyInvtProfile."Planning Flexibility" = SupplyInvtProfile."planning flexibility"::Unlimited then begin
            SupplyInvtProfile."Original Quantity" := SupplyInvtProfile.Quantity;
            SupplyInvtProfile."Max. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
            SupplyInvtProfile."Quantity (Base)" := SupplyInvtProfile."Min. Quantity";
            SupplyInvtProfile."Remaining Quantity (Base)" := SupplyInvtProfile."Min. Quantity";
            SupplyInvtProfile."Untracked Quantity" := 0;

            if SupplyInvtProfile."Remaining Quantity (Base)" = 0 then
              SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::Cancel
            else
              SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Change Qty.";
            SupplyInvtProfile.Modify;

            MaintainPlanningLine(SupplyInvtProfile,Planninglinestage::Exploded,Scheduledirection::Backward);
            Track(SupplyInvtProfile,DemandInvtProfile,true,false,SupplyInvtProfile.Binding::" ");
            SupplyInvtProfile.Delete;

            Cancel := (SupplyInvtProfile."Action Message" = SupplyInvtProfile."action message"::Cancel);

            // IF supply is fully cancelled, demand is deleted, otherwise demand is modified:
            if Cancel then
              DemandInvtProfile.Delete
            else begin
              DemandInvtProfile.Get(DemandInvtProfile."Line No."); // Get the updated version
              DemandInvtProfile."Untracked Quantity" -= (DemandInvtProfile."Original Quantity" - DemandInvtProfile."Quantity (Base)");
              DemandInvtProfile.Modify;
            end;
          end;
        end;
        SupplyInvtProfile.Copy(xSupply2);
    end;

    local procedure PostInvChgReminder(var InvChangeReminder: Record "Inventory Profile";InvProfile: Record "Inventory Profile";PostOnlyMinimum: Boolean)
    begin
        // Update information on changes in the Projected Inventory over time
        // Only the quantity that is known for sure should be posted

        OnBeforePostInvChgReminder(InvChangeReminder,InvProfile,PostOnlyMinimum);
        InvChangeReminder := InvProfile;

        if PostOnlyMinimum then begin
          InvChangeReminder."Remaining Quantity (Base)" -= InvProfile."Untracked Quantity";
          InvChangeReminder."Remaining Quantity (Base)" += InvProfile."Safety Stock Quantity";
        end;

        if not InvChangeReminder.Insert then
          InvChangeReminder.Modify;
        OnAfterPostInvChgReminder(InvChangeReminder,InvProfile,PostOnlyMinimum);
    end;

    local procedure QtyFromPendingReminders(var InvChangeReminder: Record "Inventory Profile";AtDate: Date;LatestBucketStartDate: Date) PendingQty: Decimal
    var
        xInvChangeReminder: Record "Inventory Profile";
    begin
        // Calculates the sum of queued up adjustments to the projected inventory level
        xInvChangeReminder.Copy(InvChangeReminder);

        InvChangeReminder.SetRange("Due Date",LatestBucketStartDate,AtDate);
        if InvChangeReminder.FindSet then
          repeat
            if InvChangeReminder.IsSupply then
              PendingQty += InvChangeReminder."Remaining Quantity (Base)"
            else
              PendingQty -= InvChangeReminder."Remaining Quantity (Base)";
          until InvChangeReminder.Next = 0;

        InvChangeReminder.Copy(xInvChangeReminder);
    end;

    local procedure MaintainProjectedInv(var InvChangeReminder: Record "Inventory Profile";AtDate: Date;var LastProjectedInventory: Decimal;var LatestBucketStartDate: Date;var ROPHasBeenCrossed: Boolean)
    var
        NextBucketEndDate: Date;
        NewProjectedInv: Decimal;
        SupplyIncrementQty: Decimal;
        DemandIncrementQty: Decimal;
    begin
        // Updates information about projected inventory up until AtDate or until reorder point is crossed.
        // The check is performed within time buckets.

        ROPHasBeenCrossed := false;
        LatestBucketStartDate := FindNextBucketStartDate(InvChangeReminder,AtDate,LatestBucketStartDate);
        NextBucketEndDate := LatestBucketStartDate + BucketSizeInDays - 1;

        while (NextBucketEndDate < AtDate) and not ROPHasBeenCrossed do begin
          InvChangeReminder.SetFilter("Due Date",'%1..%2',LatestBucketStartDate,NextBucketEndDate);
          SupplyIncrementQty := 0;
          DemandIncrementQty := 0;
          if InvChangeReminder.FindSet then
            repeat
              if InvChangeReminder.IsSupply then begin
                if InvChangeReminder."Order Relation" <> InvChangeReminder."order relation"::"Safety Stock" then
                  SupplyIncrementQty += InvChangeReminder."Remaining Quantity (Base)";
              end else
                DemandIncrementQty -= InvChangeReminder."Remaining Quantity (Base)";
              InvChangeReminder.Delete;
            until InvChangeReminder.Next = 0;

          NewProjectedInv := LastProjectedInventory + SupplyIncrementQty + DemandIncrementQty;
          if FutureSupplyWithinLeadtime > SupplyIncrementQty then
            FutureSupplyWithinLeadtime -= SupplyIncrementQty
          else
            FutureSupplyWithinLeadtime := 0;
          ROPHasBeenCrossed :=
            (LastProjectedInventory + SupplyIncrementQty > TempSKU."Reorder Point") and
            (NewProjectedInv <= TempSKU."Reorder Point") or
            (NewProjectedInv + FutureSupplyWithinLeadtime <= TempSKU."Reorder Point");
          LastProjectedInventory := NewProjectedInv;
          if ROPHasBeenCrossed then
            LatestBucketStartDate := NextBucketEndDate + 1
          else
            LatestBucketStartDate := FindNextBucketStartDate(InvChangeReminder,AtDate,LatestBucketStartDate);
          NextBucketEndDate := LatestBucketStartDate + BucketSizeInDays - 1;
        end;
    end;

    local procedure FindNextBucketStartDate(var InvChangeReminder: Record "Inventory Profile";AtDate: Date;LatestBucketStartDate: Date) NextBucketStartDate: Date
    var
        NumberOfDaysToNextReminder: Integer;
    begin
        if AtDate = 0D then
          exit(LatestBucketStartDate);

        InvChangeReminder.SetFilter("Due Date",'%1..%2',LatestBucketStartDate,AtDate);
        if InvChangeReminder.FindFirst then
          AtDate := InvChangeReminder."Due Date";

        NumberOfDaysToNextReminder := AtDate - LatestBucketStartDate;
        NextBucketStartDate := AtDate - (NumberOfDaysToNextReminder MOD BucketSizeInDays);
    end;

    local procedure SetIgnoreOverflow(var SupplyInvtProfile: Record "Inventory Profile")
    begin
        // Apply a minimum quantity to the existing orders to protect the
        // remaining valid surplus from being reduced in the common balancing act

        with SupplyInvtProfile do begin
          if FindSet(true) then
            repeat
              "Min. Quantity" := "Remaining Quantity (Base)";
              Modify;
            until Next = 0;
        end;
    end;

    local procedure ChkInitialOverflow(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile";OverflowLevel: Decimal;InventoryLevel: Decimal;FromDate: Date;ToDate: Date)
    var
        xDemandInvtProfile: Record "Inventory Profile";
        xSupplyInvtProfile: Record "Inventory Profile";
        OverflowQty: Decimal;
        OriginalSupplyQty: Decimal;
        DecreasedSupplyQty: Decimal;
        PrevBucketStartDate: Date;
        PrevBucketEndDate: Date;
        CurrBucketStartDate: Date;
        CurrBucketEndDate: Date;
        NumberOfDaysToNextSupply: Integer;
    begin
        xDemandInvtProfile.Copy(DemandInvtProfile);
        xSupplyInvtProfile.Copy(SupplyInvtProfile);
        SupplyInvtProfile.SetRange("Is Exception Order",false);

        if OverflowLevel > 0 then begin
          // Detect if there is overflow in inventory within any time bucket
          // In that case: Decrease superfluous Supply; latest first
          // Apply a minimum quantity to the existing orders to protect the
          // remaining valid surplus from being reduced in the common balancing act

          // Avoid Safety Stock Demand
          DemandInvtProfile.SetRange("Order Relation",DemandInvtProfile."order relation"::Normal);

          PrevBucketStartDate := FromDate;
          CurrBucketEndDate := ToDate;

          while PrevBucketStartDate <= ToDate do begin
            SupplyInvtProfile.SetRange("Due Date",PrevBucketStartDate,ToDate);
            if SupplyInvtProfile.FindFirst then begin
              NumberOfDaysToNextSupply := SupplyInvtProfile."Due Date" - PrevBucketStartDate;
              CurrBucketEndDate :=
                SupplyInvtProfile."Due Date" - (NumberOfDaysToNextSupply MOD BucketSizeInDays) + BucketSizeInDays - 1;
              CurrBucketStartDate := CurrBucketEndDate - BucketSizeInDays + 1;
              PrevBucketEndDate := CurrBucketStartDate - 1;

              DemandInvtProfile.SetRange("Due Date",PrevBucketStartDate,PrevBucketEndDate);
              if DemandInvtProfile.FindSet then
                repeat
                  InventoryLevel -= DemandInvtProfile."Remaining Quantity (Base)";
                until DemandInvtProfile.Next = 0;

              // Negative inventory from previous buckets shall not influence
              // possible overflow in the current time bucket
              if InventoryLevel < 0 then
                InventoryLevel := 0;

              DemandInvtProfile.SetRange("Due Date",CurrBucketStartDate,CurrBucketEndDate);
              if DemandInvtProfile.FindSet then
                repeat
                  InventoryLevel -= DemandInvtProfile."Remaining Quantity (Base)";
                until DemandInvtProfile.Next = 0;

              SupplyInvtProfile.SetRange("Due Date",CurrBucketStartDate,CurrBucketEndDate);
              if SupplyInvtProfile.Find('-') then begin
                repeat
                  InventoryLevel += SupplyInvtProfile."Remaining Quantity (Base)";
                until SupplyInvtProfile.Next = 0;

                OverflowQty := InventoryLevel - OverflowLevel;
                repeat
                  if OverflowQty > 0 then begin
                    OriginalSupplyQty := SupplyInvtProfile."Quantity (Base)";
                    SupplyInvtProfile."Min. Quantity" := 0;
                    DecreaseQty(SupplyInvtProfile,OverflowQty);

                    // If the supply has not been decreased as planned, try to cancel it.
                    DecreasedSupplyQty := SupplyInvtProfile."Quantity (Base)";
                    if (DecreasedSupplyQty > 0) and (OriginalSupplyQty - DecreasedSupplyQty < OverflowQty) and
                       (SupplyInvtProfile."Order Priority" < 1000)
                    then
                      if CanDecreaseSupply(SupplyInvtProfile,OverflowQty) then
                        DecreaseQty(SupplyInvtProfile,DecreasedSupplyQty);

                    if OriginalSupplyQty <> SupplyInvtProfile."Quantity (Base)" then begin
                      DummyInventoryProfileTrackBuffer."Warning Level" := DummyInventoryProfileTrackBuffer."warning level"::Attention;
                      PlanningTransparency.LogWarning(
                        SupplyInvtProfile."Line No.",ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                        StrSubstNo(Text010,InventoryLevel,OverflowLevel,CurrBucketEndDate));
                      OverflowQty -= (OriginalSupplyQty - SupplyInvtProfile."Quantity (Base)");
                      InventoryLevel -= (OriginalSupplyQty - SupplyInvtProfile."Quantity (Base)");
                    end;
                  end;
                  SupplyInvtProfile."Min. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
                  SupplyInvtProfile.Modify;
                  if SupplyInvtProfile."Line No." = xSupplyInvtProfile."Line No." then
                    xSupplyInvtProfile := SupplyInvtProfile;
                until (SupplyInvtProfile.Next(-1) = 0);
              end;

              if InventoryLevel < 0 then
                InventoryLevel := 0;
              PrevBucketStartDate := CurrBucketEndDate + 1;
            end else
              PrevBucketStartDate := ToDate + 1;
          end;
        end else
          if OverflowLevel = 0 then
            SetIgnoreOverflow(SupplyInvtProfile);

        DemandInvtProfile.Copy(xDemandInvtProfile);
        SupplyInvtProfile.Copy(xSupplyInvtProfile);
    end;

    local procedure CheckNewOverflow(var SupplyInvtProfile: Record "Inventory Profile";InventoryLevel: Decimal;QtyToDecreaseOverFlow: Decimal;LastDueDate: Date)
    var
        xSupplyInvtProfile: Record "Inventory Profile";
        OriginalSupplyQty: Decimal;
        QtyToDecrease: Decimal;
    begin
        // the function tries to avoid overflow when a new supply was suggested
        xSupplyInvtProfile.Copy(SupplyInvtProfile);
        SupplyInvtProfile.SetRange("Due Date",LastDueDate + 1,PlanToDate);
        SupplyInvtProfile.SetFilter("Remaining Quantity (Base)",'>0');

        if SupplyInvtProfile.FindSet(true) then
          repeat
            if SupplyInvtProfile."Original Quantity" > 0 then
              InventoryLevel := InventoryLevel + SupplyInvtProfile."Original Quantity" * SupplyInvtProfile."Qty. per Unit of Measure"
            else
              InventoryLevel := InventoryLevel + SupplyInvtProfile."Remaining Quantity (Base)";
            OriginalSupplyQty := SupplyInvtProfile."Quantity (Base)";

            if InventoryLevel > OverflowLevel then begin
              SupplyInvtProfile."Min. Quantity" := 0;
              DummyInventoryProfileTrackBuffer."Warning Level" := DummyInventoryProfileTrackBuffer."warning level"::Attention;
              QtyToDecrease := InventoryLevel - OverflowLevel;

              if QtyToDecrease > QtyToDecreaseOverFlow then
                QtyToDecrease := QtyToDecreaseOverFlow;

              if QtyToDecrease > SupplyInvtProfile."Remaining Quantity (Base)" then
                QtyToDecrease := SupplyInvtProfile."Remaining Quantity (Base)";

              DecreaseQty(SupplyInvtProfile,QtyToDecrease);

              PlanningTransparency.LogWarning(
                SupplyInvtProfile."Line No.",ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                StrSubstNo(Text010,InventoryLevel,OverflowLevel,SupplyInvtProfile."Due Date"));

              QtyToDecreaseOverFlow := QtyToDecreaseOverFlow - (OriginalSupplyQty - SupplyInvtProfile."Quantity (Base)");
              InventoryLevel := InventoryLevel - (OriginalSupplyQty - SupplyInvtProfile."Quantity (Base)");
              SupplyInvtProfile."Min. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
              SupplyInvtProfile.Modify;
            end;
          until (SupplyInvtProfile.Next = 0) or (QtyToDecreaseOverFlow <= 0);

        SupplyInvtProfile.Copy(xSupplyInvtProfile);
    end;

    local procedure CheckScheduleIn(var SupplyInvtProfile: Record "Inventory Profile";TargetDate: Date;var PossibleDate: Date;LimitedHorizon: Boolean): Boolean
    begin
        if SupplyInvtProfile."Planning Flexibility" <> SupplyInvtProfile."planning flexibility"::Unlimited then
          exit(false);

        if LimitedHorizon and not AllowScheduleIn(SupplyInvtProfile,TargetDate) then
          PossibleDate := SupplyInvtProfile."Due Date"
        else
          PossibleDate := TargetDate;

        exit(TargetDate = PossibleDate);
    end;

    local procedure CheckScheduleOut(var SupplyInvtProfile: Record "Inventory Profile";TargetDate: Date;var PossibleDate: Date;LimitedHorizon: Boolean): Boolean
    begin
        OnBeforeCheckScheduleOut(SupplyInvtProfile,TempSKU,BucketSize);

        if SupplyInvtProfile."Planning Flexibility" <> SupplyInvtProfile."planning flexibility"::Unlimited then
          exit(false);

        if (TargetDate - SupplyInvtProfile."Due Date") <= DampenersDays then
          PossibleDate := SupplyInvtProfile."Due Date"
        else
          if not LimitedHorizon or
             (SupplyInvtProfile."Planning Level Code" > 0)
          then
            PossibleDate := TargetDate
          else
            if AllowScheduleOut(SupplyInvtProfile,TargetDate) then
              PossibleDate := TargetDate
            else begin
              // Do not reschedule but may be lot accumulation is still an option
              PossibleDate := SupplyInvtProfile."Due Date";
              if SupplyInvtProfile."Fixed Date" <> 0D then
                exit(AllowLotAccumulation(SupplyInvtProfile,TargetDate));
              exit(false);
            end;

        // Limit possible rescheduling in case the supply is already linked up to another demand
        if (SupplyInvtProfile."Fixed Date" <> 0D) and
           (SupplyInvtProfile."Fixed Date" < PossibleDate)
        then begin
          if not AllowLotAccumulation(SupplyInvtProfile,TargetDate) then // but reschedule only if lot accumulation is allowed for target date
            exit(false);

          PossibleDate := SupplyInvtProfile."Fixed Date";
        end;

        exit(true);
    end;

    local procedure CheckSupplyWithSKU(var InventoryProfile: Record "Inventory Profile";var SKU: Record "Stockkeeping Unit")
    var
        xInventoryProfile: Record "Inventory Profile";
    begin
        xInventoryProfile.Copy(InventoryProfile);

        with InventoryProfile do begin
          if SKU."Maximum Order Quantity" > 0 then
            if Find('-') then
              repeat
                if (SKU."Maximum Order Quantity" > "Max. Quantity") and
                   ("Quantity (Base)" > 0) and
                   ("Max. Quantity" = 0)
                then begin
                  "Max. Quantity" := SKU."Maximum Order Quantity";
                  Modify;
                end;
              until Next = 0;
        end;
        InventoryProfile.Copy(xInventoryProfile);
        if InventoryProfile.Get(InventoryProfile."Line No.") then;
    end;

    local procedure CreateSupplyForward(var SupplyInvtProfile: Record "Inventory Profile";AtDate: Date;ProjectedInventory: Decimal;var NewSupplyHasTakenOver: Boolean;CurrDueDate: Date)
    var
        TempSupplyInvtProfile: Record "Inventory Profile" temporary;
        CurrSupplyInvtProfile: Record "Inventory Profile";
        LeadTimeEndDate: Date;
        QtyToOrder: Decimal;
        QtyToOrderThisLine: Decimal;
        SupplyWithinLeadtime: Decimal;
        HasLooped: Boolean;
        CurrSupplyExists: Boolean;
        QtyToDecreaseOverFlow: Decimal;
    begin
        // Save current supply and check if it is real
        CurrSupplyInvtProfile := SupplyInvtProfile;
        CurrSupplyExists := SupplyInvtProfile.Find('=');

        // Initiate new supplyprofile
        InitSupply(TempSupplyInvtProfile,0,AtDate);

        // Make sure VAR boolean is reset:
        NewSupplyHasTakenOver := false;
        QtyToOrder := CalcOrderQty(QtyToOrder,ProjectedInventory,TempSupplyInvtProfile."Line No.");

        // Use new supplyprofile to determine lead-time
        UpdateQty(TempSupplyInvtProfile,QtyToOrder + AdjustReorderQty(QtyToOrder,TempSKU,TempSupplyInvtProfile."Line No.",0));
        TempSupplyInvtProfile.Insert;
        ScheduleForward(TempSupplyInvtProfile,AtDate);
        LeadTimeEndDate := TempSupplyInvtProfile."Due Date";

        // Find supply within leadtime, returns a qty
        SupplyWithinLeadtime := SumUpProjectedSupply(SupplyInvtProfile,AtDate,LeadTimeEndDate);
        FutureSupplyWithinLeadtime := SupplyWithinLeadtime;

        // If found supply + projinvlevel covers ROP then the situation has already been taken care of: roll back and (exit)
        if SupplyWithinLeadtime + ProjectedInventory > TempSKU."Reorder Point" then begin
          // Delete obsolete Planning Line
          MaintainPlanningLine(TempSupplyInvtProfile,Planninglinestage::Obsolete,Scheduledirection::Backward);
          PlanningTransparency.CleanLog(TempSupplyInvtProfile."Line No.");
          exit;
        end;

        // If Max: Deduct found supply in order to stay below max inventory and adjust transparency log
        if TempSKU."Reordering Policy" = TempSKU."reordering policy"::"Maximum Qty." then
          if SupplyWithinLeadtime <> 0 then begin
            QtyToOrder -= SupplyWithinLeadtime;
            PlanningTransparency.ModifyLogEntry(
              TempSupplyInvtProfile."Line No.",0,Database::Item,TempSKU."Item No.",-SupplyWithinLeadtime,
              Surplustype::MaxInventory);
          end;

        LeadTimeEndDate := AtDate;

        while QtyToOrder > 0 do begin
          // In case of max order the new supply could be split in several new supplies:
          if HasLooped then begin
            InitSupply(TempSupplyInvtProfile,0,AtDate);
            case TempSKU."Reordering Policy" of
              TempSKU."reordering policy"::"Maximum Qty.":
                SurplusType := Surplustype::MaxInventory;
              TempSKU."reordering policy"::"Fixed Reorder Qty.":
                SurplusType := Surplustype::FixedOrderQty;
            end;
            PlanningTransparency.LogSurplus(TempSupplyInvtProfile."Line No.",0,0,'',QtyToOrder,SurplusType);
            QtyToOrderThisLine := QtyToOrder + AdjustReorderQty(QtyToOrder,TempSKU,TempSupplyInvtProfile."Line No.",0);
            UpdateQty(TempSupplyInvtProfile,QtyToOrderThisLine);
            TempSupplyInvtProfile.Insert;
            ScheduleForward(TempSupplyInvtProfile,AtDate);
          end else begin
            QtyToOrderThisLine := QtyToOrder + AdjustReorderQty(QtyToOrder,TempSKU,TempSupplyInvtProfile."Line No.",0);
            if QtyToOrderThisLine <> TempSupplyInvtProfile."Remaining Quantity (Base)" then begin
              UpdateQty(TempSupplyInvtProfile,QtyToOrderThisLine);
              ScheduleForward(TempSupplyInvtProfile,AtDate);
            end;
            HasLooped := true;
          end;

          // The supply is inserted into the overall supply dataset
          SupplyInvtProfile := TempSupplyInvtProfile;
          TempSupplyInvtProfile.Delete;
          SupplyInvtProfile."Min. Quantity" := SupplyInvtProfile."Remaining Quantity (Base)";
          SupplyInvtProfile."Max. Quantity" := TempSKU."Maximum Order Quantity";
          SupplyInvtProfile."Fixed Date" := SupplyInvtProfile."Due Date";
          SupplyInvtProfile."Order Priority" := 1000; // Make sure to give last priority if supply exists on the same date
          SupplyInvtProfile."Attribute Priority" := 1000;
          SupplyInvtProfile.Insert;

          // Planning Transparency
          PlanningTransparency.LogSurplus(
            SupplyInvtProfile."Line No.",0,0,'',SupplyInvtProfile."Untracked Quantity",Surplustype::ReorderPoint);

          if SupplyInvtProfile."Due Date" < CurrDueDate then begin
            CurrSupplyInvtProfile := SupplyInvtProfile;
            CurrDueDate := SupplyInvtProfile."Due Date";
            NewSupplyHasTakenOver := true
          end;

          if LeadTimeEndDate < SupplyInvtProfile."Due Date" then
            LeadTimeEndDate := SupplyInvtProfile."Due Date";

          if (not CurrSupplyExists) or
             (SupplyInvtProfile."Due Date" < CurrSupplyInvtProfile."Due Date")
          then begin
            CurrSupplyInvtProfile := SupplyInvtProfile;
            CurrSupplyExists := true;
            NewSupplyHasTakenOver := CurrSupplyInvtProfile."Due Date" <= CurrDueDate;
          end;

          QtyToOrder -= SupplyInvtProfile."Remaining Quantity (Base)";
          FutureSupplyWithinLeadtime += SupplyInvtProfile."Remaining Quantity (Base)";
          QtyToDecreaseOverFlow += SupplyInvtProfile."Quantity (Base)";
        end;

        if HasLooped and (OverflowLevel > 0) then
          // the new supply might cause overflow in inventory since
          // it wasn't considered when Overflow was calculated
          CheckNewOverflow(SupplyInvtProfile,ProjectedInventory + QtyToDecreaseOverFlow,QtyToDecreaseOverFlow,LeadTimeEndDate);

        SupplyInvtProfile := CurrSupplyInvtProfile;
    end;

    local procedure AllowScheduleIn(SupplyInvtProfile: Record "Inventory Profile";TargetDate: Date) CanReschedule: Boolean
    begin
        CanReschedule := CalcDate(TempSKU."Rescheduling Period",TargetDate) >= SupplyInvtProfile."Due Date";
    end;

    local procedure AllowScheduleOut(SupplyInvtProfile: Record "Inventory Profile";TargetDate: Date) CanReschedule: Boolean
    begin
        CanReschedule := CalcDate(TempSKU."Rescheduling Period",SupplyInvtProfile."Due Date") >= TargetDate;
    end;

    local procedure AllowLotAccumulation(SupplyInvtProfile: Record "Inventory Profile";DemandDueDate: Date) AccumulationOK: Boolean
    begin
        AccumulationOK := CalcDate(TempSKU."Lot Accumulation Period",SupplyInvtProfile."Due Date") >= DemandDueDate;
    end;

    local procedure ShallSupplyBeClosed(SupplyInventoryProfile: Record "Inventory Profile";DemandDueDate: Date;IsReorderPointPlanning: Boolean): Boolean
    var
        CloseSupply: Boolean;
    begin
        if SupplyInventoryProfile."Is Exception Order" then begin
          if TempSKU."Reordering Policy" = TempSKU."reordering policy"::"Lot-for-Lot" then
            // supply within Lot Accumulation Period will be summed up with Exception order
            CloseSupply := not AllowLotAccumulation(SupplyInventoryProfile,DemandDueDate)
          else
            // only demand in the same day as Exception will be summed up
            CloseSupply := SupplyInventoryProfile."Due Date" <> DemandDueDate;
        end else
          CloseSupply := IsReorderPointPlanning;

        exit(CloseSupply);
    end;

    local procedure NextLineNo(): Integer
    begin
        LineNo += 1;
        exit(LineNo);
    end;

    local procedure Reschedule(var SupplyInvtProfile: Record "Inventory Profile";TargetDate: Date;TargetTime: Time)
    begin
        SupplyInvtProfile.TestField("Planning Flexibility",SupplyInvtProfile."planning flexibility"::Unlimited);

        if (TargetDate <> SupplyInvtProfile."Due Date") and
           (SupplyInvtProfile."Action Message" <> SupplyInvtProfile."action message"::New)
        then begin
          if SupplyInvtProfile."Original Due Date" = 0D then
            SupplyInvtProfile."Original Due Date" := SupplyInvtProfile."Due Date";
          if SupplyInvtProfile."Original Quantity" = 0 then
            SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::Reschedule
          else
            SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::"Resched.& Chg. Qty.";
        end;
        SupplyInvtProfile."Due Date" := TargetDate;
        if (SupplyInvtProfile."Due Time" = 0T) or
           (SupplyInvtProfile."Due Time" > TargetTime)
        then
          SupplyInvtProfile."Due Time" := TargetTime;
        SupplyInvtProfile.Modify;
    end;

    local procedure InitSupply(var SupplyInvtProfile: Record "Inventory Profile";OrderQty: Decimal;DueDate: Date)
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        SupplyInvtProfile.Init;
        SupplyInvtProfile."Line No." := NextLineNo;
        SupplyInvtProfile."Item No." := TempSKU."Item No.";
        SupplyInvtProfile."Variant Code" := TempSKU."Variant Code";
        SupplyInvtProfile."Location Code" := TempSKU."Location Code";
        SupplyInvtProfile."Action Message" := SupplyInvtProfile."action message"::New;
        UpdateQty(SupplyInvtProfile,OrderQty);
        SupplyInvtProfile."Due Date" := DueDate;
        SupplyInvtProfile.IsSupply := true;
        Item.Get(TempSKU."Item No.");
        SupplyInvtProfile."Unit of Measure Code" := Item."Base Unit of Measure";
        SupplyInvtProfile."Qty. per Unit of Measure" := 1;

        case TempSKU."Replenishment System" of
          TempSKU."replenishment system"::Purchase:
            begin
              SupplyInvtProfile."Source Type" := Database::"Purchase Line";
              SupplyInvtProfile."Unit of Measure Code" := Item."Purch. Unit of Measure";
              if SupplyInvtProfile."Unit of Measure Code" <> Item."Base Unit of Measure" then begin
                ItemUnitOfMeasure.Get(TempSKU."Item No.",Item."Purch. Unit of Measure");
                SupplyInvtProfile."Qty. per Unit of Measure" := ItemUnitOfMeasure."Qty. per Unit of Measure";
              end;
            end;
          TempSKU."replenishment system"::"Prod. Order":
            SupplyInvtProfile."Source Type" := Database::"Prod. Order Line";
          TempSKU."replenishment system"::Assembly:
            SupplyInvtProfile."Source Type" := Database::"Assembly Header";
          TempSKU."replenishment system"::Transfer:
            SupplyInvtProfile."Source Type" := Database::"Transfer Line";
        end;
    end;

    local procedure UpdateQty(var InvProfile: Record "Inventory Profile";Qty: Decimal)
    begin
        with InvProfile do begin
          "Untracked Quantity" := Qty;
          "Quantity (Base)" := "Untracked Quantity";
          "Remaining Quantity (Base)" := "Quantity (Base)";
        end;
    end;

    local procedure TransferAttributes(var ToInvProfile: Record "Inventory Profile";var FromInvProfile: Record "Inventory Profile")
    begin
        if SpecificLotTracking then
          ToInvProfile."Lot No." := FromInvProfile."Lot No.";
        if SpecificSNTracking then
          ToInvProfile."Serial No." := FromInvProfile."Serial No.";

        if TempSKU."Replenishment System" = TempSKU."replenishment system"::"Prod. Order" then
          if FromInvProfile."Planning Level Code" > 0 then begin
            ToInvProfile.Binding := ToInvProfile.Binding::"Order-to-Order";
            ToInvProfile."Planning Level Code" := FromInvProfile."Planning Level Code";
            ToInvProfile."Due Time" := FromInvProfile."Due Time";
            ToInvProfile."Bin Code" := FromInvProfile."Bin Code";
          end;

        if FromInvProfile.Binding = FromInvProfile.Binding::"Order-to-Order" then begin
          ToInvProfile.Binding := ToInvProfile.Binding::"Order-to-Order";
          ToInvProfile."Primary Order Status" := FromInvProfile."Primary Order Status";
          ToInvProfile."Primary Order No." := FromInvProfile."Primary Order No.";
          ToInvProfile."Primary Order Line" := FromInvProfile."Primary Order Line";
        end;

        ToInvProfile."MPS Order" := FromInvProfile."MPS Order";

        if ToInvProfile.TrackingExists then
          ToInvProfile."Planning Flexibility" := ToInvProfile."planning flexibility"::None;
    end;

    local procedure AllocateSafetystock(var SupplyInvtProfile: Record "Inventory Profile";QtyToAllocate: Decimal;AtDate: Date)
    var
        MinQtyToCoverSafetyStock: Decimal;
    begin
        if QtyToAllocate > SupplyInvtProfile."Safety Stock Quantity" then begin
          SupplyInvtProfile."Safety Stock Quantity" := QtyToAllocate;
          MinQtyToCoverSafetyStock :=
            SupplyInvtProfile."Remaining Quantity (Base)" -
            SupplyInvtProfile."Untracked Quantity" + SupplyInvtProfile."Safety Stock Quantity";
          if SupplyInvtProfile."Min. Quantity" < MinQtyToCoverSafetyStock then
            SupplyInvtProfile."Min. Quantity" := MinQtyToCoverSafetyStock;
          if SupplyInvtProfile."Min. Quantity" > SupplyInvtProfile."Remaining Quantity (Base)" then
            Error(Text001,SupplyInvtProfile.FieldCaption("Safety Stock Quantity"));
          if (SupplyInvtProfile."Fixed Date" = 0D) or (SupplyInvtProfile."Fixed Date" > AtDate) then
            SupplyInvtProfile."Fixed Date" := AtDate;
          SupplyInvtProfile.Modify;
        end;
    end;

    local procedure SumUpProjectedSupply(var SupplyInvtProfile: Record "Inventory Profile";FromDate: Date;ToDate: Date) ProjectedQty: Decimal
    var
        xSupplyInvtProfile: Record "Inventory Profile";
    begin
        // Sums up the contribution to the projected inventory

        xSupplyInvtProfile.Copy(SupplyInvtProfile);
        SupplyInvtProfile.SetRange("Due Date",FromDate,ToDate);

        if SupplyInvtProfile.FindSet then
          repeat
            if (SupplyInvtProfile.Binding <> SupplyInvtProfile.Binding::"Order-to-Order") and
               (SupplyInvtProfile."Order Relation" <> SupplyInvtProfile."order relation"::"Safety Stock")
            then
              ProjectedQty += SupplyInvtProfile."Remaining Quantity (Base)";
          until SupplyInvtProfile.Next = 0;

        SupplyInvtProfile.Copy(xSupplyInvtProfile);
    end;

    local procedure SumUpAvailableSupply(var SupplyInvtProfile: Record "Inventory Profile";FromDate: Date;ToDate: Date) AvailableQty: Decimal
    var
        xSupplyInvtProfile: Record "Inventory Profile";
    begin
        // Sums up the contribution to the available inventory

        xSupplyInvtProfile.Copy(SupplyInvtProfile);
        SupplyInvtProfile.SetRange("Due Date",FromDate,ToDate);

        if SupplyInvtProfile.FindSet then
          repeat
            AvailableQty += SupplyInvtProfile."Untracked Quantity";
          until SupplyInvtProfile.Next = 0;

        SupplyInvtProfile.Copy(xSupplyInvtProfile);
    end;

    local procedure SetPriority(var InvProfile: Record "Inventory Profile";IsReorderPointPlanning: Boolean;ToDate: Date)
    begin
        with InvProfile do begin
          if IsSupply then begin
            if "Due Date" > ToDate then
              "Planning Flexibility" := "planning flexibility"::None;

            if IsReorderPointPlanning and (Binding <> Binding::"Order-to-Order") and
               ("Planning Flexibility" <> "planning flexibility"::None)
            then
              "Planning Flexibility" := "planning flexibility"::"Reduce Only";

            case "Source Type" of
              Database::"Item Ledger Entry":
                "Order Priority" := 100;
              Database::"Sales Line":
                case "Source Order Status" of // Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order
                  5:
                    "Order Priority" := 200; // Return Order
                  1:
                    "Order Priority" := 200; // Negative Sales Order
                end;
              Database::"Job Planning Line":
                "Order Priority" := 230;
              Database::"Transfer Line",Database::"Requisition Line",Database::"Planning Component":
                "Order Priority" := 300;
              Database::"Assembly Header":
                "Order Priority" := 320;
              Database::"Prod. Order Line":
                case "Source Order Status" of // Simulated,Planned,Firm Planned,Released,Finished
                  3:
                    "Order Priority" := 400; // Released
                  2:
                    "Order Priority" := 410; // Firm Planned
                  1:
                    "Order Priority" := 420; // Planned
                end;
              Database::"Purchase Line":
                "Order Priority" := 500;
              Database::"Prod. Order Component":
                case "Source Order Status" of // Simulated,Planned,Firm Planned,Released,Finished
                  3:
                    "Order Priority" := 600; // Released
                  2:
                    "Order Priority" := 610; // Firm Planned
                  1:
                    "Order Priority" := 620; // Planned
                end;
            end;
          end else  // Demand
            case "Source Type" of
              Database::"Item Ledger Entry":
                "Order Priority" := 100;
              Database::"Purchase Line":
                "Order Priority" := 200;
              Database::"Sales Line":
                case "Source Order Status" of // Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order
                  1:
                    "Order Priority" := 300; // Order
                  4:
                    "Order Priority" := 700; // Blanket Order
                  5:
                    "Order Priority" := 300; // Negative Return Order
                end;
              Database::"Service Line":
                "Order Priority" := 400;
              Database::"Job Planning Line":
                "Order Priority" := 450;
              Database::"Assembly Line":
                "Order Priority" := 470;
              Database::"Prod. Order Component":
                case "Source Order Status" of // Simulated,Planned,Firm Planned,Released,Finished
                  3:
                    "Order Priority" := 500; // Released
                  2:
                    "Order Priority" := 510; // Firm Planned
                  1:
                    "Order Priority" := 520; // Planned
                end;
              Database::"Transfer Line",Database::"Requisition Line",Database::"Planning Component":
                "Order Priority" := 600;
              Database::"Production Forecast Entry":
                "Order Priority" := 800;
            end;

          OnAfterSetOrderPriority(InvProfile);

          TestField("Order Priority");

          // Inflexible supply must be handled before all other supply and is therefore grouped
          // together with inventory in group 100:
          if IsSupply and ("Source Type" <> Database::"Item Ledger Entry") then
            if "Planning Flexibility" <> "planning flexibility"::Unlimited then
              "Order Priority" := 100 + ("Order Priority" / 10);

          if "Planning Flexibility" = "planning flexibility"::Unlimited then
            if ActiveInWarehouse then
              "Order Priority" -= 1;

          SetAttributePriority(InvProfile);

          Modify;
        end;
    end;

    local procedure SetAttributePriority(var InvProfile: Record "Inventory Profile")
    var
        HandleLot: Boolean;
        HandleSN: Boolean;
    begin
        with InvProfile do begin
          HandleSN := ("Serial No." <> '') and SpecificSNTracking;
          HandleLot := ("Lot No." <> '') and SpecificLotTracking;

          if HandleSN then begin
            if HandleLot then
              if Binding = Binding::"Order-to-Order" then
                "Attribute Priority" := 1
              else
                "Attribute Priority" := 4
            else
              if Binding = Binding::"Order-to-Order" then
                "Attribute Priority" := 2
              else
                "Attribute Priority" := 5;
          end else begin
            if HandleLot then
              if Binding = Binding::"Order-to-Order" then
                "Attribute Priority" := 3
              else
                "Attribute Priority" := 6
            else
              if Binding = Binding::"Order-to-Order" then
                "Attribute Priority" := 7
              else
                "Attribute Priority" := 8;
          end;
        end;
    end;

    local procedure UpdatePriorities(var InvProfile: Record "Inventory Profile";IsReorderPointPlanning: Boolean;ToDate: Date)
    var
        xInvProfile: Record "Inventory Profile";
    begin
        xInvProfile.Copy(InvProfile);
        InvProfile.SetCurrentkey("Line No.");
        if InvProfile.FindSet(true) then
          repeat
            SetPriority(InvProfile,IsReorderPointPlanning,ToDate);
          until InvProfile.Next = 0;
        InvProfile.Copy(xInvProfile);
    end;

    local procedure InsertSafetyStockDemands(var DemandInvtProfile: Record "Inventory Profile";PlanningStartDate: Date)
    var
        xDemandInvtProfile: Record "Inventory Profile";
        TempSafetyStockInvtProfile: Record "Inventory Profile" temporary;
        OrderRelation: Option Normal,"Safety Stock","Reorder Point";
    begin
        if TempSKU."Safety Stock Quantity" = 0 then
          exit;
        xDemandInvtProfile.Copy(DemandInvtProfile);

        DemandInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");
        DemandInvtProfile.SetFilter("Due Date",'%1..',PlanningStartDate);

        if DemandInvtProfile.FindSet then
          repeat
            if TempSafetyStockInvtProfile."Due Date" <> DemandInvtProfile."Due Date" then
              CreateDemand(
                TempSafetyStockInvtProfile,TempSKU,TempSKU."Safety Stock Quantity",
                DemandInvtProfile."Due Date",Orderrelation::"Safety Stock");
          until DemandInvtProfile.Next = 0;

        DemandInvtProfile.SetRange("Due Date",PlanningStartDate);
        if DemandInvtProfile.IsEmpty then
          CreateDemand(
            TempSafetyStockInvtProfile,TempSKU,TempSKU."Safety Stock Quantity",PlanningStartDate,Orderrelation::"Safety Stock");

        if TempSafetyStockInvtProfile.FindSet(true) then
          repeat
            DemandInvtProfile := TempSafetyStockInvtProfile;
            DemandInvtProfile."Order Priority" := 1000;
            DemandInvtProfile.Insert;
          until TempSafetyStockInvtProfile.Next = 0;

        DemandInvtProfile.Copy(xDemandInvtProfile);

        OnAfterInsertSafetyStockDemands(
          DemandInvtProfile,xDemandInvtProfile,TempSafetyStockInvtProfile,TempSKU,PlanningStartDate,PlanToDate);
    end;

    local procedure ScheduleAllOutChangesSequence(var SupplyInvtProfile: Record "Inventory Profile";NewDate: Date): Boolean
    var
        xSupplyInvtProfile: Record "Inventory Profile";
        TempRescheduledSupplyInvtProfile: Record "Inventory Profile" temporary;
        TryRescheduleSupply: Boolean;
        HasLooped: Boolean;
        Continue: Boolean;
        NumberofSupplies: Integer;
    begin
        xSupplyInvtProfile.Copy(SupplyInvtProfile);
        if (SupplyInvtProfile."Due Date" = 0D) or
           (SupplyInvtProfile."Planning Flexibility" <> SupplyInvtProfile."planning flexibility"::Unlimited)
        then
          exit(false);

        if not AllowScheduleOut(SupplyInvtProfile,NewDate) then
          exit(false);

        Continue := true;
        TryRescheduleSupply := true;

        while Continue do begin
          NumberofSupplies += 1;
          TempRescheduledSupplyInvtProfile := SupplyInvtProfile;
          TempRescheduledSupplyInvtProfile."Line No." := -TempRescheduledSupplyInvtProfile."Line No."; // Use negative Line No. to shift sequence
          TempRescheduledSupplyInvtProfile.Insert;
          if TryRescheduleSupply then begin
            Reschedule(TempRescheduledSupplyInvtProfile,NewDate,0T);
            Continue := TempRescheduledSupplyInvtProfile."Due Date" <> SupplyInvtProfile."Due Date";
          end;
          if Continue then
            if SupplyInvtProfile.Next <> 0 then begin
              Continue := SupplyInvtProfile."Due Date" <= NewDate;
              TryRescheduleSupply :=
                (SupplyInvtProfile."Planning Flexibility" = SupplyInvtProfile."planning flexibility"::Unlimited) and
                (SupplyInvtProfile."Fixed Date" = 0D);
            end else
              Continue := false;
        end;

        // If there is only one supply before the demand we roll back
        if NumberofSupplies = 1 then begin
          SupplyInvtProfile.Copy(xSupplyInvtProfile);
          exit(false);
        end;

        TempRescheduledSupplyInvtProfile.SetCurrentkey(
          "Item No.","Variant Code","Location Code","Due Date","Attribute Priority","Order Priority");

        // If we have resheduled we replace the original supply records with the resceduled ones,
        // we re-write the primary key to make sure that the supplies are handled in the right order.
        if TempRescheduledSupplyInvtProfile.FindSet then begin
          repeat
            SupplyInvtProfile."Line No." := -TempRescheduledSupplyInvtProfile."Line No.";
            SupplyInvtProfile.Delete;
            SupplyInvtProfile := TempRescheduledSupplyInvtProfile;
            SupplyInvtProfile."Line No." := NextLineNo;
            SupplyInvtProfile.Insert;
            if not HasLooped then begin
              xSupplyInvtProfile := SupplyInvtProfile; // The first supply is bookmarked
              HasLooped := true;
            end;
          until TempRescheduledSupplyInvtProfile.Next = 0;
          SupplyInvtProfile := xSupplyInvtProfile;
        end;

        exit(true);
    end;

    local procedure PrepareOrderToOrderLink(var InventoryProfile: Record "Inventory Profile")
    begin
        // Prepare new demand for order-to-order planning
        with InventoryProfile do begin
          if FindSet(true) then
            repeat
              if not IsSupply then
                if not ("Source Type" = Database::"Production Forecast Entry") then
                  if not (("Source Type" = Database::"Sales Line") and ("Source Order Status" = 4)) then // Blanket Order
                    if (TempSKU."Reordering Policy" = TempSKU."reordering policy"::Order) or
                       ("Planning Level Code" <> 0)
                    then begin
                      if "Source Type" = Database::"Planning Component" then begin
                        // Primary Order references have already been set on Component Lines
                        Binding := Binding::"Order-to-Order";
                      end else begin
                        Binding := Binding::"Order-to-Order";
                        "Primary Order Type" := "Source Type";
                        "Primary Order Status" := "Source Order Status";
                        "Primary Order No." := "Source ID";
                        if "Source Type" <> Database::"Prod. Order Component" then
                          "Primary Order Line" := "Source Ref. No.";
                      end;
                      Modify;
                    end;
            until Next = 0;
        end;
    end;

    local procedure SetAcceptAction(ItemNo: Code[20])
    var
        ReqLine: Record "Requisition Line";
        PurchHeader: Record "Purchase Header";
        ProdOrder: Record "Production Order";
        TransHeader: Record "Transfer Header";
        AsmHeader: Record "Assembly Header";
        ReqWkshTempl: Record "Req. Wksh. Template";
        AcceptActionMsg: Boolean;
    begin
        with ReqLine do begin
          ReqWkshTempl.Get(CurrTemplateName);
          if ReqWkshTempl.Type <> ReqWkshTempl.Type::Planning then
            exit;
          SetCurrentkey("Worksheet Template Name","Journal Batch Name",Type,"No.");
          SetRange("Worksheet Template Name",CurrTemplateName);
          SetRange("Journal Batch Name",CurrWorksheetName);
          SetRange(Type,Type::Item);
          SetRange("No.",ItemNo);
          DummyInventoryProfileTrackBuffer."Warning Level" := DummyInventoryProfileTrackBuffer."warning level"::Attention;

          if FindSet(true) then
            repeat
              AcceptActionMsg := "Starting Date" >= WorkDate;
              if not AcceptActionMsg then
                PlanningTransparency.LogWarning(0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                  StrSubstNo(Text008,DummyInventoryProfileTrackBuffer."Warning Level",FieldCaption("Starting Date"),
                    "Starting Date",WorkDate));

              if "Action Message" <> "action message"::New then
                case "Ref. Order Type" of
                  "ref. order type"::Purchase:
                    if (PurchHeader.Get(PurchHeader."document type"::Order,"Ref. Order No.") and
                        (PurchHeader.Status = PurchHeader.Status::Released))
                    then begin
                      AcceptActionMsg := false;
                      PlanningTransparency.LogWarning(
                        0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                        StrSubstNo(Text009,
                          DummyInventoryProfileTrackBuffer."Warning Level",PurchHeader.FieldCaption(Status),"Ref. Order Type",
                          "Ref. Order No.",PurchHeader.Status));
                    end;
                  "ref. order type"::"Prod. Order":
                    if "Ref. Order Status" = ProdOrder.Status::Released then begin
                      AcceptActionMsg := false;
                      PlanningTransparency.LogWarning(
                        0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                        StrSubstNo(Text009,
                          DummyInventoryProfileTrackBuffer."Warning Level",ProdOrder.FieldCaption(Status),"Ref. Order Type",
                          "Ref. Order No.","Ref. Order Status"));
                    end;
                  "ref. order type"::Assembly:
                    if AsmHeader.Get("Ref. Order Status","Ref. Order No.") and
                       (AsmHeader.Status = AsmHeader.Status::Released)
                    then begin
                      AcceptActionMsg := false;
                      PlanningTransparency.LogWarning(
                        0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                        StrSubstNo(Text009,
                          DummyInventoryProfileTrackBuffer."Warning Level",AsmHeader.FieldCaption(Status),"Ref. Order Type",
                          "Ref. Order No.",AsmHeader.Status));
                    end;
                  "ref. order type"::Transfer:
                    if (TransHeader.Get("Ref. Order No.") and
                        (TransHeader.Status = TransHeader.Status::Released))
                    then begin
                      AcceptActionMsg := false;
                      PlanningTransparency.LogWarning(
                        0,ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
                        StrSubstNo(Text009,
                          DummyInventoryProfileTrackBuffer."Warning Level",TransHeader.FieldCaption(Status),"Ref. Order Type",
                          "Ref. Order No.",TransHeader.Status));
                    end;
                end;

              if AcceptActionMsg then
                AcceptActionMsg := PlanningTransparency.ReqLineWarningLevel(ReqLine) = 0;

              if not AcceptActionMsg then begin
                "Accept Action Message" := false;
                Modify;
              end;
            until Next = 0;
        end;
    end;

    procedure GetRouting(var ReqLine: Record "Requisition Line")
    var
        PlanRoutingLine: Record "Planning Routing Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderLine: Record "Prod. Order Line";
        VersionMgt: Codeunit VersionManagement;
    begin
        with ReqLine do begin
          if Quantity <= 0 then
            exit;

          if ("Action Message" = "action message"::New) or
             ("Ref. Order Type" = "ref. order type"::Purchase)
          then begin
            if "Routing No." <> '' then
              Validate("Routing Version Code",
                VersionMgt.GetRtngVersion("Routing No.","Due Date",true));
            Clear(PlngLnMgt);
            if PlanningResilicency then
              PlngLnMgt.SetResiliencyOn("Worksheet Template Name","Journal Batch Name","No.");
          end else
            if "Ref. Order Type" = "ref. order type"::"Prod. Order" then begin
              ProdOrderLine.Get("Ref. Order Status","Ref. Order No.","Ref. Line No.");
              ProdOrderRoutingLine.SetRange(Status,ProdOrderLine.Status);
              ProdOrderRoutingLine.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
              ProdOrderRoutingLine.SetRange("Routing Reference No.",ProdOrderLine."Routing Reference No.");
              ProdOrderRoutingLine.SetRange("Routing No.",ProdOrderLine."Routing No.");
              DisableRelations;
              if ProdOrderRoutingLine.Find('-') then
                repeat
                  PlanRoutingLine.Init;
                  PlanRoutingLine."Worksheet Template Name" := "Worksheet Template Name";
                  PlanRoutingLine."Worksheet Batch Name" := "Journal Batch Name";
                  PlanRoutingLine."Worksheet Line No." := "Line No.";
                  PlanRoutingLine.TransferFromProdOrderRouting(ProdOrderRoutingLine);
                  PlanRoutingLine.Insert;
                until ProdOrderRoutingLine.Next = 0;
            end;
        end;
    end;

    procedure GetComponents(var ReqLine: Record "Requisition Line")
    var
        PlanComponent: Record "Planning Component";
        ProdOrderComp: Record "Prod. Order Component";
        AsmLine: Record "Assembly Line";
        VersionMgt: Codeunit VersionManagement;
    begin
        with ReqLine do begin
          BlockDynamicTracking(true);
          Clear(PlngLnMgt);
          if PlanningResilicency then
            PlngLnMgt.SetResiliencyOn("Worksheet Template Name","Journal Batch Name","No.");
          PlngLnMgt.BlockDynamicTracking(true);
          if "Action Message" = "action message"::New then begin
            if "Production BOM No." <> '' then
              Validate("Production BOM Version Code",
                VersionMgt.GetBOMVersion("Production BOM No.","Due Date",true));
          end else
            case "Ref. Order Type" of
              "ref. order type"::"Prod. Order":
                begin
                  ProdOrderComp.SetRange(Status,"Ref. Order Status");
                  ProdOrderComp.SetRange("Prod. Order No.","Ref. Order No.");
                  ProdOrderComp.SetRange("Prod. Order Line No.","Ref. Line No.");
                  if ProdOrderComp.Find('-') then
                    repeat
                      PlanComponent.Init;
                      PlanComponent."Worksheet Template Name" := "Worksheet Template Name";
                      PlanComponent."Worksheet Batch Name" := "Journal Batch Name";
                      PlanComponent."Worksheet Line No." := "Line No.";
                      PlanComponent."Planning Line Origin" := "Planning Line Origin";
                      PlanComponent.TransferFromComponent(ProdOrderComp);
                      PlanComponent.Insert;
                      TempPlanningCompList := PlanComponent;
                      if not TempPlanningCompList.Insert then
                        TempPlanningCompList.Modify;
                    until ProdOrderComp.Next = 0;
                end;
              "ref. order type"::Assembly:
                begin
                  AsmLine.SetRange("Document Type",AsmLine."document type"::Order);
                  AsmLine.SetRange("Document No.","Ref. Order No.");
                  AsmLine.SetRange(Type,AsmLine.Type::Item);
                  if AsmLine.Find('-') then
                    repeat
                      PlanComponent.Init;
                      PlanComponent."Worksheet Template Name" := "Worksheet Template Name";
                      PlanComponent."Worksheet Batch Name" := "Journal Batch Name";
                      PlanComponent."Worksheet Line No." := "Line No.";
                      PlanComponent."Planning Line Origin" := "Planning Line Origin";
                      PlanComponent.TransferFromAsmLine(AsmLine);
                      PlanComponent.Insert;
                      TempPlanningCompList := PlanComponent;
                      if not TempPlanningCompList.Insert then
                        TempPlanningCompList.Modify;
                    until AsmLine.Next = 0;
                end;
            end;
        end;
    end;


    procedure Recalculate(var ReqLine: Record "Requisition Line";Direction: Option Forward,Backward)
    var
        RefreshRouting: Boolean;
    begin
        with ReqLine do begin
          RefreshRouting := ("Action Message" = "action message"::New) or ("Ref. Order Type" = "ref. order type"::Purchase);

          PlngLnMgt.Calculate(ReqLine,Direction,RefreshRouting,"Action Message" = "action message"::New,-1);
          if "Action Message" = "action message"::New then
            PlngLnMgt.GetPlanningCompList(TempPlanningCompList);
        end;
    end;

    procedure GetPlanningCompList(var PlanningCompList: Record "Planning Component" temporary)
    begin
        if TempPlanningCompList.Find('-') then
          repeat
            PlanningCompList := TempPlanningCompList;
            if not PlanningCompList.Insert then
              PlanningCompList.Modify;
            TempPlanningCompList.Delete;
          until TempPlanningCompList.Next = 0;
    end;

    procedure SetParm(Forecast: Code[10];ExclBefore: Date;WorksheetType: Option Requisition,Planning)
    begin
        CurrForecast := Forecast;
        ExcludeForecastBefore := ExclBefore;
        UseParm := true;
        CurrWorksheetType := WorksheetType;
    end;

    procedure SetResiliencyOn()
    begin
        PlanningResilicency := true;
    end;

    procedure GetResiliencyError(var PlanningErrorLog: Record "Planning Error Log"): Boolean
    begin
        if ReqLine.GetResiliencyError(PlanningErrorLog) then
          exit(true);
        exit(PlngLnMgt.GetResiliencyError(PlanningErrorLog));
    end;

    local procedure CloseTracking(ReservEntry: Record "Reservation Entry";var SupplyInventoryProfile: Record "Inventory Profile";ToDate: Date): Boolean
    var
        xSupplyInventoryProfile: Record "Inventory Profile";
        ReservationEngineMgt: Codeunit "Reservation Engine Mgt.";
        Closed: Boolean;
    begin
        with ReservEntry do begin
          if "Reservation Status" <> "reservation status"::Tracking then
            exit(false);

          xSupplyInventoryProfile.Copy(SupplyInventoryProfile);
          Closed := false;

          if ("Expected Receipt Date" <= ToDate) and
             ("Shipment Date" > ToDate)
          then begin
            // tracking exists with demand in future
            SupplyInventoryProfile.SetCurrentkey(
              "Source Type","Source Order Status","Source ID","Source Batch Name","Source Ref. No.","Source Prod. Order Line",IsSupply,
              "Due Date");
            SupplyInventoryProfile.SetRange("Source Type","Source Type");
            SupplyInventoryProfile.SetRange("Source Order Status","Source Subtype");
            SupplyInventoryProfile.SetRange("Source ID","Source ID");
            SupplyInventoryProfile.SetRange("Source Batch Name","Source Batch Name");
            SupplyInventoryProfile.SetRange("Source Ref. No.","Source Ref. No.");
            SupplyInventoryProfile.SetRange("Source Prod. Order Line","Source Prod. Order Line");
            SupplyInventoryProfile.SetRange("Due Date",0D,ToDate);

            if not SupplyInventoryProfile.IsEmpty then begin
              // demand is either deleted as well or will get Surplus status
              ReservationEngineMgt.CloseReservEntry(ReservEntry,false,false);
              Closed := true;
            end;
          end;
        end;

        SupplyInventoryProfile.Copy(xSupplyInventoryProfile);
        exit(Closed);
    end;

    local procedure FrozenZoneTrack(FromInventoryProfile: Record "Inventory Profile";ToInventoryProfile: Record "Inventory Profile")
    begin
        if FromInventoryProfile.TrackingExists then
          Track(FromInventoryProfile,ToInventoryProfile,true,false,FromInventoryProfile.Binding::" ");

        if ToInventoryProfile.TrackingExists then begin
          ToInventoryProfile."Untracked Quantity" := FromInventoryProfile."Untracked Quantity";
          ToInventoryProfile."Quantity (Base)" := FromInventoryProfile."Untracked Quantity";
          ToInventoryProfile."Original Quantity" := 0;
          Track(ToInventoryProfile,FromInventoryProfile,true,false,ToInventoryProfile.Binding::" ");
        end;
    end;

    local procedure ExceedROPinException(RespectPlanningParm: Boolean): Boolean
    begin
        if not RespectPlanningParm then
          exit(false);

        exit(TempSKU."Reordering Policy" = TempSKU."reordering policy"::"Fixed Reorder Qty.");
    end;

    local procedure CreateSupplyForInitialSafetyStockWarning(var SupplyInventoryProfile: Record "Inventory Profile";ProjectedInventory: Decimal;var LastProjectedInventory: Decimal;var LastAvailableInventory: Decimal;PlanningStartDate: Date;RespectPlanningParm: Boolean;IsReorderPointPlanning: Boolean)
    var
        OrderQty: Decimal;
        ReorderQty: Decimal;
    begin
        OrderQty := TempSKU."Safety Stock Quantity" - ProjectedInventory;
        if ExceedROPinException(RespectPlanningParm) then
          OrderQty := TempSKU."Reorder Point" - ProjectedInventory;

        ReorderQty := OrderQty;

        repeat
          InitSupply(SupplyInventoryProfile,ReorderQty,PlanningStartDate);
          if RespectPlanningParm then begin
            if IsReorderPointPlanning then
              ReorderQty := CalcOrderQty(ReorderQty,ProjectedInventory,SupplyInventoryProfile."Line No.");

            ReorderQty += AdjustReorderQty(ReorderQty,TempSKU,SupplyInventoryProfile."Line No.",SupplyInventoryProfile."Min. Quantity");
            SupplyInventoryProfile."Max. Quantity" := TempSKU."Maximum Order Quantity";
            UpdateQty(SupplyInventoryProfile,ReorderQty);
            SupplyInventoryProfile."Min. Quantity" := SupplyInventoryProfile."Quantity (Base)";
          end;
          SupplyInventoryProfile."Fixed Date" := SupplyInventoryProfile."Due Date";
          SupplyInventoryProfile."Order Relation" := SupplyInventoryProfile."order relation"::"Safety Stock";
          SupplyInventoryProfile."Is Exception Order" := true;
          SupplyInventoryProfile.Insert;

          DummyInventoryProfileTrackBuffer."Warning Level" := DummyInventoryProfileTrackBuffer."warning level"::Exception;
          PlanningTransparency.LogWarning(
            SupplyInventoryProfile."Line No.",ReqLine,DummyInventoryProfileTrackBuffer."Warning Level",
            StrSubstNo(Text007,DummyInventoryProfileTrackBuffer."Warning Level",TempSKU.FieldCaption("Safety Stock Quantity"),
              TempSKU."Safety Stock Quantity",PlanningStartDate));

          LastProjectedInventory += SupplyInventoryProfile."Remaining Quantity (Base)";
          ProjectedInventory += SupplyInventoryProfile."Remaining Quantity (Base)";
          LastAvailableInventory += SupplyInventoryProfile."Untracked Quantity";

          OrderQty -= ReorderQty;
          if ExceedROPinException(RespectPlanningParm) and (OrderQty = 0) then
            OrderQty := ExceedROPqty;
          ReorderQty := OrderQty;
        until OrderQty <= 0; // Create supplies until Safety Stock is met or Reorder point is exceeded
    end;

    local procedure IsTrkgForSpecialOrderOrDropShpt(ReservEntry: Record "Reservation Entry"): Boolean
    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
    begin
        case ReservEntry."Source Type" of
          Database::"Sales Line":
            if SalesLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.") then
              exit(SalesLine."Special Order" or SalesLine."Drop Shipment");
          Database::"Purchase Line":
            if PurchLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.") then
              exit(PurchLine."Special Order" or PurchLine."Drop Shipment");
        end;

        exit(false);
    end;

    local procedure CheckSupplyRemQtyAndUntrackQty(var InventoryProfile: Record "Inventory Profile")
    var
        RemQty: Decimal;
    begin
        with InventoryProfile do begin
          if "Source Type" = Database::"Item Ledger Entry" then
            exit;

          if "Remaining Quantity (Base)" >= TempSKU."Maximum Order Quantity" then begin
            RemQty := "Remaining Quantity (Base)";
            "Remaining Quantity (Base)" := TempSKU."Maximum Order Quantity";
            if not ("Action Message" in ["action message"::New,"action message"::Reschedule]) then
              "Original Quantity" := "Quantity (Base)";
          end;
          if "Untracked Quantity" >= TempSKU."Maximum Order Quantity" then
            "Untracked Quantity" := "Untracked Quantity" - RemQty + "Remaining Quantity (Base)";
        end;
    end;

    local procedure CheckItemInventoryExists(var InventoryProfile: Record "Inventory Profile") ItemInventoryExists: Boolean
    begin
        with InventoryProfile do begin
          SetRange("Source Type",Database::"Item Ledger Entry");
          SetFilter(Binding,'<>%1',Binding::"Order-to-Order");
          ItemInventoryExists := not IsEmpty;
          SetRange("Source Type");
          SetRange(Binding);
        end;
    end;

    local procedure ApplyUntrackedQuantityToItemInventory(SupplyExists: Boolean;ItemInventoryExists: Boolean): Boolean
    begin
        if SupplyExists then
          exit(false);
        exit(ItemInventoryExists);
    end;

    local procedure UpdateAppliedItemEntry(var ReservEntry: Record "Reservation Entry")
    begin
        with TempItemTrkgEntry do begin
          SetSourceFilter(
            ReservEntry."Source Type",ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.",true);
          if ReservEntry."Lot No." <> '' then
            SetRange("Lot No.",ReservEntry."Lot No.");
          if ReservEntry."Serial No." <> '' then
            SetRange("Serial No.",ReservEntry."Serial No.");
          if FindFirst then begin
            ReservEntry."Appl.-from Item Entry" := "Appl.-from Item Entry";
            ReservEntry."Appl.-to Item Entry" := "Appl.-to Item Entry";
          end;
        end;
    end;

    local procedure CheckSupplyAndTrack(InventoryProfileFromDemand: Record "Inventory Profile";InventoryProfileFromSupply: Record "Inventory Profile")
    begin
        if InventoryProfileFromSupply."Source Type" = Database::"Item Ledger Entry" then
          Track(InventoryProfileFromDemand,InventoryProfileFromSupply,false,false,InventoryProfileFromSupply.Binding)
        else
          Track(InventoryProfileFromDemand,InventoryProfileFromSupply,false,false,InventoryProfileFromDemand.Binding);
    end;

    local procedure CheckPlanSKU(SKU: Record "Stockkeeping Unit";DemandExists: Boolean;SupplyExists: Boolean;IsReorderPointPlanning: Boolean): Boolean
    begin
        if (CurrWorksheetType = Currworksheettype::Requisition) and
           (SKU."Replenishment System" in [SKU."replenishment system"::"Prod. Order",SKU."replenishment system"::Assembly])
        then
          exit(false);

        if DemandExists or SupplyExists or IsReorderPointPlanning then
          exit(true);

        exit(false);
    end;

    local procedure PrepareDemand(var InventoryProfile: Record "Inventory Profile";IsReorderPointPlanning: Boolean;ToDate: Date)
    begin
        // Transfer attributes
        if (TempSKU."Reordering Policy" = TempSKU."reordering policy"::Order) or
           (TempSKU."Manufacturing Policy" = TempSKU."manufacturing policy"::"Make-to-Order")
        then
          PrepareOrderToOrderLink(InventoryProfile);
        UpdatePriorities(InventoryProfile,IsReorderPointPlanning,ToDate);
    end;

    local procedure DemandMatchedSupply(var FromInventoryProfile: Record "Inventory Profile";var ToInventoryProfile: Record "Inventory Profile";SKU: Record "Stockkeeping Unit"): Boolean
    var
        xFromInventoryProfile: Record "Inventory Profile";
        xToInventoryProfile: Record "Inventory Profile";
        UntrackedQty: Decimal;
    begin
        xToInventoryProfile.CopyFilters(FromInventoryProfile);
        xFromInventoryProfile.CopyFilters(ToInventoryProfile);
        with FromInventoryProfile do begin
          SetRange("Attribute Priority",1,7);
          if FindSet then begin
            repeat
              ToInventoryProfile.SetRange(Binding,Binding);
              ToInventoryProfile.SetRange("Primary Order Status","Primary Order Status");
              ToInventoryProfile.SetRange("Primary Order No.","Primary Order No.");
              ToInventoryProfile.SetRange("Primary Order Line","Primary Order Line");
              ToInventoryProfile.SetTrackingFilter(FromInventoryProfile);
              if ToInventoryProfile.FindSet then
                repeat
                  UntrackedQty += ToInventoryProfile."Untracked Quantity";
                until ToInventoryProfile.Next = 0;
              UntrackedQty -= "Untracked Quantity";
            until Next = 0;
            if (UntrackedQty = 0) and (SKU."Reordering Policy" = SKU."reordering policy"::"Lot-for-Lot") then begin
              SetRange("Attribute Priority",8);
              CalcSums("Untracked Quantity");
              if "Untracked Quantity" = 0 then begin
                CopyFilters(xToInventoryProfile);
                ToInventoryProfile.CopyFilters(xFromInventoryProfile);
                exit(true);
              end;
            end;
          end;
          CopyFilters(xToInventoryProfile);
          ToInventoryProfile.CopyFilters(xFromInventoryProfile);
          exit(false);
        end;
    end;

    local procedure ReservedForProdComponent(ReservationEntry: Record "Reservation Entry"): Boolean
    begin
        if not ReservationEntry.Positive then
          exit(ReservationEntry."Source Type" = Database::"Prod. Order Component");
        if ReservationEntry.Get(ReservationEntry."Entry No.",false) then
          exit(ReservationEntry."Source Type" = Database::"Prod. Order Component");
    end;

    local procedure ShouldInsertTrackingEntry(FromTrkgReservEntry: Record "Reservation Entry"): Boolean
    var
        InsertedReservEntry: Record "Reservation Entry";
    begin
        with InsertedReservEntry do begin
          SetRange("Source ID",FromTrkgReservEntry."Source ID");
          SetRange("Source Ref. No.",FromTrkgReservEntry."Source Ref. No.");
          SetRange("Source Type",FromTrkgReservEntry."Source Type");
          SetRange("Source Subtype",FromTrkgReservEntry."Source Subtype");
          SetRange("Source Batch Name",FromTrkgReservEntry."Source Batch Name");
          SetRange("Source Prod. Order Line",FromTrkgReservEntry."Source Prod. Order Line");
          SetRange("Reservation Status",FromTrkgReservEntry."Reservation Status");
          exit(IsEmpty);
        end;
    end;

    local procedure CloseInventoryProfile(var ClosedInvtProfile: Record "Inventory Profile";var OpenInvtProfile: Record "Inventory Profile";ActionMessage: Option " ",New,"Change Qty.",Reschedule,"Resched.& Chg. Qty.",Cancel)
    var
        PlanningStageToMaintain: Option " ","Line Created","Routing Created",Exploded,Obsolete;
    begin
        OpenInvtProfile."Untracked Quantity" -= ClosedInvtProfile."Untracked Quantity";
        OpenInvtProfile.Modify;

        if OpenInvtProfile.Binding = OpenInvtProfile.Binding::"Order-to-Order" then
          PlanningStageToMaintain := Planningstagetomaintain::Exploded
        else
          PlanningStageToMaintain := Planningstagetomaintain::"Line Created";

        if ActionMessage <> Actionmessage::" " then
          if OpenInvtProfile.IsSupply then
            MaintainPlanningLine(OpenInvtProfile,PlanningStageToMaintain,Scheduledirection::Backward)
          else
            MaintainPlanningLine(ClosedInvtProfile,PlanningStageToMaintain,Scheduledirection::Backward);

        Track(ClosedInvtProfile,OpenInvtProfile,false,false,OpenInvtProfile.Binding);

        if ClosedInvtProfile.Binding = ClosedInvtProfile.Binding::"Order-to-Order" then
          ClosedInvtProfile."Remaining Quantity (Base)" -= ClosedInvtProfile."Untracked Quantity";

        ClosedInvtProfile."Untracked Quantity" := 0;
        if ClosedInvtProfile."Remaining Quantity (Base)" = 0 then
          ClosedInvtProfile.Delete
        else
          ClosedInvtProfile.Modify;
    end;

    local procedure CloseDemand(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile")
    begin
        CloseInventoryProfile(DemandInvtProfile,SupplyInvtProfile,SupplyInvtProfile."Action Message");
    end;

    local procedure CloseSupply(var DemandInvtProfile: Record "Inventory Profile";var SupplyInvtProfile: Record "Inventory Profile"): Boolean
    begin
        CloseInventoryProfile(SupplyInvtProfile,DemandInvtProfile,SupplyInvtProfile."Action Message");
        exit(SupplyInvtProfile.Next <> 0);
    end;

    local procedure QtyPickedForSourceDocument(TrkgReservEntry: Record "Reservation Entry"): Decimal
    var
        WhseEntry: Record "Warehouse Entry";
    begin
        WhseEntry.SetRange("Item No.",TrkgReservEntry."Item No.");
        WhseEntry.SetSourceFilter(
          TrkgReservEntry."Source Type",TrkgReservEntry."Source Subtype",TrkgReservEntry."Source ID",
          TrkgReservEntry."Source Ref. No.",false);
        WhseEntry.SetRange("Lot No.",TrkgReservEntry."Lot No.");
        WhseEntry.SetRange("Serial No.",TrkgReservEntry."Serial No.");
        WhseEntry.SetFilter("Qty. (Base)",'<0');
        WhseEntry.CalcSums("Qty. (Base)");
        exit(WhseEntry."Qty. (Base)");
    end;

    local procedure CreateTempSKUForComponentsLocation(var Item: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if ManufacturingSetup."Components at Location" = '' then
          exit;

        SKU.SetRange("Item No.",Item."No.");
        SKU.SetRange("Location Code",ManufacturingSetup."Components at Location");
        Item.Copyfilter("Variant Filter",SKU."Variant Code");
        if SKU.IsEmpty then
          CreateTempSKUForLocation(Item."No.",ManufacturingSetup."Components at Location");
    end;

    local procedure ForecastInitDemand(var InventoryProfile: Record "Inventory Profile";ProductionForecastEntry: Record "Production Forecast Entry";ItemNo: Code[20];LocationCode: Code[10];TotalForecastQty: Decimal)
    begin
        with InventoryProfile do begin
          Init;
          "Line No." := NextLineNo;
          "Source Type" := Database::"Production Forecast Entry";
          "Planning Flexibility" := "planning flexibility"::None;
          "Qty. per Unit of Measure" := 1;
          "MPS Order" := true;
          "Source ID" := ProductionForecastEntry."Production Forecast Name";
          "Item No." := ItemNo;
          if ManufacturingSetup."Use Forecast on Locations" then
            "Location Code" := ProductionForecastEntry."Location Code"
          else
            "Location Code" := LocationCode;
          "Remaining Quantity (Base)" := TotalForecastQty;
          "Untracked Quantity" := TotalForecastQty;
        end;
    end;

    local procedure SetPurchase(var PurchaseLine: Record "Purchase Line";var InventoryProfile: Record "Inventory Profile")
    begin
        with ReqLine do begin
          "Ref. Order Type" := "ref. order type"::Purchase;
          "Ref. Order No." := InventoryProfile."Source ID";
          "Ref. Line No." := InventoryProfile."Source Ref. No.";
          PurchaseLine.Get(PurchaseLine."document type"::Order,"Ref. Order No.","Ref. Line No.");
          TransferFromPurchaseLine(PurchaseLine);
        end;
    end;

    local procedure SetProdOrder(var ProdOrderLine: Record "Prod. Order Line";var InventoryProfile: Record "Inventory Profile")
    begin
        with ReqLine do begin
          "Ref. Order Type" := "ref. order type"::"Prod. Order";
          "Ref. Order Status" := InventoryProfile."Source Order Status";
          "Ref. Order No." := InventoryProfile."Source ID";
          "Ref. Line No." := InventoryProfile."Source Prod. Order Line";
          ProdOrderLine.Get("Ref. Order Status","Ref. Order No.","Ref. Line No.");
          TransferFromProdOrderLine(ProdOrderLine);
        end;
    end;

    local procedure SetAssembly(var AsmHeader: Record "Assembly Header";var InventoryProfile: Record "Inventory Profile")
    begin
        with ReqLine do begin
          "Ref. Order Type" := "ref. order type"::Assembly;
          "Ref. Order No." := InventoryProfile."Source ID";
          "Ref. Line No." := 0;
          AsmHeader.Get(AsmHeader."document type"::Order,"Ref. Order No.");
          TransferFromAsmHeader(AsmHeader);
        end;
    end;

    local procedure SetTransfer(var TransLine: Record "Transfer Line";var InventoryProfile: Record "Inventory Profile")
    begin
        with ReqLine do begin
          "Ref. Order Type" := "ref. order type"::Transfer;
          "Ref. Order Status" := 0; // A Transfer Order has no status
          "Ref. Order No." := InventoryProfile."Source ID";
          "Ref. Line No." := InventoryProfile."Source Ref. No.";
          TransLine.Get("Ref. Order No.","Ref. Line No.");
          TransferFromTransLine(TransLine);
        end;
    end;

    local procedure SKURequiresLotAccumulation(var StockkeepingUnit: Record "Stockkeeping Unit"): Boolean
    var
        BlankPeriod: DateFormula;
    begin
        with StockkeepingUnit do
          if "Reordering Policy" = "reordering policy"::"Lot-for-Lot" then begin
            Evaluate(BlankPeriod,'');
            exit("Lot Accumulation Period" <> BlankPeriod);
          end;
        exit(false);
    end;

    local procedure FromLotAccumulationPeriodStartDate(LotAccumulationPeriodStartDate: Date;DemandDueDate: Date): Boolean
    begin
        if LotAccumulationPeriodStartDate > 0D then
          exit(CalcDate(TempSKU."Lot Accumulation Period",LotAccumulationPeriodStartDate) >= DemandDueDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransToChildInvProfile(var ReservEntry: Record "Reservation Entry";var ChildInvtProfile: Record "Inventory Profile")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDemandToInvProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;var ReservEntry: Record "Reservation Entry";var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSupplyToInvProfile(var InventoryProfile: Record "Inventory Profile";var Item: Record Item;var ToDate: Date;var ReservEntry: Record "Reservation Entry";var NextLineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetOrderPriority(var InventoryProfile: Record "Inventory Profile")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBlanketOrderConsumpFind(var BlanketSalesLine: Record "Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckScheduleOut(var InventoryProfile: Record "Inventory Profile";var TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;BucketSize: DateFormula)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDemandInvtProfileInsert(var InventoryProfile: Record "Inventory Profile";StockkeepingUnit: Record "Stockkeeping Unit")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeMatchAttributesDemandApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEndMatchAttributesDemandApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStartOfMatchAttributesDemandApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrePlanDateApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnStartOfPrePlanDateApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrePlanDateDemandProc(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePrePlanDateSupplyProc(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPrePlanDateSupplyProc(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePlanStepSettingOnStartOver(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculatePlanFromWorksheet(var Item: Record Item;ManufacturingSetup2: Record "Manufacturing Setup";TemplateName: Code[10];WorksheetName: Code[10];OrderDate: Date;ToDate: Date;MRPPlanning: Boolean;RespectPlanningParm: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertSafetyStockDemands(var DemandInvtProfile: Record "Inventory Profile";xDemandInvtProfile: Record "Inventory Profile";var TempSafetyStockInvtProfile: Record "Inventory Profile" temporary;var TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;var PlanningStartDate: Date;var PlanToDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFindCombinationAfterAssignTempSKU(var TempStockkeepingUnit: Record "Stockkeeping Unit" temporary;InventoryProfile: Record "Inventory Profile")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostInvChgReminder(var InventoryProfileChangeReminder: Record "Inventory Profile";var InventoryProfile: Record "Inventory Profile";PostOnlyMinimum: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostInvChgReminder(var InventoryProfileChangeReminder: Record "Inventory Profile";var InventoryProfile: Record "Inventory Profile";PostOnlyMinimum: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEndOfPrePlanDateApplicationLoop(var SupplyInventoryProfile: Record "Inventory Profile";var DemandInventoryProfile: Record "Inventory Profile";var SupplyExists: Boolean;var DemandExists: Boolean)
    begin
    end;
}

