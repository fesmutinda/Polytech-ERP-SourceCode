#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000890 "Machine Center Load Lines"
{
    Caption = 'Lines';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    SaveValues = true;
    SourceTable = Date;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Period Start";"Period Start")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Period Start';
                    ToolTip = 'Specifies the starting date for the evaluation of the machine centers, which according to the actual planning are overloaded.';
                }
                field("Period Name";"Period Name")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Period Name';
                    ToolTip = 'Specifies the name of the period shown in the line.';
                }
                field(Capacity;MachineCenter."Capacity (Effective)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Capacity';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of work that can be done in a specified time period at this machine center.';

                    trigger OnDrillDown()
                    var
                        CalendarEntry: Record "Calendar Entry";
                    begin
                        CalendarEntry.SetRange("Capacity Type",CalendarEntry."capacity type"::"Machine Center");
                        CalendarEntry.SetRange("No.",MachineCenter."No.");
                        CalendarEntry.SetRange(Date,"Period Start","Period End");

                        Page.Run(0,CalendarEntry);
                    end;
                }
                field(AllocatedQty;MachineCenter."Prod. Order Need (Qty.)")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Allocated Qty.';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the amount of capacity that is needed to produce a desired output in a given time period. ';

                    trigger OnDrillDown()
                    var
                        ProdOrderCapNeed: Record "Prod. Order Capacity Need";
                    begin
                        ProdOrderCapNeed.SetCurrentkey(Type,"No.","Starting Date-Time");
                        ProdOrderCapNeed.SetRange(Type,ProdOrderCapNeed.Type::"Machine Center");
                        ProdOrderCapNeed.SetRange("No.",MachineCenter."No.");
                        ProdOrderCapNeed.SetRange(Date,"Period Start","Period End");
                        ProdOrderCapNeed.SetRange("Requested Only",false);
                        Page.Run(0,ProdOrderCapNeed);
                    end;
                }
                field(CapacityAvailable;CapacityAvailable)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Availability After Orders';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the available capacity of this machine center that is not used in the planning of a given time period.';
                }
                field(CapacityEfficiency;CapacityEfficiency)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Load';
                    DecimalPlaces = 0:5;
                    ToolTip = 'Specifies the sum of the required number of times that all the planned and actual orders are run on the machine center in a specified period.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetDateFilter;
        MachineCenter.CalcFields("Capacity (Effective)","Prod. Order Need (Qty.)");
        CapacityAvailable := MachineCenter."Capacity (Effective)" - MachineCenter."Prod. Order Need (Qty.)";
        if MachineCenter."Capacity (Effective)" <> 0 then
          CapacityEfficiency := ROUND(MachineCenter."Prod. Order Need (Qty.)" / MachineCenter."Capacity (Effective)" * 100,0.1)
        else
          CapacityEfficiency := 0;
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        exit(PeriodFormMgt.FindDate(Which,Rec,PeriodType));
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        exit(PeriodFormMgt.NextDate(Steps,Rec,PeriodType));
    end;

    trigger OnOpenPage()
    begin
        Reset;
    end;

    var
        MachineCenter: Record "Machine Center";
        PeriodFormMgt: Codeunit UnknownCodeunit359;
        CapacityAvailable: Decimal;
        CapacityEfficiency: Decimal;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";

    procedure Set(var NewMachineCenter: Record "Machine Center";NewPeriodType: Integer;NewAmountType: Option "Net Change","Balance at Date")
    begin
        MachineCenter.Copy(NewMachineCenter);
        PeriodType := NewPeriodType;
        AmountType := NewAmountType;
        CurrPage.Update(false);
    end;

    local procedure SetDateFilter()
    begin
        if AmountType = Amounttype::"Net Change" then
          MachineCenter.SetRange("Date Filter","Period Start","Period End")
        else
          MachineCenter.SetRange("Date Filter",0D,"Period End");
    end;
}

