
Page 58009 "Wallet Transaction Schedule"
{
    PageType = ListPart;
    SourceTable = "Wallet Transaction Schedule";// "Sacco Transfers Schedule";

    layout
    {
        area(content)
        {
            repeater(Control1102760000)
            {
                field("Member Number"; Rec."Member Number")
                {
                    ApplicationArea = Basic;
                }
                field("Destination Account No."; Rec."Destination Account No.")
                {
                    ApplicationArea = Basic;
                }
                field("Destination Account Name"; Rec."Destination Account Name")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SaccoHeader.Reset;
        SaccoHeader.SetRange(SaccoHeader.No, Rec."No.");
        if SaccoHeader.FindSet then begin
            if SaccoHeader.Status = SaccoHeader.Status::Open then begin
                CurrPage.Editable := true
            end else
                CurrPage.Editable := false;
        end;
    end;

    trigger OnOpenPage()
    begin
        SaccoHeader.Reset;
        SaccoHeader.SetRange(SaccoHeader.No, Rec."No.");
        if SaccoHeader.FindSet then begin
            if SaccoHeader.Status = SaccoHeader.Status::Open then begin
                CurrPage.Editable := true
            end else
                if (SaccoHeader.Status = SaccoHeader.Status::pending) or (SaccoHeader.Status = SaccoHeader.Status::pending) then begin
                    CurrPage.Editable := false;
                end;
        end;
    end;

    var
        SaccoHeader: Record "Sacco Transfers";
}

