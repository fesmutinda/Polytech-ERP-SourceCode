#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Codeunit 51516005 "Custom Workflow Responses"
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
    end;


    procedure AddResponsePredecessors()
    begin

        //Payment Header
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPaymentDocForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPaymentDocForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPaymentDocForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPaymentApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPaymentApprovalRequestCode);

        //Membership Application
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMembershipApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMembershipApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMembershipApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMembershipApplicationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMembershipApplicationApprovalRequestCode);
        //Loan Application
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanApplicationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanApplicationApprovalRequestCode);

        //Loan Disbursement
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanDisbursementForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanDisbursementForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanDisbursementForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanDisbursementApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanDisbursementApprovalRequestCode);



        //Standing Order
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStandingOrderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStandingOrderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStandingOrderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelStandingOrderApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelStandingOrderApprovalRequestCode);

        //Membership Withdrawal
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMWithdrawalApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMWithdrawalApprovalRequestCode);

        //ATM Card Application
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendATMCardForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendATMCardForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendATMCardForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelATMCardApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelATMCardApprovalRequestCode);

        //Guarantor Recovery
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendGuarantorRecoveryForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendGuarantorRecoveryForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendGuarantorRecoveryForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelGuarantorRecoveryApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelGuarantorRecoveryApprovalRequestCode);

        //Change Request
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChangeRequestForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChangeRequestForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChangeRequestForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelChangeRequestApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelChangeRequestApprovalRequestCode);

        //Treasury Transactions
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendTTransactionsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendTTransactionsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendTTransactionsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelTTransactionsApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelTTransactionsApprovalRequestCode);


        //FOSA Account Application
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFAccountApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFAccountApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFAccountApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelFAccountApplicationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelFAccountApplicationApprovalRequestCode);



        //Stores Requisition

        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSReqApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSReqApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSReqApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelSReqApplicationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelSReqApplicationApprovalRequestCode);

        //Sacco Transfer
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSaccoTransferForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSaccoTransferForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendSaccoTransferForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelSaccoTransferApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelSaccoTransferApprovalRequestCode);
        //Cheque Discounting
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChequeDiscountingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChequeDiscountingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendChequeDiscountingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelChequeDiscountingApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelChequeDiscountingApprovalRequestCode);

        //Imprest Requisition
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestRequisitionForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestRequisitionForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestRequisitionForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelImprestRequisitionApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelImprestRequisitionApprovalRequestCode);

        //Imprest Surrender
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestSurrenderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestSurrenderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendImprestSurrenderForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelImprestSurrenderApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelImprestSurrenderApprovalRequestCode);

        //Leave Application
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLeaveApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLeaveApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLeaveApplicationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLeaveApplicationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLeaveApplicationApprovalRequestCode);
        //Bulk Withdrawal
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendBulkWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendBulkWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendBulkWithdrawalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelBulkWithdrawalApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelBulkWithdrawalApprovalRequestCode);

        //Package Lodge
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageLodgeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageLodgeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageLodgeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPackageLodgeApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPackageLodgeApprovalRequestCode);

        //Package Retrieval
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageRetrievalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageRetrievalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPackageRetrievalForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPackageRetrievalApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPackageRetrievalApprovalRequestCode);

        //House Change
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelHouseChangeApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelHouseChangeApprovalRequestCode);

        //CRM Training
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendCRMTrainingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendCRMTrainingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendCRMTrainingForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelCRMTrainingApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelCRMTrainingApprovalRequestCode);

        //Petty Cash
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPettyCashForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPettyCashForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendPettyCashForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPettyCashApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelPettyCashApprovalRequestCode);

        //Staff Claims
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStaffClaimsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStaffClaimsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendStaffClaimsForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelStaffClaimsApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelStaffClaimsApprovalRequestCode);

        //Member Agent/NOK Change
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMemberAgentNOKChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMemberAgentNOKChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendMemberAgentNOKChangeForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMemberAgentNOKChangeApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelMemberAgentNOKChangeApprovalRequestCode);

        //House Registration
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseRegistrationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseRegistrationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendHouseRegistrationForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelHouseRegistrationApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelHouseRegistrationApprovalRequestCode);

        //Loan Payoff
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanPayOffForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanPayOffForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendLoanPayOffForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanPayOffApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelLoanPayOffApprovalRequestCode);

        //Fixed Deposit
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SetStatusToPendingApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFixedDepositForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CreateApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFixedDepositForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.SendApprovalRequestForApprovalCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnSendFixedDepositForApprovalCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.OpenDocumentCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelFixedDepositApprovalRequestCode);
        WFResponseHandler.AddResponsePredecessor(WFResponseHandler.CancelAllApprovalRequestsCode,
                                                 SwizzsoftWFEvents.RunWorkflowOnCancelFixedDepositApprovalRequestCode);

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


    procedure ReleaseMembershipApplication(var MembershipApplication: Record 51516360)
    var
        MembershipApp: Record 51516360;
    begin

        MembershipApp.Reset;
        MembershipApp.SetRange(MembershipApp."No.", MembershipApplication."No.");
        if MembershipApp.FindFirst then begin
            MembershipApp.Status := MembershipApp.Status::Approved;
            MembershipApp.Modify;
        end;
    end;


    procedure ReOpenMembershipApplication(var MemberApplication: Record 51516360)
    var
        MembershipApp: Record 51516360;
    begin
        MembershipApp.Reset;
        MembershipApp.SetRange(MembershipApp."No.", MemberApplication."No.");
        if MembershipApp.FindFirst then begin
            MembershipApp.Status := MembershipApp.Status::Open;
            MembershipApp.Modify;
        end;
    end;


    procedure ReleaseLoanApplication(var LoanApplication: Record 51516371)
    var
        LoanB: Record 51516371;
    begin
        LoanB.Reset;
        LoanB.SetRange(LoanB."Loan  No.", LoanApplication."Loan  No.");
        if LoanB.FindFirst then begin
            LoanB."Loan Status" := LoanB."loan status"::Approved;
            LoanB."Approval Status" := LoanB."approval status"::Approved;
            LoanB.Modify;
        end;
    end;


    procedure ReOpenLoanApplication(var LoanApplication: Record 51516371)
    var
        LoanB: Record 51516371;
    begin
        LoanB.Reset;
        LoanB.SetRange(LoanB."Loan  No.", LoanApplication."Loan  No.");
        if LoanB.FindFirst then begin
            LoanB."Loan Status" := LoanB."loan status"::Application;
            LoanB."Approval Status" := LoanB."approval status"::Open;
            LoanB.Modify;
        end;
    end;


    procedure ReleaseLoanDisbursement(var LoanDisbursement: Record 51516377)
    var
        LoanD: Record 51516377;
    begin
        LoanD.Reset;
        LoanD.SetRange(LoanD."Batch No.", LoanDisbursement."Batch No.");
        if LoanD.FindFirst then begin
            LoanD.Status := LoanD.Status::Approved;
            LoanD.Modify;
        end;
    end;


    procedure ReOpenLoanDisbursement(var LoanDisbursement: Record 51516377)
    var
        LoanD: Record 51516377;
    begin
        LoanD.Reset;
        LoanD.SetRange(LoanD."Batch No.", LoanDisbursement."Batch No.");
        if LoanD.FindFirst then begin
            LoanD.Status := LoanD.Status::Open;
            LoanD.Modify;
        end;
    end;


    procedure ReleaseStandingOrder(var StandingOrder: Record 51516449)
    var
        Sto: Record 51516449;
    begin
        Sto.Reset;
        Sto.SetRange(Sto."No.", StandingOrder."No.");
        if Sto.FindFirst then begin
            Sto.Status := Sto.Status::Approved;
            Sto.Modify;
        end;
    end;


    procedure ReOpenStandingOrder(var StandingOrder: Record 51516449)
    var
        Sto: Record 51516449;
    begin
        Sto.Reset;
        Sto.SetRange(Sto."No.", StandingOrder."No.");
        if Sto.FindFirst then begin
            Sto.Status := Sto.Status::Open;
            Sto.Modify;
        end;
    end;


    procedure ReleaseMWithdrawal(var MWithdrawal: Record 51516400)
    var
        Withdrawal: Record 51516400;
    begin
        Withdrawal.Reset;
        Withdrawal.SetRange(Withdrawal."No.", MWithdrawal."No.");
        if Withdrawal.FindFirst then begin
            Withdrawal.Status := Withdrawal.Status::Approved;
            Withdrawal.Modify;
        end;
    end;


    procedure ReOpenMWithdrawal(var MWithdrawal: Record 51516400)
    var
        Withdrawal: Record 51516400;
    begin
        Withdrawal.Reset;
        Withdrawal.SetRange(Withdrawal."No.", MWithdrawal."No.");
        if Withdrawal.FindFirst then begin
            Withdrawal.Status := Withdrawal.Status::Open;
            Withdrawal.Modify;
        end;
    end;


    procedure ReleaseATMCard(var ATMCard: Record 51516464)
    var
        ATM: Record 51516464;
    begin
        ATMCard.Reset;
        ATMCard.SetRange(ATMCard."No.", ATMCard."No.");
        if ATMCard.FindFirst then begin
            ATMCard.Status := ATMCard.Status::"2";
            ATMCard.Modify;
        end;
    end;


    procedure ReOpenATMCard(var ATMCard: Record 51516464)
    var
        ATM: Record 51516464;
    begin
        ATMCard.Reset;
        ATMCard.SetRange(ATMCard."No.", ATMCard."No.");
        if ATMCard.FindFirst then begin
            ATMCard.Status := ATMCard.Status::"0";
            ATMCard.Modify;
        end;
    end;


    procedure ReleaseGuarantorRecovery(var GuarantorRecovery: Record 51516550)
    var
        GuarantorR: Record 51516550;
    begin
        GuarantorRecovery.Reset;
        GuarantorRecovery.SetRange(GuarantorRecovery."Document No", GuarantorRecovery."Document No");
        if GuarantorRecovery.FindFirst then begin
            GuarantorRecovery.Status := GuarantorRecovery.Status::Approved;
            GuarantorRecovery.Modify;
        end;
    end;


    procedure ReOpenGuarantorRecovery(var GuarantorRecovery: Record 51516550)
    var
        GuarantorR: Record 51516550;
    begin
        GuarantorRecovery.Reset;
        GuarantorRecovery.SetRange(GuarantorRecovery."Document No", GuarantorRecovery."Document No");
        if GuarantorRecovery.FindFirst then begin
            GuarantorRecovery.Status := GuarantorRecovery.Status::Open;
            GuarantorRecovery.Modify;
        end;
    end;


    procedure ReleaseChangeRequest(var ChangeRequest: Record 51516552)
    var
        ChReq: Record 51516552;
    begin
        ChangeRequest.Reset;
        ChangeRequest.SetRange(ChangeRequest.No, ChangeRequest.No);
        if ChangeRequest.FindFirst then begin
            ChangeRequest.Status := ChangeRequest.Status::Approved;
            ChangeRequest.Modify;
        end;
    end;


    procedure ReOpenChangeRequest(var ChangeRequest: Record 51516552)
    var
        ChReq: Record 51516552;
    begin
        ChangeRequest.Reset;
        ChangeRequest.SetRange(ChangeRequest.No, ChangeRequest.No);
        if ChangeRequest.FindFirst then begin
            ChangeRequest.Status := ChangeRequest.Status::Open;
            ChangeRequest.Modify;
        end;
    end;


    procedure ReleaseTTransactions(var TTransactions: Record 51516443)
    var
        TTrans: Record 51516443;
    begin
        TTransactions.Reset;
        TTransactions.SetRange(TTransactions.No, TTransactions.No);
        if TTransactions.FindFirst then begin
            TTransactions.Status := TTransactions.Status::Approved;
            TTransactions.Modify;
        end;
    end;


    procedure ReOpenTTransactions(var TTransactions: Record 51516443)
    var
        TTrans: Record 51516443;
    begin
        TTransactions.Reset;
        TTransactions.SetRange(TTransactions.No, TTransactions.No);
        if TTransactions.FindFirst then begin
            TTransactions.Status := TTransactions.Status::Open;
            TTransactions.Modify;
        end;
    end;


    procedure ReleaseFAccount(var FAccount: Record 51516430)
    var
        FOSAACC: Record 51516430;
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


    procedure ReOpenFAccount(var FAccount: Record 51516430)
    var
        FOSAACC: Record 51516430;
    begin
        FAccount.Reset;
        FAccount.SetRange(FAccount."No.", FAccount."No.");
        if FAccount.FindFirst then begin
            FAccount.Status := FAccount.Status::Open;
            FAccount.Modify;
        end;
    end;


    procedure ReleaseSReq(var SReq: Record 51516102)
    var
        Stores: Record 51516102;
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


    procedure ReOpenSReq(var SReq: Record 51516102)
    var
        Stores: Record 51516102;
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
            STransfer.Status := SaccoTransfer.Status::Approved;
            STransfer.Modify;
        end;
    end;


    procedure ReOpenSaccoTransfer(var SaccoTransfer: Record "Imprest Lines")
    var
        STransfer: Record "Imprest Line";
    begin
        STransfer.Reset;
        STransfer.SetRange(STransfer.No, SaccoTransfer.No);
        if STransfer.FindFirst then begin
            STransfer.Status := SaccoTransfer.Status::Open;
            STransfer.Modify;
        end;
    end;


    procedure ReleaseChequeDiscounting(var ChequeDiscounting: Record 51516513)
    var
        CDiscounting: Record 51516513;
    begin
        CDiscounting.Reset;
        CDiscounting.SetRange(CDiscounting."Transaction No", ChequeDiscounting."Transaction No");
        if CDiscounting.FindFirst then begin
            CDiscounting.Status := ChequeDiscounting.Status::Approved;
            CDiscounting.Modify;
        end;
    end;


    procedure ReOpenChequeDiscounting(var ChequeDiscounting: Record 51516513)
    var
        CDiscounting: Record 51516513;
    begin
        CDiscounting.Reset;
        CDiscounting.SetRange(CDiscounting."Transaction No", ChequeDiscounting."Transaction No");
        if CDiscounting.FindFirst then begin
            CDiscounting.Status := ChequeDiscounting.Status::Open;
            CDiscounting.Modify;
        end;
    end;


    procedure ReleaseImprestRequisition(var ImprestRequisition: Record 51516006)
    var
        ImprestReq: Record 51516006;
    begin
        ImprestReq.Reset;
        ImprestReq.SetRange(ImprestReq."No.", ImprestRequisition."No.");
        if ImprestReq.FindFirst then begin
            ImprestReq.Status := ImprestRequisition.Status::Approved;
            ImprestReq.Modify;
        end;
    end;


    procedure ReOpenImprestRequisition(var ImprestRequisition: Record 51516006)
    var
        ImprestReq: Record 51516006;
    begin
        ImprestReq.Reset;
        ImprestReq.SetRange(ImprestReq."No.", ImprestRequisition."No.");
        if ImprestReq.FindFirst then begin
            ImprestReq.Status := ImprestRequisition.Status::Open;
            ImprestReq.Modify;
        end;
    end;


    procedure ReleaseImprestSurrender(var ImprestSurrender: Record 51516008)
    var
        ImprestSurr: Record 51516008;
    begin
        ImprestSurr.Reset;
        ImprestSurr.SetRange(ImprestSurr.No, ImprestSurrender.No);
        if ImprestSurr.FindFirst then begin
            ImprestSurr.Status := ImprestSurrender.Status::Approved;
            ImprestSurr.Modify;
        end;
    end;


    procedure ReOpenImprestSurrender(var ImprestSurrender: Record 51516008)
    var
        ImprestSurr: Record 51516008;
    begin
        ImprestSurr.Reset;
        ImprestSurr.SetRange(ImprestSurr.No, ImprestSurrender.No);
        if ImprestSurr.FindFirst then begin
            ImprestSurr.Status := ImprestSurrender.Status::Open;
            ImprestSurr.Modify;
        end;
    end;


    procedure ReleaseLeaveApplication(var LeaveApplication: Record 51516183)
    var
        LeaveApp: Record 51516183;
    begin
        LeaveApp.Reset;
        LeaveApp.SetRange(LeaveApp."Application Code", LeaveApplication."Application Code");
        if LeaveApp.FindFirst then begin
            LeaveApp.Status := LeaveApplication.Status::Approved;
            LeaveApp.Modify;
        end;
    end;


    procedure ReOpenLeaveApplication(LeaveApplication: Record 51516183)
    var
        LeaveApp: Record 51516183;
    begin
        LeaveApp.Reset;
        LeaveApp.SetRange(LeaveApp."Application Code", LeaveApplication."Application Code");
        if LeaveApp.FindFirst then begin
            LeaveApp.Status := LeaveApplication.Status::New;
            LeaveApp.Modify;
        end;
    end;


    procedure ReleaseBulkWithdrawal(var BulkWithdrawal: Record 51516902)
    var
        BulkWith: Record 51516902;
    begin
        BulkWithdrawal.Reset;
        BulkWithdrawal.SetRange(BulkWithdrawal."Transaction No", BulkWithdrawal."Transaction No");
        if BulkWithdrawal.FindFirst then begin
            BulkWithdrawal.Status := BulkWithdrawal.Status::Approved;
            BulkWithdrawal.Modify;
        end;
    end;


    procedure ReOpenBulkWithdrawal(var BulkWithdrawal: Record 51516902)
    var
        BulkWith: Record 51516902;
    begin
        BulkWithdrawal.Reset;
        BulkWithdrawal.SetRange(BulkWithdrawal."Transaction No", BulkWithdrawal."Transaction No");
        if BulkWithdrawal.FindFirst then begin
            BulkWithdrawal.Status := BulkWithdrawal.Status::Open;
            BulkWithdrawal.Modify;
        end;
    end;


    procedure ReleasePackageLodge(var PackageLodge: Record 51516904)
    var
        PLodge: Record 51516904;
    begin
        PackageLodge.Reset;
        PackageLodge.SetRange(PackageLodge."Package ID", PackageLodge."Package ID");
        if PackageLodge.FindFirst then begin
            PackageLodge.Status := PackageLodge.Status::Approved;
            PackageLodge.Modify;
        end;
    end;


    procedure ReOpenPackageLodge(var PackageLodge: Record 51516904)
    var
        PLodge: Record 51516904;
    begin
        PackageLodge.Reset;
        PackageLodge.SetRange(PackageLodge."Package ID", PackageLodge."Package ID");
        if PackageLodge.FindFirst then begin
            PackageLodge.Status := PackageLodge.Status::Open;
            PackageLodge.Modify;
        end;
    end;


    procedure ReleasePackageRetrieval(var PackageRetrieval: Record 51516907)
    var
        PRetrieval: Record 51516907;
    begin
        PackageRetrieval.Reset;
        PackageRetrieval.SetRange(PackageRetrieval."Request No", PackageRetrieval."Request No");
        if PackageRetrieval.FindFirst then begin
            PackageRetrieval.Status := PackageRetrieval.Status::Approved;
            PackageRetrieval.Modify;
        end;
    end;


    procedure ReOpenPackageRetrieval(var PackageRetrieval: Record 51516907)
    var
        PRetrieval: Record 51516907;
    begin
        PackageRetrieval.Reset;
        PackageRetrieval.SetRange(PackageRetrieval."Request No", PackageRetrieval."Request No");
        if PackageRetrieval.FindFirst then begin
            PackageRetrieval.Status := PackageRetrieval.Status::Open;
            PackageRetrieval.Modify;
        end;
    end;


    procedure ReleaseHouseChange(var HouseChange: Record 51516927)
    var
        HChange: Record 51516927;
    begin
        HouseChange.Reset;
        HouseChange.SetRange(HouseChange."Document No", HouseChange."Document No");
        if HouseChange.FindFirst then begin
            HouseChange.Status := HouseChange.Status::Approved;
            HouseChange.Modify;
        end;
    end;


    procedure ReOpenHouseChange(var HouseChange: Record 51516927)
    var
        HChange: Record 51516927;
    begin
        HouseChange.Reset;
        HouseChange.SetRange(HouseChange."Document No", HouseChange."Document No");
        if HouseChange.FindFirst then begin
            HouseChange.Status := HouseChange.Status::Open;
            HouseChange.Modify;
        end;
    end;


    procedure ReleaseCRMTraining(var CRMTraining: Record 51516929)
    var
        CTraining: Record 51516929;
    begin
        CRMTraining.Reset;
        CRMTraining.SetRange(CRMTraining.Code, CRMTraining.Code);
        if CRMTraining.FindFirst then begin
            CRMTraining.Status := CRMTraining.Status::Approved;
            CRMTraining.Modify;
        end;
    end;


    procedure ReOpenCRMTraining(var CRMTraining: Record 51516929)
    var
        CTraining: Record 51516929;
    begin
        CRMTraining.Reset;
        CRMTraining.SetRange(CRMTraining.Code, CRMTraining.Code);
        if CRMTraining.FindFirst then begin
            CRMTraining.Status := CRMTraining.Status::Open;
            CRMTraining.Modify;
        end;
    end;


    procedure ReleasePettyCash(var PettyCash: Record 51516000)
    var
        PettyC: Record 51516000;
    begin
        PettyCash.Reset;
        PettyCash.SetRange(PettyCash."No.", PettyCash."No.");
        if PettyCash.FindFirst then begin
            PettyCash.Status := PettyCash.Status::Approved;
            PettyCash.Modify;
        end;
    end;


    procedure ReOpenPettyCash(var PettyCash: Record 51516000)
    var
        PettyC: Record 51516000;
    begin
        PettyCash.Reset;
        PettyCash.SetRange(PettyCash."No.", PettyCash."No.");
        if PettyCash.FindFirst then begin
            PettyCash.Status := PettyCash.Status::New;
            PettyCash.Modify;
        end;
    end;


    procedure ReleaseStaffClaims(var StaffClaims: Record 51516010)
    var
        SClaims: Record 51516010;
    begin
        StaffClaims.Reset;
        StaffClaims.SetRange(StaffClaims."No.", StaffClaims."No.");
        if StaffClaims.FindFirst then begin
            StaffClaims.Status := StaffClaims.Status::Approved;
            StaffClaims.Modify;
        end;
    end;


    procedure ReOpenStaffClaims(var StaffClaims: Record 51516010)
    var
        SClaims: Record 51516010;
    begin
        StaffClaims.Reset;
        StaffClaims.SetRange(StaffClaims."No.", StaffClaims."No.");
        if StaffClaims.FindFirst then begin
            StaffClaims.Status := StaffClaims.Status::"1st Approval";
            StaffClaims.Modify;
        end;
    end;


    procedure ReleaseMemberAgentNOKChange(var MemberAgentNOKChange: Record 51516940)
    var
        MAgentNOKChange: Record 51516940;
    begin
        MemberAgentNOKChange.Reset;
        MemberAgentNOKChange.SetRange(MemberAgentNOKChange."Document No", MemberAgentNOKChange."Document No");
        if MemberAgentNOKChange.FindFirst then begin
            MemberAgentNOKChange.Status := MemberAgentNOKChange.Status::Approved;
            MemberAgentNOKChange.Modify;
        end;
    end;


    procedure ReOpenMemberAgentNOKChange(var MemberAgentNOKChange: Record 51516940)
    var
        MAgentNOKChange: Record 51516940;
    begin
        MemberAgentNOKChange.Reset;
        MemberAgentNOKChange.SetRange(MemberAgentNOKChange."Document No", MemberAgentNOKChange."Document No");
        if MemberAgentNOKChange.FindFirst then begin
            MemberAgentNOKChange.Status := MemberAgentNOKChange.Status::Open;
            MemberAgentNOKChange.Modify;
        end;
    end;


    procedure ReleaseHouseRegistration(var HouseRegistration: Record 51516942)
    var
        HRegistration: Record 51516942;
    begin
        HouseRegistration.Reset;
        HouseRegistration.SetRange(HouseRegistration."Cell Group Code", HouseRegistration."Cell Group Code");
        if HouseRegistration.FindFirst then begin
            HouseRegistration.Status := HouseRegistration.Status::Approved;
            HouseRegistration.Modify;
        end;
    end;


    procedure ReOpenHouseRegistration(var HouseRegistration: Record 51516942)
    var
        HRegistration: Record 51516942;
    begin
        HouseRegistration.Reset;
        HouseRegistration.SetRange(HouseRegistration."Cell Group Code", HouseRegistration."Cell Group Code");
        if HouseRegistration.FindFirst then begin
            HouseRegistration.Status := HouseRegistration.Status::Open;
            HouseRegistration.Modify;
        end;
    end;


    procedure ReleaseLoanPayOff(var LoanPayOff: Record 51516526)
    var
        LPayOff: Record 51516526;
    begin
        LoanPayOff.Reset;
        LoanPayOff.SetRange(LoanPayOff."Document No", LoanPayOff."Document No");
        if LoanPayOff.FindFirst then begin
            LoanPayOff.Status := LoanPayOff.Status::Approved;
            LoanPayOff.Modify;
        end;
    end;


    procedure ReOpenLoanPayOff(var LoanPayOff: Record 51516526)
    var
        LPayOff: Record 51516526;
    begin
        LoanPayOff.Reset;
        LoanPayOff.SetRange(LoanPayOff."Document No", LoanPayOff."Document No");
        if LoanPayOff.FindFirst then begin
            LoanPayOff.Status := LoanPayOff.Status::Open;
            LoanPayOff.Modify;
        end;
    end;


    procedure ReleaseFixedDeposit(var FixedDeposit: Record 51516945)
    var
        FDeposit: Record 51516945;
    begin
        FixedDeposit.Reset;
        FixedDeposit.SetRange(FixedDeposit."Document No", FixedDeposit."Document No");
        if FixedDeposit.FindFirst then begin
            FixedDeposit.Status := FixedDeposit.Status::Approved;
            FixedDeposit.Modify;
        end;
    end;


    procedure ReOpenFixedDeposit(var FixedDeposit: Record 51516945)
    var
        FDeposit: Record 51516945;
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


    procedure ReleaseTrunch(var Trunch: Record 51516495)
    var
        ObjTrunch: Record 51516495;
    begin
        ObjTrunch.Reset;
        ObjTrunch.SetRange(ObjTrunch."Document No", Trunch."Document No");
        if ObjTrunch.FindFirst then begin
            ObjTrunch.Status := ObjTrunch.Status::Approved;
            ObjTrunch.Modify;
        end;
    end;


    procedure ReOpenTrunch(var Trunch: Record 51516495)
    var
        ObjTrunch: Record 51516495;
    begin
        ObjTrunch.Reset;
        ObjTrunch.SetRange(ObjTrunch."Document No", Trunch."Document No");
        if ObjTrunch.FindFirst then begin
            ObjTrunch.Status := ObjTrunch.Status::Open;
            ObjTrunch.Modify;
        end;
    end;
}

