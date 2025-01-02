Codeunit 50005 "Custom Workflow Responses old" //Back to 50041
{

    trigger OnRun()
    begin
    end;

    var
        WFEventHandler: Codeunit "Workflow Event Handling";
        SwizzsoftWFEvents: Codeunit "Custom Workflow Events";
        WFResponseHandler: Codeunit "Workflow Response Handling";


    procedure AddResponsesToLib()
    begin
        AddResponsePredecessors();
    end;

    procedure AddResponsePredecessors()
    begin
        //-----------------------------End AddOn--------------------------------------------------------------------------------------
    end;


    procedure ReleasePaymentVoucher(var PaymentHeader: Record "Payment Header")
    var
        PHeader: Record "Payment Header";
    begin
        PHeader.Reset;
        PHeader.SetRange(PHeader."No.", PaymentHeader."No.");
        if PHeader.FindFirst then begin
            PHeader.Status := PHeader.Status::Approved;
            PHeader.Modify;
        end;
    end;


    procedure ReOpenPaymentVoucher(var PaymentHeader: Record "Payment Header")
    var
        PHeader: Record "Payment Header";
    begin
        PHeader.Reset;
        PHeader.SetRange(PHeader."No.", PaymentHeader."No.");
        if PHeader.FindFirst then begin
            PHeader.Status := PHeader.Status::"Pending Approval";
            PHeader.Modify;
        end;
    end;


    procedure ReleaseMembershipApplication(var MembershipApplication: Record "Membership Applications")
    var
        MembershipApp: Record "Membership Applications";
    begin

        MembershipApp.Reset;
        MembershipApp.SetRange(MembershipApp."No.", MembershipApplication."No.");
        if MembershipApp.FindFirst then begin
            MembershipApp.Status := MembershipApp.Status::Approved;
            MembershipApp.Modify;
        end;
    end;


    procedure ReOpenMembershipApplication(MembershipApp: Record "Membership Applications")

    begin
        MembershipApp.Reset;
        MembershipApp.SetRange(MembershipApp."No.", MembershipApp."No.");
        if MembershipApp.FindFirst then begin
            MembershipApp.Status := MembershipApp.Status::Open;
            MembershipApp.Modify;
        end;
    end;

    procedure ReleaseMembershipExit(var MembershipExt: Record "Membership Exist")
    var
    //MembershipExt: Record "Membership Exist";
    begin

        MembershipExt.Reset;
        MembershipExt.SetRange(MembershipExt."No.", MembershipExt."No.");
        if MembershipExt.FindFirst then begin
            MembershipExt.Status := MembershipExt.Status::Approved;
            MembershipExt.Modify;
        end;
    end;


    procedure ReOpenMembershipExit(MembershipApp: Record "Membership Exist")

    begin
        MembershipApp.Reset;
        MembershipApp.SetRange(MembershipApp."No.", MembershipApp."No.");
        if MembershipApp.FindFirst then begin
            MembershipApp.Status := MembershipApp.Status::Open;
            MembershipApp.Modify;
        end;
    end;



    procedure ReleaseLoanApplication(var LoanApplication: Record "Loans Register")
    var
        LoanB: Record "Loans Register";
    begin
        LoanB.Reset;
        LoanB.SetRange(LoanB."Loan  No.", LoanApplication."Loan  No.");
        if LoanB.FindFirst then begin
            LoanB."Loan Status" := LoanB."loan status"::Approved;
            LoanB."Approval Status" := LoanB."approval status"::Approved;
            LoanB.Modify;
        end;
    end;


    procedure ReOpenLoanApplication(var LoanApplication: Record "Loans Register")
    var
        LoanB: Record "Loans Register";
    begin
        LoanB.Reset;
        LoanB.SetRange(LoanB."Loan  No.", LoanApplication."Loan  No.");
        if LoanB.FindFirst then begin
            LoanB."Loan Status" := LoanB."loan status"::Application;
            LoanB."Approval Status" := LoanB."approval status"::Open;
            LoanB.Modify;
        end;
    end;


    procedure ReleaseLoanDisbursement(var LoanDisbursement: Record 51377)
    var
        LoanD: Record 51377;
    begin
        LoanD.Reset;
        LoanD.SetRange(LoanD."Batch No.", LoanDisbursement."Batch No.");
        if LoanD.FindFirst then begin
            LoanD.Status := LoanD.Status::Approved;
            LoanD.Modify;
        end;
    end;


    procedure ReOpenLoanDisbursement(var LoanDisbursement: Record 51377)
    var
        LoanD: Record 51377;
    begin
        LoanD.Reset;
        LoanD.SetRange(LoanD."Batch No.", LoanDisbursement."Batch No.");
        if LoanD.FindFirst then begin
            LoanD.Status := LoanD.Status::Open;
            LoanD.Modify;
        end;
    end;


    procedure ReleaseStandingOrder(var StandingOrder: Record 51449)
    var
        Sto: Record 51449;
    begin
        Sto.Reset;
        Sto.SetRange(Sto."No.", StandingOrder."No.");
        if Sto.FindFirst then begin
            Sto.Status := Sto.Status::Approved;
            Sto.Modify;
        end;
    end;


    procedure ReOpenStandingOrder(var StandingOrder: Record 51449)
    var
        Sto: Record 51449;
    begin
        Sto.Reset;
        Sto.SetRange(Sto."No.", StandingOrder."No.");
        if Sto.FindFirst then begin
            Sto.Status := Sto.Status::Open;
            Sto.Modify;
        end;
    end;


    procedure ReleaseMWithdrawal(var MWithdrawal: Record 51400)
    var
        Withdrawal: Record 51400;
    begin
        Withdrawal.Reset;
        Withdrawal.SetRange(Withdrawal."No.", MWithdrawal."No.");
        if Withdrawal.FindFirst then begin
            Withdrawal.Status := Withdrawal.Status::Approved;
            Withdrawal.Modify;
        end;
    end;


    procedure ReOpenMWithdrawal(var MWithdrawal: Record 51400)
    var
        Withdrawal: Record 51400;
    begin
        Withdrawal.Reset;
        Withdrawal.SetRange(Withdrawal."No.", MWithdrawal."No.");
        if Withdrawal.FindFirst then begin
            Withdrawal.Status := Withdrawal.Status::Open;
            Withdrawal.Modify;
        end;
    end;


    procedure ReleaseATMCard(var ATMCard: Record 51464)
    var
        ATM: Record 51464;
    begin
        ATMCard.Reset;
        ATMCard.SetRange(ATMCard."No.", ATMCard."No.");
        if ATMCard.FindFirst then begin
            // ATMCard.Status := ATMCard.Status::"2";
            ATMCard.Modify;
        end;
    end;


    procedure ReOpenATMCard(var ATMCard: Record 51464)
    var
        ATM: Record 51464;
    begin
        ATMCard.Reset;
        ATMCard.SetRange(ATMCard."No.", ATMCard."No.");
        if ATMCard.FindFirst then begin
            // ATMCard.Status := ATMCard.Status::"0";
            ATMCard.Modify;
        end;
    end;


    procedure ReleaseGuarantorRecovery(var GuarantorRecovery: Record 51550)
    var
        GuarantorR: Record 51550;
    begin
        GuarantorRecovery.Reset;
        GuarantorRecovery.SetRange(GuarantorRecovery."Document No", GuarantorRecovery."Document No");
        if GuarantorRecovery.FindFirst then begin
            GuarantorRecovery.Status := GuarantorRecovery.Status::Approved;
            GuarantorRecovery.Modify;
        end;
    end;


    procedure ReOpenGuarantorRecovery(var GuarantorRecovery: Record 51550)
    var
        GuarantorR: Record 51550;
    begin
        GuarantorRecovery.Reset;
        GuarantorRecovery.SetRange(GuarantorRecovery."Document No", GuarantorRecovery."Document No");
        if GuarantorRecovery.FindFirst then begin
            GuarantorRecovery.Status := GuarantorRecovery.Status::Open;
            GuarantorRecovery.Modify;
        end;
    end;


    procedure ReleaseChangeRequest(var ChangeRequest: Record 51552)
    var
        ChReq: Record 51552;
    begin
        ChangeRequest.Reset;
        ChangeRequest.SetRange(ChangeRequest.No, ChangeRequest.No);
        if ChangeRequest.FindFirst then begin
            ChangeRequest.Status := ChangeRequest.Status::Approved;
            ChangeRequest.Modify;
        end;
    end;


    procedure ReOpenChangeRequest(var ChangeRequest: Record 51552)
    var
        ChReq: Record 51552;
    begin
        ChangeRequest.Reset;
        ChangeRequest.SetRange(ChangeRequest.No, ChangeRequest.No);
        if ChangeRequest.FindFirst then begin
            ChangeRequest.Status := ChangeRequest.Status::Open;
            ChangeRequest.Modify;
        end;
    end;


    procedure ReleaseTTransactions(var TTransactions: Record 51443)
    var
        TTrans: Record 51443;
    begin
        TTransactions.Reset;
        TTransactions.SetRange(TTransactions.No, TTransactions.No);
        if TTransactions.FindFirst then begin
            TTransactions.Status := TTransactions.Status::Approved;
            TTransactions.Modify;
        end;
    end;


    procedure ReOpenTTransactions(var TTransactions: Record 51443)
    var
        TTrans: Record 51443;
    begin
        TTransactions.Reset;
        TTransactions.SetRange(TTransactions.No, TTransactions.No);
        if TTransactions.FindFirst then begin
            TTransactions.Status := TTransactions.Status::Open;
            TTransactions.Modify;
        end;
    end;


    procedure ReleaseFAccount(var FAccount: Record 51430)
    var
        FOSAACC: Record 51430;
    begin
        FAccount.Reset;
        FAccount.SetRange(FAccount."No.", FAccount."No.");
        if FAccount.FindFirst then begin
            FAccount.Status := FAccount.Status::Approved;
            FAccount.Modify;

            if FAccount.Get(FOSAACC."No.") then begin
                FAccount.Status := FAccount.Status::Approved;
                FAccount.Modify;
            end;
        end;
    end;


    procedure ReOpenFAccount(var FAccount: Record 51430)
    var
        FOSAACC: Record 51430;
    begin
        FAccount.Reset;
        FAccount.SetRange(FAccount."No.", FAccount."No.");
        if FAccount.FindFirst then begin
            FAccount.Status := FAccount.Status::Open;
            FAccount.Modify;
        end;
    end;


    procedure ReleaseSReq(var SReq: Record 51102)
    var
        Stores: Record 51102;
    begin
        SReq.Reset;
        SReq.SetRange(SReq."No.", SReq."No.");
        if SReq.FindFirst then begin
            SReq.Status := SReq.Status::Released;
            SReq.Modify;

            if SReq.Get(Stores."No.") then begin
                SReq.Status := SReq.Status::Released;
                SReq.Modify;
            end;
        end;
    end;


    procedure ReOpenSReq(var SReq: Record 51102)
    var
        Stores: Record 51102;
    begin
        SReq.Reset;
        SReq.SetRange(SReq."No.", SReq."No.");
        if SReq.FindFirst then begin
            SReq.Status := SReq.Status::Open;
            SReq.Modify;
        end;
    end;


    procedure ReleaseSaccoTransfer(var SaccoTransfer: Record "Imprest Lines")
    var
        STransfer: Record "Imprest Lines";
    begin
        STransfer.Reset;
        STransfer.SetRange(STransfer.No, SaccoTransfer.No);
        if STransfer.FindFirst then begin
            // STransfer.Status := SaccoTransfer.Status::Approved;
            STransfer.Modify;
        end;
    end;


    procedure ReOpenSaccoTransfer(var SaccoTransfer: Record "Imprest Lines")
    var
        STransfer: Record "Imprest Lines";
    begin
        STransfer.Reset;
        STransfer.SetRange(STransfer.No, SaccoTransfer.No);
        if STransfer.FindFirst then begin
            // STransfer.Status := SaccoTransfer.Status::Open;
            STransfer.Modify;
        end;
    end;


    procedure ReleaseChequeDiscounting(var ChequeDiscounting: Record 51513)
    var
        CDiscounting: Record 51513;
    begin
        CDiscounting.Reset;
        CDiscounting.SetRange(CDiscounting."Transaction No", ChequeDiscounting."Transaction No");
        if CDiscounting.FindFirst then begin
            CDiscounting.Status := ChequeDiscounting.Status::Approved;
            CDiscounting.Modify;
        end;
    end;


    procedure ReOpenChequeDiscounting(var ChequeDiscounting: Record 51513)
    var
        CDiscounting: Record 51513;
    begin
        CDiscounting.Reset;
        CDiscounting.SetRange(CDiscounting."Transaction No", ChequeDiscounting."Transaction No");
        if CDiscounting.FindFirst then begin
            CDiscounting.Status := ChequeDiscounting.Status::Open;
            CDiscounting.Modify;
        end;
    end;


    procedure ReleaseImprestRequisition(var ImprestRequisition: Record 51006)
    var
        ImprestReq: Record 51006;
    begin
        ImprestReq.Reset;
        ImprestReq.SetRange(ImprestReq."No.", ImprestRequisition."No.");
        if ImprestReq.FindFirst then begin
            ImprestReq.Status := ImprestRequisition.Status::Approved;
            ImprestReq.Modify;
        end;
    end;


    procedure ReOpenImprestRequisition(var ImprestRequisition: Record 51006)
    var
        ImprestReq: Record 51006;
    begin
        ImprestReq.Reset;
        ImprestReq.SetRange(ImprestReq."No.", ImprestRequisition."No.");
        if ImprestReq.FindFirst then begin
            ImprestReq.Status := ImprestRequisition.Status::Open;
            ImprestReq.Modify;
        end;
    end;


    procedure ReleaseImprestSurrender(var ImprestSurrender: Record 51008)
    var
        ImprestSurr: Record 51008;
    begin
        ImprestSurr.Reset;
        ImprestSurr.SetRange(ImprestSurr.No, ImprestSurrender.No);
        if ImprestSurr.FindFirst then begin
            ImprestSurr.Status := ImprestSurrender.Status::Approved;
            ImprestSurr.Modify;
        end;
    end;


    procedure ReOpenImprestSurrender(var ImprestSurrender: Record 51008)
    var
        ImprestSurr: Record 51008;
    begin
        ImprestSurr.Reset;
        ImprestSurr.SetRange(ImprestSurr.No, ImprestSurrender.No);
        if ImprestSurr.FindFirst then begin
            ImprestSurr.Status := ImprestSurrender.Status::Open;
            ImprestSurr.Modify;
        end;
    end;


    procedure ReleaseLeaveApplication(var LeaveApplication: Record 51183)
    var
        LeaveApp: Record 51183;
    begin
        LeaveApp.Reset;
        LeaveApp.SetRange(LeaveApp."Application Code", LeaveApplication."Application Code");
        if LeaveApp.FindFirst then begin
            LeaveApp.Status := LeaveApplication.Status::Approved;
            LeaveApp.Modify;
        end;
    end;


    procedure ReOpenLeaveApplication(LeaveApplication: Record 51183)
    var
        LeaveApp: Record 51183;
    begin
        LeaveApp.Reset;
        LeaveApp.SetRange(LeaveApp."Application Code", LeaveApplication."Application Code");
        if LeaveApp.FindFirst then begin
            LeaveApp.Status := LeaveApplication.Status::New;
            LeaveApp.Modify;
        end;
    end;


    procedure ReleaseBulkWithdrawal(var BulkWithdrawal: Record 51902)
    var
        BulkWith: Record 51902;
    begin
        BulkWithdrawal.Reset;
        BulkWithdrawal.SetRange(BulkWithdrawal."Transaction No", BulkWithdrawal."Transaction No");
        if BulkWithdrawal.FindFirst then begin
            BulkWithdrawal.Status := BulkWithdrawal.Status::Approved;
            BulkWithdrawal.Modify;
        end;
    end;


    procedure ReOpenBulkWithdrawal(var BulkWithdrawal: Record 51902)
    var
        BulkWith: Record 51902;
    begin
        BulkWithdrawal.Reset;
        BulkWithdrawal.SetRange(BulkWithdrawal."Transaction No", BulkWithdrawal."Transaction No");
        if BulkWithdrawal.FindFirst then begin
            BulkWithdrawal.Status := BulkWithdrawal.Status::Open;
            BulkWithdrawal.Modify;
        end;
    end;


    procedure ReleasePackageLodge(var PackageLodge: Record 51904)
    var
        PLodge: Record 51904;
    begin
        PackageLodge.Reset;
        PackageLodge.SetRange(PackageLodge."Package ID", PackageLodge."Package ID");
        if PackageLodge.FindFirst then begin
            PackageLodge.Status := PackageLodge.Status::Approved;
            PackageLodge.Modify;
        end;
    end;


    procedure ReOpenPackageLodge(var PackageLodge: Record 51904)
    var
        PLodge: Record 51904;
    begin
        PackageLodge.Reset;
        PackageLodge.SetRange(PackageLodge."Package ID", PackageLodge."Package ID");
        if PackageLodge.FindFirst then begin
            PackageLodge.Status := PackageLodge.Status::Open;
            PackageLodge.Modify;
        end;
    end;


    procedure ReleasePackageRetrieval(var PackageRetrieval: Record 51907)
    var
        PRetrieval: Record 51907;
    begin
        PackageRetrieval.Reset;
        PackageRetrieval.SetRange(PackageRetrieval."Request No", PackageRetrieval."Request No");
        if PackageRetrieval.FindFirst then begin
            PackageRetrieval.Status := PackageRetrieval.Status::Approved;
            PackageRetrieval.Modify;
        end;
    end;


    procedure ReOpenPackageRetrieval(var PackageRetrieval: Record 51907)
    var
        PRetrieval: Record 51907;
    begin
        PackageRetrieval.Reset;
        PackageRetrieval.SetRange(PackageRetrieval."Request No", PackageRetrieval."Request No");
        if PackageRetrieval.FindFirst then begin
            PackageRetrieval.Status := PackageRetrieval.Status::Open;
            PackageRetrieval.Modify;
        end;
    end;


    procedure ReleaseHouseChange(var HouseChange: Record 51927)
    var
        HChange: Record 51927;
    begin
        HouseChange.Reset;
        HouseChange.SetRange(HouseChange."Document No", HouseChange."Document No");
        if HouseChange.FindFirst then begin
            HouseChange.Status := HouseChange.Status::Approved;
            HouseChange.Modify;
        end;
    end;


    procedure ReOpenHouseChange(var HouseChange: Record 51927)
    var
        HChange: Record 51927;
    begin
        HouseChange.Reset;
        HouseChange.SetRange(HouseChange."Document No", HouseChange."Document No");
        if HouseChange.FindFirst then begin
            HouseChange.Status := HouseChange.Status::Open;
            HouseChange.Modify;
        end;
    end;


    procedure ReleaseCRMTraining(var CRMTraining: Record 51929)
    var
        CTraining: Record 51929;
    begin
        CRMTraining.Reset;
        CRMTraining.SetRange(CRMTraining.Code, CRMTraining.Code);
        if CRMTraining.FindFirst then begin
            CRMTraining.Status := CRMTraining.Status::Approved;
            CRMTraining.Modify;
        end;
    end;


    procedure ReOpenCRMTraining(var CRMTraining: Record 51929)
    var
        CTraining: Record 51929;
    begin
        CRMTraining.Reset;
        CRMTraining.SetRange(CRMTraining.Code, CRMTraining.Code);
        if CRMTraining.FindFirst then begin
            CRMTraining.Status := CRMTraining.Status::Open;
            CRMTraining.Modify;
        end;
    end;


    procedure ReleasePettyCash(var PettyCash: Record 51000)
    var
        PettyC: Record 51000;
    begin
        PettyCash.Reset;
        PettyCash.SetRange(PettyCash."No.", PettyCash."No.");
        if PettyCash.FindFirst then begin
            PettyCash.Status := PettyCash.Status::Approved;
            PettyCash.Modify;
        end;
    end;


    procedure ReOpenPettyCash(var PettyCash: Record 51000)
    var
        PettyC: Record 51000;
    begin
        PettyCash.Reset;
        PettyCash.SetRange(PettyCash."No.", PettyCash."No.");
        if PettyCash.FindFirst then begin
            PettyCash.Status := PettyCash.Status::New;
            PettyCash.Modify;
        end;
    end;


    procedure ReleaseStaffClaims(var StaffClaims: Record 51010)
    var
        SClaims: Record 51010;
    begin
        StaffClaims.Reset;
        StaffClaims.SetRange(StaffClaims."No.", StaffClaims."No.");
        if StaffClaims.FindFirst then begin
            StaffClaims.Status := StaffClaims.Status::Approved;
            StaffClaims.Modify;
        end;
    end;


    procedure ReOpenStaffClaims(var StaffClaims: Record 51010)
    var
        SClaims: Record 51010;
    begin
        StaffClaims.Reset;
        StaffClaims.SetRange(StaffClaims."No.", StaffClaims."No.");
        if StaffClaims.FindFirst then begin
            StaffClaims.Status := StaffClaims.Status::"1st Approval";
            StaffClaims.Modify;
        end;
    end;


    procedure ReleaseMemberAgentNOKChange(var MemberAgentNOKChange: Record 51940)
    var
        MAgentNOKChange: Record 51940;
    begin
        MemberAgentNOKChange.Reset;
        MemberAgentNOKChange.SetRange(MemberAgentNOKChange."Document No", MemberAgentNOKChange."Document No");
        if MemberAgentNOKChange.FindFirst then begin
            MemberAgentNOKChange.Status := MemberAgentNOKChange.Status::Approved;
            MemberAgentNOKChange.Modify;
        end;
    end;


    procedure ReOpenMemberAgentNOKChange(var MemberAgentNOKChange: Record 51940)
    var
        MAgentNOKChange: Record 51940;
    begin
        MemberAgentNOKChange.Reset;
        MemberAgentNOKChange.SetRange(MemberAgentNOKChange."Document No", MemberAgentNOKChange."Document No");
        if MemberAgentNOKChange.FindFirst then begin
            MemberAgentNOKChange.Status := MemberAgentNOKChange.Status::Open;
            MemberAgentNOKChange.Modify;
        end;
    end;


    procedure ReleaseHouseRegistration(var HouseRegistration: Record 51942)
    var
        HRegistration: Record 51942;
    begin
        HouseRegistration.Reset;
        HouseRegistration.SetRange(HouseRegistration."Cell Group Code", HouseRegistration."Cell Group Code");
        if HouseRegistration.FindFirst then begin
            HouseRegistration.Status := HouseRegistration.Status::Approved;
            HouseRegistration.Modify;
        end;
    end;


    procedure ReOpenHouseRegistration(var HouseRegistration: Record 51942)
    var
        HRegistration: Record 51942;
    begin
        HouseRegistration.Reset;
        HouseRegistration.SetRange(HouseRegistration."Cell Group Code", HouseRegistration."Cell Group Code");
        if HouseRegistration.FindFirst then begin
            HouseRegistration.Status := HouseRegistration.Status::Open;
            HouseRegistration.Modify;
        end;
    end;


    procedure ReleaseLoanPayOff(var LoanPayOff: Record 51526)
    var
        LPayOff: Record 51526;
    begin
        LoanPayOff.Reset;
        LoanPayOff.SetRange(LoanPayOff."Document No", LoanPayOff."Document No");
        if LoanPayOff.FindFirst then begin
            LoanPayOff.Status := LoanPayOff.Status::Approved;
            LoanPayOff.Modify;
        end;
    end;


    procedure ReOpenLoanPayOff(var LoanPayOff: Record 51526)
    var
        LPayOff: Record 51526;
    begin
        LoanPayOff.Reset;
        LoanPayOff.SetRange(LoanPayOff."Document No", LoanPayOff."Document No");
        if LoanPayOff.FindFirst then begin
            LoanPayOff.Status := LoanPayOff.Status::Open;
            LoanPayOff.Modify;
        end;
    end;


    procedure ReleaseFixedDeposit(var FixedDeposit: Record 51945)
    var
        FDeposit: Record 51945;
    begin
        FixedDeposit.Reset;
        FixedDeposit.SetRange(FixedDeposit."Document No", FixedDeposit."Document No");
        if FixedDeposit.FindFirst then begin
            FixedDeposit.Status := FixedDeposit.Status::Approved;
            FixedDeposit.Modify;
        end;
    end;


    procedure ReOpenFixedDeposit(var FixedDeposit: Record 51945)
    var
        FDeposit: Record 51945;
    begin
        FixedDeposit.Reset;
        FixedDeposit.SetRange(FixedDeposit."Document No", FixedDeposit."Document No");
        if FixedDeposit.FindFirst then begin
            FixedDeposit.Status := FixedDeposit.Status::Open;
            FixedDeposit.Modify;
        end;
    end;


    procedure ReleasePR(var PRequest: Record "Purchase Header")
    begin
        PRequest.Reset;
        PRequest.SetRange(PRequest."No.", PRequest."No.");
        if PRequest.FindFirst then begin
            PRequest.Status := PRequest.Status::Released;
            PRequest.Modify;

        end;
    end;


    procedure ReleaseTrunch(var Trunch: Record 51495)
    var
        ObjTrunch: Record 51495;
    begin
        ObjTrunch.Reset;
        ObjTrunch.SetRange(ObjTrunch."Document No", Trunch."Document No");
        if ObjTrunch.FindFirst then begin
            ObjTrunch.Status := ObjTrunch.Status::Approved;
            ObjTrunch.Modify;
        end;
    end;


    procedure ReOpenTrunch(var Trunch: Record 51495)
    var
        ObjTrunch: Record 51495;
    begin
        ObjTrunch.Reset;
        ObjTrunch.SetRange(ObjTrunch."Document No", Trunch."Document No");
        if ObjTrunch.FindFirst then begin
            ObjTrunch.Status := ObjTrunch.Status::Open;
            ObjTrunch.Modify;
        end;
    end;
}

