#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000839 "Prod. Order Comment List"
{
    Caption = 'Comment List';
    DataCaptionFields = Status,"Prod. Order No.";
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "Prod. Order Comment Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Prod. Order No.";"Prod. Order No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the related production order.';
                }
                field(Date;Date)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a date.';
                }
                field(Comment;Comment)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the comment.';
                }
            }
        }
    }

    actions
    {
    }
}

