page 53025 "User Permission Card"
{
    Caption = 'User Permissions Card';
    PageType = Card;
    SourceTable = "User Setup";
    PromotedActionCategories = 'New,Process,Reports,Disbursement,Loan File,Cancellation,Associated Accounts,Post,Approval,Statement';
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    Caption = 'User ID';
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field("Allow Posting From"; Rec."Allow Posting From")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Posting From';
                    ToolTip = 'Specifies the earliest date on which the user is allowed to post to the company.';
                }
                field("Allow Posting To"; Rec."Allow Posting To")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Posting To';
                    ToolTip = 'Specifies the last date on which the user is allowed to post to the company.';
                }

                field("Allow FA Posting From"; Rec."Allow FA Posting From")
                {
                    ApplicationArea = All;
                    Caption = 'Allow FA Posting From';
                    ToolTip = 'Specifies the value of the Allow FA Posting From field.';
                }
                field("Allow FA Posting To"; Rec."Allow FA Posting To")
                {
                    ApplicationArea = All;
                    Caption = 'Allow FA Posting To';
                    ToolTip = 'Specifies the value of the Allow FA Posting To field.';
                }
                field("Register Time"; Rec."Register Time")
                {
                    ApplicationArea = All;
                    Caption = 'Register Time';
                    ToolTip = 'Specifies if you want to register time for this user. This is based on the time spent from when the user logs in to when the user logs out.';
                }

                field("Approver ID"; Rec."Approver ID")
                {
                    ApplicationArea = All;
                    Caption = 'Approver ID';
                    ToolTip = 'Specifies the user ID of the person who must approve records that are made by the user in the User ID field before the record can be released.';
                }
                field("Allow Deferral Posting From"; Rec."Allow Deferral Posting From")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Deferral Posting From';
                    ToolTip = 'Specifies the earliest date on which the user is allowed to post deferrals to the company.';
                }
                field("Allow Deferral Posting To"; Rec."Allow Deferral Posting To")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Deferral Posting To';
                    ToolTip = 'Specifies the last date on which the user is allowed to post deferrals to the company.';
                }

                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = All;
                    Caption = 'E-Mail';
                    ToolTip = 'Specifies the email address of the approver that you can use if you want to send approval mail notifications.';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Caption = 'Phone No.';
                    ToolTip = 'Specifies the user''s phone number.';
                }
            }

            group("User Management")
            {
                Caption = 'User Management';
                field("Registration of New User Accounts"; Rec."Registration of New User Accounts") { }
                field("Assign User Roles & Permissions"; Rec."Assign User Roles & Permissions") { }

            }
            group("System Parameters Setup")
            {
                field("Setting Up UIC Address Information"; Rec."Setting Up UIC Address Information") { }
                field("No Series Setup"; Rec."No Series Setup") { }
                field("Payment Types Setup"; Rec."Payment Types Setup") { }
                field("Posting Group and Transaction Types Setups"; Rec."Posting Group and Transaction Types Setups") { }
            }
            group("Member Accounts")
            {
                field("View Member Accounts"; Rec."View Member Accounts") { }
                field("View Member Statements"; Rec."View Member Statements") { }
                field("View Member Transaction History"; Rec."View Member Transaction History") { }
                field("Process a New Member Application"; Rec."Process a New Member Application") { }
                field("Receipt Membership Applicant minimum contributions, entrance fees"; Rec."Receipt Membership Applicant minimum contributions, entrance fees") { }
                field("View Membership Reports"; Rec."View Membership Reports") { }
                field("Edit Member Details"; Rec."Edit Member Details") { }
                field("Execute change request"; Rec."Execute change request") { }
            }
            // group("Land/Project Registration")
            // {
            //     field("Register New Project"; Rec."Register New Project") { }
            //     field("Originate Plots"; Rec."Originate Plots") { }
            //     field("Linking of Project to General Ledger"; Rec."Linking of Project to General Ledger") { }
            //     field("Land Booking Application"; Rec."Land Booking Application") { }
            //     field("Land Booking Receipting"; Rec."Land Booking Receipting") { }
            //     field("Payment Plan Origination"; Rec."Payment Plan Origination") { }
            //     field("Approval of Negotiation of payment plan"; Rec."Approval of Negotiation of payment plan") { }
            // }
            group("Finance Management")
            {
                field("Budget Management"; Rec."Budget Management") { }
                field("Direct Posting on the General Journal"; Rec."Direct Posting on the General Journal") { }
                field("General Journal Templates and Batches"; Rec."General Journal Templates and Batches") { }
                field("Reversal of Posted transactions"; Rec."Reversal of Posted transactions") { }
                field("Viewing Financial Statements"; Rec."Viewing Financial Statements") { }
                field("Viewing the UIC Chart of Accounts"; Rec."Viewing the UIC Chart of Accounts") { }
                field("Posting of Receipts"; Rec."Posting of Receipts") { }
                field("Viewing pending Receipt lists"; Rec."Viewing pending Receipt lists") { }
                field("Viewing Posted Receipt lists"; Rec."Viewing Posted Receipt lists") { }
                field("Posting of Payment Voucher"; Rec."Posting of Payment Voucher") { }
                field("imprest/reimbursement Application"; Rec."Making an imprest/reimbursement Application") { }
                field("Funds Transfer (InterBank Transfer) Application"; Rec."Making a Funds Transfer (InterBank Transfer) Application") { }
                field("Posting a Funds Transfer"; Rec."Posting a Funds Transfer") { }
                field("Payroll User"; Rec."Payroll User") { }
                field("View Payroll"; Rec."View Payroll") { }
                field("Allow Process Payroll"; Rec."Allow Process Payroll") { }

            }
            group("Fixed Assets")
            {
                field("Acquisition of fixed asset"; Rec."Acquisition of fixed asset") { }
                field("Fixed Asset Setup"; Rec."Fixed Asset Setup") { }
                field("Disposal of Fixed Asset"; Rec."Disposal of Fixed Asset") { }
            }
            group("Periodic Processes")
            {
                field("Checkoff Processing"; Rec."Checkoff Processing") { }
                field("Checkoff Posting"; Rec."Checkoff Posting") { }
                field("Bank Account Reconciliations"; Rec."Bank Account Reconciliations") { }
                field("Dividends Processing"; Rec."Dividends Processing") { }
                field("Share Trading"; Rec."Share Trading") { }
            }
            group("Alternative Channels")
            {
                field("USSD Activation"; Rec."USSD Activation") { }
                field("Reset PIN"; Rec."Reset PIN") { }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if (UserId <> 'STEPHEN') and (UserId <> 'SWIZZSOFTADMIN') then
            CurrPage.Editable := false;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // case Rec."Approval Status" of
        //     Rec."Approval Status"::Approved,
        //     Rec."Approval Status"::Deffered,
        //     Rec."Approval Status"::"Pending Approval":
        //         begin
        //             Error('Approval status must be open, the current status is %1', Rec."Approval Status");
        //         end;
        // end;

    end;

    trigger OnDeleteRecord(): Boolean
    begin

        // case Rec."Approval Status" of
        //     Rec."Approval Status"::Approved,
        //     Rec."Approval Status"::Deffered,
        //     Rec."Approval Status"::"Pending Approval":
        //         begin
        //             Error('Approval status must be open, the current status is %1', Rec."Approval Status");
        //         end;
        // end;
    end;

    var
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}






