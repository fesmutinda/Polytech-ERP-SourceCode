page 50009 "Payment Line New"
{
    ApplicationArea = All;
    Caption = 'Payment Line New';
    PageType = List;
    SourceTable = "Payment Line New";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Line No."; Rec."Line No.")
                {
                }
                field("Document No"; Rec."Document No")
                {
                }
                field("Type"; Rec."Type")
                {
                }
                field("Account No."; Rec."Account No.")
                {
                }
                field("Account Name"; Rec."Account Name")
                {
                }
                field("Account Type"; Rec."Account Type")
                {
                }
                field(Posted; Rec.Posted)
                {
                }
                field("Date Posted"; Rec."Date Posted")
                {
                }
                field("Posted By"; Rec."Posted By")
                {
                }
                field(Amount; Rec.Amount)
                {
                }
                field("Withholding Tax Amount"; Rec."Withholding Tax Amount")
                {
                }
                field("Net Amount"; Rec."Net Amount")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Posting Date"; Rec."Posting Date")
                {
                }
                field("Member Type"; Rec."Member Type")
                {
                }
                field("Board Member Name"; Rec."Board Member Name")
                {
                }
            }
        }
    }
}
