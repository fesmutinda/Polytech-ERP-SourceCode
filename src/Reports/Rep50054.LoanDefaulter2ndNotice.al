#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50054 "Loan Defaulter 2nd Notice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/LoanDefaulter_2ndNotice.rdl';

    dataset
    {
        dataitem("Loans Register"; "Loans Register")
        {
            RequestFilterFields = "Client Code", "Loan  No.", "Loans Category-SASRA";
            column(ReportForNavId_1102755000; 1102755000)
            {
            }
            column(OutstandingBalance_Loans; "Loans Register"."Outstanding Balance")
            {
            }
            column(LoanNo_Loans; "Loans Register"."Loan  No.")
            {
            }
            column(ClientName_Loans; "Loans Register"."Client Name")
            {
            }
            column(LoanProductType_LoansRegister; "Loans Register"."Loan Product Type")
            {
            }
            column(LoanProductTypeName_LoansRegister; "Loans Register"."Loan Product Type Name")
            {
            }
            column(ClientCode_Loans; "Loans Register"."Client Code")
            {
            }

            column(LoanNo_LoansPrinciple; "Loans Register"."Approved Amount")
            {
            }
            column(LoanNo_LoanDate; "Loans Register"."Issued Date")
            {
            }
            column(LoanNo_LoanPeriod; "Loans Register"."Instalment Period")
            {
            }
            column(LoanNo_LoanPeriodInt; "Loans Register".Installments)
            {
            }
            column(recoverNoticedate; recoverNoticedate)
            {
            }

            dataitem("Members Register"; Customer)
            {
                DataItemLink = "No." = field("Client Code");
                column(ReportForNavId_1102755005; 1102755005)
                {
                }
                column(City_Members; "Members Register".City)
                {
                }
                column(Address2_Members; "Members Register"."Address 2")
                {
                }
                column(Address_Members; "Members Register".Address)
                {
                }
                column(DOCNAME; DOCNAME)
                {
                }
                column(CName; CompanyInfo.Name)
                {
                }
                column(Caddress; CompanyInfo.Address)
                {
                }
                column(CmobileNo; CompanyInfo."Phone No.")
                {
                }
                column(clogo; CompanyInfo.Picture)
                {
                }
                column(Cwebsite; CompanyInfo."Home Page")
                {
                }
                column(Email; CompanyInfo."E-Mail")
                {
                }
                column(loansOFFICER; Lofficer)
                {
                }
                dataitem("Default Notices Register"; "Default Notices Register")
                {
                    DataItemLink = "Member No" = field("No.");
                    column(Loan_Outstanding_Balance; "Loan Outstanding Balance")
                    {
                    }
                    column(Outstanding_Interest_DefaultNoticesRegister; "Default Notices Register"."Outstanding Interest")
                    {
                    }
                    column(AmountInArrears_DefaultNoticesRegister; "Default Notices Register"."Amount In Arrears")
                    {
                    }
                    column(DaysInArrears_DefaultNoticesRegister; "Default Notices Register"."Days In Arrears")
                    {
                    }

                }
                trigger OnAfterGetRecord()
                begin
                    // workString := CONVERTSTR(Customer.Name, ' ', ',');
                    // DearM := SELECTSTR(1, workString);
                    // //LastPDate := 0D;
                    // Balance := 0;
                    // SharesB := 0;
                end;
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
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        DOCNAME := 'SECOND DEMAND NOTICE';
        Lofficer := UserId;
    end;

    var
        DOCNAME: Text[30];
        CompanyInfo: Record "Company Information";
        Lofficer: Text;
        recoverNoticedate: Date;
}

