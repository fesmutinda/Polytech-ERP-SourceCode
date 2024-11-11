#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000917 "Report Selection - Prod. Order"
{
    Caption = 'Report Selection - Prod. Order';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Report Selections";

    layout
    {
        area(content)
        {
            field(ReportUsage2;ReportUsage2)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Usage';
                OptionCaption = 'Job Card,Mat. & Requisition,Shortage List,Gantt Chart,Prod. Order';
                ToolTip = 'Specifies which type of document the report is used for.';

                trigger OnValidate()
                begin
                    SetUsageFilter(true);
                end;
            }
            repeater(Control1)
            {
                field(Sequence;Sequence)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a number that indicates where this report is in the printing order.';
                }
                field("Report ID";"Report ID")
                {
                    ApplicationArea = Manufacturing;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the report ID of the report that the program will print.';
                }
                field("Report Caption";"Report Caption")
                {
                    ApplicationArea = Manufacturing;
                    DrillDown = false;
                    ToolTip = 'Specifies the name of the report.';
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
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        NewRecord;
    end;

    trigger OnOpenPage()
    begin
        SetUsageFilter(false);
    end;

    var
        ReportUsage2: Option "Job Card","Mat. & Requisition","Shortage List","Gantt Chart","Prod. Order";

    local procedure SetUsageFilter(ModifyRec: Boolean)
    begin
        if ModifyRec then
          if Modify then;
        FilterGroup(2);
        case ReportUsage2 of
          Reportusage2::"Job Card":
            SetRange(Usage,Usage::M1);
          Reportusage2::"Mat. & Requisition":
            SetRange(Usage,Usage::M2);
          Reportusage2::"Shortage List":
            SetRange(Usage,Usage::M3);
          Reportusage2::"Gantt Chart":
            SetRange(Usage,Usage::M4);
          Reportusage2::"Prod. Order":
            SetRange(Usage,Usage::"Prod. Order");
        end;
        FilterGroup(0);
        CurrPage.Update;
    end;
}

