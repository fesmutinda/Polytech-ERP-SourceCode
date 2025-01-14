codeunit 50054 "Live SASRA Loan Classification"
{
    trigger OnRun()
    begin
        // FnUpdateGLs();
        // FnUpdateKeyDetails();
        //FnResetLoanStatus();
        //FnUpdateLoanStatus();
    end;

    procedure FnResetLoanStatus()
    begin
        LoanClassificationCalc.Reset();
        if LoanClassificationCalc.Find('-') then begin
            LoanClassificationCalc.DeleteAll();
        end;
    end;

    procedure FnUpdateLoanStatus()
    begin
        ExpectedLoanBal := 0;
        CurrentLoanBalance := 0;
        LoanArrears := 0;
        InterestArrears := 0;
        NoOfMonthsInArrears := 0;
        DaysInArrears := 0;
        //.........................
        LoansReg.Reset();
        LoansReg.SetRange(LoansReg.Posted, true);
        LoansReg.SetFilter(LoansReg."Date filter", '..' + Format(Today));
        LoansReg.SetFilter(LoansReg."Schedule Installments", '>%1', 0);
        LoansReg.SetAutocalcFields(LoansReg."Scheduled Principle Payments", LoansReg."Schedule Loan Amount Issued", LoansReg."Schedule Installments", LoansReg."Outstanding Balance", LoansReg."Oustanding Interest", LoansReg."Scheduled Interest Payments", LoansReg."Interest Paid", LoansReg."Principal Paid");
        if LoansReg.Find('-') then begin
            LoansTotal := 0;
            LoansTotal := LoansReg.Count();
            Reached := 0;
            PercentageDone := 0;
            repeat
                Reached := Reached + 1;
                PercentageDone := (Reached / LoansTotal) * 100;
                DialogBox.Open('Processing ' + Format(Reached) + ' of ' + Format(LoansTotal) + ': Percentage= ' + Format(Round(PercentageDone)));
                if (LoansReg."Schedule Installments" > 0) then begin
                    //..........Expected Loan Balance
                    ExpectedLoanBal := 0;
                    ExpectedLoanBal := LoansReg."Schedule Loan Amount Issued" - LoansReg."Scheduled Principle Payments";
                    //...........Current Loan Balance
                    CurrentLoanBalance := 0;
                    CurrentLoanBalance := LoansReg."Outstanding Balance";
                    //...........Calculate Principle Arrears
                    LoanArrears := 0;
                    LoanArrears := CurrentLoanBalance - ExpectedLoanBal;
                    if LoanArrears < 0 then begin
                        LoanArrears := 0;
                    end;

                    //...........................Interest Arrears
                    if LoansReg.Source = LoansReg.Source::BOSA then begin
                        InterestArrears := 0;
                        InterestArrears := LoansReg."Oustanding Interest";
                        if InterestArrears < 0 then begin
                            InterestArrears := 0;
                        end;
                    end else
                        if LoansReg.Source = LoansReg.Source::FOSA then begin
                            InterestArrears := 0;
                            IF (LoansReg."Loan Product Type" = 'LPO') OR (LoansReg."Loan Product Type" = 'CHRISTMAS ADV') OR (LoansReg."Loan Product Type" = 'DIVIDEND') THEN begin
                                IF (LoansReg."Loan Product Type" = 'LPO') OR (LoansReg."Loan Product Type" = 'CHRISTMAS ADV') OR (LoansReg."Loan Product Type" = 'DIVIDEND') THEN begin
                                    IF CalcDate('12M', LoansReg."Loan Disbursement Date") < Today then begin
                                        InterestArrears := LoansReg."Oustanding Interest";
                                    end else
                                        IF CalcDate('12M', LoansReg."Loan Disbursement Date") >= Today then begin
                                            InterestArrears := 0;
                                        end;
                                end else
                                    IF (LoansReg."Loan Product Type" = 'LPO') then begin
                                        IF CalcDate('6M', LoansReg."Loan Disbursement Date") >= Today then begin
                                            InterestArrears := 0;
                                        end else
                                            IF CalcDate('6M', LoansReg."Loan Disbursement Date") < Today then begin
                                                InterestArrears := LoansReg."Oustanding Interest";
                                            end;
                                    end;

                            end else begin
                                InterestArrears := LoansReg."Oustanding Interest";
                            end;
                            if InterestArrears < 0 then begin
                                InterestArrears := 0;
                            end;
                        end else
                            if LoansReg.Source = LoansReg.Source::MICRO then begin
                                InterestArrears := 0;
                                if loansreg."Issued Date" < 20230807D then begin
                                    InterestArrears := LoansReg."Oustanding Interest";
                                end else
                                    if loansreg."Issued Date" >= 20230807D then begin
                                        InterestArrears := (LoansReg."Scheduled Interest Payments") - ((LoansReg."Interest Paid") * -1);
                                    end;
                                if InterestArrears < 0 then begin
                                    InterestArrears := 0;
                                end;
                            end;
                    IF (LoansReg."Loan Product Type" = 'OVERDRAFT') then begin
                        InterestArrears := 0;
                        InterestArrears := LoansReg."Scheduled Interest Payments" - (LoansReg."Interest Paid" * -1);
                    end;
                    //..........Get The Number of Months In Arrears
                    if LoanArrears >= 1 then begin
                        NoOfMonthsInArrears := 0;
                        NoOfMonthsInArrears := ROUND(LoanArrears / (LoansReg."Schedule Loan Amount Issued" / LoansReg."Schedule Installments"), 1, '>');
                    end
                    else
                        if LoanArrears < 1 then begin
                            NoOfMonthsInArrears := 0;
                            NoOfMonthsInArrears := 0;
                        end;
                    DaysInArrears := 0;
                    DaysInArrears := ROUND((LoanArrears / (LoansReg."Schedule Loan Amount Issued" / LoansReg."Schedule Installments") * 30), 1, '>');
                    //...........Classify Paramenters
                    IF LoansReg."Outstanding Balance" > 0 THEN begin
                        if (LoansReg."Expected Date of Completion" <> 0D) and (Today <= LoansReg."Expected Date of Completion") then begin
                            case NoOfMonthsInArrears of
                                0:
                                    begin
                                        LoanClassificationCalc.Init();
                                        LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                        LoanClassificationCalc."Principle In Arrears" := 0;
                                        LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                        LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                        LoanClassificationCalc."No of Days In Arrears" := 0;
                                        LoanClassificationCalc."No of months In Arrears" := 0;
                                        LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Perfoming;
                                        LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                        LoanClassificationCalc.Insert(true);
                                    end;
                                1:
                                    begin
                                        LoanClassificationCalc.Init();
                                        LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                        LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                        LoanClassificationCalc."Principle In Arrears" := LoanArrears;
                                        LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                        LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                        LoanClassificationCalc."No of Days In Arrears" := DaysInArrears;
                                        LoanClassificationCalc."No of months In Arrears" := NoOfMonthsInArrears;
                                        LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Watch;
                                        LoanClassificationCalc.Insert(true);
                                    end;
                                2, 3, 4, 5, 6:
                                    begin
                                        LoanClassificationCalc.Init();
                                        LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                        LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                        LoanClassificationCalc."Principle In Arrears" := LoanArrears;
                                        LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                        LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                        LoanClassificationCalc."No of Days In Arrears" := DaysInArrears;
                                        LoanClassificationCalc."No of months In Arrears" := NoOfMonthsInArrears;
                                        LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Substandard;
                                        LoanClassificationCalc.Insert(true);
                                    end;
                                7, 8, 9, 10, 11, 12:
                                    begin
                                        LoanClassificationCalc.Init();
                                        LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                        LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                        LoanClassificationCalc."Principle In Arrears" := LoanArrears;
                                        LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                        LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                        LoanClassificationCalc."No of Days In Arrears" := DaysInArrears;
                                        LoanClassificationCalc."No of months In Arrears" := NoOfMonthsInArrears;
                                        LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Doubtful;
                                        LoanClassificationCalc.Insert(true);
                                    end;
                                else begin
                                    LoanClassificationCalc.Init();
                                    LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                    LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                    LoanClassificationCalc."Principle In Arrears" := LoanArrears;
                                    LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                    LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                    LoanClassificationCalc."No of Days In Arrears" := DaysInArrears;
                                    LoanClassificationCalc."No of months In Arrears" := NoOfMonthsInArrears;
                                    LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Loss;
                                    LoanClassificationCalc.Insert(true);
                                end;
                            end;
                        end else
                            if (LoansReg."Expected Date of Completion" <> 0D) and (Today > LoansReg."Expected Date of Completion") then begin
                                LoanClassificationCalc.Init();
                                LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                                LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                                LoanClassificationCalc."Principle In Arrears" := LoansReg."Outstanding Balance";
                                LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                                LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                                LoanClassificationCalc."No of Days In Arrears" := DaysInArrears;
                                LoanClassificationCalc."No of months In Arrears" := NoOfMonthsInArrears;
                                LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::Loss;
                                LoanClassificationCalc.Insert(true);
                            end;
                    end ELSE
                        IF LoansReg."Outstanding Balance" < 0 THEN begin
                            LoanClassificationCalc.Init();
                            LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                            LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                            LoanClassificationCalc."Principle In Arrears" := 0;
                            LoanClassificationCalc."Interest In Arrears" := InterestArrears;
                            LoanClassificationCalc."Amount In Arrears" := LoanClassificationCalc."Principle In Arrears" + LoanClassificationCalc."Interest In Arrears";
                            LoanClassificationCalc."No of Days In Arrears" := 0;
                            LoanClassificationCalc."No of months In Arrears" := 0;
                            LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::" ";
                            LoanClassificationCalc.Insert(true);
                        end;
                end else begin
                    LoanClassificationCalc.Init();
                    LoanClassificationCalc."Client Code" := LoansReg."Client Code";
                    LoanClassificationCalc."Loan No" := LoansReg."Loan  No.";
                    LoanClassificationCalc."Principle In Arrears" := 0;
                    LoanClassificationCalc."Interest In Arrears" := 0;
                    LoanClassificationCalc."Amount In Arrears" := 0;
                    LoanClassificationCalc."No of Days In Arrears" := 0;
                    LoanClassificationCalc."No of months In Arrears" := 0;
                    LoanClassificationCalc."SASRA Loan Category" := LoanClassificationCalc."SASRA Loan Category"::" ";
                    LoanClassificationCalc.Insert(true);
                end;
            //*******************************************************Input to calculator

            until LoansReg.Next = 0;
        end;
        DialogBox.Close();
    end;

    local procedure FnGetSourceCode(LoanNo: Code[20]): Code[20]
    var
        LoansRegister: Record "Loans Register";
    begin
        LoansRegister.Reset();
        LoansRegister.SetRange(LoansRegister."Loan  No.", LoanNo);
        if LoansRegister.Find('-') then begin
            exit(Format(LoansRegister.Source));
        end;

    end;

    procedure FnUpdateKeyDetails()
    var
        Custledger: Record "Cust. Ledger Entry";
    begin
        //..................Update FOSA & BOSA Dimensions In Cust Ledger Entry
        //.......................Update Loan Branch Code
        LoansReg.Reset();
        LoansReg.SetRange(LoansReg."Branch Code", '');
        if LoansReg.Find('-') then begin
            repeat
                LoansReg."Branch Code" := SurestepFactory.FnGetMemberBranch(LoansReg."Client Code");
                LoansReg.Modify();
            until LoansReg.Next = 0;
        end;
        //....................
        Custledger.Reset();
        Custledger.SetFilter(Custledger."Transaction Type", '=%1|%2|%3|%4', Custledger."Transaction Type"::Loan, Custledger."Transaction Type"::"Interest Paid", Custledger."Transaction Type"::"Interest Due", Custledger."Transaction Type"::Repayment);
        //Custledger.SetRange(Custledger."Posting Date", Today);
        if Custledger.Find('-') then begin
            repeat
                Custledger."Global Dimension 1 Code" := FnGetSourceCode(Custledger."Loan No");//FOSA,BOSA,MICRO
                IF Custledger."Global Dimension 2 Code" = '' then begin//Branch Code
                    Custledger."Global Dimension 2 Code" := SurestepFactory.FnGetMemberBranch(Custledger."Customer No.");
                end;
                Custledger.Modify();
            until Custledger.Next = 0;
        end;
    end;

    local procedure FnGetBranchCodeWithDocNo(DocumentNo: Code[20]): Code[20]
    var
        GLEntryTable: Record "G/L Entry";
    begin
        GLEntryTable.Reset();
        GLEntryTable.SetRange(GLEntryTable."Document No.", DocumentNo);
        GLEntryTable.SetFilter(GLEntryTable."Global Dimension 2 Code", '<>%1', ' ');
        if GLEntryTable.FindLast() then begin
            exit(GLEntryTable."Global Dimension 2 Code");
        end;
    end;

    procedure FnUpdateGLs()
    var
        GLEntryTable: Record "G/L Entry";
    begin
        GLEntryTable.Reset();
        //GLEntryTable.SetRange(GLEntryTable."G/L Account No.", '1531');
        GLEntryTable.SetFilter(GLEntryTable."Posting Date", '%1..%2', 20230801D, Today);
        if GLEntryTable.Find('-') then begin
            repeat
                if GLEntryTable."Global Dimension 2 Code" = '' then begin
                    GLEntryTable."Global Dimension 2 Code" := '';
                    GLEntryTable."Global Dimension 2 Code" := FnGetBranchCodeWithDocNo(GLEntryTable."Document No.");

                    if GLEntryTable."Global Dimension 2 Code" = '' then begin
                        if GLEntryTable."Bal. Account Type" = GLEntryTable."Bal. Account Type"::Vendor then begin
                            GLEntryTable."Global Dimension 2 Code" := SurestepFactory.FnGetMemberBranchUsingFosaAccount(GLEntryTable."Bal. Account No.");
                        end;
                        if GLEntryTable."Bal. Account Type" = GLEntryTable."Bal. Account Type"::"G/L Account" then begin
                            GLEntryTable."Global Dimension 2 Code" := SurestepFactory.FnGetUserBranchB(GLEntryTable."User ID");
                        end;
                        if GLEntryTable."Bal. Account Type" = GLEntryTable."Bal. Account Type"::Customer then begin
                            GLEntryTable."Global Dimension 2 Code" := SurestepFactory.FnGetMemberBranch(GLEntryTable."Bal. Account No.");
                        end;
                        if GLEntryTable."Bal. Account Type" = GLEntryTable."Bal. Account Type"::"Bank Account" then begin
                            GLEntryTable."Global Dimension 2 Code" := SurestepFactory.FnGetUserBranchB(GLEntryTable."User ID");
                        end;
                    end;
                    GLEntryTable.Modify();
                end;
            until GLEntryTable.Next = 0;
        end;
    end;

    var
        LoansReg: Record "Loans Register";
        msg: Text;
        SurestepFactory: Codeunit "SURESTEP Factory";
        DateFilter: Text;
        ExpectedLoanBal: Decimal;
        CurrentLoanBalance: Decimal;
        LoanArrears: Decimal;
        NoOfMonthsInArrears: Decimal;
        DaysInArrears: Decimal;
        InterestArrears: Decimal;
        LoansTotal: Integer;
        Reached: integer;
        PercentageDone: Decimal;
        DialogBox: Dialog;
        LoanClassificationCalc: record "Loan Classification Calculator";
}
