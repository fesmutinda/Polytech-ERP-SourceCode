#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51516046 "Tariff Codes"
{
    // DrillDownPageID = UnknownPage51516651;
    // LookupPageID = UnknownPage51516651;

    fields
    {
        field(1;"Code";Code[20])
        {
            NotBlank = true;
        }
        field(2;Description;Text[50])
        {
        }
        field(3;Percentage;Decimal)
        {
        }
        field(4;"Account No.";Code[20])
        {
            TableRelation = if ("Account Type"=const("G/L Account")) "G/L Account"."No."
                            else if ("Account Type"=const(Vendor)) Vendor."No.";
        }
        field(5;Type;Option)
        {
            OptionMembers = " ","W/Tax",VAT,Excise,Others,Retention;
        }
        field(12;"Account Type";Option)
        {
            Caption = 'Account Type';
            OptionCaption = 'G/L Account,Customer,Vendor,Bank Account,Fixed Asset,IC Partner';
            OptionMembers = "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner";

            trigger OnValidate()
            var
            begin
            end;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    var
}

