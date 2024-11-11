#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516640 "Data Sheet Lines"
{
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = 51516421;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payroll No"; "Payroll No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic;
                }
                field("Loan Type"; "Loan Type")
                {
                    ApplicationArea = Basic;
                }
                field("Principal Amount"; "Principal Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Outstanding Interest"; "Outstanding Interest")
                {
                    ApplicationArea = Basic;
                }
                field("Outstanding Balance"; "Outstanding Balance")
                {
                    ApplicationArea = Basic;
                }
                field("Expected Principal Balance"; "Expected Principal Balance")
                {
                    ApplicationArea = Basic;
                    Caption = 'Expected Principal Balance(Post-ChkOff)';
                }
                field("Share Capital"; "Share Capital")
                {
                    ApplicationArea = Basic;
                }
                field("Entrance Fees"; "Entrance Fees")
                {
                    ApplicationArea = Basic;
                }
                field("Deposit Contribution"; "Deposit Contribution")
                {
                    ApplicationArea = Basic;
                }
                field("Kanisa Savings"; "Kanisa Savings")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                    Style = StrongAccent;
                    StyleExpr = true;
                }
            }
        }
    }

    actions
    {
    }
}

