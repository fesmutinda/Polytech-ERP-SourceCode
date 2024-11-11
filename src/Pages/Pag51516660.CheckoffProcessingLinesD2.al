#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516660 "Checkoff Processing Lines-D2"
{
    DelayedInsert = false;
    DeleteAllowed = true;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = 51516654;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member No."; "Member No.")
                {
                    ApplicationArea = Basic;
                    StyleExpr = CoveragePercentStyle;
                }
                field("Staff/Payroll No"; "Staff/Payroll No")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Variance; Variance)
                {
                    ApplicationArea = Basic;
                }
                field("Employer Code"; "Employer Code")
                {
                    ApplicationArea = Basic;
                }
                field("Receipt Header No"; "Receipt Header No")
                {
                    ApplicationArea = Basic;
                }
                field("Jiokoe Savings"; "Jiokoe Savings")
                {
                    ApplicationArea = Basic;
                }
                field("Unallocated Fund"; "Unallocated Fund")
                {
                    ApplicationArea = Basic;
                }
                field("Deposit contribution"; "Deposit contribution")
                {
                    ApplicationArea = Basic;
                }
                field("Share Capital"; "Share Capital")
                {
                    ApplicationArea = Basic;
                }
                field("Entrance Fees"; "Entrance Fees")
                {
                    ApplicationArea = Basic;
                }
                field("Principal Loan"; "Principal Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Emergency 1 Loan"; "Emergency 1 Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Emergency 2 Loan"; "Emergency 2 Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Instant Loan"; "Instant Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Instant2 Loan"; "Instant2 Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Elimu Loan"; "Elimu Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Mjengo Loan"; "Mjengo Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Vision Loan"; "Vision Loan")
                {
                    ApplicationArea = Basic;
                }
                field("KHL Loan"; "KHL Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Car Loan"; "Car Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Sukuma Mwezi Loan"; "Sukuma Mwezi Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Karibu Loan"; "Karibu Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Mali Mali Loan"; "Mali Mali Loan")
                {
                    ApplicationArea = Basic;
                }
                field("Motor Vehicle Insurance"; "Motor Vehicle Insurance")
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
        if Name = '' then
            CoveragePercentStyle := 'Unfavorable';
        if Name <> '' then
            CoveragePercentStyle := 'Favorable';
    end;
}

