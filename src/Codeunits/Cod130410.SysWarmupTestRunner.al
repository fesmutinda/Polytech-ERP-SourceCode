#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 130410 "Sys. Warmup Test Runner"
{
    Subtype = TestRunner;
    TestIsolation = Codeunit;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"Sys. Warmup Scenarios");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyOpen', '', true, true)]
    local procedure WarmUpOnAfterCompanyOpen()
    var
        O365GettingStarted: Record "O365 Getting Started";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
        PermissionManager: Codeunit "Permission Manager";
    begin
        if not GuiAllowed then
          exit;

        if not CompanyInformationMgt.IsDemoCompany then
          exit;

        if not PermissionManager.SoftwareAsAService then
          exit;

        if not O365GettingStarted.IsEmpty then
          exit;

        if not TaskScheduler.CanCreateTask then
          exit;

        TaskScheduler.CreateTask(Codeunit::"Sys. Warmup Test Runner",0,true,COMPANYNAME,CurrentDatetime + 10000); // Add 10s
    end;
}

