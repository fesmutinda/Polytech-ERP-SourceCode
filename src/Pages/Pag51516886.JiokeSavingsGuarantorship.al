#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516886 "Jioke Savings Guarantorship"
{
    PageType = ListPart;
    SourceTable = 51516711;

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
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Name)
                {
                    ApplicationArea = Basic;
                }
                field("Jiokoe Savings"; "Jiokoe Savings")
                {
                    ApplicationArea = Basic;
                }
                field("Amount Guaranteed"; "Amount Guaranteed")
                {
                    ApplicationArea = Basic;
                }
                field(Liability; Liability)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan Balance"; "Loan Balance")
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

