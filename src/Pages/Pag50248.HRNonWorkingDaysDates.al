#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50248 "HR Non Working Days & Dates"
{
    PageType = List;
    SourceTable = "HR Non Working Days & Dates";

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                field("Non Working Days"; Rec."Non Working Days")
                {
                    ApplicationArea = Basic;
                }
                field("Non Working Dates"; Rec."Non Working Dates")
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

