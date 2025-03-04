#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 50019 "Bank Acc. Set Recon.-No. H"
{
    Permissions = TableData "Bank Account Ledger Entry" = rm,
                  TableData "Check Ledger Entry" = rm;

    trigger OnRun()
    begin
    end;

    var
        CheckLedgEntry: Record "Check Ledger Entry";


    procedure ApplyEntries(var BankAccReconLine: Record "Bank Acc. Reconciliation Line"; var BankAccLedgEntry: Record "Bank Account Ledger Entry"; Relation: Option "One-to-One","One-to-Many"): Boolean
    begin
        BankAccLedgEntry.LockTable;
        CheckLedgEntry.LockTable;
        BankAccReconLine.LockTable;
        BankAccReconLine.Find;

        if BankAccLedgEntry.IsApplied then
            exit(false);

        if (Relation = Relation::"One-to-One") and (BankAccReconLine."Applied Entries" > 0) then
            exit(false);

        BankAccReconLine.TestField("Statement Type", BankAccReconLine."statement type"::"Bank Reconciliation");
        BankAccReconLine.TestField("Account Type", BankAccReconLine."Account Type"::"Bank Account");
        BankAccReconLine."Ready for Application" := true;
        SetReconNo(BankAccLedgEntry, BankAccReconLine);
        BankAccReconLine."Applied Amount" += BankAccLedgEntry."Remaining Amount";
        BankAccReconLine."Applied Entries" := BankAccReconLine."Applied Entries" + 1;
        BankAccReconLine.Validate("Statement Amount");
        BankAccReconLine.Reconciled := true;
        BankAccReconLine.Modify;
        exit(true);
    end;


    procedure RemoveApplication(var BankAccLedgEntry: Record "Bank Account Ledger Entry")
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        BankAccStatementLine: Record "Funds User Setup";
    begin
        BankAccLedgEntry.LockTable;
        CheckLedgEntry.LockTable;
        BankAccReconLine.LockTable;

        if not BankAccReconLine.Get(
             BankAccReconLine."statement type"::"Bank Reconciliation",
             BankAccLedgEntry."Bank Account No.",
             BankAccLedgEntry."Statement No.", BankAccLedgEntry."Statement Line No.")
        then
            exit;

        BankAccReconLine.TestField("Statement Type", BankAccReconLine."statement type"::"Bank Reconciliation");
        BankAccReconLine.TestField("Account Type", BankAccReconLine."Account Type"::"Bank Account");
        RemoveReconNo(BankAccLedgEntry, BankAccReconLine, true);

        BankAccReconLine."Applied Amount" -= BankAccLedgEntry."Remaining Amount";
        BankAccReconLine."Applied Entries" := BankAccReconLine."Applied Entries" - 1;
        BankAccReconLine.Reconciled := false;// ** changes

        BankAccReconLine.Validate("Statement Amount");
        BankAccReconLine.Modify;
    end;


    procedure SetReconNo(var BankAccLedgEntry: Record "Bank Account Ledger Entry"; var BankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccLedgEntry.TestField(Open, true);
        BankAccLedgEntry.TestField("Statement Status", BankAccLedgEntry."statement status"::Open);
        BankAccLedgEntry.TestField("Statement No.", '');
        BankAccLedgEntry.TestField("Statement Line No.", 0);
        BankAccLedgEntry.TestField("Bank Account No.", BankAccReconLine."Bank Account No.");
        BankAccLedgEntry."Statement Status" :=
          BankAccLedgEntry."statement status"::"Bank Acc. Entry Applied";
        BankAccLedgEntry."Statement No." := BankAccReconLine."Statement No.";
        BankAccLedgEntry."Statement Line No." := BankAccReconLine."Statement Line No.";
        BankAccLedgEntry.Modify;

        CheckLedgEntry.Reset;
        CheckLedgEntry.SetCurrentkey("Bank Account Ledger Entry No.");
        CheckLedgEntry.SetRange("Bank Account Ledger Entry No.", BankAccLedgEntry."Entry No.");
        CheckLedgEntry.SetRange(Open, true);
        if CheckLedgEntry.Find('-') then
            repeat
                CheckLedgEntry.TestField("Statement Status", CheckLedgEntry."statement status"::Open);
                CheckLedgEntry.TestField("Statement No.", '');
                CheckLedgEntry.TestField("Statement Line No.", 0);
                CheckLedgEntry."Statement Status" :=
                  CheckLedgEntry."statement status"::"Bank Acc. Entry Applied";
                CheckLedgEntry."Statement No." := '';
                CheckLedgEntry."Statement Line No." := 0;
                CheckLedgEntry.Modify;
            until CheckLedgEntry.Next = 0;
    end;


    procedure RemoveReconNo(var BankAccLedgEntry: Record "Bank Account Ledger Entry"; var BankAccReconLine: Record "Bank Acc. Reconciliation Line"; Test: Boolean)
    begin
        BankAccLedgEntry.TestField(Open, true);
        if Test then begin
            BankAccLedgEntry.TestField(
              "Statement Status", BankAccLedgEntry."statement status"::"Bank Acc. Entry Applied");
            BankAccLedgEntry.TestField("Statement No.", BankAccReconLine."Statement No.");
            BankAccLedgEntry.TestField("Statement Line No.", BankAccReconLine."Statement Line No.");
        end;
        BankAccLedgEntry.TestField("Bank Account No.", BankAccReconLine."Bank Account No.");
        BankAccLedgEntry."Statement Status" := BankAccLedgEntry."statement status"::Open;
        BankAccLedgEntry."Statement No." := '';
        BankAccLedgEntry."Statement Line No." := 0;
        BankAccLedgEntry.Modify;

        CheckLedgEntry.Reset;
        CheckLedgEntry.SetCurrentkey("Bank Account Ledger Entry No.");
        CheckLedgEntry.SetRange("Bank Account Ledger Entry No.", BankAccLedgEntry."Entry No.");
        CheckLedgEntry.SetRange(Open, true);
        if CheckLedgEntry.Find('-') then
            repeat
                if Test then begin
                    CheckLedgEntry.TestField(
                      "Statement Status", CheckLedgEntry."statement status"::"Bank Acc. Entry Applied");
                    CheckLedgEntry.TestField("Statement No.", '');
                    CheckLedgEntry.TestField("Statement Line No.", 0);
                end;
                CheckLedgEntry."Statement Status" := CheckLedgEntry."statement status"::Open;
                CheckLedgEntry."Statement No." := '';
                CheckLedgEntry."Statement Line No." := 0;
                CheckLedgEntry.Modify;
            until CheckLedgEntry.Next = 0;
    end;


    procedure ApplyEntries2(var BankAccReconLine: Record "Bank Acc. Reconciliation Line"; var BankAccLedgEntry: Record "Bank Account Ledger Entry"; Relation: Option "One-to-One","One-to-Many"; BankAccStatementLine: Record "Bank Account Statement Line"): Boolean
    begin
        BankAccLedgEntry.LockTable;
        CheckLedgEntry.LockTable;
        BankAccReconLine.LockTable;
        BankAccReconLine.Find;

        if BankAccLedgEntry.IsApplied then
            exit(false);

        if (Relation = Relation::"One-to-One") and (BankAccReconLine."Applied Entries" > 0) then
            exit(false);

        BankAccReconLine.TestField("Account Type", BankAccReconLine."Account Type"::"Bank Account");
        BankAccReconLine."Ready for Application" := true;
        SetReconNo(BankAccLedgEntry, BankAccReconLine);
        BankAccReconLine."Applied Amount" += BankAccLedgEntry."Remaining Amount";
        BankAccReconLine."Applied Entries" := BankAccReconLine."Applied Entries" + 1;
        BankAccReconLine.Reconciled := true;          //**changes
        BankAccReconLine."Statement Line No." := BankAccStatementLine."Statement Line No.";
        BankAccReconLine.Validate("Statement Amount");
        BankAccReconLine.Modify;
        //**changes to include the statement lines
        BankAccStatementLine."Applied Amount" += BankAccLedgEntry."Remaining Amount";
        BankAccStatementLine."Applied Entries" := BankAccStatementLine."Applied Entries" + 1;
        BankAccStatementLine.Validate("Statement Amount");
        BankAccStatementLine.Modify;

        exit(true);
    end;


    procedure RemoveApplication2(var BankAccLedgEntry: Record "Bank Account Ledger Entry")
    var
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        BankAccStatementLine: Record "Bank Account Statement Line";
    begin
        BankAccLedgEntry.LockTable;
        CheckLedgEntry.LockTable;
        BankAccReconLine.LockTable;

        if not BankAccReconLine.Get(
             BankAccReconLine."statement type"::"Bank Reconciliation",
             BankAccLedgEntry."Bank Account No.",
             BankAccLedgEntry."Statement No.", BankAccLedgEntry."Statement Line No.")
        then
            exit;

        BankAccReconLine.TestField("Statement Type", BankAccReconLine."statement type"::"Bank Reconciliation");
        BankAccReconLine.TestField("Account Type", BankAccReconLine."Account Type"::"Bank Account");
        RemoveReconNo(BankAccLedgEntry, BankAccReconLine, true);

        BankAccReconLine."Applied Amount" -= BankAccLedgEntry."Remaining Amount";
        BankAccReconLine."Applied Entries" := BankAccReconLine."Applied Entries" - 1;
        BankAccReconLine.Reconciled := false;//**changes
        BankAccReconLine.Validate("Statement Amount");
        BankAccReconLine.Modify;

        //**changes
        BankAccStatementLine.Reset;
        BankAccStatementLine.SetRange("Bank Account No.", BankAccReconLine."Bank Account No.");
        BankAccStatementLine.SetRange("Statement No.", BankAccReconLine."Statement No.");
        BankAccStatementLine.SetRange("Statement Line No.", BankAccReconLine."Bank Statement Entry Line No");
        if BankAccStatementLine.FindFirst then begin
            BankAccStatementLine."Applied Amount" -= BankAccLedgEntry."Remaining Amount";
            BankAccStatementLine."Applied Entries" := BankAccStatementLine."Applied Entries" - 1;

            BankAccStatementLine.Validate("Statement Amount");
            BankAccStatementLine.Modify;
        end
    end;
}

