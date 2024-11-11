#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000817 "Manu. Print Report"
{

    trigger OnRun()
    begin
    end;

    var
        ReportSelection: Record "Report Selections";
        ProductionOrder: Record "Production Order";

    procedure PrintProductionOrder(NewProductionOrder: Record "Production Order";Usage: Option)
    begin
        ProductionOrder := NewProductionOrder;
        ProductionOrder.SetRecfilter;

        ReportSelection.PrintWithCheck(ConvertUsage(Usage),ProductionOrder,'');
    end;

    local procedure ConvertUsage(Usage: Option M1,M2,M3,M4): Integer
    begin
        case Usage of
          Usage::M1:
            exit(ReportSelection.Usage::M1);
          Usage::M2:
            exit(ReportSelection.Usage::M2);
          Usage::M3:
            exit(ReportSelection.Usage::M3);
          Usage::M4:
            exit(ReportSelection.Usage::M4);
        end;
    end;
}

