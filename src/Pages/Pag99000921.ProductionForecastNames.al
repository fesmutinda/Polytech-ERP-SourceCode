#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000921 "Production Forecast Names"
{
    Caption = 'Production Forecast Names';
    PageType = List;
    SourceTable = "Production Forecast Name";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name;Name)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the name of the production forecast.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a brief description of the production forecast.';
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
        area(processing)
        {
            action("Edit Production Forecast")
            {
                ApplicationArea = Manufacturing;
                Caption = 'Edit Production Forecast';
                Image = EditForecast;
                Promoted = true;
                PromotedCategory = Process;
                ShortCutKey = 'Return';
                ToolTip = 'Open the related production forecast.';

                trigger OnAction()
                var
                    ProductionForecast: Page "Production Forecast";
                begin
                    ProductionForecast.SetProductionForecastName(Name);
                    ProductionForecast.Run;
                end;
            }
        }
    }
}

