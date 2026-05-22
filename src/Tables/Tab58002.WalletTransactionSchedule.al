Table 58002 "Wallet Transaction Schedule"
{

    fields
    {
        field(1; "No."; Code[20])
        {
            TableRelation = "Wallet Transactions".No;// "Sacco Transfers".No;
        }
        field(2; "Destination Account No."; Code[20])
        {
            TableRelation = Vendor."No." where("BOSA Account No" = field("Member Number"));

            trigger OnValidate()
            begin
                Vend.Reset;
                if Vend.Get("Destination Account No.") then begin
                    "Destination Account Name" := Vend.Name;
                    "Global Dimension 2 Code" := Vend."Global Dimension 2 Code";
                end;

                //validate account pn
                SaccoTransfer.Reset;
                SaccoTransfer.SetRange(No, SaccoTransfer.No);
                if SaccoTransfer.Find('-') then begin
                    if SaccoTransfer."Source Account No" = Rec."Destination Account No." then
                        Error(Text001);


                end;
            end;
        }
        field(3; "Destination Account Name"; Text[100])
        {
        }
        field(5; "Destination Type"; ENUM TransactionTypesEnum)
        {
        }
        field(7; Amount; Decimal)
        {

        }
        field(8; Description; Text[100])
        {
        }
        field(9; "Created By"; Code[20])
        {
        }
        field(10; "Cummulative Total Payment Loan"; Decimal)
        {
        }
        field(11; Credit; Text[30])
        {
        }
        field(12; "Global Dimension 1 Code"; Code[10])
        {
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1),
                                                          "Dimension Value Type" = const(Standard));
        }
        field(13; "Global Dimension 2 Code"; Code[10])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2),
                                                          "Dimension Value Type" = const(Standard));
        }
        field(14; "Member Number"; Code[50])
        {
            TableRelation = Customer."No.";
            trigger OnValidate()
            var
                swizzMobile: Codeunit SwizzKashMobile;
                SFactory: Codeunit "Swizzsoft Factory.";
            begin
                "Destination Account No." := SFactory.FnGetFosaAccount("Member Number");

                // vendorTable.Reset();
                // vendorTable.SetRange(vendorTable."BOSA Account No", "Member Number");
                // if vendorTable.Find('-') then begin
                //     "Destination Account No." :=  vendorTable."No.";
                // end else begin

                // end;
            end;
        }
        field(15; "Payroll Number"; Code[50])
        {
            TableRelation = Customer."Personal No";// "Payroll/Staff No";
        }
    }

    keys
    {
        key(Key1; "No.", "Destination Account No.", "Destination Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if "Destination Account No." <> '' then begin
            Bosa.Reset;
            if Bosa.Get("No.") then begin
                if (Bosa.Posted) or (Bosa.Approved) then
                    Error('Cannot delete approved or posted batch');
            end;
        end;
    end;

    trigger OnInsert()
    begin
        Credit := 'Debit';
    end;

    trigger OnModify()
    begin
        if "Destination Account No." <> '' then begin
            Bosa.Reset;
            if Bosa.Get("No.") then begin
                if (Bosa.Posted) or (Bosa.Approved) then
                    Error('Cannot modify approved or posted batch');
            end;
        end;
    end;

    trigger OnRename()
    begin
        Bosa.Reset;
        if Bosa.Get("No.") then begin
            if (Bosa.Posted) or (Bosa.Approved) then
                Error('Cannot rename approved or posted batch');
        end;
    end;

    var
        Cust: Record Customer;
        Vend: Record Vendor;
        vendorTable: Record Vendor;
        Bank: Record "Bank Account";
        Bosa: Record "BOSA Transfers";
        "G/L": Record "G/L Account";
        memb: Record Customer;
        Loans: Record "Loans Register";
        ReceiptAll: Record "Sacco Transfers Schedule";
        SaccoTransfer: Record "Wallet Transactions";// "Sacco Transfers";
        Text001: label 'Source Account Cannot Be Same As Destination Account! Check Accounts....';
}

