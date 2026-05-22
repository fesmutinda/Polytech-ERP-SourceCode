page 50010 "Loan Repayment Schedule List"
{
    ApplicationArea = All;
    Caption = 'Loan Repayment Schedule';
    PageType = List;
    SourceTable = "Loan Repayment Schedule";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Loan No."; Rec."Loan No.")
                {
                    ToolTip = 'Specifies the value of the Loan No. field.', Comment = '%';
                }
                field("Member No."; Rec."Member No.")
                {
                    ToolTip = 'Specifies the value of the Member No. field.', Comment = '%';
                }
                field("Member Name"; Rec."Member Name")
                {
                    ToolTip = 'Specifies the value of the Member Name field.', Comment = '%';
                }
                field("Instalment No"; Rec."Instalment No")
                {
                    ToolTip = 'Specifies the value of the Instalment No field.', Comment = '%';
                }
                field("Loan Amount"; Rec."Loan Amount")
                {
                    ToolTip = 'Specifies the value of the Loan Amount field.', Comment = '%';
                }
                field("Monthly Repayment"; Rec."Monthly Repayment")
                {
                    ToolTip = 'Specifies the value of the Monthly Repayment field.', Comment = '%';
                }
                field("Monthly Interest"; Rec."Monthly Interest")
                {
                    ToolTip = 'Specifies the value of the Monthly Interest field.', Comment = '%';
                }
                field("Repayment Date"; Rec."Repayment Date")
                {
                    ToolTip = 'Specifies the value of the Repayment Date field.', Comment = '%';
                }
                field("Principal Repayment"; Rec."Principal Repayment")
                {
                    ToolTip = 'Specifies the value of the Principal Repayment field.', Comment = '%';
                }
                field("Loan Balance"; Rec."Loan Balance")
                {
                    ToolTip = 'Specifies the value of the Loan Balance field.', Comment = '%';
                }
            }
        }
    }
}
