#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51234 "HR Leave Family Employees"
{
    // DrillDownPageID = "HR Leave Family Employees List";
    // LookupPageID = "HR Leave Family Employees List";

    fields
    {
        field(1; Family; Code[20])
        {
            NotBlank = true;
            TableRelation = "HR Leave Family Groups".Code;
        }
        field(2; "Employee No"; Code[20])
        {
            NotBlank = true;
            TableRelation = "HR Employees"."No.";
        }
        field(3; Remarks; Text[100])
        {
        }
    }

    keys
    {
        key(Key1; Family, "Employee No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

