#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 130408 "CAL Test Coverage Map"
{
    Caption = 'CAL Test Coverage Map';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "CAL Test Coverage Map";
    SourceTableView = sorting("Object Type", "Object ID");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type"; Rec."Object Type")
                {
                    ApplicationArea = All;
                    Visible = ObjectVisible;
                }
                field("Object ID"; Rec."Object ID")
                {
                    ApplicationArea = All;
                    Visible = ObjectVisible;
                }
                field("Object Name"; Rec."Object Name")
                {
                    ApplicationArea = All;
                    Visible = ObjectVisible;
                }
                field("Hit by Test Codeunits"; Rec."Hit by Test Codeunits")
                {
                    ApplicationArea = All;
                    Visible = ObjectVisible;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowTestCodeunits;
                    end;
                }
                field("Test Codeunit ID"; Rec."Test Codeunit ID")
                {
                    ApplicationArea = All;
                    Visible = TestCodeunitVisible;
                }
                field("Test Codeunit Name"; Rec."Test Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = TestCodeunitVisible;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportExportTestMap)
            {
                ApplicationArea = All;
                Caption = 'Import/Export';
                Image = ImportExport;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"CAL Test Coverage Map");
                end;
            }
            action(ImportFromFolder)
            {
                ApplicationArea = All;
                Caption = 'Import TestMap From Folder';
                Image = ImportExport;
                //The property 'ToolTip' cannot be empty.
                //ToolTip = '';

                trigger OnAction()
                var
                    TempNameValueBuffer: Record "Name/Value Buffer" temporary;
                    FileManagement: Codeunit "File Management";
                    File: File;
                    InStream: InStream;
                    ImportFolderPath: Text;
                    ServerFolderPath: Text;
                begin
                    if FileManagement.SelectFolderDialog(ImportFromFolderLbl, ImportFolderPath) then begin
                        ServerFolderPath := FileManagement.UploadClientDirectorySilent(ImportFolderPath, '*.txt', false);
                        FileManagement.GetServerDirectoryFilesList(TempNameValueBuffer, ServerFolderPath);
                        if TempNameValueBuffer.FindSet then
                            repeat
                                File.Open(TempNameValueBuffer.Name);
                                File.CreateInstream(InStream);
                                Xmlport.Import(Xmlport::"CAL Test Coverage Map", InStream);
                                File.Close;
                            until TempNameValueBuffer.Next = 0;
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        TestCodeunitVisible := Rec.GetFilter("Test Codeunit ID") = '';
        ObjectVisible := (Rec.GetFilter("Object ID") = '') and (Rec.GetFilter("Object Type") = '');
    end;

    var
        ObjectVisible: Boolean;
        TestCodeunitVisible: Boolean;
        ImportFromFolderLbl: label 'Select folder to import TestMaps from';
}

