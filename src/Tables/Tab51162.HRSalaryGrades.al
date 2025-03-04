#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51162 "HR Salary Grades"
{
    // DrillDownPageID = 55526;
    // LookupPageID = 55526;

    fields
    {
        field(1; "Salary Grade"; Code[20])
        {
        }
        field(2; "Salary Amount"; Decimal)
        {
        }
        field(3; Description; Text[100])
        {
        }
        field(4; "Pays NHF"; Boolean)
        {
        }
        field(5; "Pays NSITF"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Salary Grade")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

