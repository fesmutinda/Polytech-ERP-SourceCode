#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130407 "CAL Test Objects To Select"
{
    Caption = 'CAL Test Objects To Select';
    Editable = false;
    PageType = List;
    SourceTable = "Object";
    SourceTableView = where(Type=filter(>TableData));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Type;Type)
                {
                    ApplicationArea = All;
                }
                field(ID;ID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID that applies.';
                }
                field(Name;Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the test objects selected.';
                }
                field(HitBy;CountTestCodeunits)
                {
                    ApplicationArea = All;
                    Caption = 'Hit By Test Codeunits';

                    trigger OnDrillDown()
                    begin
                        if CALTestCoverageMap.FindFirst then
                          Page.RunModal(0,CALTestCoverageMap);
                    end;
                }
                field(Caption;Caption)
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    Visible = false;
                }
                field(Modified;Modified)
                {
                    ApplicationArea = All;
                }
                field(Date;Date)
                {
                    ApplicationArea = All;
                }
                field(Time;Time)
                {
                    ApplicationArea = All;
                }
                field("Version List";"Version List")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CALTestCoverageMap.SetRange("Object Type",Type);
        CALTestCoverageMap.SetRange("Object ID",ID);
    end;

    var
        CALTestCoverageMap: Record "CAL Test Coverage Map";

    local procedure CountTestCodeunits(): Integer
    begin
        if CALTestCoverageMap.FindFirst then begin
          CALTestCoverageMap.CalcFields("Hit by Test Codeunits");
          exit(CALTestCoverageMap."Hit by Test Codeunits");
        end;
        exit(0);
    end;
}

