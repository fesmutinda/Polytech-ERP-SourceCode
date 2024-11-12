#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516250 "HR Asset Return Form"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Misc. Article Information";

    layout
    {
        area(content)
        {
            repeater(Control1102755000)
            {
                field("Misc. Article Code"; Rec."Misc. Article Code")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field(Returned; Rec.Returned)
                {
                    ApplicationArea = Basic;
                }
                field("Status On Return"; Rec."Status On Return")
                {
                    ApplicationArea = Basic;
                }
                field("Date Returned"; Rec."Date Returned")
                {
                    ApplicationArea = Basic;
                }
                field(Recommendations; Rec.Recommendations)
                {
                    ApplicationArea = Basic;
                }
                field("Received By"; Rec."Received By")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    var
        EI: Record "HR Employee Exit Interviews";


    procedure refresh()
    begin
        CurrPage.Update(false);
    end;
}

