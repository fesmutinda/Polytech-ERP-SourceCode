#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50432 "Fixed Deposit Receipt"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Fixed Deposit Receipt.rdlc';

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            column(ReportForNavId_1000000000; 1000000000)
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CompanyPic; CompInfo.Picture)
            {
            }
            column(tODAYSdATE; Format(Today, 0, 4))
            {
            }
            column(Name; UpperCase(Vendor.Name))
            {
            }
            column(Balance; Vendor.Balance)
            {
            }
            column(MaturityDate; Format(Vendor."FD Maturity Date", 0, 4))
            {
            }
            column(FixedType; Vendor."Fixed Deposit Type")
            {
            }
            column(FDRate; FixedRate)
            {
            }
            column(NumberText_1_; NumberText[1])
            {
            }
            column(ID_No; Vendor."ID No.")
            {
            }
            column(No; Vendor."No.")
            {
            }
            column(CompName; CompInfo.Name)
            {
            }
            column(RegistrationDate_Vendor; Format(Vendor."Registration Date"))
            {
            }
            column(NegInterestRate_Vendor; Vendor."Neg. Interest Rate")
            {
            }

            trigger OnAfterGetRecord()
            begin
                /*FixedRate:=0;
                FDCalcRules.RESET;
                
                REPEAT
                IF (Vendor.Balance>=FDCalcRules."Minimum Amount") AND (Vendor.Balance<=FDCalcRules."Maximum Amount") THEN
                FixedRate:=FDCalcRules."Interest Rate";
                UNTIL
                FDCalcRules.NEXT=0;
                */

                Vendor.CalcFields(Vendor."Balance (LCY)");

                //Amount into words
                CheckReport.InitTextVariable;
                CheckReport.FormatNoText(NumberText, Vendor."Balance (LCY)", '');

            end;

            trigger OnPreDataItem()
            begin
                CompInfo.Get;
                CompInfo.CalcFields(CompInfo.Picture);
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
        CompInfo: Record "Company Information";
        FixedRate: Decimal;
        FDCalcRules: Record "FD Interest Calculation Crite";// Interest Calculation Criter";
        CheckReport: Report Check;
        NumberText: array[2] of Text[120];
}

