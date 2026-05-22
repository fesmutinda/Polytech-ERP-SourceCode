#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 56093 "Dividends Progression Prorated"
{

    fields
    {
        field(1; "Dividend Year"; Code[30])
        {
        }
        field(2; "Member No"; Code[50])
        {
            TableRelation = customer."No.";
        }
        field(3; "Start Period"; Date)
        {
        }
        field(4; "End Period"; Date)
        {
        }
        field(5; "Qualifying Share Capital"; Decimal)
        {
        }
        field(6; "Gross Div On Share Capital"; Decimal)
        {
        }
        field(7; "WHT On Share Capital"; Decimal)
        {
        }
        field(8; "Net Div On Share Capital"; Decimal)
        {
        }
        field(9; "Qualifying Deposits"; Decimal)
        {
        }
        field(10; "Gross Interest On Deposits"; Decimal)
        {
        }
        field(11; "WHT On Interest On Deposits"; Decimal)
        {
        }
        field(12; "Net Interest On Deposits"; Decimal)
        {
        }

    }

    keys
    {
        key(Key1; "Dividend Year", "Member No", "Start Period", "End Period")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

