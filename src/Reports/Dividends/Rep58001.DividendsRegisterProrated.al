#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 58001 "Dividends Register Prorated"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Dividend Layouts/Dividends Register Prorated.rdl';

    dataset
    {
        dataitem("Dividends Progression Prorated"; "Dividends Progression Prorated")
        {
            RequestFilterFields = "Member No", "Dividend Year";
            column(ReportForNavId_1102755000; 1102755000)
            {
            }
            column(USERID; UserId)
            {
            }
            column(PageNo_Members; CurrReport.PageNo)
            {
            }
            column(Company_Name; Company.Name)
            {
            }
            column(Company_Address; Company.Address)
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(DividendYear_DividendsProgressionProrated; "Dividends Progression Prorated"."Dividend Year")
            {
            }
            column(MemberNo_DividendsProgressionProrated; "Dividends Progression Prorated"."Member No")
            {
            }
            column(StartPeriod_DividendsProgressionProrated; "Dividends Progression Prorated"."Start Period")
            {
            }
            column(EndPeriod_DividendsProgressionProrated; "Dividends Progression Prorated"."End Period")
            {
            }
            column(QualifyingShareCapital_DividendsProgressionProrated; "Dividends Progression Prorated"."Qualifying Share Capital")
            {
            }
            column(GrossDivOnShareCapital_DividendsProgressionProrated; "Dividends Progression Prorated"."Gross Div On Share Capital")
            {
            }
            column(WHTOnShareCapital_DividendsProgressionProrated; "Dividends Progression Prorated"."WHT On Share Capital")
            {
            }
            column(NetDivOnShareCapital_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Div On Share Capital")
            {
            }
            column(QualifyingDeposits_DividendsProgressionProrated; "Dividends Progression Prorated"."Qualifying Deposits")
            {
            }
            column(GrossInterestOnDeposits_DividendsProgressionProrated; "Dividends Progression Prorated"."Gross Interest On Deposits")
            {
            }
            column(WHTOnInterestOnDeposits_DividendsProgressionProrated; "Dividends Progression Prorated"."WHT On Interest On Deposits")
            {
            }
            column(NetInterestOnDeposits_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Interest On Deposits")
            {
            }
            column(QualifyingKhojaShares_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Interest On Deposits")
            {
            }
            column(GrossInterestOnKhojaShares_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Interest On Deposits")
            {
            }
            column(WHTOnInterestOnKhojaShare_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Interest On Deposits")
            {
            }
            column(NetInterestOnKhojaShares_DividendsProgressionProrated; "Dividends Progression Prorated"."Net Interest On Deposits")
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        Company.Get();
        Company.CalcFields(Company.Picture);
    end;

    var
        OpenBalance: Decimal;
        CLosingBalance: Decimal;
        OpenBalanceXmas: Decimal;
        CLosingBalanceXmas: Decimal;
        Cust: Record customer;
        OpeningBal: Decimal;
        ClosingBal: Decimal;
        FirstRec: Boolean;
        PrevBal: Integer;
        BalBF: Decimal;
        LoansR: Record "Loans Register";
        DateFilterBF: Text[150];
        SharesBF: Decimal;
        InsuranceBF: Decimal;
        LoanBF: Decimal;
        PrincipleBF: Decimal;
        InterestBF: Decimal;
        ShowZeroBal: Boolean;
        ClosingBalSHCAP: Decimal;
        ShareCapBF: Decimal;
        RiskBF: Decimal;
        DividendBF: Decimal;
        Company: Record "Company Information";
        OpenBalanceHse: Decimal;
        CLosingBalanceHse: Decimal;
        OpenBalanceDep1: Decimal;
        CLosingBalanceDep1: Decimal;
        OpenBalanceDep2: Decimal;
        CLosingBalanceDep2: Decimal;
        HseBF: Decimal;
        Dep1BF: Decimal;
        Dep2BF: Decimal;
        OpeningBalInt: Decimal;
        ClosingBalInt: Decimal;
        InterestPaid: Decimal;
        SumInterestPaid: Decimal;
        OpenBalanceRisk: Decimal;
        CLosingBalanceRisk: Decimal;
        OpenBalanceDividend: Decimal;
        ClosingBalanceDividend: Decimal;
        OpenBalanceHoliday: Decimal;
        ClosingBalanceHoliday: Decimal;
        LoanSetup: Record "Loan Products Setup";
        LoanName: Text[50];
        SaccoEmp: Record "Sacco Employers";
        EmployerName: Text[100];
}

