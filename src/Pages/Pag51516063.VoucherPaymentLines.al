#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516063 "Voucher Payment Lines"
{
    PageType = ListPart;
    SourceTable = "Payment Line";

    layout
    {
        area(content)
        {
            repeater(Control1102760000)
            {
                field(Type; Rec."Payment Type")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                    Enabled = FieldEditable;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Description';
                    Editable = FieldEditable;
                    Enabled = FieldEditable;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                    Enabled = FieldEditable;
                }
                // field("Shortcut Dimension 2 Code";Rec."Shortcut Dimension 2 Code")
                // {
                //     ApplicationArea = Basic;
                //     Editable = FieldEditable;
                //     Enabled = FieldEditable;
                // }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                    Editable = FieldEditable;
                    Enabled = FieldEditable;

                    trigger OnValidate()
                    begin
                        //check if the payment reference is for farmer purchase
                        // if Rec."Payment Reference"=Rec."payment reference"::"Farmer Purchase" then
                        //   begin
                        //     if Rec.Amount<>xRec.Amount then
                        //       begin
                        //         Error('Amount cannot be modified');
                        //       end;
                        //   end;

                        Rec."VAT Withheld Amount(LCY)" := Rec.Amount;
                        if Rec."Account Type" in [Rec."account type"::Customer, Rec."account type"::Vendor,
                        Rec."account type"::"G/L Account", Rec."account type"::"Bank Account", Rec."account type"::"Fixed Asset"] then
                            case Rec."Account Type" of
                                Rec."account type"::"G/L Account":
                                    begin

                                        Rec.TestField(Amount);
                                        RecPayTypes.Reset;
                                        // RecPayTypes.SetRange(RecPayTypes.Code,Type);
                                        RecPayTypes.SetRange(RecPayTypes.Type, RecPayTypes.Type::Payment);
                                        if RecPayTypes.Find('-') then begin
                                            if RecPayTypes."VAT Chargeable" = RecPayTypes."vat chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."VAT Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."VAT Code");
                                                if TarriffCodes.Find('-') then begin
                                                    Rec."VAT Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    Rec."VAT Amount" := (Rec.Amount / ((TarriffCodes.Percentage + 100)) * TarriffCodes.Percentage);
                                                end;
                                            end
                                            else begin
                                                Rec."VAT Amount" := 0;
                                            end;

                                            if RecPayTypes."Withholding Tax Chargeable" = RecPayTypes."withholding tax chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."Withholding Tax Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."Withholding Tax Code");
                                                if TarriffCodes.Find('-') then begin
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    Rec."Withholding Tax Amount" := (Rec.Amount - Rec."VAT Amount") * (TarriffCodes.Percentage / 100);
                                                end;
                                            end
                                            else begin
                                                Rec."Withholding Tax Amount" := 0;
                                            end;
                                        end;
                                    end;
                                Rec."account type"::Customer:
                                    begin

                                        Rec.TestField(Amount);
                                        RecPayTypes.Reset;
                                        RecPayTypes.SetRange(RecPayTypes.Code, Rec."Payment Type");
                                        RecPayTypes.SetRange(RecPayTypes.Type, RecPayTypes.Type::Payment);
                                        if RecPayTypes.Find('-') then begin
                                            if RecPayTypes."VAT Chargeable" = RecPayTypes."vat chargeable"::Yes then begin
                                                Rec.TestField("VAT Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, Rec."VAT Code");
                                                if TarriffCodes.Find('-') then begin
                                                    //"VAT Amount":=(TarriffCodes.Percentage/100)*Amount;
                                                    Rec."VAT Amount" := (Rec.Amount / ((TarriffCodes.Percentage + 100)) * TarriffCodes.Percentage);
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."VAT Amount" := 0;
                                            end;

                                            if RecPayTypes."Withholding Tax Chargeable" = RecPayTypes."withholding tax chargeable"::Yes then begin
                                                Rec.TestField("Withholding Tax Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, Rec."Withholding Tax Code");
                                                if TarriffCodes.Find('-') then begin
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;

                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * (Rec.Amount - Rec."VAT Amount");

                                                end;
                                            end
                                            else begin
                                                Rec."Withholding Tax Amount" := 0;
                                            end;
                                        end;



                                    end;
                                Rec."account type"::Vendor:
                                    begin

                                        Rec.TestField(Amount);
                                        RecPayTypes.Reset;
                                        RecPayTypes.SetRange(RecPayTypes.Code, Rec."Payment Type");
                                        RecPayTypes.SetRange(RecPayTypes.Type, RecPayTypes.Type::Payment);
                                        if RecPayTypes.Find('-') then begin
                                            if RecPayTypes."VAT Chargeable" = RecPayTypes."vat chargeable"::Yes then begin
                                                Rec.TestField("VAT Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, Rec."VAT Code");
                                                if TarriffCodes.Find('-') then begin
                                                    Rec."VAT Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    //
                                                    Rec."VAT Amount" := (Rec.Amount / ((TarriffCodes.Percentage + 100)) * TarriffCodes.Percentage);
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."VAT Amount" := 0;
                                            end;

                                            if RecPayTypes."Withholding Tax Chargeable" = RecPayTypes."withholding tax chargeable"::Yes then begin
                                                Rec.TestField("Withholding Tax Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, Rec."Withholding Tax Code");
                                                if TarriffCodes.Find('-') then begin
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    //
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * (Rec.Amount - Rec."VAT Amount");
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."Withholding Tax Amount" := 0;
                                            end;
                                        end;


                                    end;
                                Rec."account type"::"Bank Account":
                                    begin

                                        Rec.TestField(Amount);
                                        RecPayTypes.Reset;
                                        RecPayTypes.SetRange(RecPayTypes.Code, Rec."Payment Type");
                                        RecPayTypes.SetRange(RecPayTypes.Type, RecPayTypes.Type::Payment);
                                        if RecPayTypes.Find('-') then begin
                                            if RecPayTypes."VAT Chargeable" = RecPayTypes."vat chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."VAT Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."VAT Code");
                                                if TarriffCodes.Find('-') then begin
                                                    //
                                                    Rec."VAT Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    Rec."VAT Amount" := (Rec.Amount / ((TarriffCodes.Percentage + 100)) * TarriffCodes.Percentage);
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."VAT Amount" := 0;
                                            end;

                                            if RecPayTypes."Withholding Tax Chargeable" = RecPayTypes."withholding tax chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."Withholding Tax Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."Withholding Tax Code");
                                                if TarriffCodes.Find('-') then begin
                                                    //
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * (Rec.Amount - Rec."VAT Amount");
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."Withholding Tax Amount" := 0;
                                            end;
                                        end;


                                    end;
                                Rec."account type"::"Fixed Asset":
                                    begin

                                        Rec.TestField(Amount);
                                        RecPayTypes.Reset;
                                        RecPayTypes.SetRange(RecPayTypes.Code, Rec."Payment Type");
                                        RecPayTypes.SetRange(RecPayTypes.Type, RecPayTypes.Type::Payment);
                                        if RecPayTypes.Find('-') then begin
                                            if RecPayTypes."VAT Chargeable" = RecPayTypes."vat chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."VAT Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."VAT Code");
                                                if TarriffCodes.Find('-') then begin
                                                    //"VAT Amount":=(TarriffCodes.Percentage/100)*Amount;
                                                    Rec."VAT Amount" := (Rec.Amount / ((TarriffCodes.Percentage + 100)) * TarriffCodes.Percentage);
                                                end;
                                            end
                                            else begin
                                                Rec."VAT Amount" := 0;
                                            end;

                                            if RecPayTypes."Withholding Tax Chargeable" = RecPayTypes."withholding tax chargeable"::Yes then begin
                                                RecPayTypes.TestField(RecPayTypes."Withholding Tax Code");
                                                TarriffCodes.Reset;
                                                TarriffCodes.SetRange(TarriffCodes.Code, RecPayTypes."Withholding Tax Code");
                                                if TarriffCodes.Find('-') then begin
                                                    //
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * Rec.Amount;
                                                    Rec."Withholding Tax Amount" := (TarriffCodes.Percentage / 100) * (Rec.Amount - Rec."VAT Amount");
                                                    //
                                                end;
                                            end
                                            else begin
                                                Rec."Withholding Tax Amount" := 0;
                                            end;
                                        end;


                                    end;
                            end;


                        Rec."Net Amount" := Rec.Amount - Rec."Withholding Tax Amount";
                        Rec.Validate("Net Amount");
                    end;
                }
                // field(Remarks; Rec.Remarks)
                // {
                //     ApplicationArea = Basic;
                //     Editable = FieldEditable;
                //     Enabled = FieldEditable;
                // }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = Basic;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Vendor Bank Account"; Rec."Account No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("VAT Rate"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Retention Code"; Rec."Retention Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Withholding Tax Code"; Rec."Withholding Tax Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;

                    trigger OnValidate()
                    begin
                        TarriffCodes.Reset;
                        // TarriffCodes.SetRange(TarriffCodes.Code, "Withholding Tax Code");
                        // if TarriffCodes.FindFirst then begin
                        //     //    "Withholding Tax Amount":=(TarriffCodes.Percentage/100)*Amount;
                        //     Rec."Withholding Tax Amount" := (Rec."Amount With VAT" - Rec."VAT Amount") * (TarriffCodes.Percentage / 100);
                        // end
                        // else begin
                        Rec."Withholding Tax Amount" := 0;
                        // end;
                        Rec."Net Amount" := Rec.Amount - Rec."Withholding Tax Amount";
                    end;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Withholding Tax Amount"; Rec."Withholding Tax Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                // field("Retention  Amount"; Rec."Retention  Amount")
                // {
                //     ApplicationArea = Basic;
                //     Visible = false;
                // }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                // field("Apply to ID"; Rec."Apply to ID")
                // {
                //     ApplicationArea = Basic;
                //     Editable = false;
                //     Lookup = true;
                //     Visible = false;
                // }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic;
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        FieldEditable := true;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        PHeader.Reset;
        PHeader.SetRange(PHeader."No.", Rec.No);
        if PHeader.FindFirst then begin
            if (PHeader.Status = PHeader.Status::Approved) or (PHeader.Status = PHeader.Status::"Pending Approval") then begin
                FieldEditable := false;
            end else begin
                FieldEditable := true;
            end;
        end;
    end;

    var
        RecPayTypes: Record 51516004;
        TarriffCodes: Record 51516046;
        GenJnlLine: Record "Gen. Journal Line";
        DefaultBatch: Record "Gen. Journal Batch";
        CashierLinks: Record 51516047;
        LineNo: Integer;
        CustLedger: Record "Vendor Ledger Entry";
        CustLedger1: Record "Vendor Ledger Entry";
        Amt: Decimal;
        TotAmt: Decimal;
        ApplyInvoice: Codeunit "Purchase Header Apply";
        AppliedEntries: Record 51516037;
        VendEntries: Record "Vendor Ledger Entry";
        PInv: Record "Purch. Inv. Header";
        VATPaid: Decimal;
        VATToPay: Decimal;
        PInvLine: Record "Purch. Inv. Line";
        VATBase: Decimal;
        FieldEditable: Boolean;
        PHeader: Record 51516000;
}

