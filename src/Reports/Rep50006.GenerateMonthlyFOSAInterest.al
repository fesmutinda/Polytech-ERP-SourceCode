/* Report 50006 "Generate Monthly FOSA Interest"
{
    ApplicationArea = All;
    Caption = 'Generate Monthly FOSA Interest';
    UsageCategory = Tasks;
    ProcessingOnly = true;
    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No; "No.")
            {
            }
            trigger OnPreDataItem()
            begin
                BATCH_TEMPLATE := 'GENERAL';
                BATCH_NAME := 'INT_EARNED';
                SN := SN + 1;
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name", BATCH_TEMPLATE);
                GenJournalLine.SETRANGE("Journal Batch Name", BATCH_NAME);
                GenJournalLine.DELETEALL;

                DocNo := 'INT EARNED';
                DOCUMENT_NO := 'INT EARNED';
                IF PDate = 0D THEN
                    PDate := TODAY;

                // InterestBuffer.RESET;
                // InterestBuffer.SETRANGE(InterestBuffer."Document No", DOCUMENT_NO);
                // IF InterestBuffer.FIND('-') THEN
                //     InterestBuffer.DELETEALL;
                AsAt := 20230831D;
                IF PDate = 0D THEN
                    PDate := AsAt;

                InterestBuffer.RESET;
                IF InterestBuffer.FIND('+') THEN
                    IntBufferNo := InterestBuffer.No;


                StartDate := CALCDATE('-CM', AsAt);
                IntDays := (AsAt - StartDate) + 1;
            end;

            trigger OnAfterGetRecord()
            begin
                IntRate := 0;
                AccruedInt := 0;
                MidMonthFactor := 1;
                MinBal := FALSE;
                RIntDays := IntDays;
                AsAt := StartDate;
                Vendor.SetFilter(Vendor."Account Type", '%1|%2|%3', 'ORDINARY', 'JUNIOR', 'JAZA');
                IF AccountType.GET(Vendor."Account Type") THEN BEGIN
                    IF AccountType."Earns Interest" = TRUE THEN BEGIN
                        REPEAT
                            RIntDays := RIntDays - 1;
                            DFilter := '..' + FORMAT(AsAt);
                            Cust.RESET;
                            Cust.SETRANGE(Cust."No.", Vendor."No.");
                            Cust.SETFILTER(Cust."Date Filter", DFilter);
                            IF Cust.FIND('-') THEN BEGIN
                                Cust.CALCFIELDS(Cust."FOSA Balance");
                                Bal := Cust."FOSA Balance";
                                Cust."Not Qualify for Interest" := FALSE;
                                IF Cust."FOSA Balance" <= AccountType."Interest Calc Min Balance" THEN BEGIN
                                    Cust."Not Qualify for Interest" := TRUE;
                                    Cust.MODIFY;
                                END
                                ELSE
                                    IF ((Cust."FOSA Balance" >= AccountType."Interest Calc Min Balance") AND (NOT Cust."Not Qualify for Interest")) THEN BEGIN
                                        IF AccountType."Fixed Deposit" = TRUE THEN BEGIN
                                            FDInterestCalc.RESET;
                                            FDInterestCalc.SETRANGE(FDInterestCalc.Code, Vendor."Fixed Deposit Type");
                                            IF FDInterestCalc.FIND('-') THEN BEGIN
                                                REPEAT
                                                    IF (FDInterestCalc."Minimum Amount" <= Cust."FOSA Balance") AND (Cust."FOSA Balance" <= FDInterestCalc."Maximum Amount") THEN
                                                        IntRate := FDInterestCalc."Interest Rate";
                                                UNTIL FDInterestCalc.NEXT = 0;
                                            END;
                                        END
                                        ELSE BEGIN
                                            AccountType.TESTFIELD(AccountType."Interest Rate");
                                            IntRate := AccountType."Interest Rate";
                                        END;
                                        IF AccountType."Fixed Deposit" = FALSE THEN BEGIN
                                            IF ((Cust."FOSA Balance" >= AccountType."Interest Calc Min Balance") AND (NOT Cust."Not Qualify for Interest")) THEN BEGIN
                                                AccruedInt := AccruedInt + ((IntRate / 36500) * Cust."FOSA Balance");
                                            END;
                                        END;
                                    END;
                            END
                            ELSE BEGIN
                                MinBal := TRUE;
                            END;
                            AsAt := CALCDATE('1D', AsAt);
                        UNTIL RIntDays = 0;
                        IF MinBal = TRUE THEN
                            AccruedInt := 0;

                        IF AccruedInt > 0 THEN BEGIN
                            //1.-------------------------------------------PAY INTEREST-------------------------------------------------
                            LineNo := LineNo + 10000;
                            SFactory.FnCreateGnlJournalLineBalancedFOSA(BATCH_TEMPLATE, BATCH_NAME, DOCUMENT_NO, LineNo, GenJournalLine."Transaction Type"::"0", GenJournalLine."Account Type"::Vendor,
                            Vendor."No.", 20230831D, ROUND(AccruedInt, 0.05, '>') * -1, Vendor, Vendor."No.", 'Interest earned', '',
                            GenJournalLine."Account Type"::"G/L Account", AccountType."Interest Expense Account");

                            //2.--------------------------------------------RECOVER INTEREST-----------------------------------------------------
                            LineNo := LineNo + 10000;
                            SFactory.FnCreateGnlJournalLineBalancedFOSA(BATCH_TEMPLATE, BATCH_NAME, DOCUMENT_NO, LineNo, GenJournalLine."Transaction Type"::"0", GenJournalLine."Account Type"::Vendor,
                            Vendor."No.", 20230831D, ROUND((AccruedInt * AccountType."Tax On Interest" / 100), 0.05, '>'), Vendor, Vendor."No.", 'Witholding Tax on Int', '',
                            GenJournalLine."Account Type"::"G/L Account", AccountType."Interest Tax Account");

                        END;
                    END;
                END;
            end;

            trigger OnPostDataItem()
            begin
                Message('Done');
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    var
        GenJournalLine: RECORD "Gen. Journal Line";
        DocNo: Code[10];
        PDate: Date;
        InterestBuffer: RECORD "Interest Buffer";
        IntBufferNo: Integer;
        StartDate: Date;
        IntDays: Integer;
        //..........................
        IntRate: Decimal;
        AccruedInt: Decimal;
        MidMonthFactor: Decimal;
        MinBal: Boolean;
        RIntDays: Integer;
        AsAt: date;
        LowestBal: Decimal;
        Bal: Decimal;
        AccountType: Record "Account Types-Saving Products";
        DFilter: Text;
        Cust: Record Customer;
        LineNo: Integer;
        BATCH_TEMPLATE: CODE[50];
        BATCH_NAME: CODE[50];
        SN: Integer;
        SFactory: Codeunit "SURESTEP Factory";
        FDInterestCalc: Record "FD Interest Calculation Criter";
        DOCUMENT_NO: Code[10];
}
 */