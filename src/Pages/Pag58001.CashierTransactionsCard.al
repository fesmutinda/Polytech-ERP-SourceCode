// Page 58001 "Cashier Transactions Card"
// {
//     DeleteAllowed = true;
//     PageType = Card;
//     PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
//     SourceTable = Transactions;
//     SourceTableView = where(Posted = filter(false));

//     layout
//     {
//         area(content)
//         {
//             group(Transactions)
//             {
//                 Caption = 'Transactions';
//                 field(No; Rec.No)
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Member No"; Rec."Member No")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Member Name"; Rec."Member Name")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Savings Product"; Rec."Savings Product")
//                 {
//                     ApplicationArea = Basic;
//                     trigger OnValidate()
//                     begin
//                         FnSendRecordApproval();
//                     end;

//                 }
//                 field("Account No"; Rec."Account No")
//                 {
//                     ApplicationArea = Basic;

//                     trigger OnValidate()
//                     begin
//                         if Rec.Posted = true then
//                             Error('You cannot modify an already posted record.');
//                         FnSendRecordApproval();

//                         // CalcAvailableBal;

//                         Rec.CalcFields("Uncleared Cheques");

//                     end;
//                 }
//                 field("Transaction Type"; Rec."Transaction Type")
//                 {
//                     ApplicationArea = Basic;

//                     // trigger OnValidate()
//                     // begin
//                     //     FnSendRecordApproval();
//                     //     if Rec.Posted = true then
//                     //         Error('You cannot modify an already posted record.');

//                     //     FChequeVisible := false;
//                     //     BChequeVisible := false;
//                     //     BReceiptVisible := false;
//                     //     BOSAReceiptChequeVisible := false;
//                     //     "Branch RefferenceVisible" := false;
//                     //     LRefVisible := false;
//                     //     ChequeTransfVisible := false;
//                     //     ChequeWithdrawalVisible := false;
//                     //     DepositSlipVisible := false;
//                     //     ChequeWithOll := false;
//                     //     if TransactionTypes.Get(Rec."Transaction Type") then begin
//                     //         if TransactionTypes.Type = TransactionTypes.Type::"Cheque Deposit" then begin
//                     //             FChequeVisible := true;
//                     //             if (Rec."Account No" = '502-00-000300-00') or (Rec."Account No" = '502-00-000303-00') then
//                     //                 BOSAReceiptChequeVisible := true;
//                     //         end;
//                     //         if TransactionTypes.Type = TransactionTypes.Type::"Bankers Cheque" then
//                     //             BChequeVisible := true;

//                     //         if (Rec."Transaction Type" = 'BOSA') or (Rec."Transaction Type" = 'FOSALOAN') then
//                     //             BReceiptVisible := true;

//                     //         TellerTill.Reset;
//                     //         TellerTill.SetRange(TellerTill."Account Type", TellerTill."account type"::Cashier);
//                     //         TellerTill.SetRange(TellerTill."Cashier ID", UserId);
//                     //         if TellerTill.Find('-') then begin
//                     //             Rec."Bank Account" := TellerTill."No.";
//                     //         end;

//                     //         if TransactionTypes.Type = TransactionTypes.Type::Transfer then begin
//                     //             ChequeTransfVisible := true;
//                     //         end;

//                     //         if TransactionTypes.Type = TransactionTypes.Type::"Inhouse Cheque Withdrawal" then begin
//                     //             ChequeWithdrawalVisible := true;
//                     //         end;

//                     //         if TransactionTypes.Type = TransactionTypes.Type::"Cheque Withdrawal" then begin
//                     //             ChequeWithOll := true;
//                     //         end;

//                     //         if TransactionTypes.Type = TransactionTypes.Type::"Deposit Slip" then begin
//                     //             DepositSlipVisible := true;
//                     //         end;

//                     //         if TransactionTypes.Type = TransactionTypes.Type::Encashment then
//                     //             BReceiptVisible := true;



//                     //     end;

//                     //     if Rec."Branch Transaction" = true then begin
//                     //         "Branch RefferenceVisible" := true;
//                     //         LRefVisible := true;
//                     //     end;

//                     //     if Acc.Get(Rec."Account No") then begin
//                     //         if Acc."Account Category" = Acc."account category"::Project then begin
//                     //             "Branch RefferenceVisible" := true;
//                     //             LRefVisible := true;
//                     //         end;
//                     //     end;


//                     //     CalcAvailableBal;
//                     // end;

//                 }
//                 field(Amount; Rec.Amount)
//                 {
//                     ApplicationArea = Basic;
//                     // trigger OnValidate()
//                     // begin
//                     //     FnSendRecordApproval();
//                     //     GenSetup.Get();
//                     //     if (Rec.Type = 'Withdrawal') and Rec."Use Graduated Charges" = true then begin
//                     //         GraduatedCharge.Reset;
//                     //         if GraduatedCharge.Find('-') then begin
//                     //             repeat
//                     //                 if (Rec.Amount >= GraduatedCharge."Minimum Amount") and (Rec.Amount <= GraduatedCharge."Maximum Amount") then begin
//                     //                     if GraduatedCharge."Use Percentage" = true then begin
//                     //                         TransCharges := Rec.Amount * (GraduatedCharge."Percentage of Amount" / 100);
//                     //                         ExciseDuty := TransCharges * (GenSetup."Excise Duty(%)" / 100)
//                     //                     end else
//                     //                         TransCharges := GraduatedCharge.Amount;
//                     //                     ExciseDuty := TransCharges * (GenSetup."Excise Duty(%)" / 100);

//                     //                     TransCharges := TransCharges + ExciseDuty;
//                     //                 end;
//                     //             until GraduatedCharge.Next = 0;
//                     //         end;
//                     //     end;
//                     //     Rec."Transaction Charges" := TransCharges;

//                     //     if (Rec.Type = 'Bankers Cheque') or (Rec.Type = 'Cheque Deposit') or (Rec.Type = 'Cheque Withdrawal') then begin
//                     //         TransactionCharges.Reset;
//                     //         TransactionCharges.SetRange(TransactionCharges."Transaction Type", Rec."Transaction Type");
//                     //         if TransactionCharges.Find('-') then begin
//                     //             TransCharges := TransactionCharges."Charge Amount";
//                     //             ExciseDuty := TransCharges * (GenSetup."Excise Duty(%)" / 100);

//                     //             TransCharges := TransCharges + ExciseDuty;
//                     //         end;
//                     //         Rec."Transaction Charges" := TransCharges;
//                     //     end;
//                     // end;

//                 }
//                 field("Transaction Charges"; Rec."Transaction Charges")
//                 {
//                     ApplicationArea = Basic;
//                     Style = Unfavorable;
//                 }
//                 field("Transaction Mode New"; Rec."Transaction Mode New")
//                 {
//                     ApplicationArea = Basic;
//                     Caption = 'Transaction Mode';
//                 }
//                 field(Description; Rec.Description)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 group(DepositSlip)
//                 {
//                     Visible = DepositSlipVisible;
//                     field("Receipt Bank."; Rec."Bank Account")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Receipt Bank';
//                     }
//                     field("Document Date"; Rec."Document Date")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                 }
//                 group(BCheque)
//                 {
//                     Caption = '.';
//                     Visible = BChequeVisible;
//                     field("Bankers Cheque No"; Rec."Bankers Cheque No")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field(Payee; Rec.Payee)
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Post Dated"; Rec."Post Dated")
//                     {
//                         ApplicationArea = Basic;

//                         trigger OnValidate()
//                         begin
//                             "Transaction DateEditable" := false;
//                             if Rec."Post Dated" = true then
//                                 "Transaction DateEditable" := true
//                             else
//                                 Rec."Transaction Date" := Today;
//                         end;
//                     }
//                     field("Cheque Clearing Bank Code"; Rec."Cheque Clearing Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank_ Code';
//                     }
//                     field("Cheque Clearing Bank"; Rec."Cheque Clearing Bank")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing_Bank';
//                         Editable = false;
//                     }
//                 }
//                 group(ChequeWith)
//                 {
//                     Caption = '.';
//                     Visible = ChequeWithOll;
//                     field("Cheque NoChq"; Rec."Bankers Cheque No")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque No';
//                     }
//                     field("CheqWith Payee"; Rec.Payee)
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Payee';
//                     }
//                     field("ChequeWith Post Dated"; Rec."Post Dated")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Post Dated';

//                         trigger OnValidate()
//                         begin
//                             "Transaction DateEditable" := false;
//                             if Rec."Post Dated" = true then
//                                 "Transaction DateEditable" := true
//                             else
//                                 Rec."Transaction Date" := Today;
//                         end;
//                     }
//                     field("Cheque Clearing Bank Code Cheq"; Rec."Cheque Clearing Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank Code';
//                     }
//                     field("Cheque Clearing Bank Cheq"; Rec."Cheque Clearing Bank")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank';
//                         Editable = false;
//                     }
//                 }
//                 group(BReceipt)
//                 {
//                     Caption = '.';
//                     Visible = BReceiptVisible;
//                     field("BOSA Account No"; Rec."BOSA Account No")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Allocated Amount"; Rec."Allocated Amount")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Receipt Bank"; Rec."Bank Account")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("<Document Date.>"; Rec."Document Date")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Document Date';
//                     }
//                 }
//                 group(FCheque)
//                 {
//                     Caption = '.';
//                     Visible = FChequeVisible;
//                     field("Cheque Type"; Rec."Cheque Type")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Cheque No"; Rec."Cheque No")
//                     {
//                         ApplicationArea = Basic;

//                         trigger OnValidate()
//                         begin
//                             if StrLen(Rec."Cheque No") <> 6 then
//                                 Error('Cheque No. cannot contain More or less than 6 Characters.');
//                         end;
//                     }
//                     field("Bank Code"; Rec."Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Source Bank';
//                     }
//                     field("<Cheque Clearing Bank_Code>"; Rec."Cheque Clearing Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank Code>';
//                     }
//                     field("<Cheque_Clearing Bank>"; Rec."Cheque Clearing Bank")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank';
//                         Editable = false;
//                     }
//                     field("Expected Maturity Date"; Rec."Expected Maturity Date")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field(Status; Rec.Status)
//                     {
//                         ApplicationArea = Basic;
//                         Editable = false;
//                     }
//                     field("50048"; Rec."Banking Posted")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Banked';
//                         Editable = false;
//                     }
//                     field("Bank Account"; Rec."Bank Account")
//                     {
//                         ApplicationArea = Basic;
//                         Visible = false;
//                     }
//                     field("Cheque Date"; Rec."Cheque Date")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Cheque Deposit Remarks"; Rec."Cheque Deposit Remarks")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                 }
//                 group(ChequeWithdrawal)
//                 {
//                     Caption = '.';
//                     Visible = ChequeWithdrawalVisible;
//                     field("Cheque TypeWith"; Rec."Cheque Type")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Type';
//                     }
//                     field("Drawer's Account No."; Rec."Drawer's Account No")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Drawer''s Account No.';
//                     }
//                     field("Drawer's NameWith"; Rec."Drawer's Name")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Drawer''s Name';
//                         Editable = false;
//                     }
//                     field("Drawers Cheque No.With"; Rec."Drawers Cheque No.")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Drawers Cheque No.';
//                     }
//                     field("Cheque DateWith"; Rec."Cheque Date")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Date';
//                     }
//                     field("Cheque Deposit RemarksWith"; Rec."Cheque Deposit Remarks")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Deposit Remarks';
//                     }
//                     field("Cheque Clearing Bank Code.With"; Rec."Cheque Clearing Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank Code.';
//                     }
//                 }
//                 group(ChequeTransf)
//                 {
//                     Caption = '.';
//                     Visible = ChequeTransfVisible;
//                     field("Cheque TypeTR"; Rec."Cheque Type")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Type';
//                     }
//                     field("Drawer's Account No"; Rec."Drawer's Account No")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Drawer's Name"; Rec."Drawer's Name")
//                     {
//                         ApplicationArea = Basic;
//                         Editable = false;
//                     }
//                     field("Drawers Cheque No."; Rec."Drawers Cheque No.")
//                     {
//                         ApplicationArea = Basic;
//                     }
//                     field("Cheque DateTR"; Rec."Cheque Date")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Date';
//                     }
//                     field("Cheque Deposit RemarksTR"; Rec."Cheque Deposit Remarks")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Deposit Remarks';
//                     }
//                     field("<Cheque Clearing Bank Code.>"; Rec."Cheque Clearing Bank Code")
//                     {
//                         ApplicationArea = Basic;
//                         Caption = 'Cheque Clearing Bank Code.';
//                     }
//                     group(BOSAReceiptCheque)
//                     {
//                         Caption = '.';
//                         Visible = BOSAReceiptChequeVisible;
//                     }
//                 }
//                 field("Account Name"; Rec."Account Name")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Transaction Description"; Rec."Transaction Description")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = true;
//                 }
//                 field("Book Balance"; Rec."Book Balance")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("ID No"; Rec."ID No")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field(Cashier; Rec.Cashier)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Transaction Date"; Rec."Transaction Date")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Transaction Time"; Rec."Transaction Time")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;

//                 }
//                 field(Posted; Rec.Posted)
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//             }
//         }
//         area(factboxes)
//         {
//             part(Control1000000000; "FOSA Statistics FactBox")
//             {
//                 SubPageLink = "No." = field("Account No");
//             }
//             part(Control1000000018; "Member Statistics FactBox")
//             {
//                 SubPageLink = "No." = field("Member No");
//             }
//         }
//     }

