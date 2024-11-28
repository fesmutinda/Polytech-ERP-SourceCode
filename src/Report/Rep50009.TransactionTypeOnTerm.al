#pragma warning disable AA0005,AL0579,AL0600,AL0589, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50009 "Transaction Type On Term"
{
    Caption = 'Transaction Type On Term Basis';
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/Transaction Type On Term.rdlc';
    dataset
    {
        dataitem("Transaction Types Table"; "Transaction Types Table")
        {
            RequestFilterFields = "Transaction Type";
            column(Company_Name; Company.Name)
            {
            }
            column(Company_Address; Company.Address)
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(TransactionTypes; "Transaction Types Table"."Transaction Type")
            {
            }
            dataitem(Deposits; "Cust. Ledger Entry")
            {
                DataItemLink = "Transaction Type" = field("Transaction Type"), "Posting Date" = field("Date Filter");
                DataItemTableView = sorting("Transaction Type", "Loan No", "Posting Date") where("Transaction Type" = const("Deposit Contribution"), Reversed = filter(false));
                PrintOnlyIfDetail = false;
                column(OpeningBal; OpeningBal)
                {
                }
                column(ClosingBal; ClosingBal)
                {
                }
                column(TransactionType_Deposits; Deposits."Transaction Type")
                {
                }
                column(Amount_Deposits; Deposits."Amount Posted")
                {
                }
                column(Description_Deposits; Deposits.Description)
                {
                }
                column(DocumentNo_Deposits; Deposits."Document No.")
                {
                }
                column(PostingDate_Deposits; Deposits."Posting Date")
                {
                }
                column(DebitAmount_Deposits; Deposits."Debit Amount")
                {
                }
                column(CreditAmount_Deposits; Deposits."Credit Amount")
                {
                }
                column(Deposits_Description; Deposits.Description)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    Deposits.SetFilter(Deposits."Posting Date", DateFilterBF);
                    if Deposits.Find('-') then begin
                        ClosingBal := ClosingBal + Deposits."Amount Posted";
                        if Deposits."Amount Posted" < 0 then begin
                            Deposits."Credit Amount" := (Deposits."Amount Posted" * -1);
                        end else
                            if Deposits."Amount Posted" > 0 then begin
                                Deposits."Debit Amount" := (Deposits."Amount Posted");
                            end;
                    end else
                        CurrReport.Skip();
                end;

                trigger OnPreDataItem()
                begin
                    ClosingBal := SharesBF;
                    OpeningBal := SharesBF * -1;
                end;
            }

            trigger OnAfterGetRecord()
            begin

                SharesBF := 0;
                InsuranceBF := 0;
                ShareCapBF := 0;
                XmasBF := 0;
                HseBF := 0;
                Dep1BF := 0;
                Dep2BF := 0;
                SchoolfeesBF := 0;
                PepeaShares := 0;
                vanshares := 0;
                computershares := 0;
                FosaShares := 0;
                PrefShares := 0;
                FosaSharesBF := 0;
                ComputerSharesBF := 0;
                VanSharesBF := 0;
                PrefSharesBF := 0;
                // if DateFilterBF <> '' then begin
                //     Cust.Reset;
                //     Cust.SetRange(Cust."No.", "No.");
                //     Cust.SetFilter(Cust."Date Filter", DateFilterBF);
                //     if Cust.Find('-') then begin
                //         Cust.CalcFields(Cust."Shares Retained", Cust."Current Shares", Cust."Insurance Fund", Cust."Fosa Shares", Cust."Computer Shares", Cust."van Shares", Cust."Preferencial Building Shares");
                //         SharesBF := Cust."Current Shares";
                //         ShareCapBF := Cust."Shares Retained";
                //         InsuranceBF := Cust."Insurance Fund";
                //         SchoolfeesBF := Cust."School Fees Shares";
                //         PepeaSharesBF := Cust."Pepea Shares";
                //         FosaSharesBF := Cust."Fosa Shares";
                //         ComputerSharesBF := Cust."Computer Shares";
                //         VanSharesBF := Cust."van Shares";
                //         PrefShares := Cust."Preferencial Building Shares";
                //     end;
                // end;

            end;

            trigger OnPreDataItem()
            begin

                if "Transaction Types Table".GetFilter("Transaction Types Table"."Date Filter") <> '' then
                    DateFilterBF := '..' + Format(CalcDate('-1D', "Transaction Types Table".GetRangeMin("Transaction Types Table"."Date Filter")));
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        Company.Get();
        Company.CalcFields(Company.Picture);
    end;

    var
        OpenBalance: Decimal;
        CLosingBalance: Decimal;
        OpenBalanceXmas: Decimal;
        CLosingBalanceXmas: Decimal;
        Cust: Record Customer;
        OpeningBal: Decimal;
        ClosingBal: Decimal;
        FirstRec: Boolean;
        PrevBal: Integer;
        BalBF: Decimal;
        LoansR: Record "Loans Register";
        DateFilterBF: Text[150];
        SharesBF: Decimal;
        InsuranceBF: Decimal;
        LoanBF: Decimal;
        PrincipleBF: Decimal;
        InterestBF: Decimal;
        ShowZeroBal: Boolean;
        ClosingBalSHCAP: Decimal;
        ShareCapBF: Decimal;
        XmasBF: Decimal;
        Company: Record "Company Information";
        OpenBalanceHse: Decimal;
        CLosingBalanceHse: Decimal;
        OpenBalanceDep1: Decimal;
        CLosingBalanceDep1: Decimal;
        OpenBalanceDep2: Decimal;
        CLosingBalanceDep2: Decimal;
        HseBF: Decimal;
        Dep1BF: Decimal;
        Dep2BF: Decimal;
        OpeningBalInt: Decimal;
        ClosingBalInt: Decimal;
        InterestPaid: Decimal;
        SumInterestPaid: Decimal;
        OpenBalanceJuja: Decimal;
        CLosingBalanceJuja: Decimal;
        OpenBalanceFani: Decimal;
        CLosingBalanceFani: Decimal;
        OpenBalancejpange: Decimal;
        CLosingBalancejpange: Decimal;
        OpenBalancejunior: Decimal;
        CLosingBalancejunior: Decimal;
        OpenBalanceholiday: Decimal;
        CLosingBalanceholiday: Decimal;
        PrincipleBF1: Decimal;
        SchoolfeesBF: Integer;
        OpenBalanceSF: Decimal;
        CLosingBalanceSF: Decimal;
        PepeaShares: Decimal;
        vanshares: Decimal;
        computershares: Decimal;
        FosaShares: Decimal;
        PepeaSharesBF: Decimal;
        OpenBalancePS: Decimal;
        CLosingBalancePS: Decimal;
        OpenBalanceFs: Decimal;
        CLosingBalanceFs: Decimal;
        ComputerSharesBF: Decimal;
        OpenBalanceCs: Decimal;
        CLosingBalanceCs: Decimal;
        FosaSharesBF: Decimal;
        VanSharesBF: Decimal;
        OpenBalanceVs: Decimal;
        CLosingBalanceVs: Decimal;
        OpenBalancePref: Decimal;
        ClosingBalPref: Decimal;
        PrefSharesBF: Decimal;
        PrefShares: Decimal;
}

