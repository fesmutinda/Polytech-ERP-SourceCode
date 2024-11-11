#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516663 "Posts_web"
{
    PageType = List;
    SourceTable = 51516973;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Entry; Entry)
                {
                    ApplicationArea = Basic;
                }
                field(Title; Title)
                {
                    ApplicationArea = Basic;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic;
                }
                field(DateEntered; DateEntered)
                {
                    ApplicationArea = Basic;
                }
                field(DateModified; DateModified)
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