//     // actions
//     // {
//     //     area(navigation)
//     //     {
//     //         group(Transaction)
//     //         {
//     //             Caption = 'Transaction';
//     //             action("Account Card")
//     //             {
//     //                 ApplicationArea = Basic;
//     //                 Caption = 'Go To FOSA Page';
//     //                 Image = Vendor;
//     //                 Promoted = true;
//     //                 RunObject = Page "Product Card";
//     //                 PromotedCategory = Process;
//     //                 RunPageLink = "No." = field("Account No");
//     //             }
//     //             action("Account Signatories")
//     //             {
//     //                 ApplicationArea = Basic;
//     //                 Caption = 'Signatories Details';
//     //                 Promoted = true;
//     //                 PromotedCategory = Process;
//     //                 RunObject = Page "Member Account Signatory list";
//     //                 RunPageLink = "Account No" = field("Member No");
//     //             }
//     //             action(SendApproval)
//     //             {
//     //                 ApplicationArea = Basic;
//     //                 Caption = 'Send Approval Request';
//     //                 Image = Print;
//     //                 Promoted = true;
//     //                 PromotedCategory = Process;
//     //                 PromotedIsBig = true;
//     //                 Enabled = AllowSendApproval;

//     //                 trigger OnAction()
//     //                 var
//     //                     ApprovalWorkFlow: Codeunit SwizzsoftApprovalsCodeUnit;
//     //                 begin
//     //                     rec.TestField(rec.Amount);
//     //                     rec.Status := rec.Status::open;
//     //                     rec.modify;
//     //                     //rec.TestField(rec.Status, rec.Status::Open);
//     //                     if Confirm('Send Approval Request ?', false) = false then begin
//     //                         exit;
//     //                     end else begin
//     //                         ApprovalWorkFlow.SendTellerTransactionsRequestForApproval(rec.No, Rec);
//     //                         CurrPage.Close();
//     //                     end;
//     //                 end;
//     //             }
//     //             action(CancelApproval)
//     //             {
//     //                 ApplicationArea = Basic;
//     //                 Caption = 'Cancel Approval Request';
//     //                 Image = Print;
//     //                 Promoted = true;
//     //                 PromotedCategory = Process;
//     //                 PromotedIsBig = true;
//     //                 Enabled = CancelApproval;
//     //                 trigger OnAction()
//     //                 var
//     //                     ApprovalWorkFlow: Codeunit SwizzsoftApprovalsCodeUnit;
//     //                 begin
//     //                     if Confirm('Cancel Approval Request ?', false) = false then begin
//     //                         exit;
//     //                     end else begin
//     //                         ApprovalWorkFlow.CancelTellerTransactionsRequestForApproval(rec.No, Rec);
//     //                         CurrPage.Close();
//     //                     end;
//     //                 end;
//     //             }
//     //         }
//     //     }
//     //     area(processing)
//     //     {
//     //         action(Post)
//     //         {
//     //             ApplicationArea = Basic;
//     //             Caption = 'Post';
//     //             Image = Post;
//     //             Promoted = true;
//     //             PromotedCategory = Process;
//     //             trigger OnAction()
//     //             begin

//     //                 //Check if Posted
//     //                 If Rec."Transaction Date" <> today then Error('Contact the Administator , Transaction Date is not equal to today');
//     //                 BankLedger.Reset;
//     //                 BankLedger.SetRange(BankLedger."Document No.", Rec.No);
//     //                 if BankLedger.Find('-') then begin
//     //                     Rec.Posted := true;
//     //                     Rec.Modify;
//     //                     Message('Transaction is aready posted');
//     //                     exit;
//     //                 end;
//     //                 //Ensure Min Share Capital Is Contributed
//     //                 BosaSetUp.Get();
//     //                 if Rec.Type = 'BOSA Receipt' then begin
//     //                     if Cust.Get(Rec."Member No") then begin
//     //                         Cust.CalcFields(Cust."Registration Fee Paid", Cust."Shares Retained");
//     //                         if Cust."Shares Retained" < BosaSetUp."Retained Shares" then begin


//     //                             ReceiptAllocations.Reset;
//     //                             ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec.No);
//     //                             ReceiptAllocations.SetRange(ReceiptAllocations."Transaction Type", ReceiptAllocations."transaction type"::"Share Capital");
//     //                             if not ReceiptAllocations.Find('-') then
//     //                                 Message('The Member Must first Contribute Min. Share Capital Amount');

//     //                             ReceiptAllocations.Reset;
//     //                             ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec.No);
//     //                             if ReceiptAllocations.Find('-') then begin
//     //                                 if ReceiptAllocations.Count > 1 then
//     //                                     if ReceiptAllocations.Amount < (BosaSetUp."Retained Shares" - Cust."Shares Retained") then
//     //                                         Message('The Member Must first Contribute Min. Share Capital Amount');
//     //                             end;
//     //                         end;
//     //                     end;
//     //                 end;
//     //                 if Rec.Cashier <> UpperCase(UserId) then
//     //                     Error('Cannot post a Transaction being processed by %1', Rec.Cashier);

//     //                 BankLedger.Reset;
//     //                 BankLedger.SetRange(BankLedger."Posting Date", Rec."Transaction Date");
//     //                 BankLedger.SetRange(BankLedger."User ID", Rec."Posted By");
//     //                 BankLedger.SetRange(BankLedger.Description, 'END OF DAY RETURN TO TREASURY');
//     //                 if BankLedger.Find('-') = true then begin
//     //                     Error('You cannot post any transactions after perfoming end of day');
//     //                 end;

//     //                 UsersID.Reset;
//     //                 UsersID.SetRange(UsersID."User ID", UpperCase(UserId));
//     //                 if UsersID.Find('-') then begin
//     //                     DBranch := UsersID.Branch;
//     //                     DActivity := 'FOSA';
//     //                 end;


//     //                 if Rec.Posted = true then
//     //                     Error('The transaction has already been posted.');

//     //                 VarAmtHolder := 0;

//     //                 if Rec.Amount <= 0 then
//     //                     Error('Please specify an amount greater than zero.');

//     //                 if Rec."Transaction Type" = '' then
//     //                     Error('Please select the transaction type.');

//     //                 Rec."Post Attempted" := true;
//     //                 Rec.Modify;
//     //                 //2030
//     //                 if Rec.Type = 'Cheque Deposit' then begin
//     //                     Rec.TestField("Cheque Type");
//     //                     Rec.TestField("Cheque No");
//     //                     Rec.TestField("Cheque Date");
//     //                     Rec.TestField("Bank Code");

//     //                     exit;
//     //                 end;

//     //                 if Rec.Type = 'Transfer' then begin
//     //                     Rec.TestField("Drawers Cheque No.");
//     //                     Rec.TestField("Drawer's Account No");
//     //                     PostTransfer;
//     //                     exit;
//     //                 end;

//     //                 if Rec.Type = 'Bankers Cheque' then begin
//     //                     PostBankersChequeVer1;
//     //                     exit;
//     //                 end;

//     //                 if (Rec.Type = 'Encashment') or (Rec.Type = 'Inhouse Cheque Withdrawal') then begin
//     //                     PostEncashment;
//     //                     exit;
//     //                 end;
//     //                 if Rec.Type = 'Deposit Slip' then begin
//     //                     PostDepSlipDep;
//     //                 end;
//     //                 if Rec.Type = 'BOSA Receipt' then begin
//     //                     // PostBOSAEntries;
//     //                     exit;
//     //                 end;
//     //                 if Rec.Type = 'Transfer' then begin
//     //                     PostTransfer;
//     //                 end;
//     //                 if (Rec.Type = 'Withdrawal') or (Rec.Type = 'Cash Deposit') then begin
//     //                     PostCashDepWith;
//     //                     exit;
//     //                 end;
//     //                 if Rec.Type = 'Cheque Withdrawal' then begin
//     //                     PostChequeWith;
//     //                     exit;
//     //                 end;
//     //             end;
//     //         }
//     //     }
//     // }
//     // trigger OnAfterGetCurrRecord()
//     // begin
//     //     FnSendRecordApproval();
//     // end;



//     // trigger OnAfterGetRecord()
//     // begin
//     //     FnSendRecordApproval();
//     //     Rec.SetRange(Cashier, UserId);
//     //     FChequeVisible := false;
//     //     BChequeVisible := false;
//     //     BReceiptVisible := false;
//     //     BOSAReceiptChequeVisible := false;
//     //     ChequeTransfVisible := false;
//     //     if (Rec.Type = 'Cheque Deposit') or (Rec.Type = 'Cheque Withdrawal') then begin
//     //         FChequeVisible := true;
//     //         if (Rec."Account No" = '502-00-000300-00') or (Rec."Account No" = '502-00-000303-00') then
//     //             BOSAReceiptChequeVisible := true;

//     //     end;

//     //     "Branch RefferenceVisible" := false;
//     //     LRefVisible := false;


//     //     if Rec.Type = 'Bankers Cheque' then
//     //         BChequeVisible := true;

//     //     if Rec.Type = 'Encashment' then
//     //         BReceiptVisible := true;


//     //     if (Rec."Transaction Type" = 'RECEIPT') or (Rec."Transaction Type" = 'FOSALN') then
//     //         BReceiptVisible := true;

//     //     if Rec."Transaction Type" = 'TRANSFER' then
//     //         ChequeTransfVisible := true;

//     //     if Rec."Branch Transaction" = true then begin
//     //         "Branch RefferenceVisible" := true;
//     //         LRefVisible := true;
//     //     end;

//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc."Account Category" = Acc."account category"::Project then begin
//     //             "Branch RefferenceVisible" := true;
//     //             LRefVisible := true;
//     //         end;
//     //     end;


//     //     "Transaction DateEditable" := false;
//     //     if Rec."Post Dated" = true then
//     //         "Transaction DateEditable" := true;

//     // end;

//     // trigger OnDeleteRecord(): Boolean
//     // begin
//     //     if Rec.Posted = true then
//     //         Error('You cannot delete an already posted record.');
//     // end;

//     // trigger OnInit()
//     // begin
//     //     "Transaction DateEditable" := true;


//     // end;

//     // trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     // begin

//     //     Rec."Needs Approval" := Rec."needs approval"::No;
//     //     FChequeVisible := false;
//     //     Rec."Transaction Date" := Today;

//     //     CashierTrans.Reset;
//     //     CashierTrans.SetRange(CashierTrans.Posted, false);
//     //     CashierTrans.SetRange(CashierTrans.Cashier, UserId);
//     //     if CashierTrans.Count > 0 then begin
//     //         if CashierTrans."Account No" = '' then begin
//     //             if Confirm('There are still some Unused Transaction Nos. Continue?', false) = false then begin
//     //                 Error('There are still some Unused Transaction Nos. Please utilise them first');
//     //             end;
//     //         end;
//     //     end;
//     // end;

//     // trigger OnModifyRecord(): Boolean
//     // begin
//     //     /*IF xRec.Posted = TRUE THEN BEGIN
//     //     IF Posted = TRUE THEN
//     //     ERROR('You cannot modify an already posted record.');
//     //     END;*/

//     // end;

//     // trigger OnOpenPage()
//     // begin
//     //     /*IF UsersID.GET(USERID) THEN BEGIN
//     //     IF UsersID.Branch <> '' THEN
//     //     SETRANGE("Transacting Branch",UsersID.Branch);

//     //     END;*/



//     //     if Rec.Posted = true then
//     //         CurrPage.Editable := false;


//     //     FChequeVisible := false;
//     //     BChequeVisible := false;
//     //     BReceiptVisible := false;
//     //     BOSAReceiptChequeVisible := false;
//     //     ChequeTransfVisible := false;
//     //     ChequeWithdrawalVisible := false;
//     //     DepositSlipVisible := false;


//     //     if (Rec.Type = 'Cheque Deposit') or (Rec.Type = 'Cheque Withdrawal') then begin
//     //         FChequeVisible := true;
//     //         if (Rec."Account No" = '502-00-000300-00') or (Rec."Account No" = '502-00-000303-00') then
//     //             BOSAReceiptChequeVisible := true;

//     //     end;

//     //     "Branch RefferenceVisible" := false;
//     //     LRefVisible := false;


//     //     if Rec.Type = 'Bankers Cheque' then
//     //         BChequeVisible := true;

//     //     if Rec.Type = 'Encashment' then
//     //         BReceiptVisible := true;


//     //     if (Rec."Transaction Type" = 'RECEIPT') or (Rec."Transaction Type" = 'FOSALN') then
//     //         BReceiptVisible := true;

//     //     if Rec."Transaction Type" = 'TRANSFER' then
//     //         ChequeTransfVisible := true;

//     //     if TransactionTypes.Type = TransactionTypes.Type::"Inhouse Cheque Withdrawal" then begin
//     //         ChequeWithdrawalVisible := true;
//     //     end;

//     //     if TransactionTypes.Type = TransactionTypes.Type::"Deposit Slip" then begin
//     //         DepositSlipVisible := true;
//     //     end;

//     //     if Rec."Branch Transaction" = true then begin
//     //         "Branch RefferenceVisible" := true;
//     //         LRefVisible := true;
//     //     end;

//     // end;

