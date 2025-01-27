#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 59047 "Online Loan Application"
{

    fields
    {
        field(1; "Application No"; Integer)
        {
            AutoIncrement = true;
        }
    }

    keys
    {
        key(Key1; "Application No")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
    end;

    var
        MyRecRef: RecordRef;
        OnlineLoanTable: Record "Online Loan Application";
        RecordLink: Record "Record Link";
}

