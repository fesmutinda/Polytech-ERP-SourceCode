// page 50012 "Polytech Dividend Card"
// {
//     ApplicationArea = All;
//     Caption = 'Polytech Dividend Card';
//     PageType = Card;
//     SourceTable = "Polytech Dividend Receipt";
//     DeleteAllowed = false;
//     SourceTableView = where(Posted = const(false));

//     layout
//     {
//         area(content)
//         {
//             group(General)
//             {
//                 field(DividendYear; Rec.DividendYear)
//                 {
//                     ApplicationArea = Basic;
//                     Editable = true;
//                 }
//                 field("Document No"; Rec."Document No")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Date Entered"; Rec."Date Entered")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Posting date"; Rec."Posting date")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = true;
//                 }
//                 field(Remarks; Rec.Remarks)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Total Count"; Rec."Total Count")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Posted By"; Rec."Posted By")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field(Amount; Rec.Amount)
//                 {
//                     Caption = 'Cheque Amount';
//                     ApplicationArea = Basic;
//                 }
//                 field("Scheduled Amount"; Rec."Scheduled Amount")
//                 {
//                     ApplicationArea = Basic;
//                     Editable = false;
//                 }
//                 field("Entered By"; Rec."Entered By")
//                 {
//                     ApplicationArea = Basic;
//                     Enabled = false;
//                 }
//                 field("Dividend Year"; Rec."Dividend Year")
//                 {
//                     Editable = false;
//                 }
//             }
//             part(Polytech_Dividend_Lines; "Polytech Dividend Lines")
//             {
//                 SubPageLink = "Receipt Dividend Year" = field(DividendYear);
//             }
//         }
//     }
//     actions
//     {
//         area(processing)
//         {
//             // 1. Import Dividend
//             action(ImportItems)
//             {
//                 Caption = 'Import Dividend Lines';
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 Image = Import;
//                 ApplicationArea = All;

//                 RunObject = xmlport "Polytech Dividend Import";
//             }
//             // 2. Validate Receipts
//             action("Validate Receipts")
//             {
//                 ApplicationArea = Basic;
//                 Caption = 'Validate Receipts';
//                 Image = ValidateEmailLoggingSetup;
//                 Promoted = true;
//                 PromotedCategory = Process;

//                 trigger OnAction()
//                 begin
//                     dividendLines.Reset;
//                     dividendLines.SetRange(dividendLines."Receipt Dividend Year", Rec.DividendYear);
//                     if dividendLines.Find('-') then begin
//                         repeat

//                             Memb.Reset;
//                             Memb.SetRange(Memb."No.", dividendLines."Member No");
//                             if Memb.Find('-') then begin

//                                 dividendLines."Member No" := Memb."No.";
//                                 dividendLines.Name := Memb.Name;
//                                 dividendLines."ID No." := Memb."ID No.";
//                                 dividendLines."Member Found" := true;
//                                 dividendLines.Modify;
//                             end;
//                         until dividendLines.Next = 0;
//                     end;
//                     Message('Successfully validated');
//                 end;
//             }
//             // 3. Refresh Page
//             action(RefreshPage)
//             {
//                 Caption = 'Refresh page';
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 Image = Refresh;
//                 ApplicationArea = All;

//                 trigger OnAction()
//                 begin
//                     // Message('Refreshing...');
//                     CurrPage.Update; // Refresh the current page UI
//                     Rec.Validate("Scheduled Amount");
//                     FnValidateMembers();
//                     FnValidateAmounts();
//                     Rec.UpdateTotalAmount();
//                     Rec.Modify(true);
//                     Message('Page refreshed and data updated.');
//                 end;
//             }
//             // 4. Post Dividend
//             action("Post Dividend")
//             {
//                 ApplicationArea = Basic;
//                 Caption = 'Post Dividend Lines';
//                 Image = Post;
//                 Promoted = true;
//                 PromotedCategory = Process;
//                 // PromotedIsBig = true;