//     // var
//     //     LoanBalance: Decimal;
//     //     SMSMessages: Record "SMS Messages";
//     //     AvailableBalance: Decimal;
//     //     UnClearedBalance: Decimal;
//     //     LoanSecurity: Decimal;
//     //     LoanGuaranteed: Decimal;
//     //     GenJournalLine: Record "Gen. Journal Line";
//     //     DefaultBatch: Record "Gen. Journal Batch";
//     //     window: Dialog;
//     //     iEntryNo: Integer;
//     //     Account: Record Vendor;
//     //     TransactionTypes: Record "Transaction Types";
//     //     TransactionCharges: Record "Transaction Charges";
//     //     TCharges: Decimal;
//     //     LineNo: Integer;
//     //     AccountTypes: Record "Account Types-Saving Products";
//     //     GenLedgerSetup: Record "General Ledger Setup";
//     //     MinAccBal: Decimal;
//     //     FeeBelowMinBal: Decimal;
//     //     AccountNo: Code[30];
//     //     NewAccount: Boolean;
//     //     CurrentTellerAmount: Decimal;
//     //     TellerTill: Record "Bank Account";
//     //     IntervalPenalty: Decimal;
//     //     StandingOrders: Record "Standing Orders";
//     //     AccountAmount: Decimal;
//     //     STODeduction: Decimal;
//     //     Charges: Record Charges;
//     //     "Total Deductions": Decimal;
//     //     STODeductedAmount: Decimal;
//     //     NoticeAmount: Decimal;
//     //     AccountNotices: Record "Account Notices";
//     //     Cust: Record Customer;
//     //     AccountHolders: Record Vendor;
//     //     ChargesOnFD: Decimal;
//     //     TotalGuaranted: Decimal;
//     //     VarAmtHolder: Decimal;
//     //     chqtransactions: Record Transactions;
//     //     Trans: Record Transactions;
//     //     TotalUnprocessed: Decimal;
//     //     CustAcc: Record Customer;
//     //     AmtAfterWithdrawal: Decimal;
//     //     TransactionsRec: Record Transactions;
//     //     LoansTotal: Decimal;
//     //     Interest: Decimal;
//     //     InterestRate: Decimal;
//     //     OBal: Decimal;
//     //     Principal: Decimal;
//     //     ATMTrans: Decimal;
//     //     ATMBalance: Decimal;
//     //     TotalBal: Decimal;
//     //     DenominationsRec: Record Denominations;
//     //     TillNo: Code[20];
//     //     FOSASetup: Record "Purchases & Payables Setup";
//     //     Acc: Record Vendor;
//     //     ChequeTypes: Record "Cheque Types";
//     //     ChargeAmount: Decimal;
//     //     TChargeAmount: Decimal;
//     //     DActivity: Code[20];
//     //     DBranch: Code[20];
//     //     UsersID: Record "User Setup";
//     //     ChBank: Code[20];
//     //     DValue: Record "Dimension Value";
//     //     ReceiptAllocations: Record "Receipt Allocation";
//     //     Loans: Record "Loans Register";
//     //     Commision: Decimal;
//     //     Cheque: Boolean;
//     //     LOustanding: Decimal;
//     //     TotalCommision: Decimal;
//     //     TotalOustanding: Decimal;
//     //     BOSABank: Code[20];
//     //     InterestPaid: Decimal;
//     //     PaymentAmount: Decimal;
//     //     RunBal: Decimal;
//     //     Recover: Boolean;
//     //     GenSetup: Record "Sacco General Set-Up";
//     //     MailContent: Text[150];
//     //     supervisor: Record "Supervisors Approval Levels";
//     //     TEXT1: label 'YOU HAVE A TRANSACTION AWAITING APPROVAL';
//     //     AccP: Record Vendor;
//     //     LoansR: Record "Loans Register";
//     //     ClearingCharge: Decimal;
//     //     ClearingRate: Decimal;

//     //     FChequeVisible: Boolean;

//     //     BChequeVisible: Boolean;

//     //     BReceiptVisible: Boolean;

//     //     BOSAReceiptChequeVisible: Boolean;

//     //     "Branch RefferenceVisible": Boolean;

//     //     LRefVisible: Boolean;
//     //     ChequeTransfVisible: Boolean;

//     //     "Transaction DateEditable": Boolean;
//     //     Excise: Decimal;
//     //     Echarge: Decimal;
//     //     BankLedger: Record "Bank Account Ledger Entry";
//     //     Vend: Record Vendor;
//     //     ChequeBook: Record "Cheques Register";
//     //     BosaSetUp: Record "Sacco General Set-Up";
//     //     CashierTrans: Record Transactions;
//     //     ChequeWithdrawalVisible: Boolean;
//     //     DepositSlipVisible: Boolean;
//     //     OverDraftCharge: Decimal;
//     //     OverDraftChargeAcc: Code[20];
//     //     ChequeWithOll: Boolean;
//     //     ChequeRegister: Record "Cheque Book Register";
//     //     LoanType: Record "Loan Products Setup";
//     //     GraduatedCharge: Record "CWithdrawal Graduated Charges";
//     //     ExciseDuty: Decimal;
//     //     ShareCapDefecit: Decimal;
//     //     TransCharges: Decimal;
//     //     Audit: Record "Audit Entries";
//     //     EntryNos: Integer;


//     // procedure CalcAvailableBal()
//     // begin
//     //     ATMBalance := 0;

//     //     TCharges := 0;
//     //     AvailableBalance := 0;
//     //     MinAccBal := 0;
//     //     TotalUnprocessed := 0;
//     //     IntervalPenalty := 0;


//     //     if Account.Get(Rec."Account No") then begin
//     //         Account.CalcFields(Account.Balance, Account."Uncleared Cheques", Account."ATM Transactions");

//     //         AccountTypes.Reset;
//     //         AccountTypes.SetRange(AccountTypes.Code, Rec."Savings Product");
//     //         if AccountTypes.Find('-') then begin
//     //             MinAccBal := AccountTypes."Minimum Balance";
//     //             FeeBelowMinBal := AccountTypes."Fee Below Minimum Balance";


//     //             //Check Withdrawal Interval
//     //             if Account.Status <> Account.Status::New then begin
//     //                 if Rec.Type = 'Withdrawal' then begin
//     //                     AccountTypes.Reset;
//     //                     AccountTypes.SetRange(AccountTypes.Code, Rec."Savings Product");
//     //                     if Account."Last Withdrawal Date" <> 0D then begin
//     //                         if CalcDate(AccountTypes."Withdrawal Interval", Account."Last Withdrawal Date") > Today then
//     //                             IntervalPenalty := AccountTypes."Withdrawal Penalty";
//     //                     end;
//     //                 end;
//     //                 //Check Withdrawal Interval

//     //                 //Fixed Deposit
//     //                 ChargesOnFD := 0;
//     //                 if AccountTypes."Fixed Deposit" = true then begin
//     //                     if Account."Expected Maturity Date" > Today then
//     //                         ChargesOnFD := AccountTypes."Charge Closure Before Maturity";
//     //                 end;
//     //                 //Fixed Deposit

//     //                 /*
//     //                 //Current Charges
//     //                 TransactionCharges.RESET;
//     //                 TransactionCharges.SETRANGE(TransactionCharges."Transaction Type","Transaction Type");
//     //                 IF TransactionCharges.FIND('-') THEN BEGIN
//     //                 REPEAT
//     //                 IF TransactionCharges."Use Percentage"=TRUE THEN BEGIN
//     //                 TransactionCharges.TESTFIELD("Percentage of Amount");
//     //                 TCharges:=TCharges+(TransactionCharges."Percentage of Amount"/100)*Amount;
//     //                 END ELSE BEGIN
//     //                 TCharges:=TCharges+TransactionCharges."Charge Amount";
//     //                 END;
//     //                 UNTIL TransactionCharges.NEXT=0;
//     //                 END;
//     //                 */

//     //                 TotalUnprocessed := Account."Uncleared Cheques";
//     //                 ATMBalance := Account."ATM Transactions";

//     //                 //FD
//     //                 if AccountTypes."Fixed Deposit" = false then begin
//     //                     if Account.Balance < MinAccBal then
//     //                         AvailableBalance := Account.Balance - FeeBelowMinBal - TCharges - MinAccBal - TotalUnprocessed - ATMBalance -
//     //                                           Account."EFT Transactions" + Account."Cheque Discounted" + Rec."Transaction Charges"// IntervalPenalty -
//     //                     else
//     //                         AvailableBalance := Account.Balance - TCharges - MinAccBal - TotalUnprocessed - ATMBalance -
//     //                                           Account."EFT Transactions" + Account."Cheque Discounted" + Rec."Transaction Charges";//IntervalPenalty -
//     //                 end else begin
//     //                     AvailableBalance := Account.Balance - TCharges - ChargesOnFD - Account."ATM Transactions" + Account."Cheque Discounted" + Rec."Transaction Charges";
//     //                 end;
//     //             end;

//     //             /*MESSAGE('FeeBelowMinBal Is %1',FeeBelowMinBal);
//     //             MESSAGE('TCharges Is %1',TCharges);
//     //             MESSAGE('IntervalPenalty Is %1',IntervalPenalty);
//     //             MESSAGE('MinAccBal Is %1',MinAccBal);
//     //             MESSAGE('TotalUnprocessed Is %1',TotalUnprocessed);
//     //             MESSAGE('ATMBalance Is %1',ATMBalance);
//     //             MESSAGE('EFT Transactions Is %1',Account."EFT Transactions");*/


//     //             //FD

//     //         end;
//     //     end;

//     //     if Rec."N.A.H Balance" <> 0 then
//     //         AvailableBalance := Rec."N.A.H Balance";
//     //     Message('Available balance is %1', AvailableBalance);

//     // end;



//     // procedure PostDepSlipDep()
//     // begin
//     //     if Rec.Type = 'Deposit Slip' then
//     //         DValue.Reset;
//     //     DValue.SetRange(DValue."Global Dimension No.", 2);
//     //     //DValue.SETRANGE(DValue.Code,DBranch);`
//     //     //DValue.SETRANGE(DValue.Code,'NAIROBI');
//     //     if DValue.Find('-') then begin
//     //         //DValue.TESTFIELD(DValue."Clearing Bank Account");
//     //     end else
//     //         //ERROR('Branch not set.');
//     //         ChBank := Rec."Bank Account";

//     //     //IF ChequeTypes.GET("Cheque Type") THEN BEGIN
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := Rec."Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";

//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     if Rec."Branch Transaction" = true then
//     //         GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //     else
//     //         GenJournalLine.Description := Rec."Transaction Description" + '-' + Rec.Description;
//     //     //Project Accounts
//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc."Account Category" = Acc."account category"::Project then
//     //             GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //     end;
//     //     //Project Accounts
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := -Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
//     //     GenJournalLine."Account No." := "Bank Account";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := "Account Name";
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := Rec.Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;
//     //     /*
//     //     //Post Charges
//     //     ChargeAmount:=0;

//     //     LineNo:=LineNo+10000;
//     //     ClearingCharge:=0;
//     //     IF ChequeTypes."Use %" = TRUE THEN BEGIN
//     //     ClearingCharge:=((ChequeTypes."% Of Amount"*0.01)*Amount);
//     //     END ELSE
//     //     ClearingCharge:=ChequeTypes."Clearing Charges";
//     //     //MESSAGE('ClearingCharge%1',ClearingCharge);
//     //     GenJournalLine.INIT;
//     //     GenJournalLine."Journal Template Name":='PURCHASES';
//     //     GenJournalLine."Journal Batch Name":='FTRANS';
//     //     GenJournalLine."Document No.":=No;
//     //     GenJournalLine."Line No.":=LineNo;
//     //     GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
//     //     GenJournalLine."Account No.":="Account No";
//     //     GenJournalLine."FOSA Account type":="Account Type";
//     //     GenJournalLine."External Document No.":="ID No";
//     //     GenJournalLine.VALIDATE(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date":="Transaction Date";
//     //     GenJournalLine.Description:='Clearing Charges';
//     //     GenJournalLine.VALIDATE(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount:=ClearingCharge;
//     //     GenJournalLine.VALIDATE(GenJournalLine.Amount);
//     //     GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"G/L Account";
//     //     GenJournalLine."Bal. Account No.":=ChequeTypes."Clearing Charges GL Account";
//     //     GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //     GenJournalLine."Shortcut Dimension 1 Code":=DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code":=DBranch;
//     //     GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
//     //     IF GenJournalLine.Amount<>0 THEN
//     //     GenJournalLine.INSERT;
//     //     //Post Charges



//     //     //Excise Duty
//     //     genSetup.GET(0);

//     //     LineNo:=LineNo+10000;
//     //     GenJournalLine.INIT;
//     //     GenJournalLine."Journal Template Name":='PURCHASES';
//     //     GenJournalLine."Journal Batch Name":='FTRANS';
//     //     GenJournalLine."Document No.":=No;
//     //     GenJournalLine."Line No.":=LineNo;
//     //     GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
//     //     GenJournalLine."Account No.":="Account No";
//     //     GenJournalLine."FOSA Account type":="Account Type";
//     //     GenJournalLine."External Document No.":="ID No";
//     //     GenJournalLine.VALIDATE(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date":="Transaction Date";
//     //     GenJournalLine.Description:='Excise Duty';
//     //     GenJournalLine.VALIDATE(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount:=(ClearingCharge*genSetup."Excise Duty(%)")/100;
//     //     GenJournalLine.VALIDATE(GenJournalLine.Amount);
//     //     GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"G/L Account";
//     //     GenJournalLine."Bal. Account No.":=genSetup."Excise Duty Account";
//     //     GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //     GenJournalLine."Shortcut Dimension 1 Code":=DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code":=DBranch;
//     //     GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
//     //     IF GenJournalLine.Amount<>0 THEN
//     //     GenJournalLine.INSERT;

