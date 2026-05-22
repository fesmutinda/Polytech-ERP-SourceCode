#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56602 "Dividend Payment Batch"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Nav Layouts/Dividend Payment Batch.rdlc';

    dataset
    {
        dataitem(UnknownTable51516099; "Dividends Registerd")
        {
            RequestFilterFields = Processed;
            column(ReportForNavId_13; 13)
            {
            }
            dataitem("Member Register"; Customer)
            {
                DataItemLink = "No." = field("Member No");
                DataItemTableView = where("Dividend Amount" = filter(> 0));
                RequestFilterFields = "No.", "Bank Account No.", "Bank Branch Code", "Employer Code";
                column(ReportForNavId_1; 1)
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
                column(PaymentMethod; PaymentMethod)
                {
                }
                column(Type; Type)
                {
                }
                column(Currency; Currency)
                {
                }
                column(DRAcc; DRAcc)
                {
                }
                column(No_MemberRegister; "Member Register"."No.")
                {
                }
                column(Name_MemberRegister; "Member Register".Name)
                {
                }
                column(BankAccountNo_MemberRegister; "Member Register"."Bank Account No.")
                {
                }
                column(BankBranchCode_MemberRegister; "Member Register"."Bank Branch Code")
                {
                }
                column(BankCode_MemberRegister; "Member Register"."Bank Branch Code")
                {
                }
                column(DividendAmount_MemberRegister; "Member Register"."Dividend Amount")
                {
                }
                column(PersonalNo_MemberRegister; "Member Register"."Personal No")
                {
                }
                column(SN_No; SN)
                {
                }
                column(MobilePhoneNo_MemberRegister; "Member Register"."Mobile Phone No")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    PaymentMethod := 'Corporate salary transfer';
                    Currency := 'KES';
                    Type := 'Dividends';
                    GenSetUp.Get();
                    //DRAcc:=GenSetUp."Loan Current Account DR";
                    SN := SN + 1;
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
        Company.Get();
        Company.CalcFields(Company.Picture);
    end;

    var
        Company: Record "Company Information";
        PaymentMethod: Text;
        Currency: Text;
        Type: Text;
        DRAcc: Code[30];
        GenSetUp: Record "Sacco General Set-Up";
        SN: Integer;
}

