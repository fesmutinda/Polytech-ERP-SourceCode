#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56294 "Recruited By List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Recruited By List.rdlc';

    dataset
    {
        dataitem("Member Register"; Customer)
        {
            RequestFilterFields = "Recruited By", "Registration Date";
            column(ReportForNavId_1; 1)
            {
            }
            column(Address_MemberRegister; "Member Register".Address)
            {
            }
            column(Address2_MemberRegister; "Member Register"."Address 2")
            {
            }
            column(City_MemberRegister; "Member Register".City)
            {
            }
            column(Contact_MemberRegister; "Member Register".Contact)
            {
            }
            column(PhoneNo_MemberRegister; "Member Register"."Phone No.")
            {
            }
            column(TelexNo_MemberRegister; "Member Register"."Telex No.")
            {
            }
            column(OurAccountNo_MemberRegister; "Member Register"."Our Account No.")
            {
            }
            column(No_MemberRegister; "Member Register"."No.")
            {
            }
            column(Gender_MemberRegister; "Member Register".Gender)
            {
            }
            column(Name_MemberRegister; "Member Register".Name)
            {
            }
            column(EMail_MemberRegister; "Member Register"."E-Mail")
            {
            }
            column(RecruitedBy_MemberRegister; "Member Register"."Recruited By")
            {
            }
            column(RejoiningDate_MemberRegister; "Member Register"."Rejoining Date")
            {
            }
            column(ApplicationMethod_MemberRegister; "Member Register"."Application Method")
            {
            }
            column(ApplicationDate_MemberRegister; "Member Register"."Application Date")
            {
            }
            column(EmployerCode_MemberRegister; "Member Register"."Employer Code")
            {
            }
            column(RegistrationDate_MemberRegister; "Member Register"."Registration Date")
            {
            }
            column(run; run)
            {
            }
            column(COMPANYNAME; COMPANYNAME)
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
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(RecruiterName_MemberRegister; "Member Register"."Recruiter Name")
            {
            }

            trigger OnAfterGetRecord()
            begin
                run := run + 1;
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

    trigger OnPreReport()
    begin
        Company.Get();
        Company.CalcFields(Company.Picture);
    end;

    var
        run: Integer;
        Company: Record "Company Information";
}