//     //     */


//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;

//     //     //Post New


//     //     Rec.Posted := true;
//     //     Rec.Authorised := Rec.Authorised::Yes;
//     //     Rec."Supervisor Checked" := true;
//     //     Rec."Needs Approval" := Rec."needs approval"::No;
//     //     Rec."Frequency Needs Approval" := Rec."frequency needs approval"::No;
//     //     Rec."Date Posted" := Today;
//     //     Rec."Time Posted" := Time;
//     //     Rec."Posted By" := UserId;


//     //     Rec.Modify;
//     //     //Audit Entries
//     //     if (UserId <> 'MOBILE') and (UserId <> 'ATM') and (UserId <> 'AGENCY') then begin
//     //         EntryNos := 0;
//     //         if Audit.FindLast then
//     //             EntryNos := 1 + Audit."Entry No";
//     //         Audit.Init;
//     //         Audit."Entry No" := EntryNos;
//     //         Audit."Transaction Type" := "Transaction Type";
//     //         Audit."Loan Number" := '';
//     //         Audit."Document Number" := Rec.No;
//     //         Audit.UsersId := UserId;
//     //         Audit."Account Number" := Rec."Account No";
//     //         Audit.Amount := Rec.Amount;
//     //         Audit.Date := Today;
//     //         Audit.Time := Time;
//     //         Audit.Source := 'CASHIER TRANSACTION';
//     //         Audit.Insert;
//     //         Commit
//     //     end;
//     //     //End Audit Entries


//     //     Message('Deposit Slip deposited successfully.');

//     //     Trans.Reset;
//     //     Trans.SetRange(Trans.No, No);
//     //     if Trans.Find('-') then
//     //         //Report.Run(56500, false, true, Trans);
//     //     Report.Run(56500, true, true, Trans);


//     //     //END;

//     // end;


//     // procedure PostTransfer()
//     // begin
//     //     DValue.Reset;
//     //     DValue.SetRange(DValue."Global Dimension No.", 2);
//     //     //DValue.SETRANGE(DValue.Code,DBranch);`
//     //     //DValue.SETRANGE(DValue.Code,'NAIROBI');
//     //     if DValue.Find('-') then begin
//     //         //DValue.TESTFIELD(DValue."Clearing Bank Account");
//     //     end else
//     //         //ERROR('Branch not set.');
//     //         ChBank := "Bank Account";

//     //     if ChequeTypes.Get("Cheque Type") then begin
//     //         GenJournalLine.Reset;
//     //         GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //         GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //         GenJournalLine.DeleteAll;

//     //         LineNo := LineNo + 10000;

//     //         GenJournalLine.Init;
//     //         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //         GenJournalLine."Document No." := Rec.No;
//     //         GenJournalLine."External Document No." := "Cheque No";
//     //         GenJournalLine."Line No." := LineNo;
//     //         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //         GenJournalLine."Account No." := Rec."Account No";

//     //         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //         GenJournalLine."Posting Date" := Today;
//     //         if Rec."Branch Transaction" = true then
//     //             GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //         else
//     //             GenJournalLine.Description := Rec."Transaction Description" + '-' + Rec.Description;
//     //         //Project Accounts
//     //         if Acc.Get(Rec."Account No") then begin
//     //             if Acc."Account Category" = Acc."account category"::Project then
//     //                 GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //         end;
//     //         //Project Accounts
//     //         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //         GenJournalLine.Amount := -Amount;
//     //         GenJournalLine.Validate(GenJournalLine.Amount);
//     //         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //         if GenJournalLine.Amount <> 0 then
//     //             GenJournalLine.Insert;

//     //         //Debit The drawers Account
//     //         LineNo := LineNo + 10000;
//     //         GenJournalLine.Init;
//     //         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //         GenJournalLine."Document No." := Rec.No;
//     //         GenJournalLine."External Document No." := "Cheque No";
//     //         GenJournalLine."Line No." := LineNo;
//     //         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //         GenJournalLine."Account No." := "Drawer's Account No";
//     //         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //         GenJournalLine."Posting Date" := Today;
//     //         GenJournalLine.Description := "Account Name";
//     //         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //         GenJournalLine.Amount := Rec.Amount;
//     //         GenJournalLine.Validate(GenJournalLine.Amount);
//     //         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //         if GenJournalLine.Amount <> 0 then
//     //             GenJournalLine.Insert;

//     //         //Post Charges
//     //         ChargeAmount := 0;

//     //         LineNo := LineNo + 10000;
//     //         ClearingCharge := 0;
//     //         if ChequeTypes."Use %" = true then begin
//     //             ClearingCharge := ((ChequeTypes."% Of Amount" * 0.01) * Amount);
//     //         end else
//     //             ClearingCharge := ChequeTypes."Clearing Charges";
//     //         //MESSAGE('ClearingCharge%1',ClearingCharge);
//     //         GenJournalLine.Init;
//     //         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //         GenJournalLine."Document No." := Rec.No;
//     //         GenJournalLine."Line No." := LineNo;
//     //         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //         GenJournalLine."Account No." := Rec."Account No";
//     //         GenJournalLine."External Document No." := Rec."ID No";
//     //         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //         GenJournalLine."Posting Date" := Today;
//     //         GenJournalLine.Description := 'Clearing Charges';
//     //         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //         GenJournalLine.Amount := ClearingCharge;
//     //         GenJournalLine.Validate(GenJournalLine.Amount);
//     //         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //         GenJournalLine."Bal. Account No." := ChequeTypes."Clearing Charges GL Account";
//     //         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //         if GenJournalLine.Amount <> 0 then
//     //             GenJournalLine.Insert;
//     //         //Post Charges



//     //         //Excise Duty
//     //         GenSetup.Get(0);

//     //         LineNo := LineNo + 10000;
//     //         GenJournalLine.Init;
//     //         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //         GenJournalLine."Document No." := Rec.No;
//     //         GenJournalLine."Line No." := LineNo;
//     //         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //         GenJournalLine."Account No." := Rec."Account No";
//     //         GenJournalLine."External Document No." := Rec."ID No";
//     //         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //         GenJournalLine."Posting Date" := Today;
//     //         GenJournalLine.Description := 'Excise Duty';
//     //         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //         GenJournalLine.Amount := (ClearingCharge * GenSetup."Excise Duty(%)") / 100;
//     //         GenJournalLine.Validate(GenJournalLine.Amount);
//     //         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //         GenJournalLine."Bal. Account No." := GenSetup."Excise Duty Account";
//     //         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //         if GenJournalLine.Amount <> 0 then
//     //             GenJournalLine.Insert;




//     //         //Post New
//     //         GenJournalLine.Reset;
//     //         GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //         GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //         if GenJournalLine.Find('-') then begin
//     //             Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //         end;

//     //         //Post New


//     //         Posted := true;
//     //         Authorised := Authorised::Yes;
//     //         "Supervisor Checked" := true;
//     //         "Needs Approval" := "needs approval"::No;
//     //         "Frequency Needs Approval" := "frequency needs approval"::No;
//     //         "Date Posted" := Today;
//     //         "Time Posted" := Time;
//     //         "Posted By" := UserId;
//     //         if ChequeTypes."Clearing  Days" = 0 then begin
//     //             Status := Status::Approved;
//     //             //"Cheque Processed":="cheque processed"::"1";
//     //             "Date Cleared" := Today;
//     //         end;

//     //         Modify;

//     //         //Update Cheque Book
//     //         ChequeBook.Reset;
//     //         ChequeBook.SetRange(ChequeBook."Account No.", "Drawers Member No");
//     //         ChequeBook.SetRange(ChequeBook."Cheque No.", "Drawers Cheque No.");
//     //         if ChequeBook.Find('-') then begin
//     //             ChequeBook.Status := ChequeBook.Status::Approved;
//     //             ChequeBook.Modify;
//     //         end;

//     //         //Audit Entries
//     //         if (UserId <> 'MOBILE') and (UserId <> 'ATM') and (UserId <> 'AGENCY') then begin
//     //             EntryNos := 0;
//     //             if Audit.FindLast then
//     //                 EntryNos := 1 + Audit."Entry No";
//     //             Audit.Init;
//     //             Audit."Entry No" := EntryNos;
//     //             Audit."Transaction Type" := "Transaction Type";
//     //             Audit."Loan Number" := '';
//     //             Audit."Document Number" := Rec.No;
//     //             Audit.UsersId := UserId;
//     //             Audit."Account Number" := Rec."Account No";
//     //             Audit.Amount := Rec.Amount;
//     //             Audit.Date := Today;
//     //             Audit.Time := Time;
//     //             Audit.Source := 'CASHIER TRANSACTION';
//     //             Audit.Insert;
//     //             Commit
//     //         end;
//     //         //End Audit Entries




//     //         Message('Transfer Posted successfully.');

//     //         Trans.Reset;
//     //         Trans.SetRange(Trans.No, No);
//     //         if Trans.Find('-') then
//     //             // Report.Run(56524, false, true, Trans);
//     //             Report.Run(56524, true, true, Trans);

//     //     end;
//     // end;


//     // procedure PostBankersCheq()
//     // begin
//     //     //Block Payments
//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc.Blocked = Acc.Blocked::Payment then
//     //             Error('This account has been blocked from receiving payments.');
//     //     end;


//     //     DValue.Reset;
//     //     DValue.SetRange(DValue."Global Dimension No.", 2);
//     //     DValue.SetRange(DValue.Code, 'Nairobi');
//     //     //DValue.SETRANGE(DValue.Code,DBranch);
//     //     if DValue.Find('-') then begin
//     //         // DValue.TestField(DValue."Banker Cheque Account");
//     //         // ChBank:=DValue."Banker Cheque Account";
//     //     end else
//     //         Error('Branch not set.');

//     //     CalcAvailableBal;

//     //     //Check withdrawal limits
//     //     if Rec.Type = 'Bankers Cheque' then begin
//     //         if AvailableBalance < Amount then begin
//     //             if Authorised = Authorised::Yes then begin
//     //                 Overdraft := true;
//     //                 Modify;
//     //             end;

//     //             if Authorised = Authorised::No then begin
//     //                 if Rec."Branch Transaction" = false then begin
//     //                     "Authorisation Requirement" := 'Bankers Cheque - Over draft';
//     //                     Modify;
//     //                     Message('You cannot issue a Bankers cheque more than the available balance unless authorised.');
//     //                     SendEmail;
//     //                     exit;
//     //                 end;
//     //             end;
//     //             if Authorised = Authorised::Rejected then
//     //                 Error('Bankers cheque transaction has been rejected and therefore cannot proceed.');
//     //             //SendEmail;
//     //         end;
//     //     end;
//     //     //Check withdrawal limits


//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");

//     //     GenJournalLine."Posting Date" := Today;
//     //     if Rec."Branch Transaction" = true then
//     //         GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //     else
//     //         GenJournalLine.Description := Description; //"Transaction Description"+'-'+Description ;
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := Rec.Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
//     //     GenJournalLine."Account No." := ChBank;
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := Payee;//"Account Name";
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := -Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;


//     //     //Charges
//     //     TransactionCharges.Reset;
//     //     TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //     if TransactionCharges.Find('-') then begin
//     //         repeat
//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."External Document No." := "Bankers Cheque No";
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := TransactionCharges.Description;
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             GenJournalLine.Amount := TransactionCharges."Charge Amount";
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := TransactionCharges."G/L Account";
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;

//     //             if TransactionCharges."Due Amount" > 0 then begin
//     //                 LineNo := LineNo + 10000;

//     //                 GenJournalLine.Init;
//     //                 GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                 GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                 GenJournalLine."Document No." := Rec.No;
//     //                 GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                 GenJournalLine."Line No." := LineNo;
//     //                 GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
//     //                 GenJournalLine."Account No." := TransactionCharges."G/L Account";
//     //                 GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                 GenJournalLine."Posting Date" := Today;
//     //                 GenJournalLine.Description := TransactionCharges.Description;
//     //                 GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                 GenJournalLine.Amount := TransactionCharges."Due Amount";
//     //                 GenJournalLine.Validate(GenJournalLine.Amount);
//     //                 GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"Bank Account";
//     //                 GenJournalLine."Bal. Account No." := ChBank;
//     //                 GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                 GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                 GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                 if GenJournalLine.Amount <> 0 then
//     //                     GenJournalLine.Insert;


//     //             end;

//     //         until TransactionCharges.Next = 0;
//     //     end;

//     //     //Charges

//     //     //Excise Duty
//     //     GenSetup.Get(0);

//     //     LineNo := LineNo + 10000;
//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     GenJournalLine."External Document No." := Rec."ID No";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := 'Excise Duty';
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := (TransactionCharges."Charge Amount" * GenSetup."Excise Duty(%)") / 100;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //     GenJournalLine."Bal. Account No." := GenSetup."Excise Duty Account";
//     //     GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;



//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;

//     //     //Post New


