#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516135 "Posted Payment Voucher List"
{
    CardPageID = "Posted Payment Header";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = 51516112;
    SourceTableView = where("Payment Type" = filter(Normal),
                            Posted = filter(Yes),
                            Status = filter(<> Cancelled),
                            "Expense Type" = filter(<> Director));

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                }
                field(Cashier; Rec.Cashier)
                {
                    ApplicationArea = Basic;
                }
                field(Date; Rec.Date)
                {
                    ApplicationArea = Basic;
                }
                field("Pay Mode"; Rec."Pay Mode")
                {
                    ApplicationArea = Basic;
                }
                field("Cheque No."; Rec."Cheque No.")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ApplicationArea = Basic;
                }
                field(Payee; Rec.Payee)
                {
                    ApplicationArea = Basic;
                }
                field("Payment Narration"; Rec."Payment Narration")
                {
                    ApplicationArea = Basic;
                }
                field("On Behalf Of"; Rec."On Behalf Of")
                {
                    ApplicationArea = Basic;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic;
                }
                field("Total Payment Amount"; Rec."Total Payment Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Current Status"; Rec."Current Status")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Print)
            {
                ApplicationArea = Basic;
                Caption = 'Reprint Voucher';
                Image = Print;
                Promoted = true;
                PromotedCategory = "Report";

                trigger OnAction()
                begin
                    Rec.Reset;
                    Rec.SetFilter("No.", "No.");
                    Report.Run(51516125, true, true, Rec);
                    Rec.Reset;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}

