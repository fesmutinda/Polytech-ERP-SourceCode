
page 50003 "Payroll Employee P9"
{
    ApplicationArea = All;
    Caption = 'Payroll Employee P9';
    PageType = List;
    SourceTable = "Payroll Employee P9.";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Payroll Period"; Rec."Payroll Period")
                {
                    ToolTip = 'Specifies the value of the Payroll Period field.', Comment = '%';
                }
                field(Allowances; Rec.Allowances)
                {
                    ToolTip = 'Specifies the value of the Allowances field.', Comment = '%';
                }
                field("Basic Pay"; Rec."Basic Pay")
                {
                    ToolTip = 'Specifies the value of the Basic Pay field.', Comment = '%';
                }
                field(Benefits; Rec.Benefits)
                {
                    ToolTip = 'Specifies the value of the Benefits field.', Comment = '%';
                }
                field(Deductions; Rec.Deductions)
                {
                    ToolTip = 'Specifies the value of the Deductions field.', Comment = '%';
                }
                field("Defined Contribution"; Rec."Defined Contribution")
                {
                    ToolTip = 'Specifies the value of the Defined Contribution field.', Comment = '%';
                }
                field("Employee Code"; Rec."Employee Code")
                {
                    ToolTip = 'Specifies the value of the Employee Code field.', Comment = '%';
                }
                field("Gross Pay"; Rec."Gross Pay")
                {
                    ToolTip = 'Specifies the value of the Gross Pay field.', Comment = '%';
                }
                field(HELB; Rec.HELB)
                {
                    ToolTip = 'Specifies the value of the HELB field.', Comment = '%';
                }
                field("Insurance Relief"; Rec."Insurance Relief")
                {
                    ToolTip = 'Specifies the value of the Insurance Relief field.', Comment = '%';
                }
                field(NHIF; Rec.NHIF)
                {
                    ToolTip = 'Specifies the value of the NHIF field.', Comment = '%';
                }
                field(NSSF; Rec.NSSF)
                {
                    ToolTip = 'Specifies the value of the NSSF field.', Comment = '%';
                }
                field("Net Pay"; Rec."Net Pay")
                {
                    ToolTip = 'Specifies the value of the Net Pay field.', Comment = '%';
                }
                field("Owner Occupier Interest"; Rec."Owner Occupier Interest")
                {
                    ToolTip = 'Specifies the value of the Owner Occupier Interest field.', Comment = '%';
                }
                field(PAYE; Rec.PAYE)
                {
                    ToolTip = 'Specifies the value of the PAYE field.', Comment = '%';
                }
                field("Payroll Code"; Rec."Payroll Code")
                {
                    ToolTip = 'Specifies the value of the Payroll Code field.', Comment = '%';
                }
                field(Pension; Rec.Pension)
                {
                    ToolTip = 'Specifies the value of the Pension field.', Comment = '%';
                }
                field("Period Month"; Rec."Period Month")
                {
                    ToolTip = 'Specifies the value of the Period Month field.', Comment = '%';
                }
                field("Period Year"; Rec."Period Year")
                {
                    ToolTip = 'Specifies the value of the Period Year field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
                field(SystemId; Rec.SystemId)
                {
                    ToolTip = 'Specifies the value of the SystemId field.', Comment = '%';
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.', Comment = '%';
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.', Comment = '%';
                }
                field("Tax Charged"; Rec."Tax Charged")
                {
                    ToolTip = 'Specifies the value of the Tax Charged field.', Comment = '%';
                }
                field("Tax Relief"; Rec."Tax Relief")
                {
                    ToolTip = 'Specifies the value of the Tax Relief field.', Comment = '%';
                }
                field("Taxable Pay"; Rec."Taxable Pay")
                {
                    ToolTip = 'Specifies the value of the Taxable Pay field.', Comment = '%';
                }
                field("Value Of Quarters"; Rec."Value Of Quarters")
                {
                    ToolTip = 'Specifies the value of the Value Of Quarters field.', Comment = '%';
                }
            }
        }
    }
}
