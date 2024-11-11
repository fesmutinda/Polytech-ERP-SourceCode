#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516706 "Loan Reschedulling list"
{
    CardPageID = "Loan Rescheduling card";
    PageType = List;
    SourceTable = 51516069;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Loan No"; "Loan No")
                {
                    ApplicationArea = Basic;
                }
                field(Rescheduled; Rescheduled)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

