page 50058 "Tarrif Codes List"
{
    ApplicationArea = All;
    Caption = 'Tarrif Codes List';
    PageType = List;
    SourceTable = "Tariff Codes";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tax Code"; Rec."Tax Code")
                {
                    ToolTip = 'Specifies the value of the Tax Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
            }
        }
    }
}
