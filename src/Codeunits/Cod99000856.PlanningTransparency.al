#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000856 "Planning Transparency"
{

    trigger OnRun()
    begin
    end;

    var
        TempInvProfileTrack: Record "Inventory Profile Track Buffer" temporary;
        TempPlanningWarning: Record "Untracked Planning Element" temporary;
        CurrReqLine: Record "Requisition Line";
        CurrTemplateName: Code[10];
        CurrWorksheetName: Code[10];
        Text000: label 'Undefined';
        Text001: label 'Production Forecast';
        Text002: label 'Blanket Order';
        Text003: label 'Safety Stock Quantity';
        Text004: label 'Reorder Point';
        Text005: label 'Maximum Inventory';
        Text006: label 'Reorder Quantity';
        Text007: label 'Maximum Order Quantity';
        Text008: label 'Minimum Order Quantity';
        Text009: label 'Order Multiple';
        Text010: label 'Dampener (% of Lot Size)';
        Text011: label 'Emergency Order';
        SequenceNo: Integer;

    procedure SetTemplAndWorksheet(TemplateName: Code[10];WorksheetName: Code[10])
    begin
        CurrTemplateName := TemplateName;
        CurrWorksheetName := WorksheetName;
    end;

    procedure FindReason(var DemandInvProfile: Record "Inventory Profile"): Integer
    var
        SurplusType: Option "None",Forecast,BlanketOrder,SafetyStock,ReorderPoint,MaxInventory,FixedOrderQty,MaxOrder,MinOrder,OrderMultiple,DampenerQty,PlanningFlexibility,Undefined;
    begin
        case DemandInvProfile."Source Type" of
          0:
            if DemandInvProfile."Order Relation" = DemandInvProfile."order relation"::"Safety Stock" then
              SurplusType := Surplustype::SafetyStock
            else
              if DemandInvProfile."Order Relation" = DemandInvProfile."order relation"::"Reorder Point" then
                SurplusType := Surplustype::ReorderPoint
              else
                SurplusType := Surplustype::Undefined;
          Database::"Sales Line":
            if DemandInvProfile."Source Order Status" = 4 then
              SurplusType := Surplustype::BlanketOrder;
          Database::"Production Forecast Entry":
            SurplusType := Surplustype::Forecast;
          else
            SurplusType := Surplustype::None;
        end;
        exit(SurplusType);
    end;

    procedure LogSurplus(SupplyLineNo: Integer;DemandLineNo: Integer;SourceType: Integer;SourceID: Code[20];Qty: Decimal;SurplusType: Option "None",Forecast,BlanketOrder,SafetyStock,ReorderPoint,MaxInventory,FixedOrderQty,MaxOrder,MinOrder,OrderMultiple,DampenerQty,PlanningFlexibility,Undefined,EmergencyOrder)
    var
        Priority: Integer;
    begin
        if (Qty = 0) or (SupplyLineNo = 0) then
          exit;

        case SurplusType of
          Surplustype::BlanketOrder:
            Priority := 1;
          Surplustype::Forecast:
            Priority := 1;
          Surplustype::SafetyStock:
            Priority := 1;
          Surplustype::ReorderPoint:
            Priority := 1;
          Surplustype::EmergencyOrder:
            Priority := 2;
          Surplustype::MaxInventory:
            Priority := 3;
          Surplustype::FixedOrderQty:
            Priority := 3;
          Surplustype::MaxOrder:
            Priority := 4;
          Surplustype::MinOrder:
            Priority := 5;
          Surplustype::OrderMultiple:
            Priority := 6;
          Surplustype::DampenerQty:
            Priority := 7;
          else
            SurplusType := Surplustype::Undefined;
        end;

        if SurplusType <> Surplustype::Undefined then begin
          TempInvProfileTrack.Init;
          TempInvProfileTrack.Priority := Priority;
          TempInvProfileTrack."Line No." := SupplyLineNo;
          TempInvProfileTrack."Demand Line No." := DemandLineNo;
          TempInvProfileTrack."Sequence No." := GetSequenceNo;
          TempInvProfileTrack."Surplus Type" := SurplusType;
          TempInvProfileTrack."Source Type" := SourceType;
          TempInvProfileTrack."Source ID" := SourceID;
          TempInvProfileTrack."Quantity Tracked" := Qty;
          TempInvProfileTrack.Insert;
        end;
    end;

    procedure ModifyLogEntry(SupplyLineNo: Integer;DemandLineNo: Integer;SourceType: Integer;SourceID: Code[20];Qty: Decimal;SurplusType: Option)
    begin
        if (Qty = 0) or (SupplyLineNo = 0) then
          exit;

        TempInvProfileTrack.SetRange("Line No.",SupplyLineNo);
        TempInvProfileTrack.SetRange("Demand Line No.",DemandLineNo);
        TempInvProfileTrack.SetRange("Surplus Type",SurplusType);
        TempInvProfileTrack.SetRange("Source Type",SourceType);
        TempInvProfileTrack.SetRange("Source ID",SourceID);
        if TempInvProfileTrack.FindLast then begin
          TempInvProfileTrack."Quantity Tracked" += Qty;
          TempInvProfileTrack.Modify;
        end;
        TempInvProfileTrack.Reset;
    end;

    procedure CleanLog(SupplyLineNo: Integer)
    begin
        TempInvProfileTrack.SetRange("Line No.",SupplyLineNo);
        if not TempInvProfileTrack.IsEmpty then
          TempInvProfileTrack.DeleteAll;
        TempInvProfileTrack.SetRange("Line No.");

        TempPlanningWarning.SetRange("Worksheet Line No.",SupplyLineNo);
        if not TempPlanningWarning.IsEmpty then
          TempPlanningWarning.DeleteAll;
        TempPlanningWarning.SetRange("Worksheet Line No.");
    end;

    procedure PublishSurplus(var SupplyInvProfile: Record "Inventory Profile";var SKU: Record "Stockkeeping Unit";var ReqLine: Record "Requisition Line";var ReservEntry: Record "Reservation Entry")
    var
        PlanningElement: Record "Untracked Planning Element";
        QtyTracked: Decimal;
        QtyRemaining: Decimal;
        QtyReorder: Decimal;
        QtyMin: Decimal;
        QtyRound: Decimal;
        DampenerQty: Decimal;
        OrderSizeParticipated: Boolean;
    begin
        TempInvProfileTrack.SetRange("Line No.",SupplyInvProfile."Line No.");

        QtyRemaining := SurplusQty(ReqLine,ReservEntry);
        QtyTracked := SupplyInvProfile."Quantity (Base)" - QtyRemaining;
        if (QtyRemaining > 0) or not TempPlanningWarning.IsEmpty then
          with TempInvProfileTrack do begin
            PlanningElement."Worksheet Template Name" := CurrTemplateName;
            PlanningElement."Worksheet Batch Name" := CurrWorksheetName;
            PlanningElement."Worksheet Line No." := SupplyInvProfile."Planning Line No.";
            if QtyRemaining <= 0 then
              SetFilter("Warning Level",'<>%1',0);
            if FindSet then
              repeat
                SetRange(Priority,Priority);
                SetRange("Demand Line No.","Demand Line No.");
                PlanningElement.Init;
                FindLast;
                PlanningElement."Track Quantity From" := QtyRemaining;
                PlanningElement."Warning Level" := "Warning Level";
                case Priority of
                  1:
                    begin  // Anticipated demand
                      CalcSums("Quantity Tracked");
                      if "Surplus Type" = "surplus type"::SafetyStock then begin
                        PlanningElement."Parameter Value" := SKU."Safety Stock Quantity";
                        "Source ID" := SKU."Item No.";
                      end else
                        if "Surplus Type" = "surplus type"::ReorderPoint then begin
                          PlanningElement."Parameter Value" := SKU."Reorder Point";
                          "Source ID" := SKU."Item No.";
                          "Quantity Tracked" := 0;
                        end;
                      PlanningElement."Untracked Quantity" := "Quantity Tracked";
                    end;
                  2:
                    // Emergency Order
                    PlanningElement."Untracked Quantity" := "Quantity Tracked";
                  3:
                    begin  // Order size
                      QtyReorder := "Quantity Tracked";
                      if QtyTracked < QtyReorder then begin
                        OrderSizeParticipated := true;
                        PlanningElement."Untracked Quantity" := QtyReorder - QtyTracked;
                        case "Surplus Type" of
                          "surplus type"::ReorderPoint:
                            PlanningElement."Parameter Value" := SKU."Reorder Point";
                          "surplus type"::FixedOrderQty:
                            PlanningElement."Parameter Value" := SKU."Reorder Quantity";
                          "surplus type"::MaxInventory:
                            PlanningElement."Parameter Value" := SKU."Maximum Inventory";
                        end;
                      end else
                        OrderSizeParticipated := false
                    end;
                  4:
                    // Maximum Order
                    if OrderSizeParticipated then begin
                      PlanningElement."Untracked Quantity" := "Quantity Tracked";
                      PlanningElement."Parameter Value" := SKU."Maximum Order Quantity";
                    end;
                  5:
                    begin  // Minimum Order
                      QtyMin := "Quantity Tracked";
                      if QtyTracked < QtyMin then
                        PlanningElement."Untracked Quantity" := QtyMin - QtyTracked;
                      PlanningElement."Parameter Value" := SKU."Minimum Order Quantity";
                    end;
                  6:
                    begin  // Rounding
                      QtyRound := SKU."Order Multiple"
                        - ROUND(SupplyInvProfile."Quantity (Base)",SKU."Order Multiple",'>')
                        + SupplyInvProfile."Quantity (Base)";
                      if QtyRound > "Quantity Tracked" then
                        QtyRound := "Quantity Tracked";
                      if QtyRound > QtyRemaining then
                        QtyRound := QtyRemaining;
                      PlanningElement."Untracked Quantity" := QtyRound;
                      PlanningElement."Parameter Value" := SKU."Order Multiple";
                    end;
                  7:
                    begin  // Dampener
                      DampenerQty := "Quantity Tracked";
                      if DampenerQty < QtyRemaining then
                        PlanningElement."Untracked Quantity" := DampenerQty
                      else
                        PlanningElement."Untracked Quantity" := QtyRemaining;
                      PlanningElement."Parameter Value" := DampenerQty;
                    end;
                end;
                if (PlanningElement."Untracked Quantity" <> 0) or
                   ("Surplus Type" = "surplus type"::ReorderPoint) or
                   ("Warning Level" > 0)
                then begin
                  PlanningElement."Track Line No." += 1;
                  PlanningElement."Item No." := SupplyInvProfile."Item No.";
                  PlanningElement."Variant Code" := SupplyInvProfile."Variant Code";
                  PlanningElement."Location Code" := SupplyInvProfile."Location Code";
                  PlanningElement."Source Type" := "Source Type";
                  PlanningElement."Source ID" := "Source ID";
                  PlanningElement.Source := ShowSurplusReason("Surplus Type");
                  QtyTracked += PlanningElement."Untracked Quantity";
                  QtyRemaining -= PlanningElement."Untracked Quantity";
                  PlanningElement."Track Quantity To" := QtyRemaining;
                  TransferWarningSourceText(TempInvProfileTrack,PlanningElement);
                  PlanningElement.Insert;
                end;
                SetRange(Priority);
                SetRange("Demand Line No.");
              until (Next = 0);

            if QtyRemaining > 0 then begin // just in case that something by accident has not been captured
              PlanningElement.Init;
              PlanningElement."Track Line No." += 1;
              PlanningElement."Item No." := SupplyInvProfile."Item No.";
              PlanningElement."Variant Code" := SupplyInvProfile."Variant Code";
              PlanningElement."Location Code" := SupplyInvProfile."Location Code";
              PlanningElement.Source := ShowSurplusReason("surplus type"::Undefined);
              PlanningElement."Track Quantity From" := QtyRemaining;
              PlanningElement."Untracked Quantity" := QtyRemaining;
              QtyTracked += PlanningElement."Untracked Quantity";
              QtyRemaining -= PlanningElement."Untracked Quantity";
              PlanningElement."Track Quantity To" := QtyRemaining;
              PlanningElement.Insert;
            end;
          end;
        TempInvProfileTrack.SetRange("Line No.");
        TempInvProfileTrack.SetRange("Warning Level");
        CleanLog(SupplyInvProfile."Line No.");
    end;

    local procedure SurplusQty(var ReqLine: Record "Requisition Line";var ReservEntry: Record "Reservation Entry"): Decimal
    var
        CrntReservEntry: Record "Reservation Entry";
        ReservEngineMgt: Codeunit "Reservation Engine Mgt.";
        ReqLineReserve: Codeunit "Req. Line-Reserve";
        QtyTracked1: Decimal;
        QtyTracked2: Decimal;
    begin
        CrntReservEntry.Copy(ReservEntry);
        ReservEngineMgt.InitFilterAndSortingLookupFor(ReservEntry,false);
        ReqLineReserve.FilterReservFor(ReservEntry,ReqLine);
        with ReservEntry do begin
          SetRange("Reservation Status","reservation status"::Surplus);
          if FindSet then
            repeat
              QtyTracked1 += "Quantity (Base)";
            until Next = 0;
          Reset;
          if ReqLine."Action Message" > ReqLine."action message"::New then begin
            case ReqLine."Ref. Order Type" of
              ReqLine."ref. order type"::Purchase:
                begin
                  SetRange("Source ID",ReqLine."Ref. Order No.");
                  SetRange("Source Ref. No.",ReqLine."Ref. Line No.");
                  SetRange("Source Type",Database::"Purchase Line");
                  SetRange("Source Subtype",1);
                end;
              ReqLine."ref. order type"::"Prod. Order":
                begin
                  SetRange("Source ID",ReqLine."Ref. Order No.");
                  SetRange("Source Type",Database::"Prod. Order Line");
                  SetRange("Source Subtype",ReqLine."Ref. Order Status");
                  SetRange("Source Prod. Order Line",ReqLine."Ref. Line No.");
                end;
              ReqLine."ref. order type"::Transfer:
                begin
                  SetRange("Source ID",ReqLine."Ref. Order No.");
                  SetRange("Source Ref. No.",ReqLine."Ref. Line No.");
                  SetRange("Source Type",Database::"Transfer Line");
                  SetRange("Source Subtype",1); // Inbound
                  SetRange("Source Prod. Order Line",0);
                end;
            end;
            SetRange("Reservation Status","reservation status"::Surplus);
            if FindSet then
              repeat
                QtyTracked2 += "Quantity (Base)";
              until Next = 0;
            Reset;
          end;
        end;
        ReservEntry.Copy(CrntReservEntry);
        exit(QtyTracked1 + QtyTracked2);
    end;

    local procedure ShowSurplusReason(SurplusType: Option "None",Forecast,BlanketOrder,SafetyStock,ReorderPoint,MaxInventory,FixedOrderQty,MaxOrder,MinOrder,OrderMultiple,DampenerQty,PlanningFlexibility,Undefined,EmergencyOrder) ReturnText: Text[50]
    begin
        case SurplusType of
          Surplustype::Forecast:
            ReturnText := Text001;
          Surplustype::BlanketOrder:
            ReturnText := Text002;
          Surplustype::SafetyStock:
            ReturnText := Text003;
          Surplustype::ReorderPoint:
            ReturnText := Text004;
          Surplustype::MaxInventory:
            ReturnText := Text005;
          Surplustype::FixedOrderQty:
            ReturnText := Text006;
          Surplustype::MaxOrder:
            ReturnText := Text007;
          Surplustype::MinOrder:
            ReturnText := Text008;
          Surplustype::OrderMultiple:
            ReturnText := Text009;
          Surplustype::DampenerQty:
            ReturnText := Text010;
          Surplustype::EmergencyOrder:
            ReturnText := Text011;
          else
            ReturnText := Text000;
        end;
    end;

    procedure SetCurrReqLine(var CurrentReqLine: Record "Requisition Line")
    begin
        CurrReqLine := CurrentReqLine;
    end;

    procedure DrillDownUntrackedQty(CaptionText: Text[80])
    var
        PlanningElement: Record "Untracked Planning Element";
        SurplusTrackForm: Page "Untracked Planning Elements";
    begin
        with CurrReqLine do begin
          if not ("Planning Line Origin" <> "planning line origin"::" ") then // IsPlanning
            exit;

          PlanningElement.SetRange("Worksheet Template Name","Worksheet Template Name");
          PlanningElement.SetRange("Worksheet Batch Name","Journal Batch Name");
          PlanningElement.SetRange("Worksheet Line No.","Line No.");

          SurplusTrackForm.SetTableview(PlanningElement);
          SurplusTrackForm.SetCaption(CaptionText);
          SurplusTrackForm.RunModal;
        end;
    end;

    procedure ReqLineWarningLevel(ReqLine: Record "Requisition Line") WarningLevel: Integer
    var
        PlanningElement: Record "Untracked Planning Element";
    begin
        with ReqLine do begin
          PlanningElement.SetRange("Worksheet Template Name","Worksheet Template Name");
          PlanningElement.SetRange("Worksheet Batch Name","Journal Batch Name");
          PlanningElement.SetRange("Worksheet Line No.","Line No.");
          PlanningElement.SetFilter("Warning Level",'>%1',0);
          if PlanningElement.FindSet then
            repeat
              if (PlanningElement."Warning Level" < WarningLevel) or (WarningLevel = 0) then
                WarningLevel := PlanningElement."Warning Level";
            until PlanningElement.Next = 0;
        end;
    end;

    procedure LogWarning(SupplyLineNo: Integer;ReqLine: Record "Requisition Line";WarningLevel: Option;Source: Text[200]): Boolean
    var
        PlanningElement: Record "Untracked Planning Element";
    begin
        if SupplyLineNo = 0 then
          with ReqLine do begin
            PlanningElement.SetRange("Worksheet Template Name","Worksheet Template Name");
            PlanningElement.SetRange("Worksheet Batch Name","Journal Batch Name");
            PlanningElement.SetRange("Worksheet Line No.","Line No.");

            if not PlanningElement.FindLast then begin
              PlanningElement."Worksheet Template Name" := "Worksheet Template Name";
              PlanningElement."Worksheet Batch Name" := "Journal Batch Name";
              PlanningElement."Worksheet Line No." := "Line No.";
            end;

            PlanningElement.Init;
            PlanningElement."Track Line No." += 1;
            PlanningElement.Source := Source;
            PlanningElement."Warning Level" := WarningLevel;
            PlanningElement.Insert;
          end
        else
          with TempInvProfileTrack do begin
            Init;
            "Line No." := SupplyLineNo;
            Priority := 10;
            "Sequence No." := GetSequenceNo;
            "Demand Line No." := 0;
            "Surplus Type" := 0;
            "Source Type" := 0;
            "Source ID" := '';
            "Quantity Tracked" := 0;
            "Warning Level" := WarningLevel;
            Insert;
            TempPlanningWarning.Init;
            TempPlanningWarning."Worksheet Template Name" := '';
            TempPlanningWarning."Worksheet Batch Name" := '';
            TempPlanningWarning."Worksheet Line No." := SupplyLineNo;
            TempPlanningWarning."Track Line No." := "Sequence No.";
            TempPlanningWarning.Source := Source;
            TempPlanningWarning.Insert;
          end;
        exit(true);
    end;

    local procedure TransferWarningSourceText(FromInvProfileTrack: Record "Inventory Profile Track Buffer" temporary;var ToPlanningElement: Record "Untracked Planning Element")
    begin
        if FromInvProfileTrack."Warning Level" = 0 then
          exit;
        if TempPlanningWarning.Get('','',FromInvProfileTrack."Line No.",FromInvProfileTrack."Sequence No.") then begin
          ToPlanningElement.Source := TempPlanningWarning.Source;
          TempPlanningWarning.Delete;
        end;
    end;

    local procedure GetSequenceNo(): Integer
    begin
        SequenceNo := SequenceNo + 1;
        exit(SequenceNo);
    end;
}

