#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56265 "Yearly Loan Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Yearly Loan Report.rdlc';

    dataset
    {
        dataitem("Loans Register"; "Loans Register")
        {
            RequestFilterFields = "Loan  No.", "Client Code";
            column(ReportForNavId_1; 1)
            {
            }
            column(OutstandingBalance_LoansRegister; "Loans Register"."Outstanding Balance")
            {
            }
            column(OustandingInterest_LoansRegister; "Loans Register"."Oustanding Interest")
            {
            }
            column(Installments_LoansRegister; "Loans Register".Installments)
            {
            }
            column(LoanDisbursementDate_LoansRegister; "Loans Register"."Loan Disbursement Date")
            {
            }
            column(ClientName_LoansRegister; "Loans Register"."Client Name")
            {
            }
            column(LoanNo_LoansRegister; "Loans Register"."Loan  No.")
            {
            }
            column(ApplicationDate_LoansRegister; "Loans Register"."Application Date")
            {
            }
            column(LoanProductType_LoansRegister; "Loans Register"."Loan Product Type")
            {
            }
            column(ClientCode_LoansRegister; "Loans Register"."Client Code")
            {
            }
            column(GroupCode_LoansRegister; "Loans Register"."Group Code")
            {
            }
            column(Savings_LoansRegister; "Loans Register".Savings)
            {
            }
            column(RequestedAmount_LoansRegister; "Loans Register"."Requested Amount")
            {
            }
            column(ApprovedAmount_LoansRegister; "Loans Register"."Approved Amount")
            {
            }
            column(Interest_LoansRegister; "Loans Register".Interest)
            {
            }
            column(TAmountPaid; TAmountPaid)
            {
            }
            column(TIntDue; TIntDue)
            {
            }
            column(currrentBal; currrentBal)
            {
            }
            column(TIntPaid; TIntPaid)
            {
            }
            column(LastPayDate_LoansRegister; "Loans Register"."Last Pay Date")
            {
            }

            trigger OnAfterGetRecord()
            begin

                TAmountPaid := 0;
                AmountPaid := 0;
                TIntDue := 0;
                TIntPaid := 0;
                IntDue := 0;
                IntPaid := 0;

                MemberLedgerEntry.Reset();
                MemberLedgerEntry.SetRange(MemberLedgerEntry."Loan No", "Loans Register"."Loan  No.");
                MemberLedgerEntry.SetRange(MemberLedgerEntry.Reversed, false);
                MemberLedgerEntry.SetFilter(MemberLedgerEntry."Posting Date", '%1..%2', Beging_Date, End_Date);
                if MemberLedgerEntry.Find('-') then begin
                    repeat
                        if MemberLedgerEntry."Transaction Type" = MemberLedgerEntry."transaction type"::"Loan Repayment" then begin
                            TAmountPaid += (-1 * MemberLedgerEntry."Amount Posted");
                        end;
                        if MemberLedgerEntry."Transaction Type" = MemberLedgerEntry."transaction type"::"Interest Due" then begin
                            TIntDue += MemberLedgerEntry."Amount Posted";
                        end;
                        if MemberLedgerEntry."Transaction Type" = MemberLedgerEntry."transaction type"::"Interest Paid" then begin
                            TIntPaid += (-1 * MemberLedgerEntry."Amount Posted");
                        end;
                    until MemberLedgerEntry.Next = 0;
                end;
                LoanApp.Reset;
                LoanApp.SetRange(LoanApp."Loan  No.", "Loans Register"."Loan  No.");
                LoanApp.SetFilter(LoanApp."Date filter", '%1..%2', Beging_Date, End_Date);
                if LoanApp.Find('-') then begin
                    LoanApp.CalcFields("Outstanding Balance");
                    repeat
                        currrentBal := LoanApp."Outstanding Balance";
                    until LoanApp.Next = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if Beging_Date = 0D then
                    Error('Please Enter the start Date');
                if End_Date = 0D then
                    Error('Please Enter the end Date');
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(Start_Date; Beging_Date)
                {
                    ApplicationArea = Basic;
                }
                field(End_Date; End_Date)
                {
                    ApplicationArea = Basic;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        AmountPaid: Decimal;
        TAmountPaid: Decimal;
        IntDue: Decimal;
        TIntDue: Decimal;
        IntPaid: Decimal;
        TIntPaid: Decimal;
        MemberLedgerEntry: Record "Cust. Ledger Entry";
        currrentBal: Decimal;
        Beging_Date: Date;
        End_Date: Date;
        LoanApp: Record "Loans Register";
}

