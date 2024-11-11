#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516020 "Mobile Payment Line"
{
    PageType = ListPart;
    SourceTable = 51516001;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                    TableRelation = "Funds Transaction Types"."Transaction Code" where("Transaction Type" = const(Payment),
                                                                                        "Meeting Transaction" = const(No));
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                }
                field("Date Posted"; Rec."Date Posted")
                {
                    ApplicationArea = Basic;
                }
                field("Time Posted"; Rec."Time Posted")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic;
                }
                field("VAT Code"; Rec."VAT Code")
                {
                    ApplicationArea = Basic;
                }
                field("Withholding Tax Code"; Rec."Withholding Tax Code")
                {
                    ApplicationArea = Basic;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Withholding Tax Amount"; Rec."Withholding Tax Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Paying Bank Account"; Rec."Paying Bank Account")
                {
                    ApplicationArea = Basic;
                }
                field("PO/INV No"; Rec."PO/INV No")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Account No"; Rec."Bank Account No")
                {
                    ApplicationArea = Basic;
                }
                field("Total Allocation"; Rec."Total Allocation")
                {
                    ApplicationArea = Basic;
                }
                field("Total Expenditure"; Rec."Total Expenditure")
                {
                    ApplicationArea = Basic;
                }
                field("Total Commitments"; Rec."Total Commitments")
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

