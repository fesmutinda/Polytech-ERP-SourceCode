#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516025 "Receipt Header Card"
{
    PageType = Card;
    SourceTable = 51516002;
    SourceTableView = where(Posted = const(No));

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic;
                }
                field(Date; Date)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Code"; "Bank Code")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Name"; "Bank Name")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Balance"; "Bank Balance")
                {
                    ApplicationArea = Basic;
                }
                field("Pay Mode"; "Pay Mode")
                {
                    ApplicationArea = Basic;
                }
                field("Cheque No"; "Cheque No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cheque No.';
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                }
                field("Amount Received"; "Amount Received")
                {
                    ApplicationArea = Basic;
                }
                field("Amount Received(LCY)"; "Amount Received(LCY)")
                {
                    ApplicationArea = Basic;
                }
                field("Total Amount"; "Total Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Total Amount(LCY)"; "Total Amount(LCY)")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic;
                }
                field("Received From"; "Received From")
                {
                    ApplicationArea = Basic;
                }
                field("On Behalf of"; "On Behalf of")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = Basic;
                }
            }
            part(Control23; "Receipt Line")
            {
                SubPageLink = "Document No" = field("No.");
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Post and Print Receipt")
            {
                ApplicationArea = Basic;
                Image = Post;
                Promoted = true;
                PromotedIsBig = true;

                trigger OnAction()
                begin

                    CheckReceiptRequiredFields;
                    CheckLines;
                    DocNo := "No.";

                    ok := Confirm('Post Receipt No:' + Format("No.") + '?');
                    if ok then begin
                        if FundsUser.Get(UserId) then begin
                            FundsUser.TestField(FundsUser."Receipt Journal Template");
                            FundsUser.TestField(FundsUser."Receipt Journal Batch");
                            JTemplate := FundsUser."Receipt Journal Template";
                            JBatch := FundsUser."Receipt Journal Batch";
                            FundsManager.PostReceipt(Rec, JTemplate, JBatch);
                            Commit;
                            //Print Receipt
                            ReceiptHeader.Reset;
                            ReceiptHeader.SetRange(ReceiptHeader."No.", DocNo);
                            if ReceiptHeader.FindFirst then begin
                                Report.RunModal(Report::"Receipt Header", true, false, ReceiptHeader);
                            end;
                        end else begin
                            Error('User Account Not Setup');
                        end;
                    end;
                end;
            }
            action("Print Receipt")
            {
                ApplicationArea = Basic;
                Image = Receipt;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //Print Receipt
                    ReceiptHeader.Reset;
                    ReceiptHeader.SetRange(ReceiptHeader."No.", "No.");
                    if ReceiptHeader.FindFirst then begin
                        Report.RunModal(Report::"Receipt Header", true, false, ReceiptHeader);
                    end;
                end;
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Pay Mode" := "pay mode"::Cash;
        "Global Dimension 1 Code" := 'BOSA';
        "Global Dimension 2 Code" := 'NAIROBI';
    end;

    var
        BillNoVisible: Boolean;
        AccNoVisible: Boolean;
        ok: Boolean;
        ReceiptLine: Record UnknownRecord51516003;
        LineNo: Integer;
        FundsTransTypes: Record UnknownRecord51516032;
        Amount: Decimal;
        "Amount(LCY)": Decimal;
        ReceiptLines: Record UnknownRecord51516003;
        FundsManager: Codeunit UnknownCodeunit51516000;
        JTemplate: Code[20];
        JBatch: Code[20];
        FundsUser: Record UnknownRecord51516031;
        PostingVisible: Boolean;
        MoveVisible: Boolean;
        PageEditable: Boolean;
        ReverseVisible: Boolean;
        DocNo: Code[20];
        ReceiptHeader: Record UnknownRecord51516002;
        BankAcc: Record "Bank Account";

    local procedure CheckReceiptRequiredFields()
    begin
        CalcFields("Total Amount");

        TestField("Total Amount");
        TestField("Amount Received");
        TestField("Bank Code");
        TestField(Date);
        TestField("Posting Date");
        TestField(Description);
        TestField("Received From");
        TestField("Global Dimension 1 Code");
        TestField("Global Dimension 2 Code");

        if "Amount Received" <> "Total Amount" then
            Error('Amount Received must be Equal to the total Amount');

        if "Currency Code" = '' then begin
            if BankAcc.Get("Bank Code") then
                BankAcc.TestField(BankAcc."Currency Code", '');
        end;
    end;

    local procedure CheckLines()
    begin
        ReceiptLines.Reset;
        ReceiptLines.SetRange(ReceiptLines."Document No", "No.");
        if ReceiptLines.FindSet then begin
            repeat
                ReceiptLines.TestField(ReceiptLines."Account Code");
                ReceiptLines.TestField(ReceiptLines."Account Code");
                ReceiptLines.TestField(ReceiptLines.Amount);
            until ReceiptLines.Next = 0;
        end else begin
            Error('Empty Receipt Lines');
        end;
    end;
}

