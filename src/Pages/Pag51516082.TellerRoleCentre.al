#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516082 "Teller Role Centre"
{
    Caption = 'Role Center';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(Control1000000018; "Member List")
            {
            }
            group(Control1000000015)
            {
            }
            part(Control1000000001; "Copy Profile")
            {
            }
            systempart(Control1000000000; MyNotes)
            {
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Member Balances")
            {
                ApplicationArea = Basic;
                Caption = 'Member Balances';
                Image = "Report";
                RunObject = Report 51516362;
            }
            action("Member Statement")
            {
                ApplicationArea = Basic;
                Caption = 'Member Statement';
                Image = "Report";
                RunObject = Report 51516223;
            }
            action("Member Guarantors")
            {
                ApplicationArea = Basic;
                Caption = 'Member Guarantors';
                Image = "Report";
                RunObject = Report 51516482;
            }
            action("Credit Loans Register-CFC")
            {
                ApplicationArea = Basic;
                Caption = 'Credit Loans Register-CFC';
                Image = Register;
                RunObject = Report 51516372;
            }
            action("Credit Loans Register-Board")
            {
                ApplicationArea = Basic;
                Caption = 'Credit Loans Register-Board';
                Image = Register;
                RunObject = Report 51516530;
            }
            action("Members Loan Register")
            {
                ApplicationArea = Basic;
                Caption = 'Members Loan Register';
                Image = "Report";
                RunObject = Report 51516370;
            }
            action("Loans Guaranteed")
            {
                ApplicationArea = Basic;
                Caption = 'Loans Guaranteed';
                Image = "Report";
                RunObject = Report 51516484;
            }
            action("Loans Repayment Schedule")
            {
                ApplicationArea = Basic;
                Caption = 'Loans Repayment Schedule';
                Image = "Report";
                RunObject = Report 51516477;
            }
            action("Loans Batch Schedule")
            {
                ApplicationArea = Basic;
                Caption = 'Loans Batch Schedule';
                Image = "Report";
                RunObject = Report 51516485;
            }
            action("Loans Appraisal")
            {
                ApplicationArea = Basic;
                Caption = 'Loans Appraisal';
                Image = "Report";
                RunObject = Report 51516384;
            }
            action("Loan Balances")
            {
                ApplicationArea = Basic;
                Caption = 'Loan Balances';
                Image = "Report";
                RunObject = Report 51516451;
            }
            action("Loans Defaulter Aging")
            {
                ApplicationArea = Basic;
                Caption = 'Loans Defaulter Aging';
                Image = "Report";
                RunObject = Report 51516400;
            }
            separator(Action1000000009)
            {
                Caption = 'Dividends';
            }
            action("Prorated Dividends Processing")
            {
                ApplicationArea = Basic;
                Caption = 'Prorated Dividends Processing';
                Image = "Report";
                RunObject = Report 51516378;
            }
            action("Flat Rate Dividends Processing")
            {
                ApplicationArea = Basic;
                Caption = 'Flat Rate Dividends Processing';
                Image = "Report";
                RunObject = Report 51516379;
            }
            action("Dividends Register")
            {
                ApplicationArea = Basic;
                Caption = 'Dividends Register';
                Image = "Report";
                RunObject = Report 51516377;
            }
            action("Dividends Progression")
            {
                ApplicationArea = Basic;
                Caption = 'Dividends Progression';
                Image = "Report";
                RunObject = Report 51516241;
            }
            separator(Action1000000019)
            {
            }
            action("Checkoff Main")
            {
                ApplicationArea = Basic;
                Caption = 'Checkoff Main';
                RunObject = Report 51516409;
            }
        }
        area(embedding)
        {
            action("Chart of Accounts")
            {
                ApplicationArea = Basic;
                Caption = 'Chart of Accounts';
                RunObject = Page "Chart of Accounts";
            }
            action(Vendors)
            {
                ApplicationArea = Basic;
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Vendor List";
            }
            action(Balance)
            {
                ApplicationArea = Basic;
                Caption = 'Balance';
                Image = Balance;
                RunObject = Page "Vendor List";
                RunPageView = where("Balance (LCY)" = filter(<> 0));
            }
        }
        area(sections)
        {
            group(Members)
            {
                Caption = 'Members';
                Image = Journals;
                action("Member List")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member List';
                    RunObject = Page "Member List";
                }
            }
            group("Members Regiatration")
            {
                Caption = 'Members Regiatration';
                Image = Journals;
                action(jjj)
                {
                    ApplicationArea = Basic;
                    Caption = 'Individual/Joint Application list';
                    RunObject = Page "Membership Application List";
                }
            }
            group("FOSA Savings Product")
            {
                Caption = 'FOSA Savings Product';
                Image = Journals;
                action("FOSA Product Applications")
                {
                    ApplicationArea = Basic;
                    Caption = 'FOSA Product Applications';
                    RunObject = Page "Mwanangu Applications List";
                }
                action("Savings product list")
                {
                    ApplicationArea = Basic;
                    Caption = 'Savings product list';
                    RunObject = Page "FOSA Accounts Details Master";
                }
            }
            group("Common Requisitions")
            {
                Caption = 'Common Requisitions';
                Image = FixedAssets;
                action("Leave Application")
                {
                    ApplicationArea = Basic;
                    Caption = 'Leave Application';
                    RunObject = Page "HR Leave Applications List";
                }
                action("Imprest Requisition")
                {
                    ApplicationArea = Basic;
                    Caption = 'Imprest Requisition';
                    RunObject = Page "Imprest List";
                }
                action("Store Requisitions")
                {
                    ApplicationArea = Basic;
                    Caption = 'Store Requisitions';
                    RunObject = Page "Open Store Requisitions List";
                }
            }
            group("Cashier Transactions")
            {
                Caption = 'Cashier Transactions';
                action("Cashier Transactions - List")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cashier Transactions - List';
                    RunObject = Page "Cashier Transactions - List";
                }
                action("<Page Cashier Transactions - Lis")
                {
                    ApplicationArea = Basic;
                    Caption = 'Posted Cashier Transactions - List';
                    RunObject = Page "Posted Cashier Transactions";
                }
            }
            group("Teller/Treasury Management")
            {
                Caption = 'Teller/Treasury Management';
                action("Teller & Treasury Trans List")
                {
                    ApplicationArea = Basic;
                    Caption = 'Teller & Treasury Trans List';
                    RunObject = Page "Teller & Treasury Trans List";
                }
                action(Action1000000004)
                {
                    ApplicationArea = Basic;
                    Caption = 'Teller & Treasury Trans List';
                    RunObject = Page "Teller Till List";
                }
            }
            group("Document Approvals")
            {
                Caption = 'Document Approvals';
                action("Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Approval Request';
                    Image = Approvals;
                    RunObject = Page "Requests to Approve";
                }
            }
        }
    }
}

