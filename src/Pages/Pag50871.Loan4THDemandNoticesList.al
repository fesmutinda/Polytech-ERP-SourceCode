#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50871 "Loan 4TH Demand Notices List"
{
    CardPageID = "Loan 4TH Demand Notices Card";
    DeleteAllowed = false;
    PageType = List;
    SourceTable = 51926;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Loan In Default"; Rec."Loan In Default")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Product"; Rec."Loan Product")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Instalments"; Rec."Loan Instalments")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Disbursement Date"; Rec."Loan Disbursement Date")
                {
                    ApplicationArea = Basic;
                }
                field("Expected Completion Date"; Rec."Expected Completion Date")
                {
                    ApplicationArea = Basic;
                }
                field("Amount In Arrears"; Rec."Amount In Arrears")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Outstanding Balance"; Rec."Loan Outstanding Balance")
                {
                    ApplicationArea = Basic;
                }
                field("Notice Type"; Rec."Notice Type")
                {
                    ApplicationArea = Basic;
                }
                field("Demand Notice Date"; Rec."Demand Notice Date")
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic;
                }
                field("No. Series"; Rec."No. Series")
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
