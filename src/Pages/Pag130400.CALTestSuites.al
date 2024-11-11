#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130400 "CAL Test Suites"
{
    Caption = 'CAL Test Suites';
    PageType = List;
    SaveValues = true;
    SourceTable = "CAL Test Suite";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the test suite.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Update Test Coverage Map"; Rec."Update Test Coverage Map")
                {
                    ApplicationArea = All;
                }
                field("Tests to Execute"; Rec."Tests to Execute")
                {
                    ApplicationArea = All;
                }
                field(Failures; Rec.Failures)
                {
                    ApplicationArea = All;
                }
                field("Tests not Executed"; Rec."Tests not Executed")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Test &Suite")
            {
                Caption = 'Test &Suite';
                action("&Run All")
                {
                    ApplicationArea = All;
                    Caption = '&Run All';
                    Image = Start;
                    Promoted = true;
                    PromotedCategory = Process;
                    ShortCutKey = 'Shift+Ctrl+L';

                    trigger OnAction()
                    var
                        CALTestSuite: Record "CAL Test Suite";
                        CALTestLine: Record "CAL Test Line";
                    begin
                        if CALTestSuite.FindSet then
                            repeat
                                CALTestLine.SetRange("Test Suite", CALTestSuite.Name);
                                if CALTestLine.FindFirst then
                                    Codeunit.Run(Codeunit::"CAL Test Runner", CALTestLine);
                            until CALTestSuite.Next = 0;
                        Commit;
                    end;
                }
                group(Setup)
                {
                    Caption = 'Setup';
                    Image = Setup;
                    action("E&xport")
                    {
                        ApplicationArea = All;
                        Caption = 'E&xport';
                        Promoted = true;
                        PromotedCategory = Process;

                        trigger OnAction()
                        begin
                            ExportTestSuiteSetup;
                        end;
                    }
                    action("I&mport")
                    {
                        ApplicationArea = All;
                        Caption = 'I&mport';

                        trigger OnAction()
                        begin
                            ImportTestSuiteSetup;
                        end;
                    }
                }
                separator(Action15)
                {
                    Caption = 'Separator';
                }
                group(Results)
                {
                    Caption = 'Results';
                    Image = Log;
                    action(Action16)
                    {
                        ApplicationArea = All;
                        Caption = 'E&xport';

                        trigger OnAction()
                        begin
                            ExportTestSuiteResult;
                        end;
                    }
                    action(Action24)
                    {
                        ApplicationArea = All;
                        Caption = 'I&mport';

                        trigger OnAction()
                        begin
                            ImportTestSuiteResult;
                        end;
                    }
                }
            }
        }
    }
}

