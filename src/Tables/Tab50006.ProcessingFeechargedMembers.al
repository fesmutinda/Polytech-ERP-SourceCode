table 50006 "Processing Fee charged Members"
{
    Caption = 'Processing Fee charged Members';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Member No"; Code[50])
        {
            Caption = 'Member No';
        }
        field(2; "FOSA Account"; Code[50])
        {
            Caption = 'FOSA Account';
        }
        field(3; Charged; Boolean)
        {
            Caption = 'Charged';
        }
        field(4; Amount; Decimal)
        {
        }
        field(5; Excise; Decimal)
        {
        }
        field(6; "Gross Share Capital"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Dividends Progression Prorated"."Gross Div On Share Capital" where("Member No" = field("Member No")));
        }
        field(8; "Gross Deposits"; Decimal)
        {
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = sum("Dividends Progression Prorated"."Gross Interest On Deposits" where("Member No" = field("Member No")));
        }
    }
    keys
    {
        key(PK; "Member No", "FOSA Account")
        {
            Clustered = true;
        }
    }
}
