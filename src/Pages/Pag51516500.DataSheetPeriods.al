#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516500 "Data Sheet Periods"
{
    PageType = List;
    SourceTable = 51516419;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Period Code"; "Period Code")
                {
                    ApplicationArea = Basic;
                }
                field("Begin Date"; "Begin Date")
                {
                    ApplicationArea = Basic;
                }
                field("End Date"; "End Date")
                {
                    ApplicationArea = Basic;
                }
                field(Month; Month)
                {
                    ApplicationArea = Basic;
                }
                field("Payroll Month"; "Payroll Month")
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

