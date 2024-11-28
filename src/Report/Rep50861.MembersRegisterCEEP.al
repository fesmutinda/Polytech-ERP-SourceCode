#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50861 "Members Register-CEEP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Members Register-CEEP.rdlc';

    dataset
    {
        dataitem("Members Register"; Customer)
        {
            DataItemTableView = sorting("No.") order(ascending) where("Global Dimension 1 Code" = filter('MICRO'), "Group Account" = filter(false));
            // RequestFilterFields = "No.", "Business Loan Officer", "Outstanding Balance", "Group Account No", "Date Filter", "Outstanding Interest", "Loan Officer Name";

            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
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
            column(Company_Address2; Company."Address 2")
            {
            }
            column(Company_PhoneNo; Company."Phone No.")
            {
            }
            column(No; "RNo.")
            {
            }
            column(Company_Email; Company."E-Mail")
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(USERID; UserId)
            {
            }
            column(No_MembersRegister; "Members Register"."No.")
            {
            }
            column(Name_MembersRegister; "Members Register".Name)
            {
            }
            column(Address_MembersRegister; "Members Register".Address)
            {
            }
            column(City_MembersRegister; "Members Register".City)
            {
            }
            column(PhoneNo_MembersRegister; "Members Register"."Phone No.")
            {
            }
            column(BusinessLoanOfficer_MembersRegister; "Members Register"."Business Loan Officer")
            {
            }
            column(CurrentShares_MembersRegister; "Members Register"."Current Shares")
            {
            }
            column(OutstandingBalance_MembersRegister; "Members Register"."Outstanding Balance")
            {
            }
            column(Status_MembersRegister; "Members Register".Status)
            {
            }
            column(FOSAAccount_MembersRegister; "Members Register"."FOSA Account")
            {
            }
            column(IDNo_MembersRegister; "Members Register"."ID No.")
            {
            }
            column(SharesRetained_MembersRegister; "Members Register"."Shares Retained")
            {
            }
            column(GroupAccount_MembersRegister; "Members Register"."Group Account")
            {
            }
            column(GroupAccountName_MembersRegister; "Members Register"."Group Account Name")
            {
            }
            column(MICROOutstandingBalance_MembersRegister; "Members Register"."MICRO Outstanding Balance")
            {
            }
            // column(GroupAccountNo_MembersRegister; "Members Register"."Group Account No")
            // {
            // }
            column(DateIssued; DateIssued)
            {
            }
            column(ApprovedAmt; ApprovedAmt)
            {
            }
            column(OutstandingInterest_MembersRegister; "Members Register"."Outstanding Interest")
            {
            }

            trigger OnAfterGetRecord()
            var
                paramoption: Option IssuedDate,ApprovedAmount;
            begin
                "RNo." := "RNo." + 1;
                DateIssued := FnGetLoanIssuedDate("Members Register"."No.");
                ApprovedAmt := FnGetLoanApprovedAmount("Members Register"."No.");
            end;

            trigger OnPreDataItem()
            begin
                DateFilter := GetFilter("Members Register"."Date Filter");
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
        Company: Record "Company Information";
        "RNo.": Integer;
        DateIssued: Date;
        DateFilter: Text[100];
        ApprovedAmt: Decimal;

    local procedure FnGetLoanIssuedDate(MemberNo: Code[100]): Date
    var
        ObjLoans: Record "Loans Register";
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Client Code", MemberNo);
        ObjLoans.SetFilter(ObjLoans."Loan Product Type", 'CEEP NEW');
        ObjLoans.SetFilter(ObjLoans."Date filter", DateFilter);
        if ObjLoans.Find('-') then begin
            repeat
                ObjLoans.CalcFields(ObjLoans."Outstanding Balance");
                if ObjLoans."Outstanding Balance" > 0 then
                    exit(ObjLoans."Issued Date");
            until ObjLoans.Next = 0;
        end
    end;

    local procedure FnGetLoanApprovedAmount(MemberNo: Code[100]): Decimal
    var
        ObjLoans: Record "Loans Register";
    begin
        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Client Code", MemberNo);
        ObjLoans.SetFilter(ObjLoans."Loan Product Type", 'CEEP NEW');
        ObjLoans.SetFilter(ObjLoans."Date filter", DateFilter);
        if ObjLoans.Find('-') then begin
            repeat
                ObjLoans.CalcFields(ObjLoans."Outstanding Balance");
                if ObjLoans."Outstanding Balance" > 0 then
                    exit(ObjLoans."Approved Amount");
            until ObjLoans.Next = 0;
        end
    end;
}

