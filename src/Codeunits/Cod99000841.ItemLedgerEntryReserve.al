#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 99000841 "Item Ledger Entry-Reserve"
{
    Permissions = TableData "Reservation Entry"=rimd;

    trigger OnRun()
    begin
    end;

    procedure FilterReservFor(var FilterReservEntry: Record "Reservation Entry";ItemLedgEntry: Record "Item Ledger Entry")
    begin
        FilterReservEntry.SetSourceFilter(Database::"Item Ledger Entry",0,'',ItemLedgEntry."Entry No.",false);
        FilterReservEntry.SetSourceFilter2('',0);
    end;

    procedure Caption(ItemLedgEntry: Record "Item Ledger Entry") CaptionText: Text[80]
    begin
        CaptionText :=
          StrSubstNo(
            '%1 %2',ItemLedgEntry.TableCaption,ItemLedgEntry."Entry No.");
    end;
}

