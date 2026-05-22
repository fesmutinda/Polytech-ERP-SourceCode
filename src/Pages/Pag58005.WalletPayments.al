
page 58005 "Wallet Payments"
{
    ApplicationArea = All;
    Caption = 'Wallet Payments';
    PageType = List;
    CardPageId = "Wallet Payments Card";
    SourceTable = "Wallet Transactions";
    SourceTableView = where(Posted = filter(false));

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(No; Rec.No)
                {
                    ToolTip = 'Specifies the value of the No field.', Comment = '%';
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ToolTip = 'Specifies the value of the Transaction Date field.', Comment = '%';
                }
                field("Schedule Total"; Rec."Schedule Total")
                {
                    ToolTip = 'Specifies the value of the Schedule Total field.', Comment = '%';
                }
                field("Total Amount"; Rec."Total Amount") { }
                field(Approved; Rec.Approved)
                {
                    ToolTip = 'Specifies the value of the Approved field.', Comment = '%';
                }
                field("Approved By"; Rec."Approved By")
                {
                    ToolTip = 'Specifies the value of the Approved By field.', Comment = '%';
                }
                field(Posted; Rec.Posted)
                {
                    ToolTip = 'Specifies the value of the Posted field.', Comment = '%';
                }
                field("Captured By"; Rec."Captured By") { }
            }
        }
    }
}
