
codeunit 50005 "Guarantor Management"
{
    trigger OnRun()
    begin
        fnGetMemberGuarantorshipLiability('2074');
        UpdateLoanGuarantorsCommitment();
    end;

    var
        ObjMembers: Record Customer;
        ObjLoans: Record "Loans Register";
        ObjLoanSecurities: Record "Loan Collateral Details";
        ObjLoanGuarantors: Record "Loans Guarantee Details";

    procedure UpdateLoanGuarantorsCommitment()
    var
        ObjLoanGuarantors: Record "Loans Guarantee Details";
        LoanNo: Code[30];
        ProcessedLoans: Dictionary of [Code[30], Boolean];
    begin
        ProcessedLoans.Add('LoanNo', true);//ProcessedLoans := Dictionary of [Code[30], Boolean].Create();

        ObjLoanGuarantors.Reset();
        ObjLoanGuarantors.SetRange(Substituted, false); // Optional: skip substituted lines
        if ObjLoanGuarantors.FindSet() then begin
            repeat
                LoanNo := ObjLoanGuarantors."Loan No";

                // Avoid recalculating the same LoanNo multiple times
                if not ProcessedLoans.ContainsKey(LoanNo) then begin
                    UpdateCommittedSharesForLoan(LoanNo);
                    ProcessedLoans.Add(LoanNo, true);
                end;
            until ObjLoanGuarantors.Next() = 0;
        end;
    end;


    procedure fnGetMemberGuarantorshipLiability(MemberNo: Code[30]) guarantorshipAmount: Decimal
    var
        commitedShares: Decimal;
        totalCommitedShares: Decimal;
        maxFigure: Decimal;
    begin
        totalCommitedShares := 0;
        guarantorshipAmount := 0;

        //Calculate member maximum = Shares times 2
        ObjMembers.Reset;
        ObjMembers.SetRange(ObjMembers."No.", MemberNo);
        if ObjMembers.FindSet() then begin
            ObjMembers.CalcFields("Current Shares", "Shares Retained");
            maxFigure := ROUND((ObjMembers."Current Shares" * 2), 1, '=');
        end;

        //get their total committed shares....
        totalCommitedShares := ROUND(getAmountGuaranteed(MemberNo), 1, '=');
        //calculate their remaining ability
        guarantorshipAmount := maxFigure - totalCommitedShares;

        //not less than zero
        if guarantorshipAmount < 0 then guarantorshipAmount := 0;

        exit(guarantorshipAmount);
    end;

    procedure fnGetMemberGuarantorshipLiabilityperLoan(MemberNo: Code[30]; loanNumber: Code[30]) guarantorshipAmount: Decimal
    var
        commitedShares: Decimal;
        totalCommitedShares: Decimal;
        maxFigure: Decimal;
    begin
        totalCommitedShares := 0;
        guarantorshipAmount := 0;

        //Calculate member maximum = Shares times 2
        ObjMembers.Reset;
        ObjMembers.SetRange(ObjMembers."No.", MemberNo);
        if ObjMembers.FindSet() then begin
            ObjMembers.CalcFields("Current Shares", "Shares Retained");
            maxFigure := ROUND((ObjMembers."Current Shares" * 2), 1, '=');
        end;

        //get their total committed shares....
        totalCommitedShares := ROUND(getAmountGuaranteedPerLoan(MemberNo, loanNumber), 1, '=');
        //calculate their remaining ability
        guarantorshipAmount := maxFigure - totalCommitedShares;

        //not less than zero
        if guarantorshipAmount < 0 then guarantorshipAmount := 0;

        exit(guarantorshipAmount);
    end;

    procedure fnGetMemberSelfGuarantorshipLiability(MemberNo: Code[30]) guarantorshipAmount: Decimal
    var
        commitedShares: Decimal;
        totalCommitedShares: Decimal;
        maxFigure: Decimal;
    begin
        totalCommitedShares := 0;
        guarantorshipAmount := 0;

        //Calculate member maximum = Shares times 2
        ObjMembers.Reset;
        ObjMembers.SetRange(ObjMembers."No.", MemberNo);
        if ObjMembers.FindSet() then begin
            ObjMembers.CalcFields("Current Shares", "Shares Retained");
            //25% of their shares multplied by 2
            maxFigure := ROUND((ObjMembers."Current Shares" * 2) * (25 / 100), 1, '=');
        end;

        //get their total committed shares....
        totalCommitedShares := ROUND(getAmountSelfGuaranteed(MemberNo), 1, '=');
        //calculate their remaining ability
        guarantorshipAmount := maxFigure - totalCommitedShares;

        //not less than zero
        if guarantorshipAmount < 0 then guarantorshipAmount := 0;

        exit(guarantorshipAmount);
    end;

    local procedure getAmountGuaranteed(memberNumber: Code[30]) amountInuse: Decimal
    begin
        amountInuse := 0;
        ObjLoanGuarantors.Reset;
        ObjLoanGuarantors.SetRange(ObjLoanGuarantors."Member No", memberNumber);
        ObjLoanGuarantors.SetRange(Substituted, false);
        if ObjLoanGuarantors.FindSet then begin
            repeat
                // UpdateCommittedSharesForLoan(ObjLoanGuarantors."Loan No");
                ObjLoanGuarantors.CalcFields(ObjLoanGuarantors."Outstanding Balance");
                if ObjLoanGuarantors."Outstanding Balance" > 0 then begin
                    amountInuse := amountInuse + ObjLoanGuarantors."Committed Shares";

                end;
            until ObjLoanGuarantors.Next = 0;
        end;
    end;

    local procedure getAmountGuaranteedPerLoan(memberNumber: Code[30]; loanNumber: Code[30]) amountInuse: Decimal
    begin
        amountInuse := 0;
        ObjLoanGuarantors.Reset;
        ObjLoanGuarantors.SetRange(ObjLoanGuarantors."Member No", memberNumber);
        ObjLoanGuarantors.SetRange(ObjLoanGuarantors."Loan No", loanNumber);
        ObjLoanGuarantors.SetRange(Substituted, false);
        if ObjLoanGuarantors.FindSet then begin
            repeat
                // UpdateCommittedSharesForLoan(ObjLoanGuarantors."Loan No");
                ObjLoanGuarantors.CalcFields(ObjLoanGuarantors."Outstanding Balance");
                if ObjLoanGuarantors."Outstanding Balance" > 0 then begin
                    amountInuse := amountInuse + ObjLoanGuarantors."Committed Shares";

                end;
            until ObjLoanGuarantors.Next = 0;
        end;
    end;

    local procedure getAmountSelfGuaranteed(memberNumber: Code[30]) amountInuse: Decimal
    begin
        amountInuse := 0;
        ObjLoanGuarantors.Reset;
        ObjLoanGuarantors.SetRange(ObjLoanGuarantors."Member No", memberNumber);
        ObjLoanGuarantors.SetRange(ObjLoanGuarantors."Self Guarantee", true);
        ObjLoanGuarantors.SetRange(Substituted, false);
        if ObjLoanGuarantors.FindSet then begin
            repeat
                // UpdateCommittedSharesForLoan(ObjLoanGuarantors."Loan No");
                ObjLoanGuarantors.CalcFields(ObjLoanGuarantors."Outstanding Balance");
                if ObjLoanGuarantors."Outstanding Balance" > 0 then begin
                    amountInuse := amountInuse + ObjLoanGuarantors."Committed Shares";

                end;
            until ObjLoanGuarantors.Next = 0;
        end;
    end;

    local procedure UpdateCommittedSharesForLoan(LoanNo: Code[30])
    var
        Guarantor: Record "Loans Guarantee Details";
        TotalAmountGuaranteed: Decimal;
        TotalOutstanding: Decimal;
    begin
        // Step 1: Calculate total Amount Guaranteed and Outstanding Balance for this loan
        Guarantor.Reset();
        Guarantor.SetRange("Loan No", LoanNo);
        Guarantor.SetRange(Substituted, false); // exclude substituted guarantors
        if Guarantor.FindSet() then begin
            TotalAmountGuaranteed := 0;
            TotalOutstanding := 0;
            repeat
                Guarantor.CalcFields("Outstanding Balance");
                TotalAmountGuaranteed += Guarantor."Amont Guaranteed";
                TotalOutstanding := Guarantor."Outstanding Balance"; // all share same loan
            until Guarantor.Next() = 0;
        end;

        if TotalAmountGuaranteed = 0 then
            exit;

        // Step 2: Recalculate and update each guarantor's committed shares
        Guarantor.Reset();
        Guarantor.SetRange("Loan No", LoanNo);
        Guarantor.SetRange(Substituted, false);
        if Guarantor.FindSet() then begin
            repeat
                // TotalOutstanding := Guarantor."Outstanding Balance";
                Guarantor."Committed Shares" :=
                    ROUND(
                        (Guarantor."Amont Guaranteed" / TotalAmountGuaranteed) * TotalOutstanding,
                        1, '='
                    );
                Guarantor.Modify();
            until Guarantor.Next() = 0;
        end;
    end;

}
