#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 56109 "Prorate Dividends Processing"
{

    trigger OnRun()
    begin
        // DividendsProgressionTable.RESET;
        // DividendsProgressionTable.DELETEALL;
        // //FnProcessMemberDividends('02854',20230101D,TODAY,'2024');
        // MESSAGE('Done');

        //MemberTable.CALCFIELDS(MemberTable."Current Shares",MemberTable."Shares Retained",MemberTable."Khoja Shares");
    end;

    var
        DividendsProgressionTable: Record "Dividends Progression Prorated";


    procedure FnProcessMemberDividends(MemberNo: Code[50]; StartDate: Date; PostingDate: Date; DivYear: Code[50]): Decimal
    var
        I: Integer;
        MemberTable: Record Customer;
        LoopMonth: Text;
        EndMonthOfPeriod: Date;
        QualifyingShareCapital: Decimal;
        QualifyingDeposits: Decimal;
        RecoveredAmount: Decimal;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CompleteYear: Text;
        KhojaRecovered: Decimal;
        ShareCapRecovered: Decimal;
    begin
        EndMonthOfPeriod := 0D;
        RecoveredAmount := 0;
        KhojaRecovered := 0;
        ShareCapRecovered := 0;
        EndMonthOfPeriod := CalcDate('CM', StartDate);
        CompleteYear := '';
        CompleteYear := Format(StartDate) + '..' + Format(CalcDate('CY', StartDate));
        MemberTable.Reset;
        MemberTable.SetRange(MemberTable."No.", MemberNo);
        if MemberTable.Find('-') then begin
            //Deposits
            CustLedgerEntry.Reset;
            CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", MemberNo);
            CustLedgerEntry.SetFilter(CustLedgerEntry."Posting Date", CompleteYear);
            CustLedgerEntry.SetFilter(CustLedgerEntry."Amount Posted", '>%1', 0);
            CustLedgerEntry.SetRange(CustLedgerEntry.Reversed, false);
            CustLedgerEntry.SetRange(CustLedgerEntry."Transaction Type", CustLedgerEntry."transaction type"::"Deposit Contribution");
            if CustLedgerEntry.Find('-') then begin
                repeat
                    RecoveredAmount += CustLedgerEntry."Amount Posted";
                until CustLedgerEntry.Next = 0;
            end;

            //.............Share cap recovered
            CustLedgerEntry.Reset;
            CustLedgerEntry.SetRange(CustLedgerEntry."Customer No.", MemberNo);
            CustLedgerEntry.SetFilter(CustLedgerEntry."Posting Date", CompleteYear);
            CustLedgerEntry.SetFilter(CustLedgerEntry."Amount Posted", '>%1', 0);
            CustLedgerEntry.SetRange(CustLedgerEntry.Reversed, false);
            CustLedgerEntry.SetRange(CustLedgerEntry."Transaction Type", CustLedgerEntry."transaction type"::"Share Capital");
            if CustLedgerEntry.Find('-') then begin
                repeat
                    ShareCapRecovered += CustLedgerEntry."Amount Posted";
                until CustLedgerEntry.Next = 0;
            end;
            //...................Loop 12 Times start
            for I := 12 downto 1 do begin
                LoopMonth := '';
                LoopMonth := Format(I) + 'M';
                if I = 12 then begin
                    MemberTable.SetFilter(MemberTable."Date Filter", '%1..%2', 0D, EndMonthOfPeriod);
                    MemberTable.CalcFields(MemberTable."Current Shares", MemberTable."Shares Retained");
                    QualifyingShareCapital := 0;
                    QualifyingDeposits := 0;
                    if MemberTable."Current Shares" <> 0 then QualifyingDeposits := MemberTable."Current Shares";
                    if MemberTable."Shares Retained" <> 0 then QualifyingShareCapital := MemberTable."Shares Retained";
                    FnProcessMemberEarnings(DivYear, MemberNo, 0D, EndMonthOfPeriod, QualifyingDeposits, QualifyingShareCapital, 1, 0, 0, 0);
                    //MESSAGE('Qualifying Shares for the period  %1 are  %2',EndMonthOfPeriod,QualifyingDeposits);
                end else if I <> 12 then begin
                    LoopMonth := '';
                    LoopMonth := Format(12 - I) + 'M';
                    MemberTable.SetFilter(MemberTable."Date Filter", '%1..%2', 0D, CalcDate('CM', CalcDate(LoopMonth, EndMonthOfPeriod)));
                    MemberTable.CalcFields(MemberTable."Current Shares", MemberTable."Shares Retained");
                    QualifyingShareCapital := 0;
                    QualifyingDeposits := 0;
                    if MemberTable."Current Shares" <> 0 then QualifyingDeposits := MemberTable."Current Shares";
                    if MemberTable."Shares Retained" <> 0 then QualifyingShareCapital := MemberTable."Shares Retained";
                    FnProcessMemberEarnings(DivYear, MemberNo, 0D, CalcDate('CM', CalcDate(LoopMonth, EndMonthOfPeriod)), QualifyingDeposits, QualifyingShareCapital, 1, 0, 0, 0);
                    // MESSAGE('Qualifying Shares for the period  %1 ...%2 are  %3',CALCDATE('-CM',CALCDATE(LoopMonth,EndMonthOfPeriod)),CALCDATE('CM',CALCDATE(LoopMonth,EndMonthOfPeriod)),QualifyingDeposits)

                end;
            end;
            //...................Loop 12 Times stop
        end;
    end;


    procedure FnResetTable(MemberNo: Code[40]; DivYear: Code[30])
    begin
        DividendsProgressionTable.Reset;
        DividendsProgressionTable.SetRange(DividendsProgressionTable."Dividend Year", DivYear);
        if DividendsProgressionTable.Find('-') then begin
            DividendsProgressionTable.DeleteAll;
        end;
    end;

    local procedure FnProcessMemberEarnings(DivYear: Code[30]; MemberNo: Code[30]; PeriodStart: Date; PeriodEnd: Date; QualifyingDeposits: Decimal; QualifyingShareCapital: Decimal; Numerator: Integer; RecoveredAmountInTheYear: Decimal; KhodjaRecovered: Decimal; ShareCapRecovered: Decimal)
    var
        SaccoGenSetUp: Record "Sacco General Set-Up";
    begin
        SaccoGenSetUp.Get();
        DividendsProgressionTable.Reset;
        DividendsProgressionTable.Init;
        DividendsProgressionTable."Dividend Year" := DivYear;
        DividendsProgressionTable."Member No" := MemberNo;
        DividendsProgressionTable."Start Period" := PeriodStart;
        DividendsProgressionTable."End Period" := PeriodEnd;
        //Share Capital
        DividendsProgressionTable."Qualifying Share Capital" := ROUND(QualifyingShareCapital, 0.05, '<');
        if ShareCapRecovered <= 0 then begin
            DividendsProgressionTable."Gross Div On Share Capital" := ROUND(((SaccoGenSetUp."Dividend (%)" / 100) * DividendsProgressionTable."Qualifying Share Capital") * Numerator / 12, 0.05, '<');
        end else if ShareCapRecovered > 0 then begin
            DividendsProgressionTable."Gross Div On Share Capital" := ROUND(((SaccoGenSetUp."Dividend (%)" / 100) * (DividendsProgressionTable."Qualifying Share Capital" - RecoveredAmountInTheYear)) * Numerator / 12, 0.05, '<');
        end;
        if DividendsProgressionTable."Gross Div On Share Capital" < 0 then DividendsProgressionTable."Gross Div On Share Capital" := 0;
        DividendsProgressionTable."WHT On Share Capital" := ROUND((SaccoGenSetUp."Withholding Tax (%)" / 100) * DividendsProgressionTable."Gross Div On Share Capital", 0.05, '<');
        DividendsProgressionTable."Net Div On Share Capital" := ROUND(DividendsProgressionTable."Gross Div On Share Capital" - DividendsProgressionTable."WHT On Share Capital", 0.05, '<');
        //Deposits
        DividendsProgressionTable."Qualifying Deposits" := ROUND(QualifyingDeposits, 0.05, '<');
        if RecoveredAmountInTheYear <= 0 then begin
            DividendsProgressionTable."Gross Interest On Deposits" := ROUND((SaccoGenSetUp."Interest on Deposits (%)" / 100) * DividendsProgressionTable."Qualifying Deposits" * Numerator / 12, 0.05, '<');
        end else if RecoveredAmountInTheYear > 0 then begin
            DividendsProgressionTable."Gross Interest On Deposits" := ROUND((SaccoGenSetUp."Interest on Deposits (%)" / 100) * (DividendsProgressionTable."Qualifying Deposits" - RecoveredAmountInTheYear) * Numerator / 12, 0.05, '<');
        end;
        if DividendsProgressionTable."Gross Interest On Deposits" < 0 then DividendsProgressionTable."Gross Interest On Deposits" := 0;
        //MESSAGE('%1...%2..%3',SaccoGenSetUp."Interest on Deposits (%)",DividendsProgressionTable."Qualifying Deposits",Numerator);
        DividendsProgressionTable."WHT On Interest On Deposits" := ROUND((SaccoGenSetUp."Withholding Tax (%)" / 100) * DividendsProgressionTable."Gross Interest On Deposits", 0.05, '<');
        DividendsProgressionTable."Net Interest On Deposits" := ROUND(DividendsProgressionTable."Gross Interest On Deposits" - DividendsProgressionTable."WHT On Interest On Deposits", 0.05, '<');

        DividendsProgressionTable.Insert;
    end;
}

