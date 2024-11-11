#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000919 "Production Forecast"
{
    Caption = 'Production Forecast';
    DataCaptionExpression = ProductionForecastName;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPlus;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ProductionForecastName;ProductionForecastName)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Production Forecast Name';
                    TableRelation = "Production Forecast Name".Name;
                    ToolTip = 'Specifies the name of the relevant production forecast for which you are creating an entry.';

                    trigger OnValidate()
                    begin
                        SetMatrix;
                    end;
                }
                field(LocationFilter;LocationFilter)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Location Filter';
                    ToolTip = 'Specifies a location code if you want to create a forecast entry for a specific location.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Loc: Record Location;
                        LocList: Page "Location List";
                    begin
                        LocList.LookupMode(true);
                        Loc.SetRange("Use As In-Transit",false);
                        LocList.SetTableview(Loc);
                        if not (LocList.RunModal = Action::LookupOK) then
                          exit(false);

                        Text := LocList.GetSelectionFilter;

                        exit(true);
                    end;

                    trigger OnValidate()
                    var
                        Location: Record Location;
                    begin
                        Location.SetFilter(Code,LocationFilter);
                        LocationFilter := Location.GetFilter(Code);
                        SetMatrix;
                    end;
                }
                field(PeriodType;PeriodType)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'View by';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        SetColumns(Setwanted::First);
                    end;
                }
                field(QtyType;QtyType)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'View as';
                    OptionCaption = 'Net Change,Balance at Date';
                    ToolTip = 'Specifies how amounts are displayed. Net Change: The net change in the balance for the selected period. Balance at Date: The balance as of the last day in the selected period.';

                    trigger OnValidate()
                    begin
                        QtyTypeOnAfterValidate;
                    end;
                }
                field(ForecastType;ForecastType)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Forecast Type';
                    OptionCaption = 'Sales Item,Component,Both';
                    ToolTip = 'Specifies one of the following two types when you create a production forecast entry: sales item or component item.';

                    trigger OnValidate()
                    begin
                        ForecastTypeOnAfterValidate;
                    end;
                }
                field(DateFilter;DateFilter)
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    var
                        ApplicationManagement: Codeunit ApplicationManagement;
                    begin
                        if ApplicationManagement.MakeDateFilter(DateFilter) = 0 then;
                        SetColumns(Setwanted::First);
                    end;
                }
            }
            part(Matrix;UnknownPage9245)
            {
                ApplicationArea = Manufacturing;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Copy Production Forecast")
                {
                    ApplicationArea = Manufacturing;
                    Caption = 'Copy Production Forecast';
                    Ellipsis = true;
                    Image = CopyForecast;
                    RunObject = Report "Copy Production Forecast";
                    ToolTip = 'Copy an existing production forecast to quickly create a similar forecast.';
                }
            }
            action("Previous Set")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                begin
                    SetColumns(Setwanted::Previous);
                end;
            }
            action("Previous Column")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Previous Column';
                Image = PreviousRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the previous column.';

                trigger OnAction()
                begin
                    SetColumns(Setwanted::PreviousColumn);
                end;
            }
            action("Next Column")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Next Column';
                Image = NextRecord;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next column.';

                trigger OnAction()
                begin
                    SetColumns(Setwanted::NextColumn);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                begin
                    SetColumns(Setwanted::Next);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (NewProductionForecastName <> '') and (NewProductionForecastName <> ProductionForecastName) then
          ProductionForecastName := NewProductionForecastName;
        SetColumns(Setwanted::First);
    end;

    var
        MatrixRecords: array [32] of Record Date;
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        QtyType: Option "Net Change","Balance at Date";
        ForecastType: Option "Sales Item",Component,Both;
        ProductionForecastName: Text[30];
        NewProductionForecastName: Text[30];
        LocationFilter: Text;
        DateFilter: Text[1024];
        MatrixColumnCaptions: array [32] of Text[1024];
        ColumnSet: Text[1024];
        SetWanted: Option First,Previous,Same,Next,PreviousColumn,NextColumn;
        PKFirstRecInCurrSet: Text[100];
        CurrSetLength: Integer;


    procedure SetColumns(SetWanted: Option Initial,Previous,Same,Next,PreviousSet,NextSet)
    var
        MatrixMgt: Codeunit "Matrix Management";
    begin
        MatrixMgt.GeneratePeriodMatrixData(SetWanted,ArrayLen(MatrixRecords),false,PeriodType,DateFilter,PKFirstRecInCurrSet,
          MatrixColumnCaptions,ColumnSet,CurrSetLength,MatrixRecords);
        SetMatrix;
    end;

    procedure SetProductionForecastName(NextProductionForecastName: Text[30])
    begin
        NewProductionForecastName := NextProductionForecastName;
    end;


    procedure SetMatrix()
    begin
        CurrPage.Matrix.Page.Load(
          MatrixColumnCaptions,MatrixRecords,ProductionForecastName,DateFilter,LocationFilter,ForecastType,
          QtyType,CurrSetLength);
        CurrPage.Update(false);
    end;

    local procedure ForecastTypeOnAfterValidate()
    begin
        SetMatrix;
    end;

    local procedure QtyTypeOnAfterValidate()
    begin
        SetMatrix;
    end;
}

