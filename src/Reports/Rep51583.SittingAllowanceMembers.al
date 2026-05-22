#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 51583 "Sitting Allowance Members"
{
    RDLCLayout = './Layouts/sittingAllowanceMembers2.rdl';
    DefaultLayout = RDLC;
    ApplicationArea = Basic;

    dataset
    {
        dataitem("Payments Line"; "Payment Line New")
        {
            DataItemTableView = where("Account No." = const('400554'));//, "Posting Date" = filter(0D | 20260101D));//, Posted = filter(true));//("Account No." = const('400554'));//("Payment Type" = filter('SITTING ALLOWANCE'));////201214
            RequestFilterFields = "Member Type", "Board Member Name", "Posting Date";// SetFilter("Posting Date", '%1|<%2', 0D, 20260101D);

            column(AccountName_PaymentLine; "Payments Line"."Account Name") { }
            column(MemberType_PaymentLine; "Member Type") { }
            column(Board_Member_Name; "Board Member Name") { }
            column(Amount_PaymentLine; "Payments Line".Amount) { }
            column(NetAmount_PaymentLine; "Payments Line"."Net Amount") { }
            column(Date_PaymentLine; "Payments Line"."Date Posted") { }
            column(Document_No; "Document No") { }
            trigger OnAfterGetRecord()
            var
                glEntries: Record "G/L Entry";
                reversed: Boolean;
            begin
                // if "Posting Date" > DMY2Date(1, 1, 2026) then
                //     CurrReport.Skip;
            end;

            trigger OnPreDataItem()
            begin
                // SetFilter("Posting Date", '%1|<%2', 0D, 20260101D);
            end;
        }
    }
    requestpage
    {
        SaveValues = false;
        layout
        {
        }
    }
    var
        Customer: Record Customer;

}