//                 trigger OnAction()
//                 var
//                     UsersID: Record User;
//                     FundsUSer: Record "Funds User Setup";
//                     GenJnlManagement: Codeunit GenJnlManagement;
//                     GenBatch: Record "Gen. Journal Batch";
//                     dialogBox: Dialog;
//                     loanArrears: Decimal;
//                 begin
//                     Rec.SetRange(Rec.DividendYear);
//                     genstup.Get();
//                     if Rec.Posted = true then
//                         Error('This Check Off has already been posted');

//                     if Rec."Document No" = '' then
//                         Error('You must specify the Document No.');
//                     if Rec."Posting date" = 0D then
//                         Error('You must specify the Posting date.');
//                     if Rec."Posting date" = 0D then
//                         Error('You must specify the Posting date.');

//                     Jtemplate := 'PAYMENTS';
//                     Jbatch := 'DIVIDEND';

//                     Gensetup.Get();
//                     GenJournalLine.Reset;
//                     GenJournalLine.SetRange("Journal Template Name", 'PAYMENTS');
//                     GenJournalLine.SetRange("Journal Batch Name", 'DIVIDEND');
//                     if GenJournalLine.Find('-') then begin
//                         GenJournalLine.DeleteAll;
//                     end;

//                     // Rec.CalcFields("Scheduled Amount");
//                     if Rec."Scheduled Amount" <> Rec.Amount then begin
//                         ERROR('Scheduled Amount Is Not Equal To Cheque Amount');
//                     end;

//                     // StartDate := 20250101D;//yyyymmddD
//                     LineN := 10000;

//                     dividendLines.Reset;
//                     dividendLines.SetRange(dividendLines."Receipt Dividend Year", Rec.DividendYear);
//                     dividendLines.SetRange(dividendLines.Posted, false);
//                     if dividendLines.Find('-') then begin
//                         repeat
//                             dialogBox.Open('Processing Dividends for ' + Format(dividendLines."Member No") + ': ' + dividendLines.Name + '...');

//                             //get Loan Arrears
//                             loanArrears := 0;
//                             loanArrears := FnGetLoanArrears(dividendLines."Member No");

//                             LineN := LineN + 10000;
//                             FnPostDividendstoWallet(dividendLines."Member No",
//                                                     Rec."Posting date",
//                                                     dividendLines."Gross Dividend",
//                                                     dividendLines."WTX Tax",
//                                                     loanArrears,
//                                                     Rec."Dividend Year"
//                                                     );


//                             //send Dividend SMS

//                             // Mark as posted
//                             dividendLines.Posted := true;
//                             dividendLines.Modify();

//                             dialogBox.Close();

//                         until dividendLines.Next = 0;
//                     end;

//                     // Reinitialize the record and open the journal page
//                     Gnljnline.Reset();
//                     Gnljnline.SetRange("Journal Template Name", Jtemplate);
//                     Gnljnline.SetRange("Journal Batch Name", Jbatch);
//                     if Gnljnline.Find('-') then begin
//                         Page.Run(page::"General Journal", Gnljnline);
//                         Message('CheckOff Successfully Generated');
//                     end;


//                 end;
//             }
//             // 5. Mark as Posted
//             action("Processed Dividend")
//             {
//                 Caption = 'Mark as Posted';
//                 ApplicationArea = Basic;
//                 Image = POST;
//                 Promoted = true;
//                 PromotedCategory = Process;

//                 trigger OnAction()
//                 begin
//                     if Confirm('Are you sure you want to mark this Checkoff as Processed', false) = true then begin
//                         Rec.Posted := true;
//                         Rec."Posted By" := UserId;
//                         Rec.Modify;
//                         CurrPage.close();
//                     end;
//                 end;
//             }
//         }
//     }

//     trigger OnInsertRecord(BelowxRec: Boolean): Boolean
//     begin
//         Rec."Posting date" := Today;
//         Rec."Date Entered" := Today;
//     end;

