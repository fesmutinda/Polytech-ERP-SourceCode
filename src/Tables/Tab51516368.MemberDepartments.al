#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51516368 "Member Departments"
{
    DrillDownPageID = 51516378;
    LookupPageID = 51516378;

    fields
    {
        field(1; "No."; Code[10])
        {
            NotBlank = true;
        }
        field(2; Department; Text[70])
        {
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

