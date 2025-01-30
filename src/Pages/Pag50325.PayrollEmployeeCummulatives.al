#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50325 "Payroll Employee Cummulatives."
{
    // version Payroll ManagementV1.0(Surestep Systems)

    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Card;
    SourceTable = "Payroll Employee.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Full Name"; Rec."Full Name")
                {
                    ApplicationArea = All;
                }

            }
            group(Cummulatives)
            {
                field("Cummulative Basic Pay"; Rec."Cummulative Basic Pay")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Gross Pay"; Rec."Cummulative Gross Pay")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Allowances"; Rec."Cummulative Allowances")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Deductions"; Rec."Cummulative Deductions")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Net Pay"; Rec."Cummulative Net Pay")
                {
                    ApplicationArea = All;
                }
                field("Cummulative PAYE"; Rec."Cummulative PAYE")
                {
                    ApplicationArea = All;
                }
                field("Cummulative NSSF"; Rec."Cummulative NSSF")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Pension"; Rec."Cummulative Pension")
                {
                    ApplicationArea = All;
                }
                field("Cummulative HELB"; Rec."Cummulative HELB")
                {
                    ApplicationArea = All;
                }
                field("Cummulative NHIF"; Rec."Cummulative NHIF")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Employer Pension"; Rec."Cummulative Employer Pension")
                {
                    ApplicationArea = All;
                }
                field("Cummulative TopUp"; Rec."Cummulative TopUp")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Basic Pay(LCY)"; Rec."Cummulative Basic Pay(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Gross Pay(LCY)"; Rec."Cummulative Gross Pay(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Allowances(LCY)"; Rec."Cummulative Allowances(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Deductions(LCY)"; Rec."Cummulative Deductions(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Net Pay(LCY)"; Rec."Cummulative Net Pay(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Development Loans"; Rec."Development Loans")
                {
                    ApplicationArea = all;
                }
                field("Emergency Loans"; Rec."Emergency Loans")
                {
                    ApplicationArea = all;
                }
                field("Cummulative PAYE(LCY)"; Rec."Cummulative PAYE(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative NSSF(LCY)"; Rec."Cummulative NSSF(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Pension(LCY)"; Rec."Cummulative Pension(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative HELB(LCY)"; Rec."Cummulative HELB(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative NHIF(LCY)"; Rec."Cummulative NHIF(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cumm Employer Pension(LCY)"; Rec."Cumm Employer Pension(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative TopUp(LCY)"; Rec."Cummulative TopUp(LCY)")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Gratuity"; Rec."Cummulative Gratuity")
                {
                    ApplicationArea = All;
                }
                field("Cummulative Gratuity(LCY)"; Rec."Cummulative Gratuity(LCY)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}


