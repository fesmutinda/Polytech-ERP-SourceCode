Report 50004 "FOSA Interest Generated"
{
    Caption = 'FOSA Interest Generated';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = Basic, Suite;
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/FOSA Interest Generated.rdlc';

    dataset
    {
        dataitem(InterestBuffer; "Interest Buffer")
        {
            column(DocumentNo; "Account No")
            {
            }
            column(AccountNo; "Account No")
            {
            }
            column(AccountType; "Account Type")
            {
            }
            column(Description; Description)
            {
            }

            column(InterestAmount; "Interest Amount")
            {
            }
            column(InterestDate; "Interest Date")
            {
            }
            column(No; No)
            {
            }
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
