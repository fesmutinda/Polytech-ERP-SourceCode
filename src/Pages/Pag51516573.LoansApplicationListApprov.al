#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516573 "Loans Application List(Approv)"
{
    CardPageID = "Loans Application Card(Approv)";
    Editable = false;
    PageType = List;
    SourceTable = 51516371;
    SourceTableView = where("Approval Status" = filter(Approved),
                            Posted = filter(No),
                            Source = const(BOSA));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan  No."; "Loan  No.")
                {
                    ApplicationArea = Basic;
                }
                field("Application Date"; "Application Date")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Product Type"; "Loan Product Type")
                {
                    ApplicationArea = Basic;
                }
                field("Client Code"; "Client Code")
                {
                    ApplicationArea = Basic;
                }
                field("Group Code"; "Group Code")
                {
                    ApplicationArea = Basic;
                }
                field("Requested Amount"; "Requested Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Approved Amount"; "Approved Amount")
                {
                    ApplicationArea = Basic;
                }
                field(Interest; Interest)
                {
                    ApplicationArea = Basic;
                }
                field(Insurance; Insurance)
                {
                    ApplicationArea = Basic;
                }
                field("Client Name"; "Client Name")
                {
                    ApplicationArea = Basic;
                }
                field("Captured By"; "Captured By")
                {
                    ApplicationArea = Basic;
                }
                field("Released By Auditor"; "Released By Auditor")
                {
                    ApplicationArea = Basic;
                    Style = Attention;
                    StyleExpr = true;
                }
                field("Checked By"; "Checked By")
                {
                    ApplicationArea = Basic;
                    Caption = 'Released By';
                    Style = StrongAccent;
                    StyleExpr = true;
                }
                field(Posted; Posted)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("View Schedule")
            {
                ApplicationArea = Basic;
                Caption = 'View Schedule';
                Image = "Table";
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;
                ShortCutKey = 'Ctrl+F7';

                trigger OnAction()
                begin
                    SFactory.FnGenerateRepaymentSchedule(Rec."Loan  No.");
                    LoanApp.Reset;
                    LoanApp.SetRange(LoanApp."Loan  No.", "Loan  No.");
                    if LoanApp.Find('-') then
                        Report.Run(51516477, true, false, LoanApp);
                end;
            }
            action("Loan Appraisal")
            {
                ApplicationArea = Basic;
                Caption = 'Loan Appraisal';
                Enabled = true;
                Image = GanttChart;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedOnly = true;

                trigger OnAction()
                begin
                    TestField("Mode of Disbursement");
                    LoanApp.Reset;
                    LoanApp.SetRange(LoanApp."Loan  No.", "Loan  No.");
                    if LoanApp.Find('-') then begin
                        if LoanApp.Source = LoanApp.Source::BOSA then
                            Report.Run(51516384, true, false, LoanApp)
                        else
                            Report.Run(51516384, true, false, LoanApp)
                    end;
                end;
            }
            action("Re-OPen Loan")
            {
                ApplicationArea = Basic;
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    if Usersetup.Get(UserId) then begin
                        if Usersetup."Release Loans" = false then
                            Error('You dont have permissions to Release a Loan! ')
                    end;
                    LoanApp.Reset;
                    LoanApp.SetRange("Loan  No.", "Loan  No.");
                    if LoanApp.Find('-') then begin
                        if Confirm('Are you sure you want to Re-Open this Document ?') = true then
                            LoanApp."Loan Status" := LoanApp."loan status"::Application;
                        LoanApp."Approval Status" := LoanApp."approval status"::Open;
                        LoanApp."Released By Auditor" := false;
                        LoanApp."Checked By" := UserId;
                        LoanApp.Modify;
                    end
                end;
            }
        }
    }

    var
        i: Integer;
        LoanType: Record 51516381;
        PeriodDueDate: Date;
        ScheduleRep: Record 51516375;
        LoanGuar: Record 51516372;
        RunningDate: Date;
        G: Integer;
        IssuedDate: Date;
        SMSMessages: Record 51516471;
        iEntryNo: Integer;
        GracePeiodEndDate: Date;
        InstalmentEnddate: Date;
        GracePerodDays: Integer;
        InstalmentDays: Integer;
        NoOfGracePeriod: Integer;
        NewSchedule: Record 51516375;
        RSchedule: Record 51516375;
        GP: Text[30];
        ScheduleCode: Code[20];
        PreviewShedule: Record 51516375;
        PeriodInterval: Code[10];
        CustomerRecord: Record 51516364;
        Gnljnline: Record "Gen. Journal Line";
        Jnlinepost: Codeunit "Gen. Jnl.-Post Line";
        CumInterest: Decimal;
        NewPrincipal: Decimal;
        PeriodPrRepayment: Decimal;
        GenBatch: Record "Gen. Journal Batch";
        LineNo: Integer;
        GnljnlineCopy: Record "Gen. Journal Line";
        NewLNApplicNo: Code[10];
        Cust: Record 51516364;
        LoanApp: Record 51516371;
        TestAmt: Decimal;
        CustRec: Record 51516364;
        CustPostingGroup: Record "Customer Posting Group";
        GenSetUp: Record 51516398;
        PCharges: Record 51516383;
        TCharges: Decimal;
        LAppCharges: Record 51516385;
        LoansR: Record 51516371;
        LoanAmount: Decimal;
        InterestRate: Decimal;
        RepayPeriod: Integer;
        LBalance: Decimal;
        RunDate: Date;
        InstalNo: Decimal;
        RepayInterval: DateFormula;
        TotalMRepay: Decimal;
        LInterest: Decimal;
        LPrincipal: Decimal;
        RepayCode: Code[40];
        GrPrinciple: Integer;
        GrInterest: Integer;
        QPrinciple: Decimal;
        QCounter: Integer;
        InPeriod: DateFormula;
        InitialInstal: Integer;
        InitialGraceInt: Integer;
        GenJournalLine: Record "Gen. Journal Line";
        FOSAComm: Decimal;
        BOSAComm: Decimal;
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        LoanTopUp: Record 51516376;
        Vend: Record Vendor;
        BOSAInt: Decimal;
        TopUpComm: Decimal;
        DActivity: Code[20];
        DBranch: Code[20];
        TotalTopupComm: Decimal;
        CustE: Record 51516364;
        DocN: Text[50];
        DocM: Text[100];
        DNar: Text[250];
        DocF: Text[50];
        MailBody: Text[250];
        ccEmail: Text[250];
        LoanG: Record 51516372;
        SpecialComm: Decimal;
        FOSAName: Text[150];
        IDNo: Code[50];
        MovementTracker: Record 51516394;
        DiscountingAmount: Decimal;
        StatusPermissions: Record 51516452;
        BridgedLoans: Record 51516379;
        SMSMessage: Record 51516471;
        InstallNo2: Integer;
        currency: Record "Currency Exchange Rate";
        CURRENCYFACTOR: Decimal;
        LoanApps: Record 51516371;
        LoanDisbAmount: Decimal;
        BatchTopUpAmount: Decimal;
        BatchTopUpComm: Decimal;
        Disbursement: Record 51516377;
        SchDate: Date;
        DisbDate: Date;
        WhichDay: Integer;
        LBatches: Record 51516371;
        SalDetails: Record 51516373;
        LGuarantors: Record 51516372;
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal;
        CurrpageEditable: Boolean;
        LoanStatusEditable: Boolean;
        MNoEditable: Boolean;
        ApplcDateEditable: Boolean;
        LProdTypeEditable: Boolean;
        InstallmentEditable: Boolean;
        AppliedAmountEditable: Boolean;
        ApprovedAmountEditable: Boolean;
        RepayMethodEditable: Boolean;
        RepaymentEditable: Boolean;
        BatchNoEditable: Boolean;
        RepayFrequencyEditable: Boolean;
        ModeofDisburesmentEdit: Boolean;
        DisbursementDateEditable: Boolean;
        AccountNoEditable: Boolean;
        LNBalance: Decimal;
        ApprovalEntries: Record "Approval Entry";
        RejectionRemarkEditable: Boolean;
        ApprovalEntry: Record "Approval Entry";
        Table_id: Integer;
        Doc_No: Code[20];
        Doc_Type: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        GrossPay: Decimal;
        Nettakehome: Decimal;
        TotalDeductions: Decimal;
        UtilizableAmount: Decimal;
        NetUtilizable: Decimal;
        Deductions: Decimal;
        Benov: Decimal;
        TAXABLEPAY: Record 51516478;
        PAYE: Decimal;
        PAYESUM: Decimal;
        BAND1: Decimal;
        BAND2: Decimal;
        BAND3: Decimal;
        BAND4: Decimal;
        BAND5: Decimal;
        Taxrelief: Decimal;
        OTrelief: Decimal;
        Chargeable: Decimal;
        PartPay: Record 51516494;
        PartPayTotal: Decimal;
        AmountPayable: Decimal;
        RepaySched: Record 51516375;
        LoanReferee1NameEditable: Boolean;
        LoanReferee2NameEditable: Boolean;
        LoanReferee1MobileEditable: Boolean;
        LoanReferee2MobileEditable: Boolean;
        LoanReferee1AddressEditable: Boolean;
        LoanReferee2AddressEditable: Boolean;
        LoanReferee1PhyAddressEditable: Boolean;
        LoanReferee2PhyAddressEditable: Boolean;
        LoanReferee1RelationEditable: Boolean;
        LoanReferee2RelationEditable: Boolean;
        LoanPurposeEditable: Boolean;
        WitnessEditable: Boolean;
        compinfo: Record "Company Information";
        CummulativeGuarantee: Decimal;
        LoansRec: Record 51516371;
        RecoveryModeEditable: Boolean;
        RemarksEditable: Boolean;
        CopyofIDEditable: Boolean;
        CopyofPayslipEditable: Boolean;
        ScheduleBal: Decimal;
        SFactory: Codeunit UnknownCodeunit51516007;
        BATCH_NAME: Code[50];
        BATCH_TEMPLATE: Code[50];
        ReschedulingFees: Decimal;
        ReschedulingFeeAccount: Code[50];
        LoanProcessingFee: Decimal;
        ExciseDuty: Decimal;
        EditableField: Boolean;
        DOCUMENT_NO: Code[40];
        Usersetup: Record "User Setup";


    procedure UpdateControl()
    begin
        if "Approval Status" = "approval status"::Open then begin
            MNoEditable := true;
            ApplcDateEditable := false;
            LoanStatusEditable := false;
            LProdTypeEditable := true;
            InstallmentEditable := true;
            AppliedAmountEditable := true;
            ApprovedAmountEditable := true;
            RepayMethodEditable := true;
            RepaymentEditable := true;
            BatchNoEditable := false;
            RepayFrequencyEditable := true;
            ModeofDisburesmentEdit := true;
            DisbursementDateEditable := false;
            BatchNoEditable := false;
            RemarksEditable := false;
        end;

        if "Approval Status" = "approval status"::Pending then begin
            MNoEditable := false;
            ApplcDateEditable := false;
            LoanStatusEditable := false;
            LProdTypeEditable := false;
            InstallmentEditable := false;
            AppliedAmountEditable := false;
            ApprovedAmountEditable := true;
            RepayMethodEditable := true;
            RepaymentEditable := true;
            BatchNoEditable := false;
            RepayFrequencyEditable := false;
            ModeofDisburesmentEdit := true;
            DisbursementDateEditable := false;
            BatchNoEditable := false;
            RemarksEditable := false;
        end;

        if "Approval Status" = "approval status"::Rejected then begin
            MNoEditable := false;
            AccountNoEditable := false;
            ApplcDateEditable := false;
            LoanStatusEditable := false;
            LProdTypeEditable := false;
            InstallmentEditable := false;
            AppliedAmountEditable := false;
            ApprovedAmountEditable := false;
            RepayMethodEditable := false;
            RepaymentEditable := false;
            BatchNoEditable := false;
            RepayFrequencyEditable := false;
            ModeofDisburesmentEdit := false;
            DisbursementDateEditable := false;
            RejectionRemarkEditable := false;
            BatchNoEditable := false;
            RemarksEditable := false;
        end;

        if "Approval Status" = "approval status"::Approved then begin
            MNoEditable := false;
            AccountNoEditable := false;
            LoanStatusEditable := false;
            ApplcDateEditable := false;
            LProdTypeEditable := false;
            InstallmentEditable := false;
            AppliedAmountEditable := false;
            ApprovedAmountEditable := false;
            RepayMethodEditable := false;
            RepaymentEditable := false;
            BatchNoEditable := true;
            RepayFrequencyEditable := false;
            ModeofDisburesmentEdit := true;
            DisbursementDateEditable := true;
            RejectionRemarkEditable := false;
            BatchNoEditable := true;
            RemarksEditable := false;
        end;
    end;


    procedure LoanAppPermisions()
    begin
    end;

    local procedure FnBoosterLoansDisbursement(ObjLoanDetails: Record 51516371; LineNo: Integer): Code[40]
    var
        GenJournalLine: Record "Gen. Journal Line";
        CUNoSeriesManagement: Codeunit NoSeriesManagement;
        DocNumber: Code[100];
        loanTypes: Record 51516381;
        ObjLoanX: Record 51516371;
    begin
        loanTypes.Reset;
        loanTypes.SetRange(loanTypes.Code, 'BLOAN');
        if loanTypes.Find('-') then begin
            DocNumber := CUNoSeriesManagement.GetNextNo('LOANSB', 0D, true);
            LoansRec.Init;
            LoansRec."Loan  No." := DocNumber;
            LoansRec.Insert;

            if LoansRec.Get(LoansRec."Loan  No.") then begin
                LoansRec."Client Code" := ObjLoanDetails."Client Code";
                LoansRec.Validate(LoansRec."Client Code");
                LoansRec."Loan Product Type" := 'BLOAN';
                LoansRec.Validate(LoansRec."Loan Product Type");
                LoansRec.Interest := ObjLoanDetails.Interest;
                LoansRec."Loan Status" := LoansRec."loan status"::Issued;
                LoansRec."Application Date" := ObjLoanDetails."Application Date";
                LoansRec."Issued Date" := ObjLoanDetails."Posting Date";
                LoansRec."Loan Disbursement Date" := ObjLoanDetails."Loan Disbursement Date";
                LoansRec.Validate(LoansRec."Loan Disbursement Date");
                LoansRec."Mode of Disbursement" := LoansRec."mode of disbursement"::"Bank Transfer";
                LoansRec."Repayment Start Date" := ObjLoanDetails."Repayment Start Date";
                LoansRec."Global Dimension 1 Code" := 'BOSA';
                LoansRec."Global Dimension 2 Code" := SFactory.FnGetUserBranch();
                LoansRec.Source := ObjLoanDetails.Source;
                LoansRec."Approval Status" := ObjLoanDetails."Approval Status";
                LoansRec.Repayment := ObjLoanDetails."Boosted Amount";
                LoansRec."Requested Amount" := ObjLoanDetails."Boosted Amount";
                LoansRec."Approved Amount" := ObjLoanDetails."Boosted Amount";
                LoansRec.Interest := ObjLoanDetails.Interest;
                LoansRec."Mode of Disbursement" := LoansRec."mode of disbursement"::"Bank Transfer";
                LoansRec.Posted := true;
                LoansRec."Advice Date" := Today;
                LoansRec.Modify;
            end;
        end;
        exit(DocNumber);
    end;
}

