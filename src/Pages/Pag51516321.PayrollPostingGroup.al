#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516321 "Payroll Posting Group."
{
    PageType = List;
    SourceTable = "Payroll Posting Groups.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Posting Code"; Rec."Posting Code")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Salary Account"; Rec."Salary Account")
                {
                    ApplicationArea = Basic;
                }
                field("Income Tax Account"; Rec."Income Tax Account")
                {
                    ApplicationArea = Basic;
                }
                field("SSF Employer Account"; Rec."SSF Employer Account")
                {
                    ApplicationArea = Basic;
                    Caption = 'NSSF Employer Account';
                }
                field("SSF Employee Account"; Rec."SSF Employee Account")
                {
                    ApplicationArea = Basic;
                    Caption = 'NSSF Employee Account';
                }
                field("Net Salary Payable"; Rec."Net Salary Payable")
                {
                    ApplicationArea = Basic;
                }
                field("Operating Overtime"; Rec."Operating Overtime")
                {
                    ApplicationArea = Basic;
                }
                field("Tax Relief"; Rec."Tax Relief")
                {
                    ApplicationArea = Basic;
                }
                field("Employee Provident Fund Acc."; Rec."Employee Provident Fund Acc.")
                {
                    ApplicationArea = Basic;
                }
                field("Pay Period Filter"; Rec."Pay Period Filter")
                {
                    ApplicationArea = Basic;
                }
                field("Pension Employer Acc"; Rec."Pension Employer Acc")
                {
                    ApplicationArea = Basic;
                }
                field("Pension Employee Acc"; Rec."Pension Employee Acc")
                {
                    ApplicationArea = Basic;
                }
                field("Earnings and deductions"; Rec."Earnings and deductions")
                {
                    ApplicationArea = Basic;
                }
                field("Staff Benevolent"; Rec."Staff Benevolent")
                {
                    ApplicationArea = Basic;
                }
                field(SalaryExpenseAC; Rec.SalaryExpenseAC)
                {
                    ApplicationArea = Basic;
                }
                field("Directors Fee GL"; Rec."Directors Fee GL")
                {
                    ApplicationArea = Basic;
                }
                field("Staff Gratuity"; Rec."Staff Gratuity")
                {
                    ApplicationArea = Basic;
                }
                field("NHIF Employee Account"; Rec."NHIF Employee Account")
                {
                    ApplicationArea = Basic;
                }
                field("Payroll Code"; Rec."Payroll Code")
                {
                    ApplicationArea = Basic;
                }
                field("Upload to Payroll"; Rec."Upload to Payroll")
                {
                    ApplicationArea = Basic;
                }
                field("PAYE Benefit A/C"; Rec."PAYE Benefit A/C")
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