//     var
//         welfareProcessing: Codeunit WelfareProcessing;
//         Gnljnline: Record "Gen. Journal Line";
//         GenJournalLine: Record "Gen. Journal Line";
//         PDate: Date;
//         DocNo: Code[20];
//         // RunBal: Decimal;
//         emergencyLoan12Balance: Decimal;
//         emergencyLoan13Balance: Decimal;
//         quickLoanBalance: Decimal;
//         superQuickLoanBalance: Decimal;
//         schoolFeesLoanBalance: Decimal;
//         superSchoolFeesLoanBalance: Decimal;
//         investmentLoanBalance: Decimal;
//         normal20LoanBalance: Decimal;
//         normal21LoanBalance: Decimal;
//         normal22LoanBalance: Decimal;
//         development23LoanBalance: Decimal;
//         development25LoanBalance: Decimal;
//         merchandiseLoanBalance: Decimal;
//         welfarecontributionbalance: Decimal;
//         LBatches: Record "Loan Disburesment-Batching";
//         Jtemplate: Code[30];
//         JBatch: Code[30];
//         "Cheque No.": Code[20];
//         DActivityBOSA: Code[20];
//         DBranchBOSA: Code[20];
//         ReptProcHeader: Record "Polytech Checkoff Header";
//         Cust: Record Customer;
//         MembPostGroup: Record "Customer Posting Group";
//         Loantable: Record "Loans Register";
//         LRepayment: Decimal;
//         dividendLines: Record "Polytech Dividend Lines";
//         AmountToDeduct: Decimal;
//         WelfareAmount: Decimal;
//         CommissionAmount: Decimal;
//         LoanType: Record "Loan Products Setup";
//         LoanApp: Record "Loans Register";
//         Interest: Decimal;
//         LineN: Integer;
//         TotalRepay: Decimal;
//         MultipleLoan: Integer;
//         LType: Text;
//         MonthlyAmount: Decimal;
//         ShRec: Decimal;
//         SHARESCAP: Decimal;
//         DIFF: Decimal;
//         DIFFPAID: Decimal;
//         genstup: Record "Sacco General Set-Up";
//         Memb: Record Customer;
//         INSURANCE: Decimal;
//         GenBatches: Record "Gen. Journal Batch";
//         XMAS: Decimal;
//         MemberRec: Record Customer;
//         Vendor: Record Vendor;
//         TotalWelfareAmount: Decimal;
//         LoanRepS: Record "Loan Repayment Schedule";
//         MonthlyRepay: Decimal;
//         cm: Date;
//         mm: Code[10];
//         Lschedule: Record "Loan Repayment Schedule";
//         ScheduleRepayment: Decimal;
//         LineNo: Integer;
//         SFactory: Codeunit "SWIZZSOFT Factory.";
//         GenSetUp: Record "Sacco General Set-Up";
//         YearCalc: Text;
//         walletAccount: Code[20];
//         ExciseDuty: Decimal;

//     local procedure FnValidateMembers()
//     var
//     begin
//         dividendLines.Reset;
//         dividendLines.SetRange(dividendLines."Receipt Dividend Year", Rec.DividendYear);
//         if dividendLines.Find('-') then begin
//             repeat

//                 Memb.Reset;
//                 Memb.SetRange(Memb."No.", dividendLines."Member No");
//                 if Memb.Find('-') then begin

//                     dividendLines."Member No" := Memb."No.";
//                     dividendLines.Name := Memb.Name;
//                     dividendLines."ID No." := Memb."ID No.";
//                     dividendLines."Member Found" := true;
//                     dividendLines.Modify;
//                 end;
//             until dividendLines.Next = 0;
//         end;
//     end;

//     local procedure FnValidateAmounts()
//     var
//     begin

//     end;



//     local procedure FnGetLoanArrears(MemberNo: Code[20]) arrearsAmount: Decimal
//     var
//         loansRegisterTableA: Record "Loans Register";
//     begin
//         arrearsAmount := 0;

//         loansRegisterTableA.Reset();
//         loansRegisterTableA.SetRange("Client Code", MemberNo);
//         loansRegisterTableA.SetFilter("Amount in Arrears", '>%1', 0);

//         if loansRegisterTableA.FindSet() then begin
//             repeat
//                 arrearsAmount += loansRegisterTableA."Amount in Arrears";
//             until loansRegisterTableA.Next() = 0;
//         end;
//     end;

