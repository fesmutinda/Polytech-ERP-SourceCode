Report 50347 "REPORT OF THE DIRECTORS"

{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './Layout/Reportofthedirectors.rdlc';

    dataset
    {
        dataitem("Sacco Information"; "Sacco Information")
        {
            column(Code; Code)
            {

            }
            column(Independent_Auditor; "Independent Auditor")
            {

            }
            column(Asat; Asat)
            {


            }
            column(CurrentYear; CurrentYear)
            {

            }
            column(PreviousYear; PreviousYear)
            {

            }
            column(ThisYear; ThisYear)
            {

            }
            column(Sacco_Principal_Activities; "Sacco Principal Activities")
            {

            }
            column(IntCurrentDeposits; IntCurrentDeposits)
            {

            }

            column(IntShareCapital; IntShareCapital)
            {

            }
            column(InterestonMemberdeposits; InterestonMemberdeposits * -1)
            {

            }
            column(LInterestonMemberdeposits; LInterestonMemberdeposits * -1)
            {

            }
            column(ShareCapital; ShareCapital)
            {

            }
            column(LShareCapital; LShareCapital)
            {

            }
            column(LprofitorLossbeforetax; LprofitorLossbeforetax) { }
            column(profitorLossbeforetax; profitorLossbeforetax) { }
            column(RetainedEarnings; RetainedEarnings) { }
            column(IncomeTaxExpense; IncomeTaxExpense) { }
            column(LIncomeTaxExpense; LIncomeTaxExpense) { }
            column(LRetainedEarnings; LRetainedEarnings) { }

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
                InputDate: Date;
                DateFormula: Text;
                DateExpr: Text;
            begin
                DateFormula := '<-CY-1D>';
                DateExpr := '<-1y>';
                InputDate := Asat;
                ThisYear := Asat;
                CurrentYear := Date2DMY(ThisYear, 3);
                LastYear := CalcDate(DateFormula, ThisYear);
                PreviousYear := CurrentYear - 1;
                GenSetup.Get();
                IntCurrentDeposits := (GenSetup."Interest on Share Capital(%)" * 0.01);
                IntShareCapital := (GenSetup."Interest On Current Shares" * 0.01);



                //Dividends
                InterestonMemberdeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::dividendsandInterestPayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            InterestonMemberdeposits += 1 * GLEntry.Amount;

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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestonMemberdeposits += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                //End Of Dividends
                //Sharecapital
                ShareCapital := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::Sharecapital);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', ThisYear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LShareCapital += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //Endofsharecapital


                //Retained Earnings
                RetainedEarnings := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::RevenueReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            RetainedEarnings += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                LRetainedEarnings := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::RevenueReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LRetainedEarnings += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                //End Of Retained Earnings

                //Revenues
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LOtherOperatingincome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInvestmentIncome += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                Governanceexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::GorvernanceExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Governanceexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LGovernanceexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::GorvernanceExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LGovernanceexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                administrativeexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::AdministrationExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            administrativeexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                Ladministrativeexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::AdministrationExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Ladministrativeexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                PersonalExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::PersonelExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            PersonalExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LPersonalExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::PersonelExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LPersonalExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                OperatingExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::OperatingExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            OperatingExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LOperatingExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::OperatingExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LOperatingExpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                FinancialExpense := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::FinancialExpense);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            FinancialExpense += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LFinancialExpense := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::FinancialExpense);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LFinancialExpense += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                Makertingexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::MarketingExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Makertingexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LMakertingexpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::MarketingExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LMakertingexpenses += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;


                DepreciationAmmortisation := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::DepreciationAmmortisation);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            DepreciationAmmortisation += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LDepreciationAmmortisation := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::DepreciationAmmortisation);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LDepreciationAmmortisation += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                //Income Tax Expense

                IncomeTaxExpense := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::IncomeTaxExpense);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', ThisYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            IncomeTaxExpense += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                LIncomeTaxExpense := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::IncomeTaxExpense);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LIncomeTaxExpense += -1 * GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                //end Of income Tax Expense


                //Net Surplus Before Tax
                profitorLossbeforetax := InterestonLoans + InterestExpenses + OtherOperatingincome + InvestmentIncome
                + Governanceexpenses + administrativeexpenses + PersonalExpenses + OperatingExpenses + FinancialExpense + Makertingexpenses + DepreciationAmmortisation;
                LprofitorLossbeforetax := LInterestonLoans + LInterestExpenses + LOtherOperatingincome + LInvestmentIncome
           + LGovernanceexpenses + Ladministrativeexpenses + LPersonalExpenses + LOperatingExpenses + LFinancialExpense + LMakertingexpenses + LDepreciationAmmortisation;
                //Net Tax Before Tax

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
        ShareCapital: Decimal;
        IncomeTaxExpense: Decimal;
        LIncomeTaxExpense: Decimal;
        LShareCapital: Decimal;
        RetainedEarnings: Decimal;
        LprofitorLossbeforetax: Decimal;
        profitorLossbeforetax: Decimal;
        LRetainedEarnings: Decimal;
        IntCurrentDeposits: Decimal;
        InterestonMemberdeposits: Decimal;
        LInterestonMemberdeposits: Decimal;
        GLEntry: Record "G/L Entry";
        GLAccount: Record "G/L Account";
        IntShareCapital: Decimal;
        myInt: Integer;
        LastYear: Date;
        Asat: Date;
        CurrentYear: Integer;
        PreviousYear: Integer;
        ThisYear: date;
        GenSetup: Record "Sacco General Set-Up";

        DepreciationAmmortisation: decimal;
        InterestonLoans: decimal;
        InterestExpenses: decimal;
        OtherOperatingincome: decimal;
        InvestmentIncome: decimal;
        Governanceexpenses: decimal;
        administrativeexpenses: decimal;
        PersonalExpenses: decimal;
        OperatingExpenses: decimal;
        FinancialExpense: decimal;
        Makertingexpenses: decimal;
        LDepreciationAmmortisation: decimal;
        LInterestonLoans: decimal;
        LInterestExpenses: decimal;
        LOtherOperatingincome: decimal;
        LInvestmentIncome: decimal;
        LGovernanceexpenses: decimal;
        Ladministrativeexpenses: decimal;
        LPersonalExpenses: decimal;
        LOperatingExpenses: decimal;
        LFinancialExpense: decimal;
        LMakertingexpenses: decimal;

}
