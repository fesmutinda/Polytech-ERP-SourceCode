#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000757 "Update Prod. Order Cost"
{

    trigger OnRun()
    begin
    end;

    var
        SalesLine: Record "Sales Line";
        PurchLine: Record "Purchase Line";
        ReqLine: Record "Requisition Line";
        ItemJnlLine: Record "Item Journal Line";
        ProdOrderComp: Record "Prod. Order Component";
        PlanningComponent: Record "Planning Component";
        ServiceInvLine: Record "Service Line";
        ReservMgt: Codeunit "Reservation Management";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReserveProdOrderLine: Codeunit "Prod. Order Line-Reserve";
        ReserveProdOrderComp: Codeunit "Prod. Order Comp.-Reserve";

    local procedure ModifyFor(ReservEntry: Record "Reservation Entry";UnitCost: Decimal)
    var
        ProdOrderLine: Record "Prod. Order Line";
        ReqLine: Record "Requisition Line";
        QtyToReserveNonBase: Decimal;
        QtyToReserve: Decimal;
        QtyReservedThisLineNonBase: Decimal;
        QtyReservedThisLine: Decimal;
    begin
        if UnitCost = 0 then
          exit;

        if not ReservEntry.Get(ReservEntry."Entry No.",not ReservEntry.Positive) then
          exit;

        case ReservEntry."Source Type" of
          Database::"Sales Line":
            begin
              SalesLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
              ReservMgt.SetSalesLine(SalesLine);
              ReservMgt.SalesLineUpdateValues(SalesLine,QtyToReserveNonBase,QtyToReserve,
                QtyReservedThisLineNonBase,QtyReservedThisLine);
              if SalesLine."Qty. per Unit of Measure" <> 0 then
                SalesLine."Unit Cost (LCY)" :=
                  ROUND(SalesLine."Unit Cost (LCY)" / SalesLine."Qty. per Unit of Measure");
              if SalesLine."Quantity (Base)" <> 0 then
                SalesLine."Unit Cost (LCY)" :=
                  ROUND(
                    (SalesLine."Unit Cost (LCY)" *
                     (SalesLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / SalesLine."Quantity (Base)",0.00001);
              if SalesLine."Qty. per Unit of Measure" <> 0 then
                SalesLine."Unit Cost (LCY)" :=
                  ROUND(SalesLine."Unit Cost (LCY)" * SalesLine."Qty. per Unit of Measure");
              SalesLine.Validate("Unit Cost (LCY)");
              SalesLine.Modify;
            end;
          Database::"Requisition Line":
            begin
              ReqLine.Get(ReservEntry."Source ID",ReservEntry."Source Batch Name",ReservEntry."Source Ref. No.");
              ReservMgt.ReqLineUpdateValues(ReqLine,QtyToReserveNonBase,QtyToReserve,
                QtyReservedThisLineNonBase,QtyReservedThisLine);
              if ReqLine."Qty. per Unit of Measure" <> 0 then
                ReqLine."Direct Unit Cost" :=
                  ROUND(ReqLine."Direct Unit Cost" / ReqLine."Qty. per Unit of Measure");
              if ReqLine."Quantity (Base)" <> 0 then
                ReqLine."Direct Unit Cost" :=
                  ROUND(
                    (ReqLine."Direct Unit Cost" *
                     (ReqLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / ReqLine."Quantity (Base)",0.00001);
              if ReqLine."Qty. per Unit of Measure" <> 0 then
                ReqLine."Direct Unit Cost" :=
                  ROUND(ReqLine."Direct Unit Cost" * ReqLine."Qty. per Unit of Measure");
              ReqLine.Validate("Direct Unit Cost");
              ReqLine.Modify;
            end;
          Database::"Purchase Line":
            begin
              PurchLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
              if PurchLine."Qty. per Unit of Measure" <> 0 then
                PurchLine."Unit Cost (LCY)" :=
                  ROUND(PurchLine."Unit Cost (LCY)" / PurchLine."Qty. per Unit of Measure");
              if PurchLine."Quantity (Base)" <> 0 then
                PurchLine."Unit Cost (LCY)" :=
                  ROUND(
                    (PurchLine."Unit Cost (LCY)" *
                     (PurchLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / PurchLine."Quantity (Base)",0.00001);
              if PurchLine."Qty. per Unit of Measure" <> 0 then
                PurchLine."Unit Cost (LCY)" :=
                  ROUND(PurchLine."Unit Cost (LCY)" * PurchLine."Qty. per Unit of Measure");
              PurchLine.Validate("Unit Cost (LCY)");
              PurchLine.Modify;
            end;
          Database::"Item Journal Line":
            begin
              ItemJnlLine.Get(
                ReservEntry."Source ID",ReservEntry."Source Batch Name",ReservEntry."Source Ref. No.");
              if ItemJnlLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Unit Cost" :=
                  ROUND(ItemJnlLine."Unit Cost" / ItemJnlLine."Qty. per Unit of Measure");
              if ItemJnlLine."Quantity (Base)" <> 0 then
                ItemJnlLine."Unit Cost" :=
                  ROUND(
                    (ItemJnlLine."Unit Cost" *
                     (ItemJnlLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / ItemJnlLine."Quantity (Base)",0.00001);
              if ItemJnlLine."Qty. per Unit of Measure" <> 0 then
                ItemJnlLine."Unit Cost" :=
                  ROUND(ItemJnlLine."Unit Cost" * ItemJnlLine."Qty. per Unit of Measure");
              ItemJnlLine.Validate("Unit Cost");
              ItemJnlLine.Modify;
            end;
          Database::"Prod. Order Line":
            begin
              ProdOrderLine.Get(
                ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Prod. Order Line");
              if ProdOrderLine."Qty. per Unit of Measure" <> 0 then
                ProdOrderLine."Unit Cost" :=
                  ROUND(ProdOrderLine."Unit Cost" / ProdOrderLine."Qty. per Unit of Measure");
              if ProdOrderLine."Quantity (Base)" <> 0 then
                ProdOrderLine."Unit Cost" :=
                  ROUND(
                    (ProdOrderLine."Unit Cost" *
                     (ProdOrderLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / ProdOrderLine."Quantity (Base)",0.00001);
              if ProdOrderLine."Qty. per Unit of Measure" <> 0 then
                ProdOrderLine."Unit Cost" :=
                  ROUND(ProdOrderLine."Unit Cost" * ProdOrderLine."Qty. per Unit of Measure");
              ProdOrderLine.Validate("Unit Cost");
              ProdOrderLine.Modify;
            end;
          Database::"Prod. Order Component":
            begin
              ProdOrderComp.Get(
                ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Prod. Order Line",
                ReservEntry."Source Ref. No.");
              ReservMgt.SetProdOrderComponent(ProdOrderComp);
              ReservMgt.ProdOrderCompUpdateValues(ProdOrderComp,QtyToReserveNonBase,QtyToReserve,
                QtyReservedThisLineNonBase,QtyReservedThisLine);
              if ProdOrderComp."Qty. per Unit of Measure" <> 0 then
                ProdOrderComp."Unit Cost" :=
                  ROUND(ProdOrderComp."Unit Cost" / ProdOrderComp."Qty. per Unit of Measure");
              if ProdOrderComp."Expected Qty. (Base)" <> 0 then
                ProdOrderComp."Unit Cost" :=
                  ROUND(
                    (ProdOrderComp."Unit Cost" *
                     (ProdOrderComp."Expected Qty. (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / ProdOrderComp."Expected Qty. (Base)",0.00001);
              if ProdOrderComp."Qty. per Unit of Measure" <> 0 then
                ProdOrderComp."Unit Cost" :=
                  ROUND(ProdOrderComp."Unit Cost" * ProdOrderComp."Qty. per Unit of Measure");
              ProdOrderComp.Validate("Unit Cost");
              ProdOrderComp.Modify;
            end;
          Database::"Planning Component":
            begin
              PlanningComponent.Get(
                ReservEntry."Source ID",
                ReservEntry."Source Batch Name",
                ReservEntry."Source Prod. Order Line",
                ReservEntry."Source Ref. No.");
              if PlanningComponent."Qty. per Unit of Measure" <> 0 then
                PlanningComponent."Unit Cost" :=
                  ROUND(PlanningComponent."Unit Cost" / PlanningComponent."Qty. per Unit of Measure");
              if PlanningComponent."Expected Quantity (Base)" <> 0 then
                PlanningComponent."Unit Cost" :=
                  ROUND(
                    (PlanningComponent."Unit Cost" *
                     (PlanningComponent."Expected Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / PlanningComponent."Expected Quantity (Base)",0.00001);
              if PlanningComponent."Qty. per Unit of Measure" <> 0 then
                PlanningComponent."Unit Cost" :=
                  ROUND(PlanningComponent."Unit Cost" * PlanningComponent."Qty. per Unit of Measure");
              PlanningComponent.Validate("Unit Cost");
              PlanningComponent.Modify;
            end;
          Database::"Service Line":
            begin
              ServiceInvLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
              ReservMgt.SetServLine(ServiceInvLine);
              ReservMgt.ServiceInvLineUpdateValues(ServiceInvLine,QtyToReserveNonBase,QtyToReserve,
                QtyReservedThisLineNonBase,QtyReservedThisLine);
              if ServiceInvLine."Qty. per Unit of Measure" <> 0 then
                ServiceInvLine."Unit Cost (LCY)" :=
                  ROUND(ServiceInvLine."Unit Cost (LCY)" / ServiceInvLine."Qty. per Unit of Measure");
              if ServiceInvLine."Quantity (Base)" <> 0 then
                ServiceInvLine."Unit Cost (LCY)" :=
                  ROUND(
                    (ServiceInvLine."Unit Cost (LCY)" *
                     (ServiceInvLine."Quantity (Base)" - QtyReservedThisLine) +
                     UnitCost * QtyReservedThisLine) / ServiceInvLine."Quantity (Base)",0.00001);
              if ServiceInvLine."Qty. per Unit of Measure" <> 0 then
                ServiceInvLine."Unit Cost (LCY)" :=
                  ROUND(ServiceInvLine."Unit Cost (LCY)" * ServiceInvLine."Qty. per Unit of Measure");
              ServiceInvLine.Validate("Unit Cost (LCY)");
              ServiceInvLine.Modify;
            end;
        end;
    end;

    local procedure SumTrackingCosts(var ReservEntry: Record "Reservation Entry";var TotalUnitCost: Decimal;var TotalCostQty: Decimal;MultipleLevels: Boolean;Item: Record Item)
    var
        PurchLine: Record "Purchase Line";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        TotalUnitCost := 0;
        TotalCostQty := 0;

        repeat
          case ReservEntry."Source Type" of
            Database::"Sales Line":
              begin
                SalesLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
                if SalesLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(SalesLine."Unit Cost (LCY)" / SalesLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Requisition Line":
              begin
                ReqLine.Get(ReservEntry."Source ID",ReservEntry."Source Batch Name",ReservEntry."Source Ref. No.");
                if ReqLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(ReqLine."Direct Unit Cost" / ReqLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Purchase Line":
              begin
                PurchLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
                if PurchLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(PurchLine."Unit Cost (LCY)" / PurchLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Item Journal Line":
              begin
                ItemJnlLine.Get(
                  ReservEntry."Source ID",ReservEntry."Source Batch Name",ReservEntry."Source Ref. No.");
                if ItemJnlLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(ItemJnlLine."Unit Cost" / ItemJnlLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Prod. Order Line":
              begin
                ProdOrderLine.Get(
                  ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Prod. Order Line");
                if MultipleLevels then begin
                  UpdateUnitCostOnProdOrder(ProdOrderLine,MultipleLevels,false);
                  ProdOrderLine.Get(
                    ProdOrderLine.Status,
                    ProdOrderLine."Prod. Order No.",ProdOrderLine."Line No.");
                end;
                if ProdOrderLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    ROUND(ProdOrderLine."Unit Cost" / ProdOrderLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Prod. Order Component":
              begin
                ProdOrderComp.Get(
                  ReservEntry."Source Subtype",
                  ReservEntry."Source ID",
                  ReservEntry."Source Prod. Order Line",
                  ReservEntry."Source Ref. No.");
                if ProdOrderComp."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(Item."Unit Cost" / ProdOrderComp."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Planning Component":
              begin
                PlanningComponent.Get(
                  ReservEntry."Source ID",ReservEntry."Source Batch Name",ReservEntry."Source Prod. Order Line",
                  ReservEntry."Source Ref. No.");
                if PlanningComponent."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(Item."Unit Cost" / PlanningComponent."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
            Database::"Service Line":
              begin
                ServiceInvLine.Get(ReservEntry."Source Subtype",ReservEntry."Source ID",ReservEntry."Source Ref. No.");
                if ServiceInvLine."Qty. per Unit of Measure" <> 0 then
                  TotalUnitCost :=
                    TotalUnitCost +
                    ROUND(ServiceInvLine."Unit Cost (LCY)" / ServiceInvLine."Qty. per Unit of Measure",0.00001) *
                    ReservEntry.Quantity;
              end;
          end;
          TotalCostQty := TotalCostQty + ReservEntry.Quantity;
        until ReservEntry.Next = 0;
    end;

    procedure UpdateUnitCostOnProdOrder(var ProdOrderLine: Record "Prod. Order Line";MultipleLevels: Boolean;UpdateReservation: Boolean)
    var
        Item: Record Item;
        ProdOrderComp: Record "Prod. Order Component";
        ReservEntry: Record "Reservation Entry";
        TotalCostQty: Decimal;
        TotalUnitCost: Decimal;
        UnitCost: Decimal;
    begin
        if not Item.Get(ProdOrderLine."Item No.") then
          exit;

        if Item."Costing Method" > Item."costing method"::Average then
          exit;

        ProdOrderComp.SetRange(Status,ProdOrderLine.Status);
        ProdOrderComp.SetRange("Prod. Order No.",ProdOrderLine."Prod. Order No.");
        ProdOrderComp.SetRange("Prod. Order Line No.",ProdOrderLine."Line No.");

        if ProdOrderComp.Find('-') then
          repeat
            TotalCostQty := 0;
            TotalUnitCost := 0;
            Item.Get(ProdOrderComp."Item No.");
            if Item."Costing Method" <= Item."costing method"::Average then begin
              ReservEntry."Source Type" := Database::"Prod. Order Component";
              ReservEngineMgt.InitFilterAndSortingFor(ReservEntry,true);
              ReserveProdOrderComp.FilterReservFor(ReservEntry,ProdOrderComp);
              if ReservEntry.Find('-') then
                SumTrackingCosts(ReservEntry,TotalUnitCost,TotalCostQty,MultipleLevels,Item);
              ProdOrderComp.CalcFields("Reserved Qty. (Base)");
              TotalUnitCost :=
                TotalUnitCost +
                (Item."Unit Cost" *
                 (ProdOrderComp."Expected Qty. (Base)" - ProdOrderComp."Reserved Qty. (Base)"));
              TotalCostQty :=
                TotalCostQty +
                (ProdOrderComp."Expected Qty. (Base)" - ProdOrderComp."Reserved Qty. (Base)");
              if TotalCostQty <> 0 then begin
                UnitCost := TotalUnitCost / TotalCostQty * ProdOrderComp."Qty. per Unit of Measure";
                if ProdOrderComp."Unit Cost" <> UnitCost then begin
                  ProdOrderComp.Validate("Unit Cost",UnitCost);
                  ProdOrderComp.Modify;
                end;
              end;
            end;
          until ProdOrderComp.Next = 0;

        ProdOrderLine.CalcFields(
          "Expected Operation Cost Amt.",
          "Total Exp. Oper. Output (Qty.)",
          "Expected Component Cost Amt.");

        if ProdOrderLine."Total Exp. Oper. Output (Qty.)" <> 0 then
          ProdOrderLine."Expected Operation Cost Amt." :=
            ROUND(
              ProdOrderLine."Expected Operation Cost Amt." /
              ProdOrderLine."Total Exp. Oper. Output (Qty.)" *
              ProdOrderLine.Quantity);

        ProdOrderLine.Validate(
          "Unit Cost",
          (ProdOrderLine."Expected Operation Cost Amt." +
           ProdOrderLine."Expected Component Cost Amt.") /
          ProdOrderLine.Quantity);

        ProdOrderLine.Modify;
        if UpdateReservation then begin
          ReservEntry.Reset;
          ReservEntry."Source Type" := Database::"Prod. Order Line";
          ReservEngineMgt.InitFilterAndSortingFor(ReservEntry,false);
          ReserveProdOrderLine.FilterReservFor(ReservEntry,ProdOrderLine);
          if ProdOrderLine."Qty. per Unit of Measure" <> 0 then
            UnitCost := ROUND(ProdOrderLine."Unit Cost" / ProdOrderLine."Qty. per Unit of Measure",0.00001)
          else
            UnitCost := ProdOrderLine."Unit Cost";
          if ReservEntry.Find('-') then
            repeat
              ModifyFor(ReservEntry,UnitCost);
            until ReservEntry.Next = 0;
        end;
    end;
}

