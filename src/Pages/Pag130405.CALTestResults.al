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
                field("No.";"No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Test Run No.";"Test Run No.")
                {
                    ApplicationArea = All;
                }
                field("Codeunit ID";"Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Codeunit Name";"Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Function Name";"Function Name")
                {
                    ApplicationArea = All;
                }
                field(Platform;Platform)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Result;Result)
                {
                    ApplicationArea = All;
                    StyleExpr = Style;
                }
                field(Restore;Restore)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Start Time";"Start Time")
                {
                    ApplicationArea = All;
                }
                field("Execution Time";"Execution Time")
                {
                    ApplicationArea = All;
                }
                field("Error Message";"Error Message")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = true;
                }
                field("User ID";"User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field(File;File)
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
                    if "Call Stack".Hasvalue then begin
                      CalcFields("Call Stack");
                      "Call Stack".CreateInstream(InStr);
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
        case Result of
          Result::Passed:
            exit('Favorable');
          Result::Failed:
            exit('Unfavorable');
          Result::Inconclusive:
            exit('Ambiguous');
          else
            exit('Standard');
        end;
    end;
}

