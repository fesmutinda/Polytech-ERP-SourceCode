Report 51026 "Member Account Statement"
{
    ApplicationArea = All;
    Caption = 'Member Account Statement';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './Layouts/MemberAccountStatement.rdl';
    dataset
    {
        dataitem(MembersRegister; Customer)
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