//     procedure FnPostDividendstoWallet(MemberNo: Code[20]; PostingDate: Date; GrossTotalDiv: Decimal; TotalWhtax: Decimal; loanArrears: Decimal; StartDate: Date)
//     var
//         DividendAmount: Decimal;
//         smsText: Text[1000];
//         loanRecovered: Decimal;
//     begin
//         //Declaration....
//         smsText := '';
//         DividendAmount := GrossTotalDiv;
//         walletAccount := SFactory.FnGetFosaAccount(MemberNo);
//         YearCalc := Format(Date2dmy(StartDate, 3));
//         GenSetUp.Get();
//         ExciseDuty := 0;
//         ExciseDuty := (GenSetUp."Dividend Processing Fee" * (GenSetUp."Excise Duty(%)" / 100));

//         ////### -- 1.1 CREDIT MEMBER DIVIDEND -GrossTotalDiv
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, MemberNo, PostingDate, GrossTotalDiv * -1, 'BOSA', '',
//         'Gross Dividend and Interest on Deposits - ' + Format(YearCalc), '');

//         ////## --- 1.2 DEBIT DIVIDEND PAYABLE GL - GrossTotalDiv
//         LineNo := LineNo + 10000;
//         GenSetUp.Get();
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::" ",
//         GenJournalLine."Account Type"::"G/L Account", GenSetUp."Dividend Payable Account", PostingDate, GrossTotalDiv, 'BOSA', '',
//         'Gross Dividend and Interest on Deposits - ' + MemberNo, '');

//         ///######## 3.1 CREDIT WTX GL ACC
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::" ",
//         GenJournalLine."account type"::"G/L Account", GenSetUp."WithHolding Tax Account", PostingDate, (TotalWhtax) * -1, 'BOSA', '',
//         'Witholding Tax on Dividend- ' + MemberNo, '');

//         //########## 3.2 DEBIT Div Membe Acc ON WTX
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, MemberNo, PostingDate, (TotalWhtax), 'BOSA', '',
//         'Witholding Tax on Dividend- ' + YearCalc, '');
//         DividendAmount := DividendAmount - TotalWhtax;


//         ////######## 4.1 DEBIT Member Number ON PROCESSSING FEE
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, MemberNo, PostingDate, GenSetUp."Dividend Processing Fee", 'BOSA', '',
//         'Processing Fee- ' + MemberNo, '');
//         ///##### 4.2 CREDIT PROCESSING FEE GL ACC
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::" ",
//         GenJournalLine."account type"::"G/L Account", GenSetUp."Dividend Process Fee Account", PostingDate, GenSetUp."Dividend Processing Fee" * -1, 'BOSA', '',
//         'Processing Fee- ' + Format(PostingDate), '');
//         DividendAmount := DividendAmount - GenSetUp."Dividend Processing Fee";

//         // //###### 5.1 DEBIT M-WALLET ON EXCISE DUTY ON PROCESSING FEE 
//         // LineNo := LineNo + 10000;
//         // SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         // GenJournalLine."account type"::Vendor, walletAccount, PostingDate, ExciseDuty, 'BOSA', '',
//         // 'Excise on DivProcessing Fee ' + MemberNo, '');
//         // //###### 5.2 CREDIT EXCISE DUTY GL ACC
//         // LineNo := LineNo + 10000;
//         // SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::" ",
//         // GenJournalLine."account type"::"G/L Account", GenSetUp."Dividend Process Fee Account", PostingDate, ExciseDuty * -1, 'BOSA', '',
//         // 'Excise on DivProcessing Fee ' + Format(PostingDate), '');
//         // DividendAmount := DividendAmount - ExciseDuty;

//         //handle arrears
//         loanRecovered := 0;
//         if loanArrears > 0 then begin

//             loanRecovered := ApplyDividendToLoanArrears(MemberNo, DividendAmount, PostingDate);

//         end;

//         /////######## 2.1 CREDIT M-WALLET ACC
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."Account Type"::Vendor, walletAccount, PostingDate, (GrossTotalDiv - loanRecovered) * -1, 'BOSA', '',
//         'Net Dividend and Interest on Deposits ' + Format(YearCalc), '');
//         //#########  2.2 DEBIT MEMBER DIVIDEND
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, MemberNo, PostingDate, (GrossTotalDiv - loanRecovered), 'BOSA', '',
//         'Net Dividend and Interest on Deposits transfered to M-Wallet  ' + Format(PostingDate), '');

