table 50002 "Polytech Dividend Lines"
{
    Caption = 'Polytech Dividend Lines';
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Receipt Dividend Year"; Code[20]) { }
        field(2; "Receipt Line No"; Integer) { AutoIncrement = true; }
        field(3; "Entry No"; Code[20]) { Editable = false; }
        field(5; "Member No"; Code[50]) { TableRelation = Customer."No." where("Customer Type" = filter(Member)); }
        field(6; "Member Found"; Boolean) { }
        field(7; "Name"; Code[50]) { Editable = false; }
        field(8; "ID No."; Code[20]) { Editable = false; }
        field(9; Posted; Boolean) { }
        field(10; "Gross Dividend"; Decimal) { }
        field(11; "Interest on Deposits"; Decimal) { }
        field(12; "Total Earning"; Decimal) { }
        field(13; "WTX Tax"; Decimal) { }
        field(14; Commision; Decimal) { }
        field(15; "Net Dividends"; Decimal) { }
        field(16; "Loan Arrears"; Decimal) { }
        field(17; "SMS Sent"; Text[1000]) { }
    }

    keys
    {
        key(Key1; "Receipt Dividend Year", "Receipt Line No", "Member No")
        {
            Clustered = true;
        }
        key(Key2; "Receipt Line No")
        {
        }
        key(Key3; "Member No")
        {
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}