#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56598 InsiderN
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/InsiderN.rdlc';

    dataset
    {
        dataitem("Supervisory$Board$Empl"; "Supervisory$Board$Empl")
        {
            RequestFilterFields = "Member No", "Position held";
            column(ReportForNavId_35; 35)
            {
            }
            column(Positioninsociety_SaccoInsiders; "Supervisory$Board$Empl"."Position held")
            {
            }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = field("Member No");
                column(ReportForNavId_36; 36)
                {
                }
                column(CurrentShares_MembersRegister; Customer."Current Shares")
                {
                }
                dataitem("Loans Register"; "Loans Register")
                {
                    DataItemLink = "Client Code" = field("No.");
                    // DataItemTableView = where("Outstanding Balance" = filter(> 0));
                    // RequestFilterFields = "Loan Disbursement Date", "Date filter";
                    column(ReportForNavId_1; 1)
                    {
                    }
                    column(StartDate; StartDate)
                    {
                    }
                    column(MStartDate; MStartDate)
                    {
                    }
                    column(MEndDate; MEndDate)
                    {
                    }
                    column(AsAt; End_Date)
                    {
                    }
                    column(EmplNme; EmplNme)
                    {
                    }
                    column(EmplNme1; EmplNme1)
                    {
                    }
                    column(LoanNo_LoansRegister; "Loans Register"."Loan  No.")
                    {
                    }
                    column(qwe; qwe)
                    {
                    }
                    column(EmplNmeboard; EmplNmeboard)
                    {
                    }
                    column(EmplNme1board; EmplNme1board)
                    {
                    }
                    column(LoanNo; LoanNo)
                    {
                    }
                    column(LoanNo1; LoanNo1)
                    {
                    }
                    column(LoanNo2; LoanNo2)
                    {
                    }
                    column(LoanNo3; LoanNo3)
                    {
                    }
                    column(InsiderBoard_LoansRegister; "Loans Register"."Insider-board")
                    {
                    }
                    column(insiderEmployee_LoansRegister; "Loans Register"."Insider-Employee")
                    {
                    }
                    column(t; T)
                    {
                    }
                    column(MEMBERNUMBER; MEMBERNUMBER)
                    {
                    }
                    column(POSITIONHELD; POSITIONHELD)
                    {
                    }
                    column(AMOUNTGRANTED; AMOUNTGRANTED)
                    {
                    }
                    column(DATEAPPROVED; DATEAPPROVED)
                    {
                    }
                    column(AMOUNTrequested; AMOUNT)
                    {
                    }
                    column(AMOUNTOFBOSADEPOSITS; AMOUNTOFBOSADEPOSITS)
                    {
                    }
                    column(NATUREOFSECURITY; NATUREOFSECURITY)
                    {
                    }
                    column(REPAYMENTCOMMENCEMENT; REPAYMENTCOMMENCEMENT)
                    {
                    }
                    column(REPAYMENTPERIOD; REPAYMENTPERIOD)
                    {
                    }
                    column(LOANTYPENAME; LOANTYPENAME)
                    {
                    }
                    column(OUTSTANDINGAMOUNT; OUTSTANDINGAMOUNT)
                    {
                    }
                    column(PERFORMANCE; PERFORMANCE)
                    {
                    }
                    column(LoansCategorySASRA_LoansRegister; "Loans Register"."Loans Category-SASRA")
                    {
                    }
                    column(name; CompanyProperty.DisplayName)
                    {
                    }
                    column(LoansCategory_LoansRegister; "Loans Register"."Loans Category")
                    {
                    }
                    column(SN; SN)
                    {
                    }
                    column(MemberName_LoansRegister; "Loans Register"."Client Name")
                    {
                    }
                    column(ClientCode_LoansRegister; "Loans Register"."Client Code")
                    {
                    }
                    column(LoanProductType_LoansRegister; "Loans Register"."Loan Product Type")
                    {
                    }
                    column(Installments_LoansRegister; "Loans Register".Installments)
                    {
                    }
                    column(RepaymentStartDate_LoansRegister; "Loans Register"."Repayment Start Date")
                    {
                    }
                    column(InstalmentPeriod_LoansRegister; "Loans Register"."Instalment Period")
                    {
                    }
                    column(RequestedAmount_LoansRegister; "Loans Register"."Requested Amount")
                    {
                    }
                    column(IssuedDate_LoansRegister; "Loans Register"."Issued Date")
                    {
                    }
                    column(LoanAmount_LoansRegister; "Loans Register"."Loan Amount")
                    {
                    }
                    column(ApprovedAmount_LoansRegister; "Loans Register"."Approved Amount")
                    {
                    }
                    column(OutstandingBalance_LoansRegister; "Loans Register"."Outstanding Balance")
                    {
                    }
                    column(LoanProductTypeName_LoansRegister; "Loans Register"."Loan Product Type Name")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        qwe := '';
                        SN := SN + 1;
                        NATUREOFSECURITY := '';
                        LoanApp.Reset;
                        LoanApp.SetRange(LoanApp."Loan  No.", "Loans Register"."Loan  No.");
                        if LoanApp.Find('-') then begin
                            if LoanApp."Loan Product Type" = 'D315' then begin
                                //AMOUNT:=LoanApp."Loan Disbursed Amount";
                                AMOUNT := "Loans Register"."Loan Amount";
                            end else
                                AMOUNT := LoanApp."Approved Amount";
                        end;

                        LoanApp.Reset;
                        LoanApp.SetRange(LoanApp."Loan  No.", "Loans Register"."Loan  No.");
                        LoanApp.SetFilter(LoanApp."Date filter", '%1..%2', Beging_Date, End_Date);
                        LoanApp.SetAutocalcFields("Outstanding Balance");
                        if LoanApp.Find('-') then begin
                            OUTSTANDINGAMOUNT := LoanApp."Outstanding Balance";
                        end;

                        LoansGuaranteeDetails.Reset;
                        LoansGuaranteeDetails.SetRange(LoansGuaranteeDetails."Loan No", LoanApp."Loan  No.");
                        LoansGuaranteeDetails.SetRange(LoansGuaranteeDetails."Loanees  No", LoanApp."Client Code");
                        if LoansGuaranteeDetails.Find('-') then begin
                            LoansGuaranteeDetails.CalcFields(LoanCount);
                            LoanCount := LoansGuaranteeDetails.LoanCount;
                        end;

                        LoansGuaranteeDetails.Reset;
                        LoansGuaranteeDetails.SetRange(LoansGuaranteeDetails."Loan No", "Loans Register"."Loan  No.");
                        if LoansGuaranteeDetails.FindFirst then begin
                            LoansGuaranteeDetails.CalcFields(LoanCount);

                            if (LoansGuaranteeDetails.LoanCount = 1) and (LoansGuaranteeDetails."Self Guarantee" = true) then
                                NATUREOFSECURITY := 'Deposits'
                            else
                                NATUREOFSECURITY := 'Guarantors'

                        end;
                        LoanCollateralDetails.Reset;
                        LoanCollateralDetails.SetRange(LoanCollateralDetails."Loan No", "Loans Register"."Loan  No.");
                        if LoanCollateralDetails.FindFirst then begin
                            NATUREOFSECURITY := 'Collateral'
                        end;
                        if NATUREOFSECURITY = '' then begin
                            NATUREOFSECURITY := 'Deposits';
                        end;
                    end;

                    trigger OnPreDataItem()
                    begin
                        "Loans Register".SetFilter("Loans Register"."Date filter", '%1..%2', Beging_Date, End_Date);
                        "Loans Register".SetFilter("Loans Register"."Loan Disbursement Date", '%1..%2', Beging_Date, End_Date);
                    end;
                }
            }
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

    trigger OnPreReport()
    begin
        if Beging_Date = 0D then
            Error('Please Enter the start Date');
        if End_Date = 0D then
            Error('Please Enter the end Date');


        StartDate := CalcDate('-CY', End_Date);
        MStartDate := CalcDate('-CM', End_Date);
        MEndDate := CalcDate('CM', End_Date);

        loansDateFilter := Format(Beging_Date) + '..' + Format(End_Date);
    end;

    var
        StartDate: Date;
        MStartDate: Date;
        MEndDate: Date;
        LoansGuaranteeDetails: Record "Loans Guarantee Details";
        LoanCollateralDetails: Record "Loan Collateral Details";
        LoanCount: Integer;
        loansDateFilter: Text;
        Beging_Date: Date;
        End_Date: Date;
        LoanApp: Record "Loans Register";
        EmplNme: Text;
        EmplNme1: Text[50];
        // MembersRegister: Record UnknownRecord51516364;
        LoansRegister: Record "Loans Register";
        qwe: Text[50];
        EmplNmeboard: Text;
        EmplNme1board: Text;
        LoanNo: Code[20];
        LoanNo1: Code[20];
        LoanNo2: Code[20];
        LoanNo3: Code[20];
        T: Boolean;
        F: Boolean;
        MEMBERNUMBER: Code[30];
        POSITIONHELD: Text;
        LOANTYPENAME: Text;
        AMOUNT: Decimal;
        AMOUNTGRANTED: Decimal;
        DATEAPPROVED: Date;
        AMOUNTOFBOSADEPOSITS: Decimal;
        NATUREOFSECURITY: Text;
        REPAYMENTCOMMENCEMENT: Date;
        REPAYMENTPERIOD: DateFormula;
        OUTSTANDINGAMOUNT: Decimal;
        PERFORMANCE: Text;
        SN: Integer;
        "Insider-Board": Boolean;
    // LoansGuaranteeDetails: Record UnknownRecord51516372;
    // LoanCollateralDetails: Record UnknownRecord51516374;
}

