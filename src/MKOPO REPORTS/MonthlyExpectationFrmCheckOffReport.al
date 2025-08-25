#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 51045 "monthly exp polytech"
{
    RDLCLayout = './Layouts/monthlyexppolytech.rdl';
    DefaultLayout = RDLC;

    dataset
    {
        dataitem(Customer; Customer)
        {
            RequestFilterFields = "No.";
            column(Name; Customer.Name)
            {
            }
            column(No; Customer."No.")
            {
            }
            column(ShareCapital; ShareCapital)
            {
            }
            column(DevP; DevP)
            {
            }
            column(Devint; Devint)
            {
            }
            column(montlycon; montlycon)
            {
            }
            column(Devint1; Devint1)
            {
            }
            column(DevP1; DevP1)
            {
            }
            column(EMERGENCYp; EMERGENCYp)
            {
            }
            column(EMERGENCYINTEREST; EMERGENCYi)
            {
            }
            column(SUPEREMERGENCYPRINCIPAL; SUPEREMERGENCYp)
            {
            }
            column(SUPEREMERGENCYINTEREST; SUPEREMERGENCYi)
            {
            }
            column(QUICKLOANPRINCIPAL; QUICKLOANp)
            {
            }
            column(QUICKLOANINTEREST; QUICKLOANi)
            {
            }
            column(SUPERQUICKPRINCIPAL; SUPERQUICKp)
            {
            }
            column(SUPERQUICKINTEREST; SUPERQUICKi)
            {
            }
            column(SCHOOLFEESPRINCIPAL; SCHOOLFEESp)
            {
            }
            column(SCHOOLFEESINTEREST; SCHOOLFEESi)
            {
            }
            column(SUPERSCHOOLFEESPRINCIPAL; SUPERSCHOOLFEESp)
            {
            }
            column(SUPERSCHOOLFEESINTEREST; SUPERSCHOOLFEESi)
            {
            }
            column(INVESTMENTLOANPRINCIPAL; INVESTMENTLOANp)
            {
            }
            column(INVESTMENTLOANINTEREST; INVESTMENTLOANi)
            {
            }
            column(CIName; CI.Name)
            {
            }
            column(CIAddress; CI.Address)
            {
            }
            column(CIPicture; CI.Picture)
            {
            }
            column(PersonalNo_MemberRegister; Customer."Personal No")
            {
            }
            column(NORMALLOANp; NORMALLOANp)
            {
            }
            column(NORMALLOANi; NORMALLOANi)
            {
            }
            column(NORMALLOAN1p; NORMALLOAN1p)
            {
            }
            column(HolidayContribution_MemberRegister; Customer."Holiday Contribution")
            {
            }
            column(Welfare_Contr; "Welfare Contr")
            {
            }
            column(DevelopmentLoanP; DevelopmentLoanP)
            {
            }
            column(DevelopmentLoanInt; DevelopmentLoanInt)
            {
            }
            column(MERCHANDISEPr; MERCHANDISEPr)
            {
            }
            column(MERCHANDISEIn; MERCHANDISEIn)
            {
            }
            trigger OnPreDataItem();
            begin
                //ReportForNav.OnPreDataItem('Customer',Customer);
            end;

            trigger OnAfterGetRecord();
            begin
                CI.Get();
                CI.CalcFields(Picture);

                ShareCapital := 0;
                Customer.CalcFields(Customer."Shares Retained");
                //MESSAGE (FORMAT(Customer."Shares Retained"));
                if Customer."Shares Retained" >= 15000 then begin
                    ShareCapital := 0
                end else
                    if Customer."Shares Retained" > 5000 then begin
                        ShareCapital := 417
                    end else
                        if Customer."Shares Retained" < 5000 then begin
                            ShareCapital := 1000
                        end;
                //MESSAGE(FORMAT(ASAT));
                BeginMonth_Date := CalcDate('<-CM +14D>', ASAT);
                // EndMonth_Date := CALCDATE('<-15D>', ASAT);
                //MESSAGE ('begg IS %1',BeginMonth_Date);
                montlycon := Customer."Monthly Contribution";
                "Welfare Contr" := Customer."Welfare Contr";
                Customer.SetFilter(Customer."Monthly Contribution", '>%1', 0);
                // 

                // DEVELOPMENT
                CalculateLoanRepayment2('20', DevP, Devint, Customer."No.", ASAT, BeginMonth_Date);

                // DEVELOPMENT 1
                CalculateLoanRepayment('23', DevP1, Devint1, Customer."No.", ASAT, BeginMonth_Date);

                // EMERGENCY
                CalculateLoanRepayment('12', EMERGENCYp, EMERGENCYi, Customer."No.", ASAT, BeginMonth_Date);

                //SUPER SCHOOL FEE
                CalculateLoanRepayment2('18', SUPERSCHOOLFEESp, SUPERSCHOOLFEESi, Customer."No.", ASAT, BeginMonth_Date);

                // SUPER EMERGENCY LOAN
                SUPEREMERGENCYp := 0;
                SUPEREMERGENCYi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '13');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SUPEREMERGENCYp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SUPEREMERGENCYp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SUPEREMERGENCYi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SUPEREMERGENCYi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter("Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));
                        if LoanRepaymentSchedule.Find('-') then begin
                            SUPEREMERGENCYi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            SUPEREMERGENCYp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SUPEREMERGENCYp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SUPEREMERGENCYp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SUPEREMERGENCYi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SUPEREMERGENCYi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;

                //SUPER EMERGENCY LOAN end=============================================================================================================================================
                //QUICK LOAN start==========================================================================================================================================
                // QUICK LOAN start
                QUICKLOANp := 0;
                QUICKLOANi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '15');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                QUICKLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                QUICKLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            QUICKLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                QUICKLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                        if LoanRepaymentSchedule.Find('-') then begin
                            QUICKLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            QUICKLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                QUICKLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                QUICKLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            QUICKLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                QUICKLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;
                // QUICK LOAN end


                // SUPER QUICK start
                SUPERQUICKp := 0;
                SUPERQUICKi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '16');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SUPERQUICKp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SUPERQUICKp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SUPERQUICKi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SUPERQUICKi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                        if LoanRepaymentSchedule.Find('-') then begin
                            SUPERQUICKi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            SUPERQUICKp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SUPERQUICKp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SUPERQUICKp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SUPERQUICKi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SUPERQUICKi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;


                SCHOOLFEESp := 0;
                SCHOOLFEESi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '17'); // School Fees
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SCHOOLFEESp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SCHOOLFEESp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SCHOOLFEESi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SCHOOLFEESi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                        if LoanRepaymentSchedule.Find('-') then begin
                            SCHOOLFEESi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            SCHOOLFEESp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                SCHOOLFEESp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                SCHOOLFEESp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            SCHOOLFEESi := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                SCHOOLFEESi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;

                INVESTMENTLOANp := 0;
                INVESTMENTLOANi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '19'); // Investment loans
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    // Case 1: Loan should be completed by ASAT (overdue)
                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal: use the smaller of scheduled or actual outstanding
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                INVESTMENTLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                INVESTMENTLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest: default to outstanding interest
                            INVESTMENTLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');

                            // But if scheduled principal is lower than outstanding, prefer monthly interest
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                INVESTMENTLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else
                        // Case 2: Active loan disbursed before this month
                        if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                            LoanRepaymentSchedule.Reset;
                            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                            LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                            if LoanRepaymentSchedule.Find('-') then begin
                                INVESTMENTLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                                INVESTMENTLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                            end;
                        end else begin
                            LoanRepaymentSchedule.Reset;
                            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                            if LoanRepaymentSchedule.FindLast then begin
                                // Principal: use the smaller of scheduled or actual outstanding
                                if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                    INVESTMENTLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                                else
                                    INVESTMENTLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                                // Interest: default to outstanding interest
                                INVESTMENTLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');

                                // But if scheduled principal is lower than outstanding, prefer monthly interest
                                if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                    INVESTMENTLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            end;
                        end;
                end;

                //INVESTMENT LOAN end=============================================================================================================================================
                //NORMAL LOAN start==========================================================================================================================================
                NORMALLOANp := 0;
                NORMALLOANi := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '21'); // Normal loans
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    // Case 1: Loan should be completed by ASAT (overdue)
                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal: use actual outstanding if smaller than scheduled
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                NORMALLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                NORMALLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest: default to outstanding interest
                            NORMALLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');

                            // If scheduled principal < outstanding, use monthly interest
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                NORMALLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else
                        // Case 2: Active loan disbursed before this month
                        if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                            LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                            LoanRepaymentSchedule.Reset;
                            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                            LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                            if LoanRepaymentSchedule.Find('-') then begin
                                NORMALLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                                NORMALLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                            end;
                        end else begin
                            LoanRepaymentSchedule.Reset;
                            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                            if LoanRepaymentSchedule.FindLast then begin
                                // Principal: use actual outstanding if smaller than scheduled
                                if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                    NORMALLOANp := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                                else
                                    NORMALLOANp := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                                // Interest: default to outstanding interest
                                NORMALLOANi := ROUND(LoansRegister."Oustanding Interest", 1, '>');

                                // If scheduled principal < outstanding, use monthly interest
                                if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                    NORMALLOANi := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            end;
                        end;
                end;

                //Development NORMAL 1 LOAN start==========================================================================================================================================
                DevelopmentLoanInt := 0;
                DevelopmentLoanP := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '25');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal logic
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                DevelopmentLoanP := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                DevelopmentLoanP := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest logic
                            DevelopmentLoanInt := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                DevelopmentLoanInt := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                        if LoanRepaymentSchedule.Find('-') then begin
                            DevelopmentLoanInt := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            DevelopmentLoanP := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal logic
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                DevelopmentLoanP := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                DevelopmentLoanP := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest logic
                            DevelopmentLoanInt := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                DevelopmentLoanInt := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;
                //NORMAL 1 LOAN start==========================================================================================================================================
                NORMALLOAN1i := 0;
                NORMALLOAN1p := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '22');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
                    //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

                    if LoansRegister."Expected Date of Completion" <= ASAT then begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal logic
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                NORMALLOAN1p := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                NORMALLOAN1p := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest logic
                            NORMALLOAN1i := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                NORMALLOAN1i := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;

                    end else if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                        LoanRepaymentSchedule.SetFilter(LoanRepaymentSchedule."Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

                        if LoanRepaymentSchedule.Find('-') then begin
                            NORMALLOAN1i := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                            NORMALLOAN1p := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                        end;
                    end else begin
                        LoanRepaymentSchedule.Reset;
                        LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

                        if LoanRepaymentSchedule.FindLast then begin
                            // Principal logic
                            if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                                NORMALLOAN1p := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                            else
                                NORMALLOAN1p := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                            // Interest logic
                            NORMALLOAN1i := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                            if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                                NORMALLOAN1i := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                        end;
                    end;
                end;

                MERCHANDISEPr := 0;
                MERCHANDISEIn := 0;
                TotalMRepay := 0;

                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '26');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                LoansRegister.SetCurrentKey("Client Code", "Application Date");
                LoansRegister.Ascending(false); // Descending order by Application Date

                if LoansRegister.FindSet then begin
                    repeat
                        //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");
                        if LoansRegister."Loan Disbursement Date" < BeginMonth_Date then begin
                            LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

                            // === PRINCIPAL ===
                            MERCHANDISEPr := MERCHANDISEPr + ROUND(LoansRegister."Loan Principle Repayment", 1, '>');

                            // === INTEREST DEFAULT CALCULATION ===
                            MERCHANDISEIn := MERCHANDISEIn + ROUND(LoansRegister."Outstanding Balance" / 12 * LoansRegister.Interest / 100, 1, '>');

                            // === AMORTIZED METHOD OVERRIDE ===
                            if LoansRegister."Repayment Method" = LoansRegister."repayment method"::Amortised then begin
                                TotalMRepay := ROUND(
                                    (LoansRegister.Interest / 12 / 100) /
                                    (1 - Power(1 + (LoansRegister.Interest / 12 / 100), -LoansRegister.Installments)) *
                                    LoansRegister."Requested Amount", 0.05, '>');

                                // Set interest portion for amortized repayment
                                MERCHANDISEIn := ROUND(LoansRegister."Outstanding Balance" / 100 / 12 * LoansRegister.Interest, 1, '>');

                                // Principal is total monthly repay - interest
                                MERCHANDISEPr := ROUND(TotalMRepay - MERCHANDISEIn, 1, '>');
                            end;
                        end;
                    until LoansRegister.Next() = 0;
                end;

                //....................................................................................
                ////......................................loan
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '25');
                LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
                LoansRegister.SetRange(LoansRegister.Posted, true);
                // LoansRegister.SETRANGE(LoansRegister."Issued Date",ASAT);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    developmentLoan_No := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                ///.........
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '22');
                // LoansRegister.SETRANGE(LoansRegister."Issued Date",ASAT);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    NORMALLOAN1LNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                ////.......................................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '21');
                // LoansRegister.SETRANGE(LoansRegister."Issued Date",ASAT);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    NORMALLOANLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                ///..............................................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '19');
                // LoansRegister.SETRANGE(LoansRegister."Issued Date",ASAT);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    INVESTMENTLOANLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //.............................................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '18');
                // LoansRegister.SETRANGE(LoansRegister."Issued Date",ASAT);
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    SUPERSCHOOLFEESLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //............................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '17');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    SCHOOLFEESLNNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //..............
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '16');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    SUPERQUICKLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //.......................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '15');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    QUICKLOANNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //..............................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '13');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    SUPEREMERGENCYLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //////////////.............................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '12');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    EMERGENCYLNO := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                //..........................
                LoansRegister.Reset;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '23');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                    inDev1 := LoansRegister."Loan  No.";
                end;
                //.................LoansRegister.RESET;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '20');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    lndev := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                LoansRegister.SetRange("Client Code", Customer."No.");
                LoansRegister.SetRange("Loan Product Type", '26');
                LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
                if LoansRegister.FindSet then begin
                    MERCHANDISE_No := LoansRegister."Loan  No.";
                    if LoansRegister."Loan  No." = '' then
                        CurrReport.Skip;
                end;
                TOTALREMMITANCE := 0;
                TOTALREMMITANCE := montlycon + "Welfare Contr" + ShareCapital + NORMALLOAN1i + NORMALLOANp + NORMALLOANi + NORMALLOAN1p + EMERGENCYp + EMERGENCYi + SUPEREMERGENCYp + SUPEREMERGENCYi + QUICKLOANp + QUICKLOANi + SUPERQUICKp + SUPERQUICKi + SCHOOLFEESp + SCHOOLFEESi + SUPERSCHOOLFEESp + SUPERSCHOOLFEESi +
                INVESTMENTLOANi + DevP + Devint + DevelopmentLoanP + DevelopmentLoanInt + MERCHANDISEPr + MERCHANDISEIn;
            end;

        }
    }
    requestpage
    {
        SaveValues = false;
        layout
        {
            area(Content)
            {
                field(Date; ASAT)
                {
                    ApplicationArea = Basic;
                    Caption = 'Date';
                }
            }
        }

    }
    var
        EndMonth_Date: Date;
        BeginMonth_Date: Date;
        ASAT: Date;
        LoansRegister: Record "Loans Register";
        ShareCapital: Decimal;
        DevP: Decimal;
        DevLNO: Code[20];
        Devint: Decimal;
        montlycon: Decimal;
        lndev: Code[30];
        EMERGENCYp: Decimal;
        EMERGENCYi: Decimal;
        EMERGENCYLNO: Code[20];
        EMERGENCYlnb: Code[30];
        SUPEREMERGENCYLNO: Code[20];
        SUPEREMERGENCYp: Decimal;
        SUPEREMERGENCYi: Decimal;
        QUICKLOANNO: Code[20];
        QUICKLOANp: Decimal;
        QUICKLOANi: Decimal;
        SUPERQUICKLNO: Code[20];
        SUPERQUICKp: Decimal;
        SUPERQUICKi: Decimal;
        SCHOOLFEESLNNO: Code[20];
        SCHOOLFEESp: Decimal;
        SCHOOLFEESi: Decimal;
        SUPERSCHOOLFEESLNO: Code[20];
        SUPERSCHOOLFEESp: Decimal;
        SUPERSCHOOLFEESi: Decimal;
        INVESTMENTLOANLNO: Code[20];
        INVESTMENTLOANp: Decimal;
        INVESTMENTLOANi: Decimal;
        TOTALREMMITANCE: Decimal;
        CI: Record "Company Information";
        NORMALLOANLNO: Code[20];
        NORMALLOANp: Decimal;
        NORMALLOANi: Decimal;
        NORMALLOAN1LNO: Code[20];
        NORMALLOAN1p: Decimal;
        NORMALLOAN1i: Decimal;
        DevP1LNO: Code[20];
        DevP1: Decimal;
        Devint1: Decimal;
        inDev1: Code[50];
        LoanRepaymentSchedule: Record "Loan Repayment Schedule";
        DevelopmentLoanP: Decimal;
        DevelopmentLoanInt: Decimal;
        developmentLoan_No: Code[20];
        TotalMRepay: Decimal;
        MERCHANDISEPr: Decimal;
        MERCHANDISEIn: Decimal;
        MERCHANDISE_No: Code[20];
        SwizzFactory: Codeunit "Swizzsoft Factory";

    // trigger OnInitReport();
    // begin
    //     ;
    //     ReportsForNavInit;
    // end;

    // trigger OnPreReport();
    // begin
    //     ;
    //     ReportsForNavPre;
    // end;

    // --> Reports ForNAV Autogenerated code - do not delete or modify
    var
        ReportForNavTotalsCausedBy: Integer;
        ReportForNavInitialized: Boolean;
        ReportForNavShowOutput: Boolean;

    procedure CalculateLoanRepayment(
                                    LoanProductType: Code[10];
                                    var Principal: Decimal;
                                    var Interest: Decimal;
                                    CustomerNo: Code[20];
                                    ASAT: Date;
                                    BeginMonthDate: Date
                                    )
    var
        LoansRegister: Record "Loans Register";
        LoanRepaymentSchedule: Record "Loan Repayment Schedule";
    begin
        Principal := 0;
        Interest := 0;

        LoansRegister.Reset;
        LoansRegister.SetRange("Client Code", CustomerNo);
        LoansRegister.SetRange("Loan Product Type", LoanProductType);
        LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
        LoansRegister.SetRange(LoansRegister.Posted, true);
        LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
        LoansRegister.SetCurrentKey("Client Code", "Application Date");
        LoansRegister.Ascending(false); // Descending order by Application Date

        if LoansRegister.FindSet then begin
            LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");
            //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");

            if LoansRegister."Expected Date of Completion" <= ASAT then begin
                LoanRepaymentSchedule.Reset;
                LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                if LoanRepaymentSchedule.FindLast then begin
                    if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                        Principal := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                    else
                        Principal := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                    Interest := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                    if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                        Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                end;

            end else if LoansRegister."Loan Disbursement Date" < BeginMonthDate then begin
                LoanRepaymentSchedule.Reset;
                LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                LoanRepaymentSchedule.SetFilter("Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));
                if LoanRepaymentSchedule.Find('-') then begin
                    Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                    Principal := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                end;
            end else begin
                LoanRepaymentSchedule.Reset;
                LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
                if LoanRepaymentSchedule.FindLast then begin
                    if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                        Principal := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                    else
                        Principal := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');

                    Interest := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                    if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                        Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
                end;
            end;
        end;
    end;

    procedure CalculateLoanRepayment2(
     LoanProductType: Code[10];
     var Principal: Decimal;
     var Interest: Decimal;
     CustomerNo: Code[20];
     ASAT: Date;
     BeginMonthDate: Date
 )
    var
        LoansRegister: Record "Loans Register";
        LoanRepaymentSchedule: Record "Loan Repayment Schedule";
    begin
        Principal := 0;
        Interest := 0;

        LoansRegister.Reset;
        LoansRegister.SetRange("Client Code", CustomerNo);
        LoansRegister.SetRange("Loan Product Type", LoanProductType);
        LoansRegister.SetAutocalcFields(LoansRegister."Outstanding Balance", LoansRegister."Oustanding Interest");
        LoansRegister.SetRange(LoansRegister.Posted, true);
        LoansRegister.SetFilter("Outstanding Balance", '>%1', 0);
        LoansRegister.SetCurrentKey("Client Code", "Application Date");
        LoansRegister.Ascending(false); // Descending order by Application Date

        if not LoansRegister.FindFirst then
            exit;

        //SwizzFactory.FnGenerateRepaymentSchedule(LoansRegister."Loan  No.");
        LoansRegister.CalcFields("Outstanding Balance", "Oustanding Interest", "Interest Due");

        if LoansRegister."Outstanding Balance" <= 1 then
            exit;

        if LoansRegister."Expected Date of Completion" <= ASAT then begin
            // Case 1: Loan expected to end on or before ASAT
            LoanRepaymentSchedule.Reset;
            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

            if LoanRepaymentSchedule.FindLast then begin
                if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                    Principal := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                else
                    Principal := LoanRepaymentSchedule."Principal Repayment";

                Interest := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                    Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
            end;

        end else if LoansRegister."Loan Disbursement Date" < BeginMonthDate then begin
            // Case 2: Active long-term loan, disbursed before current month
            LoanRepaymentSchedule.Reset;
            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");
            LoanRepaymentSchedule.SetFilter("Repayment Date", '%1..%2', ASAT, CalcDate('CM', ASAT));

            if LoanRepaymentSchedule.Find('-') then begin
                Principal := ROUND(LoanRepaymentSchedule."Principal Repayment", 1, '>');
                Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
            end;

        end else begin
            // Case 3: Loan expected to complete in the future and not disbursed before the month
            Principal := 0;
            Interest := 0;
            LoanRepaymentSchedule.Reset;
            LoanRepaymentSchedule.SetRange("Loan No.", LoansRegister."Loan  No.");

            if LoanRepaymentSchedule.FindLast then begin
                if LoanRepaymentSchedule."Principal Repayment" > LoansRegister."Outstanding Balance" then
                    Principal := ROUND(LoansRegister."Outstanding Balance", 1, '>')
                else
                    Principal := LoanRepaymentSchedule."Principal Repayment";

                Interest := ROUND(LoansRegister."Oustanding Interest", 1, '>');
                if LoanRepaymentSchedule."Principal Repayment" < LoansRegister."Outstanding Balance" then
                    Interest := ROUND(LoanRepaymentSchedule."Monthly Interest", 1, '>');
            end;
        end;
    end;



    /*local procedure ReportsForNavInit()
	var
		id: Integer;
		FormatRegion: Text;
	begin
		Evaluate(id, CopyStr(CurrReport.ObjectId(false), StrPos(CurrReport.ObjectId(false), ' ') + 1));
		ReportForNav.OnInit(id);
	end;
	local procedure ReportsForNavPre() begin end;
	local procedure ReportForNavSetTotalsCausedBy(value : Integer) begin ReportForNavTotalsCausedBy := value; end;
	local procedure ReportForNavSetShowOutput(value : Boolean) begin ReportForNavShowOutput := value; end;
	local procedure ReportForNavInit(jsonObject : JsonObject) begin ReportForNav.Init(jsonObject, CurrReport.ObjectId); end;
	local procedure ReportForNavWriteDataItem(dataItemId: Text; rec : Variant) : Text
	var
		values: Text;
		jsonObject: JsonObject;
		currLanguage: Integer;
	begin
		if not ReportForNavInitialized then begin
			ReportForNavInit(jsonObject);
			ReportForNavInitialized := true;
		end;

		case (dataItemId) of
			'Customer':
				begin
					currLanguage := GlobalLanguage; GlobalLanguage := 1033; jsonObject.Add('DataItem$Customer$CurrentKey$Text',Customer.CurrentKey); GlobalLanguage := currLanguage;
				end;
		end;
		ReportForNav.AddDataItemValues(jsonObject,dataItemId,rec);
		jsonObject.WriteTo(values);
		exit(values);
	end;*/
    // Reports ForNAV Autogenerated code - do not delete or modify -->
}
