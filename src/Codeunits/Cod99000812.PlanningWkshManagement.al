#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000812 PlanningWkshManagement
{

    trigger OnRun()
    begin
    end;

    var
        LastReqLine: Record "Requisition Line";

    procedure SetName(CurrentWkshBatchName: Code[10];var ReqLine: Record "Requisition Line")
    begin
        ReqLine.FilterGroup(2);
        ReqLine.SetRange("Journal Batch Name",CurrentWkshBatchName);
        ReqLine.FilterGroup(0);
        if ReqLine.Find('-') then;
    end;

    procedure GetDescriptionAndRcptName(var ReqLine: Record "Requisition Line";var ItemDescription: Text[50];var RoutingDescription: Text[50])
    var
        Item: Record Item;
        RtngHeader: Record "Routing Header";
    begin
        if ReqLine."No." = '' then
          ItemDescription := ''
        else
          if ReqLine."No." <> LastReqLine."No." then begin
            if Item.Get(ReqLine."No.") then
              ItemDescription := Item.Description
            else
              ItemDescription := '';
          end;

        if ReqLine."Routing No." = '' then
          RoutingDescription := ''
        else
          if ReqLine."Routing No." <> LastReqLine."Routing No." then begin
            if RtngHeader.Get(ReqLine."Routing No.") then
              RoutingDescription := RtngHeader.Description
            else
              RoutingDescription := '';
          end;

        LastReqLine := ReqLine;
    end;
}

