#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50053 "Loan Defaulter 1st Notice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/LoanDefaulter_1stNotice.rdl';

    dataset
    {
        dataitem("Loans Register"; "Loans Register")
        {
            RequestFilterFields = "Client Code", "Loan  No.", "Loans Category-SASRA";
            column(ReportForNavId_1102755000; 1102755000)
            {
            }
            column(OutstandingBalance_Loans; "Loans Register"."Outstanding Balance")
            {
            }
            column(LoanNo_Loans; "Loans Register"."Loan  No.")
            {
            }

            column(LoanNo_LoansPrinciple; "Loans Register"."Approved Amount")
            {
            }
            column(LoanNo_LoanDate; "Loans Register"."Issued Date")
            {
            }
            column(LoanNo_LoanPeriod; "Loans Register"."Instalment Period")
            {
            }
            column(LoanNo_LoanPeriodInt; "Loans Register".Installments)
            {
            }
            column(recoverNoticedate; recoverNoticedate)
            {
            }
            column(LoanProductTypeName_LoansRegister; "Loans Register"."Loan Product Type Name")
            {
            }


            column(OutstandingInterest_Loans; "Loans Register"."Oustanding Interest")
            {
            }
            column(ClientName_Loans; "Loans Register"."Client Name")
            {
            }
            column(LoanProductType_LoansRegister; "Loans Register"."Loan Product Type")
            {
            }
            column(ClientCode_Loans; "Loans Register"."Client Code")
            {
            }
            column(RemainingPeriod; RemainingPeriod)
            {
            }

            column(LBalance; LBalance)
            {
            }
            column(LBalance1; LBalance1)
            {
            }
            dataitem("Members Register"; Customer)
            {
                DataItemLink = "No." = field("Client Code");
                RequestFilterFields = "No.";
                column(ReportForNavId_1102755005; 1102755005)
                {
                }
                column(City_Members; "Members Register".City)
                {
                }
                column(Address2_Members; "Members Register"."Address 2")
                {
                }
                column(Address_Members; "Members Register".Address)
                {
                }
                column(DOCNAME; DOCNAME)
                {
                }
                column(CName; CompanyInfo.Name)
                {
                }
                column(Caddress; CompanyInfo.Address)
                {
                }
                column(CmobileNo; CompanyInfo."Phone No.")
                {
                }
                column(clogo; CompanyInfo.Picture)
                {
                }
                column(Cwebsite; CompanyInfo."Home Page")
                {
                }
                column(Email; CompanyInfo."E-Mail")
                {
                }
                column(loansOFFICER; Lofficer)
                {
                }
                dataitem("Default Notices Register"; "Default Notices Register")
                {
                    DataItemLink = "Member No" = field("No.");
                    column(Loan_Outstanding_Balance; "Loan Outstanding Balance")
                    {
                    }
                    column(Outstanding_Interest_DefaultNoticesRegister; "Default Notices Register"."Outstanding Interest")
                    {
                    }
                    column(AmountInArrears_DefaultNoticesRegister; "Default Notices Register"."Amount In Arrears")
                    {
                    }
                    column(DaysInArrears_DefaultNoticesRegister; "Default Notices Register"."Days In Arrears")
                    {
                    }

                }
                trigger OnAfterGetRecord()
                begin
                    workString := CONVERTSTR(Customer.Name, ' ', ',');
                    DearM := SELECTSTR(1, workString);
                    //LastPDate := 0D;
                    Balance := 0;
                    SharesB := 0;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                LBalance := 0;
                Lbalance1 := 0;
                RemainingPeriod := LoansREC.Installments - ObjSwizzFactory.KnGetCurrentPeriodForLoan("Loan  No.");
                recoverNoticedate := CALCDATE('1M', TODAY);
                MemberLedgerEntry.RESET;
                MemberLedgerEntry.SETRANGE("Loan No", LoansREC."Loan  No.");
                IF MemberLedgerEntry.FINDLAST() THEN BEGIN
                    //LoansREC.CALCFIELDS(LoansREC."Outstanding Balance", LoansREC."Oustanding Interest", LoansREC."No. Of Guarantors");
                    IF (MemberLedgerEntry."Transaction Type" = MemberLedgerEntry."Transaction Type"::"Loan Repayment") OR
                      (MemberLedgerEntry."Transaction Type" = MemberLedgerEntry."Transaction Type"::"Interest Paid") THEN
                        LastPayDate := MemberLedgerEntry."Posting Date";
                END;
                IF LastPayDate = 0D THEN
                    LastPayDate := LoansREC."Issued Date";
                LoansREC.CALCFIELDS(LoansREC."Outstanding Balance", LoansREC."Oustanding Interest", LoansREC."No. Of Guarantors");
                NoGuarantors := LoansREC."No. Of Guarantors";
                IF NoGuarantors = 0 THEN
                    NoGuarantors := 1;
                LBalance := LoansREC."Outstanding Balance" + LoansREC."Oustanding Interest";
                LBalance1 := LoansREC."Outstanding Balance";
                Notified := TRUE;
                //LoansREC."Notified date":=TODAY;
                MODIFY;


                Balance := Balance - (LoansREC."Outstanding Balance" + LoansREC."Oustanding Interest");

                SharesB := SharesB - (LoansREC."Outstanding Balance" + LoansREC."Oustanding Interest");

                IF SharesB < 0 THEN
                    BalanceType := 'Debit Balance'
                ELSE
                    BalanceType := 'Credit Balance';


                LoanGuar.RESET;
                LoanGuar.SETRANGE(LoanGuar."Loan No", LoansREC."Loan  No.");
                IF LoanGuar.FIND('-') THEN BEGIN
                    LoanGuar.RESET;
                    LoanGuar.SETRANGE(LoanGuar."Loan No", LoansREC."Loan  No.");

                    REPEAT
                        TGrAmount := TGrAmount + GrAmount;
                        GrAmount := LoanGuar."Amont Guaranteed";
                        //LoanGuar."Amount Guarnted";
                        FGrAmount := TGrAmount + LoanGuar."Amont Guaranteed";
                    UNTIL LoanGuar.NEXT = 0;
                END;
                //Defaulter loan clear
                LoansREC.CALCFIELDS(LoansREC."Outstanding Balance", LoansREC."Interest Due", LoansREC."Oustanding Interest");
                Lbal := ROUND(LoansREC."Outstanding Balance", 0.5, '=');
                INTBAL := LoansREC."Oustanding Interest";
                COMM := LoansREC."Oustanding Interest" * 0.5;



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
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        DOCNAME := 'FIRST DEMAND NOTICE';
        Lofficer := UserId;
    end;



    var
        DOCNAME: Text[30];
        CompanyInfo: Record "Company Information";
        Lofficer: Text;
        recoverNoticedate: Date;
        RemainingPeriod: Integer;
        MemberLedgerEntry: Record "Member Ledger Entry";
        LoansREC: Record "Loans Register";
        ObjSwizzFactory: Codeunit "Swizzsoft Factory.";
        LastPayDate: Date;
        VarArrearsAmount: Decimal;
        NoGuarantors: Integer;
        LBalance: Decimal;
        LBalance1: Decimal;
        Notified: Boolean;
        Balance: Decimal;
        SharesB: Decimal;
        lbal: Decimal;
        IntBal: Decimal;
        COMM: Decimal;
        BalanceType: Text;
        LoanGuar: Record "Loans Guarantee Details";
        TGrAmount: Decimal;
        GrAmount: Decimal;
        Customer: Record Customer;
        workstring: Text;
        DearM: Text;
        FGrAmount: Decimal;


}

