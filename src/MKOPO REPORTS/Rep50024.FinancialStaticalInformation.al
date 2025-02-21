report 50024 FinancialStaticalInformation
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './Layout/FinancialStaticalInformation.rdlc';


    dataset
    {
        dataitem("Sacco Information"; "Sacco Information")
        {
            column(Code; Code) { }
            column(Previous_Deposits_Interest; "Previous Deposits Interest") { }
            column(Previous_Dividends_Interest; "Previous Dividends Interest") { }
            column(Deposits_Interest; "Deposits Interest") { }
            column(Dividends_Interest; "Dividends Interest") { }
            column(RetainedEarningscoreCapital; RetainedEarningscoreCapital) { }
            column(LRetainedEarningscoreCapital; LRetainedEarningscoreCapital) { }
            column(Active; Active) { }
            column(Dormant; Dormant) { }
            column(LActive; LActive) { }
            column(LDormant; LDormant) { }

            column(StatutoryReserve; StatutoryReserve * -1) { }
            column(LStatutoryReserve; LStatutoryReserve * -1) { }
            column(Institutionalcapital; Institutionalcapital * -1) { }
            column(LInstitutionalcapital; LInstitutionalcapital * -1) { }
            column(FemaleLNumberofEmployees; FemaleLNumberofEmployees) { }
            column(FemaleNumberofEmployees; FemaleNumberofEmployees) { }
            column(MaleLNumberofEmployees; MaleLNumberofEmployees) { }
            column(MaleNumberofEmployees; MaleNumberofEmployees) { }
            column(TotalAssets; TotalAssets) { }
            column(LTotalAssets; LTotalAssets) { }
            column(DepositAmount; (DepositAmount * -1)) { }
            column(LDepositAmount; (LDepositAmount * -1)) { }
            column(LoanandAdvances; LoanandAdvances) { }
            column(LLoanandAdvances; LLoanandAdvances) { }
            column(InterestonMemberdeposits; (InterestonMemberdeposits)) { }
            column(LInterestonMemberdeposits; (LInterestonMemberdeposits)) { }
            column(IntCurrentDeposits; IntCurrentDeposits)
            {

            }
            column(PersonalExpenseRevenue; PersonalExpenseRevenue) { }
            column(LPersonalExpenseRevenue; LPersonalExpenseRevenue) { }

            column(IntShareCapital; IntShareCapital)
            {

            }
            column(FinancialAssets; FinancialAssets) { }
            column(LFinancialAssets; LFinancialAssets) { }
            column(TotalRevenue; TotalRevenue) { }
            column(LTotalRevenue; LTotalRevenue) { }
            column(TotalInteresstIncome; TotalInteresstIncome) { }
            column(LTotalInteresstIncome; LTotalInteresstIncome) { }
            column(TotalExpenses; TotalExpenses) { }
            column(LTotalExpenses; LTotalExpenses) { }
            column(ShareCapital; ShareCapital * -1) { }
            column(LShareCapital; LShareCapital * -1) { }
            column(Nonwithdrawabledeposits; Nonwithdrawabledeposits) { }
            column(LNonwithdrawabledeposits; LNonwithdrawabledeposits) { }
            column(CorecapitaltoAssetsRatio; CorecapitaltoAssetsRatio) { }
            column(LCorecapitaltoAssetsRatio; LCorecapitaltoAssetsRatio) { }
            column(Corecapital; Corecapital * -1) { }
            column(LCorecapital; LCorecapital * -1) { }
            column(CorecapitaltoDepositsRatio; CorecapitaltoDepositsRatio) { }
            column(LCorecapitaltoDepositsRatio; LCorecapitaltoDepositsRatio) { }
            column(LExternalBorrowingtoAssetsRatio; LExternalBorrowingtoAssetsRatio) { }
            column(ExternalBorrowingtoAssetsRatio; ExternalBorrowingtoAssetsRatio) { }
            column(LiquidAssetstoTotalassetsshorttermliabilities; LiquidAssetstoTotalassetsshorttermliabilities) { }
            column(LLiquidAssetstoTotalassetsshorttermliabilities; LLiquidAssetstoTotalassetsshorttermliabilities) { }
            column(LiquidAssetsTotalAssets; LiquidAssetsTotalAssets) { }
            column(LLiquidAssetsTotalAssets; LLiquidAssetsTotalAssets) { }

            column(GrossLoansTotalAssets; GrossLoansTotalAssets) { }
            column(LGrossLoansTotalAssets; LGrossLoansTotalAssets) { }
            column(GrossLoansdeposits; GrossLoansdeposits) { }
            column(LGrossLoansdeposits; LGrossLoansdeposits) { }
            column(TotalExpensesTotalRevenue; TotalExpensesTotalRevenue) { }
            column(LTotalExpensesTotalRevenue; LTotalExpensesTotalRevenue) { }
            column(TotalExpensesTotalAssets; TotalExpensesTotalAssets) { }
            column(LTotalExpensesTotalAssets; LTotalExpensesTotalAssets) { }
            column(DividendsTotalRevenue; DividendsTotalRevenue) { }
            column(LDividendsTotalRevenue; LDividendsTotalRevenue) { }
            column(FinancialAssetsTotalAssets; FinancialAssetsTotalAssets) { }
            column(LFinancialAssetsTotalAssets; LFinancialAssetsTotalAssets) { }
            column(NoSaccoBraches; NoSaccoBraches)
            {

            }
            column(CurrentYear; CurrentYear)
            {

            }
            column(PreviousYear; PreviousYear)
            {

            }
            column(EndofLastyear; EndofLastyear)
            {

            }
            trigger OnAfterGetRecord()
            var
                myInt: Integer;
                InputDate: Date;
                DateFormula: Text;
                DateExpr: Text;

            begin


                GenSetup.Get();
                IntCurrentDeposits := (GenSetup."Interest on Share Capital(%)" * 0.01);
                IntShareCapital := (GenSetup."Interest On Current Shares" * 0.01);
                DateFormula := '<-CY-1D>';
                DateExpr := '<-1y>';
                InputDate := Asat;
                Direction := '>';
                Precision := 0.01;

                EndofLastyear := Asat;
                CurrentYear := Date2DMY(EndofLastyear, 3);
                LastYearButOne := CalcDate(DateFormula, EndofLastyear);
                PreviousYear := CurrentYear - 1;
                //Date := DMY2DATE(Day,Month,Year);

                TotalAssets := 0;
                LTotalAssets := 0;

                FemaleLNumberofEmployees := 0;
                FemaleNumberofEmployees := 0;
                Active := 0;
                Dormant := 0;
                LActive := 0;
                LDormant := 0;
                LLoanBalance := 0;
                Equityinvestment := 0;

                SubsidiaryandRelated := 0;
                cust.Reset();
                cust.SetFilter(Cust."Customer Type", '=%1', Cust."Customer Type"::Member);
                if Cust.Find('-') then begin
                    Cust.SetFilter(Cust.Status, '=%1', Cust.Status::Active);
                    Cust.SetFilter(Cust."Registration Date", '<=%1', EndofLastyear);
                    if FindSet() then
                        Active := Cust.Count;
                    Cust.SetFilter(Cust.Status, '=%1', Cust.Status::Dormant);
                    Cust.SetFilter(Cust."Registration Date", '<=%1', EndofLastyear);
                    if FindSet() then
                        Dormant := Cust.Count;

                    Cust.SetFilter(Cust.Status, '=%1', Cust.Status::Active);
                    Cust.SetFilter(Cust."Registration Date", '<=%1', LastYearButOne);
                    if FindSet() then
                        LActive := Cust.Count;

                    Cust.SetFilter(Cust.Status, '=%1', Cust.Status::Dormant);
                    Cust.SetFilter(Cust."Registration Date", '<=%1', LastYearButOne);
                    if FindSet() then
                        LDormant := Cust.Count;
                end;
                //Number of Female Sacco Employees
                Emp.reset;
                Emp.SetFilter(Emp.Status, '%1', Emp.Status::Active);
                Emp.SetFilter(Emp.Gender, '%1', Emp.Gender::Female);
                if FindSet() then begin
                    Emp.SetFilter(Emp."Employment Date", '<=%1', EndofLastyear);
                    if FindSet() then
                        FemaleNumberofEmployees := Emp.Count;

                    Emp.SetFilter(Emp."Employment Date", '<=%1', LastYearButOne);
                    if FindSet() then
                        FemaleLNumberofEmployees := Emp.Count;//LNumberofEmployees
                end;


                //Number of male Sacco Employees
                Emp.reset;
                Emp.SetFilter(Emp.Status, '%1', Emp.Status::Active);
                Emp.SetFilter(Emp.Gender, '%1', Emp.Gender::Male);
                if FindSet() then begin
                    Emp.SetFilter(Emp."Employment Date", '<=%1', EndofLastyear);
                    if FindSet() then
                        maleNumberofEmployees := Emp.Count;

                    Emp.SetFilter(Emp."Employment Date", '<=%1', LastYearButOne);
                    if FindSet() then
                        maleLNumberofEmployees := Emp.Count;//LNumberofEmployees
                end;
                //End ofNumber of male Sacco Employees



                //Financials
                //Total Assets
                Cashatbank := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::CashAndEquivalents);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LCashatbank += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;

                //End of Cash and Cash Equivalents
                //Receivables And Prepayments
                ReceivableandPrepayments := 0;
                LReceivableandPrepayments := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::ReceivablesAndPrepayements);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LoanandAdvances += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::LoansAndAdvances);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LLoanandAdvances += GLEntry.Amount;
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LFinancialAssets += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //End Of Financial Assets


                //Property,Plant and equipment
                PropertyEquipment := 0;
                LPropertyEquipment := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::propertyplantandEquipment);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            PropertyEquipment += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::propertyplantandEquipment);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LPropertyEquipment += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //End of propert plant and Equipments
                //intangible assets
                IntangibleAssets := 0;
                LIntangibleAssets := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::Intangiableassets);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            IntangibleAssets += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::Intangiableassets);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LIntangibleAssets += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                TotalAssets := Cashatbank + ReceivableandPrepayments + LoanandAdvances + FinancialAssets + PropertyEquipment + IntangibleAssets;
                LTotalAssets := LCashatbank + LReceivableandPrepayments + LLoanandAdvances + LFinancialAssets + LPropertyEquipment + LIntangibleAssets;


                //End of Total assets

                //Member Deposits

                Nonwithdrawabledeposits := 0;
                LNonwithdrawabledeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::MemberDeposits);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LNonwithdrawabledeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                //end of Member deposits

                //Dividends
                InterestonMemberdeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::dividendsandInterestPayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestonMemberdeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                //End of Member Dividends
                //LoanandAdvances
                LoanandAdvances := 0;
                LLoanandAdvances := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::LoansAndAdvances);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LoanandAdvances += GLEntry.Amount;

                        end;

                    until GLAccount.Next = 0;
                end;

                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Assets, '%1', GLAccount.Assets::LoansAndAdvances);
                if GLAccount.FindSet then begin
                    repeat

                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LLoanandAdvances += GLEntry.Amount;
                        end;

                    until GLAccount.Next = 0;
                end;
                //EndofLoanandAdavances
                //Sharecapital
                ShareCapital := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::Sharecapital);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LShareCapital += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //Endofsharecapital
                //Total Revenue
                TotalRevenue := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Financials, '%1', GLAccount.Financials::Revenue);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            TotalRevenue += -1 * GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;
                end;
                LTotalRevenue := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Financials, '%1', GLAccount.Financials::Revenue);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LTotalRevenue += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //End Total Revenue
                //Total interest Income
                TotalInteresstIncome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestOnLoans);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            TotalInteresstIncome += -1 * GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;
                end;
                LTotalInteresstIncome := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::InterestOnLoans);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LTotalInteresstIncome += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //End Total Interest Income
                //start of Personal Expenses

                PersonalExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Incomes, '%1', GLAccount.Incomes::PersonelExpenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            PersonalExpenses += GLEntry.Amount;

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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LPersonalExpenses += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;


                //End Of Personal Expenses
                //Total Expenses
                LPersonalExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Financials, '%1', GLAccount.Financials::Expenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            TotalExpenses += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LTotalExpenses := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Financials, '%1', GLAccount.Financials::Expenses);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LTotalExpenses += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //End Total Interest Income


                //short term Liabilities
                //LIABILITIES
                //Member Deposits
                Nonwithdrawabledeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::MemberDeposits);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            Nonwithdrawabledeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                LNonwithdrawabledeposits := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::MemberDeposits);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYearButOne);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LInterestonMemberdeposits += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;

                //End of Dividends
                //TradeandOtherPayables
                TradeandOtherPayables := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::TradeandotherPayables);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
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
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LHononaria += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //EndofHonaria
                //TaxPayable
                TaxPayable := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::Taxpayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            TaxPayable += -1 * GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;
                end;
                LTaxPayable := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.MkopoLiabilities, '%1', GLAccount.MkopoLiabilities::Taxpayable);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LTaxPayable += -1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //EndofTaxpayable
                shortTermLiabilities := 0;
                LshortTermLiabilities := 0;

                shortTermLiabilities := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Others, '%1', GLAccount.Others::ShortTermLiabilities);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            shortTermLiabilities += GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;

                end;
                LshortTermLiabilities := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.Others, '%1', GLAccount.Others::ShortTermLiabilities);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '..%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LshortTermLiabilities += GLEntry.Amount;

                        end;
                    until GLAccount.Next = 0;

                end;

                //statutory
                StatutoryReserve := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::StatutoryReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            StatutoryReserve += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LStatutoryReserve := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::StatutoryReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LStatutoryReserve += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //End of Statutory

                //Revenue Reserves
                RevenueReservers := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::RevenueReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', EndofLastyear);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            RevenueReservers += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                LRevenueReservers := 0;
                GLAccount.Reset;
                GLAccount.SetFilter(GLAccount.FinancedBy, '%1', GLAccount.FinancedBy::RevenueReserves);
                if GLAccount.FindSet then begin
                    repeat
                        GLEntry.Reset;
                        GLEntry.SetRange(GLEntry."G/L Account No.", GLAccount."No.");
                        GLEntry.SetFilter(GLEntry."Posting Date", '<=%1', LastYearButOne);
                        if GLEntry.FindSet then begin
                            GLEntry.CalcSums(Amount);
                            LRevenueReservers += 1 * GLEntry.Amount;
                        end;
                    until GLAccount.Next = 0;
                end;
                //end of Revenue reserves

                Institutionalcapital := 0;
                LInstitutionalcapital := 0;


                Institutionalcapital := StatutoryReserve + RevenueReservers;
                LInstitutionalcapital := LStatutoryReserve + LRevenueReservers;

                Corecapital := 0;
                LCorecapital := 0;
                Corecapital := ShareCapital + Institutionalcapital;
                LCorecapital := LShareCapital + LInstitutionalcapital;


                LiquidAssetstoTotalassetsshorttermliabilities := 0;
                LLiquidAssetstoTotalassetsshorttermliabilities := 0;
                LiquidAssetsTotalAssets := 0;
                LiquidAssetsTotalAssets := 0;
                LLiquidAssetsTotalAssets := 0;

                //corecapitaltoTotalassets
                CorecapitaltoAssetsRatio := 0;
                LCorecapitaltoAssetsRatio := 0;
                if TotalAssets <> 0 then
                    CorecapitaltoAssetsRatio := Corecapital / TotalAssets;
                CorecapitaltoAssetsRatio := (Round(CorecapitaltoAssetsRatio, Precision, Direction));

                if LTotalAssets <> 0 then
                    LCorecapitaltoAssetsRatio := LCorecapital / LTotalAssets;
                LCorecapitaltoAssetsRatio := (Round(LCorecapitaltoAssetsRatio, Precision, Direction));


                //EndofCoreCapitalTotalAssets
                //TotalcorecapitaltoTotalDeposits
                CorecapitaltoDepositsRatio := 0;
                LCorecapitaltoDepositsRatio := 0;

                CorecapitaltoDepositsRatio := Corecapital / Nonwithdrawabledeposits;
                CorecapitaltoDepositsRatio := (Round(CorecapitaltoDepositsRatio, Precision, Direction));

                LCorecapitaltoDepositsRatio := LCorecapital / LNonwithdrawabledeposits;
                LCorecapitaltoDepositsRatio := (Round(LCorecapitaltoDepositsRatio, Precision, Direction));

                //LTotalcorecapitaltoTotalDeposits

                //Retained Earning and disclosed Reserverscorecapital
                RetainedEarningscoreCapital := 0;
                LRetainedEarningscoreCapital := 0;


                if Corecapital <> 0 then begin
                    RetainedEarningscoreCapital := (Round(Institutionalcapital / Corecapital));
                end;
                if LCorecapital <> 0 then begin
                    LRetainedEarningscoreCapital := (Round(LInstitutionalcapital / LCorecapital));
                end;


                FinancialAssetsTotalAssets := 0;
                FinancialAssetsTotalAssets := Round(FinancialAssets / TotalAssets, Precision, Direction);

                LFinancialAssetsTotalAssets := 0;
                LFinancialAssetsTotalAssets := Round(LFinancialAssets / LTotalAssets, Precision, Direction);

                //end Retained Earning and disclosed Reserverscorecapital

                PersonalExpenseRevenue := 0;
                if TotalRevenue <> 0 then begin
                    PersonalExpenseRevenue := -1 * (PersonalExpenses / TotalExpenses);
                end;

                LPersonalExpenseRevenue := 0;
                if LTotalRevenue <> 0 then begin
                    LPersonalExpenseRevenue := -1 * (LPersonalExpenses / LTotalExpenses);
                end;
                if shortTermLiabilities <> 0 then begin
                    LiquidAssetstoTotalassetsshorttermliabilities := (Cashatbank / (-shortTermLiabilities));
                end;

                if LshortTermLiabilities <> 0 then begin
                    LLiquidAssetstoTotalassetsshorttermliabilities := (LCashatbank / (-LshortTermLiabilities));
                end;

                if TotalAssets <> 0 then begin
                    LiquidAssetsTotalAssets := ((Cashatbank / TotalAssets));
                end;

                if LTotalAssets <> 0 then begin
                    LLiquidAssetsTotalAssets := ((LCashatbank / LTotalAssets));
                end;

                if Nonwithdrawabledeposits <> 0 then begin
                    GrossLoansdeposits := (LoanandAdvances / Nonwithdrawabledeposits);
                end;

                if LNonwithdrawabledeposits <> 0 then begin
                    LGrossLoansdeposits := (LLoanandAdvances / LNonwithdrawabledeposits);
                end;

                if LTotalAssets <> 0 then begin
                    LGrossLoansTotalAssets := (LLoanandAdvances / LTotalAssets);
                end;

                if TotalAssets <> 0 then begin
                    GrossLoansTotalAssets := (LoanandAdvances / TotalAssets);
                end;

                if TotalRevenue <> 0 then begin
                    TotalExpensesTotalRevenue := (TotalExpenses / TotalRevenue);
                end;

                if LTotalRevenue <> 0 then begin
                    LTotalExpensesTotalRevenue := -(LTotalExpenses / LTotalRevenue);
                end;

                if TotalAssets <> 0 then begin
                    TotalExpensesTotalAssets := (TotalExpenses / TotalAssets);
                end;

                if LTotalAssets <> 0 then begin
                    LTotalExpensesTotalAssets := (LTotalExpenses / LTotalAssets);
                end;

                if TotalRevenue <> 0 then begin
                    DividendsTotalRevenue := (InterestonMemberdeposits / TotalRevenue);
                end;

                if LTotalRevenue <> 0 then begin
                    LDividendsTotalRevenue := (LInterestonMemberdeposits / LTotalRevenue);
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
    }

    var
        GenSetup: Record "Sacco General Set-Up";
        RetainedEarningsDisclosedReserves: Decimal;
        PersonalExpenseRevenue: Decimal;
        LPersonalExpenseRevenue: Decimal;
        FinancialAssetsTotalAssets: Decimal;
        LFinancialAssetsTotalAssets: Decimal;
        LRetainedEarningsDisclosedReserves: Decimal;
        Direction: Text;
        Precision: Decimal;
        Result: Decimal;
        Institutionalcapital: Decimal;
        LInstitutionalcapital: Decimal;
        TotalRevenue: Decimal;
        DividendsTotalRevenue: Decimal;
        LDividendsTotalRevenue: Decimal;
        LTotalRevenue: Decimal;
        TotalInteresstIncome: Decimal;
        LTotalInteresstIncome: Decimal;
        TotalExpenses: Decimal;
        LTotalExpenses: Decimal;
        LiquidAssetsTotalAssets: Decimal;
        LLiquidAssetsTotalAssets: Decimal;
        GrossLoansTotalAssets: Decimal;
        LGrossLoansTotalAssets: Decimal;
        GrossLoansdeposits: Decimal;
        LGrossLoansdeposits: Decimal;
        IntCurrentDeposits: Decimal;
        IntShareCapital: Decimal;
        Cust: Record Customer;
        Active: Integer;
        Dormant: Integer;
        LActive: Integer;
        LDormant: Integer;
        LongtermLiablities: Decimal;

        TotalExpensesTotalRevenue: Decimal;
        LTotalExpensesTotalRevenue: Decimal;
        TotalExpensesTotalAssets: Decimal;
        LTotalExpensesTotalAssets: Decimal;

        LLongtermliabilities: Decimal;
        CorecapitaltoAssetsRatio: Decimal;
        CorecapitaltoDepositsRatio: Decimal;
        ExternalBorrowingtoAssetsRatio: Decimal;
        LExternalBorrowingtoAssetsRatio: Decimal;
        LCorecapitaltoDepositsRatio: Decimal;
        LCorecapitaltoAssetsRatio: Decimal;
        LiquidAssetstoTotalassetsshorttermliabilities: Decimal;
        LLiquidAssetstoTotalassetsshorttermliabilities: Decimal;
        LiquidAssets: Decimal;
        LLiquidAssets: Decimal;
        GLEntry: Record "G/L Entry";
        Asat: Date;

        Corecapital: Decimal;
        LCorecapital: Decimal;
        NetSurplusaftertax: Decimal;
        LNetSurplusaftertax: Decimal;
        InvestmentsinSubsidiary: Decimal;
        LInvestmentsinSubsidiary: Decimal;
        FinancialAssets: Decimal;
        LFinancialAssets: Decimal;
        Otherinvestments: Decimal;
        StartDate: Date;
        CurrentYear: Integer;
        shortTermLiabilities: Decimal;
        LshortTermLiabilities: Decimal;
        PreviousYear: Integer;
        EndofLastyear: date;
        LastYearButOne: Date;
        FemaleNumberofEmployees: Integer;
        FemaleLNumberofEmployees: Integer;
        MaleNumberofEmployees: Integer;
        MaleLNumberofEmployees: Integer;
        Emp: Record Employee;
        TotalAssets: Decimal;
        LTotalAssets: Decimal;
        SubsidiaryandRelated: Decimal;
        GL: Record "G/L Account";
        DepositAmount: Decimal;
        LDepositAmount: Decimal;
        LoanBalance: Decimal;
        LLoanBalance: Decimal;
        Equityinvestment: Decimal;
        StatutoryReserves: Decimal;
        LStatutoryReserves: Decimal;
        RevenueReservers: Decimal;
        LRevenueReservers: Decimal;

        LInvestmentProperties: Decimal;
        Hononaria: Decimal;
        LHononaria: Decimal;
        ShareCapitalValue: Decimal;
        LPropertyEquipment: Decimal;
        LPrepaidLeaseentals: Decimal;
        LIntangibleAssets: Decimal;
        LOtherAssets: Decimal;
        PersonalExpenses: Decimal;
        LPersonalExpenses: Decimal;

        LInterestonMemberDeposits: Decimal;
        InterestonMemberdeposits: Decimal;

        ReceivableandPrepayments: Decimal;
        LReceivableandPrepayments: Decimal;
        LoanandAdvances: Decimal;
        LLoanandAdvances: Decimal;

        PropertyPlantandequipment: Decimal;
        LPropertyPlantandequipment: Decimal;
        CompanyInformation: Record "Company Information";
