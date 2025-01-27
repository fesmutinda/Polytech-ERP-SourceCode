pageextension 57104 "vendorledgerentry" extends "Vendor Ledger Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("CreditAmount"; Rec."Credit Amount")
            {
                ApplicationArea = Basic;
                Caption = 'Credit Amount';
            }
            field("DebitAmount"; Rec."Debit Amount")
            {
                ApplicationArea = Basic;
                Caption = 'Debit Amount';
            }
            field("UserID"; Rec."User ID")
            {
                ApplicationArea = Basic;
                Caption = 'User ID';
            }
        }
        modify("Payment Method Code")
        {
            Visible = false;
        }
        modify("Currency Code")
        {
            Visible = false;
        }
        modify("Payment Reference")
        {
            Visible = false;
        }
        modify("Document Type")
        {
            Visible = false;
        }
        modify("Creditor No.")
        {
            Visible = false;
        }
        modify("Remaining Amount")
        {
            Visible = false;
        }
        modify("Remaining Amt. (LCY)")
        {
            Visible = false;
        }
        modify("Due Date")
        {
            Visible = false;
        }
        modify("Pmt. Disc. Tolerance Date")
        {
            Visible = false;
        }
        modify("Pmt. Discount Date")
        {
            Visible = false;
        }
        modify("Original Pmt. Disc. Possible")
        {
            Visible = false;
        }
        modify("Remaining Pmt. Disc. Possible")
        {
            Visible = false;
        }
        modify("Max. Payment Tolerance")
        {
            Visible = false;
        }
        modify(Open)
        {
            Visible = false;
        }
        modify("On Hold")
        {
            Visible = false;
        }
        modify("Exported to Payment File")
        {
            Visible = false;
        }
        modify(RecipientBankAcc)
        {
            Visible = false;
        }
        modify("Remit-to Code")
        {
            Visible = false;
        }

    }
    trigger OnOpenPage()
    begin
        CurrPage.Editable := false;
    end;
}


