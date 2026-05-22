page 50012 "M-Polytech Deductions"
{
    ApplicationArea = All;
    Caption = 'M-Polytech Deductions';
    PageType = List;
    SourceTable = "M-Polytech Deductions";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Entry; Rec.Entry)
                {
                    ToolTip = 'Specifies the value of the Entry field.', Comment = '%';
                }
                field("Member Number"; Rec."Member Number")
                {
                    ToolTip = 'Specifies the value of the Member Number field.', Comment = '%';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Specifies the value of the Member Name field.', Comment = '%';
                }
                field("Current Deposits"; Rec."Current Deposits")
                {
                    ToolTip = 'Specifies the value of the Current Deposits field.', Comment = '%';
                }
                field("Deposits at Deduction"; Rec."Deposits at Deduction")
                {
                    ToolTip = 'Specifies the value of the Deposits at Deduction field.', Comment = '%';
                }
                field("Loan Number"; Rec."Loan Number")
                {
                    ToolTip = 'Specifies the value of the Loan Number field.', Comment = '%';
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ToolTip = 'Specifies the value of the Loan Balance field.', Comment = '%';
                }
                field("Amount Deducted"; Rec."Amount Deducted")
                {
                    ToolTip = 'Specifies the value of the Amount Deducted field.', Comment = '%';
                }
                field("Interest Deducted"; Rec."Interest Deducted") { }
                field("Date Deducted"; Rec."Date Deducted")
                {
                    ToolTip = 'Specifies the value of the Date Deducted field.', Comment = '%';
                }
                field("Date Eligible"; Rec."Date Eligible")
                {
                    ToolTip = 'Specifies the value of the Date Eligible field.', Comment = '%';
                }
            }
        }
    }
}
