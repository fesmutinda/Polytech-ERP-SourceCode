Page 50951 "PaymentList"
{
    ApplicationArea = All;
    Caption = 'Payment List';
    PageType = List;
    SourceTable = "Payment Header";
    UsageCategory = Lists;
    CardPageId = PaymentCard;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
                field("Amount(LCY)"; Rec."Amount(LCY)")
                {
                    ApplicationArea = Basic;
                }
                field(Cashier; Rec.Cashier)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Payment Mode" := Rec."payment mode"::Cheque;
        Rec."Payment Type" := Rec."payment type"::Normal;
    end;

    trigger OnOpenPage()
    begin
        Rec.SetRange(Cashier, UserId);
    end;
}

