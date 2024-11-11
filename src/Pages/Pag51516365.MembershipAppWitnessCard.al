#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516365 "Membership App Witness Card"
{
    PageType = Card;
    SourceTable = 51516363;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Account No"; "Account No")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field(Names; Names)
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("BOSA No."; "BOSA No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member No.';
                }
                field("Date Of Birth"; "Date Of Birth")
                {
                    ApplicationArea = Basic;
                }
                field("ID No."; "ID No.")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Mobile No."; "Mobile No.")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic;
                }
                field("Email Address"; "Email Address")
                {
                    ApplicationArea = Basic;
                }
                field(Address; Address)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

