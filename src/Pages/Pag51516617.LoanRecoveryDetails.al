#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516617 "Loan Recovery Details"
{
    PageType = ListPart;
    SourceTable = 51516551;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Guarantor Number"; "Guarantor Number")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Name';
                    Editable = false;
                }
                field("phone No"; "phone No")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Type"; "Loan Type")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Monthly Repayment"; "Monthly Repayment")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Loan No."; "Loan No.")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Outstanding"; "Loan Outstanding")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Outstanding Balance"; "Outstanding Balance")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Outstanding Interest"; "Outstanding Interest")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Guarantor Deposits"; "Guarantor Deposits")
                {
                    ApplicationArea = Basic;
                }
                field("Defaulter Loan"; "Defaulter Loan")
                {
                    ApplicationArea = Basic;
                    Caption = 'Trustee Loan';
                    Editable = false;
                }
                field("Amount to Trustee Loan"; "Amount to Trustee Loan")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Origan Amount"; "Origan Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Amont Guaranteed"; "Amont Guaranteed")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Per(%)"; "Per(%)")
                {
                    ApplicationArea = Basic;
                }
                field(PayOff; PayOff)
                {
                    ApplicationArea = Basic;
                    Caption = 'PayOff Amount';
                }
                field("Amount from Deposits"; "Amount from Deposits")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

