report 50039 cashFlows
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    Caption = 'satement of changes in equity Previous Period';
    RDLCLayout = './Layout/cashflowsreport.rdlc';

    dataset
    {
        dataitem("Sacco Information"; "Sacco Information")
        {
            column(Code; Code)
            {

            }
            column(Cashatbank; Cashatbank) { }
            column(LCashatbank; LCashatbank) { }
            column(endCashatbank; endCashatbank) { }
            column(EndLCashatbank; EndLCashatbank) { }
            column(PreviousYear; PreviousYear)
            {

            }
            column(CurrentYear; CurrentYear)
            {

            }
            column(EndofLastyear; EndofLastyear)
            {

            }
            column(LoanandAdvances; LoanandAdvances)
            {
            }
            column(LLoanandAdvances; LLoanandAdvances)
            {
            }
            column(FinancialAssets; FinancialAssets)
            {
            }
            column(LFinancialAssets; LFinancialAssets)
            {
            }
            column(TradeandOtherPayables; TradeandOtherPayables)
            {
            }
            column(LTradeandOtherPayables; LTradeandOtherPayables)
            {
            }
            column(Hononaria; Hononaria)
            {
            }
            column(LHononaria; LHononaria)
            {
            }
            column(Nonwithdrawabledeposits; Nonwithdrawabledeposits)
            {
            }
            column(LNonwithdrawabledeposits; LNonwithdrawabledeposits)
            {
            }
            column(InterestonMemberdeposits; InterestonMemberdeposits)
            {

            }
            column(LInterestonMemberDeposits; LInterestonMemberDeposits)
            {

            }
            column(InvestmentIncome; InvestmentIncome)
            {

            }
            column(LInvestmentIncome; LInvestmentIncome)
            {

            }
            column(ShareCapital; ShareCapital)
            {
            }
            column(LShareCapital; LShareCapital)
            { }
            column(LOtherOperatingincome; LOtherOperatingincome)
            {

            }
            column(OtherOperatingincome; OtherOperatingincome)
            {

            }
            column(InterestonLoans; InterestonLoans) { }
            column(LInterestonLoans; LInterestonLoans) { }
            column(LInterestExpenses; LInterestExpenses) { }
            column(InterestExpenses; InterestExpenses) { }
            column(ReceivableandPrepayments; ReceivableandPrepayments) { }
            column(LReceivableandPrepayments; LReceivableandPrepayments) { }
            column(ThisYear; ThisYear)
            {

            }
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
                InputDate: Date;
                DateFormula: Text;
                DateExpr: Text;
                StartofcurrentYear: Date;
                StartofPreviousYear: Date;
                DateExpr2: Text;


            begin
                DateFormula := '<-CY-1D>';
                DateExpr := '<-1y>';
                InputDate := Asat;
                DateExpr2 := '<-CY>';

                ThisYear := InputDate;
                StartofcurrentYear := CalcDate(DateExpr2, ThisYear);

                CurrentYear := Date2DMY(ThisYear, 3);
                EndofLastyear := CalcDate(DateFormula, ThisYear);
                StartofPreviousYear := CalcDate(DateExpr2, EndofLastyear);
                PreviousYear := CurrentYear - 1;

                //Interest on Loans
                InterestonLoans := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestOnLoans);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            InterestonLoans += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LInterestonLoans := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestOnLoans);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestonLoans += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                //Interest Exepenses
                InterestExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            InterestExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LInterestExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //Otheroperatingincome
                OtherOperatingincome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::OtherOperatingincome);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            OtherOperatingincome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                OtherOperatingincome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::OtherOperatingincome);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LOtherOperatingincome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //Receivables And Prepayments
                ReceivableandPrepayments := 0;
                LReceivableandPrepayments := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::ReceivablesAndPrepayements);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            ReceivableandPrepayments += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::ReceivablesAndPrepayements);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LReceivableandPrepayments += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //End of Receivables and Prepayments


                //LoanandAdvances
                LoanandAdvances := 0;
                LLoanandAdvances := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::LoansAndAdvances);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LoanandAdvances += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::LoansAndAdvances);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LLoanandAdvances += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //EndofLoanandAdavances


                //Financial Assets
                FinancialAssets := 0;
                LFinancialAssets := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::FinancialAssets);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            FinancialAssets += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::FinancialAssets);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LFinancialAssets += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //End Of Financial Assets
                //TradeandOtherPayables
                TradeandOtherPayables := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::TradeandotherPayables);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            TradeandOtherPayables += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LTradeandOtherPayables := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::TradeandotherPayables);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LTradeandOtherPayables += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //EndofTradeAndotherPayables


                //Honoraria
                Hononaria := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::Honoria);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Hononaria += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LHononaria := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::Honoria);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LHononaria += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //EndofHonaria

                //Member Deposits
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::MemberDeposits);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Nonwithdrawabledeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::MemberDeposits);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LNonwithdrawabledeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;

                // EmdMember deposits
                //Dividends
                InterestonMemberdeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::dividendsandInterestPayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofcurrentYear, ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            InterestonMemberdeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LInterestonMemberdeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::dividendsandInterestPayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '%1..%2', StartofPreviousYear, EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestonMemberdeposits += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                //End of Dividends


                //OtherInterestIncome
                InvestmentIncome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InvestmentIncome);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            InvestmentIncome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LInvestmentIncome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InvestmentIncome);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInvestmentIncome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;


                ShareCapital := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::Sharecapital);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            ShareCapital += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LShareCapital := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::Sharecapital);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LShareCapital += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //Endofsharecapital



                Cashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', StartofcurrentYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Cashatbank += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                LCashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', StartofPreviousYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LCashatbank += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;



                Cashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', StartofcurrentYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Cashatbank += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                LCashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', StartofPreviousYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LCashatbank += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;

                //End of year cash and Equivalents

                Cashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', AsAt);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            endCashatbank += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                LCashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            EndLCashatbank += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(Asat; Asat)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }



    var
        Cashatbank: Decimal;
        LCashatbank: Decimal;

        endCashatbank: Decimal;
        EndLCashatbank: Decimal;
        AsAt: Date;
        ReceivableandPrepayments: Decimal;
        LReceivableandPrepayments: Decimal;
        LInterestExpenses: Decimal;
        InterestExpenses: Decimal;
        PreviousYear: Integer;
        CurrentYear: Integer;
        EndofLastyear: date;
        ThisYear: Date;
        InterestonLoans: Decimal;
        LInterestonLoans: Decimal;
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        LoanandAdvances: Decimal;
        LLoanandAdvances: Decimal;
        FinancialAssets: Decimal;
        LFinancialAssets: Decimal;
        Hononaria: Decimal;
        LHononaria: Decimal;
        InvestmentIncome: Decimal;
        LInvestmentIncome: Decimal;
        TradeandOtherPayables: Decimal;
        LTradeandOtherPayables: Decimal;
        LInterestonMemberDeposits: Decimal;
        InterestonMemberdeposits: Decimal;
        LOtherOperatingincome: Decimal;
        OtherOperatingincome: Decimal;
        Nonwithdrawabledeposits: Decimal;
        LNonwithdrawabledeposits: Decimal;
        ShareCapital: Decimal;
        LShareCapital: Decimal;

}