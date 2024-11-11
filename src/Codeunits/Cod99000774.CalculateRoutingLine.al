#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000774 "Calculate Routing Line"
{
    Permissions = TableData "Production Order"=r,
                  TableData "Prod. Order Line"=r,
                  TableData "Prod. Order Routing Line"=im,
                  TableData "Prod. Order Capacity Need"=rimd,
                  TableData "Work Center"=r,
                  TableData "Calendar Entry"=r,
                  TableData "Machine Center"=r,
                  TableData "Manufacturing Setup"=r,
                  TableData "Capacity Constrained Resource"=r;

    trigger OnRun()
    begin
    end;

    var
        Text000: label 'Error when calculating %1. Calendar is not available %2 %3 for %4 %5.';
        Text001: label 'backward';
        Text002: label 'before';
        Text003: label 'forward';
        Text004: label 'after';
        Text005: label 'The sum of setup, move and wait time exceeds the available time in the period.';
        Text006: label 'fixed schedule';
        Text007: label 'Starting time must be before ending time.';
        MfgSetup: Record "Manufacturing Setup";
        Workcenter: Record "Work Center";
        Workcenter2: Record "Work Center";
        MachineCenter: Record "Machine Center";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
        ProdOrderCapNeed2: Record "Prod. Order Capacity Need";
        CalendarEntry: Record "Calendar Entry";
        CalendarMgt: Codeunit "Shop Calendar Management";
        NextCapNeedLineNo: Integer;
        ProdStartingTime: Time;
        ProdEndingTime: Time;
        ProdStartingDate: Date;
        ProdEndingDate: Date;
        MaxLotSize: Decimal;
        TotalLotSize: Decimal;
        ProdOrderQty: Decimal;
        TotalScrap: Decimal;
        LotSize: Decimal;
        RemainNeedQty: Decimal;
        ConCurrCap: Decimal;
        RunStartingDateTime: DateTime;
        RunEndingDateTime: DateTime;
        FirstInBatch: Boolean;
        FirstEntry: Boolean;
        UpdateDates: Boolean;
        WaitTimeOnly: Boolean;
        CurrentWorkCenterNo: Code[20];
        CurrentTimeFactor: Decimal;
        CurrentRounding: Decimal;

    local procedure TestForError(DirectionTxt: Text[30];BefAfterTxt: Text[30];Date: Date)
    begin
        if RemainNeedQty <> 0 then
          Error(
            Text000,
            DirectionTxt,
            BefAfterTxt,
            Date,
            ProdOrderRoutingLine.Type,
            ProdOrderRoutingLine."No.");
    end;

    local procedure CreateCapNeed(NeedDate: Date;StartingTime: Time;EndingTime: Time;NeedQty: Decimal;TimeType: Option "Setup Time","Run Time";Direction: Option Forward,Backward)
    begin
        ProdOrderCapNeed.Init;
        ProdOrderCapNeed.Status := ProdOrder.Status;
        ProdOrderCapNeed."Prod. Order No." := ProdOrder."No.";
        ProdOrderCapNeed."Routing No." := ProdOrderRoutingLine."Routing No.";
        ProdOrderCapNeed."Routing Reference No." := ProdOrderRoutingLine."Routing Reference No.";
        ProdOrderCapNeed."Line No." := NextCapNeedLineNo;
        ProdOrderCapNeed.Type := ProdOrderRoutingLine.Type;
        ProdOrderCapNeed."No." := ProdOrderRoutingLine."No.";
        ProdOrderCapNeed."Work Center No." := ProdOrderRoutingLine."Work Center No.";
        ProdOrderCapNeed."Operation No." := ProdOrderRoutingLine."Operation No.";
        ProdOrderCapNeed."Work Center Group Code" := ProdOrderRoutingLine."Work Center Group Code";
        ProdOrderCapNeed.Date := NeedDate;
        ProdOrderCapNeed."Starting Time" := StartingTime;
        ProdOrderCapNeed."Ending Time" := EndingTime;
        ProdOrderCapNeed."Needed Time" := NeedQty;
        ProdOrderCapNeed."Needed Time (ms)" := NeedQty * CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code");
        ProdOrderCapNeed."Concurrent Capacities" := ConCurrCap;
        ProdOrderCapNeed.Efficiency := CalendarEntry.Efficiency;
        ProdOrderCapNeed."Requested Only" := false;
        ProdOrderCapNeed.Active := true;
        if ProdOrder.Status <> ProdOrder.Status::Simulated then begin
          ProdOrderCapNeed."Allocated Time" := NeedQty;
          ProdOrderRoutingLine."Expected Capacity Need" :=
            ProdOrderRoutingLine."Expected Capacity Need" + ProdOrderCapNeed."Needed Time (ms)";
        end;

        ProdOrderCapNeed."Time Type" := TimeType;
        if TimeType = Timetype::"Run Time" then
          ProdOrderCapNeed."Lot Size" := LotSize;

        if TimeType = Timetype::"Run Time" then
          if RemainNeedQty = 0 then begin
            if FirstInBatch then
              ProdOrderCapNeed."Send-Ahead Type" := ProdOrderCapNeed."send-ahead type"::Both
            else
              case Direction of
                Direction::Forward:
                  ProdOrderCapNeed."Send-Ahead Type" := ProdOrderCapNeed."send-ahead type"::Output;
                Direction::Backward:
                  ProdOrderCapNeed."Send-Ahead Type" := ProdOrderCapNeed."send-ahead type"::Input;
              end;
          end else
            if FirstInBatch then
              case Direction of
                Direction::Forward:
                  ProdOrderCapNeed."Send-Ahead Type" := ProdOrderCapNeed."send-ahead type"::Input;
                Direction::Backward:
                  ProdOrderCapNeed."Send-Ahead Type" := ProdOrderCapNeed."send-ahead type"::Output;
              end;

        ProdOrderCapNeed.UpdateDatetime;

        ProdOrderCapNeed.Insert;

        NextCapNeedLineNo := NextCapNeedLineNo + 1;
    end;

    local procedure CreateLoadBack(TimeType: Option "Setup Time","Run Time","Wait Time","Move Time","Queue Time";Write: Boolean)
    var
        OldCalendarEntry: Record "Calendar Entry";
        AvQtyBase: Decimal;
        RelevantEfficiency: Decimal;
        xConCurrCap: Decimal;
        RemainNeedQtyBase: Decimal;
        StartingTime: Time;
        StopLoop: Boolean;
    begin
        xConCurrCap := 1;
        if (RemainNeedQty = 0) and ((not FirstEntry) or (not Write) or WaitTimeOnly) then
          exit;
        if CalendarEntry.Find('+') then begin
          if (TimeType = Timetype::"Wait Time") and (CalendarEntry.Date < ProdEndingDate) then begin
            CalendarEntry.Date := ProdEndingDate;
            CreateCalendarEntry(CalendarEntry);
          end;
          GetCurrentWorkCenterTimeFactorAndRounding(CalendarEntry."Work Center No.");
          RemainNeedQtyBase := ROUND(RemainNeedQty * CurrentTimeFactor,CurrentRounding);
          repeat
            OldCalendarEntry := CalendarEntry;
            ConCurrCap := ProdOrderRoutingLine."Concurrent Capacities";
            if (ConCurrCap = 0) or (CalendarEntry.Capacity < ConCurrCap) then
              ConCurrCap := CalendarEntry.Capacity;
            if TimeType <> Timetype::"Run Time" then
              RemainNeedQtyBase := ROUND(RemainNeedQtyBase * ConCurrCap / xConCurrCap,CurrentRounding);
            xConCurrCap := ConCurrCap;
            AvQtyBase :=
              CalcAvailQtyBase(
                CalendarEntry,ProdEndingDate,ProdEndingTime,TimeType,ConCurrCap,false,CurrentTimeFactor,CurrentRounding);

            if AvQtyBase > RemainNeedQtyBase then
              AvQtyBase := RemainNeedQtyBase;
            if TimeType in [Timetype::"Setup Time",Timetype::"Run Time"] then
              RelevantEfficiency := CalendarEntry.Efficiency
            else
              RelevantEfficiency := 100;
            StartingTime :=
              CalendarMgt.CalcTimeSubtract(
                CalendarEntry."Ending Time",
                ROUND(AvQtyBase * 100 / RelevantEfficiency / ConCurrCap,1,'>'));
            RemainNeedQtyBase := RemainNeedQtyBase - AvQtyBase;
            if Write then begin
              RemainNeedQty := ROUND(RemainNeedQtyBase / CurrentTimeFactor,CurrentRounding);
              CreateCapNeed(
                CalendarEntry.Date,StartingTime,CalendarEntry."Ending Time",
                ROUND(AvQtyBase / CurrentTimeFactor,CurrentRounding),TimeType,1);
              FirstInBatch := false;
              FirstEntry := false;
            end;
            if UpdateDates and
               ((CalendarEntry."Capacity (Effective)" <> 0) or (TimeType = Timetype::"Wait Time"))
            then begin
              ProdOrderRoutingLine."Ending Time" := CalendarEntry."Ending Time";
              ProdOrderRoutingLine."Ending Date" := CalendarEntry.Date;
              UpdateDates := false;
            end;
            ProdEndingTime := StartingTime;
            ProdEndingDate := CalendarEntry.Date;
            ProdOrderRoutingLine."Starting Time" := StartingTime;
            ProdOrderRoutingLine."Starting Date" := CalendarEntry.Date;

            if (RemainNeedQtyBase = 0) and ((not FirstEntry) or (not Write)) then
              StopLoop := true
            else
              if TimeType = Timetype::"Wait Time" then begin
                StopLoop := false;
                ReturnNextCalendarEntry(CalendarEntry,OldCalendarEntry,0);
              end else begin
                CalendarEntry := OldCalendarEntry;
                StopLoop := CalendarEntry.Next(-1) = 0;
              end;
          until StopLoop;
          RemainNeedQty := ROUND(RemainNeedQtyBase / CurrentTimeFactor,CurrentRounding);
        end;
    end;

    local procedure CreateLoadForward(TimeType: Option "Setup Time","Run Time","Wait Time","Move Time","Queue Time";Write: Boolean;LoadFactor: Decimal)
    var
        OldCalendarEntry: Record "Calendar Entry";
        AvQtyBase: Decimal;
        RelevantEfficiency: Decimal;
        xConCurrCap: Decimal;
        RemainNeedQtyBase: Decimal;
        EndingTime: Time;
        StopLoop: Boolean;
    begin
        xConCurrCap := 1;
        if (RemainNeedQty = 0) and ((not FirstEntry) or (not Write) or WaitTimeOnly) then
          exit;
        if CalendarEntry.Find('-') then begin
          if (TimeType = Timetype::"Wait Time") and (CalendarEntry.Date > ProdStartingDate) then begin
            CalendarEntry.Date := ProdStartingDate;
            CreateCalendarEntry(CalendarEntry);
          end;
          if CalendarEntry."Capacity (Effective)" = 0 then begin
            CalendarEntry."Starting Time" := ProdStartingTime;
            CalendarEntry.Date := ProdStartingDate;
          end;
          if CalendarEntry."Work Center No." = Workcenter."No." then
            GetCurrentWorkCenterTimeFactorAndRounding(Workcenter."No.")
          else
            GetCurrentWorkCenterTimeFactorAndRounding(CalendarEntry."Work Center No.");
          RemainNeedQtyBase := ROUND(RemainNeedQty * CurrentTimeFactor,CurrentRounding);
          repeat
            OldCalendarEntry := CalendarEntry;
            ConCurrCap := ProdOrderRoutingLine."Concurrent Capacities";
            if (ConCurrCap = 0) or (CalendarEntry.Capacity < ConCurrCap) then
              ConCurrCap := CalendarEntry.Capacity;
            if TimeType <> Timetype::"Run Time" then
              RemainNeedQtyBase := ROUND(RemainNeedQtyBase * ConCurrCap / xConCurrCap,CurrentRounding);
            xConCurrCap := ConCurrCap;
            AvQtyBase :=
              CalcAvailQtyBase(
                CalendarEntry,ProdStartingDate,ProdStartingTime,TimeType,ConCurrCap,true,CurrentTimeFactor,CurrentRounding);

            if AvQtyBase * LoadFactor > RemainNeedQtyBase then
              AvQtyBase := ROUND(RemainNeedQtyBase / LoadFactor,CurrentRounding);

            if TimeType in [Timetype::"Setup Time",Timetype::"Run Time"] then
              RelevantEfficiency := CalendarEntry.Efficiency
            else
              RelevantEfficiency := 100;
            EndingTime :=
              CalendarEntry."Starting Time" + ROUND(AvQtyBase * 100 / RelevantEfficiency / ConCurrCap,1,'>');

            if AvQtyBase * LoadFactor >= 0 then
              RemainNeedQtyBase := RemainNeedQtyBase - AvQtyBase * LoadFactor;
            if Write then begin
              RemainNeedQty := ROUND(RemainNeedQtyBase / CurrentTimeFactor,CurrentRounding);
              CreateCapNeed(
                CalendarEntry.Date,CalendarEntry."Starting Time",EndingTime,
                ROUND(AvQtyBase * LoadFactor / CurrentTimeFactor,CurrentRounding),TimeType,0);
              FirstInBatch := false;
              FirstEntry := false;
            end;
            if UpdateDates and
               ((CalendarEntry."Capacity (Effective)" <> 0) or (TimeType = Timetype::"Wait Time"))
            then begin
              ProdOrderRoutingLine."Starting Time" := CalendarEntry."Starting Time";
              ProdOrderRoutingLine."Starting Date" := CalendarEntry.Date;
              UpdateDates := false;
            end;
            if (EndingTime = 000000T) and (AvQtyBase <> 0) then
              // Ending Time reached 24:00:00 so we need to move date as well
              CalendarEntry.Date := CalendarEntry.Date + 1;
            ProdStartingTime := EndingTime;
            ProdStartingDate := CalendarEntry.Date;
            ProdOrderRoutingLine."Ending Time" := EndingTime;
            ProdOrderRoutingLine."Ending Date" := CalendarEntry.Date;

            if ProdOrderRoutingLine."Schedule Manually" then begin
              if TimeType = Timetype::"Setup Time" then
                RunStartingDateTime := CreateDatetime(ProdStartingDate,ProdStartingTime);
              if RemainNeedQtyBase < 0 then
                RemainNeedQtyBase := 0;
            end;

            if (RemainNeedQtyBase = 0) and ((not FirstEntry) or (not Write)) and (AvQtyBase * LoadFactor >= 0) then
              StopLoop := true
            else
              if TimeType = Timetype::"Wait Time" then begin
                StopLoop := false;
                ReturnNextCalendarEntry(CalendarEntry,OldCalendarEntry,1);
              end else begin
                CalendarEntry := OldCalendarEntry;
                StopLoop := CalendarEntry.Next = 0;
              end;
          until StopLoop;
          RemainNeedQty := ROUND(RemainNeedQtyBase / CurrentTimeFactor,CurrentRounding);
        end;
    end;

    local procedure AvailableCapacity(CapType: Option "Work Center","Machine Center";CapNo: Code[20];StartingDateTime: DateTime;EndingDateTime: DateTime) AvQty: Decimal
    var
        CalendarEntry2: Record "Calendar Entry";
        ConCurrCapacity: Decimal;
        Overlap: Decimal;
        TotalDuration: Decimal;
    begin
        CalendarEntry2.SetCapacityFilters(CapType,CapNo);
        CalendarEntry2.SetFilter("Starting Date-Time",'<=%1',EndingDateTime);
        CalendarEntry2.SetFilter("Ending Date-Time",'>=%1',StartingDateTime);

        if CalendarEntry2.Find('-') then
          repeat
            ConCurrCapacity := ProdOrderRoutingLine."Concurrent Capacities";
            if (ConCurrCapacity = 0) or (CalendarEntry2.Capacity < ConCurrCapacity) then
              ConCurrCapacity := CalendarEntry2.Capacity;

            Overlap := 0;
            if StartingDateTime > CalendarEntry2."Starting Date-Time" then
              Overlap := CalcDuration(CalendarEntry2."Starting Date-Time",StartingDateTime);
            if EndingDateTime < CalendarEntry2."Ending Date-Time" then
              Overlap := Overlap + CalcDuration(EndingDateTime,CalendarEntry2."Ending Date-Time");

            TotalDuration := CalcDuration(CalendarEntry2."Starting Date-Time",CalendarEntry2."Ending Date-Time");

            AvQty := AvQty +
              ROUND(
                ((TotalDuration - Overlap) / TotalDuration) *
                CalendarEntry2."Capacity (Effective)" / CalendarEntry2.Capacity * ConCurrCapacity,
                Workcenter."Calendar Rounding Precision");
          until CalendarEntry2.Next = 0;
        exit(AvQty);
    end;

    local procedure LoadCapBack(CapType: Option "Work Center","Machine Center";CapNo: Code[20];TimeType: Option "Setup Time","Run Time","Wait Time","Move Time","Queue Time";Write: Boolean)
    begin
        ProdOrderRoutingLine."Starting Date" := ProdEndingDate;
        ProdOrderRoutingLine."Starting Time" := ProdEndingTime;

        CalendarEntry.SetCapacityFilters(CapType,CapNo);
        CalendarEntry.SetRange("Ending Date-Time",0DT,CreateDatetime(ProdEndingDate + 1,ProdEndingTime));
        CalendarEntry.SetRange("Starting Date-Time",0DT,CreateDatetime(ProdEndingDate,ProdEndingTime));

        CreateLoadBack(TimeType,Write);

        if RemainNeedQty = 0 then
          exit;

        TestForError(Text001,Text002,ProdOrderRoutingLine."Starting Date");
    end;

    local procedure LoadCapForward(CapType: Option "Work Center","Machine Center";CapNo: Code[20];TimeType: Option "Setup Time","Run Time","Wait Time","Move Time","Queue Time";Write: Boolean)
    var
        TotalAvailCapacity: Decimal;
        LoadFactor: Decimal;
    begin
        ProdOrderRoutingLine."Ending Date" := ProdStartingDate;
        ProdOrderRoutingLine."Ending Time" := ProdStartingTime;

        CalendarEntry.SetCapacityFilters(CapType,CapNo);
        CalendarEntry.SetFilter("Starting Date-Time",'>=%1',CreateDatetime(ProdStartingDate - 1,ProdStartingTime));
        if TimeType = Timetype::"Wait Time" then
          CalendarEntry.SetFilter("Ending Date-Time",'>=%1',CreateDatetime(ProdStartingDate,000000T))
        else
          CalendarEntry.SetFilter("Ending Date-Time",'>=%1',CreateDatetime(ProdStartingDate,ProdStartingTime));

        if ProdOrderRoutingLine."Schedule Manually" and (TimeType = Timetype::"Run Time") then begin
          if (RunEndingDateTime < RunStartingDateTime) or
             ((RunEndingDateTime = RunStartingDateTime) and
              (ProdOrderRoutingLine."Run Time" <> 0) and
              (ProdOrderRoutingLine."Input Quantity" <> 0))
          then
            Error(Text005);
          TotalAvailCapacity :=
            AvailableCapacity(CapType,CapNo,RunStartingDateTime,RunEndingDateTime);
          if TotalAvailCapacity = 0 then begin
            TestForError(Text006,Text002,Dt2Date(RunEndingDateTime));
            LoadFactor := 0;
          end else
            LoadFactor := ROUND(RemainNeedQty / TotalAvailCapacity,Workcenter."Calendar Rounding Precision",'>');
        end else
          LoadFactor := 1;

        CreateLoadForward(TimeType,Write,LoadFactor);

        if RemainNeedQty = 0 then
          exit;

        TestForError(Text003,Text004,ProdOrderRoutingLine."Ending Date");
    end;

    local procedure CalcMoveAndWaitBack()
    begin
        UpdateDates := true;

        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Move Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Move Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");

        LoadCapBack(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.",3,false);
        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Wait Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Wait Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        LoadCapBack(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.",2,false);
    end;

    local procedure GetSendAheadStartingTime(ProdOrderRoutingLine2: Record "Prod. Order Routing Line";FirstLine: Boolean;var SendAheadLotSize: Decimal): Boolean
    var
        ProdOrderCapNeed3: Record "Prod. Order Capacity Need";
        ExpectedTime: Decimal;
        ResidualLotSize: Decimal;
    begin
        ProdStartingDate := ProdOrderRoutingLine2."Starting Date";
        ProdStartingTime := ProdOrderRoutingLine2."Starting Time";
        SendAheadLotSize := MaxLotSize;
        if TotalLotSize = MaxLotSize then
          exit(true);

        with ProdOrderRoutingLine2 do begin
          if (ProdOrderRoutingLine."Send-Ahead Quantity" = 0) or
             (ProdOrderRoutingLine."Send-Ahead Quantity" >= MaxLotSize)
          then begin
            TotalLotSize := SendAheadLotSize;
            exit(false);
          end;
          SendAheadLotSize := ProdOrderRoutingLine."Send-Ahead Quantity";
          if MaxLotSize < (TotalLotSize + SendAheadLotSize) then begin
            SendAheadLotSize := MaxLotSize - TotalLotSize;
            TotalLotSize := MaxLotSize;
          end else begin
            if TotalLotSize = 0 then begin
              ResidualLotSize := MaxLotSize - SendAheadLotSize * ROUND(MaxLotSize / SendAheadLotSize,1,'<');
              if ResidualLotSize > 0 then
                SendAheadLotSize := ResidualLotSize;
            end;
            TotalLotSize := TotalLotSize + SendAheadLotSize;
          end;
          Workcenter2.Get("Work Center No.");
          if "Lot Size" = 0 then
            "Lot Size" := 1;
          ExpectedTime :=
            ROUND(
              "Run Time" * SendAheadLotSize / "Lot Size" *
              CalendarMgt.TimeFactor("Run Time Unit of Meas. Code") /
              CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
              Workcenter2."Calendar Rounding Precision");
          if FirstLine then begin
            ProdOrderCapNeed2.Reset;
            ProdOrderCapNeed2.SetCurrentkey(Status,"Prod. Order No.","Routing Reference No.","Operation No.",Date,"Starting Time");
            ProdOrderCapNeed2.SetRange(Status,Status);
            ProdOrderCapNeed2.SetRange("Prod. Order No.","Prod. Order No.");
            ProdOrderCapNeed2.SetRange("Requested Only",false);
            ProdOrderCapNeed2.SetRange("Routing No.","Routing No.");
            ProdOrderCapNeed2.SetRange("Routing Reference No.","Routing Reference No.");
            ProdOrderCapNeed2.SetRange("Operation No.","Operation No.");
            if not ProdOrderCapNeed2.Find('+') then begin
              ProdStartingDate := "Ending Date";
              ProdStartingTime := "Ending Time";
              exit(false);
            end;
          end;
          repeat
            if ExpectedTime <= ProdOrderCapNeed2."Needed Time" then begin
              ProdOrderCapNeed2."Ending Time" :=
                CalendarMgt.CalcTimeSubtract(
                  ProdOrderCapNeed2."Ending Time",
                  ROUND(
                    ExpectedTime *
                    CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code") /
                    ProdOrderCapNeed2.Efficiency * 100 /
                    ProdOrderCapNeed2."Concurrent Capacities",1));
              ProdOrderCapNeed2."Needed Time" :=
                ProdOrderCapNeed2."Needed Time" - ExpectedTime;
              ProdStartingTime := ProdOrderCapNeed2."Ending Time";
              ProdStartingDate := ProdOrderCapNeed2.Date;
              if MaxLotSize = TotalLotSize then begin
                ProdOrderCapNeed3.SetCurrentkey(Status,"Prod. Order No.","Routing Reference No.","Operation No.",Date,"Starting Time");
                ProdOrderCapNeed3.CopyFilters(ProdOrderCapNeed2);
                ProdOrderCapNeed3.SetRange("Time Type",ProdOrderCapNeed3."time type"::Setup);
                if ProdOrderCapNeed3.FindFirst then begin
                  ProdStartingTime := ProdOrderCapNeed3."Starting Time";
                  ProdStartingDate := ProdOrderCapNeed3.Date;
                end;
              end;
              exit(false);
            end else
              ExpectedTime := ExpectedTime - ProdOrderCapNeed2."Needed Time";
          until ProdOrderCapNeed2.Next(-1) = 0;
        end;
        exit(false);
    end;

    local procedure CalcRoutingLineBack(CalculateEndDate: Boolean)
    var
        ProdOrderRoutingLine2: Record "Prod. Order Routing Line";
        ProdOrderRoutingLine3: Record "Prod. Order Routing Line";
        ConstrainedCapacity: Record "Capacity Constrained Resource";
        ParentWorkCenter: Record "Capacity Constrained Resource";
        TmpProdOrderRtngLine: Record "Prod. Order Routing Line" temporary;
        TmpProdOrderCapNeed: Record "Prod. Order Capacity Need" temporary;
        SendAheadLotSize: Decimal;
        ParentIsConstrained: Boolean;
        ResourceIsConstrained: Boolean;
    begin
        CalendarEntry.SetRange(Date,0D,ProdOrderRoutingLine."Ending Date");

        ProdEndingTime := ProdOrderRoutingLine."Ending Time";
        ProdEndingDate := ProdOrderRoutingLine."Ending Date";
        ProdStartingTime := ProdOrderRoutingLine."Ending Time";
        ProdStartingDate := ProdOrderRoutingLine."Ending Date";

        FirstEntry := true;
        if (ProdOrderRoutingLine."Next Operation No." <> '') and
           CalculateEndDate
        then begin
          Clear(ProdOrderRoutingLine3);

          TmpProdOrderRtngLine.Reset;
          TmpProdOrderRtngLine.DeleteAll;
          TmpProdOrderCapNeed.Reset;
          TmpProdOrderCapNeed.DeleteAll;

          SetRoutingLineFilters(ProdOrderRoutingLine,ProdOrderRoutingLine2);
          ProdOrderRoutingLine2.SetFilter("Operation No.",ProdOrderRoutingLine."Next Operation No.");
          if ProdOrderRoutingLine2.Find('-') then
            repeat
              TotalLotSize := 0;
              GetSendAheadStartingTime(ProdOrderRoutingLine2,true,SendAheadLotSize);

              TmpProdOrderRtngLine.Copy(ProdOrderRoutingLine2);
              TmpProdOrderRtngLine.Insert;
              TmpProdOrderCapNeed.Copy(ProdOrderCapNeed2);
              if TmpProdOrderCapNeed."Operation No." = TmpProdOrderRtngLine."Operation No." then
                TmpProdOrderCapNeed.Insert;

              SetMinDateTime(ProdEndingDate,ProdEndingTime,ProdStartingDate,ProdStartingTime);
              ProdOrderRoutingLine3 := ProdOrderRoutingLine2;
            until ProdOrderRoutingLine2.Next = 0;
          if ProdOrderRoutingLine3."Prod. Order No." <> '' then begin
            Workcenter2.Get(ProdOrderRoutingLine3."Work Center No.");
            ProdOrderRoutingLine3."Critical Path" := true;
            ProdOrderRoutingLine3.UpdateDatetime;
            ProdOrderRoutingLine3.Modify;
            if ProdOrderRoutingLine3.Type = ProdOrderRoutingLine3.Type::"Machine Center" then begin
              MachineCenter.Get(ProdOrderRoutingLine3."No.");
              Workcenter2."Queue Time" := MachineCenter."Queue Time";
              Workcenter2."Queue Time Unit of Meas. Code" :=
                MachineCenter."Queue Time Unit of Meas. Code";
            end;
            UpdateDates := false;
            RemainNeedQty :=
              ROUND(
                Workcenter2."Queue Time" *
                CalendarMgt.TimeFactor(Workcenter2."Queue Time Unit of Meas. Code") /
                CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                Workcenter2."Calendar Rounding Precision");

            LoadCapBack(ProdOrderRoutingLine2.Type,ProdOrderRoutingLine2."No.",4,false);
          end else
            ProdOrderRoutingLine3 := ProdOrderRoutingLine2;
        end else begin
          TotalLotSize := MaxLotSize;
          SendAheadLotSize := MaxLotSize;
        end;

        // In case of Parallel Routing and the last operation is finished
        if ProdEndingDate = CalendarMgt.GetMaxDate then begin
          ProdOrderRoutingLine."Ending Date" := ProdOrderLine."Ending Date";
          ProdOrderRoutingLine."Ending Time" := ProdOrderLine."Ending Time";

          ProdEndingTime := ProdOrderRoutingLine."Ending Time";
          ProdEndingDate := ProdOrderRoutingLine."Ending Date";
          ProdStartingTime := ProdOrderRoutingLine."Ending Time";
          ProdStartingDate := ProdOrderRoutingLine."Ending Date";

          TotalLotSize := MaxLotSize;
          SendAheadLotSize := MaxLotSize;
        end;

        UpdateDates := true;

        CalcMoveAndWaitBack;

        if ProdOrderRoutingLine."Schedule Manually" then // Move and wait time has been calculated
          exit;

        repeat
          LotSize := SendAheadLotSize;
          RemainNeedQty :=
            LotSize *
            ProdOrderRoutingLine.RunTimePer;
          RemainNeedQty :=
            ROUND(
              RemainNeedQty *
              CalendarMgt.TimeFactor(ProdOrderRoutingLine."Run Time Unit of Meas. Code") /
              CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
              Workcenter."Calendar Rounding Precision");

          with ProdOrderRoutingLine do begin
            ResourceIsConstrained := ConstrainedCapacity.Get(Type,"No.");
            ParentIsConstrained := ParentWorkCenter.Get(Type::"Work Center","Work Center No.");
            if not "Schedule Manually" and
               (ResourceIsConstrained or ParentIsConstrained)
            then
              FinitelyLoadCapBack(1,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained)
            else
              LoadCapBack(Type,"No.",1,true);
          end;

          ProdEndingDate := ProdOrderRoutingLine."Starting Date";
          ProdEndingTime := ProdOrderRoutingLine."Starting Time";
        until FindSendAheadStartingTime(TmpProdOrderRtngLine,TmpProdOrderCapNeed,SendAheadLotSize);

        ProdEndingDate := ProdOrderRoutingLine."Starting Date";
        ProdEndingTime := ProdOrderRoutingLine."Starting Time";
        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Setup Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Setup Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");

        with ProdOrderRoutingLine do begin
          ResourceIsConstrained := ConstrainedCapacity.Get(Type,"No.");
          ParentIsConstrained := ParentWorkCenter.Get(Type::"Work Center","Work Center No.");
          if not "Schedule Manually" and
             (ResourceIsConstrained or ParentIsConstrained)
          then
            FinitelyLoadCapBack(0,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained)
          else
            LoadCapBack(Type,"No.",0,true);

          "Starting Date" := ProdEndingDate;
          "Starting Time" := ProdEndingTime;

          if "Ending Date" = CalendarMgt.GetMaxDate then begin
            "Ending Date" := "Starting Date";
            "Ending Time" := "Starting Time";
          end;

          UpdateDatetime;
          Modify;
        end;
    end;

    local procedure GetSendAheadEndingTime(ProdOrderRoutingLine2: Record "Prod. Order Routing Line";FirstLine: Boolean;var SendAheadLotSize: Decimal): Boolean
    var
        ExpectedTime: Decimal;
        SetupTime: Decimal;
        xProdStartingDate: Date;
        xProdStartingTime: Time;
    begin
        ProdEndingTime := ProdOrderRoutingLine2."Ending Time";
        ProdEndingDate := ProdOrderRoutingLine2."Ending Date";
        SendAheadLotSize := MaxLotSize;
        if TotalLotSize = MaxLotSize then
          exit(true);

        with ProdOrderRoutingLine2 do begin
          if ("Send-Ahead Quantity" = 0) or
             ("Send-Ahead Quantity" >= MaxLotSize)
          then begin
            TotalLotSize := SendAheadLotSize;
            exit(false);
          end;
          SendAheadLotSize := "Send-Ahead Quantity";
          if MaxLotSize < (TotalLotSize + SendAheadLotSize) then begin
            SendAheadLotSize := MaxLotSize - TotalLotSize;
            TotalLotSize := MaxLotSize;
          end else
            TotalLotSize := TotalLotSize + SendAheadLotSize;

          Workcenter2.Get("Work Center No.");
          if "Lot Size" = 0 then
            "Lot Size" := 1;
          if FirstLine then begin
            ExpectedTime :=
              ROUND(
                ("Setup Time" + "Run Time" * SendAheadLotSize / "Lot Size") *
                CalendarMgt.TimeFactor("Run Time Unit of Meas. Code") /
                CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                Workcenter2."Calendar Rounding Precision");
            SetupTime := ROUND(
                "Setup Time" *
                CalendarMgt.TimeFactor("Setup Time Unit of Meas. Code") /
                CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                Workcenter2."Calendar Rounding Precision");
          end else
            ExpectedTime :=
              ROUND(
                "Run Time" * "Send-Ahead Quantity" / "Lot Size" *
                CalendarMgt.TimeFactor("Run Time Unit of Meas. Code") /
                CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                Workcenter2."Calendar Rounding Precision");
          if FirstLine then begin
            ProdOrderCapNeed2.Reset;
            ProdOrderCapNeed2.SetCurrentkey(Status,"Prod. Order No.","Routing Reference No.","Operation No.",Date,"Starting Time");
            ProdOrderCapNeed2.SetRange(Status,Status);
            ProdOrderCapNeed2.SetRange("Prod. Order No.","Prod. Order No.");
            ProdOrderCapNeed2.SetRange("Requested Only",false);
            ProdOrderCapNeed2.SetRange("Routing No.","Routing No.");
            ProdOrderCapNeed2.SetRange("Routing Reference No.","Routing Reference No.");
            ProdOrderCapNeed2.SetRange("Operation No.","Operation No.");
            if not ProdOrderCapNeed2.Find('-') then begin
              ProdEndingTime := "Starting Time";
              ProdEndingDate := "Starting Date";
              exit(false);
            end;
          end;
          repeat
            if ExpectedTime <= ProdOrderCapNeed2."Needed Time" then begin
              ProdOrderCapNeed2."Starting Time" :=
                ProdOrderCapNeed2."Starting Time" +
                ROUND(
                  ((ExpectedTime - SetupTime) *
                   CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code") /
                   ProdOrderCapNeed2."Concurrent Capacities" +
                   SetupTime * CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code")) /
                  ProdOrderCapNeed2.Efficiency * 100,1);
              ProdOrderCapNeed2."Needed Time" :=
                ProdOrderCapNeed2."Needed Time" - ExpectedTime;
              UpdateDates := false;
              xProdStartingTime := ProdStartingTime;
              xProdStartingDate := ProdStartingDate;
              ProdStartingTime := ProdOrderCapNeed2."Starting Time";
              ProdStartingDate := ProdOrderCapNeed2.Date;
              RemainNeedQty :=
                ROUND(
                  "Wait Time" *
                  CalendarMgt.TimeFactor("Wait Time Unit of Meas. Code") /
                  CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                  Workcenter2."Calendar Rounding Precision");
              LoadCapForward(Type,"No.",2,false);

              RemainNeedQty :=
                ROUND(
                  "Move Time" *
                  CalendarMgt.TimeFactor("Move Time Unit of Meas. Code") /
                  CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                  Workcenter2."Calendar Rounding Precision");
              LoadCapForward(Type,"No.",3,false);

              ProdEndingTime := ProdStartingTime;
              ProdEndingDate := ProdStartingDate;
              ProdStartingTime := xProdStartingTime;
              ProdStartingDate := xProdStartingDate;
              exit(false);
            end else
              ExpectedTime := ExpectedTime - ProdOrderCapNeed2."Needed Time";

          until ProdOrderCapNeed2.Next = 0;
        end;
        exit(false);
    end;

    local procedure CalcRoutingLineForward(CalculateStartDate: Boolean)
    var
        ProdOrderRoutingLine2: Record "Prod. Order Routing Line";
        ProdOrderRoutingLine3: Record "Prod. Order Routing Line";
        ConstrainedCapacity: Record "Capacity Constrained Resource";
        ParentWorkCenter: Record "Capacity Constrained Resource";
        TmpProdOrderRtngLine: Record "Prod. Order Routing Line" temporary;
        TmpProdOrderCapNeed: Record "Prod. Order Capacity Need" temporary;
        SendAheadLotSize: Decimal;
        InputQtyDiffTime: Decimal;
        ParentIsConstrained: Boolean;
        ResourceIsConstrained: Boolean;
    begin
        CalendarEntry.SetRange(Date,ProdOrderRoutingLine."Starting Date",Dmy2date(31,12,9999));

        ProdStartingTime := ProdOrderRoutingLine."Starting Time";
        ProdStartingDate := ProdOrderRoutingLine."Starting Date";
        ProdEndingTime := ProdOrderRoutingLine."Starting Time";
        ProdEndingDate := ProdOrderRoutingLine."Starting Date";

        InputQtyDiffTime := 0;

        FirstEntry := true;

        if (ProdOrderRoutingLine."Previous Operation No." <> '') and
           CalculateStartDate
        then begin
          Clear(ProdOrderRoutingLine3);

          TmpProdOrderRtngLine.Reset;
          TmpProdOrderRtngLine.DeleteAll;
          TmpProdOrderCapNeed.Reset;
          TmpProdOrderCapNeed.DeleteAll;

          SetRoutingLineFilters(ProdOrderRoutingLine,ProdOrderRoutingLine2);
          ProdOrderRoutingLine2.SetFilter("Operation No.",ProdOrderRoutingLine."Previous Operation No.");
          if ProdOrderRoutingLine2.Find('-') then
            repeat
              TotalLotSize := 0;
              GetSendAheadEndingTime(ProdOrderRoutingLine2,true,SendAheadLotSize);

              TmpProdOrderRtngLine.Copy(ProdOrderRoutingLine2);
              TmpProdOrderRtngLine.Insert;
              TmpProdOrderCapNeed.Copy(ProdOrderCapNeed2);
              if TmpProdOrderRtngLine."Operation No." = TmpProdOrderCapNeed."Operation No." then
                TmpProdOrderCapNeed.Insert;

              SetMaxDateTime(ProdStartingDate,ProdStartingTime,ProdEndingDate,ProdEndingTime);
              ProdOrderRoutingLine3 := ProdOrderRoutingLine2;

              if (ProdOrderRoutingLine2."Send-Ahead Quantity" > 0) and
                 (ProdOrderRoutingLine2."Input Quantity" > ProdOrderRoutingLine."Input Quantity")
              then begin
                Workcenter2.Get(ProdOrderRoutingLine2."Work Center No.");
                InputQtyDiffTime :=
                  (ProdOrderRoutingLine2."Input Quantity" - ProdOrderRoutingLine."Input Quantity") *
                  ProdOrderRoutingLine2.RunTimePer;
                InputQtyDiffTime :=
                  ROUND(
                    InputQtyDiffTime *
                    CalendarMgt.TimeFactor(ProdOrderRoutingLine2."Run Time Unit of Meas. Code") /
                    CalendarMgt.TimeFactor(Workcenter2."Unit of Measure Code"),
                    Workcenter2."Calendar Rounding Precision");
              end;
            until ProdOrderRoutingLine2.Next = 0
          else
            // parallel routing with finished first operation
            if ProdStartingDate = 0D then begin
              ProdOrderRoutingLine2.Get(ProdOrderRoutingLine.Status,
                ProdOrderRoutingLine."Prod. Order No.",ProdOrderRoutingLine."Routing Reference No.",
                ProdOrderRoutingLine."Routing No.",ProdOrderRoutingLine."Operation No.");
              ProdStartingDate := ProdOrderRoutingLine2."Starting Date";
              ProdStartingTime := ProdOrderRoutingLine2."Starting Time";
            end;
          if ProdOrderRoutingLine3."Prod. Order No." <> '' then begin
            ProdOrderRoutingLine3."Critical Path" := true;
            ProdOrderRoutingLine3.UpdateDatetime;
            ProdOrderRoutingLine3.Modify;
          end;
        end else begin
          TotalLotSize := MaxLotSize;
          SendAheadLotSize := MaxLotSize;
        end;
        RemainNeedQty :=
          ROUND(
            Workcenter."Queue Time" *
            CalendarMgt.TimeFactor(Workcenter."Queue Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        RemainNeedQty += InputQtyDiffTime;
        LoadCapForward(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.",4,false);
        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Setup Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Setup Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        UpdateDates := true;

        with ProdOrderRoutingLine do begin
          ResourceIsConstrained := ConstrainedCapacity.Get(Type,"No.");
          ParentIsConstrained := ParentWorkCenter.Get(Type::"Work Center","Work Center No.");
          if not "Schedule Manually" and
             (RemainNeedQty > 0) and (ResourceIsConstrained or ParentIsConstrained)
          then
            FinitelyLoadCapForward(0,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained)
          else
            LoadCapForward(Type,"No.",0,true);
        end;

        FirstInBatch := true;
        repeat
          if (InputQtyDiffTime > 0) and (TotalLotSize = MaxLotSize) then
            SetMaxDateTime(
              ProdStartingDate,ProdStartingTime,ProdOrderRoutingLine2."Ending Date",ProdOrderRoutingLine2."Ending Time");

          LotSize := SendAheadLotSize;
          RemainNeedQty := LotSize * ProdOrderRoutingLine.RunTimePer;
          RemainNeedQty :=
            ROUND(
              RemainNeedQty *
              CalendarMgt.TimeFactor(ProdOrderRoutingLine."Run Time Unit of Meas. Code") /
              CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
              Workcenter."Calendar Rounding Precision");

          with ProdOrderRoutingLine do begin
            ResourceIsConstrained := ConstrainedCapacity.Get(Type,"No.");
            ParentIsConstrained := ParentWorkCenter.Get(Type::"Work Center","Work Center No.");
            if not "Schedule Manually" and
               (RemainNeedQty > 0) and (ResourceIsConstrained or ParentIsConstrained)
            then
              FinitelyLoadCapForward(1,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained)
            else
              LoadCapForward(Type,"No.",1,true);
          end;

          ProdStartingDate := ProdOrderRoutingLine."Ending Date";
          ProdStartingTime := ProdOrderRoutingLine."Ending Time";
        until FindSendAheadEndingTime(TmpProdOrderRtngLine,TmpProdOrderCapNeed,SendAheadLotSize);

        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Wait Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Wait Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        LoadCapForward(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.",2,false);
        RemainNeedQty :=
          ROUND(
            ProdOrderRoutingLine."Move Time" *
            CalendarMgt.TimeFactor(ProdOrderRoutingLine."Move Time Unit of Meas. Code") /
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        LoadCapForward(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.",3,false);

        with ProdOrderRoutingLine do begin
          if "Starting Date" = 0D then begin
            "Starting Date" := "Ending Date";
            "Starting Time" := "Ending Time";
          end;

          UpdateDatetime;
          Modify;
        end;
    end;

    local procedure CalculateRoutingLineFixed()
    var
        FixedProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        FixedProdOrderRoutingLine := ProdOrderRoutingLine;
        if FixedProdOrderRoutingLine."Starting Date-Time" > FixedProdOrderRoutingLine."Ending Date-Time" then
          Error(Text007);

        // Calculate wait and move time, find end of runtime
        CalcRoutingLineBack(true);
        RunEndingDateTime :=
          CreateDatetime(ProdOrderRoutingLine."Starting Date",ProdOrderRoutingLine."Starting Time");

        // Find start of runtime
        ProdOrderRoutingLine := FixedProdOrderRoutingLine;
        CalcRoutingLineForward(true);

        ProdOrderRoutingLine."Starting Time" := FixedProdOrderRoutingLine."Starting Time";
        ProdOrderRoutingLine."Starting Date" := FixedProdOrderRoutingLine."Starting Date";
        ProdOrderRoutingLine."Ending Time" := FixedProdOrderRoutingLine."Ending Time";
        ProdOrderRoutingLine."Ending Date" := FixedProdOrderRoutingLine."Ending Date";
        ProdOrderRoutingLine.UpdateDatetime;
        ProdOrderRoutingLine.Modify;
    end;

    procedure CalculateRoutingLine(var ProdOrderRoutingLine2: Record "Prod. Order Routing Line";Direction: Option Forward,Backward;CalcStartEndDate: Boolean)
    var
        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
        CostCalcMgt: Codeunit "Cost Calculation Management";
        ExpectedOperOutput: Decimal;
        ActualOperOutput: Decimal;
        TotalQtyPerOperation: Decimal;
        TotalCapacityPerOperation: Decimal;
        ConCurrCapacity: Decimal;
    begin
        MfgSetup.Get;

        ProdOrderRoutingLine := ProdOrderRoutingLine2;

        WaitTimeOnly :=
          (ProdOrderRoutingLine."Setup Time" = 0) and (ProdOrderRoutingLine."Run Time" = 0) and
          (ProdOrderRoutingLine."Move Time" = 0);

        if ProdOrderRoutingLine."Ending Time" = 0T then
          ProdOrderRoutingLine."Ending Time" := 000000T;

        if ProdOrderRoutingLine."Starting Time" = 0T then
          ProdOrderRoutingLine."Starting Time" := 000000T;

        ProdOrderRoutingLine."Expected Operation Cost Amt." := 0;
        ProdOrderRoutingLine."Expected Capacity Ovhd. Cost" := 0;
        ProdOrderRoutingLine."Expected Capacity Need" := 0;

        ProdOrderCapNeed.Reset;
        ProdOrderCapNeed.SetRange(Status,ProdOrderRoutingLine.Status);
        ProdOrderCapNeed.SetRange("Prod. Order No.",ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderCapNeed.SetRange("Requested Only",false);
        ProdOrderCapNeed.SetRange("Routing No.",ProdOrderRoutingLine."Routing No.");
        ProdOrderCapNeed.SetRange("Routing Reference No.",ProdOrderRoutingLine."Routing Reference No.");
        ProdOrderCapNeed.SetRange("Operation No.",ProdOrderRoutingLine."Operation No.");
        ProdOrderCapNeed.DeleteAll;

        NextCapNeedLineNo := 1;

        ProdOrderRoutingLine.TestField("Work Center No.");

        CurrentWorkCenterNo := '';
        Workcenter.Get(ProdOrderRoutingLine."Work Center No.");
        if ProdOrderRoutingLine.Type = ProdOrderRoutingLine.Type::"Machine Center" then begin
          MachineCenter.Get(ProdOrderRoutingLine."No.");
          Workcenter."Queue Time" := MachineCenter."Queue Time";
          Workcenter."Queue Time Unit of Meas. Code" := MachineCenter."Queue Time Unit of Meas. Code";
        end;
        if not CalcStartEndDate then
          Clear(Workcenter."Queue Time");
        ProdOrder.Get(ProdOrderRoutingLine.Status,ProdOrderRoutingLine."Prod. Order No.");

        ProdOrderQty := 0;
        TotalScrap := 0;
        TotalLotSize := 0;
        ProdOrderLine.SetRange(Status,ProdOrderRoutingLine.Status);
        ProdOrderLine.SetRange("Prod. Order No.",ProdOrderRoutingLine."Prod. Order No.");
        ProdOrderLine.SetRange("Routing Reference No.",ProdOrderRoutingLine."Routing Reference No.");
        ProdOrderLine.SetRange("Routing No.",ProdOrderRoutingLine."Routing No.");
        if ProdOrderLine.Find('-') then begin
          ExpectedOperOutput := 0;
          repeat
            ExpectedOperOutput := ExpectedOperOutput + ProdOrderLine."Quantity (Base)";
            TotalScrap := TotalScrap + ProdOrderLine."Scrap %";
          until ProdOrderLine.Next = 0;
          ActualOperOutput := CostCalcMgt.CalcActOutputQtyBase(ProdOrderLine,ProdOrderRoutingLine);
          ProdOrderQty := ExpectedOperOutput - ActualOperOutput;
          if ProdOrderQty < 0 then
            ProdOrderQty := 0;
        end;

        MaxLotSize :=
          ProdOrderQty *
          (1 + ProdOrderRoutingLine."Scrap Factor % (Accumulated)") *
          (1 + TotalScrap / 100) +
          ProdOrderRoutingLine."Fixed Scrap Qty. (Accum.)";

        ProdOrderRoutingLine."Input Quantity" := MaxLotSize;

        if ActualOperOutput > 0 then begin
          TotalQtyPerOperation :=
            ExpectedOperOutput *
            (1 + ProdOrderRoutingLine."Scrap Factor % (Accumulated)") *
            (1 + TotalScrap / 100) +
            ProdOrderRoutingLine."Fixed Scrap Qty. (Accum.)";
        end else
          TotalQtyPerOperation := MaxLotSize;

        TotalCapacityPerOperation :=
          ROUND(
            TotalQtyPerOperation *
            ProdOrderRoutingLine.RunTimePer *
            CalendarMgt.QtyperTimeUnitofMeasure(
              ProdOrderRoutingLine."Work Center No.",ProdOrderRoutingLine."Run Time Unit of Meas. Code"),
            0.00001);
        if MfgSetup."Cost Incl. Setup" then begin
          ConCurrCapacity := ProdOrderRoutingLine."Concurrent Capacities";
          if ConCurrCapacity = 0 then
            ConCurrCapacity := 1;
          TotalCapacityPerOperation :=
            TotalCapacityPerOperation +
            ROUND(
              ConCurrCapacity * ProdOrderRoutingLine."Setup Time" *
              CalendarMgt.QtyperTimeUnitofMeasure(
                ProdOrderRoutingLine."Work Center No.",ProdOrderRoutingLine."Setup Time Unit of Meas. Code"),
              0.00001);
        end;
        CalcExpectedCost(ProdOrderRoutingLine,TotalQtyPerOperation,TotalCapacityPerOperation);

        if ProdOrderRoutingLine."Schedule Manually" then
          CalculateRoutingLineFixed
        else begin
          if Direction = Direction::Backward then
            CalcRoutingLineBack(CalcStartEndDate)
          else
            CalcRoutingLineForward(CalcStartEndDate);
        end;

        OnAfterCalculateRoutingLine(ProdOrderRoutingLine);

        ProdOrderRoutingLine2 := ProdOrderRoutingLine;
    end;

    local procedure FinitelyLoadCapBack(TimeType: Option "Setup Time","Run Time";ConstrainedCapacity: Record "Capacity Constrained Resource";ResourceIsConstrained: Boolean;ParentWorkCenter: Record "Capacity Constrained Resource";ParentIsConstrained: Boolean)
    var
        LastProdOrderCapNeed: Record "Prod. Order Capacity Need";
        AvailTime: Decimal;
        ProdEndingDateTime: DateTime;
        ProdEndingDateTimeAddOneDay: DateTime;
        SetupTime: Decimal;
        TimetoProgram: Decimal;
        AvailCap: Decimal;
        DampTime: Decimal;
        xConCurrCap: Decimal;
        EndTime: Time;
        StartTime: Time;
    begin
        if (RemainNeedQty = 0) and WaitTimeOnly then
          exit;
        EndTime := ProdEndingTime;
        ProdEndingDateTime := CreateDatetime(ProdEndingDate,ProdEndingTime);
        ProdEndingDateTimeAddOneDay := CreateDatetime(ProdEndingDate + 1,ProdEndingTime);
        ConCurrCap := ProdOrderRoutingLine."Concurrent Capacities";
        xConCurrCap := 1;

        LastProdOrderCapNeed.SetFilters(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.");

        CalendarEntry.SetCapacityFilters(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.");
        CalendarEntry.SetFilter("Starting Date-Time",'<= %1',ProdEndingDateTime);
        CalendarEntry.SetFilter("Ending Date-Time",'<= %1',ProdEndingDateTimeAddOneDay);
        if CalendarEntry.Find('+') then
          repeat
            if (EndTime > CalendarEntry."Ending Time") or (EndTime < CalendarEntry."Starting Time") or
               (ProdEndingDate <> CalendarEntry.Date)
            then
              EndTime := CalendarEntry."Ending Time";
            StartTime := EndTime;

            if (ConCurrCap = 0) or (CalendarEntry.Capacity < ConCurrCap) then
              ConCurrCap := CalendarEntry.Capacity;
            if TimeType <> Timetype::"Run Time" then
              RemainNeedQty := RemainNeedQty * ConCurrCap / xConCurrCap;
            xConCurrCap := ConCurrCap;

            CalculateDailyLoad(AvailCap,DampTime,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained);
            SetupTime := 0;
            if TimeType = Timetype::"Run Time" then begin
              SetupTime :=
                ROUND(
                  ProdOrderRoutingLine."Setup Time" *
                  CalendarMgt.TimeFactor(ProdOrderRoutingLine."Setup Time Unit of Meas. Code") /
                  CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
                  Workcenter."Calendar Rounding Precision");
              SetupTime := SetupTime * ConCurrCap;
            end;
            if RemainNeedQty + SetupTime <= AvailCap + DampTime then
              AvailCap := AvailCap + DampTime;
            AvailCap :=
              ROUND(AvailCap *
                CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
                100 / CalendarEntry.Efficiency / ConCurrCap,1,'>');

            if AvailCap > 0 then begin
              ProdEndingDateTime := CreateDatetime(CalendarEntry.Date,EndTime);
              LastProdOrderCapNeed.SetFilter(
                "Ending Date-Time",'>= %1 & < %2',CalendarEntry."Starting Date-Time",ProdEndingDateTimeAddOneDay);
              LastProdOrderCapNeed.SetFilter(
                "Starting Date-Time",'>= %1 & < %2',CalendarEntry."Starting Date-Time",ProdEndingDateTime);
              if LastProdOrderCapNeed.Find('+') then
                repeat
                  if LastProdOrderCapNeed."Ending Time" < EndTime then begin
                    AvailTime := Min(CalendarMgt.CalcTimeDelta(EndTime,LastProdOrderCapNeed."Ending Time"),AvailCap);
                    if AvailTime > 0 then begin
                      UpdateTimesBack(AvailTime,AvailCap,TimetoProgram,StartTime,EndTime);
                      CreateCapNeed(CalendarEntry.Date,StartTime,EndTime,TimetoProgram,TimeType,1);
                      if FirstInBatch and FirstEntry then begin
                        FirstInBatch := false;
                        FirstEntry := false
                      end;
                      if UpdateDates then begin
                        ProdOrderRoutingLine."Ending Time" := EndTime;
                        ProdOrderRoutingLine."Ending Date" := CalendarEntry.Date;
                        UpdateDates := false
                      end;
                      EndTime := StartTime;
                    end;
                  end;
                  if LastProdOrderCapNeed."Starting Time" < EndTime then
                    EndTime := LastProdOrderCapNeed."Starting Time";
                until (LastProdOrderCapNeed.Next(-1) = 0) or (RemainNeedQty = 0) or (AvailCap = 0);

              if (AvailCap > 0) and (RemainNeedQty > 0) then begin
                AvailTime := Min(CalendarMgt.CalcTimeDelta(EndTime,CalendarEntry."Starting Time"),AvailCap);
                if AvailTime > 0 then begin
                  UpdateTimesBack(AvailTime,AvailCap,TimetoProgram,StartTime,EndTime);
                  if StartTime < CalendarEntry."Starting Time" then
                    StartTime := CalendarEntry."Starting Time";
                  if TimetoProgram <> 0 then
                    CreateCapNeed(CalendarEntry.Date,StartTime,EndTime,TimetoProgram,TimeType,1);
                  if FirstInBatch and FirstEntry then begin
                    FirstInBatch := false;
                    FirstEntry := false
                  end;
                  if UpdateDates then begin
                    ProdOrderRoutingLine."Ending Time" := EndTime;
                    ProdOrderRoutingLine."Ending Date" := CalendarEntry.Date;
                    UpdateDates := false
                  end;
                  EndTime := StartTime;
                end;
              end;
            end;
            if RemainNeedQty > 0 then begin
              if CalendarEntry.Next(-1) = 0 then begin
                TestForError(Text001,Text002,CalendarEntry.Date);
                exit;
              end;
              EndTime := CalendarEntry."Ending Time";
            end else begin
              ProdEndingTime := StartTime;
              ProdEndingDate := CalendarEntry.Date;
              ProdOrderRoutingLine."Starting Time" := StartTime;
              ProdOrderRoutingLine."Starting Date" := CalendarEntry.Date;
              exit;
            end;
          until false;
    end;

    local procedure FinitelyLoadCapForward(TimeType: Option "Setup Time","Run Time";ConstrainedCapacity: Record "Capacity Constrained Resource";ResourceIsConstrained: Boolean;ParentWorkCenter: Record "Capacity Constrained Resource";ParentIsConstrained: Boolean)
    var
        NextProdOrderCapNeed: Record "Prod. Order Capacity Need";
        AvailTime: Decimal;
        ProdStartingDateTime: DateTime;
        ProdStartingDateTimeSubOneDay: DateTime;
        RunTime: Decimal;
        TimetoProgram: Decimal;
        AvailCap: Decimal;
        DampTime: Decimal;
        xConCurrCap: Decimal;
        EndTime: Time;
        StartTime: Time;
    begin
        if (RemainNeedQty = 0) and WaitTimeOnly then
          exit;
        StartTime := ProdStartingTime;
        ProdStartingDateTime := CreateDatetime(ProdStartingDate,ProdStartingTime);
        ProdStartingDateTimeSubOneDay := CreateDatetime(ProdStartingDate - 1,ProdStartingTime);
        ConCurrCap := ProdOrderRoutingLine."Concurrent Capacities";
        xConCurrCap := 1;

        NextProdOrderCapNeed.SetFilters(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.");

        CalendarEntry.SetCapacityFilters(ProdOrderRoutingLine.Type,ProdOrderRoutingLine."No.");
        CalendarEntry.SetFilter("Starting Date-Time",'>= %1',ProdStartingDateTimeSubOneDay);
        CalendarEntry.SetFilter("Ending Date-Time",'>= %1',ProdStartingDateTime);
        if CalendarEntry.Find('-') then
          repeat
            if (StartTime < CalendarEntry."Starting Time") or (StartTime > CalendarEntry."Ending Time") or
               (ProdStartingDate <> CalendarEntry.Date)
            then
              StartTime := CalendarEntry."Starting Time";
            EndTime := StartTime;

            if (ConCurrCap = 0) or (CalendarEntry.Capacity < ConCurrCap) then
              ConCurrCap := CalendarEntry.Capacity;
            if TimeType <> Timetype::"Run Time" then
              RemainNeedQty := RemainNeedQty * ConCurrCap / xConCurrCap;
            xConCurrCap := ConCurrCap;

            CalculateDailyLoad(AvailCap,DampTime,ConstrainedCapacity,ResourceIsConstrained,ParentWorkCenter,ParentIsConstrained);
            RunTime := 0;
            if TimeType = Timetype::"Setup Time" then begin
              RunTime := LotSize * ProdOrderRoutingLine.RunTimePer;
              RunTime :=
                ROUND(RunTime *
                  CalendarMgt.TimeFactor(ProdOrderRoutingLine."Run Time Unit of Meas. Code") /
                  CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
                  Workcenter."Calendar Rounding Precision");
            end;
            if RemainNeedQty + RunTime <= AvailCap + DampTime then
              AvailCap := AvailCap + DampTime;
            AvailCap :=
              ROUND(AvailCap *
                CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
                100 / CalendarEntry.Efficiency / ConCurrCap,1,'>');

            if AvailCap > 0 then begin
              ProdStartingDateTime := CreateDatetime(CalendarEntry.Date,StartTime);
              NextProdOrderCapNeed.SetFilter(
                "Ending Date-Time",'> %1 & <= %2',ProdStartingDateTime,CalendarEntry."Ending Date-Time");
              NextProdOrderCapNeed.SetFilter(
                "Starting Date-Time",'> %1 & <= %2',ProdStartingDateTimeSubOneDay,CalendarEntry."Ending Date-Time");
              if NextProdOrderCapNeed.Find('-') then
                repeat
                  if NextProdOrderCapNeed."Starting Time" > StartTime then begin
                    AvailTime := Min(CalendarMgt.CalcTimeDelta(NextProdOrderCapNeed."Starting Time",StartTime),AvailCap);
                    if AvailTime > 0 then begin
                      UpdateTimesForward(AvailTime,AvailCap,TimetoProgram,StartTime,EndTime);
                      CreateCapNeed(CalendarEntry.Date,StartTime,EndTime,TimetoProgram,TimeType,0);
                      if FirstInBatch and FirstEntry then begin
                        FirstInBatch := false;
                        FirstEntry := false
                      end;
                      if UpdateDates then begin
                        ProdOrderRoutingLine."Starting Time" := StartTime;
                        ProdOrderRoutingLine."Starting Date" := CalendarEntry.Date;
                        UpdateDates := false
                      end;
                      StartTime := EndTime;
                    end;
                  end;
                  if NextProdOrderCapNeed."Ending Time" > StartTime then
                    StartTime := NextProdOrderCapNeed."Ending Time"
                until (NextProdOrderCapNeed.Next = 0) or (RemainNeedQty = 0) or (AvailCap = 0);

              if (AvailCap > 0) and (RemainNeedQty > 0) then begin
                AvailTime := Min(CalendarMgt.CalcTimeDelta(CalendarEntry."Ending Time",StartTime),AvailCap);
                if AvailTime > 0 then begin
                  UpdateTimesForward(AvailTime,AvailCap,TimetoProgram,StartTime,EndTime);
                  if EndTime > CalendarEntry."Ending Time" then
                    EndTime := CalendarEntry."Ending Time";
                  if TimetoProgram <> 0 then
                    CreateCapNeed(CalendarEntry.Date,StartTime,EndTime,TimetoProgram,TimeType,0);
                  if FirstInBatch and FirstEntry then begin
                    FirstInBatch := false;
                    FirstEntry := false
                  end;
                  if UpdateDates then begin
                    ProdOrderRoutingLine."Starting Time" := StartTime;
                    ProdOrderRoutingLine."Starting Date" := CalendarEntry.Date;
                    UpdateDates := false
                  end;
                  StartTime := EndTime;
                end;
              end;
            end;
            if RemainNeedQty > 0 then begin
              if CalendarEntry.Next = 0 then begin
                TestForError(Text003,Text004,CalendarEntry.Date);
                exit;
              end;
              StartTime := CalendarEntry."Starting Time";
            end else begin
              ProdStartingTime := EndTime;
              ProdStartingDate := CalendarEntry.Date;
              ProdOrderRoutingLine."Ending Time" := EndTime;
              ProdOrderRoutingLine."Ending Date" := CalendarEntry.Date;
              exit;
            end;
          until false;
    end;

    local procedure CalculateDailyLoad(var AvailCap: Decimal;var DampTime: Decimal;ConstrainedCapacity: Record "Capacity Constrained Resource";IsResourceConstrained: Boolean;ParentWorkCenter: Record "Capacity Constrained Resource";IsParentConstrained: Boolean)
    var
        CurrentLoadBase: Decimal;
        AvailCapWorkCenter: Decimal;
        DampTimeWorkCenter: Decimal;
        CapEffectiveBase: Decimal;
    begin
        GetCurrentWorkCenterTimeFactorAndRounding(Workcenter."No.");
        if (CalendarEntry."Capacity Type" = CalendarEntry."capacity type"::"Work Center") or
           ((CalendarEntry."Capacity Type" = CalendarEntry."capacity type"::"Machine Center") and
            (IsResourceConstrained xor IsParentConstrained))
        then begin
          with ConstrainedCapacity do begin
            if IsParentConstrained then begin
              ConstrainedCapacity := ParentWorkCenter;
              CalcCapConResWorkCenterLoadBase(ConstrainedCapacity,CalendarEntry.Date,CapEffectiveBase,CurrentLoadBase)
            end else
              CalcCapConResProdOrderNeedBase(ConstrainedCapacity,CalendarEntry.Date,CapEffectiveBase,CurrentLoadBase);
            CalcAvailCapBaseAndDampTime(
              ConstrainedCapacity,AvailCap,DampTime,CapEffectiveBase,CurrentLoadBase,CurrentTimeFactor,CurrentRounding);
          end;
        end else begin
          CalcCapConResProdOrderNeedBase(ConstrainedCapacity,CalendarEntry.Date,CapEffectiveBase,CurrentLoadBase);
          CalcAvailCapBaseAndDampTime(
            ConstrainedCapacity,AvailCap,DampTime,CapEffectiveBase,CurrentLoadBase,CurrentTimeFactor,CurrentRounding);

          CalcCapConResWorkCenterLoadBase(ParentWorkCenter,CalendarEntry.Date,CapEffectiveBase,CurrentLoadBase);
          CalcAvailCapBaseAndDampTime(
            ParentWorkCenter,AvailCapWorkCenter,DampTimeWorkCenter,CapEffectiveBase,CurrentLoadBase,CurrentTimeFactor,CurrentRounding);

          if AvailCap + DampTime > AvailCapWorkCenter + DampTimeWorkCenter then
            DampTime := DampTimeWorkCenter
          else
            if AvailCap + DampTime = AvailCapWorkCenter + DampTimeWorkCenter then
              DampTime := Max(DampTime,DampTimeWorkCenter);
          AvailCap := ROUND(Min(AvailCap,AvailCapWorkCenter),1);
        end;
    end;

    local procedure UpdateTimesBack(var AvailTime: Decimal;var AvailCap: Decimal;var TimetoProgram: Decimal;var StartTime: Time;EndTime: Time)
    var
        RoundedTimetoProgram: Decimal;
    begin
        AvailTime :=
          ROUND(AvailTime / CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
            CalendarEntry.Efficiency / 100 * ConCurrCap,Workcenter."Calendar Rounding Precision");
        TimetoProgram := Min(RemainNeedQty,AvailTime);
        RoundedTimetoProgram :=
          ROUND(TimetoProgram *
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
            100 / CalendarEntry.Efficiency / ConCurrCap,1,'>');
        StartTime := CalendarMgt.CalcTimeSubtract(EndTime,RoundedTimetoProgram);
        RemainNeedQty := RemainNeedQty - TimetoProgram;
        if ProdOrderRoutingLine.Status <> ProdOrderRoutingLine.Status::Simulated then
          AvailCap := AvailCap - RoundedTimetoProgram;
    end;

    local procedure UpdateTimesForward(var AvailTime: Decimal;var AvailCap: Decimal;var TimetoProgram: Decimal;StartTime: Time;var EndTime: Time)
    var
        RoundedTimetoProgram: Decimal;
    begin
        AvailTime :=
          ROUND(AvailTime / CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
            CalendarEntry.Efficiency / 100 * ConCurrCap,Workcenter."Calendar Rounding Precision");
        TimetoProgram := Min(RemainNeedQty,AvailTime);
        RoundedTimetoProgram :=
          ROUND(TimetoProgram *
            CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code") *
            100 / CalendarEntry.Efficiency / ConCurrCap,1,'>');
        EndTime := StartTime + RoundedTimetoProgram;
        RemainNeedQty := RemainNeedQty - TimetoProgram;
        if ProdOrderRoutingLine.Status <> ProdOrderRoutingLine.Status::Simulated then
          AvailCap := AvailCap - RoundedTimetoProgram;
    end;

    local procedure "Min"(Number1: Decimal;Number2: Decimal): Decimal
    begin
        if Number1 <= Number2 then
          exit(Number1);

        exit(Number2);
    end;

    local procedure "Max"(Number1: Decimal;Number2: Decimal): Decimal
    begin
        if Number1 >= Number2 then
          exit(Number1);

        exit(Number2);
    end;

    local procedure CalcExpectedCost(var ProdOrderRoutingLine: Record "Prod. Order Routing Line";TotalQtyPerOperation: Decimal;TotalCapacityPerOperation: Decimal)
    begin
        if ProdOrderRoutingLine."Unit Cost Calculation" = ProdOrderRoutingLine."unit cost calculation"::Time then begin
          ProdOrderRoutingLine."Expected Operation Cost Amt." :=
            TotalCapacityPerOperation * ProdOrderRoutingLine."Unit Cost per";
          ProdOrderRoutingLine."Expected Capacity Ovhd. Cost" :=
            TotalCapacityPerOperation *
            (ProdOrderRoutingLine."Direct Unit Cost" *
             ProdOrderRoutingLine."Indirect Cost %" / 100 + ProdOrderRoutingLine."Overhead Rate");
        end else begin
          ProdOrderRoutingLine."Expected Operation Cost Amt." :=
            TotalQtyPerOperation * ProdOrderRoutingLine."Unit Cost per";
          ProdOrderRoutingLine."Expected Capacity Ovhd. Cost" :=
            TotalQtyPerOperation *
            (ProdOrderRoutingLine."Direct Unit Cost" *
             ProdOrderRoutingLine."Indirect Cost %" / 100 + ProdOrderRoutingLine."Overhead Rate");
        end;
    end;

    local procedure CalcDuration(DateTime1: DateTime;DateTime2: DateTime) TotalDuration: Decimal
    begin
        TotalDuration :=
          ROUND(
            (Dt2Date(DateTime2) - Dt2Date(DateTime1)) * (86400000 / CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code")) +
            (Dt2Time(DateTime2) - Dt2Time(DateTime1)) / CalendarMgt.TimeFactor(Workcenter."Unit of Measure Code"),
            Workcenter."Calendar Rounding Precision");
        exit(TotalDuration);
    end;

    local procedure FindSendAheadEndingTime(var TmpProdOrderRtngLine: Record "Prod. Order Routing Line";var TmpProdOrderCapNeed: Record "Prod. Order Capacity Need";var SendAheadLotSize: Decimal): Boolean
    var
        Result: Boolean;
        xTotalLotSize: Decimal;
        xSendAheadLotSize: Decimal;
        FirstLine: Boolean;
    begin
        xTotalLotSize := TotalLotSize;
        xSendAheadLotSize := SendAheadLotSize;
        if TmpProdOrderRtngLine.FindSet then begin
          repeat
            FirstLine := true;
            TotalLotSize := xTotalLotSize;
            SendAheadLotSize := xSendAheadLotSize;
            TmpProdOrderCapNeed.Reset;
            TmpProdOrderCapNeed.SetCurrentkey(Status,"Prod. Order No.","Routing Reference No.","Operation No.",Date,"Starting Time");
            TmpProdOrderCapNeed.SetRange(Status,TmpProdOrderRtngLine.Status);
            TmpProdOrderCapNeed.SetRange("Prod. Order No.",TmpProdOrderRtngLine."Prod. Order No.");
            TmpProdOrderCapNeed.SetRange("Requested Only",false);
            TmpProdOrderCapNeed.SetRange("Routing No.",TmpProdOrderRtngLine."Routing No.");
            TmpProdOrderCapNeed.SetRange("Routing Reference No.",TmpProdOrderRtngLine."Routing Reference No.");
            TmpProdOrderCapNeed.SetRange("Operation No.",TmpProdOrderRtngLine."Operation No.");
            if TmpProdOrderCapNeed.FindFirst then begin
              ProdOrderCapNeed2.Copy(TmpProdOrderCapNeed);
              TmpProdOrderCapNeed.Delete;
              FirstLine := false;
            end;

            Result := Result or GetSendAheadEndingTime(TmpProdOrderRtngLine,FirstLine,SendAheadLotSize);
            TmpProdOrderCapNeed := ProdOrderCapNeed2;
            if TmpProdOrderRtngLine."Operation No." = TmpProdOrderCapNeed."Operation No." then
              TmpProdOrderCapNeed.Insert;
          until TmpProdOrderRtngLine.Next = 0;
        end else
          Result := GetSendAheadEndingTime(TmpProdOrderRtngLine,false,SendAheadLotSize);

        exit(Result);
    end;

    local procedure FindSendAheadStartingTime(var TmpProdOrderRtngLine: Record "Prod. Order Routing Line";var TmpProdOrderCapNeed: Record "Prod. Order Capacity Need";var SendAheadLotSize: Decimal): Boolean
    var
        Result: Boolean;
        xTotalLotSize: Decimal;
        xSendAheadLotSize: Decimal;
        FirstLine: Boolean;
    begin
        xTotalLotSize := TotalLotSize;
        xSendAheadLotSize := SendAheadLotSize;
        if TmpProdOrderRtngLine.FindSet then begin
          repeat
            FirstLine := true;
            TotalLotSize := xTotalLotSize;
            SendAheadLotSize := xSendAheadLotSize;
            TmpProdOrderCapNeed.Reset;
            TmpProdOrderCapNeed.SetCurrentkey(Status,"Prod. Order No.","Routing Reference No.","Operation No.",Date,"Starting Time");
            TmpProdOrderCapNeed.SetRange(Status,TmpProdOrderRtngLine.Status);
            TmpProdOrderCapNeed.SetRange("Prod. Order No.",TmpProdOrderRtngLine."Prod. Order No.");
            TmpProdOrderCapNeed.SetRange("Requested Only",false);
            TmpProdOrderCapNeed.SetRange("Routing No.",TmpProdOrderRtngLine."Routing No.");
            TmpProdOrderCapNeed.SetRange("Routing Reference No.",TmpProdOrderRtngLine."Routing Reference No.");
            TmpProdOrderCapNeed.SetRange("Operation No.",TmpProdOrderRtngLine."Operation No.");
            if TmpProdOrderCapNeed.FindFirst then begin
              ProdOrderCapNeed2.Copy(TmpProdOrderCapNeed);
              TmpProdOrderCapNeed.Delete;
              FirstLine := false;
            end;

            Result := Result or GetSendAheadStartingTime(TmpProdOrderRtngLine,FirstLine,SendAheadLotSize);
            TmpProdOrderCapNeed := ProdOrderCapNeed2;
            if TmpProdOrderRtngLine."Operation No." = TmpProdOrderCapNeed."Operation No." then
              TmpProdOrderCapNeed.Insert;
          until TmpProdOrderRtngLine.Next = 0;
        end else
          Result := GetSendAheadStartingTime(TmpProdOrderRtngLine,false,SendAheadLotSize);

        exit(Result);
    end;

    procedure ReturnNextCalendarEntry(var CalendarEntry2: Record "Calendar Entry";OldCalendarEntry: Record "Calendar Entry";Direction: Option Backward,Forward)
    begin
        CalendarEntry2 := OldCalendarEntry;
        CalendarEntry2.SetRange(Date,CalendarEntry2.Date);

        if Direction = Direction::Backward then begin
          CalendarEntry2.Find('-');           // rewind within the same day
          CalendarEntry2.SetRange(Date);
          if CalendarEntry2.Next(-1) = 0 then
            TestForError(Text001,Text002,CalendarEntry2.Date);

          if (CalendarEntry2.Date + 1) < OldCalendarEntry.Date then begin
            CalendarEntry2.Date := OldCalendarEntry.Date - 1;
            CreateCalendarEntry(CalendarEntry2);
          end;
        end else begin
          CalendarEntry2.Find('+');            // rewind within the same day
          CalendarEntry2.SetRange(Date);
          if CalendarEntry2.Next = 0 then
            TestForError(Text003,Text004,CalendarEntry2.Date);

          if OldCalendarEntry.Date < (CalendarEntry2.Date - 1) then begin
            CalendarEntry2.Date := OldCalendarEntry.Date + 1;
            CreateCalendarEntry(CalendarEntry2);
          end;
        end;
    end;

    local procedure CreateCalendarEntry(var CalendarEntry2: Record "Calendar Entry")
    begin
        with CalendarEntry2 do begin
          "Ending Time" := 000000T;
          "Starting Time" := 000000T;
          Efficiency := 100;
          "Absence Capacity" := 0;
          "Capacity (Total)" := 0;
          "Capacity (Effective)" := "Capacity (Total)";
          "Starting Date-Time" := CreateDatetime(Date,"Starting Time");
          "Ending Date-Time" := "Starting Date-Time" + 86400000;
          if not Get("Capacity Type","No.",Date,"Starting Time","Ending Time","Work Shift Code") then
            Insert;
        end;
    end;

    local procedure GetCurrentWorkCenterTimeFactorAndRounding(WorkCenterNo: Code[20])
    var
        WorkCenter: Record "Work Center";
    begin
        if CurrentWorkCenterNo = WorkCenterNo then
          exit;

        WorkCenter.Get(WorkCenterNo);
        CurrentTimeFactor := CalendarMgt.TimeFactor(WorkCenter."Unit of Measure Code");
        CurrentRounding := WorkCenter."Calendar Rounding Precision";
    end;

    local procedure CalcCapConResWorkCenterLoadBase(CapacityConstrainedResource: Record "Capacity Constrained Resource";DateFilter: Date;var CapEffectiveBase: Decimal;var LoadBase: Decimal)
    begin
        CapEffectiveBase := 0;
        LoadBase := 0;

        with CapacityConstrainedResource do begin
          SetRange("Date Filter",DateFilter);
          CalcFields("Capacity (Effective)","Work Center Load Qty.");
          if "Capacity (Effective)" <> 0 then begin
            CapEffectiveBase := ROUND("Capacity (Effective)" * CurrentTimeFactor,CurrentRounding);
            LoadBase := ROUND("Work Center Load Qty." * CurrentTimeFactor,CurrentRounding);
          end;
        end;
    end;

    local procedure CalcCapConResProdOrderNeedBase(CapacityConstrainedResource: Record "Capacity Constrained Resource";DateFilter: Date;var CapEffectiveBase: Decimal;var LoadBase: Decimal)
    begin
        CapEffectiveBase := 0;
        LoadBase := 0;

        with CapacityConstrainedResource do begin
          SetRange("Date Filter",DateFilter);
          CalcFields("Capacity (Effective)","Prod. Order Need Qty.");
          if "Capacity (Effective)" <> 0 then begin
            CapEffectiveBase := ROUND("Capacity (Effective)" * CurrentTimeFactor,CurrentRounding);
            LoadBase := ROUND("Prod. Order Need Qty." * CurrentTimeFactor,CurrentRounding);
          end;
        end;
    end;

    procedure CalcAvailCapBaseAndDampTime(CapacityConstrainedResource: Record "Capacity Constrained Resource";var AvailCap: Decimal;var DampTime: Decimal;CapEffectiveBase: Decimal;LoadBase: Decimal;TimeFactor: Decimal;Rounding: Decimal)
    var
        AvailCapBase: Decimal;
        AvailCapBaseMax: Decimal;
        LoadPct: Decimal;
        DampenerPct: Decimal;
        CriticalLoadPct: Decimal;
    begin
        AvailCap := 0;
        DampTime := 0;

        if CapEffectiveBase = 0 then
          exit;

        CriticalLoadPct := CapacityConstrainedResource."Critical Load %";
        AvailCapBaseMax := ROUND(CapEffectiveBase * CriticalLoadPct / 100,Rounding);
        AvailCapBase := Max(0,AvailCapBaseMax - LoadBase);
        AvailCap := ROUND(AvailCapBase / TimeFactor,Rounding);

        LoadPct := ROUND(LoadBase / CapEffectiveBase * 100,Rounding);
        DampenerPct := CapacityConstrainedResource."Dampener (% of Total Capacity)";
        DampTime :=
          ROUND(CapEffectiveBase / TimeFactor * Min(DampenerPct,CriticalLoadPct + DampenerPct - LoadPct) / 100,Rounding);
        DampTime := ROUND(Max(0,DampTime),1);
    end;

    procedure CalcAvailQtyBase(var CalendarEntry: Record "Calendar Entry";ProdStartDate: Date;ProdStartTime: Time;TimeType: Option "Setup Time","Run Time","Wait Time","Move Time","Queue Time";ConCurrCap: Decimal;IsForward: Boolean;TimeFactor: Decimal;Rounding: Decimal) AvQtyBase: Decimal
    var
        CalendarStartTime: Time;
        CalendarEndTime: Time;
        CalcFactor: Integer;
        ModifyCalendar: Boolean;
    begin
        if IsForward then begin
          CalendarStartTime := CalendarEntry."Starting Time";
          CalendarEndTime := CalendarEntry."Ending Time";
          CalcFactor := -1
        end else begin
          CalendarStartTime := CalendarEntry."Ending Time";
          CalendarEndTime := CalendarEntry."Starting Time";
          CalcFactor := 1;
        end;
        ModifyCalendar := false;

        if (((CalendarStartTime < ProdStartTime) and IsForward) or
            ((CalendarStartTime > ProdStartTime) and not IsForward)) and
           (CalendarEntry.Date = ProdStartDate)
        then begin
          case TimeType of
            Timetype::"Setup Time",
            Timetype::"Run Time":
              AvQtyBase :=
                ROUND(
                  Abs(CalendarEndTime - ProdStartTime) *
                  CalendarEntry.Efficiency / 100 * ConCurrCap,Rounding);
            Timetype::"Move Time",
            Timetype::"Queue Time":
              AvQtyBase :=
                ROUND(
                  Abs(CalendarEndTime - ProdStartTime) *
                  ConCurrCap,Rounding);
            Timetype::"Wait Time":
              begin
                AvQtyBase := CalcAvailQtyBaseForWaitTime(ProdStartTime,ProdStartDate,CalendarEntry.Date,CalcFactor,IsForward);
                AvQtyBase := ROUND(AvQtyBase * ConCurrCap,Rounding);
              end;
          end;
          ModifyCalendar := true;
        end else
          if (CalendarEntry.Capacity = CalendarEntry."Absence Capacity") and
             (TimeType <> Timetype::"Wait Time")
          then
            AvQtyBase := 0
          else
            case TimeType of
              Timetype::"Setup Time",
              Timetype::"Run Time":
                AvQtyBase :=
                  ROUND(
                    TimeFactor * CalendarEntry."Capacity (Effective)" /
                    (CalendarEntry.Capacity - CalendarEntry."Absence Capacity") * ConCurrCap,
                    Rounding);
              Timetype::"Move Time",
              Timetype::"Queue Time":
                AvQtyBase :=
                  ROUND(
                    TimeFactor * CalendarEntry."Capacity (Total)" /
                    (CalendarEntry.Capacity - CalendarEntry."Absence Capacity") * ConCurrCap,
                    Rounding);
              Timetype::"Wait Time":
                begin
                  AvQtyBase := CalcAvailQtyBaseForWaitTime(ProdStartTime,ProdStartDate,CalendarEntry.Date,CalcFactor,IsForward);
                  AvQtyBase := ROUND(AvQtyBase * ConCurrCap,Rounding);
                  ModifyCalendar := true;
                end;
            end;

        if ModifyCalendar then
          if IsForward then
            CalendarEntry."Starting Time" := ProdStartTime
          else
            CalendarEntry."Ending Time" := ProdStartTime;
    end;

    local procedure CalcAvailQtyBaseForWaitTime(ProdStartTime: Time;ProdStartDate: Date;CalendarEntryDate: Date;CalcFactor: Integer;IsForward: Boolean): Decimal
    begin
        if (ProdStartTime = 000000T) and ((CalendarEntryDate <> ProdStartDate) or IsForward) then
          exit(86400000);
        exit((86400000 + (ProdStartTime - 000000T) * CalcFactor) MOD 86400000);
    end;

    local procedure SetMaxDateTime(var ResultingDate: Date;var ResultingTime: Time;DateToCompare: Date;TimeToCompare: Time)
    begin
        if ((ResultingDate = DateToCompare) and (ResultingTime >= TimeToCompare)) or
           (ResultingDate > DateToCompare)
        then
          exit;
        ResultingDate := DateToCompare;
        ResultingTime := TimeToCompare;
    end;

    local procedure SetMinDateTime(var ResultingDate: Date;var ResultingTime: Time;DateToCompare: Date;TimeToCompare: Time)
    begin
        if ((ResultingDate = DateToCompare) and (ResultingTime <= TimeToCompare)) or
           (ResultingDate < DateToCompare)
        then
          exit;
        ResultingDate := DateToCompare;
        ResultingTime := TimeToCompare
    end;

    local procedure SetRoutingLineFilters(ProdOrderRoutingLine: Record "Prod. Order Routing Line";var ProdOrderRoutingLine2: Record "Prod. Order Routing Line")
    begin
        with ProdOrderRoutingLine2 do begin
          SetRange(Status,ProdOrderRoutingLine.Status);
          SetRange("Prod. Order No.",ProdOrderRoutingLine."Prod. Order No.");
          SetRange("Routing Reference No.",ProdOrderRoutingLine."Routing Reference No.");
          SetRange("Routing No.",ProdOrderRoutingLine."Routing No.");
          SetFilter("Routing Status",'<>%1',"routing status"::Finished);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateRoutingLine(var ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    begin
    end;
}

