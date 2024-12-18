Report 50050 MembershipApplicationReport
{
    ApplicationArea = All;
    Caption = 'Membership Application Report';
    RDLCLayout = './Layouts/MembershipApplicationReport.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("Membership Applications"; "Membership Applications")
        {
            DataItemTableView = sorting("No.") order(descending);
            RequestFilterFields = Status;
            column(CompanyName; CompanyInfo.Name)
            {
            }
            column(CompanyAddress; CompanyInfo.Address)
            {
            }
            column(CompanyPhone; CompanyInfo."Phone No.")
            {
            }
            column(CompanyPic; CompanyInfo.Picture)
            {
            }
            column(CompanyEmail; CompanyInfo."E-Mail")
            {
            }
            column(No; "No.")
            { }
            column(Name; Name)
            { }
            column(ID_No_; "ID No.")
            { }
            column(EntryNo; EntryNo)
            { }
            column(Mobile_Phone_No; "Mobile Phone No")
            { }




            trigger OnAfterGetRecord();
            var
            begin

                ;
                EntryNo := EntryNo + 1;
            end;

        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    trigger OnPreReport()
    begin
        CompanyInfo.Get();
        CompanyInfo.CALCFIELDS(CompanyInfo.Picture);
        Datefilter := TbMembRegister.GetFilter("Date Filter");

    end;


    var
        CompanyInfo: Record "Company Information";
        EntryNo: Integer;
        Sharecapital: Decimal;
        Datefilter: Text[100];
        TbMembRegister: Record Customer;
        Gensetup: Record "Sacco General Set-Up";
}
