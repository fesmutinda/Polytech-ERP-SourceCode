codeunit 50053 "GenerateLoanInterestDue"
{
    trigger OnRun()
    begin

    end;

    procedure FnGenerateFOSALoansInterest()
    begin
        DocNo := '';
        DocNo := FnGetDocNo();
        LoansRegister.Reset();
        LoansRegister.SetRange(LoansRegister.Source, LoansRegister.Source::FOSA);
        LoansRegister.SetRange(LoansRegister."Check Int", false);
        LoansRegister.SetRange(LoansRegister."Loan Product Type", 'INUA BIASHARA');
        LoansRegister.SetAutoCalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
        LoansRegister.SetFilter(LoansRegister."Outstanding Balance", '>%1', 0);
        IF LoansRegister.Find('-') THEN begin
            repeat
                //----------------//Dont run interest for loans that members are marked as Deceased,loans that are expired and interest outstanding>=loan balance
                if (LoansRegister."Outstanding Balance" > LoansRegister."Oustanding Interest") and (FnMemberIsDeceased(LoansRegister."Client Code")) = false then begin
                    //Charge Interest
                    if FnIsInterestRun(DocNo, LoansRegister."Loan  No.", LoansRegister."Client Code") = false then begin
                        if ((DATE2DMY(Today, 1)) = DATE2DMY(LoansRegister."Loan Disbursement Date", 1)) and (CalcDate('1M', LoansRegister."Loan Disbursement Date") <= Today) then begin
                            FnInsertGlEntries();
                        end;
                        //<>Direct Debits on 15th
                        // if ((15) = DATE2DMY(Today, 1)) and (CalcDate('1M', LoansRegister."Loan Disbursement Date") <= Today) and (LoansRegister."Recovery Mode" <> LoansRegister."Recovery Mode"::"Direct Debits") then begin
                        //     FnInsertGlEntries();
                        // end;
                    end;
                end;
            until LoansRegister.Next = 0;
        end;
    end;

    procedure FnGenerateBOSALoansInterest()
    var
    begin
        DocNo := '';
        DocNo := FnGetDocNo();
        LoansRegister.Reset();
        LoansRegister.SetRange(LoansRegister.Source, LoansRegister.Source::BOSA);
        LoansRegister.SetRange(LoansRegister."Check Int", false);
        //LoansRegister.SetFilter(LoansRegister."Issued Date", '%1..%2', 0D, Today);
        LoansRegister.SetAutoCalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
        LoansRegister.SetFilter(LoansRegister."Outstanding Balance", '>%1', 0);
        IF LoansRegister.Find('-') THEN begin
            repeat
                //----------------//Dont run interest for loans that members are marked as Deceased,loans that are expired and interest outstanding>=loan balance
                if (LoansRegister."Outstanding Balance" > LoansRegister."Oustanding Interest") and (FnMemberIsDeceased(LoansRegister."Client Code")) = false then begin
                    //Charge Interest
                    //=Direct Debits is daily
                    // if ((DATE2DMY(Today, 1)) = DATE2DMY(LoansRegister."Loan Disbursement Date", 1)) and (LoansRegister."Loan Disbursement Date" <> Today) and (LoansRegister."Loan Disbursement Date" <> Today) and (LoansRegister."Recovery Mode"=LoansRegister."Recovery Mode"::"Direct Debits")then begin
                    //     FnInsertGlEntries();
                    // end;
                    if FnIsInterestRun(DocNo, LoansRegister."Loan  No.", LoansRegister."Client Code") = false then begin
                        if ((DATE2DMY(Today, 1)) = DATE2DMY(LoansRegister."Loan Disbursement Date", 1)) and (CalcDate('1M', LoansRegister."Loan Disbursement Date") <= Today) then begin
                            FnInsertGlEntries();
                        end;
                        //<>Direct Debits on 15th
                        // if ((15) = DATE2DMY(Today, 1)) and (CalcDate('1M', LoansRegister."Loan Disbursement Date") <= Today) and (LoansRegister."Recovery Mode" <> LoansRegister."Recovery Mode"::"Direct Debits") then begin
                        //     FnInsertGlEntries();
                        // end;
                    end;
                end;
            until LoansRegister.Next = 0;
        end;
    end;

    procedure FnGenerateMICROLoansInterest()
    begin
        DocNo := '';
        DocNo := FnGetDocNo();
        LoansRegister.Reset();
        LoansRegister.SetRange(LoansRegister.Source, LoansRegister.Source::MICRO);
        LoansRegister.SetRange(LoansRegister."Check Int", false);
        LoansRegister.SetFilter(LoansRegister."Issued Date", '%1..%2', 0D, 20230805D);
        LoansRegister.SetAutoCalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
        LoansRegister.SetFilter(LoansRegister."Outstanding Balance", '>%1', 0);
        IF LoansRegister.Find('-') THEN begin
            repeat
                //----------------//Dont run interest for loans that members are marked as Deceased,loans that are expired and interest outstanding>=loan balance
                if (LoansRegister."Outstanding Balance" > LoansRegister."Oustanding Interest") and (FnMemberIsDeceased(LoansRegister."Client Code")) = false then begin
                    if FnIsInterestRun(DocNo, LoansRegister."Loan  No.", LoansRegister."Client Code") = false then begin
                        FnInsertGlEntries();
                    end;
                    //Charge Interest
                end;
            until LoansRegister.Next = 0;
        end;
    end;

    local procedure FnMemberIsDeceased(ClientCode: Code[50]): Boolean
    var
        Customer: record customer;
    begin
        Customer.Reset();
        Customer.SetRange(Customer."No.", ClientCode);
        if Customer.find('-') then begin
            if Customer.Status = Customer.status::Deceased then begin
                exit(true);
            end;
        end;
        exit(false);
    end;

    procedure FnInitiateGLs()
    begin
        //delete journal line
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'General');
        GenJournalLine.SETRANGE("Journal Batch Name", 'INT DUE');
        GenJournalLine.DELETEALL;

        GenBatches.RESET;
        GenBatches.SETRANGE(GenBatches."Journal Template Name", 'General');
        GenBatches.SETRANGE(GenBatches.Name, 'INT DUE');
        IF GenBatches.FIND('-') = FALSE THEN BEGIN
            GenBatches.INIT;
            GenBatches."Journal Template Name" := 'General';
            GenBatches.Name := 'INT DUE';
            GenBatches.Description := 'Interest Due';
            GenBatches.INSERT;
        END;
    end;

    local procedure FnInsertGlEntries()
    begin
        LineNo := LineNo + 10000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name" := 'General';
        GenJournalLine."Journal Batch Name" := 'INT DUE';
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := LoansRegister."Client Code";
        GenJournalLine."Transaction Type" := GenJournalLine."Transaction Type"::"Interest Due";
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Document No." := DocNo;
        GenJournalLine."Posting Date" := Today;
        GenJournalLine.Description := DocNo + ' ' + 'Interest charged';
        GenJournalLine.Amount := ROUND(LoansRegister."Outstanding Balance" * (LoansRegister.Interest / 1200), 0.05, '>');
        IF LoansRegister."Repayment Method" = LoansRegister."Repayment Method"::"Straight Line" THEN
            GenJournalLine.Amount := ROUND(LoansRegister."Approved Amount" * (LoansRegister.Interest / 1200), 0.05, '>');
        IF LoansRegister.Source = LoansRegister.Source::MICRO THEN BEGIN
            GenJournalLine.Amount := Round((LoansRegister."Approved Amount" * (17 / 100) * (LoansRegister.Installments / 12) / LoansRegister.Installments), 0.05, '>');
        END;
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        IF LoanType.GET(LoansRegister."Loan Product Type") THEN BEGIN
            GenJournalLine."Bal. Account Type" := GenJournalLine."Bal. Account Type"::"G/L Account";
            GenJournalLine."Bal. Account No." := LoanType."Loan Interest Account";
            GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
        END;
        IF LoansRegister.Source = LoansRegister.Source::BOSA THEN BEGIN
            GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
        END ELSE
            IF LoansRegister.Source = LoansRegister.Source::FOSA THEN BEGIN
                GenJournalLine."Shortcut Dimension 1 Code" := 'FOSA';
            END ELSE
                IF LoansRegister.Source = LoansRegister.Source::MICRO THEN
                    GenJournalLine."Shortcut Dimension 1 Code" := 'MICRO';
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
        GenJournalLine."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoansRegister."Client Code");
        GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
        GenJournalLine."Loan No" := LoansRegister."Loan  No.";
        IF (GenJournalLine.Amount <> 0) THEN
            GenJournalLine.INSERT;
    end;

    local procedure FnGetMemberBranch(ClientCode: Code[50]): Code[20]
    var
        Cust: Record Customer;
    begin
        Cust.RESET;
        Cust.SETRANGE(Cust."No.", ClientCode);
        IF Cust.FIND('-') THEN BEGIN
            EXIT(Cust."Global Dimension 2 Code");
        END;
    end;

    local procedure FnGetDocNo(): Text
    begin
        case DATE2DMY(Today, 2) of
            1:
                begin
                    exit('Jan-' + Format(DATE2DMY(Today, 3)))
                end;
            2:
                begin
                    exit('Feb-' + Format(DATE2DMY(Today, 3)))
                end;
            3:
                begin
                    exit('March-' + Format(DATE2DMY(Today, 3)))
                end;
            4:
                begin
                    exit('April-' + Format(DATE2DMY(Today, 3)))
                end;
            5:
                begin
                    exit('May-' + Format(DATE2DMY(Today, 3)))
                end;
            6:
                begin
                    exit('June-' + Format(DATE2DMY(Today, 3)))
                end;
            7:
                begin
                    exit('July-' + Format(DATE2DMY(Today, 3)))
                end;
            8:
                begin
                    exit('Aug-' + Format(DATE2DMY(Today, 3)))
                end;
            9:
                begin
                    exit('Sep-' + Format(DATE2DMY(Today, 3)))
                end;
            10:
                begin
                    exit('Oct-' + Format(DATE2DMY(Today, 3)))
                end;
            11:
                begin
                    exit('Nov-' + Format(DATE2DMY(Today, 3)))
                end;
            12:
                begin
                    exit('Dec-' + Format(DATE2DMY(Today, 3)))
                end;
        end;
    end;

    procedure FnAutoPostGls()
    var
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJournalLine.RESET;
        GenJournalLine.SETRANGE("Journal Template Name", 'General');
        GenJournalLine.SETRANGE("Journal Batch Name", 'INT DUE');
        IF GenJournalLine.FIND('-') THEN BEGIN
            REPEAT
                GLPosting.RUN(GenJournalLine);
            UNTIL GenJournalLine.NEXT = 0;
            //Send Email of posted Entries
            FnSendEmail();
            //...................................Delete Entries
            GenJournalLine.RESET;
            GenJournalLine.SETRANGE(GenJournalLine."Journal Template Name", 'GENERAL');
            GenJournalLine.SETRANGE(GenJournalLine."Journal Batch Name", 'INT DUE');
            IF GenJournalLine.Find('-') THEN begin
                GenJournalLine.DeleteAll();
            end;
        end;
    end;

    local procedure FnSendEmail()
    begin
        //Message('Email Part Not created');
    end;

    local procedure FnScheduleRepaymentDate(LoanNo: Code[30]): Boolean
    var
        LoansRepaymentSchedule: Record "Loan Repayment Schedule";
    begin
        LoansRepaymentSchedule.Reset();
        LoansRepaymentSchedule.SetRange(LoansRepaymentSchedule."Loan No.", LoanNo);
        LoansRepaymentSchedule.SetRange(LoansRepaymentSchedule."Repayment Date", Today);
        if LoansRepaymentSchedule.Find('-') then begin
            exit(true);
        end;
        exit(false);
    end;

    local procedure FnIsInterestRun(DocNo: Text; LoanNo: Code[30]; ClientCode: Code[50]): Boolean
    var
        CustLedgerEntry: record "Cust. Ledger Entry";
        IsRun: Boolean;
    begin
        IsRun := false;
        CustLedgerEntry.Reset();
        CustLedgerEntry.SetRange(CustLedgerEntry."Loan No", LoanNo);
        CustLedgerEntry.SetRange(CustLedgerEntry."Transaction Type", CustLedgerEntry."Transaction Type"::"Interest Due");
        CustLedgerEntry.SetRange(CustLedgerEntry."Document No.", DocNo);
        //CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", ClientCode);
        if CustLedgerEntry.Find('-') then begin
            IsRun := true;
        end;
        exit(IsRun);
    end;

    ///--------------------------------------------------------------------------
    ///
    // procedure FnMarkBatchLoansAsPosted()
    // var
    //     PostedBatchList: Record "Loan Disburesment-Batching";
    //     LoansRegister: record "Loans Register";
    // begin
    //     PostedBatchList.Reset();
    //     PostedBatchList.SetRange(PostedBatchList.Posted, true);
    //     //PostedBatchList.SetRange(PostedBatchList."Batch No.", 'LBCH014912');
    //     PostedBatchList.SetRange(PostedBatchList.Source, PostedBatchList.Source::MICRO);
    //     PostedBatchList.SetFilter(PostedBatchList."Posting Date", '%1..%2', 20230807D, Today);
    //     IF PostedBatchList.Find('-') THEN begin
    //         repeat
    //             LoansRegister.Reset();
    //             LoansRegister.SetRange(LoansRegister."Batch No.", PostedBatchList."Batch No.");
    //             if LoansRegister.Find('-') then begin
    //                 repeat
    //                     LoansRegister."Issued Date" := PostedBatchList."Posting Date";
    //                     LoansRegister.Advice := true;
    //                     LoansRegister."Advice Type" := LoansRegister."advice type"::"Fresh Loan";
    //                     LoansRegister.Posted := true;
    //                     LoansRegister."Posting Date" := LoansRegister."Issued Date";
    //                     LoansRegister."Loan Interest Repayment" := ((LoansRegister."Approved Amount") * LoansRegister.Installments / 12 * (LoansRegister.Interest / 100));
    //                     LoansRegister."Loan Status" := LoansRegister."loan status"::Issued;
    //                     LoansRegister.Modify;
    //                 until LoansRegister.Next = 0;
    //             end;
    //         UNTIL PostedBatchList.Next = 0;
    //     end;
    // end;

    var
        GenJournalLine: Record "Gen. Journal Line";
        GenBatches: Record "Gen. Journal Batch";
        LineNo: Integer;
        LoansRegister: Record "Loans Register";
        LoanType: Record "Loan Products Setup";
        DocNo: text;

}
