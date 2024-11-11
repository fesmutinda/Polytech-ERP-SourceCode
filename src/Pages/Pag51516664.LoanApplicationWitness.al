#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516664 "Loan Application Witness"
{
    PageType = List;
    SourceTable = 51516370;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan No"; "Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("Witness No"; "Witness No")
                {
                    ApplicationArea = Basic;
                }
                field("Witness Name"; "Witness Name")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
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

