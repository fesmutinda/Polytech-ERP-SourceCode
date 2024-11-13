#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51516004 "Custom Workflow Events"
{

    trigger OnRun()
    begin
        AddEventsToLib();
    end;

    var
        WFHandler: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WFEventHandler: Codeunit "Workflow Event Handling";
        SurestepWFEvents: Codeunit "Custom Workflow Events";
        WFResponseHandler: Codeunit "Workflow Response Handling";

    procedure AddEventsToLib()
    begin

        //---------------------------------------------1. Approval Events--------------------------------------------------------------
        //Membership Application
        WFHandler.AddEventToLibrary(RunWorkflowOnSendMembershipApplicationForApprovalCode,
                            Database::"Membership Applications", 'Approval of Membership Application is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelMembershipApplicationApprovalRequestCode,
                                    Database::"Membership Applications", 'An Approval request for  Membership Application is canceled.', 0, false);
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //Loans Application
        WFHandler.AddEventToLibrary(RunWorkflowOnSendLoanApplicationForApprovalCode,
                            Database::"Loans Register", 'Approval of Loan Application is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelLoanApplicationApprovalRequestCode,
                                    Database::"Loans Register", 'An Approval request for  Loan Application is canceled.', 0, false);

        //-----Member exit
        WFHandler.AddEventToLibrary(RunWorkflowOnSendMembershipExitApplicationForApprovalCode,
        Database::"Membership Withdrawals", 'Approval of Membership Exit is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelMembershipExitApplicationApprovalRequestCode,
                                    Database::"Membership Withdrawals", 'An Approval request for Exit Application is canceled.', 0, false);
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //BOSA Transfers
        WFHandler.AddEventToLibrary(RunWorkflowOnSendBOSATransForApprovalCode,
                            Database::"BOSA Transfers", 'Approval of Bosa Transfer is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelBOSATransApprovalRequestCode,
                                    Database::"BOSA Transfers", 'An Approval request for  Bosa Transfer is canceled.', 0, false);
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //Loan Batch Disbursements
        WFHandler.AddEventToLibrary(RunWorkflowOnSendLoanBatchForApprovalCode,
                            Database::"Loan Disburesment-Batching", 'Approval of a Loan Batch document is requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelLoanBatchApprovalRequestCode,
                                    Database::"Loan Disburesment-Batching", 'An Approval request for a Loan Batch document is canceled.', 0, false);
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //Change Request
        WFHandler.AddEventToLibrary(RunWorkflowOnSendMemberChangeRequestForApprovalCode,
                            Database::"Change Request", 'Approval of Change Request is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelMemberChangeRequestApprovalRequestCode,
                                    Database::"Change Request", 'An Approval request for  Change Request is canceled.', 0, false);

        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //Leave Application
        WFHandler.AddEventToLibrary(RunWorkflowOnSendLeaveApplicationForApprovalCode,
                            Database::"HR Leave Application", 'Approval of Leave Application is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelLeaveApplicationApprovalRequestCode,
                                    Database::"HR Leave Application", 'An Approval request for  Leave Application is canceled.', 0, false);
        //Guarantor Substitution
        WFHandler.AddEventToLibrary(RunWorkflowOnSendGuarantorSubForApprovalCode,
                            Database::"Guarantorship Substitution H", 'Approval of Guarantor Substitution is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelGuarantorSubApprovalRequestCode,
                                    Database::"Guarantorship Substitution H", 'An Approval request for Guarantor Substitution is canceled.', 0, false);
        //Petty Cash Reimbursement
        WFHandler.AddEventToLibrary(RunWorkflowOnSendPettyCashReimbersementForApprovalCode,
                            Database::"Funds Transfer Header", 'Approval of PettyCash Reimbursment is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelPettyCashReimbersementApprovalRequestCode,
                                    Database::"Funds Transfer Header", 'An Approval request for  PettyCash Reimbursement is canceled.', 0, false);
        //-------------------------------------------------------------------------
        //NewFOSAAccount Application
        // WFHandler.AddEventToLibrary(RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode,
        //                     Database::"Product Applications Details", 'Approval of New FOSA Product Application is Requested.', 0, false);
        // WFHandler.AddEventToLibrary(RunWorkflowOnCancelNewFOSAAccountApplicationApprovalRequestCode,
        //                             Database::"Product Applications Details", 'An Approval request for  New FOSA Product Application is canceled.', 0, false);
        //Teller Transactions
        WFHandler.AddEventToLibrary(RunWorkflowOnSendTellerTransactionsForApprovalCode,
                            Database::Transactions, 'Approval of Teller Transactions is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelTellerTransactionsApprovalRequestCode,
                                    Database::Transactions, 'An Approval request for  Teller Transactions is canceled.', 0, false);

        //STO Transactions
        WFHandler.AddEventToLibrary(RunWorkflowOnSendSTOTransactionsForApprovalCode,
                            Database::"Standing Orders", 'Approval of Standing Orders is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelSTOTransactionsApprovalRequestCode,
                                    Database::"Standing Orders", 'An Approval request for  Standing Orders is canceled.', 0, false);
        // //ATM Card Applications
        // WFHandler.AddEventToLibrary(RunWorkflowOnSendATMTransactionsForApprovalCode,
        //                     Database::"ATM Card Applications", 'Approval of ATM Card Application is Requested.', 0, false);
        // WFHandler.AddEventToLibrary(RunWorkflowOnCancelATMTransactionsApprovalRequestCode,
        //                             Database::"ATM Card Applications", 'An Approval request for  ATM Card Application is canceled.', 0, false);

        //InternalTransfersTransactions
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //"Sacco Transfers"
        WFHandler.AddEventToLibrary(RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode,
                            Database::"Sacco Transfers", 'Approval of Sacco Transfers is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelInternalTransfersTransactionsApprovalRequestCode,
                                    Database::"Sacco Transfers", 'An Approval request for  Sacco Transfers is canceled.', 0, false);
        //-------------------------------------------End Approval Events-------------------------------------------------------------
        //Payment Voucher
        WFHandler.AddEventToLibrary(RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode,
                            Database::"Payment Header", 'Approval of Payment Voucher Transaction is Requested.', 0, false);
        WFHandler.AddEventToLibrary(RunWorkflowOnCancelPaymentVoucherTransactionsApprovalRequestCode,
                                    Database::"Payment Header", 'An Approval request for  Payment Voucher Transaction is canceled.', 0, false);


        //-------------------------------------------End Approval Events-------------------------------------------------------------
    end;


    procedure AddEventsPredecessor()
    begin
        //--------1.Approval,Rejection,Delegation Predecessors----------------------
        //1. Membership Application

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMembershipApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMembershipApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendMembershipApplicationForApprovalCode);

        //2. Loan Application
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendLoanApplicationForApprovalCode);

        //3. BOSA Transfers
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendBOSATransForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendBOSATransForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendBOSATransForApprovalCode);

        //4. Loan Batch Disbursement
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanBatchForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanBatchForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendLoanBatchForApprovalCode);

        //5. Loan TopUp
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanTopUpForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanTopUpForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendLoanTopUpForApprovalCode);
        //6. Change Request
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendMemberChangeRequestForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendMemberChangeRequestForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendMemberChangeRequestForApprovalCode);

        //7. Leave Application

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLeaveApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLeaveApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendLeaveApplicationForApprovalCode);

        //8.Guarantor Substitution

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendGuarantorSubForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendGuarantorSubForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendGuarantorSubForApprovalCode);
        //8. Payment Voucher
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPaymentVoucherForApprovalCode);
        //9. PettyCash Reimbursement
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPettyCashReimbersementForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPettyCashReimbersementForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPettyCashReimbersementForApprovalCode);
        //10. FOSA Product Application

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendFOSAProductApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendFOSAProductApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendFOSAProductApplicationForApprovalCode);
        //11. Loan Recovery Application

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendLoanRecoveryApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendLoanRecoveryApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendLoanRecoveryApplicationForApprovalCode);
        //12. Change Request
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendCEEPChangeRequestForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendCEEPChangeRequestForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendCEEPChangeRequestForApprovalCode);
        //13.Partial Loan Application
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPartialLoanApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPartialLoanApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPartialLoanApplicationForApprovalCode);
        //14. Share Transfers

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendShareTransApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendShareTransApplicationForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendShareTransApplicationForApprovalCode);

        //--------------------------------------------
        //1. NewFOSAAccount Application

        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode);

        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode);

        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode);

        //1. Teller Transactions
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendTellerTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendTellerTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendTellerTransactionsForApprovalCode);

        //1. Standing order Transactions
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendSTOTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendSTOTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendSTOTransactionsForApprovalCode);
        //1.ATM Carc Application
        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendATMTransactionsForApprovalCode);

        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendATMTransactionsForApprovalCode);

        // WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendATMTransactionsForApprovalCode);
        //1. Sacco Transfers
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode);

        //1.Payment Voucher
        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode);

        WFHandler.AddEventPredecessor(WFHandler.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode);

        //---------------------------------------End Approval,Rejection,Delegation Predecessors---------------------------------------------
    end;
    //...............................................................................................................................................................................
    //A)Membership Applications
    procedure RunWorkflowOnSendMembershipApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendMembershipApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelMembershipApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMembershipApplicationApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendMembershipApplicationForApproval', '', false, false)]

    procedure RunWorkflowOnSendMembershipApplicationForApproval(var MembershipApplication: Record "Membership Applications")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendMembershipApplicationForApprovalCode, MembershipApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelMembershipApplicationApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelMembershipApplicationApprovalRequest(var MembershipApplication: Record "Membership Applications")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelMembershipApplicationApprovalRequestCode, MembershipApplication);
    end;
    //2. Membership Exit

    //1)Membership Exit Application
    procedure RunWorkflowOnSendMembershipExitApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendMembershipExitApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelMembershipExitApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMembershipExitApplicationApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendMembershipExitApplicationForApproval', '', false, false)]

    procedure RunWorkflowOnSendMembershipExitApplicationForApproval(var MembershipWithdrawals: Record "Membership Withdrawals")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendMembershipApplicationForApprovalCode, "Membership Withdrawals");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelMembershipExitApplicationApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelMembershipExitApplicationApprovalRequest(var MembershipWithdrawals: Record "Membership Withdrawals")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelMembershipExitApplicationApprovalRequestCode, "Membership Withdrawals");
    end;
    //2. Loan Applications
    procedure RunWorkflowOnSendLoanApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendLoanApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelLoanApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanApplicationApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendLoanApplicationForApproval', '', false, false)]

    procedure RunWorkflowOnSendLoanApplicationForApproval(var LoansRegister: Record "Loans Register")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLoanApplicationForApprovalCode, LoansRegister);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelLoanApplicationApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelLoanApplicationApprovalRequest(var LoansRegister: Record "Loans Register")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLoanApplicationApprovalRequestCode, LoansRegister);
    end;
    //...................................................................................................

    //3. BOSA Transfers
    procedure RunWorkflowOnSendBOSATransForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendBOSATransForApproval'));
    end;


    procedure RunWorkflowOnCancelBOSATransApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelBOSATransApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendBOSATransForApproval', '', false, false)]

    procedure RunWorkflowOnSendBOSATransForApproval(var BOSATransfers: Record "BOSA Transfers")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendBOSATransForApprovalCode, BOSATransfers);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelBOSATransApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelBOSATransApprovalRequest(var BOSATransfers: Record "BOSA Transfers")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelBOSATransApprovalRequestCode, BOSATransfers);
    end;
    //...................................................................................................
    //4. Loan Batches
    procedure RunWorkflowOnSendLoanBatchForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendLoanBatchForApproval'));
    end;


    procedure RunWorkflowOnCancelLoanBatchApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanBatchApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendLoanBatchForApproval', '', false, false)]

    procedure RunWorkflowOnSendLoanBatchForApproval(var LoanDisburesmentBatching: Record "Loan Disburesment-Batching")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLoanBatchForApprovalCode, LoanDisburesmentBatching);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelLoanBatchApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelLoanBatchApprovalRequest(var LoanDisburesmentBatching: Record "Loan Disburesment-Batching")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLoanBatchApprovalRequestCode, LoanDisburesmentBatching);
    end;
    //...................................................................................................
    //5. Loan TopUp
    procedure RunWorkflowOnSendLoanTopUpForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendLoanTopUpForApproval'));
    end;


    procedure RunWorkflowOnCancelLoanTopUpApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanTopUpApprovalRequest'));
    end;


    //...................................................................................................
    //6. Change Request
    procedure RunWorkflowOnSendMemberChangeRequestForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendMemberChangeRequestForApproval'));
    end;


    procedure RunWorkflowOnCancelMemberChangeRequestApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelMemberChangeRequestApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendMemberChangeRequestForApproval', '', false, false)]

    procedure RunWorkflowOnSendMemberChangeRequestForApproval(var ChangeRequest: Record "Change Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendMemberChangeRequestForApprovalCode, ChangeRequest);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelMemberChangeRequestApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelMemberChangeRequestApprovalRequest(var ChangeRequest: Record "Change Request")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelMemberChangeRequestApprovalRequestCode, ChangeRequest);
    end;
    //A)Leave Applications
    procedure RunWorkflowOnSendLeaveApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendLeaveApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelLeaveApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLeaveApplicationApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendLeaveApplicationForApproval', '', false, false)]

    procedure RunWorkflowOnSendLeaveApplicationForApproval(var LeaveApplication: Record "HR Leave Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendLeaveApplicationForApprovalCode, LeaveApplication);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelLeaveApplicationApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelLeaveApplicationApprovalRequest(var LeaveApplication: Record "HR Leave Application")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelLeaveApplicationApprovalRequestCode, LeaveApplication);
    end;
    //...................................................................................................
    //8)Guarantor Substitution
    procedure RunWorkflowOnSendGuarantorSubForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendGuarantorSubForApproval'));
    end;


    procedure RunWorkflowOnCancelGuarantorSubApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelGuarantorSubApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendGuarantorSubForApproval', '', false, false)]

    procedure RunWorkflowOnSendGuarantorSubForApproval(var GuarantorSubstitution: Record "Guarantorship Substitution H")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendGuarantorSubForApprovalCode, GuarantorSubstitution);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelGuarantorSubApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelGuarantorSubApprovalRequest(var GuarantorSubstitution: Record "Guarantorship Substitution H")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelGuarantorSubApprovalRequestCode, GuarantorSubstitution);
    end;
    //------------------------------------------------------------------------
    //8)Payment Voucher
    procedure RunWorkflowOnSendPaymentVoucherForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendPaymentVoucherForApproval'));
    end;


    procedure RunWorkflowOnCancelPaymentVoucherApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPaymentVoucherApprovalRequest'));
    end;

    //---------------------------------------------------------------------------------
    //9)Payment Voucher
    procedure RunWorkflowOnSendPettyCashReimbersementForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendPettyCashReimbersementForApproval'));
    end;


    procedure RunWorkflowOnCancelPettyCashReimbersementApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPettyCashReimbersementApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendPettyCashReimbersementForApproval', '', false, false)]

    procedure RunWorkflowOnSendPettyCashReimbersementForApproval(var PettyCashReimbersement: Record "Funds Transfer Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPettyCashReimbersementForApprovalCode, PettyCashReimbersement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelPettyCashReimbersementApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelPettyCashReimbersementApprovalRequest(var PettyCashReimbersement: Record "Funds Transfer Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPettyCashReimbersementApprovalRequestCode, PettyCashReimbersement);
    end;
    //10)FOSA Product Applications
    procedure RunWorkflowOnSendFOSAProductApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendFOSAProductApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelFOSAProductApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelFOSAProductApplicationApprovalRequest'));
    end;

    //12)Loan Recovery Applications
    procedure RunWorkflowOnSendLoanRecoveryApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendLoanRecoveryApplicationForApproval'));
    end;

    procedure RunWorkflowOnCancelLoanRecoveryApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelLoanRecoveryApplicationApprovalRequest'));
    end;

    //...................................................................
    //12.CEEP Change Request
    procedure RunWorkflowOnSendCEEPChangeRequestForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendCEEPChangeRequestForApproval'));
    end;


    procedure RunWorkflowOnCancelCEEPChangeRequestApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelCEEPChangeRequestApprovalRequest'));
    end;
    //13 Partial Loan Disbursements
    procedure RunWorkflowOnSendPartialLoanApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendPartialLoanApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelPartialLoanApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPartialLoanApplicationApprovalRequest'));
    end;

    //14)Share Transfer
    procedure RunWorkflowOnSendShareTransApplicationForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendShareTransApplicationForApproval'));
    end;


    procedure RunWorkflowOnCancelShareTransApplicationApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelShareTransApplicationApprovalRequest'));
    end;
    //...........15)New FOSA Product Accounts Applications
    // procedure RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode(): Code[128]//
    // begin
    //     exit(UpperCase('RunWorkflowOnSendNewFOSAAccountApplicationForApproval'));
    // end;


    // procedure RunWorkflowOnCancelNewFOSAAccountApplicationApprovalRequestCode(): Code[128]
    // begin
    //     exit(UpperCase('RunWorkflowOnCancelNewFOSAAccountApplicationApprovalRequest'));
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendNewFOSAAccountApplicationForApproval', '', false, false)]

    // procedure RunWorkflowOnSendNewFOSAAccountApplicationForApproval(var NewFOSAAccountApplication: Record "Product Applications Details")
    // begin
    //     WorkflowManagement.HandleEvent(RunWorkflowOnSendNewFOSAAccountApplicationForApprovalCode, NewFOSAAccountApplication);
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelNewFOSAAccountApplicationApprovalRequest', '', false, false)]

    // procedure RunWorkflowOnCancelNewFOSAAccountApplicationApprovalRequest(var NewFOSAAccountApplication: Record "Product Applications Details")
    // begin
    //     WorkflowManagement.HandleEvent(RunWorkflowOnCancelNewFOSAAccountApplicationApprovalRequestCode, NewFOSAAccountApplication);
    // end;
    //15)Teller Transactions
    procedure RunWorkflowOnSendTellerTransactionsForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendTellerTransactionsForApproval'));
    end;


    procedure RunWorkflowOnCancelTellerTransactionsApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelTellerTransactionsApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendTellerTransactionsForApproval', '', false, false)]

    procedure RunWorkflowOnSendTellerTransactionsForApproval(var TellerTransactions: Record Transactions)
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendTellerTransactionsForApprovalCode, TellerTransactions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelTellerTransactionsApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelTellerTransactionsApprovalRequest(var TellerTransactions: Record Transactions)
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelTellerTransactionsApprovalRequestCode, TellerTransactions);
    end;
    //...................................................................................................
    //15)Standing order Transactions
    procedure RunWorkflowOnSendSTOTransactionsForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendSTOTransactionsForApproval'));
    end;


    procedure RunWorkflowOnCancelSTOTransactionsApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelSTOTransactionsApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendSTOTransactionsForApproval', '', false, false)]

    procedure RunWorkflowOnSendSTOTransactionsForApproval(var STOTransactions: Record "Standing Orders")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendSTOTransactionsForApprovalCode, STOTransactions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelSTOTransactionsApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelSTOTransactionsApprovalRequest(var STOTransactions: Record "Standing Orders")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelSTOTransactionsApprovalRequestCode, STOTransactions);
    end;
    //16)ATM Card Application
    // procedure RunWorkflowOnSendATMTransactionsForApprovalCode(): Code[128]//
    // begin
    //     exit(UpperCase('RunWorkflowOnSendATMTransactionsForApproval'));
    // end;


    // procedure RunWorkflowOnCancelATMTransactionsApprovalRequestCode(): Code[128]
    // begin
    //     exit(UpperCase('RunWorkflowOnCancelATMTransactionsApprovalRequest'));
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendATMTransactionsForApproval', '', false, false)]

    // procedure RunWorkflowOnSendATMTransactionsForApproval(var ATMTransactions: Record "ATM Card Applications")
    // begin
    //     WorkflowManagement.HandleEvent(RunWorkflowOnSendATMTransactionsForApprovalCode, ATMTransactions);
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelATMTransactionsApprovalRequest', '', false, false)]

    // procedure RunWorkflowOnCancelATMTransactionsApprovalRequest(var ATMTransactions: Record "ATM Card Applications")
    // begin
    //     WorkflowManagement.HandleEvent(RunWorkflowOnCancelATMTransactionsApprovalRequestCode, ATMTransactions);
    // end;
    //
    //15)Sacco Transfers
    procedure RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendInternalTransfersTransactionsForApproval'));
    end;


    procedure RunWorkflowOnCancelInternalTransfersTransactionsApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelInternalTransfersTransactionsApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendInternalTransfersTransactionsForApproval', '', false, false)]

    procedure RunWorkflowOnSendInternalTransfersTransactionsForApproval(var InternalTransfersTransactions: Record "Sacco Transfers")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendInternalTransfersTransactionsForApprovalCode, InternalTransfersTransactions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelInternalTransfersTransactionsApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelInternalTransfersTransactionsApprovalRequest(var InternalTransfersTransactions: Record "Sacco Transfers")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelInternalTransfersTransactionsApprovalRequestCode, InternalTransfersTransactions);
    end;

    //16)Payment Voucher
    procedure RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode(): Code[128]//
    begin
        exit(UpperCase('RunWorkflowOnSendPaymentVoucherTransactionsForApproval'));
    end;


    procedure RunWorkflowOnCancelPaymentVoucherTransactionsApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPaymentVoucherTransactionsApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnSendPaymentVoucherTransactionsForApproval', '', false, false)]

    procedure RunWorkflowOnSendPaymentVoucherTransactionsForApproval(var PaymentVoucherTransactions: Record "Payment Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPaymentVoucherTransactionsForApprovalCode, PaymentVoucherTransactions);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::SurestepApprovalsCodeUnit, 'FnOnCancelPaymentVoucherTransactionsApprovalRequest', '', false, false)]

    procedure RunWorkflowOnCancelPaymentVoucherTransactionsApprovalRequest(var PaymentVoucherTransactions: Record "Payment Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPaymentVoucherTransactionsApprovalRequestCode, PaymentVoucherTransactions);
    end;
    //...................................................................................................
}
