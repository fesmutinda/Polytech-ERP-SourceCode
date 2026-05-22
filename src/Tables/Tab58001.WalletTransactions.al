#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 58001 "Wallet Transactions"
{
    DrillDownPageId = "Wallet Payments";//  "Sacco Transfer List";
    LookupPageId = "Wallet Payments";// "Sacco Transfer List";
    fields
    {
        field(1; No; Code[20])
        {

            trigger OnValidate()
            begin
                if No <> xRec.No then begin
                    NoSetup.Get(0);
                    NoSeriesMgt.TestManual(No);
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Transaction Date"; Date)
        {
        }
        field(3; "Schedule Total"; Decimal)
        {
            CalcFormula = sum("Wallet Transaction Schedule".Amount where("No." = field(No)));
            FieldClass = FlowField;
        }
        field(4; Approved; Boolean)
        {
        }
        field(5; "Approved By"; Code[10])
        {
        }
        field(6; Posted; Boolean)
        {
        }
        field(7; "No. Series"; Code[20])
        {
        }
        field(8; "Responsibility Center"; Code[10])
        {
        }
        field(9; Remarks; Code[30])
        {
        }
        field(11; "Source Account No"; Code[20])
        {
            TableRelation = "Bank Account"."No.";

            trigger OnValidate()
            begin
                Bank.Reset;
                if Bank.Get("Source Account No") then begin
                    "Source Account Name" := Bank.Name;
                    "Global Dimension 2 Code" := Bank."Global Dimension 2 Code";
                end;

            end;
        }
        field(12; "Source Transaction Type"; ENUM TransactionTypesEnum)
        {
        }
        field(13; "Source Account Name"; Text[50])
        {
        }
        field(15; "Created By"; Code[60])
        {
        }
        field(16; Debit; Text[30])
        {
            Editable = false;
        }
        field(17; Refund; Boolean)
        {
        }
        field(18; "Guarantor Recovery"; Boolean)
        {
        }
        field(19; "Payrol No."; Code[30])
        {
        }
        field(20; "Global Dimension 1 Code"; Code[10])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          "Dimension Value Type" = const(Standard));
        }
        field(21; "Global Dimension 2 Code"; Code[10])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          "Dimension Value Type" = const(Standard));
        }
        field(22; "Bosa Number"; Code[30])
        {
        }
        field(51516061; Status; enum "Record Status")
        {

        }
        field(23; "Captured By"; Code[50]) { }
        // field(capt)
        field(24; "Total Amount"; Decimal) { }
    }

    keys
    {
        key(Key1; No)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Approved or Posted then
            Error('Cannot delete posted or approved batch');
    end;

    trigger OnInsert()
    begin
        if No = '' then begin
            NoSetup.Get;
            NoSetup.TestField(NoSetup."Wallet Transaction Nos");
            NoSeriesMgt.InitSeries(NoSetup."Wallet Transaction Nos", xRec."No. Series", 0D, No, "No. Series");
        end;
        "Transaction Date" := Today;
        "Created By" := UserId;
        Debit := 'Credit';
    end;

    trigger OnModify()
    begin
        if Posted then
            Error('Cannot modify a posted batch');
    end;

    trigger OnRename()
    begin
        if Posted then
            Error('Cannot rename a posted batch');
    end;

    var
        NoSetup: Record "Sacco No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        Cust: Record Customer;
        Bank: Record "Bank Account";
        Vend: Record Vendor;
        memb: Record Customer;
        "G/L": Record "G/L Account";
}