//     //     "Transaction Available Balance" := AvailableBalance;
//     //     Posted := true;
//     //     Authorised := Authorised::Yes;
//     //     "Supervisor Checked" := true;
//     //     "Needs Approval" := "needs approval"::No;
//     //     "Frequency Needs Approval" := "frequency needs approval"::No;
//     //     "Date Posted" := Today;
//     //     "Time Posted" := Time;
//     //     "Posted By" := UserId;
//     //     Modify;
//     //     /*IF CONFIRM('Are you sure you want to print this bankers cheque?',TRUE)=TRUE THEN BEGIN
//     //     REPORT.RUN(,TRUE,TRUE,Trans)
//     //     END;*/


//     //     Message('Bankers cheque posted successfully.');

//     // end;


//     // procedure PostEncashment()
//     // begin

//     //     //Block Payments
//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc.Blocked = Acc.Blocked::Payment then
//     //             Error('This account has been blocked from receiving payments.');
//     //     end;


//     //     CalcAvailableBal;

//     //     //Check withdrawal limits
//     //     if (Type = 'Encashment') or (Type = 'Inhouse Cheque Withdrawal') then begin
//     //         if AvailableBalance < Amount then begin
//     //             if Authorised = Authorised::Yes then begin
//     //                 Overdraft := true;
//     //                 Modify;
//     //             end;

//     //             if Authorised = Authorised::No then begin
//     //                 "Authorisation Requirement" := 'Encashment - Over draft';
//     //                 Modify;
//     //                 Message('You cannot issue an encashment more than the available balance unless authorised.');
//     //                 MailContent := 'Withdrawal transaction' + 'TR. No.' + ' ' + No + ' ' + 'of Kshs' + ' ' + Format(Amount) + ' ' + 'for'
//     //                 + ' ' + "Account Name" + ' ' + 'needs your authorization';
//     //                 SendEmail;

//     //                 //SendEmail;
//     //                 exit;
//     //             end;
//     //             if Authorised = Authorised::Rejected then begin
//     //                 MailContent := 'Bankers cheque transaction' + ' ' + 'of Kshs' + ' ' + Format(Amount) + ' ' + 'for'
//     //                 + ' ' + "Account Name" + ' ' + 'needs your approval';
//     //                 SendEmail;
//     //                 Error('Transaction has been rejected and therefore cannot proceed.');

//     //             end;
//     //         end;
//     //     end;
//     //     //Check withdrawal limits



//     //     //Check Teller Balances
//     //     //ADDED DActivity:='';
//     //     //ADDED DBranch:='';

//     //     TillNo := '';
//     //     TellerTill.Reset;
//     //     TellerTill.SetRange(TellerTill."Account Type", TellerTill."account type"::Cashier);
//     //     TellerTill.SetRange(TellerTill.CashierID, UserId);
//     //     if TellerTill.Find('-') then begin
//     //         //ADDED DActivity:=TellerTill."Global Dimension 1 Code";
//     //         //ADDED DBranch:=TellerTill."Global Dimension 2 Code";
//     //         TillNo := TellerTill."No.";
//     //         TellerTill.CalcFields(TellerTill.Balance);

//     //         CurrentTellerAmount := TellerTill.Balance;

//     //         if CurrentTellerAmount - Amount <= TellerTill."Min. Balance" then
//     //             Message('You need to add more money from the treasury since your balance has gone below the teller replenishing level.');

//     //         if ("Transaction Type" = 'Withdrawal') or ("Transaction Type" = 'Encashment') or ("Transaction Type" = 'Inhouse Cheque Withdrawal') then begin
//     //             if (CurrentTellerAmount - Amount) < 0 then
//     //                 Error('You do not have enough money to carry out this transaction.');

//     //         end;

//     //         if ("Transaction Type" = 'Withdrawal') or ("Transaction Type" = 'Encashment') or ("Transaction Type" = 'INHOUSE CHEQUE WITHDRAWAL') then begin
//     //             if CurrentTellerAmount - Amount >= TellerTill."Maximum Teller Withholding" then
//     //                 Message('You need to transfer money back to the treasury since your balance has gone above the teller maximum withholding.');

//     //         end else begin
//     //             if CurrentTellerAmount + Amount >= TellerTill."Maximum Teller Withholding" then
//     //                 Message('You need to transfer money back to the treasury since your balance has gone above the teller maximum withholding.');
//     //         end;


//     //     end;

//     //     if TillNo = '' then
//     //         Error('Teller account not set-up.');

//     //     //Check Teller Balances




//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := Rec."ID No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     if ("Account No" = '00-0000003000') or ("Account No" = '00-0200003000') then
//     //         GenJournalLine."External Document No." := Rec."ID No";

//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := Payee;
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := Rec.Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;


//     //     //Charges
//     //     TCharges := 0;
//     //     //ADDED
//     //     TChargeAmount := 0;


//     //     TransactionCharges.Reset;
//     //     TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");

//     //     if TransactionCharges.Find('-') then begin
//     //         repeat
//     //             LineNo := LineNo + 10000;

//     //             ChargeAmount := 0;
//     //             if TransactionCharges."Use Percentage" = true then begin
//     //                 ChargeAmount := (Amount * TransactionCharges."Percentage of Amount") * 0.01
//     //             end else
//     //                 ChargeAmount := TransactionCharges."Charge Amount";


//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."External Document No." := Rec."ID No";
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := Payee;
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             GenJournalLine.Amount := ChargeAmount;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := TransactionCharges."G/L Account";
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;

//     //             TChargeAmount := TChargeAmount + ChargeAmount;

//     //         until TransactionCharges.Next = 0;
//     //     end;

//     //     //Charges


//     //     //Teller Entry
//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := Rec."ID No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
//     //     GenJournalLine."Account No." := TillNo;
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := Payee;
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := -(Amount);
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;


//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;

//     //     //Post New


//     //     "Transaction Available Balance" := AvailableBalance;
//     //     Posted := true;
//     //     Authorised := Authorised::Yes;
//     //     "Supervisor Checked" := true;
//     //     "Needs Approval" := "needs approval"::No;
//     //     "Frequency Needs Approval" := "frequency needs approval"::No;
//     //     "Date Posted" := Today;
//     //     "Time Posted" := Time;
//     //     "Posted By" := UserId;
//     //     Modify;

//     //     //Update Cheque Book
//     //     ChequeBook.Reset;
//     //     ChequeBook.SetRange(ChequeBook."Account No.", "Drawers Member No");
//     //     ChequeBook.SetRange(ChequeBook."Cheque No.", "Drawers Cheque No.");
//     //     if ChequeBook.Find('-') then begin
//     //         ChequeBook.Status := ChequeBook.Status::Approved;
//     //         ChequeBook.Modify;
//     //     end;

//     //     Trans.Reset;
//     //     Trans.SetRange(Trans.No, No);
//     //     if Trans.Find('-') then
//     //         if Rec.Type = 'Inhouse Cheque Withdrawal ' then
//     //             //  Report.Run(56527, false, true, Trans);
//     //             Report.Run(56527, true, true, Trans);

//     // end;


//     // procedure PostCashDepWith()
//     // begin

//     //     CalcAvailableBal;
//     //     if Rec.Type = 'Withdrawal' then begin
//     //         //Block Payments
//     //         if Acc.Get(Rec."Account No") then begin
//     //             if Acc.Blocked = Acc.Blocked::Payment then
//     //                 Error('This account has been blocked from transacting any withdrawals.');
//     //         end;
//     //         if AvailableBalance < Amount then begin
//     //             Error('The requested amount is greater than the account balance');
//     //         end;
//     //     end;

//     //     TillNo := '';
//     //     TellerTill.Reset;
//     //     TellerTill.SetRange(TellerTill."Account Type", TellerTill."account type"::Cashier);
//     //     TellerTill.SetRange(TellerTill.CashierID, UserId);
//     //     if TellerTill.Find('-') then begin
//     //         if (rec.Amount >= TellerTill."Max Withdrawal Limit") and (rec.Type = 'Withdrawal') then begin
//     //             if rec.Status <> rec.Status::Approved then begin
//     //                 Error('Withdrawal Transactions of More than Ksh. %1 Must first be approved', TellerTill."Max Withdrawal Limit");
//     //             end;
//     //         end;

//     //         TillNo := TellerTill."No.";
//     //         TellerTill.CalcFields(TellerTill.Balance);
//     //         CurrentTellerAmount := TellerTill.Balance;
//     //         if CurrentTellerAmount - Amount <= TellerTill."Min. Balance" then
//     //             Message('Your till balance is Ksh %1 and is falling below your minimum allowed teller balance of Ksh %2. Kindly seek to replenish.', CurrentTellerAmount, tellertill."Min. Balance");
//     //         if ("Transaction Type" = 'Withdrawal') or ("Transaction Type" = 'Encashment') then begin
//     //             if (CurrentTellerAmount - Amount) < 0 then
//     //                 Error('You do not have enough money to carry out this transaction.');
//     //             exit;
//     //         end;
//     //         if (TransactionTypes.Type = TransactionTypes.Type::Withdrawal) or (TransactionTypes.Type = TransactionTypes.Type::Encashment) then begin
//     //             if CurrentTellerAmount - Amount >= TellerTill."Maximum Teller Withholding" then
//     //                 Message('Your till balance is Ksh %1 and is falling above your maximum allowed teller balance of Ksh %2. Kindly return extra amount to treasury.', CurrentTellerAmount - Amount, TellerTill."Maximum Teller Withholding");
//     //         end else begin
//     //             if CurrentTellerAmount + Amount >= TellerTill."Maximum Teller Withholding" then
//     //                 Message('Your till balance is Ksh %1 and is falling above your maximum allowed teller balance of Ksh %2. Kindly return extra amount to treasury.', CurrentTellerAmount + Amount, TellerTill."Maximum Teller Withholding");
//     //         end;
//     //         //Check teller transaction limits
//     //         if Rec.Type = 'Withdrawal' then begin
//     //             if (Amount > TellerTill."Max Withdrawal Limit") and (rec.Status <> rec.Status::Approved) then begin
//     //                 if Authorised = Authorised::No then begin
//     //                     "Authorisation Requirement" := 'Withdrawal Above teller Limit';
//     //                     Modify;

//     //                     MailContent := 'The' + ' ' + 'Cashier' + ' ' + Cashier + ' ' +
//     //                     'cannot withdraw more than allowed ,limit, Maximum limit is' + '' + Format(TellerTill."Max Withdrawal Limit") +
//     //                     'you need to authorise';
//     //                     SendEmail;
//     //                     Message('You cannot withdraw more than your allowed limit of %1 unless authorised.', TellerTill."Max Withdrawal Limit");
//     //                     exit;
//     //                 end;
//     //                 if Authorised = Authorised::Rejected then
//     //                     Error('Transaction has been rejected and therefore cannot proceed.');
//     //             end;
//     //         end;
//     //         //Prevent teller from Overdrawing Till

//     //         if Rec.Type = 'Withdrawal' then begin
//     //             TellerTill.CalcFields(TellerTill.Balance);
//     //             if Amount > TellerTill.Balance then begin
//     //                 Error('you cannot overdraw your Till Account.');
//     //             end;
//     //         end;
//     //         //Prevent teller from Overdrawing Till
//     //         if Rec.Type = 'Cash Deposit' then begin
//     //             if Amount > TellerTill."Max Deposit Limit" then begin
//     //                 if Authorised = Authorised::No then begin
//     //                     "Authorisation Requirement" := 'Deposit above teller Limit';
//     //                     Modify;
//     //                     MailContent := 'The' + ' ' + 'Cashier' + ' ' + Cashier + ' ' +
//     //                     'cannot deposit more than allowed limit, Maximum limit is' + '' + Format(TellerTill."Max Deposit Limit") + 'you need to authorise';
//     //                     SendEmail;
//     //                     Message('You cannot deposit more than your allowed limit of %1 unless authorised.', TellerTill."Max Deposit Limit");
//     //                     exit;
//     //                 end;
//     //                 if Authorised = Authorised::Rejected then
//     //                     Error('Transaction has been rejected therefore you cannot proceed.');

//     //             end;
//     //         end;
//     //         //Check teller transaction limits
//     //     end;
//     //     if TillNo = '' then
//     //         Error('Teller account not set-up.');
//     //     //Check Teller Balances
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;
//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Document No." := Rec.No;
//     //     if ("Transaction Type" = 'CASHWITH') or ("Transaction Type" = 'Encashment') then
//     //         GenJournalLine."External Document No." := Account."ID No."; // "ID No"; //"BOSA Account No";
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     if ("Transaction Type" = 'BOSA') or ("Transaction Type" = 'Encashment') then
//     //         GenJournalLine.Description := "Transaction Type" + Payee
//     //     else begin
//     //         if Rec."Branch Transaction" = true then
//     //             GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //         else
//     //             GenJournalLine.Description := "Transaction Type" + '-' + Description;
//     //     end;

//     //     if (Type = 'Cash Deposit') or (Type = 'BOSA Receipt') then
//     //         GenJournalLine.Amount := -Amount
//     //     else
//     //         GenJournalLine.Amount := Rec.Amount;

