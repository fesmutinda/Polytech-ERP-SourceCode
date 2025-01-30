#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50316 "Payroll Deductions List."
{
    // version Payroll ManagementV1.0(Surestep Systems)
    ApplicationArea = Basic, Suite;
    Caption = 'Payroll Deductions List';
    UsageCategory = Lists;
    CardPageID = "Payroll Deductions Card.";
    PageType = List;
    SourceTable = "Payroll Transaction Code.";
    SourceTableView = WHERE("Transaction Type" = CONST(Deduction));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = All;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = All;
                }
                field("Is Formulae"; Rec."Is Formulae")
                {
                    ApplicationArea = All;
                }
                field("Co-Op Parameters"; Rec."Co-Op Parameters")
                {
                    ApplicationArea = All;
                }
                field(Formulae; Rec.Formulae)
                {
                    ApplicationArea = All;
                }
                field("G/L Account"; Rec."G/L Account")
                {
                    ApplicationArea = All;
                }
                field("G/L Account Name"; Rec."G/L Account Name")
                {
                    ApplicationArea = All;
                }
                field("Sacco Code"; Rec."Sacco Code")
                {
                    ApplicationArea = All;
                }
                field("Employee Name"; Rec."Employee Name")
                {
                    ApplicationArea = All;
                }
                field("pay period"; Rec."pay period")
                {
                    ApplicationArea = All;
                }
                field("Insurance Code"; Rec."Insurance Code")
                {
                    ApplicationArea = All;
                }
                field("Bank code"; Rec."Bank code")
                {
                    ApplicationArea = All;
                }
                field("Welfare code"; Rec."Welfare code")
                {
                    ApplicationArea = All;
                }
                field("Is Loan Account"; Rec."Is Loan Account")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Transaction Type" := Rec."Transaction Type"::Deduction;
    end;
}

