#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50063 "Next of Kin Details2 Report"
{
    //DefaultLayout = RDLC;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './Layouts/NextofKinDetailsReport2.rdl';

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            column(ReportForNavId_1000000000; 1000000000)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(Company_Address; Company.Address)
            {
            }
            column(Company_Address2; Company."Address 2")
            {
            }
            column(Company_PhoneNo; Company."Phone No.")
            {
            }
            column(Company_Email; Company."E-Mail")
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(No_; "No.")
            {
            }
            column(CustName; Name)
            {
            }
            column(Phone_No_; "Phone No.")
            {
            }




            column(SN; SN)
            {
            }

            // column(RefereeMemberNo_Customer;Customer."Referee Member No")
            // {
            // }
            // column(RefereeName_Customer;Customer."Referee Name")
            // {
            // }
            column(RegistrationDate_Customer; Customer."Registration Date")
            {
            }
            dataitem("Members Nominee"; "Members Nominee")
            {
                DataItemLink = "Account No" = field("No.");
                column(ReportForNavId_12; 12)
                {
                }
                column(Account_No; "Members Nominee"."Account No")
                {
                }
                column(Name; "Members Nominee".Name)
                {
                }
                column(Total_Allocation; "Members Nominee"."Total Allocation")
                {
                }
                column(Relationship; "Members Nominee".Relationship)
                {
                }
                column(Telephone; "Members Nominee".Telephone)
                {
                }



            }

            trigger OnAfterGetRecord()
            begin
                SN := SN + 1;
                // IF EmployersRec.GET(Customer."Employer Code") THEN BEGIN
                //  Customer."Employer Name":=EmployersRec."Employer Name";
                //  END;
            end;

            trigger OnPreDataItem()
            begin
                Company.Get();
                company.CalcFields(Company.Picture);
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
        Company: Record "Company Information";
        SN: Integer;
    // EmployersRec: Record UnknownRecord51516355;
}