//     //     if (Type = 'Cash Deposit') or (Type = 'BOSA Receipt') then begin
//     //         GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::CashDeposit
//     //     end else
//     //         GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::CashWithdrawal;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"Bank Account";
//     //     GenJournalLine."Bal. Account No." := TillNo;
//     //     GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     if (Acc."Mobile Phone No" <> '') then begin
//     //         SFactory.FnSendSMS('TELLER', 'You have made a ' + Format(Type) + ' of ' + FORMAT(Amount) + '. Thank you for banking with us', Acc."No.", Acc."Mobile Phone No");
//     //     end;
//     //     //Charges
//     //     TCharges := 0;
//     //     //Charges
//     //     TCharges := 0;
//     //     if Account.Get(Rec."Account No") then begin
//     //         if Account."Staff Account" <> true then begin
//     //             if "Use Graduated Charges" = false then begin
//     //                 TransactionCharges.Reset;
//     //                 TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //                 if TransactionCharges.Find('-') then begin
//     //                     repeat
//     //                         LineNo := LineNo + 10000;
//     //                         ChargeAmount := 0;
//     //                         if Account.Get(Rec."Account No") then begin
//     //                             if Account."Staff Account" = false then begin
//     //                                 Echarge := ChargeAmount;
//     //                                 GenJournalLine.Init;
//     //                                 GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                                 GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                                 GenJournalLine."Document No." := Rec.No;
//     //                                 GenJournalLine."Line No." := LineNo;
//     //                                 GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                                 GenJournalLine."Account No." := Rec."Account No";
//     //                                 GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                                 GenJournalLine."Posting Date" := Today;
//     //                                 GenJournalLine.Description := TransactionCharges.Description;
//     //                                 GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                                 GenJournalLine.Amount := TransactionCharges."Charge Amount";
//     //                                 GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::CashWithdrawalCommission;
//     //                                 GenJournalLine.Validate(GenJournalLine.Amount);
//     //                                 GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //                                 GenJournalLine."Bal. Account No." := TransactionCharges."G/L Account";
//     //                                 GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                                 GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                                 GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                                 if GenJournalLine.Amount <> 0 then
//     //                                     GenJournalLine.Insert;
//     //                                 TChargeAmount := TChargeAmount + ChargeAmount;
//     //                             end;
//     //                         end;
//     //                     until TransactionCharges.Next = 0;
//     //                 end;
//     //             end;
//     //         end;
//     //     end;


//     //     if Account.Get(Rec."Account No") then begin
//     //         if Account."Staff Account" <> true then begin
//     //             //***Graduated Charge
//     //             ChargeAmount := 0;
//     //             if (Type = 'Withdrawal') and "Use Graduated Charges" = true then begin
//     //                 GraduatedCharge.Reset;
//     //                 if GraduatedCharge.Find('-') then begin
//     //                     repeat
//     //                         if (Amount >= GraduatedCharge."Minimum Amount") and (Amount <= GraduatedCharge."Maximum Amount") then begin
//     //                             if GraduatedCharge."Use Percentage" = true then begin
//     //                                 ChargeAmount := Amount * (GraduatedCharge."Percentage of Amount" / 100)
//     //                             end else
//     //                                 ChargeAmount := GraduatedCharge.Amount;
//     //                         end;
//     //                     until GraduatedCharge.Next = 0;
//     //                 end;
//     //             end;
//     //             if Account.Get(Rec."Account No") then begin
//     //                 if Account."Staff Account" = false then begin
//     //                     Echarge := ChargeAmount;

//     //                     LineNo := LineNo + 10000;
//     //                     GenJournalLine.Init;
//     //                     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                     GenJournalLine."Document No." := Rec.No;
//     //                     GenJournalLine."Line No." := LineNo;
//     //                     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                     GenJournalLine."Account No." := Rec."Account No";
//     //                     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                     GenJournalLine."Posting Date" := Today;
//     //                     GenJournalLine.Description := 'Cash Withdrawal Comission';
//     //                     GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::CashWithdrawalCommission;
//     //                     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                     GenJournalLine.Amount := ChargeAmount;
//     //                     GenJournalLine.Validate(GenJournalLine.Amount);
//     //                     GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //                     GenJournalLine."Bal. Account No." := GraduatedCharge."Charge Account";
//     //                     GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                     if GenJournalLine.Amount <> 0 then
//     //                         GenJournalLine.Insert;
//     //                     TChargeAmount := TChargeAmount + ChargeAmount;
//     //                 end;
//     //             end;
//     //         end;
//     //     end;

//     //     if Account.Get(Rec."Account No") then begin
//     //         if Account."Staff Account" <> true then begin

//     //             if "Use Graduated Charges" <> true then begin
//     //                 TransactionCharges.Reset;
//     //                 TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //                 TransactionCharges.SetRange(TransactionCharges."Charge Code", 'EXCISE');
//     //                 if TransactionCharges.Find('-') then begin
//     //                     Excise := TransactionCharges."Charge Amount";
//     //                     if Account.Get(Rec."Account No") then begin
//     //                         if Account."Staff Account" = true then begin

//     //                             LineNo := LineNo + 10000;
//     //                             GenJournalLine.Init;
//     //                             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                             GenJournalLine."Document No." := Rec.No;
//     //                             GenJournalLine."Line No." := LineNo;
//     //                             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                             GenJournalLine."Account No." := Rec."Account No";
//     //                             GenJournalLine."External Document No." := Rec."ID No";
//     //                             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                             GenJournalLine."Posting Date" := Today;
//     //                             GenJournalLine.Description := 'Excise Duty';
//     //                             GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ExciseDuty;
//     //                             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                             GenJournalLine.Amount := (Excise * (GenSetup."Excise Duty(%)" / 100));
//     //                             GenJournalLine.Validate(GenJournalLine.Amount);
//     //                             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //                             GenJournalLine."Bal. Account No." := GenSetup."Excise Duty Account";
//     //                             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                             if GenJournalLine.Amount <> 0 then
//     //                                 GenJournalLine.Insert;
//     //                         end;
//     //                     end;
//     //                 end;
//     //             end else
//     //                 GenSetup.Get();
//     //             //***Graduated Charge
//     //             if (Type = 'Withdrawal') and "Use Graduated Charges" = true then begin
//     //                 GraduatedCharge.Reset;
//     //                 if GraduatedCharge.Find('-') then begin
//     //                     repeat
//     //                         if (Amount >= GraduatedCharge."Minimum Amount") and (Amount <= GraduatedCharge."Maximum Amount") then begin
//     //                             if GraduatedCharge."Use Percentage" = true then begin
//     //                                 ChargeAmount := Amount * (GraduatedCharge."Percentage of Amount" / 100)
//     //                             end else
//     //                                 ChargeAmount := GraduatedCharge.Amount;
//     //                         end;
//     //                     until GraduatedCharge.Next = 0;
//     //                 end;
//     //             end;
//     //             ExciseDuty := (GenSetup."Excise Duty(%)" / 100) * ChargeAmount;
//     //             //***Graduated Charge End

//     //             LineNo := LineNo + 10000;
//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine."External Document No." := Rec."ID No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Excise Duty';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ExciseDuty;
//     //             GenJournalLine.Amount := (ChargeAmount * (GenSetup."Excise Duty(%)" / 100));
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := GenSetup."Excise Duty Account";
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;
//     //         end;
//     //     end;
//     //     if Rec.Type = 'Withdrawal' then begin
//     //         if Account.Get(Rec."Account No") then begin
//     //             if AccountTypes.Get(Account."Account Type") then begin
//     //                 if Account."Last Withdrawal Date" = 0D then begin
//     //                     Account."Last Withdrawal Date" := Today;
//     //                     Account.Modify;
//     //                 end else begin
//     //                     if CalcDate(AccountTypes."Withdrawal Interval", Account."Last Withdrawal Date") > Today then begin
//     //                         LineNo := LineNo + 10000;
//     //                         GenJournalLine.Init;
//     //                         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                         GenJournalLine."Document No." := Rec.No;
//     //                         GenJournalLine."Line No." := LineNo;
//     //                         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                         GenJournalLine."Account No." := Rec."Account No";
//     //                         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                         GenJournalLine."Posting Date" := Today;
//     //                         GenJournalLine.Description := 'Commision on Withdrawal Freq.';
//     //                         GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::CashWithdrawalCommission;
//     //                         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                         GenJournalLine.Amount := AccountTypes."Withdrawal Penalty";
//     //                         GenJournalLine.Validate(GenJournalLine.Amount);
//     //                         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //                         GenJournalLine."Bal. Account No." := AccountTypes."Withdrawal Interval Account";
//     //                         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                         if GenJournalLine.Amount <> 0 then
//     //                             GenJournalLine.Insert;

//     //                     end;
//     //                     Account."Last Withdrawal Date" := Today;
//     //                     Account.Modify;

//     //                 end;
//     //             end;
//     //         end;
//     //     end;
//     //     //2050
//     //     //2050
//     //     //Charge withdrawal Freq
//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::AWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'AWD');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     OverDraftChargeAcc := Charges."GL Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 OverDraftChargeAcc := Charges."GL Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;

//     //             /*genSetup.GET();
//     //             //Excise Duty
//     //             GenJournalLine.INIT;
//     //             GenJournalLine."Journal Template Name":='PURCHASES';
//     //             GenJournalLine."Journal Batch Name":='FTRANS';
//     //             GenJournalLine."Document No.":=No;
//     //             GenJournalLine."Line No.":=LineNo;
//     //             GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
//     //             GenJournalLine."Account No.":="Account No";
//     //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date":="Transaction Date";
//     //             GenJournalLine.Description:='Excise Duty on Overdraft';
//     //             GenJournalLine.VALIDATE(GenJournalLine."Currency Code");
//     //             IF AccountTypes.GET("Account Type") THEN BEGIN
//     //             GenJournalLine.Amount:=OverDraftCharge*(genSetup."Excise Duty(%)"/100);
//     //             END;
//     //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No.":=genSetup."Excise Duty Account";
//     //             GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code":=DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code":=DBranch;
//     //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
//     //             IF GenJournalLine.Amount<>0 THEN
//     //             GenJournalLine.INSERT;*/
//     //         end;
//     //     end;

//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::LWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'LWD');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     if LoanType.Get("LWD Loan Product") then
//     //                         //OverDraftChargeAcc:=Charges."GL Account"
//     //                         OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 if LoanType.Get("LWD Loan Product") then
//     //                     //OverDraftChargeAcc:=Charges."GL Account"
//     //                     OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;

//     //             /*genSetup.GET();
//     //             //Excise Duty
//     //             GenJournalLine.INIT;
//     //             GenJournalLine."Journal Template Name":='PURCHASES';
//     //             GenJournalLine."Journal Batch Name":='FTRANS';
//     //             GenJournalLine."Document No.":=No;
//     //             GenJournalLine."Line No.":=LineNo;
//     //             GenJournalLine."Account Type":=GenJournalLine."Account Type"::Vendor;
//     //             GenJournalLine."Account No.":="Account No";
//     //             GenJournalLine.VALIDATE(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date":="Transaction Date";
//     //             GenJournalLine.Description:='Excise Duty on Overdraft';
//     //             GenJournalLine.VALIDATE(GenJournalLine."Currency Code");
//     //             IF AccountTypes.GET("Account Type") THEN BEGIN
//     //             GenJournalLine.Amount:=OverDraftCharge*(genSetup."Excise Duty(%)"/100);
//     //             END;
//     //             GenJournalLine.VALIDATE(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No.":=genSetup."Excise Duty Account";
//     //             GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code":=DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code":=DBranch;
//     //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
//     //             IF GenJournalLine.Amount<>0 THEN
//     //             GenJournalLine.INSERT;*/
//     //         end;
//     //     end;
//     //     //..............................................
//     //     if (Type = 'Withdrawal') then begin
//     //         if SFactory.FnGetFosaAccountBalance(rec."Account No") - (Amount + TCharges + ChargeAmount + ExciseDuty) < 0 then begin
//     //             error('This transaction cannot be posted because it will lead to the balance falling below the minimum allowable account balance.');
//     //         end;
//     //     end;

//     //     //..............................................
//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;
//     //     //Post New
//     //     "Transaction Available Balance" := AvailableBalance;
//     //     Posted := true;
//     //     Authorised := Authorised::Yes;
//     //     "Supervisor Checked" := true;
//     //     "Needs Approval" := "needs approval"::No;
//     //     "Frequency Needs Approval" := "frequency needs approval"::No;
//     //     "Date Posted" := Today;
//     //     "Time Posted" := Time;
//     //     "Posted By" := UserId;
//     //     Modify;
//     //     //End Audit Entries
//     //     if Rec.Type = 'Cash Deposit' then begin
//     //         if Confirm('send Deposit sms to the member ?', false) = false then begin
//     //             exit;
//     //         end else begin

//     //         end;
//     //     end;
//     //     Commit;
//     //     Trans.Reset;
//     //     Trans.SetRange(Trans.No, No);
//     //     if Trans.Find('-') then begin
//     //         if Rec.Type = 'Cash Deposit' then
//     //             //  Report.Run(56498, false, true, Trans)
//     //             Report.Run(56498, true, true, Trans)//uncomment during live
//     //         else
//     //             if Rec.Type = 'BOSA Receipt' then
//     //                 // Report.Run(56516, false, true, Trans)
//     //                 Report.Run(56516, true, true, Trans)//uncomment during live
//     //             else
//     //                 if Rec.Type = 'Withdrawal' then begin
//     //                     //Report.Run(56499, false, true, Trans);
//     //                     Report.Run(56499, true, true, Trans);

//     //                 end;
//     //     end;
//     //     //CurrPage.Close();
//     //     //  Commit();
//     //     CurrPage.Close;
//     // end;



