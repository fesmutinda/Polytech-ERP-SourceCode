table 50003 "M-Polytech Deductions"
{
    Caption = 'M-Polytech Deductions';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Entry; Integer)
        {
            Caption = 'Entry';
            AutoIncrement = true;
        }
        field(2; "Member Number"; Code[20])
        {
            Caption = 'Member Number';
            TableRelation = Customer."No.";
        }
        field(3; "Member Name"; Code[50])
        {
            Caption = 'Member Name';
        }
        field(4; "Date Deducted"; Date)
        {
            Caption = 'Date Deducted';
        }
        field(5; "Amount Deducted"; Decimal)
        {
            Caption = 'Amount Deducted';
        }
        field(6; "Deposits at Deduction"; Decimal)
        {
            Caption = 'Deposits at Deduction';
        }
        field(7; "Date Eligible"; Date)
        {
            Caption = 'Date Eligible';
        }
        field(8; "Current Deposits"; Decimal)
        {
            Caption = 'Current Deposits';
            CalcFormula = - sum("Cust. Ledger Entry"."Amount Posted" where("Customer No." = field("Member Number"),
                                                                   "Transaction Type" = filter("Deposit Contribution"),
                                                                   Reversed = const(false)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Loan Number"; Code[30])
        {
            Caption = 'Loan Number';
            TableRelation = "Loans Register"."Loan  No.";
        }
        field(10; "Loan Balance"; Decimal)
        {
            Caption = 'Loan Balance';
            CalcFormula = sum("Cust. Ledger Entry"."Amount Posted" where("Customer No." = field("Member Number"),
                                                                  "Loan No" = field("Loan Number"),
                                                                  "Transaction Type" = filter(Loan | "Loan Repayment"),
                                                                  Reversed = const(false)
                                                                  ));
            Editable = false;
            FieldClass = FlowField;
        }
        field(11; "Interest Deducted"; Decimal)
        {
            Caption = 'Interest Deducted';
        }
    }
    keys
    {
        key(PK; Entry)
        {
            Clustered = true;
        }
    }
}
