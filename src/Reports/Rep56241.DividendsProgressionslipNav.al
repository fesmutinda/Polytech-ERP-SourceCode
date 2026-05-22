#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56241 "Dividends Progressionslip Nav"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Nav Layouts/Dividends Progressionslip.rdlc';

    dataset
    {
        dataitem("Member Register"; Customer)
        {
            DataItemTableView = sorting("No.") where("Customer Type" = const(Member));
            RequestFilterFields = "No.";
            column(ReportForNavId_7301; 7301)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Members__No__; "No.")
            {
            }
            column(Members__Payroll_Staff_No_; "Personal No")
            {
            }
            column(Members_Name; Name)
            {
            }
            column(IDNo_MembersRegister; "Member Register"."ID No.")
            {
            }
            column(Dividends_ProgressionCaption; Dividends_ProgressionCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Members__No__Caption; FieldCaption("No."))
            {
            }
            column(Members__Payroll_Staff_No_Caption; FieldCaption("Personal No"))
            {
            }
            column(Members_NameCaption; FieldCaption(Name))
            {
            }
            column(Dividends_Progression_SharesCaption; "Dividends Progression".FieldCaption(Shares))
            {
            }
            column(Dividends_Progression__Qualifying_Shares_Caption; "Dividends Progression".FieldCaption("Qualifying Shares"))
            {
            }
            column(Dividends_Progression__Net_Dividends_Caption; "Dividends Progression".FieldCaption("Net Dividends"))
            {
            }
            column(Dividends_Progression__Witholding_Tax_Caption; "Dividends Progression".FieldCaption("Witholding Tax"))
            {
            }
            column(Dividends_Progression__Gross_Dividends_Caption; "Dividends Progression".FieldCaption("Gross Dividends"))
            {
            }
            column(Dividends_Progression_DateCaption; "Dividends Progression".FieldCaption(Date))
            {
            }
            column(Company_Name; Company.Name)
            {
            }
            column(Company_Address; Company.Address)
            {
            }
            column(Company_Address_2; Company."Address 2")
            {
            }
            column(Company_Phone_No; Company."Phone No.")
            {
            }
            column(Company_Fax_No; Company."Fax No.")
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(Company_Email; Company."E-Mail")
            {
            }
            column(DividendPercentage; "VarDivided%")
            {
            }
            column(InterestPercentage; "VarInterest%")
            {
            }
            column(WithTaxPercentage; "VarWithTax%")
            {
            }
            dataitem("Dividends Progression"; "Dividends Progression")
            {
                DataItemLink = "Member No" = field("No.");
                DataItemTableView = sorting(Date);
                column(ReportForNavId_2020; 2020)
                {
                }
                column(Dividends_Progression_Date; Format(Date))
                {
                }
                column(Dividends_Progression__Gross_Dividends_; "Gross Dividends")
                {
                }
                column(Dividends_Progression__Witholding_Tax_; "Witholding Tax")
                {
                }
                column(Dividends_Progression__Net_Dividends_; ROUND("Net Dividends", 1, '<'))
                {
                }
                column(Dividends_Progression__Qualifying_Shares_; ROUND("Qualifying Shares", 1, '<'))
                {
                }
                column(Dividends_Progression_Shares; Shares)
                {
                }
                column(Dividends_Progression__Net_Dividends__Control1000000026; "Net Dividends")
                {
                }
                column(Dividends_Progression__Witholding_Tax__Control1000000027; "Witholding Tax")
                {
                }
                column(Dividends_Progression__Gross_Dividends__Control1000000028; "Gross Dividends")
                {
                }
                column(Dividends_Progression__Qualifying_Shares__Control1000000029; "Qualifying Shares")
                {
                }
                column(Dividends_Progression_Shares_Control1000000030; Shares)
                {
                }
                column(Dividends_Progression_Member_No; "Member No")
                {
                }
                column(QualifyingShareCapital_DividendsProgression; "Dividends Progression"."Qualifying Share Capital")
                {
                }
                column(ShareCapital_DividendsProgression; "Dividends Progression"."Share Capital")
                {
                }
                column(GrossInterestOnDeposit_DividendsProgression; "Dividends Progression"."Gross Interest On Deposit")
                {
                }
                column(TotalGrossDividend; ROUND("Dividends Progression"."Gross Interest On Deposit" + "Gross Dividends", 1, '<'))
                {
                }
                dataitem("Sacco General Set-Up"; "Sacco General Set-Up")
                {
                    column(ReportForNavId_1000000024; 1000000024)
                    {
                    }
                    column(Dividend_Percentage; "Sacco General Set-Up"."Dividend (%)")
                    {
                    }
                    column(Interest_on_Deposits; "Sacco General Set-Up"."Interest on Deposits (%)")
                    {
                    }
                    column(Withholding_Tax; "Sacco General Set-Up"."Withholding Tax (%)")
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                ObjGensetup.Get();
                "VarDivided%" := ObjGensetup."Dividend (%)";
                "VarInterest%" := ObjGensetup."Interest on Deposits (%)";
                "VarWithTax%" := ObjGensetup."Withholding Tax (%)";
            end;

            trigger OnPreDataItem()
            begin
                Company.Get();
                Company.CalcFields(Company.Picture);
            end;
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

    var
        Dividends_ProgressionCaptionLbl: label 'Dividends Progression';
        CurrReport_PAGENOCaptionLbl: label 'Page';
        Company: Record "Company Information";
        "VarInterest%": Decimal;
        "VarDivided%": Decimal;
        ObjGensetup: Record "Sacco General Set-Up";
        "VarWithTax%": Decimal;
}

