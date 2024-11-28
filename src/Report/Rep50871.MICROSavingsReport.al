#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50871 "MICRO Savings Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/MICROSavingsReport.rdlc';

    dataset
    {
        dataitem("Members Register"; Customer)
        {
            DataItemTableView = where("Customer Posting Group" = const('MICRO'),
                            "Group Account" = filter(false));
            // RequestFilterFields = "Group Account No", "Date Filter";
            column(ReportForNavId_1000000000; 1000000000)
            {
            }
            column(GroupAccountName_MembersRegister; "Members Register"."Group Account Name")
            {
            }
            // column(GroupAccountNo_MembersRegister; "Members Register"."Group Account No")
            // {
            // }
            column(LoanOfficerName_MembersRegister; "Members Register"."Loan Officer Name")
            {
            }
            column(CurrentShares_MembersRegister; "Members Register"."Current Shares")
            {
            }
            column(No_MembersRegister; "Members Register"."No.")
            {
            }
            column(Name_MembersRegister; "Members Register".Name)
            {
            }
            column(CompanyName; Company.Name)
            {
            }
            column(CompanyAddress; Company.Address)
            {
            }
            column(CompanyPic; Company.Picture)
            {
            }
            column(CountRec; CountRec)
            {
            }

            trigger OnAfterGetRecord()
            begin
                CountRec := CountRec + 1;
            end;

            trigger OnPreDataItem()
            begin
                "Members Register".SetFilter("Members Register"."Group Account", GroupFilter);
                "Members Register".SetFilter("Members Register"."Date Filter", DateFilter);
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
        //.....................................................
        DateFilter := "Members Register".GetFilter("Members Register"."Date Filter");
        if DateFilter = '' then begin
            DateFilter := '..' + Format(Today);
        end;
        GroupFilter := "Members Register".GetFilter("Members Register"."Group Account");

    end;

    var
        Company: Record "Company Information";
        CountRec: Integer;
        DateFilter: text;
        GroupFilter: text;
}

