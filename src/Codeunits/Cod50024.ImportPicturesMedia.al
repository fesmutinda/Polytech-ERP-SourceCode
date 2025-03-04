#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 50024 "Import Pictures Media"
{

    trigger OnRun()
    var
        FileManagement: Codeunit "File Management";
        FileName: Text;
        ClientFileName: Text;
    begin
        ObjMember.Reset;
        ObjMember.SetRange("No.", '');

        if ObjMember.Image.HasValue then// > 0 then
            /*IF NOT CONFIRM(OverrideImageQst) THEN
              ERROR('');*/

        ClientFileName := 'C:\Users\User\Pictures\Camera Roll\test.jpg';
        FileName := FileManagement.UploadFile('', ClientFileName);//SelectPictureTxt
        if FileName = '' then
            Error('');

        Clear(ObjMember.Image);
        ObjMember.Image.ImportFile(FileName, ClientFileName);
        if not ObjMember.Insert(true) then
            ObjMember.Modify(true);

        if FileManagement.DeleteServerFile(FileName) then;

    end;

    var
        CameraAvailable: Boolean;
        DeleteExportEnabled: Boolean;
        HideActions: Boolean;
        ObjMember: Record Customer;
}

