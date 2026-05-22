namespace PolyTechERPSourceCode.PolyTechERPSourceCode;

page 50059 "Tarrif Codes Card"
{
    ApplicationArea = All;
    Caption = 'Tarrif Codes Card';
    PageType = Card;
    SourceTable = "Tariff Codes";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Tax Code"; Rec."Tax Code")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                }
                field("Account No"; Rec."Account No.")
                {
                    ApplicationArea = Basic;
                }
                field(Percentage; Rec.Percentage)
                {
                    ApplicationArea = Basic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;
                }
                field("Liability Account"; Rec."Liability Account")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }
}
