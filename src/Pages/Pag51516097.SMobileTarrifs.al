#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516097 "S-Mobile Tarrifs"
{
    PageType = List;
    SourceTable = 51516535;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = Basic;
                }
                field(Minimum; Minimum)
                {
                    ApplicationArea = Basic;
                }
                field(Maximum; Maximum)
                {
                    ApplicationArea = Basic;
                }
                field("Charge Amount"; "Charge Amount")
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

