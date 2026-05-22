table 50001 "Polytech Dividend Receipt"
{
    Caption = 'Polytech Dividend Receipt';
    DataClassification = ToBeClassified;

    fields
    {
        field(100; Entry; Integer) { }
        field(1; DividendYear; Code[20])
        {

            trigger OnValidate()
            begin

            end;
        }
        field(3; Posted; Boolean)
        {
            Editable = false;
        }
        field(6; "Posted By"; Code[60])
        {
            Editable = false;
        }
        field(7; "Date Entered"; Date)
        {
        }
        field(9; "Entered By"; Text[60])
        {
        }
        field(10; Remarks; Text[150])
        {
        }
        field(20; "Time Entered"; Time)
        {
        }
        field(21; "Posting date"; Date)
        {
        }
        field(24; "Document No"; Code[20])
        {
        }
        field(25; Amount; Decimal)
        {

            trigger OnValidate()
            begin
                /*
              IF Amount<>"Scheduled Amount" THEN
              ERROR('The Amount must be equal to the Scheduled Amount');
                  */

            end;
        }
        field(26; "Scheduled Amount"; Decimal)
        {
            Editable = false;
            //FieldClass = FlowField;
        }
        field(27; "Total Count"; Integer)
        {
            CalcFormula = count("Polytech Dividend Lines" where("Receipt Dividend Year" = field(DividendYear)));
            FieldClass = FlowField;
        }
        field(28; "Dividend Year"; Date) { }

    }

    keys
    {
        key(PK; Entry)
        {
            Clustered = true;
        }
        key(key2; DividendYear)
        {
            // Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if Posted = true then
            Error('You cannot delete a Posted Check Off');
    end;

    trigger OnInsert()
    begin
        UpdateTotalAmount();

        if DividendYear = '' then begin

        end;

        "Date Entered" := Today;
        "Time Entered" := Time;
        "Entered By" := UpperCase(UserId);

        "Dividend Year" := Dmy2date(1, 1, (Date2dmy(Today, 3) - 1));

    end;

    trigger OnModify()
    begin
        UpdateTotalAmount();
    end;

    trigger OnRename()
    begin
        if Posted = true then
            Error('You cannot rename a Posted Check Off');
    end;

    procedure UpdateTotalAmount()
    var
        Total: Decimal;
        PolyCheckoffLines: Record "Polytech Dividend Lines";
    begin
        Total := 0;
        "Scheduled Amount" := Total;

        PolyCheckoffLines.Reset();
        PolyCheckoffLines.SetRange("Receipt Dividend Year", Rec.DividendYear);
        PolyCheckoffLines.SetRange(posted, false);

        if PolyCheckoffLines.FindSet() then
            repeat
                Total += PolyCheckoffLines."Total Earning";
            until PolyCheckoffLines.Next() = 0;
        "Scheduled Amount" := ROUND(Total, 1, '=');
    end;

    var

        cust: Record Customer;
        "GL Account": Record "G/L Account";
        BANKACC: Record "Bank Account";
}

