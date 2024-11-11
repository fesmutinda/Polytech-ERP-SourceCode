#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516483 "Checkoff Processing Lines-D"
{
    DelayedInsert = false;
    DeleteAllowed = true;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = 51516415;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Staff/Payroll No"; "Staff/Payroll No")
                {
                    ApplicationArea = Basic;
                    StyleExpr = CoveragePercentStyle;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Member No."; "Member No.")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Employer Code"; "Employer Code")
                {
                    ApplicationArea = Basic;
                }
                field("Shares Capital"; "Shares Capital")
                {
                    ApplicationArea = Basic;
                }
                field("Deposit contribution"; "Deposit contribution")
                {
                    ApplicationArea = Basic;
                }
                field("DLoan No"; "DLoan No")
                {
                    ApplicationArea = Basic;
                }
                field("Int DEVELOPMENT LOAN"; "Int DEVELOPMENT LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("DEVELOPMENT LOAN"; "DEVELOPMENT LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("Int INVESTMENT LOAN"; "Int INVESTMENT LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("INVESTMENT LOAN"; "INVESTMENT LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("Int SUPER SCHOOL FEES"; "Int SUPER SCHOOL FEES")
                {
                    ApplicationArea = Basic;
                }
                field("SUPER SCHOOL FEES"; "SUPER SCHOOL FEES")
                {
                    ApplicationArea = Basic;
                }
                field("Int SCHOOL FEES"; "Int SCHOOL FEES")
                {
                    ApplicationArea = Basic;
                }
                field("SCHOOL FEES"; "SCHOOL FEES")
                {
                    ApplicationArea = Basic;
                }
                field("Int SUPER QUICK"; "Int SUPER QUICK")
                {
                    ApplicationArea = Basic;
                }
                field("SUPER QUICK"; "SUPER QUICK")
                {
                    ApplicationArea = Basic;
                }
                field("Int QUICK LOAN"; "Int QUICK LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("QUICK LOAN"; "QUICK LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("Int EMERGENCY LOAN"; "Int EMERGENCY LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("EMERGENCY LOAN"; "EMERGENCY LOAN")
                {
                    ApplicationArea = Basic;
                }
                field("ELoan No."; "ELoan No.")
                {
                    ApplicationArea = Basic;
                }
                field(SLoanNo; SLoanNo)
                {
                    ApplicationArea = Basic;
                }
                field("QLoan No"; "QLoan No")
                {
                    ApplicationArea = Basic;
                }
                field("House Loan"; "House Loan")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetStyles();
    end;

    var
        CoveragePercentStyle: Text;

    local procedure SetStyles()
    begin
        CoveragePercentStyle := 'Strong';
        if "Member No." = '' then
            CoveragePercentStyle := 'Unfavorable';
        if "Member No." <> '' then
            CoveragePercentStyle := 'Favorable';
    end;
}

