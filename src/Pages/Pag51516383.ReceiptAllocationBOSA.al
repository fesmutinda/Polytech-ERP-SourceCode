#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516383 "Receipt Allocation-BOSA"
{
    PageType = List;
    SourceTable = 51516387;

    layout
    {
        area(content)
        {
            repeater(Control1102760000)
            {
                field("Account Type"; "Account Type")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Account No"; "Account No")
                {
                    ApplicationArea = Basic;
                    LookupPageID = "Fosa Account List";
                    Visible = false;
                }
                field("Transaction Type"; "Transaction Type")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        if ("Transaction Type" <> "transaction type"::"Mwanangu Savings") and ("Transaction Type" <> "transaction type"::" ") then begin
                            "Account Type" := "account type"::Member
                        end else
                            "Account Type" := "account type"::Vendor;
                    end;
                }
                field("Loan No."; "Loan No.")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                }
                field("Amount Balance"; "Amount Balance")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Interest Balance"; "Interest Balance")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        /*sto.RESET;
        sto.SETRANGE(sto."No.","Document No");
        IF sto.FIND('-') THEN BEGIN
        IF sto.Status=sto.Status::Approved THEN BEGIN
        CurrPage.EDITABLE:=FALSE;
        END ELSE
        CurrPage.EDITABLE:=TRUE;
        END;
        */

    end;

    var
        sto: Record UnknownRecord51516449;
        Loan: Record UnknownRecord51516371;
        ReceiptAllocation: Record UnknownRecord51516387;
        ReceiptH: Record UnknownRecord51516388;
}

