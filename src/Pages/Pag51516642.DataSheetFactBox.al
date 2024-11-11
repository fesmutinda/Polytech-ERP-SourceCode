#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516642 "Data Sheet FactBox"
{
    PageType = CardPart;
    SourceTable = 51516482;

    layout
    {
        area(content)
        {
            field("Code"; Code)
            {
                ApplicationArea = Basic;
            }
            field("Total Members"; "Total Members")
            {
                ApplicationArea = Basic;
            }
            field("Total Schedule Amount P"; "Total Schedule Amount P")
            {
                ApplicationArea = Basic;
                Caption = 'Total Loan Principal';
            }
            field("Total Schedule Amount I"; "Total Schedule Amount I")
            {
                ApplicationArea = Basic;
                Caption = 'Total Loan Interest';
            }
            field("Total Entrance Fees"; "Total Entrance Fees")
            {
                ApplicationArea = Basic;
            }
            field("Total Share Capital"; "Total Share Capital")
            {
                ApplicationArea = Basic;
            }
            field("Total Schedule Amount D"; "Total Schedule Amount D")
            {
                ApplicationArea = Basic;
                Caption = 'Total Deposit Contribution';
            }
            field("Total Kanisa Savings"; "Total Kanisa Savings")
            {
                ApplicationArea = Basic;
            }
            field("Total Schedule Amount"; "Total Schedule Amount")
            {
                ApplicationArea = Basic;
                Style = Attention;
                StyleExpr = true;
            }
        }
    }

    actions
    {
    }
}

