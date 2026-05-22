
xmlport 50105 "Polytech Checkoff Import"
{
    Format = VariableText;
    Caption = 'Polytech Checkoff Import';
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(PolytechCheckoffLines; "Polytech CheckoffLines")
            {
                fieldelement(ReceiptHeader; PolytechCheckoffLines."Receipt Header No") { }
                fieldelement(entryNo; PolytechCheckoffLines."Entry No") { }
                fieldelement(Code; PolytechCheckoffLines."Staff/Payroll No") { }
                fieldelement(Share_Capital; PolytechCheckoffLines."Share Capital") { }
                fieldelement(Deposit_Contribution; PolytechCheckoffLines."Deposit Contribution") { }
                fieldelement(Benevolent; PolytechCheckoffLines.Benevolent) { }
                fieldelement(Insurance; PolytechCheckoffLines.Insurance) { }
                fieldelement(Registration; PolytechCheckoffLines.Registration) { }
                fieldelement(Holiday; PolytechCheckoffLines.Holiday) { }
                fieldelement(Emergency_Loan_12_Amount; PolytechCheckoffLines."Emergency Loan 12 Amount") { }
                fieldelement(Emergency_Loan_12_Principle; PolytechCheckoffLines."Emergency Loan 12 Principle") { }
                fieldelement(Emergency_Loan_12_Interest; PolytechCheckoffLines."Emergency Loan 12 Interest") { }
                fieldelement(Super_Emergency_Loan_13_Amount; PolytechCheckoffLines."Super Emergency Loan 13 Amount") { }
                fieldelement(Super_Emergency_Loan_13_Principle; PolytechCheckoffLines."Super Emergency Loan 13 Principle") { }
                fieldelement(Super_Emergency_Loan_13_Interest; PolytechCheckoffLines."Super Emergency Loan 13 Interest") { }
                fieldelement(Quick_Loan_Amount; PolytechCheckoffLines."Quick Loan Amount") { }
                fieldelement(Quick_Loan_Principle; PolytechCheckoffLines."Quick Loan Principle") { }
                fieldelement(Quick_Loan_Interest; PolytechCheckoffLines."Quick Loan Interest") { }
                fieldelement(Super_Quick_Loan_Amount; PolytechCheckoffLines."Super Quick Amount") { }
                fieldelement(Super_Quick_Loan_Principle; PolytechCheckoffLines."Super Quick Principle") { }
                fieldelement(Super_Quick_Loan_Interest; PolytechCheckoffLines."Super Quick Interest") { }
                fieldelement(School_fees_amount; PolytechCheckoffLines."School Fees Amount") { }
                fieldelement(School_fees_principle; PolytechCheckoffLines."School Fees Principle") { }
                fieldelement(School_fees_interest; PolytechCheckoffLines."School Fees Interest") { }
                fieldelement(Super_School_fees_Amount; PolytechCheckoffLines."Super School Fees Amount") { }
                fieldelement(Super_school_fees_principle; PolytechCheckoffLines."Super School Fees Principle") { }
                fieldelement(Super_school_fees_Interest; PolytechCheckoffLines."Super School Fees Interest") { }
                fieldelement(Investment_Loan_Amount; PolytechCheckoffLines."Investment Loan Amount") { }
                fieldelement(Investment_Loan_Principle; PolytechCheckoffLines."Investment Loan Principle") { }
                fieldelement(Investment_Loan_Interest; PolytechCheckoffLines."Investment Loan Interest") { }
                fieldelement(Normal_loan_20_Amount; PolytechCheckoffLines."Normal loan 20 Amount") { }
                fieldelement(Normal_loan_20_Principle; PolytechCheckoffLines."Normal loan 20 Principle") { }
                fieldelement(Normal_loan_20_Interest; PolytechCheckoffLines."Normal loan 20 Interest") { }
                fieldelement(Normal_loan_21_Amount; PolytechCheckoffLines."Normal loan 21 Amount") { }
                fieldelement(Normal_loan_21_Principle; PolytechCheckoffLines."Normal loan 21 Principle") { }
                fieldelement(Normal_loan_21_Interest; PolytechCheckoffLines."Normal loan 21 Interest") { }
                fieldelement(Normal_loan_22_Amount; PolytechCheckoffLines."Normal loan 22 Amount") { }
                fieldelement(Normal_loan_22_Principle; PolytechCheckoffLines."Normal loan 22 Principle") { }
                // fieldelement(Normal_loan_22_Interest; PolytechCheckoffLines."Normal loan 22 Interest") { }
                fieldelement(Development_Loan_23_Amount; PolytechCheckoffLines."Development Loan 23 Amount") { }
                fieldelement(Development_Loan_23_Principle; PolytechCheckoffLines."Development Loan 23 Principle") { }
                fieldelement(Development_Loan_23_Interest; PolytechCheckoffLines."Development Loan 23 Interest") { }
                fieldelement(Development_Loan_25_Amount; PolytechCheckoffLines."Development Loan 25 Amount") { }
                fieldelement(Development_Loan_25_Principle; PolytechCheckoffLines."Development Loan 25 Principle") { }
                fieldelement(Development_Loan_25_Interest; PolytechCheckoffLines."Development Loan 25 Interest") { }
                fieldelement(Merchandise_Loan_26_Amount; PolytechCheckoffLines."Merchandise Loan 26 Amount") { }
                fieldelement(Merchandise_Loan_26_Principle; PolytechCheckoffLines."Merchandise Loan 26 Principle") { }
                fieldelement(Merchandise_Loan_26_Interest; PolytechCheckoffLines."Merchandise Loan 26 Interest") { }
                fieldelement(Welfare_Contribution; PolytechCheckoffLines."Welfare Contribution") { }
            }
        }
    }
}
