#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50850 "Micro Finance Schedule"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/MicroFinanceSchedule.rdlc';

    dataset
    {
        dataitem(Micro_Fin_Schedule; Micro_Fin_Schedule)
        {
            column(Amount_Collected; Amount)
            {
            }
            column(LoansBal; LoansBal)
            {
            }

            column(SavingsCollected; Savings)
            {
            }
            column(SavingsCF; SavingsCF)
            {
            }
            column(LoansCF; LoansCF)
            {
            }
            column(InterestCF; InterestCF)
            {
            }
            column(Principle_Collected; "Principle Amount")
            {
            }
            column(Interest_Collected; "Interest Amount")
            {
            }
            column(Excess_Amount; "Excess Amount")
            {
            }
            column(Loan_No_; "Loan No.")
            {
            }
            column(Account_No; Micro_Fin_Schedule."Account Number")
            {
            }
            column(Account_Name; Micro_Fin_Schedule."Account Name")
            {
            }
            column(Loan_No; Micro_Fin_Schedule."Loan No.")
            {
            }
            column(Expected_Principle; Micro_Fin_Schedule."Expected Principle Amount")
            {
            }
            column(Expected_Interest; Micro_Fin_Schedule."Expected Interest")
            {
            }
            column(Savings; Micro_Fin_Schedule.Savings)
            {
            }
            column(Loan_Balance; ToustLoan)
            {
            }
            column(Group_Name; GrpName)
            {
            }
            column(Group_Code; Micro_Fin_Schedule."Group Code")
            {
            }
            column(Company_Name; CompanyInfo.Name)
            {
            }
            column(Company_Picture; CompanyInfo.Picture)
            {
            }
            column(Company_Address; CompanyInfo.Address)
            {
            }
            column(Company_phone; CompanyInfo."Phone No.")
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(CEEPOfficer; CEEPOfficer)
            {
            }
            column(MeetingDate; MeetingDate)
            {
            }
            column(ReceiptNo; ReceiptNo)
            {
            }

            trigger OnAfterGetRecord()
            begin
                //...........................................Amount Collected
                //...........................................Savings Paid
                //...........................................Savings CF
                Grps.Reset();
                Grps.SetRange(Grps."No.", Micro_Fin_Schedule."Account Number");
                Grps.SetFilter(Grps."Date Filter", Format('..' + Format(PeriodEnd)));
                Grps.SetAutoCalcFields(Grps."Current Shares");
                if Grps.find('-') then begin
                    SavingsCF := 0;
                    SavingsCF := Grps."Current Shares";
                end;
                //--------------------------------------------Loan No
                //--------------------------------------------Principle BF
                //...........................................Outstanding Loans CF/Interest CF
                Loans.Reset();
                Loans.SetRange(Loans."Loan  No.", Micro_Fin_Schedule."Loan No.");
                Loans.SetFilter(Loans."Date Filter", Format('..' + Format(PeriodEnd)));
                Loans.SetAutoCalcFields(Loans."Outstanding Balance", Loans."Oustanding Interest");
                if Loans.find('-') then begin
                    LoansCF := 0;
                    LoansCF := Loans."Outstanding Balance";
                    InterestCF := 0;
                    InterestCF := loans."Oustanding Interest"
                end;
                //------------------------------Current Loan Balance
                Loans.Reset();
                Loans.SetRange(Loans."Loan  No.", Micro_Fin_Schedule."Loan No.");
                Loans.SetAutoCalcFields(Loans."Outstanding Balance", Loans."Oustanding Interest");
                if Loans.find('-') then begin
                    LoansBal := 0;
                    LoansBal := Loans."Outstanding Balance" + Loans."Oustanding Interest";
                end;
                //Get group name
                Grps.Reset;
                if Grps.Get(Micro_Fin_Schedule."Group Code") then
                    GrpName := Grps."Group Account Name";
                CEEPOfficer := Grps."Loan Officer Name";

            end;

            trigger OnPreDataItem()
            begin
                LastFieldNo := FieldNo("No.");
                MemberCurrentShares := 0;
                SavingsCF := 0;
                LoansCF := 0;
                LoansBal := 0;
                CompanyInfo.Get();
                CompanyInfo.CalcFields(CompanyInfo.Picture);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(PeriodEnd; PeriodEnd)
                {
                    ApplicationArea = Basic;
                    Caption = 'Transaction Posting Date';
                    //Editable = false;
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
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        "Outstanding Loan": Decimal;
        Saving: Decimal;
        LoanApplic: Record "Loans Register";
        vend: Record Vendor;
        Tsaving: Decimal;
        LoansBal: Decimal;
        LoansCF: Decimal;
        ToustLoan: Decimal;
        Tsavings: Decimal;
        SavingsCF: Decimal;
        GrpName: Text[100];
        PeriodEnd: Date;
        InterestCF: Decimal;
        Grps: Record Customer;
        Loans: Record "Loans Register";
        Outbal: Decimal;
        MemberCurrentShares: Decimal;
        OutInt: Decimal;
        MicroSubform: Record Micro_Fin_Schedule;
        GroupMembers: Record Vendor;
        SAVINGS2: Decimal;
        CompanyInfo: Record "Company Information";
        CEEPOfficer: Text;
        // CEEPOfficerDetails: Record "Loan Officers Details";
        MeetingDate: Date;
        Transactions: Record Micro_Fin_Transactions;
        ReceiptNo: Code[30];
        No: Code[10];

    trigger OnPreReport()
    begin
        Transactions.Reset;
        Transactions.SetRange(Transactions."No.", No);
        if Transactions.Find('-') then begin
            PeriodEnd := Transactions."Transaction Date";
        end;
    end;
}

