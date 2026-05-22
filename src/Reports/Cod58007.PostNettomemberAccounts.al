
codeunit 58007 "Post Net to member Accounts"
{
    trigger OnRun()
    var
    begin
        FnPostJournalEntries('PAYMENTS', 'DIVIDEND', 'DIV 2025');
        Message('Posted Successfully');
    end;

    procedure FnPostJournalEntries(TemplateName: Code[50]; BatchName: Code[50]; DocumentNo: Code[30]): Boolean
    var
        GenPost: Codeunit 12;
        GenJournalLine: Record 81;
        Reached: Integer;
        TotalMembers: Integer;
        PercentageDone: Decimal;
        DialogBox: Dialog;
        IsPosted: Boolean;
    begin
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE(GenJournalLine."Journal Template Name", TemplateName);
        GenJournalLine.SETRANGE(GenJournalLine."Journal Batch Name", BatchName);
        GenJournalLine.SETRANGE(GenJournalLine."Document No.", DocumentNo);
        if GenJournalLine.Find('-') then begin
            Reached := 0;
            TotalMembers := 0;
            TotalMembers := GenJournalLine.COUNT();
            PercentageDone := 0;
            if GuiAllowed then
                DialogBox.OPEN('Posting for Line #1#######' + ' Record Number #2#######' + ' of records ' + FORMAT(TotalMembers) + ' at percentage #3#######');
            repeat
                Reached += 1;
                PercentageDone := ROUND((Reached / TotalMembers) * 100, 1, '<');
                DialogBox.UPDATE(1, GenJournalLine."Line No.");
                DialogBox.UPDATE(2, Reached);
                DialogBox.UPDATE(3, PercentageDone);
                GenPost.Run(GenJournalLine);
            until GenJournalLine.Next = 0;
            IsPosted := true;
            if GuiAllowed then
                DialogBox.Close();
            // GenJournalLine.DeleteAll();
        end;
        exit(IsPosted);
    end;

}