#pragma warning restore AL0275
        Cashinhand: Decimal;
        FinancialYear: Integer;

        Cashatbank: Decimal;
        LCashatbank: Decimal;
        LCashinhand: Decimal;
        CashCashEquivalent: Decimal;
        LCashCashEquivalent: Decimal;
#pragma warning disable AL0275

        LGrossLoanPortfolio: Decimal;
        GLAccount: Record "G/L Account";
#pragma warning restore AL0275
        DateFilter: Text;
        Date: Date;
        DateFilter11: Text;

        PrepaymentsSundryReceivables: Decimal;
        FinancialInvestments: Decimal;
        LFinancialInvestments: Decimal;
        GovernmentSecurities: Decimal;
        Placement: Decimal;
        CommercialPapers: Decimal;
        CollectiveInvestment: Decimal;
        Derivatives: Decimal;
        EquityInvestments: Decimal;
        Investmentincompanies: Decimal;
        LInvestmentincompanies: Decimal;
        GrossLoanPortfolio: Decimal;
        PropertyEquipment: Decimal;
        AllowanceforLoanLoss: Decimal;
        Nonwithdrawabledeposits: Decimal;
        LNonwithdrawabledeposits: Decimal;
        TaxPayable: Decimal;
        LTaxPayable: Decimal;
        RetirementBenefitsLiability: Decimal;
        OtherLiabilities: Decimal;
        DeferredTaxLiability: Decimal;
        ExternalBorrowings: Decimal;
        TotalLiabilities: Decimal;
        ShareCapital: Decimal;
        LShareCapital: Decimal;
        StatutoryReserve: Decimal;
        LStatutoryReserve: Decimal;
        OtherReserves: Decimal;
        RevaluationReserves: Decimal;
        ProposedDividends: Decimal;
        AdjustmenttoEquity: Decimal;
        PrioryarRetainedEarnings: Decimal;
        CurrentYearSurplus: Decimal;
        TaxRecoverable: Decimal;
        DeferredTaxAssets: Decimal;
        RetirementBenefitAssets: Decimal;
        OtherAssets: Decimal;
        IntangibleAssets: Decimal;
        PrepaidLeaseentals: Decimal;
        InvestmentProperties: Decimal;
        DividendPayable: Decimal;
        LDividendPayable: Decimal;
        TradeandOtherPayables: Decimal;
        LTradeandOtherPayables: Decimal;
        NetLoanPortfolio: Decimal;
        AccountsReceivables: Decimal;
        PropertyEquipmentOtheassets: Decimal;
        LPropertyEquipmentOtheassets: Decimal;
        AccountsPayableOtherLiabilities: Decimal;
        CapitalGrants: Decimal;
        EQUITY: Decimal;
        RetainedEarnings: Decimal;
        OtherEquityAccounts: Decimal;
        TotalEquity: Decimal;
        TotalLiabilitiesandEquity: Decimal;
        TotalLiabilitiesNew: Decimal;
        RetainedEarningscoreCapital: Decimal;
        LRetainedEarningscoreCapital: Decimal;



}