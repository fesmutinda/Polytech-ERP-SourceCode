#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130404 "CAL Test Missing Codeunits"
{
    Caption = 'Missing Codeunits List';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "Integer";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater("<Codeunit List>")
            {
                Caption = 'Codeunit List';
                field(Number;Number)
                {
                    ApplicationArea = All;
                    Caption = 'Codeunit ID';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Retry)
            {
                ApplicationArea = All;
                Caption = 'Retry';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    if FindFirst then
                      CALTestMgt.AddMissingTestCodeunits(Rec,CurrentTestSuite);
                end;
            }
        }
    }

    var
        CALTestMgt: Codeunit "CAL Test Management";
        CurrentTestSuite: Code[10];


    procedure Initialize(var CUIds: Record "Integer" temporary;TestSuiteName: Code[10])
    begin
        CurrentTestSuite := TestSuiteName;
        Copy(CUIds,true);
    end;
}