//     end;

//     local procedure ApplyDividendToLoanArrears(MemberNo: Code[20]; DividendAmount: Decimal; PostingDate: Date) loanRecovered: Decimal
//     var
//         LoansRegister: Record "Loans Register";
//         AmountToPay: Decimal;
//     begin
//         loanRecovered := 0;
//         if DividendAmount <= 0 then
//             exit;

//         LoansRegister.Reset();
//         LoansRegister.SetRange("Client Code", MemberNo);
//         LoansRegister.SetFilter("Amount in Arrears", '>0');

//         // Sort by highest arrears first
//         LoansRegister.SetCurrentKey("Amount in Arrears");
//         LoansRegister.SetAscending("Amount in Arrears", false);

//         if LoansRegister.FindSet() then
//             repeat
//                 LoansRegister.CalcFields("Oustanding Interest", "Amount in Arrears");

//                 if DividendAmount <= 0 then
//                     exit;

//                 if LoansRegister."Oustanding Interest" > 0 then begin

//                     if DividendAmount >= LoansRegister."Oustanding Interest" then
//                         AmountToPay := LoansRegister."Oustanding Interest"
//                     else
//                         AmountToPay := DividendAmount;

//                     PostInterestRepayment(
//                         LoansRegister."Loan  No.",
//                         MemberNo,
//                         AmountToPay,
//                         PostingDate
//                     );
//                     loanRecovered := loanRecovered + AmountToPay;
//                     DividendAmount := DividendAmount - AmountToPay;
//                 end;

//                 if DividendAmount <= 0 then
//                     exit;

//                 if LoansRegister."Amount in Arrears" > 0 then begin
//                     // Determine amount to clear
//                     if DividendAmount >= LoansRegister."Amount in Arrears" then
//                         AmountToPay := LoansRegister."Amount in Arrears"
//                     else
//                         AmountToPay := DividendAmount;
//                     //proceed to repay the Loan Amount now
//                     PostLoanRepayment(
//                        LoansRegister."Loan  No.",
//                        MemberNo,
//                        AmountToPay,
//                        PostingDate
//                    );
//                     loanRecovered := loanRecovered + AmountToPay;
//                     // Reduce remaining dividend
//                     DividendAmount := DividendAmount - AmountToPay;
//                 end;

//             until LoansRegister.Next() = 0;
//     end;

//     local procedure PostInterestRepayment(loanNumber: Code[20]; memberNumber: Code[20]; AmountToPay: Decimal; PostingDate: Date)
//     var
//     begin
//         //###### 6.1 DEBIT M-WALLET ON loan interest recovery 
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, memberNumber, PostingDate, AmountToPay, 'BOSA', '',
//         'Loan interest Arrears recovered from Dividends ' + memberNumber, '');

//         //###### 6.2 CREDIT loan interest
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::"Interest Paid",
//         GenJournalLine."account type"::Customer, memberNumber, PostingDate, AmountToPay * -1, 'BOSA', '',
//         'Loan interest Arrears recovered from Dividends ' + Format(PostingDate), loanNumber);
//     end;

//     local procedure PostLoanRepayment(loanNumber: Code[20]; memberNumber: Code[20]; AmountToPay: Decimal; PostingDate: Date)
//     var
//     begin
//         //###### 7.1 DEBIT M-WALLET ON loan recovery 
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::Dividend,
//         GenJournalLine."account type"::Customer, memberNumber, PostingDate, AmountToPay, 'BOSA', '',
//         'Loan Arrears recovered from Dividends ' + memberNumber, '');
//         //###### 7.2 CREDIT loan repayment
//         LineNo := LineNo + 10000;
//         SFactory.FnCreateGnlJournalLine('PAYMENTS', 'DIVIDEND', 'DIV ' + Format(YearCalc), LineNo, GenJournalLine."transaction type"::"Loan Repayment",
//         GenJournalLine."account type"::Customer, memberNumber, PostingDate, AmountToPay * -1, 'BOSA', '',
//         'Loan Arrears recovered from Dividends ' + Format(PostingDate), loanNumber);
//     end;

// }