//     // procedure PostChequeWith()
//     // begin
//     //     //Block Payments
//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc.Blocked = Acc.Blocked::Payment then
//     //             Error('This account has been blocked from receiving payments.');
//     //     end;


//     //     /*DValue.RESET;
//     //     DValue.SETRANGE(DValue."Global Dimension No.",2);
//     //     DValue.SETRANGE(DValue.Code,'Nairobi');
//     //     //DValue.SETRANGE(DValue.Code,DBranch);
//     //     IF DValue.FIND('-') THEN BEGIN
//     //     DValue.TESTFIELD(DValue."Banker Cheque Account");
//     //     ChBank:=DValue."Banker Cheque Account";
//     //     END ELSE
//     //     ERROR('Branch not set.');*/

//     //     CalcAvailableBal;

//     //     //Check withdrawal limits
//     //     if Rec.Type = 'Cheque Withdrawal' then begin
//     //         if AvailableBalance < Amount then begin
//     //             if Authorised = Authorised::Yes then begin
//     //                 Overdraft := true;
//     //                 Modify;
//     //             end;

//     //             if Authorised = Authorised::No then begin
//     //                 if Rec."Branch Transaction" = false then begin
//     //                     "Authorisation Requirement" := 'Cheque Withdrawal - Over draft';
//     //                     Modify;
//     //                     Message('You cannot issue a Cheque more than the available balance unless authorised.');
//     //                     SendEmail;
//     //                     exit;
//     //                 end;
//     //             end;
//     //             if Authorised = Authorised::Rejected then
//     //                 Error('Cheque Withdrawal transaction has been rejected and therefore cannot proceed.');
//     //             //SendEmail;
//     //         end;
//     //     end;
//     //     //Check withdrawal limits


//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");

//     //     GenJournalLine."Posting Date" := Today;
//     //     if Rec."Branch Transaction" = true then
//     //         GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //     else
//     //         GenJournalLine.Description := Payee; //"Transaction Description"+'-'+Description ;
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := Rec.Amount;
//     //     GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ChequeWithdrawal;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
//     //     GenJournalLine."Account No." := "Cheque Clearing Bank Code";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := Payee;//"Account Name";
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := -Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     if Account.Get(Rec."Account No") then begin
//     //         if Account."Staff Account" <> true then begin

//     //             //Charges
//     //             TransactionCharges.Reset;
//     //             TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //             if TransactionCharges.Find('-') then begin
//     //                 repeat
//     //                     LineNo := LineNo + 10000;

//     //                     GenJournalLine.Init;
//     //                     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                     GenJournalLine."Document No." := Rec.No;
//     //                     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                     GenJournalLine."Line No." := LineNo;
//     //                     GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
//     //                     GenJournalLine."Account No." := TransactionCharges."G/L Account";
//     //                     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                     GenJournalLine."Posting Date" := Today;
//     //                     GenJournalLine.Description := TransactionCharges.Description;
//     //                     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                     GenJournalLine.Amount := TransactionCharges."Charge Amount" * -1;
//     //                     GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ChequeWithdrawalCommission;
//     //                     GenJournalLine.Validate(GenJournalLine.Amount);
//     //                     GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                     if GenJournalLine.Amount <> 0 then
//     //                         GenJournalLine.Insert;

//     //                     if TransactionCharges."Due Amount" > 0 then begin
//     //                         LineNo := LineNo + 10000;

//     //                         GenJournalLine.Init;
//     //                         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                         GenJournalLine."Document No." := Rec.No;
//     //                         GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                         GenJournalLine."Line No." := LineNo;
//     //                         GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
//     //                         GenJournalLine."Account No." := TransactionCharges."G/L Account";
//     //                         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                         GenJournalLine."Posting Date" := Today;
//     //                         GenJournalLine.Description := TransactionCharges.Description;
//     //                         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                         GenJournalLine.Amount := TransactionCharges."Due Amount";
//     //                         GenJournalLine.Validate(GenJournalLine.Amount);
//     //                         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"Bank Account";
//     //                         GenJournalLine."Bal. Account No." := ChBank;
//     //                         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                         if GenJournalLine.Amount <> 0 then
//     //                             GenJournalLine.Insert;


//     //                     end;

//     //                 until TransactionCharges.Next = 0;
//     //             end;


//     //             //Balancing Account
//     //             //Charges
//     //             TransactionCharges.Reset;
//     //             TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //             if TransactionCharges.Find('-') then begin
//     //                 TransactionCharges.CalcFields(TransactionCharges."Total Charges");
//     //                 LineNo := LineNo + 10000;

//     //                 GenJournalLine.Init;
//     //                 GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                 GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                 GenJournalLine."Document No." := Rec.No;
//     //                 GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                 GenJournalLine."Line No." := LineNo;
//     //                 GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                 GenJournalLine."Account No." := Rec."Account No";
//     //                 GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                 GenJournalLine."Posting Date" := Today;
//     //                 GenJournalLine.Description := TransactionCharges.Description;
//     //                 GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                 GenJournalLine.Amount := TransactionCharges."Total Charges";
//     //                 GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ChequeWithdrawalCommission;
//     //                 GenJournalLine.Validate(GenJournalLine.Amount);
//     //                 //GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"Bank Account";
//     //                 //GenJournalLine."Bal. Account No.":=ChBank;
//     //                 //GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //                 GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                 GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                 if GenJournalLine.Amount <> 0 then
//     //                     GenJournalLine.Insert;
//     //             end;
//     //         end;
//     //     end;

//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::AWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'AWD');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     OverDraftChargeAcc := Charges."GL Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 OverDraftChargeAcc := Charges."GL Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;
//     //         end;
//     //     end;


//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::LWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'OVERDRAFT');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     if LoanType.Get("LWD Loan Product") then
//     //                         //OverDraftChargeAcc:=Charges."GL Account"
//     //                         OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 if LoanType.Get("LWD Loan Product") then
//     //                     //OverDraftChargeAcc:=Charges."GL Account"
//     //                     OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;
//     //         end;
//     //     end;

//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;

//     //     //Post New


//     //     "Transaction Available Balance" := AvailableBalance;
//     //     Posted := true;
//     //     Authorised := Authorised::Yes;
//     //     "Supervisor Checked" := true;
//     //     "Needs Approval" := "needs approval"::No;
//     //     "Frequency Needs Approval" := "frequency needs approval"::No;
//     //     "Date Posted" := Today;
//     //     "Time Posted" := Time;
//     //     "Posted By" := UserId;
//     //     Modify;
//     //     /*IF CONFIRM('Are you sure you want to print this bankers cheque?',TRUE)=TRUE THEN BEGIN
//     //     REPORT.RUN(,TRUE,TRUE,Trans)
//     //     END;*/
//     //     //Audit Entries
//     //     if (UserId <> 'MOBILE') and (UserId <> 'ATM') and (UserId <> 'AGENCY') then begin
//     //         EntryNos := 0;
//     //         if Audit.FindLast then
//     //             EntryNos := 1 + Audit."Entry No";
//     //         Audit.Init;
//     //         Audit."Entry No" := EntryNos;
//     //         Audit."Transaction Type" := "Transaction Type";
//     //         Audit."Loan Number" := '';
//     //         Audit."Document Number" := Rec.No;
//     //         Audit.UsersId := UserId;
//     //         Audit."Account Number" := Rec."Account No";
//     //         Audit.Amount := Rec.Amount;
//     //         Audit.Date := Today;
//     //         Audit.Time := Time;
//     //         Audit.Source := 'CASHIER TRANSACTION';
//     //         Audit.Insert;
//     //         Commit
//     //     end;
//     //     //End Audit Entries

//     //     //Mark Cheque Book
//     //     ChequeRegister.Reset;
//     //     ChequeRegister.SetRange(ChequeRegister."Cheque No.", "Bankers Cheque No");
//     //     if ChequeRegister.Find('-') then begin
//     //         ChequeRegister.Issued := true;
//     //         ChequeRegister.Modify;
//     //     end;

//     //     Message('Cheque Withdrawal posted successfully.');

//     // end;


//     // procedure SuggestBOSAEntries()
//     // begin
//     //     Rec.TestField(Posted, false);
//     //     Rec.TestField("BOSA Account No");

//     //     ReceiptAllocations.Reset;
//     //     ReceiptAllocations.SetRange(ReceiptAllocations."Document No", Rec.No);
//     //     ReceiptAllocations.DeleteAll;

//     //     PaymentAmount := Rec.Amount;
//     //     RunBal := PaymentAmount;

//     //     Loans.Reset;
//     //     Loans.SetCurrentkey(Loans.Source, Loans."Client Code");
//     //     Loans.SetRange(Loans."Client Code", "BOSA Account No");
//     //     Loans.SetRange(Loans.Source, Loans.Source::" ");
//     //     if Loans.Find('-') then begin
//     //         repeat
//     //             Loans.CalcFields(Loans."Outstanding Balance", Loans."Interest Due");
//     //             Recover := true;

//     //             if (Loans."Outstanding Balance") > 0 then begin
//     //                 if ((Loans."Outstanding Balance" - Loans."Loan Principle Repayment") <= 0) and (Cheque = false) then
//     //                     Recover := false;

//     //                 if Recover = true then begin

//     //                     Commision := 0;
//     //                     if Cheque = true then begin
//     //                         Commision := (Loans."Outstanding Balance") * 0.1;
//     //                         LOustanding := Loans."Outstanding Balance";
//     //                         if Loans."Interest Due" > 0 then
//     //                             InterestPaid := Loans."Interest Due";
//     //                     end else begin
//     //                         LOustanding := (Loans."Outstanding Balance" - Loans."Loan Principle Repayment");
//     //                         if LOustanding < 0 then
//     //                             LOustanding := 0;
//     //                         if Loans."Interest Due" > 0 then
//     //                             InterestPaid := Loans."Interest Due";
//     //                         if (Loans."Outstanding Balance" - Loans."Loan Principle Repayment") > 0 then begin
//     //                             if (Loans."Outstanding Balance" - Loans."Loan Principle Repayment") > (Loans."Approved Amount" * 1 / 3) then
//     //                                 Commision := LOustanding * 0.1;
//     //                         end;
//     //                     end;

//     //                     if PaymentAmount > 0 then begin
//     //                         if RunBal < (LOustanding + Commision + InterestPaid) then begin
//     //                             if RunBal < InterestPaid then
//     //                                 InterestPaid := RunBal;
//     //                             //Commision:=(RunBal-InterestPaid)*0.1;
//     //                             Commision := (RunBal - InterestPaid) - ((RunBal - InterestPaid) / 1.1);
//     //                             LOustanding := (RunBal - InterestPaid) - Commision;

//     //                         end;
//     //                     end;


//     //                     TotalCommision := TotalCommision + Commision;
//     //                     TotalOustanding := TotalOustanding + LOustanding + InterestPaid + Commision;

//     //                     RunBal := RunBal - (LOustanding + InterestPaid + Commision);

//     //                     if (LOustanding + InterestPaid) > 0 then begin
//     //                         ReceiptAllocations.Init;
//     //                         ReceiptAllocations."Document No" := Rec.No;
//     //                         ReceiptAllocations."Member No" := "BOSA Account No";
//     //                         ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Registration Fee";
//     //                         ReceiptAllocations."Loan No." := Loans."Loan  No.";
//     //                         ReceiptAllocations.Amount := ROUND(LOustanding, 0.01);
//     //                         ReceiptAllocations."Interest Amount" := ROUND(InterestPaid, 0.01);
//     //                         ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount + ReceiptAllocations."Interest Amount";
//     //                         ReceiptAllocations.Insert;
//     //                     end;

//     //                     if Commision > 0 then begin
//     //                         ReceiptAllocations.Init;
//     //                         ReceiptAllocations."Document No" := Rec.No;
//     //                         ReceiptAllocations."Member No" := "BOSA Account No";
//     //                         ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::Repayment;
//     //                         ReceiptAllocations."Loan No." := Loans."Loan  No.";
//     //                         ReceiptAllocations.Amount := ROUND(Commision, 0.01);
//     //                         ReceiptAllocations."Interest Amount" := 0;
//     //                         ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount + ReceiptAllocations."Interest Amount";
//     //                         ReceiptAllocations.Insert;
//     //                     end;

//     //                 end;
//     //             end;

//     //         until Loans.Next = 0;
//     //     end;

//     //     if RunBal > 0 then begin
//     //         ReceiptAllocations.Init;
//     //         ReceiptAllocations."Document No" := Rec.No;
//     //         ReceiptAllocations."Member No" := "BOSA Account No";
//     //         ReceiptAllocations."Transaction Type" := ReceiptAllocations."transaction type"::"Benevolent Fund";
//     //         ReceiptAllocations."Loan No." := '';
//     //         ReceiptAllocations.Amount := RunBal;
//     //         ReceiptAllocations."Interest Amount" := 0;
//     //         ReceiptAllocations."Total Amount" := ReceiptAllocations.Amount + ReceiptAllocations."Interest Amount";
//     //         ReceiptAllocations.Insert;

//     //     end;
//     // end;


//     // procedure SendEmail()
//     // begin
//     //     /*
//     //     //send e-mail to supervisor
//     //     supervisor.RESET;
//     //     supervisor.SETFILTER(supervisor."Transaction Type",'withdrawal');
//     //     IF supervisor.FIND('-') THEN BEGIN
//     //      // MailContent:=TEXT1;
//     //     REPEAT

