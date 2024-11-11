#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516868 "Loan 3rd Demand Notices List"
{
    CardPageID = "Loan 3rd Demand Notices Card";
    PageType = List;
    SourceTable = 51516926;
    SourceTableView = where("Notice Type" = filter("3rd Notice"),
                            THIRDNOTE = filter(Yes),
                            DEFAUTER = filter(No));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; "Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Loan In Default"; "Loan In Default")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Product"; "Loan Product")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Instalments"; "Loan Instalments")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Disbursement Date"; "Loan Disbursement Date")
                {
                    ApplicationArea = Basic;
                }
                field("Expected Completion Date"; "Expected Completion Date")
                {
                    ApplicationArea = Basic;
                }
                field("Amount In Arrears"; "Amount In Arrears")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Outstanding Balance"; "Loan Outstanding Balance")
                {
                    ApplicationArea = Basic;
                }
                field("Notice Type"; "Notice Type")
                {
                    ApplicationArea = Basic;
                }
                field("Demand Notice Date"; "Demand Notice Date")
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = Basic;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Archive Paid")
            {
                ApplicationArea = Basic;
                Image = Archive;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Paid := true;
                    DEFAUTER := true;
                    Modify;
                end;
            }
        }
    }
}

