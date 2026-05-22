
page 57005 "Polytech CheckoffLines"
{
    ApplicationArea = All;
    Caption = 'Polytech CheckoffLines';
    PageType = ListPart;
    SourceTable = "Polytech CheckoffLines";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Receipt Line No"; Rec."Receipt Line No")
                {
                    Visible = false;
                }
                field("Entry No"; Rec."Entry No")
                {
                    Editable = false;
                    ApplicationArea = Basic;
                }
                field("Staff/Payroll No"; Rec."Staff/Payroll No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = Basic;
                }
                field("Member Found"; Rec."Member Found")
                {
                    ApplicationArea = Basic;
                }
                field("Share Capital"; Rec."Share Capital") { ApplicationArea = Basic; }
                field("Deposit Contribution"; Rec."Deposit Contribution") { ApplicationArea = Basic; }
                field(Benevolent; Rec.Benevolent) { ApplicationArea = Basic; }
                field(Insurance; Rec.Insurance) { ApplicationArea = Basic; }
                field(Registration; Rec.Registration) { ApplicationArea = Basic; }
                field(Holiday; Rec.Holiday) { ApplicationArea = Basic; }
                field("Emergency Loan 12 Amount"; Rec."Emergency Loan 12 Amount") { ApplicationArea = Basic; }
                field("Emergency Loan 12 Principle"; Rec."Emergency Loan 12 Principle") { ApplicationArea = Basic; }
                field("Emergency Loan 12 Interest"; Rec."Emergency Loan 12 Interest") { ApplicationArea = Basic; }
                field("Super Emergency Loan 13 Amount"; Rec."Super Emergency Loan 13 Amount") { ApplicationArea = Basic; }
                field("Super Emergency Loan 13 Principle"; Rec."Super Emergency Loan 13 Principle") { ApplicationArea = Basic; }
                field("Super Emergency Loan 13 Interest"; Rec."Super Emergency Loan 13 Interest") { ApplicationArea = Basic; }
                field("Quick Loan Amount"; Rec."Quick Loan Amount") { ApplicationArea = Basic; }
                field("Quick Loan Principle"; Rec."Quick Loan Principle") { ApplicationArea = Basic; }
                field("Quick Loan Interest"; Rec."Quick Loan Interest") { ApplicationArea = Basic; }
                field("Super Quick Amount"; Rec."Super Quick Amount") { ApplicationArea = Basic; }
                field("Super Quick Principle"; Rec."Super Quick Principle") { ApplicationArea = Basic; }
                field("Super Quick Interest"; Rec."Super Quick Interest") { ApplicationArea = Basic; }
                field("School Fees Amount"; Rec."School Fees Amount") { ApplicationArea = Basic; }
                field("School Fees Principle"; Rec."School Fees Principle") { ApplicationArea = Basic; }
                field("School Fees Interest"; Rec."School Fees Interest") { ApplicationArea = Basic; }
                field("Super School Fees Amount"; Rec."Super School Fees Amount") { ApplicationArea = Basic; }
                field("Super School Fees Principle"; Rec."Super School Fees Principle") { ApplicationArea = Basic; }
                field("Super School Fees Interest"; Rec."Super School Fees Interest") { ApplicationArea = Basic; }
                field("Investment Loan Amount"; Rec."Investment Loan Amount") { ApplicationArea = Basic; }
                field("Investment Loan Principle"; Rec."Investment Loan Principle") { ApplicationArea = Basic; }
                field("Investment Loan Interest"; Rec."Investment Loan Interest") { ApplicationArea = Basic; }
                field("Normal loan 20 Amount"; Rec."Normal loan 20 Amount") { ApplicationArea = Basic; }
                field("Normal loan 20 Principle"; Rec."Normal loan 20 Principle") { ApplicationArea = Basic; }
                field("Normal loan 20 Interest"; Rec."Normal loan 20 Interest") { ApplicationArea = Basic; }
                field("Normal loan 21 Amount"; Rec."Normal loan 21 Amount") { ApplicationArea = Basic; }
                field("Normal loan 21 Principle"; Rec."Normal loan 21 Principle") { ApplicationArea = Basic; }
                field("Normal loan 21 Interest"; Rec."Normal loan 21 Interest") { ApplicationArea = Basic; }
                field("Normal loan 22 Amount"; Rec."Normal loan 22 Amount") { ApplicationArea = Basic; }
                field("Normal loan 22 Principle"; Rec."Normal loan 22 Principle") { ApplicationArea = Basic; }
                field("Normal loan 22 Interest"; Rec."Normal loan 22 Interest") { ApplicationArea = Basic; }
                field("Development Loan 23 Amount"; Rec."Development Loan 23 Amount") { ApplicationArea = Basic; }
                field("Development Loan 23 Principle"; Rec."Development Loan 23 Principle") { ApplicationArea = Basic; }
                field("Development Loan 23 Interest"; Rec."Development Loan 23 Interest") { ApplicationArea = Basic; }
                field("Development Loan 25 Amount"; Rec."Development Loan 25 Amount") { ApplicationArea = Basic; }
                field("Development Loan 25 Principle"; Rec."Development Loan 25 Principle") { ApplicationArea = Basic; }
                field("Development Loan 25 Interest"; Rec."Development Loan 25 Interest") { ApplicationArea = Basic; }
                field("Merchandise Loan 26 Amount"; Rec."Merchandise Loan 26 Amount") { ApplicationArea = Basic; }
                field("Merchandise Loan 26 Principle"; Rec."Merchandise Loan 26 Principle") { ApplicationArea = Basic; }
                field("Merchandise Loan 26 Interest"; Rec."Merchandise Loan 26 Interest") { ApplicationArea = Basic; }
                field("Welfare Contribution"; Rec."Welfare Contribution") { ApplicationArea = Basic; }

            }
        }
    }
}