//     //      genSetup.GET(0);
//     //      SMTPMAIL.NewMessage(genSetup."Sender Address",'Transactions' +''+'');
//     //      SMTPMAIL.SetWorkMode();
//     //      SMTPMAIL.ClearAttachments();
//     //      SMTPMAIL.ClearAllRecipients();
//     //      SMTPMAIL.SetDebugMode();
//     //      SMTPMAIL.SetFromAdress(genSetup."Sender Address");
//     //      SMTPMAIL.SetHost(genSetup."Outgoing Mail Server");
//     //      SMTPMAIL.SetUserID(genSetup."Sender User ID");
//     //      SMTPMAIL.AddLine(MailContent);
//     //      SMTPMAIL.SetToAdress(supervisor."E-mail Address");
//     //      SMTPMAIL.Send;
//     //      UNTIL supervisor.NEXT=0;
//     //     END;
//     //     */

//     // end;


//     // procedure PostBankersChequeVer1()
//     // begin
//     //     //Block Payments
//     //     if Acc.Get(Rec."Account No") then begin
//     //         if Acc.Blocked = Acc.Blocked::Payment then
//     //             Error('This account has been blocked from receiving payments.');
//     //     end;


//     //     /*DValue.RESET;
//     //     DValue.SETRANGE(DValue."Global Dimension No.",2);
//     //     DValue.SETRANGE(DValue.Code,'Nairobi');
//     //     //DValue.SETRANGE(DValue.Code,DBranch);
//     //     IF DValue.FIND('-') THEN BEGIN
//     //     DValue.TESTFIELD(DValue."Banker Cheque Account");
//     //     ChBank:=DValue."Banker Cheque Account";
//     //     END ELSE
//     //     ERROR('Branch not set.');*/

//     //     CalcAvailableBal;

//     //     //Check withdrawal limits
//     //     if Rec.Type = 'Bankers Cheque' then begin
//     //         if AvailableBalance < Amount then begin
//     //             if Authorised = Authorised::Yes then begin
//     //                 Overdraft := true;
//     //                 Modify;
//     //             end;

//     //             if Authorised = Authorised::No then begin
//     //                 if Rec."Branch Transaction" = false then begin
//     //                     "Authorisation Requirement" := 'Cheque Withdrawal - Over draft';
//     //                     Modify;
//     //                     Message('You cannot issue a Cheque more than the available balance unless authorised.');
//     //                     SendEmail;
//     //                     exit;
//     //                 end;
//     //             end;
//     //             if Authorised = Authorised::Rejected then
//     //                 Error('Cheque Withdrawal transaction has been rejected and therefore cannot proceed.');
//     //             //SendEmail;
//     //         end;
//     //     end;
//     //     //Check withdrawal limits


//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     GenJournalLine.DeleteAll;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //     GenJournalLine."Account No." := Rec."Account No";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");

//     //     GenJournalLine."Posting Date" := Today;
//     //     if Rec."Branch Transaction" = true then
//     //         GenJournalLine.Description := Rec."Transaction Type" + '-' + Rec."Branch Refference"
//     //     else
//     //         GenJournalLine.Description := "Transaction Type" + '-' + Payee; //"Transaction Description"+'-'+Description ;
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := Rec.Amount;
//     //     GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::BankersCheques;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     LineNo := LineNo + 10000;

//     //     GenJournalLine.Init;
//     //     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //     GenJournalLine."Document No." := Rec.No;
//     //     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //     GenJournalLine."Line No." := LineNo;
//     //     GenJournalLine."Account Type" := GenJournalLine."account type"::"Bank Account";
//     //     GenJournalLine."Account No." := "Cheque Clearing Bank Code";
//     //     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //     GenJournalLine."Posting Date" := Today;
//     //     GenJournalLine.Description := Payee;//"Account Name";
//     //     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //     GenJournalLine.Amount := -Amount;
//     //     GenJournalLine.Validate(GenJournalLine.Amount);
//     //     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //     if GenJournalLine.Amount <> 0 then
//     //         GenJournalLine.Insert;

//     //     if Account.Get(Rec."Account No") then begin
//     //         if Account."Staff Account" <> true then begin
//     //             //Charges
//     //             TransactionCharges.Reset;
//     //             TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //             if TransactionCharges.Find('-') then begin
//     //                 repeat
//     //                     LineNo := LineNo + 10000;

//     //                     GenJournalLine.Init;
//     //                     GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                     GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                     GenJournalLine."Document No." := Rec.No;
//     //                     GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                     GenJournalLine."Line No." := LineNo;
//     //                     GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
//     //                     GenJournalLine."Account No." := TransactionCharges."G/L Account";
//     //                     GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                     GenJournalLine."Posting Date" := Today;
//     //                     GenJournalLine.Description := TransactionCharges.Description;
//     //                     GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                     GenJournalLine.Amount := TransactionCharges."Charge Amount" * -1;
//     //                     GenJournalLine.Validate(GenJournalLine.Amount);
//     //                     GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::BankersChequeCommission;
//     //                     GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                     GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                     GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                     GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                     if GenJournalLine.Amount <> 0 then
//     //                         GenJournalLine.Insert;

//     //                     if TransactionCharges."Due Amount" > 0 then begin
//     //                         LineNo := LineNo + 10000;

//     //                         GenJournalLine.Init;
//     //                         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                         GenJournalLine."Document No." := Rec.No;
//     //                         GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                         GenJournalLine."Line No." := LineNo;
//     //                         GenJournalLine."Account Type" := GenJournalLine."account type"::"G/L Account";
//     //                         GenJournalLine."Account No." := TransactionCharges."G/L Account";
//     //                         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                         GenJournalLine."Posting Date" := Today;
//     //                         GenJournalLine.Description := TransactionCharges.Description;
//     //                         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                         GenJournalLine.Amount := TransactionCharges."Due Amount";
//     //                         GenJournalLine.Validate(GenJournalLine.Amount);
//     //                         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"Bank Account";
//     //                         GenJournalLine."Bal. Account No." := ChBank;
//     //                         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //                         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                         if GenJournalLine.Amount <> 0 then
//     //                             GenJournalLine.Insert;

//     //                     end;

//     //                 until TransactionCharges.Next = 0;
//     //             end;




//     //             //Balancing Account
//     //             //Charges
//     //             TransactionCharges.Reset;
//     //             TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //             if TransactionCharges.Find('-') then begin
//     //                 TransactionCharges.CalcFields(TransactionCharges."Total Charges");
//     //                 LineNo := LineNo + 10000;

//     //                 GenJournalLine.Init;
//     //                 GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //                 GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //                 GenJournalLine."Document No." := Rec.No;
//     //                 GenJournalLine."External Document No." := "Bankers Cheque No";
//     //                 GenJournalLine."Line No." := LineNo;
//     //                 GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //                 GenJournalLine."Account No." := Rec."Account No";
//     //                 GenJournalLine.Validate(GenJournalLine."Account No.");
//     //                 GenJournalLine."Posting Date" := Today;
//     //                 GenJournalLine.Description := TransactionCharges.Description;
//     //                 GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //                 GenJournalLine.Amount := TransactionCharges."Total Charges";
//     //                 GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::BankersChequeCommission;
//     //                 GenJournalLine.Validate(GenJournalLine.Amount);
//     //                 //GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"Bank Account";
//     //                 //GenJournalLine."Bal. Account No.":=ChBank;
//     //                 //GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
//     //                 GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //                 GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //                 GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //                 if GenJournalLine.Amount <> 0 then
//     //                     GenJournalLine.Insert;
//     //             end;
//     //         end;
//     //     end;

//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::AWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'AWD');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     OverDraftChargeAcc := Charges."GL Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 OverDraftChargeAcc := Charges."GL Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;
//     //         end;
//     //     end;


//     //     //Charge Overdraft Comission
//     //     if "Authorisation Requirement" = 'Over draft' then begin
//     //         if ("Over Draft Type" = "over draft type"::LWD) and ("Excempt Charge" <> true) then begin
//     //             Charges.Reset;
//     //             Charges.SetRange(Charges.Code, 'OVERDRAFT');
//     //             if Charges.Find('-') then begin
//     //                 if Charges."Use Percentage" = true then begin
//     //                     OverDraftCharge := Amount * (Charges."Percentage of Amount" / 100);
//     //                     if LoanType.Get("LWD Loan Product") then
//     //                         //OverDraftChargeAcc:=Charges."GL Account"
//     //                         OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //                 end else
//     //                     OverDraftCharge := Charges."Charge Amount";
//     //                 if LoanType.Get("LWD Loan Product") then
//     //                     //OverDraftChargeAcc:=Charges."GL Account"
//     //                     OverDraftChargeAcc := LoanType."Loan Interest Account"
//     //             end;

//     //             LineNo := LineNo + 10000;

//     //             GenJournalLine.Init;
//     //             GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //             GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //             GenJournalLine."Document No." := Rec.No;
//     //             GenJournalLine."Line No." := LineNo;
//     //             GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //             GenJournalLine."Account No." := Rec."Account No";
//     //             GenJournalLine.Validate(GenJournalLine."Account No.");
//     //             GenJournalLine."Posting Date" := Today;
//     //             GenJournalLine.Description := 'Commision on Overdraft';
//     //             GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //             if AccountTypes.Get("Account Type") then begin
//     //                 GenJournalLine.Amount := OverDraftCharge;
//     //             end;
//     //             GenJournalLine.Validate(GenJournalLine.Amount);
//     //             GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //             GenJournalLine."Bal. Account No." := OverDraftChargeAcc;
//     //             GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //             GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //             GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //             GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //             if GenJournalLine.Amount <> 0 then
//     //                 GenJournalLine.Insert;
//     //         end;
//     //     end;

//     //     GenSetup.Get();
//     //     //Excise Duty
//     //     TransactionCharges.Reset;
//     //     TransactionCharges.SetRange(TransactionCharges."Transaction Type", "Transaction Type");
//     //     if TransactionCharges.Find('-') then begin
//     //         LineNo := LineNo + 10000;
//     //         GenJournalLine.Init;
//     //         GenJournalLine."Journal Template Name" := 'PURCHASES';
//     //         GenJournalLine."Journal Batch Name" := 'FTRANS';
//     //         GenJournalLine."Document No." := Rec.No;
//     //         GenJournalLine."External Document No." := "Bankers Cheque No";
//     //         GenJournalLine."Line No." := LineNo;
//     //         GenJournalLine."Account Type" := GenJournalLine."account type"::Vendor;
//     //         GenJournalLine."Account No." := Rec."Account No";
//     //         GenJournalLine.Validate(GenJournalLine."Account No.");
//     //         GenJournalLine."Posting Date" := Today;
//     //         GenJournalLine.Description := 'Excise Duty';
//     //         GenJournalLine.Validate(GenJournalLine."Currency Code");
//     //         GenJournalLine.Amount := (TransactionCharges."Charge Amount") * GenSetup."Excise Duty(%)" / 100;
//     //         GenJournalLine."FOSA Transaction Type" := GenJournalLine."fosa transaction type"::ExciseDuty;
//     //         GenJournalLine.Validate(GenJournalLine.Amount);
//     //         GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
//     //         GenJournalLine."Bal. Account No." := GenSetup."Excise Duty Account";
//     //         GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
//     //         GenJournalLine."Shortcut Dimension 1 Code" := DActivity;
//     //         GenJournalLine."Shortcut Dimension 2 Code" := DBranch;
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
//     //         GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
//     //         if GenJournalLine.Amount <> 0 then
//     //             GenJournalLine.Insert;
//     //     end;


//     //     //Post New
//     //     GenJournalLine.Reset;
//     //     GenJournalLine.SetRange("Journal Template Name", 'PURCHASES');
//     //     GenJournalLine.SetRange("Journal Batch Name", 'FTRANS');
//     //     if GenJournalLine.Find('-') then begin
//     //         Codeunit.Run(Codeunit::"Gen. Jnl.-Post Sacco", GenJournalLine);
//     //     end;

//     //     //Post New


//     //     "Transaction Available Balance" := AvailableBalance;
//     //     Posted := true;
//     //     Authorised := Authorised::Yes;
//     //     "Supervisor Checked" := true;
//     //     "Needs Approval" := "needs approval"::No;
//     //     "Frequency Needs Approval" := "frequency needs approval"::No;
//     //     "Date Posted" := Today;
//     //     "Time Posted" := Time;
//     //     "Posted By" := UserId;
//     //     Modify;

//     //     //Mark Cheque Book
//     //     ChequeRegister.Reset;
//     //     ChequeRegister.SetRange(ChequeRegister."Cheque No.", "Bankers Cheque No");
//     //     if ChequeRegister.Find('-') then begin
//     //         ChequeRegister.Issued := true;
//     //         ChequeRegister.Modify;
//     //     end;

//     //     Message('Cheque Withdrawal posted successfully.');

//     // end;

//     var
//         SFactory: Codeunit "SWIZZSOFT Factory";
//         AllowSendApproval: Boolean;
//         CancelApproval: Boolean;

//     local procedure FnSendRecordApproval()
//     var
//     begin
//         CancelApproval := false;
//         AllowSendApproval := false;
//         if (rec.Amount >= 50000) and (rec.Type = 'Withdrawal') then begin
//             AllowSendApproval := true;
//         end;
//         if rec.Status = rec.Status::Pending then begin
//             CancelApproval := true;
//         end;
//     end;

// }

