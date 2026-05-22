#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 58002 "Prorated Dividends Summary"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Dividend Layouts/Prorated Dividends Summary.rdl';

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            column(ReportForNavId_1120054000; 1120054000)
            {
            }
            column(QualifyingShares; QualifyingShares)
            {
            }
            column(GrossShares; GrossShares)
            {
            }
            column(WTXOnDividends; WTXOnDividends)
            {
            }
            column(NetDividends; NetDividends)
            {
            }
            column(QualifyingDeposits; QualifyingDeposits)
            {
            }
            column(GrossDeposits; GrossDeposits)
            {
            }
            column(WTXOnDeposits; WTXOnDeposits)
            {
            }
            column(NetDeposits; NetDeposits)
            {
            }
            column(QualifyingKhoja; NetDeposits)
            {
            }
            column(GrossKhoja; NetDeposits)
            {
            }
            column(WTXOnKhoja; NetDeposits)
            {
            }
            column(NetKhoja; NetDeposits)
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
            column(No_MembersRegister; customer."No.")
            {
            }

            trigger OnAfterGetRecord()
            begin
                MembersReg.Reset;
                MembersReg.SetRange(MembersReg."No.", customer."No.");
                MembersReg.SetFilter(MembersReg."Date Filter", '%1..%2', 0D, DividendYearEndingDate);
                MembersReg.SetAutocalcFields(MembersReg."Current Shares", MembersReg."Shares Retained");
                if MembersReg.Find('-') then begin
                    repeat
                        QualifyingShares := 0;
                        QualifyingShares := MembersReg."Shares Retained";
                        GrossShares := 0;
                        WTXOnDividends := 0;
                        NetDividends := 0;
                        QualifyingDeposits := 0;
                        QualifyingDeposits := MembersReg."Current Shares";
                        GrossDeposits := 0;
                        WTXOnDeposits := 0;
                        NetDeposits := 0;
                        DividendsProgressionProrated.Reset;
                        DividendsProgressionProrated.SetRange(DividendsProgressionProrated."Member No", MembersReg."No.");
                        DividendsProgressionProrated.SetRange(DividendsProgressionProrated."Dividend Year", Format(Date2dmy(DividendYearEndingDate, 3)));
                        if DividendsProgressionProrated.Find('-') then begin
                            repeat
                                //.........................Share Capital
                                //QualifyingShares+=DividendsProgressionProrated."Qualifying Share Capital";
                                GrossShares += DividendsProgressionProrated."Gross Div On Share Capital";
                                WTXOnDividends += DividendsProgressionProrated."WHT On Share Capital";
                                NetDividends += DividendsProgressionProrated."Net Div On Share Capital";
                                //.........................Deposit Contributions
                                // QualifyingDeposits+=DividendsProgressionProrated."Qualifying Deposits";
                                GrossDeposits += DividendsProgressionProrated."Gross Interest On Deposits";
                                WTXOnDeposits += DividendsProgressionProrated."WHT On Interest On Deposits";
                                NetDeposits += DividendsProgressionProrated."Net Interest On Deposits";
                            until DividendsProgressionProrated.Next = 0;
                        end;
                    until MembersReg.Next = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                QualifyingShares := 0;
                GrossShares := 0;
                WTXOnDividends := 0;
                NetDividends := 0;
                QualifyingDeposits := 0;
                GrossDeposits := 0;
                WTXOnDeposits := 0;
                NetDeposits := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(DividendYearEndingDate; DividendYearEndingDate)
                {
                    ApplicationArea = Basic;
                    Caption = 'Dividend End Date';
                }
            }
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
        DividendsProgressionProrated: Record "Dividends Progression Prorated";
        MembersReg: Record Customer;
        QualifyingShares: Decimal;
        GrossShares: Decimal;
        WTXOnDividends: Decimal;
        NetDividends: Decimal;
        QualifyingDeposits: Decimal;
        GrossDeposits: Decimal;
        WTXOnDeposits: Decimal;
        NetDeposits: Decimal;
        Company: Record "Company Information";
        DividendYearEndingDate: Date;
}

