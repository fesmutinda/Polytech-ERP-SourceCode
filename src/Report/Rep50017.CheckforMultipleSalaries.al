Report 50017 "Check for Multiple Salaries"
{
    ApplicationArea = All;
    Caption = 'Check for Multiple Salaries';
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
