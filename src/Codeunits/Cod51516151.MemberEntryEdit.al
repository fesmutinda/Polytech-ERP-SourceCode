#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51516151 "Member. Entry-Edit"
{
    Permissions = TableData "Cust. Ledger Entry" = imd,
                  TableData "Detailed Cust. Ledg. Entry" = m;
    TableNo = 51516365;

    trigger OnRun()
    begin
        CustLedgEntry := Rec;
        CustLedgEntry.LockTable;
        CustLedgEntry.Find;
        CustLedgEntry."On Hold" := Rec."On Hold";
        if CustLedgEntry.Open then begin
            CustLedgEntry."Due Date" := Rec."Due Date";
            // DtldCustLedgEntry.SETCURRENTKEY("Cust. Ledger Entry No.");
            // DtldCustLedgEntry.SETRANGE("Cust. Ledger Entry No.",CustLedgEntry."Entry No.");
            // DtldCustLedgEntry.MODIFYALL("Initial Entry Due Date","Due Date");
            CustLedgEntry."Pmt. Discount Date" := Rec."Pmt. Discount Date";
            CustLedgEntry."Applies-to ID" := Rec."Applies-to ID";
            CustLedgEntry.Validate("Remaining Pmt. Disc. Possible", Rec."Remaining Pmt. Disc. Possible");
            CustLedgEntry."Pmt. Disc. Tolerance Date" := Rec."Pmt. Disc. Tolerance Date";
            CustLedgEntry.Validate("Max. Payment Tolerance", Rec."Max. Payment Tolerance");
            CustLedgEntry.Validate("Accepted Payment Tolerance", Rec."Accepted Payment Tolerance");
            CustLedgEntry.Validate("Accepted Pmt. Disc. Tolerance", Rec."Accepted Pmt. Disc. Tolerance");
            CustLedgEntry.Validate("Amount to Apply", Rec."Amount to Apply");
            CustLedgEntry.Validate("Applying Entry", Rec."Applying Entry");
        end;
        CustLedgEntry.Modify;
        Rec := CustLedgEntry;
    end;

    var
        CustLedgEntry: Record 51516365;
        DtldCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
}

