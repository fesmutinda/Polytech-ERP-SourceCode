#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0424, AW0006 // ForNAV settings
Page 51516889 "CEEP Change Request List"
{
    CardPageID = "CEEP Change Request Card";
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "CEEP Change Request";
    SourceTableView = where(Changed = const(false));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic;
                }
                field("Micro Finance Change Type"; Rec."Micro Finance Change Type")
                {
                    ApplicationArea = Basic;
                    Caption = 'Change Type';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }



            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        IF UserId <> 'SURESTEP' THEN begin
            Rec.SetRange(Rec."Captured by", UserId);
        end;

    end;

    var
        usersetup: Record "User Setup";
}

