#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516380 "Member Account Image"
{
    PageType = Card;
    SourceTable = "Member Register";

    layout
    {
        area(content)
        {
            field(Picture; Rec.Picture)
            {
                ApplicationArea = Basic;
            }
            field(Signature; Rec.Signature)
            {
                ApplicationArea = Basic;
            }
        }
    }

    actions
    {
    }
}

