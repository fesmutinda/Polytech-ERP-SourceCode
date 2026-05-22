#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56437 "Members List-2026"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Members List-2026.rdlc';

    dataset
    {
        dataitem("Member Register"; Customer)
        {
            RequestFilterFields = "No.", "Employer Code", Gender, "Registration Date", Status, "Current Shares", "Shares Retained";
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
            column(Personal_No; "Member Register"."Personal No")
            {
            }
            column(Registration_Date; Format("Member Register"."Registration Date"))
            {
            }
            column(Share_Capital; "Member Register"."Shares Retained")
            {
            }
            column(Deposits; "Member Register"."Monthly Contribution")
            {
                AutoCalcField = true;
            }
            column(EMail_MembersRegister; "Member Register"."E-Mail")
            {
            }
            column(No_MembersRegister; "Member Register"."No.")
            {
            }
            column(Name_MembersRegister; "Member Register".Name)
            {
            }
            column(Address_MembersRegister; "Member Register".Address)
            {
            }
            column(PhoneNo_MembersRegister; "Member Register"."Phone No.")
            {
            }
            column(RiskFund_MembersRegister; "Member Register"."Risk Fund")
            {
            }
            column(FOSAAccountNo_MembersRegister; "Member Register"."FOSA Account No.")
            {
            }
            column(SharesRetained_MembersRegister; "Member Register"."Shares Retained")
            {
            }
            column(CurrentShares_MembersRegister; "Member Register"."Current Shares")
            {
            }
            column(Status_MembersRegister; "Member Register".Status)
            {
            }
            column(DividendAmount_MembersRegister; "Member Register"."Dividend Amount")
            {
            }
            column(FOSAShares_MembersRegister; "Member Register"."FOSA Shares")
            {
            }
            column(mobile_number; "Member Register"."Mobile Phone No")
            {
            }
            column(id; "Member Register"."ID No.")
            {
            }
            column(branch; "Member Register"."Global Dimension 2 Code")
            {
            }
            column(category; "Member Register"."Account Category")
            {
            }
            column(SN; SN)
            {
            }
            column(Pin_MemberRegister; "Member Register".Pin)
            {
            }
            column(Address_MemberRegister; "Member Register".Address)
            {
            }

            trigger OnAfterGetRecord()
            begin
                "Member Register".CalcFields("Shares Retained", "Current Shares");
                SN := SN + 1
            end;

            trigger OnPreDataItem()
            begin
                Company.Get();
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
}

