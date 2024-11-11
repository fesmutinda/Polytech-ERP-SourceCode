#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130405 "CAL Test Results"
{
    Caption = 'CAL Test Results';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Call Stack';
    SourceTable = "CAL Test Result";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Caption = 'Repeater';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Test Run No."; Rec."Test Run No.")
                {
                    ApplicationArea = All;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Function Name"; Rec."Function Name")
                {
                    ApplicationArea = All;
                }
                field(Platform; Rec.Platform)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Result; Rec.Result)
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                }
                field(Restore; Rec.Restore)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = All;
                }
                field("Execution Time"; Rec."Execution Time")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field(File; Rec.File)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Call Stack")
            {
                ApplicationArea = All;
                Caption = 'Call Stack';
                Image = DesignCodeBehind;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    InStr: InStream;
                    CallStack: Text;
                begin
                    if Rec."Call Stack".Hasvalue then begin
                        Rec.CalcFields("Call Stack");
                        Rec."Call Stack".CreateInstream(InStr);
                        InStr.ReadText(CallStack);
                        Message(CallStack)
                    end;
                end;
            }
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'E&xport';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    CALExportTestResult: XmlPort "CAL Export Test Result";
                begin
                    CALExportTestResult.SetTableview(Rec);
                    CALExportTestResult.Run;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Style := GetStyle;
    end;

    var
        Style: Text;

    local procedure GetStyle(): Text
    begin
        case Rec.Result of
            Rec.Result::Passed:
                exit('Favorable');
            Rec.Result::Failed:
                exit('Unfavorable');
            Rec.Result::Inconclusive:
                exit('Ambiguous');
            else
                exit('Standard');
        end;
    end;
}

