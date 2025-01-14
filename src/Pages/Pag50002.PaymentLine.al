#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 50002 "Payment Line"
{
    PageType = ListPart;
    SourceTable = "Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Payment Type"; Rec."Payment Type")
                {
                    ApplicationArea = Basic;
                    TableRelation = "Funds Transaction Types"."Transaction Code" where("Transaction Type" = const(Payment));
                }
                field("<BOSA Transaction Type>"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'BOSA Transaction Type';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        if (Rec."Account Type" = Rec."account type"::Customer) then begin
                            Rec.TestField("Transaction Type");
                        end;
                    end;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                }
                field("Loan No."; Rec."Loan No.")
                {
                    ApplicationArea = Basic;
                }
                field("Payment Description"; Rec."Payment Description")
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
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    caption = 'Activity Type';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    caption = 'Branch Code';

                }
                field("VAT Code"; Rec."VAT Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("VAT Amount(LCY)"; Rec."VAT Amount(LCY)")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("W/TAX Code"; Rec."W/TAX Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("W/TAX Amount"; Rec."W/TAX Amount")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("W/TAX Amount(LCY)"; Rec."W/TAX Amount(LCY)")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Net Amount(LCY)"; Rec."Net Amount(LCY)")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Applies-to Doc. Type"; Rec."Applies-to Doc. Type")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Applies-to Doc. No."; Rec."Applies-to Doc. No.")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        FundsTypes: Record "Funds Transaction Types";
        PHeader: Record "Payment Header";
        "G/L Account": Record "G/L Account";
        Customer: Record Customer;
        Vendor: Record Vendor;
        Investor: Record "Profitability Set up-Micro";
        FundsTaxCodes: Record "Funds Tax Codes";
        CurrExchRate: Record "Currency Exchange Rate";
        Loans: Record "Loans Register";
        Cust: Record Customer;
    //         InvestorAmounts: Record "Investor Amounts";
    //         InterestCodes: Record "Interest Rates";
}

