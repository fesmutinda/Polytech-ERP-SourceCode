#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516362 "Membership Application Image"
{
    PageType = Card;
    SourceTable = 51516360;

    layout
    {
        area(content)
        {
            field(Picture; Picture)
            {
                ApplicationArea = Basic;
            }
            field(Signature; Signature)
            {
                ApplicationArea = Basic;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        /*MemberApp.RESET;
        MemberApp.SETRANGE(MemberApp."No.","No.");
        IF MemberApp.FIND('-') THEN BEGIN
         IF MemberApp.Status=MemberApp.Status::Approved THEN BEGIN
          CurrPage.EDITABLE:=FALSE;
         END ELSE
          CurrPage.EDITABLE:=TRUE;
        END;
         */

    end;

    var
        MemberApp: Record 51516360;
}

