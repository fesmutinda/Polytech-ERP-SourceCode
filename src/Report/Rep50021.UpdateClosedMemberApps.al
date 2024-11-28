Report 50021 "Update Closed Member Apps"
{
    Caption = 'Update Closed Member Applications';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/get pictures.rdlc';

    dataset
    {

        dataitem(MembershipApplications; "Membership Applications")
        {
            PrintOnlyIfDetail = false;
            trigger OnAfterGetRecord()
            var
                customer: Record Customer;
            begin
                MemberApps.Reset();
                MemberApps.SetRange(MemberApps."No.", MembershipApplications."No.");
                if MemberApps.Find('-') then begin
                    repeat
                        customer.Reset();
                        customer.SetRange(customer."ID No.", MemberApps."ID No.");
                        if customer.Find('-') then begin
                            MemberApps.Status := MemberApps.Status::Closed;
                            MemberApps.Modify();
                        end;
                    until MemberApps.next = 0;
                end;
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
    var
        MemberApps: Record "Membership Applications";
}
