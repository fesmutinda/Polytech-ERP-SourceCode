Page 50133 "Dividends Processing Flat-Rate"
{
    ApplicationArea = All;
    Caption = 'Dividends Processing Flat Rate-List';
    PageType = ListPart;
    SourceTable = "Dividends Register Flat Rate1";
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Member No"; Rec."Member No")
                {
                    ToolTip = 'Specifies the value of the Member No field.';
                }
                field("Dividend Year"; Rec.Date)
                {
                }
                field("Current Shares"; Rec."Gross Dividends")
                {
                }
                field("Qualifying Current Shares"; Rec."Gross Rebates")
                {
                }
                field("Gross Interest -Current Shares"; Rec."Witholding Tax")
                {
                }
                field("WTX -Current Shares"; Rec."Net Dividends/Rebates")
                {
                }
                field("Net Interest -Current Shares"; Rec."Qualifying Shares")
                {
                }
                field("FOSA Shares"; Rec.Shares)
                {
                }
                field("Qualifying FOSA Shares"; Rec."Share Capital")
                {
                }
                field("Gross Interest -FOSA Shares"; Rec."Gross Dividend/Rebates")
                {
                }
            }
        }
    }
}
