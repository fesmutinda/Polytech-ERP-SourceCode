Report 50018 "Unblock Accounts for Salaries"
{
    ApplicationArea = All;
    Caption = 'Unblock Accounts for Salaries';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem(SalaryProcessingLines; "Salary Processing Lines")
        {
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
