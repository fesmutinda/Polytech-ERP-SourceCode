
page 57006 "Polytech Checkoff Card"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Polytech Checkoff Header";
    SourceTableView = where(Posted = const(false));

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Date Entered"; Rec."Date Entered")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Loan CutOff Date"; Rec."Loan CutOff Date")
                {
                    ApplicationArea = Basic;
                }
                field(Remarks; Rec.Remarks)
                {
                    ApplicationArea = Basic;
                }
                field("Total Count"; Rec."Total Count")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                    Visible = true;
                }
                field("Account No"; Rec."Account No")
                {
                    //Caption = 'Receiving Bank';
                    ApplicationArea = Basic;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = Basic;
                    // Editable = false;
                }
                field("Employer Name"; Rec."Employer Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }

                field(Amount; Rec.Amount)
                {
                    Caption = 'Cheque Amount';
                    ApplicationArea = Basic;
                }
                field("Scheduled Amount"; Rec."Scheduled Amount")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Total Welfare"; Rec."Total Welfare")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Entered By"; Rec."Entered By")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                }
            }
            part("Bosa receipt lines"; "Polytech CheckoffLines")
            {
                SubPageLink = "Receipt Header No" = field(No);
            }
        }
    }
    actions
    {
        area(processing)
        {
            // 1. Import Checkoff
            action(ImportItems)
            {
                Caption = 'Import CheckOff';
                Promoted = true;
                PromotedCategory = Process;
                Image = Import;
                ApplicationArea = All;

                RunObject = xmlport "Polytech Checkoff Import";
            }
            // 2. Validate Receipts
            action("Validate Receipts")
            {
                ApplicationArea = Basic;
                Caption = 'Validate Receipts';
                Image = ValidateEmailLoggingSetup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    RcptBufLines.Reset;
                    RcptBufLines.SetRange(RcptBufLines."Receipt Header No", Rec.No);
                    if RcptBufLines.Find('-') then begin
                        repeat

                            Memb.Reset;
                            Memb.SetRange(Memb."Personal No", RcptBufLines."Staff/Payroll No");
                            //Memb.SETRANGE(Memb."Employer Code",RcptBufLines."Employer Code");
                            if Memb.Find('-') then begin

                                RcptBufLines."Member No" := Memb."No.";
                                RcptBufLines.Name := Memb.Name;
                                RcptBufLines."ID No." := Memb."ID No.";
                                RcptBufLines."Member Found" := true;
                                RcptBufLines.Modify;
                            end;
                        until RcptBufLines.Next = 0;
                    end;
                    Message('Successfully validated');
                end;
            }
            // 3. Refresh Page
            action(RefreshPage)
            {
                Caption = 'Refresh page';
                Promoted = true;
                PromotedCategory = Process;
                Image = Refresh;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    // Message('Refreshing...');
                    CurrPage.Update; // Refresh the current page UI
                    Rec.Validate("Scheduled Amount");
                    FnValidateMembers();
                    FnValidateAmounts();
                    Rec.UpdateTotalAmount();
                    Rec.Modify(true);
                    Message('Page refreshed and data updated.');
                end;
            }
            // 4. Post Checkoff
            action("Post check off")
            {
                ApplicationArea = Basic;
                Caption = 'Post check off';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;
                // PromotedIsBig = true;

                trigger OnAction()
                var
                    UsersID: Record User;
                    FundsUSer: Record "Funds User Setup";
                    GenJnlManagement: Codeunit GenJnlManagement;
                    GenBatch: Record "Gen. Journal Batch";
                    dialogBox: Dialog;
                begin
                    Rec.SetRange(Rec.No);
                    genstup.Get();
                    if Rec.Posted = true then
                        Error('This Check Off has already been posted');
                    if Rec."Account No" = '' then
                        Error('You must specify the Account No.');
                    if Rec."Document No" = '' then
                        Error('You must specify the Document No.');
                    if Rec."Posting date" = 0D then
                        Error('You must specify the Posting date.');
                    if Rec."Posting date" = 0D then
                        Error('You must specify the Posting date.');
                    if Rec."Loan CutOff Date" = 0D then
                        Error('You must specify the Loan CutOff Date.');
                    Datefilter := '..' + Format(Rec."Loan CutOff Date");
                    IssueDate := Rec."Loan CutOff Date";
                    //General Journals
                    // if FundsUSer.Get(UserId) then begin
                    Jtemplate := 'GENERAL';
                    Jbatch := 'CHECKOFF';
                    // end;
                    //Delete journal
                    Gnljnline.Reset;
                    Gnljnline.SetRange("Journal Template Name", Jtemplate);
                    Gnljnline.SetRange("Journal Batch Name", Jbatch);
                    if Gnljnline.Find('-') then begin
                        Gnljnline.DeleteAll;
                    end;

                    // Rec.CalcFields("Scheduled Amount");
                    if Rec."Scheduled Amount" <> Rec.Amount then begin
                        ERROR('Scheduled Amount Is Not Equal To Cheque Amount');
                    end;

                    Rec.Validate("Scheduled Amount");
                    LineN := LineN + 10000;
                    Gnljnline.Init;
                    Gnljnline."Journal Template Name" := Jtemplate;
                    Gnljnline."Journal Batch Name" := Jbatch;
                    Gnljnline."Line No." := LineN;
                    Gnljnline."Account Type" := Rec."Account Type";//Gnljnline."Account Type"::"Bank Account";// Rec."Account Type";
                    Gnljnline."Account No." := Rec."Account No";
                    Gnljnline.Validate(Gnljnline."Account No.");
                    Gnljnline."Document No." := Rec."Document No";
                    Gnljnline."Posting Date" := Rec."Posting date";
                    Gnljnline.Description := 'CHECKOFF ' + Rec.Remarks;
                    Gnljnline.Amount := (Rec."Scheduled Amount" - Rec."Total Welfare");
                    Gnljnline.Validate(Gnljnline.Amount);
                    Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                    Gnljnline."Shortcut Dimension 2 Code" := 'NAIROBI';
                    Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                    Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                    if Gnljnline.Amount <> 0 then
                        Gnljnline.Insert(true);
                    //End Of control


                    RcptBufLines.Reset;
                    RcptBufLines.SetRange(RcptBufLines."Receipt Header No", Rec.No);
                    RcptBufLines.SetRange(RcptBufLines.Posted, false);
                    if RcptBufLines.Find('-') then begin
                        repeat
                            dialogBox.Open('Processing Check Off for ' + Format(RcptBufLines."Member No") + ': ' + RcptBufLines.Name + '...');
                            LineN := LineN + 10000;
                            //Share_Capital
                            if RcptBufLines."Share Capital" > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Share Capital - Checkoff',
                                                            RcptBufLines."Share Capital",
                                                            GenJournalLine."Transaction Type"::"Share Capital"
                                                            );
                            end;
                            //Deposit_Contribution
                            if RcptBufLines."Deposit Contribution" > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Deposit Contribution Checkoff',
                                                            RcptBufLines."Deposit Contribution",
                                                            GenJournalLine."Transaction Type"::"Deposit Contribution"
                                                            );
                            end;
                            //New Welfare Contribution
                            if RcptBufLines."Welfare Contribution" > 0 then begin
                                FnInsertWelfareContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Welfare contribution for ' + RcptBufLines."Member No",
                                                            RcptBufLines."Welfare Contribution",
                                                            GenJournalLine."Transaction Type"::"Welfare Contribution"
                                                            );
                            end;
                            // if RcptBufLines."Welfare Contribution" > 0 then begin
                            //     FnInsertWelfareCreditBank(Jtemplate,
                            //                                 Jbatch,
                            //                                 RcptBufLines."Member No",
                            //                                 Rec."Document No",
                            //                                 'Welfare Checkoff Polytech',
                            //                                 RcptBufLines."Welfare Contribution",
                            //                                 GenJournalLine."Transaction Type"::"Welfare Contribution"
                            //                                 );
                            // end;
                            if RcptBufLines."Welfare Contribution" > 0 then begin
                                FnInsertWelfareCommisionCredit(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Welfare Polytech Comm',
                                                            20,
                                                            GenJournalLine."Transaction Type"::"Welfare Contribution"
                                                            );
                            end;
                            if RcptBufLines."Welfare Contribution" > 0 then begin
                                FnInsertWelfareAccountCredit(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Welfare contribution for ' + RcptBufLines."Member No",
                                                            300,
                                                            GenJournalLine."Transaction Type"::"Welfare Contribution"
                                                            );
                            end;
                            //Benevolent
                            if RcptBufLines.Benevolent > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Benevolent Fund - Checkoff',
                                                            RcptBufLines.Benevolent,
                                                            GenJournalLine."Transaction Type"::"Benevolent Fund"
                                                            );
                            end;
                            //Insurance
                            if RcptBufLines.Insurance > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Insurance Contribution ChkOff',
                                                            RcptBufLines.Insurance,
                                                            GenJournalLine."Transaction Type"::"Insurance Contribution"
                                                            );
                            end;
                            //Registration
                            if RcptBufLines.Registration > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Registration Fee - Checkoff',
                                                            RcptBufLines.Registration,
                                                            GenJournalLine."Transaction Type"::"Registration Fee"
                                                            );
                            end;
                            //Holiday
                            if RcptBufLines.Holiday > 0 then begin
                                FnInsertMemberContribution(Jtemplate,
                                                            Jbatch,
                                                            RcptBufLines."Member No",
                                                            Rec."Document No",
                                                            'Holiday Savings - Checkoff',
                                                            RcptBufLines.Holiday,
                                                            GenJournalLine."Transaction Type"::"Holiday Savings"
                                                            );
                            end;
                            //Add Loan lines...Festus
                            FnPostLoansBal();

                            dialogBox.Close();

                        until RcptBufLines.Next = 0;
                    end;

                    // Reinitialize the record and open the journal page
                    Gnljnline.Reset();
                    Gnljnline.SetRange("Journal Template Name", Jtemplate);
                    Gnljnline.SetRange("Journal Batch Name", Jbatch);
                    if Gnljnline.Find('-') then begin
                        Page.Run(page::"General Journal", Gnljnline);
                        Message('CheckOff Successfully Generated');
                    end;


                end;
            }
            // 5. Mark as Posted
            action("Processed Checkoff")
            {
                Caption = 'Mark as Posted';
                ApplicationArea = Basic;
                Image = POST;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to mark this Checkoff as Processed', false) = true then begin
                        Rec.Posted := true;
                        Rec."Posted By" := UserId;
                        Rec.Modify;
                        CurrPage.close();
                    end;
                end;
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec."Posting date" := Today;
        Rec."Date Entered" := Today;
    end;

    var
        Gnljnline: Record "Gen. Journal Line";
        GenJournalLine: Record "Gen. Journal Line";
        PDate: Date;
        DocNo: Code[20];
        // RunBal: Decimal;
        emergencyLoan12Balance: Decimal;
        emergencyLoan13Balance: Decimal;
        quickLoanBalance: Decimal;
        superQuickLoanBalance: Decimal;
        schoolFeesLoanBalance: Decimal;
        superSchoolFeesLoanBalance: Decimal;
        investmentLoanBalance: Decimal;
        normal20LoanBalance: Decimal;
        normal21LoanBalance: Decimal;
        normal22LoanBalance: Decimal;
        development23LoanBalance: Decimal;
        development25LoanBalance: Decimal;
        merchandiseLoanBalance: Decimal;
        welfarecontributionbalance: Decimal;
        ReceiptsProcessingLines: Record "Polytech CheckoffLines";
        // LineNo: Integer;
        LBatches: Record "Loan Disburesment-Batching";
        Jtemplate: Code[30];
        JBatch: Code[30];
        "Cheque No.": Code[20];
        DActivityBOSA: Code[20];
        DBranchBOSA: Code[20];
        ReptProcHeader: Record "Polytech Checkoff Header";
        Cust: Record Customer;
        MembPostGroup: Record "Customer Posting Group";
        Loantable: Record "Loans Register";
        LRepayment: Decimal;
        RcptBufLines: Record "Polytech CheckoffLines";
        AmountToDeduct: Decimal;
        WelfareAmount: Decimal;
        CommissionAmount: Decimal;
        LoanType: Record "Loan Products Setup";
        LoanApp: Record "Loans Register";
        Interest: Decimal;
        LineN: Integer;
        TotalRepay: Decimal;
        MultipleLoan: Integer;
        LType: Text;
        MonthlyAmount: Decimal;
        ShRec: Decimal;
        SHARESCAP: Decimal;
        DIFF: Decimal;
        DIFFPAID: Decimal;
        genstup: Record "Sacco General Set-Up";
        Memb: Record Customer;
        INSURANCE: Decimal;
        GenBatches: Record "Gen. Journal Batch";
        Datefilter: Text[50];
        ReceiptLine: Record "Polytech CheckoffLines";
        XMAS: Decimal;
        MemberRec: Record Customer;
        Vendor: Record Vendor;
        IssueDate: Date;
        startDate: Date;
        TotalWelfareAmount: Decimal;
        LoanRepS: Record "Loan Repayment Schedule";
        MonthlyRepay: Decimal;
        cm: Date;
        mm: Code[10];
        Lschedule: Record "Loan Repayment Schedule";
        ScheduleRepayment: Decimal;

    local procedure FnValidateMembers()
    var
    begin
        RcptBufLines.Reset;
        RcptBufLines.SetRange(RcptBufLines."Receipt Header No", Rec.No);
        if RcptBufLines.Find('-') then begin
            repeat

                Memb.Reset;
                Memb.SetRange(Memb."Personal No", RcptBufLines."Staff/Payroll No");
                //Memb.SETRANGE(Memb."Employer Code",RcptBufLines."Employer Code");
                if Memb.Find('-') then begin

                    RcptBufLines."Member No" := Memb."No.";
                    RcptBufLines.Name := Memb.Name;
                    RcptBufLines."ID No." := Memb."ID No.";
                    RcptBufLines."Member Found" := true;
                    RcptBufLines.Modify;
                end;
            until RcptBufLines.Next = 0;
        end;
    end;

    local procedure FnValidateAmounts()
    var
    begin

    end;

    local procedure FnPostLoans()
    var
        loanNumber: Code[50];
        balance: Decimal;
    begin
        //Emergency_Loan_12_
        emergencyLoan12Balance := 0;
        emergencyLoan12Balance := RcptBufLines."Emergency Loan 12 Amount";
        if emergencyLoan12Balance > 0 then begin
            balance := RcptBufLines."Emergency Loan 12 Amount";
            loanNumber := fnGetLoanNumber(RcptBufLines, balance, Rec."Loan CutOff Date", '12');
            balance := FnPostInterestBal(RcptBufLines, balance, Rec."Loan CutOff Date", '12', loanNumber);
            FnPostPrincipleBal(RcptBufLines, balance, loanNumber);
            // loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Emergency Loan 12 Principle", Rec."Loan CutOff Date", '12');
            // FnPostInterest(RcptBufLines, RcptBufLines."Emergency Loan 12 Interest", Rec."Loan CutOff Date", '12', loanNumber);
            // FnPostPrinciple(RcptBufLines, RcptBufLines."Emergency Loan 12 Principle", Rec."Loan CutOff Date", '12');
        end;
        //Super_Emergency_Loan_13_
        emergencyLoan13Balance := 0;
        emergencyLoan13Balance := RcptBufLines."Super Emergency Loan 13 Amount";
        if emergencyLoan13Balance > 0 then begin
            balance := RcptBufLines."Emergency Loan 12 Amount";
            loanNumber := fnGetLoanNumber(RcptBufLines, balance, Rec."Loan CutOff Date", '13');
            balance := FnPostInterestBal(RcptBufLines, balance, Rec."Loan CutOff Date", '13', loanNumber);
            FnPostPrincipleBal(RcptBufLines, balance, loanNumber);
            // loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Super Emergency Loan 13 Principle", Rec."Loan CutOff Date", '13');
            // FnPostInterest(RcptBufLines, RcptBufLines."Super Emergency Loan 13 Interest", Rec."Loan CutOff Date", '13', loanNumber);
        end;
        //Quick_Loan_
        quickLoanBalance := 0;
        quickLoanBalance := RcptBufLines."Quick Loan Amount";
        if quickLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Quick Loan Principle", Rec."Loan CutOff Date", '15');
            FnPostInterest(RcptBufLines, RcptBufLines."Quick Loan Interest", Rec."Loan CutOff Date", '15', loanNumber);
        end;
        //Super_Quick_Loan_loan
        superQuickLoanBalance := 0;
        superQuickLoanBalance := RcptBufLines."Super Quick Amount";
        if superQuickLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Super Quick Principle", Rec."Loan CutOff Date", '16');
            FnPostInterest(RcptBufLines, RcptBufLines."Super Quick Interest", Rec."Loan CutOff Date", '16', loanNumber);
        end;
        //School_fees_loan
        schoolFeesLoanBalance := 0;
        schoolFeesLoanBalance := RcptBufLines."School Fees Amount";
        if schoolFeesLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."School Fees Principle", Rec."Loan CutOff Date", '17');
            FnPostInterest(RcptBufLines, RcptBufLines."School Fees Interest", Rec."Loan CutOff Date", '17', loanNumber);
        end;
        //Super_school_fees_
        superSchoolFeesLoanBalance := 0;
        superSchoolFeesLoanBalance := RcptBufLines."Super School Fees Amount";
        if superSchoolFeesLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Super School Fees Principle", Rec."Loan CutOff Date", '18');
            FnPostInterest(RcptBufLines, RcptBufLines."Super School Fees Interest", Rec."Loan CutOff Date", '18', loanNumber);
        end;
        //Investment_Loan_
        investmentLoanBalance := 0;
        investmentLoanBalance := RcptBufLines."Investment Loan Amount";
        if investmentLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Investment Loan Principle", Rec."Loan CutOff Date", '19');
            FnPostInterest(RcptBufLines, RcptBufLines."Investment Loan Interest", Rec."Loan CutOff Date", '19', loanNumber);
        end;
        //Normal_loan_20_
        normal20LoanBalance := 0;
        normal20LoanBalance := RcptBufLines."Normal loan 20 Amount";
        if normal20LoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Normal loan 20 Principle", Rec."Loan CutOff Date", '20');
            FnPostInterest(RcptBufLines, RcptBufLines."Normal loan 20 Interest", Rec."Loan CutOff Date", '20', loanNumber);
        end;
        //Normal_loan_21_
        normal21LoanBalance := 0;
        normal21LoanBalance := RcptBufLines."Normal loan 21 Amount";
        if normal21LoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Normal loan 21 Principle", Rec."Loan CutOff Date", '21');
            FnPostInterest(RcptBufLines, RcptBufLines."Normal loan 21 Interest", Rec."Loan CutOff Date", '21', loanNumber);
        end;
        //Normal_loan_22_
        normal22LoanBalance := 0;
        normal22LoanBalance := RcptBufLines."Normal loan 22 Amount";
        if normal22LoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Normal loan 22 Principle", Rec."Loan CutOff Date", '22');
            FnPostInterest(RcptBufLines, RcptBufLines."Normal loan 22 Interest", Rec."Loan CutOff Date", '22', loanNumber);
        end;
        //Development_Loan_23_
        development23LoanBalance := 0;
        development23LoanBalance := RcptBufLines."Development Loan 23 Amount";
        if development23LoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Development Loan 23 Principle", Rec."Loan CutOff Date", '23');
            FnPostInterest(RcptBufLines, RcptBufLines."Development Loan 23 Interest", Rec."Loan CutOff Date", '23', loanNumber);
        end;

        //Development_Loan_25_
        development25LoanBalance := 0;
        development25LoanBalance := RcptBufLines."Development Loan 25 Amount";
        if development25LoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Development Loan 25 Principle", Rec."Loan CutOff Date", '25');
            FnPostInterest(RcptBufLines, RcptBufLines."Development Loan 25 Interest", Rec."Loan CutOff Date", '25', loanNumber);
        end;
        //Merchandise_Loan_26_
        merchandiseLoanBalance := 0;
        merchandiseLoanBalance := RcptBufLines."Merchandise Loan 26 Amount";
        if merchandiseLoanBalance > 0 then begin
            loanNumber := FnPostPrinciple(RcptBufLines, RcptBufLines."Merchandise Loan 26 Principle", Rec."Loan CutOff Date", '26');
            FnPostInterest(RcptBufLines, RcptBufLines."Merchandise Loan 26 Interest", Rec."Loan CutOff Date", '26', loanNumber);
        end;
    end;

    local procedure FnPostLoansBal()
    var
        loanNumber: Code[50];
    // balance: Decimal;
    begin
        //Emergency_Loan_12_
        emergencyLoan12Balance := 0;
        emergencyLoan12Balance := RcptBufLines."Emergency Loan 12 Amount";
        if emergencyLoan12Balance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, emergencyLoan12Balance, Rec."Loan CutOff Date", '12');
            emergencyLoan12Balance := FnPostInterestBal(RcptBufLines, emergencyLoan12Balance, Rec."Loan CutOff Date", '12', loanNumber);
            emergencyLoan12Balance := FnPostPrincipleBal2(RcptBufLines, emergencyLoan12Balance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, emergencyLoan12Balance, 'Excess Payments for Emergency Loan 12');
        end;
        //Super_Emergency_Loan_13_
        emergencyLoan13Balance := 0;
        emergencyLoan13Balance := RcptBufLines."Super Emergency Loan 13 Amount";
        if emergencyLoan13Balance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, emergencyLoan13Balance, Rec."Loan CutOff Date", '13');
            emergencyLoan13Balance := FnPostInterestBal(RcptBufLines, emergencyLoan13Balance, Rec."Loan CutOff Date", '13', loanNumber);
            emergencyLoan13Balance := FnPostPrincipleBal2(RcptBufLines, emergencyLoan13Balance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, emergencyLoan13Balance, 'Excess Payments for Super Emergency Loan 13');
        end;
        //Quick_Loan_
        quickLoanBalance := 0;
        quickLoanBalance := RcptBufLines."Quick Loan Amount";
        if quickLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, quickLoanBalance, Rec."Loan CutOff Date", '15');
            quickLoanBalance := FnPostInterestBal(RcptBufLines, quickLoanBalance, Rec."Loan CutOff Date", '15', loanNumber);
            quickLoanBalance := FnPostPrincipleBal2(RcptBufLines, quickLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, quickLoanBalance, 'Excess Payments for Quick 15');
        end;
        //Super_Quick_Loan_loan
        superQuickLoanBalance := 0;
        superQuickLoanBalance := RcptBufLines."Super Quick Amount";
        if superQuickLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, superQuickLoanBalance, Rec."Loan CutOff Date", '16');
            superQuickLoanBalance := FnPostInterestBal(RcptBufLines, superQuickLoanBalance, Rec."Loan CutOff Date", '16', loanNumber);
            superQuickLoanBalance := FnPostPrincipleBal2(RcptBufLines, superQuickLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, superQuickLoanBalance, 'Excess Payments for Super Quick 16');
        end;
        //School_fees_loan
        schoolFeesLoanBalance := 0;
        schoolFeesLoanBalance := RcptBufLines."School Fees Amount";
        if schoolFeesLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, schoolFeesLoanBalance, Rec."Loan CutOff Date", '17');
            schoolFeesLoanBalance := FnPostInterestBal(RcptBufLines, schoolFeesLoanBalance, Rec."Loan CutOff Date", '17', loanNumber);
            schoolFeesLoanBalance := FnPostPrincipleBal2(RcptBufLines, schoolFeesLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, schoolFeesLoanBalance, 'Excess Payments for School Fee 17');
        end;
        //Super_school_fees_
        superSchoolFeesLoanBalance := 0;
        superSchoolFeesLoanBalance := ROUND(RcptBufLines."Super School Fees Amount", 1, '=');
        if superSchoolFeesLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, superSchoolFeesLoanBalance, Rec."Loan CutOff Date", '18');
            superSchoolFeesLoanBalance := FnPostInterestBal(RcptBufLines, superSchoolFeesLoanBalance, Rec."Loan CutOff Date", '18', loanNumber);
            superSchoolFeesLoanBalance := FnPostPrincipleBal2(RcptBufLines, superSchoolFeesLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, superSchoolFeesLoanBalance, 'Excess Payments for Super School Fee 18');
        end;
        //Investment_Loan_
        investmentLoanBalance := 0;
        investmentLoanBalance := RcptBufLines."Investment Loan Amount";
        if investmentLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, investmentLoanBalance, Rec."Loan CutOff Date", '19');
            investmentLoanBalance := FnPostInterestBal(RcptBufLines, investmentLoanBalance, Rec."Loan CutOff Date", '19', loanNumber);
            investmentLoanBalance := FnPostPrincipleBal2(RcptBufLines, investmentLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, investmentLoanBalance, 'Excess Payments for Investment Loan 19');
        end;
        //Normal_loan_20_
        normal20LoanBalance := 0;
        normal20LoanBalance := RcptBufLines."Normal loan 20 Amount";
        if normal20LoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, normal20LoanBalance, Rec."Loan CutOff Date", '20');
            normal20LoanBalance := FnPostInterestBal(RcptBufLines, normal20LoanBalance, Rec."Loan CutOff Date", '20', loanNumber);
            normal20LoanBalance := FnPostPrincipleBal2(RcptBufLines, normal20LoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal20LoanBalance, 'Excess Payments for Normal loan 20');
        end;
        //Normal_loan_21_
        normal21LoanBalance := 0;
        normal21LoanBalance := RcptBufLines."Normal loan 21 Amount";
        if normal21LoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, normal21LoanBalance, Rec."Loan CutOff Date", '21');
            normal21LoanBalance := FnPostInterestBal(RcptBufLines, normal21LoanBalance, Rec."Loan CutOff Date", '21', loanNumber);
            normal21LoanBalance := FnPostPrincipleBal2(RcptBufLines, normal21LoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal21LoanBalance, 'Excess Payments for Normal loan 21');
        end;
        //Normal_loan_22_
        normal22LoanBalance := 0;
        normal22LoanBalance := RcptBufLines."Normal loan 22 Amount";
        if normal22LoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, normal22LoanBalance, Rec."Loan CutOff Date", '22');
            normal22LoanBalance := FnPostInterestBal(RcptBufLines, normal22LoanBalance, Rec."Loan CutOff Date", '22', loanNumber);
            normal22LoanBalance := FnPostPrincipleBal2(RcptBufLines, normal22LoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal22LoanBalance, 'Excess Payments for Normal loan 22');
        end;
        //Development_Loan_23_
        development23LoanBalance := 0;
        development23LoanBalance := RcptBufLines."Development Loan 23 Amount";
        if development23LoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, development23LoanBalance, Rec."Loan CutOff Date", '23');
            development23LoanBalance := FnPostInterestBal(RcptBufLines, development23LoanBalance, Rec."Loan CutOff Date", '23', loanNumber);
            development23LoanBalance := FnPostPrincipleBal2(RcptBufLines, development23LoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, development23LoanBalance, 'Excess Payments for Development Loan 23');
        end;

        //Development_Loan_25_
        development25LoanBalance := 0;
        development25LoanBalance := RcptBufLines."Development Loan 25 Amount";
        if development25LoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, development25LoanBalance, Rec."Loan CutOff Date", '25');
            development25LoanBalance := FnPostInterestBal(RcptBufLines, development25LoanBalance, Rec."Loan CutOff Date", '25', loanNumber);
            development25LoanBalance := FnPostPrincipleBal2(RcptBufLines, development25LoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, development25LoanBalance, 'Excess Payments for Development Loan 25');
        end;
        //Merchandise_Loan_26_
        merchandiseLoanBalance := 0;
        merchandiseLoanBalance := RcptBufLines."Merchandise Loan 26 Amount";
        if merchandiseLoanBalance > 0 then begin

            loanNumber := fnGetLoanNumber(RcptBufLines, merchandiseLoanBalance, Rec."Loan CutOff Date", '26');
            merchandiseLoanBalance := FnPostInterestBal(RcptBufLines, merchandiseLoanBalance, Rec."Loan CutOff Date", '26', loanNumber);
            merchandiseLoanBalance := FnPostPrincipleBal2(RcptBufLines, merchandiseLoanBalance, loanNumber);

            FnTransferExcessToUnallocatedFunds(RcptBufLines, merchandiseLoanBalance, 'Excess Payments for Merchandise Loan 26');
        end;
    end;

    local procedure FnPostLoansandUnallocated()
    var
    begin
        //Emergency_Loan_12_
        emergencyLoan12Balance := 0;
        emergencyLoan12Balance := RcptBufLines."Emergency Loan 12 Amount";
        if emergencyLoan12Balance > 0 then begin
            emergencyLoan12Balance := FnRunInterest(RcptBufLines, emergencyLoan12Balance, Rec."Loan CutOff Date", '12');
            emergencyLoan12Balance := FnRunPrinciple(RcptBufLines, emergencyLoan12Balance, Rec."Loan CutOff Date", '12');
            //emergencyLoan12Balance := FnRunLoanRepayment(RcptBufLines, emergencyLoan12Balance, Rec."Loan CutOff Date", '12');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, emergencyLoan12Balance, 'Excess Payments for Emergency Loan 12');
        end;
        //Super_Emergency_Loan_13_
        emergencyLoan13Balance := 0;
        emergencyLoan13Balance := RcptBufLines."Super Emergency Loan 13 Amount";
        if emergencyLoan13Balance > 0 then begin
            emergencyLoan13Balance := FnRunInterest(RcptBufLines, emergencyLoan13Balance, Rec."Loan CutOff Date", '13');
            emergencyLoan13Balance := FnRunPrinciple(RcptBufLines, emergencyLoan13Balance, Rec."Loan CutOff Date", '13');
            //emergencyLoan13Balance := FnRunLoanRepayment(RcptBufLines, emergencyLoan13Balance, Rec."Loan CutOff Date", '13');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, emergencyLoan13Balance, 'Excess Payments for Super Emergency Loan 13');
        end;
        //Quick_Loan_
        quickLoanBalance := 0;
        quickLoanBalance := RcptBufLines."Quick Loan Amount";
        if quickLoanBalance > 0 then begin
            quickLoanBalance := FnRunInterest(RcptBufLines, quickLoanBalance, Rec."Loan CutOff Date", '15');
            quickLoanBalance := FnRunPrinciple(RcptBufLines, quickLoanBalance, Rec."Loan CutOff Date", '15');
            //quickLoanBalance := FnRunLoanRepayment(RcptBufLines, quickLoanBalance, Rec."Loan CutOff Date", '15');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, quickLoanBalance, 'Excess Payments for Quick Loan 15');
        end;
        //Super_Quick_Loan_loan
        superQuickLoanBalance := 0;
        superQuickLoanBalance := RcptBufLines."Super Quick Amount";
        if superQuickLoanBalance > 0 then begin
            superQuickLoanBalance := FnRunInterest(RcptBufLines, superQuickLoanBalance, Rec."Loan CutOff Date", '16');
            superQuickLoanBalance := FnRunPrinciple(RcptBufLines, superQuickLoanBalance, Rec."Loan CutOff Date", '16');
            //superQuickLoanBalance := FnRunLoanRepayment(RcptBufLines, superQuickLoanBalance, Rec."Loan CutOff Date", '16');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, superQuickLoanBalance, 'Excess Payments for Super Quick Loan 16');
        end;
        //School_fees_loan
        schoolFeesLoanBalance := 0;
        schoolFeesLoanBalance := RcptBufLines."School Fees Amount";
        if schoolFeesLoanBalance > 0 then begin
            schoolFeesLoanBalance := FnRunInterest(RcptBufLines, schoolFeesLoanBalance, Rec."Loan CutOff Date", '17');
            schoolFeesLoanBalance := FnRunPrinciple(RcptBufLines, schoolFeesLoanBalance, Rec."Loan CutOff Date", '17');
            //schoolFeesLoanBalance := FnRunLoanRepayment(RcptBufLines, schoolFeesLoanBalance, Rec."Loan CutOff Date", '17');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, schoolFeesLoanBalance, 'Excess Payments for School Fees Loan 17');
        end;
        //Super_school_fees_
        superSchoolFeesLoanBalance := 0;
        superSchoolFeesLoanBalance := RcptBufLines."Super School Fees Amount";
        if superSchoolFeesLoanBalance > 0 then begin
            superSchoolFeesLoanBalance := FnRunInterest(RcptBufLines, superSchoolFeesLoanBalance, Rec."Loan CutOff Date", '18');
            superSchoolFeesLoanBalance := FnRunPrinciple(RcptBufLines, superSchoolFeesLoanBalance, Rec."Loan CutOff Date", '18');
            //superSchoolFeesLoanBalance := FnRunLoanRepayment(RcptBufLines, superSchoolFeesLoanBalance, Rec."Loan CutOff Date", '18');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, superSchoolFeesLoanBalance, 'Excess Payments for Super School Fees Loan 18');
        end;
        //Investment_Loan_
        investmentLoanBalance := 0;
        investmentLoanBalance := RcptBufLines."Investment Loan Amount";
        if investmentLoanBalance > 0 then begin
            investmentLoanBalance := FnRunInterest(RcptBufLines, investmentLoanBalance, Rec."Loan CutOff Date", '19');
            investmentLoanBalance := FnRunPrinciple(RcptBufLines, investmentLoanBalance, Rec."Loan CutOff Date", '19');
            //investmentLoanBalance := FnRunLoanRepayment(RcptBufLines, investmentLoanBalance, Rec."Loan CutOff Date", '19');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, investmentLoanBalance, 'Excess Payments for Investment Loan 19');
        end;
        //Normal_loan_20_
        normal20LoanBalance := 0;
        normal20LoanBalance := RcptBufLines."Normal loan 20 Amount";
        if normal20LoanBalance > 0 then begin
            normal20LoanBalance := FnRunInterest(RcptBufLines, normal20LoanBalance, Rec."Loan CutOff Date", '20');
            normal20LoanBalance := FnRunPrinciple(RcptBufLines, normal20LoanBalance, Rec."Loan CutOff Date", '20');
            //normal20LoanBalance := FnRunLoanRepayment(RcptBufLines, normal20LoanBalance, Rec."Loan CutOff Date", '20');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal20LoanBalance, 'Excess Payments for Normal Loan 20');
        end;
        //Normal_loan_21_
        normal21LoanBalance := 0;
        normal21LoanBalance := RcptBufLines."Normal loan 21 Amount";
        if normal21LoanBalance > 0 then begin
            normal21LoanBalance := FnRunInterest(RcptBufLines, normal21LoanBalance, Rec."Loan CutOff Date", '21');
            normal21LoanBalance := FnRunPrinciple(RcptBufLines, normal21LoanBalance, Rec."Loan CutOff Date", '21');
            //normal21LoanBalance := FnRunLoanRepayment(RcptBufLines, normal21LoanBalance, Rec."Loan CutOff Date", '21');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal21LoanBalance, 'Excess Payments for Normal Loan 21');
        end;
        //Normal_loan_22_
        normal22LoanBalance := 0;
        normal22LoanBalance := RcptBufLines."Normal loan 22 Amount";
        if normal22LoanBalance > 0 then begin
            normal22LoanBalance := FnRunInterest(RcptBufLines, normal22LoanBalance, Rec."Loan CutOff Date", '22');
            normal22LoanBalance := FnRunPrinciple(RcptBufLines, normal22LoanBalance, Rec."Loan CutOff Date", '22');
            //normal22LoanBalance := FnRunLoanRepayment(RcptBufLines, normal22LoanBalance, Rec."Loan CutOff Date", '22');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, normal22LoanBalance, 'Excess Payments for Normal Loan 22');
        end;
        //Development_Loan_23_
        development23LoanBalance := 0;
        development23LoanBalance := RcptBufLines."Development Loan 23 Amount";
        if development23LoanBalance > 0 then begin
            development23LoanBalance := FnRunInterest(RcptBufLines, development23LoanBalance, Rec."Loan CutOff Date", '23');
            development23LoanBalance := FnRunPrinciple(RcptBufLines, development23LoanBalance, Rec."Loan CutOff Date", '23');
            //development23LoanBalance := FnRunLoanRepayment(RcptBufLines, development23LoanBalance, Rec."Loan CutOff Date", '23');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, development23LoanBalance, 'Excess Payments for Development Loan 23');
        end;

        //Development_Loan_25_
        development25LoanBalance := 0;
        development25LoanBalance := RcptBufLines."Development Loan 25 Amount";
        if development25LoanBalance > 0 then begin
            development25LoanBalance := FnRunInterest(RcptBufLines, development25LoanBalance, Rec."Loan CutOff Date", '25');
            development25LoanBalance := FnRunPrinciple(RcptBufLines, development25LoanBalance, Rec."Loan CutOff Date", '25');
            //development25LoanBalance := FnRunLoanRepayment(RcptBufLines, development25LoanBalance, Rec."Loan CutOff Date", '25');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, development25LoanBalance, 'Excess Payments for Development Loan 25');
        end;
        //Merchandise_Loan_26_
        merchandiseLoanBalance := 0;
        merchandiseLoanBalance := RcptBufLines."Merchandise Loan 26 Amount";
        if merchandiseLoanBalance > 0 then begin
            merchandiseLoanBalance := FnRunInterest(RcptBufLines, merchandiseLoanBalance, Rec."Loan CutOff Date", '26');
            merchandiseLoanBalance := FnRunPrinciple(RcptBufLines, merchandiseLoanBalance, Rec."Loan CutOff Date", '26');
            //merchandiseLoanBalance := FnRunLoanRepayment(RcptBufLines, merchandiseLoanBalance, Rec."Loan CutOff Date", '26');
            FnTransferExcessToUnallocatedFunds(RcptBufLines, merchandiseLoanBalance, 'Excess Payments for Merchandise Loan 26');
        end;
    end;

    local procedure FnInsertMemberContribution(Jtemplate: Code[30]; Jbatch: code[30]; memberNo: Code[15]; documentNo: code[30];
    transDescription: Code[30]; transAmount: Decimal; TransactionType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account"): Code[50]
    var
    begin
        LineN := LineN + 10000;
        Gnljnline.Init;
        Gnljnline."Journal Template Name" := Jtemplate;
        Gnljnline."Journal Batch Name" := Jbatch;
        Gnljnline."Line No." := LineN;
        Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
        Gnljnline."Account No." := memberNo;
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline."Document No." := documentNo;
        Gnljnline."Posting Date" := Rec."Posting date";
        Gnljnline.Description := transDescription;
        Gnljnline.Amount := transAmount * -1;
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline."Transaction Type" := TransactionType;//Gnljnline."transaction type"::"Deposit Contribution";
        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(memberNo);
        Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
        Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
        if Gnljnline.Amount <> 0 then
            Gnljnline.Insert();
    end;

    local procedure FnInsertWelfareContribution(Jtemplate: Code[30]; Jbatch: code[30]; memberNo: Code[15]; documentNo: code[30];
    transDescription: Code[100]; transAmount: Decimal; TransactionType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account","Welfare Contribution"): Code[50]
    var
    begin
        // Welfare contribution
        begin
            LineN := LineN + 10000;
            Gnljnline.Init;
            Gnljnline."Journal Template Name" := Jtemplate;
            Gnljnline."Journal Batch Name" := Jbatch;
            Gnljnline."Line No." := LineN;
            Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
            Gnljnline."Account No." := memberNo;
            Gnljnline.Validate(Gnljnline."Account No.");
            Gnljnline."Document No." := documentNo;
            Gnljnline."Posting Date" := Rec."Posting date";
            Gnljnline.Description := transDescription;
            Gnljnline.Amount := transAmount;
            Gnljnline.Validate(Gnljnline.Amount);
            Gnljnline."Transaction Type" := TransactionType;//Gnljnline."transaction type"::"Welfare Contribution";
            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(memberNo);
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            if Gnljnline.Amount <> 0 then
                Gnljnline.Insert();
        end;
        //End of welfare contribution
    end;

    local procedure FnInsertWelfareCreditBank(Jtemplate: Code[30]; Jbatch: code[30]; memberNo: Code[15]; documentNo: code[30];
    transDescription: Code[30]; transAmount: Decimal; TransactionType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account","Welfare Contribution"): Code[50]
    var
    begin
        // Welfare contribution
        begin
            LineN := LineN + 10000;
            Gnljnline.Init;
            Gnljnline."Journal Template Name" := Jtemplate;
            Gnljnline."Journal Batch Name" := Jbatch;
            Gnljnline."Line No." := LineN;
            Gnljnline."Account Type" := Gnljnline."Account Type"::"Bank Account";// Rec."Account Type";
            Gnljnline."Account No." := Rec."Account No"; //'BNK_0002';
            Gnljnline.Validate(Gnljnline."Account No.");
            Gnljnline."Document No." := Rec."Document No";
            Gnljnline."Posting Date" := Rec."Posting date";
            Gnljnline.Description := transDescription;
            Gnljnline.Amount := transAmount;
            Gnljnline.Validate(Gnljnline.Amount);
            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            Gnljnline."Shortcut Dimension 2 Code" := 'NAIROBI';
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            if Gnljnline.Amount <> 0 then
                Gnljnline.Insert(true);
        end;
        //End of welfare contribution
    end;

    local procedure FnInsertWelfareAccountCredit(Jtemplate: Code[30]; Jbatch: code[30]; memberNo: Code[15]; documentNo: code[30];
    transDescription: Code[30]; transAmount: Decimal; TransactionType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account","Welfare Contribution"): Code[50]
    var
    begin
        // Welfare contribution
        begin
            LineN := LineN + 10000;
            Gnljnline.Init;
            Gnljnline."Journal Template Name" := Jtemplate;
            Gnljnline."Journal Batch Name" := Jbatch;
            Gnljnline."Line No." := LineN;
            Gnljnline."Account Type" := Gnljnline."bal. account type"::"G/L Account";
            Gnljnline."Account No." := '200908';
            Gnljnline.Validate(Gnljnline."Account No.");
            Gnljnline."Document No." := documentNo;
            Gnljnline."Posting Date" := Rec."Posting date";
            Gnljnline.Description := transDescription;
            Gnljnline.Amount := transAmount * -1;
            Gnljnline.Validate(Gnljnline.Amount);
            Gnljnline."Transaction Type" := TransactionType;//Gnljnline."transaction type"::"Welfare Contribution";
            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(memberNo);
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            if Gnljnline.Amount <> 0 then
                Gnljnline.Insert();
        end;
        //End of welfare contribution
    end;

    local procedure FnInsertWelfareCommisionCredit(Jtemplate: Code[30]; Jbatch: code[30]; memberNo: Code[15]; documentNo: code[30];
   transDescription: Code[30]; transAmount: Decimal; TransactionType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account","Welfare Contribution"): Code[50]
    var
    begin
        // Welfare contribution
        begin
            LineN := LineN + 10000;
            Gnljnline.Init;
            Gnljnline."Journal Template Name" := Jtemplate;
            Gnljnline."Journal Batch Name" := Jbatch;
            Gnljnline."Line No." := LineN;
            Gnljnline."Account Type" := Gnljnline."bal. account type"::"G/L Account";
            Gnljnline."Account No." := '301424';
            Gnljnline.Validate(Gnljnline."Account No.");
            Gnljnline."Document No." := documentNo;
            Gnljnline."Posting Date" := Rec."Posting date";
            Gnljnline.Description := transDescription;
            Gnljnline.Amount := transAmount * -1;
            Gnljnline.Validate(Gnljnline.Amount);
            Gnljnline."Transaction Type" := TransactionType;//Gnljnline."transaction type"::"Welfare Contribution";
            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(memberNo);
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            if Gnljnline.Amount <> 0 then
                Gnljnline.Insert();
        end;
        //End of welfare contribution
    end;


    local procedure FnInsertLoanRepayment(Jtemplate: Code[30]; Jbatch: Code[30]; memberNo: code[30]; documentNo: Code[30];
        transDescription: Code[50]; transAmount: Decimal)
    var
    begin
        LineN := LineN + 10000;
        Gnljnline.Init;
        Gnljnline."Journal Template Name" := Jtemplate;
        Gnljnline."Journal Batch Name" := Jbatch;
        Gnljnline."Line No." := LineN;
        Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
        Gnljnline."Account No." := memberNo;
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline."Document No." := documentNo;
        Gnljnline."Posting Date" := Today;
        Gnljnline.Description := transDescription;
        Gnljnline.Amount := transAmount * -1;
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(memberNo);
        Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
        Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");

        if Gnljnline.Amount <> 0 then
            Gnljnline.Insert();
    end;

    local procedure FnRunInterest(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; LoanCutoffDate: Date; loanCode: Code[10]): Decimal
    var
        AmountToDeduct: Decimal;
        InterestToRecover: Decimal;
    begin
        if RunningBalance > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            // LoanApp.SetRange(LoanApp."Recovery Mode", LoanApp."recovery mode"::"Payroll Deduction");//This now will raise issuess
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            //LoanApp.SETFILTER(LoanApp."Date filter",Datefilter); //Deduct all interest outstanding regardless of date
            //LoanApp.SETRANGE(LoanApp."Issued Date",startDate,IssueDate);
            LoanApp.SetCurrentKey("Client Code", "Application Date");
            LoanApp.Ascending(false);
            if LoanApp.FindSet() then begin
                repeat
                    LoanApp.CalcFields(LoanApp."Oustanding Interest");
                    if (LoanApp."Oustanding Interest" > 0) and (LoanApp."Issued Date" <= LoanCutoffDate) then begin
                        if RunningBalance > 0 then //300
                          begin
                            AmountToDeduct := 0;
                            InterestToRecover := (LoanApp."Oustanding Interest");
                            if RunningBalance >= InterestToRecover then
                                AmountToDeduct := InterestToRecover
                            else
                                AmountToDeduct := RunningBalance;

                            LineN := LineN + 10000;
                            Gnljnline.Init;
                            Gnljnline."Journal Template Name" := Jtemplate;
                            Gnljnline."Journal Batch Name" := Jbatch;
                            Gnljnline."Line No." := LineN;
                            Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                            Gnljnline."Account No." := LoanApp."Client Code";
                            Gnljnline.Validate(Gnljnline."Account No.");
                            Gnljnline."Document No." := Rec."Document No";
                            Gnljnline."Posting Date" := Rec."Posting date";
                            Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Interest Paid ';
                            Gnljnline.Amount := -1 * AmountToDeduct;
                            Gnljnline.Validate(Gnljnline.Amount);
                            Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Interest Paid";
                            Gnljnline."Loan No" := LoanApp."Loan  No.";

                            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                            if Gnljnline.Amount <> 0 then
                                Gnljnline.Insert;
                            RunningBalance := RunningBalance - Abs(AmountToDeduct);
                        end;
                    end;
                until LoanApp.Next = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnPostInterestNew(ObjRcptBuffer: Record "Polytech CheckoffLines"; postingAmount: Decimal; LoanCutoffDate: Date; loanCode: Code[10]; loanNumber: Code[50])
    var
        AmountToDeduct: Decimal;
        InterestToRecover: Decimal;
    begin
        if postingAmount > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan  No.", loanNumber);
            if LoanApp.Find('-') then begin//end FindSet() then begin
                LineN := LineN + 10000;
                Gnljnline.Init;
                Gnljnline."Journal Template Name" := Jtemplate;
                Gnljnline."Journal Batch Name" := Jbatch;
                Gnljnline."Line No." := LineN;
                Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                Gnljnline."Account No." := LoanApp."Client Code";
                Gnljnline.Validate(Gnljnline."Account No.");
                Gnljnline."Document No." := Rec."Document No";
                Gnljnline."Posting Date" := Rec."Posting date";
                Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Interest Paid ';
                Gnljnline.Amount := -1 * postingAmount;
                Gnljnline.Validate(Gnljnline.Amount);
                Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Interest Paid";
                Gnljnline."Loan No" := LoanApp."Loan  No.";

                Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                if Gnljnline.Amount <> 0 then
                    Gnljnline.Insert;

            end;
        end;
    end;

    local procedure FnPostInterest(ObjRcptBuffer: Record "Polytech CheckoffLines"; postingAmount: Decimal; LoanCutoffDate: Date; loanCode: Code[10]; loanNumber: Code[50])
    var
        AmountToDeduct: Decimal;
        InterestToRecover: Decimal;
    begin
        if postingAmount > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            // LoanApp.SetRange(LoanApp."Recovery Mode", LoanApp."recovery mode"::"Payroll Deduction");//This now will raise issuess
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            LoanApp.SetRange(LoanApp."Loan  No.", loanNumber);
            if LoanApp.FindSet() then begin
                AmountToDeduct := postingAmount;
                repeat
                    LoanApp.CalcFields("Oustanding Interest");

                    if AmountToDeduct = 0 then exit;

                    // Check if the outstanding interest is greater than 0
                    if LoanApp."Oustanding Interest" > 0 then begin

                        InterestToRecover := (LoanApp."Oustanding Interest");
                        if postingAmount >= InterestToRecover then
                            AmountToDeduct := InterestToRecover
                        else
                            AmountToDeduct := postingAmount;

                        LineN := LineN + 10000;
                        Gnljnline.Init;
                        Gnljnline."Journal Template Name" := Jtemplate;
                        Gnljnline."Journal Batch Name" := Jbatch;
                        Gnljnline."Line No." := LineN;
                        Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                        Gnljnline."Account No." := LoanApp."Client Code";
                        Gnljnline.Validate(Gnljnline."Account No.");
                        Gnljnline."Document No." := Rec."Document No";
                        Gnljnline."Posting Date" := Rec."Posting date";
                        Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Interest Paid ';
                        Gnljnline.Amount := -1 * AmountToDeduct;
                        Gnljnline.Validate(Gnljnline.Amount);
                        Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Interest Paid";
                        Gnljnline."Loan No" := LoanApp."Loan  No.";

                        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                        if Gnljnline.Amount <> 0 then
                            Gnljnline.Insert;
                        postingAmount := postingAmount - AmountToDeduct;
                    end;
                until LoanApp.Next() = 0;

            end;
            //cater for no Interest found Loans here..or Loans not found
            if postingAmount > 0 then begin
                LineN := LineN + 10000;
                Gnljnline.Init;
                Gnljnline."Journal Template Name" := Jtemplate;
                Gnljnline."Journal Batch Name" := Jbatch;
                Gnljnline."Line No." := LineN;
                Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                Gnljnline."Account No." := LoanApp."Client Code";
                Gnljnline.Validate(Gnljnline."Account No.");
                Gnljnline."Document No." := Rec."Document No";
                Gnljnline."Posting Date" := Rec."Posting date";
                Gnljnline.Description := LoanApp."Loan Product Type" + '--Loan Repayment ';// LoanApp."Loan Product Type" + '--Loan Interest Paid ';
                Gnljnline.Amount := -1 * postingAmount;
                Gnljnline.Validate(Gnljnline.Amount);
                Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                Gnljnline."Loan No" := LoanApp."Loan  No.";

                Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                if Gnljnline.Amount <> 0 then
                    Gnljnline.Insert;
            end;
        end;
    end;

    local procedure FnPostInterestBal(ObjRcptBuffer: Record "Polytech CheckoffLines"; postingAmount: Decimal; LoanCutoffDate: Date; loanCode: Code[10]; loanNumber: Code[50]) balance: Decimal
    var
        AmountToDeduct: Decimal;
        InterestToRecover: Decimal;
    begin
        if postingAmount > 0 then begin
            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            LoanApp.SetRange(LoanApp."Loan  No.", loanNumber);
            if LoanApp.Find('-') then begin// FindSet() then begin
                AmountToDeduct := postingAmount;
                // repeat
                LoanApp.CalcFields("Oustanding Interest");

                if AmountToDeduct = 0 then exit;

                // Check if the outstanding interest is greater than 0
                if LoanApp."Oustanding Interest" > 0 then begin

                    InterestToRecover := (LoanApp."Oustanding Interest");
                    if postingAmount >= InterestToRecover then
                        AmountToDeduct := InterestToRecover
                    else
                        AmountToDeduct := postingAmount;

                    LineN := LineN + 10000;
                    Gnljnline.Init;
                    Gnljnline."Journal Template Name" := Jtemplate;
                    Gnljnline."Journal Batch Name" := Jbatch;
                    Gnljnline."Line No." := LineN;
                    Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                    Gnljnline."Account No." := LoanApp."Client Code";
                    Gnljnline.Validate(Gnljnline."Account No.");
                    Gnljnline."Document No." := Rec."Document No";
                    Gnljnline."Posting Date" := Rec."Posting date";
                    Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Interest Paid ';
                    Gnljnline.Amount := -1 * AmountToDeduct;
                    Gnljnline.Validate(Gnljnline.Amount);
                    Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Interest Paid";
                    Gnljnline."Loan No" := LoanApp."Loan  No.";

                    Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                    Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                    Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                    Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                    if Gnljnline.Amount <> 0 then
                        Gnljnline.Insert;
                    postingAmount := postingAmount - AmountToDeduct;
                end;
                // until LoanApp.Next() = 0;
                balance := postingAmount;
            end;
            //return balance
            exit(balance);
        end;
    end;

    local procedure FnChargeCommission(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal): Decimal
    var
        AmountToDeduct: Decimal;
        WelfareAmount: Decimal;
        CommissionAmount: Decimal;
    begin
        AmountToDeduct := 320;
        WelfareAmount := 300;
        CommissionAmount := 20;

        if RunningBalance >= AmountToDeduct then begin
            PostDebitCustomer(ObjRcptBuffer, AmountToDeduct);
            PostCreditBank(ObjRcptBuffer, AmountToDeduct);
            PostCreditWelfare(ObjRcptBuffer, WelfareAmount);
            PostCreditCommission(ObjRcptBuffer, CommissionAmount);

            RunningBalance := RunningBalance - AmountToDeduct;
        end;

        exit(RunningBalance);
    end;

    local procedure GetNextLineNo(Jtemplate: Code[10]; Jbatch: Code[10]): Integer
    var
        Gnljnline: Record "Gen. Journal Line";
    begin
        Gnljnline.SetRange("Journal Template Name", Jtemplate);
        Gnljnline.SetRange("Journal Batch Name", Jbatch);
        if Gnljnline.FindLast then
            exit(Gnljnline."Line No." + 10000);
        exit(10000); // start at 10000 if no lines exist
    end;

    local procedure PostDebitCustomer(ObjRcptBuffer: Record "Polytech CheckoffLines"; Amount: Decimal)
    var
        Gnljnline: Record "Gen. Journal Line";
        LineNo: Integer;
    begin
        LineNo := GetNextLineNo('GENERAL', 'CHECKOFF');
        InitJournalLine(Gnljnline, LineNo, ObjRcptBuffer);
        Gnljnline."Account Type" := Gnljnline."Account Type"::Customer;
        Gnljnline."Account No." := ObjRcptBuffer."Member No";
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline.Description := 'Welfare Contribution Checkoff';
        Gnljnline.Amount := -Amount;
        Gnljnline."Transaction Type" := Gnljnline."Transaction Type"::"Welfare Contribution";
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline.Insert();
    end;

    local procedure PostCreditBank(ObjRcptBuffer: Record "Polytech CheckoffLines"; Amount: Decimal)
    var
        Gnljnline: Record "Gen. Journal Line";
        LineNo: Integer;
        BankGLAcc: Code[20];
    begin
        BankGLAcc := 'BNK_0006';
        LineNo := GetNextLineNo('GENERAL', 'CHECKOFF');
        InitJournalLine(Gnljnline, LineNo, ObjRcptBuffer);
        Gnljnline."Account Type" := Gnljnline."Account Type"::"Bank Account";
        Gnljnline."Account No." := Rec."Account No";
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline.Description := 'Bank Receipt for Welfare' + ' for MembNo:%1' + ObjRcptBuffer."Member No";
        Gnljnline.Amount := Amount;
        Gnljnline."Transaction Type" := Gnljnline."Transaction Type"::"Welfare Contribution";
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline.Insert();
    end;


    // local procedure PostCreditBank(ObjRcptBuffer: Record "Polytech CheckoffLines"; Amount: Decimal)
    // var
    //     Gnljnline: Record "Gen. Journal Line";
    //     LineNo: Integer;
    //     BankGLAcc: Code[20];
    // begin
    //     Rec.Validate("Scheduled Amount");
    //     LineN := LineN + 10000;
    //     Gnljnline.Init;
    //     Gnljnline."Journal Template Name" := Jtemplate;
    //     Gnljnline."Journal Batch Name" := Jbatch;
    //     Gnljnline."Line No." := LineN;
    //     Gnljnline."Account Type" := Gnljnline."Account Type"::"Bank Account";// Rec."Account Type";
    //     Gnljnline."Account No." := BankGLAcc;
    //     Gnljnline.Validate(Gnljnline."Account No.");
    //     Gnljnline."Document No." := Rec."Document No";
    //     Gnljnline."Posting Date" := Rec."Posting date";
    //     Gnljnline.Description := 'CHECKOFF Bank Trans' + Rec.Remarks;
    //     Gnljnline.Amount := Amount;
    //     Gnljnline.Validate(Gnljnline.Amount);
    //     Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
    //     Gnljnline."Shortcut Dimension 2 Code" := 'NAIROBI';
    //     Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
    //     Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
    //     if Gnljnline.Amount <> 0 then
    //         Gnljnline.Insert(true);
    //     //End Of control

    // end;

    local procedure PostCreditWelfare(ObjRcptBuffer: Record "Polytech CheckoffLines"; Amount: Decimal)
    var
        Gnljnline: Record "Gen. Journal Line";
        LineNo: Integer;
        WelfareGLAcc: Code[20];
    begin
        WelfareGLAcc := '200908';
        LineNo := GetNextLineNo('GENERAL', 'CHECKOFF');
        InitJournalLine(Gnljnline, LineNo, ObjRcptBuffer);
        Gnljnline."Account Type" := Gnljnline."Account Type"::"G/L Account";
        Gnljnline."Account No." := WelfareGLAcc;
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline.Description := 'Welfare Contribution'/*  + '-> MembNo:%1' + ObjRcptBuffer."Member No" */;
        Gnljnline.Amount := Amount;
        Gnljnline."Transaction Type" := Gnljnline."Transaction Type"::"Welfare Contribution";
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline.Insert();
    end;

    local procedure PostCreditCommission(ObjRcptBuffer: Record "Polytech CheckoffLines"; Amount: Decimal)
    var
        Gnljnline: Record "Gen. Journal Line";
        LineNo: Integer;
        CommissionGLAcc: Code[20];
    begin
        CommissionGLAcc := '301424';
        LineNo := GetNextLineNo('GENERAL', 'CHECKOFF');
        InitJournalLine(Gnljnline, LineNo, ObjRcptBuffer);
        Gnljnline."Account Type" := Gnljnline."Account Type"::"G/L Account";
        Gnljnline."Account No." := CommissionGLAcc;
        Gnljnline.Validate(Gnljnline."Account No.");
        Gnljnline.Description := 'Commission on Welfare Contribution';
        Gnljnline.Amount := Amount;
        Gnljnline."Transaction Type" := Gnljnline."Transaction Type"::"Welfare Contribution";
        Gnljnline.Validate(Gnljnline.Amount);
        Gnljnline.Insert();
    end;


    local procedure InitJournalLine(var Gnljnline: Record "Gen. Journal Line"; LineNo: Integer; ObjRcptBuffer: Record "Polytech CheckoffLines")
    begin
        Gnljnline.Init;
        Gnljnline."Journal Template Name" := 'GENERAL';
        Gnljnline."Journal Batch Name" := 'CHECKOFF';
        Gnljnline."Line No." := LineNo;
        Gnljnline."Document No." := Rec."Document No";
        Gnljnline."Posting Date" := Rec."Posting Date";
        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(ObjRcptBuffer."Member No");
    end;

    local procedure fnGetLoanNumber(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; LoanCutoffDate: Date; loanCode: Code[10]) loanNumber: Code[50]
    var
    begin
        loanNumber := '';
        LoanApp.Reset;
        LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
        LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
        LoanApp.SetFilter(LoanApp."Date filter", '..' + Format(LoanCutoffDate));
        LoanApp.SetCurrentKey("Client Code", "Application Date");
        LoanApp.Ascending(false);
        if LoanApp.FindFirst() then begin
            repeat
                LoanApp.CalcFields("Outstanding Balance");

                // Check if the outstanding Balance is greater than 0
                if LoanApp."Outstanding Balance" > 0 then begin
                    loanNumber := LoanApp."Loan  No.";
                end;

            until LoanApp.Next() = 0;
        end;
        if loanNumber = '' then begin
            LoanApp.Reset;
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            LoanApp.SetFilter(LoanApp."Date filter", '..' + Format(LoanCutoffDate));
            LoanApp.SetCurrentKey("Client Code", "Application Date");
            LoanApp.Ascending(false);
            if LoanApp.FindFirst() then begin
                repeat
                    LoanApp.CalcFields("Outstanding Balance");
                    LoanApp.CalcFields("Oustanding Interest");

                    // Check if the outstanding Interest is greater than 0
                    if LoanApp."Oustanding Interest" > 0 then begin
                        loanNumber := LoanApp."Loan  No.";
                    end;

                until LoanApp.Next() = 0;
            end;
        end;
        exit(loanNumber);
    end;

    local procedure FnPostPrincipleBal(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; loanNumber: Code[50])
    var
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        AmountToDeduct: Decimal;
        NewOutstandingBal: Decimal;
    begin

        if RunningBalance > 0 then begin
            varTotalRepay := 0;
            varMultipleLoan := 0;
            MonthlyRepay := 0;
            ScheduleRepayment := 0;

            LoanApp.Reset;
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan  No.", loanNumber);
            if LoanApp.Find('-') then begin// FindFirst() then begin
                AmountToDeduct := RunningBalance;
                // repeat
                LoanApp.CalcFields("Outstanding Balance");

                //check if thi has already been posted in the loop..
                if AmountToDeduct = 0 then
                    exit;
                // Check if the outstanding Balance is greater than 0
                //////////POST THE REMAINING AMOUNT
                // if LoanApp."Outstanding Balance" > 0 then begin
                LineN := LineN + 10000;
                Gnljnline.Init;
                Gnljnline."Journal Template Name" := Jtemplate;
                Gnljnline."Journal Batch Name" := Jbatch;
                Gnljnline."Line No." := LineN;
                Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                Gnljnline."Account No." := LoanApp."Client Code";
                Gnljnline.Validate(Gnljnline."Account No.");
                Gnljnline."Document No." := Rec."Document No";
                Gnljnline."Posting Date" := Rec."Posting date";
                Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Repayment ';

                Gnljnline.Amount := AmountToDeduct * -1;
                Gnljnline.Validate(Gnljnline.Amount);
                Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                Gnljnline."Loan No" := LoanApp."Loan  No.";
                Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                if Gnljnline.Amount <> 0 then
                    Gnljnline.Insert();
                AmountToDeduct := AmountToDeduct - RunningBalance;
                loanNumber := LoanApp."Loan  No.";
                // end;
                //////HERE.....

                // until LoanApp.Next() = 0;

            end;
        end;
    end;

    local procedure FnPostPrincipleBal2(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; loanNumber: Code[50]) balance: Decimal
    var
        AmountToDeduct: Decimal;
        NewOutstandingBal: Decimal;
    begin

        if RunningBalance > 0 then begin
            AmountToDeduct := 0;
            balance := RunningBalance;

            LoanApp.Reset;
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan  No.", loanNumber);
            if LoanApp.Find('-') then begin
                AmountToDeduct := RunningBalance;
                // repeat
                LoanApp.CalcFields("Outstanding Balance");

                //check if thi has already been posted in the loop..
                if AmountToDeduct = 0 then
                    exit;

                LineN := LineN + 10000;
                Gnljnline.Init;
                Gnljnline."Journal Template Name" := Jtemplate;
                Gnljnline."Journal Batch Name" := Jbatch;
                Gnljnline."Line No." := LineN;
                Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                Gnljnline."Account No." := LoanApp."Client Code";
                Gnljnline.Validate(Gnljnline."Account No.");
                Gnljnline."Document No." := Rec."Document No";
                Gnljnline."Posting Date" := Rec."Posting date";
                Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Repayment ';

                Gnljnline.Amount := AmountToDeduct * -1;
                Gnljnline.Validate(Gnljnline.Amount);
                Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                Gnljnline."Loan No" := LoanApp."Loan  No.";
                Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                if Gnljnline.Amount <> 0 then
                    Gnljnline.Insert();

            end;
            balance := RunningBalance - AmountToDeduct;
        end;
        exit(balance);
    end;

    local procedure FnPostPrinciple(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; LoanCutoffDate: Date; loanCode: Code[10]) loanNumber: Code[50]
    var
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        AmountToDeduct: Decimal;
        NewOutstandingBal: Decimal;
    begin

        if RunningBalance > 0 then begin
            varTotalRepay := 0;
            varMultipleLoan := 0;
            MonthlyRepay := 0;
            ScheduleRepayment := 0;
            loanNumber := '';

            LoanApp.Reset;
            // LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            // LoanApp.SetRange(LoanApp."Recovery Mode", LoanApp."recovery mode"::"Payroll Deduction");//Comment kiasi here..Festus
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            //LoanApp.SETRANGE(LoanApp."Issued Date",startDate,IssueDate);
            LoanApp.SetCurrentKey("Client Code", "Application Date");
            LoanApp.Ascending(false);
            if LoanApp.FindFirst() then begin
                AmountToDeduct := RunningBalance;
                repeat
                    LoanApp.CalcFields("Outstanding Balance");

                    //check if thi has already been posted in the loop..
                    if AmountToDeduct = 0 then
                        exit;
                    // Check if the outstanding Balance is greater than 0
                    if LoanApp."Outstanding Balance" > 0 then begin
                        LineN := LineN + 10000;
                        Gnljnline.Init;
                        Gnljnline."Journal Template Name" := Jtemplate;
                        Gnljnline."Journal Batch Name" := Jbatch;
                        Gnljnline."Line No." := LineN;
                        Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                        Gnljnline."Account No." := LoanApp."Client Code";
                        Gnljnline.Validate(Gnljnline."Account No.");
                        Gnljnline."Document No." := Rec."Document No";
                        Gnljnline."Posting Date" := Rec."Posting date";
                        Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Repayment ';

                        Gnljnline.Amount := AmountToDeduct * -1;
                        Gnljnline.Validate(Gnljnline.Amount);
                        Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                        Gnljnline."Loan No" := LoanApp."Loan  No.";
                        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                        if Gnljnline.Amount <> 0 then
                            Gnljnline.Insert();
                        AmountToDeduct := AmountToDeduct - RunningBalance;
                        loanNumber := LoanApp."Loan  No.";
                    end;
                    if loanNumber = '' then
                        loanNumber := LoanApp."Loan  No.";
                until LoanApp.Next() = 0;


            end;
            // // cater for Loans without balances here... or loans not found
            // if AmountToDeduct > 0 then begin
            //     LineN := LineN + 10000;
            //     Gnljnline.Init;
            //     Gnljnline."Journal Template Name" := Jtemplate;
            //     Gnljnline."Journal Batch Name" := Jbatch;
            //     Gnljnline."Line No." := LineN;
            //     Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
            //     Gnljnline."Account No." := LoanApp."Client Code";
            //     Gnljnline.Validate(Gnljnline."Account No.");
            //     Gnljnline."Document No." := Rec."Document No";
            //     Gnljnline."Posting Date" := Rec."Posting date";
            //     Gnljnline.Description := LoanApp."Loan Product Type" + '-- Loan Repayment ';

            //     Gnljnline.Amount := AmountToDeduct * -1;
            //     Gnljnline.Validate(Gnljnline.Amount);
            //     Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
            //     // Gnljnline."Loan No" := LoanApp."Loan  No.";
            //     Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            //     Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
            //     Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            //     Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            //     if Gnljnline.Amount <> 0 then
            //         Gnljnline.Insert();
            // end;
            exit(loanNumber);
            // Message('Loan Number is' + loanNumber);
        end;
    end;

    local procedure FnRunPrinciple(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; LoanCutoffDate: Date; loanCode: Code[10]): Decimal
    var
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        AmountToDeduct: Decimal;
        NewOutstandingBal: Decimal;
    begin

        if RunningBalance > 0 then begin
            varTotalRepay := 0;
            varMultipleLoan := 0;
            MonthlyRepay := 0;
            ScheduleRepayment := 0;

            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            LoanApp.SetCurrentKey("Client Code", "Application Date");
            LoanApp.Ascending(false);
            // if LoanApp.FindFirst() then begin

            //     repeat
            //         if RunningBalance > 0 then begin
            //             LoanApp.CalcFields(LoanApp."Outstanding Balance", LoanApp."Oustanding Interest");
            //             if (LoanApp."Outstanding Balance" > 0) then begin
            //                 if (LoanApp."Issued Date" <= LoanCutoffDate) then begin

            //                     if LoanApp."Oustanding Interest" >= 0 then begin
            //                         AmountToDeduct := RunningBalance;
            //                         NewOutstandingBal := LoanApp."Outstanding Balance" - RunningBalance;
            //                         if AmountToDeduct >= (LoanApp.Repayment - LoanApp."Oustanding Interest") then begin
            //                             MonthlyRepay := LoanApp.Repayment - LoanApp."Oustanding Interest";
            //                             NewOutstandingBal := LoanApp."Outstanding Balance" - MonthlyRepay;
            //                         end else if AmountToDeduct < (LoanApp.Repayment - LoanApp."Oustanding Interest") then begin
            //                             MonthlyRepay := AmountToDeduct;
            //                             NewOutstandingBal := LoanApp."Outstanding Balance" - MonthlyRepay;
            //                         end;
            //                     end;
            //                     if MonthlyRepay >= LoanApp."Outstanding Balance" then begin
            //                         // AmountToDeduct:=LoanApp."Outstanding Balance";
            //                         // NewOutstandingBal:=LoanApp."Outstanding Balance"-AmountToDeduct;
            //                         MonthlyRepay := LoanApp."Outstanding Balance";
            //                         NewOutstandingBal := LoanApp."Outstanding Balance" - MonthlyRepay;
            //                     end;


            //                     //GET SCHEDULE REPAYMENT

            //                     Lschedule.Reset;
            //                     Lschedule.SetRange(Lschedule."Loan No.", LoanApp."Loan  No.");
            //                     //Lschedule.SETRANGE(Lschedule."Repayment Date","Posting date");
            //                     if Lschedule.FindFirst then begin
            //                         LoanApp.CalcFields(LoanApp."Outstanding Balance", LoanApp."Oustanding Interest");
            //                         //ScheduleRepayment:=Lschedule."Principal Repayment";
            //                         ScheduleRepayment := Lschedule."Monthly Repayment" - LoanApp."Oustanding Interest";
            //                         if ScheduleRepayment > LoanApp."Outstanding Balance" then begin
            //                             ScheduleRepayment := LoanApp."Outstanding Balance"
            //                         end else
            //                             ScheduleRepayment := ScheduleRepayment;
            //                     end;

            //                     LineN := LineN + 10000;
            //                     Gnljnline.Init;
            //                     Gnljnline."Journal Template Name" := Jtemplate;
            //                     Gnljnline."Journal Batch Name" := Jbatch;
            //                     Gnljnline."Line No." := LineN;
            //                     Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
            //                     Gnljnline."Account No." := LoanApp."Client Code";
            //                     Gnljnline.Validate(Gnljnline."Account No.");
            //                     Gnljnline."Document No." := Rec."Document No";
            //                     Gnljnline."Posting Date" := Rec."Posting date";
            //                     Gnljnline.Description := LoanApp."Loan Product Type" + '- Loan Repayment ';
            //                     if RunningBalance > ScheduleRepayment then begin
            //                         Gnljnline.Amount := MonthlyRepay * -1;//ScheduleRepayment * -1;
            //                     end else
            //                         Gnljnline.Amount := RunningBalance * -1;
            //                     Gnljnline.Validate(Gnljnline.Amount);
            //                     Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
            //                     Gnljnline."Loan No" := LoanApp."Loan  No.";
            //                     Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            //                     Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
            //                     Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            //                     Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            //                     if Gnljnline.Amount <> 0 then
            //                         Gnljnline.Insert();
            //                     RunningBalance := RunningBalance - Abs(Gnljnline.Amount);
            //                 end;
            //             end;
            //         end;
            //     until LoanApp.Next = 0;
            // end;
            if LoanApp.FindFirst() then begin
                AmountToDeduct := RunningBalance;
                repeat
                    LoanApp.CalcFields("Outstanding Balance");

                    //check if thi has already been posted in the loop..
                    if AmountToDeduct = 0 then
                        exit;
                    // Check if the outstanding Balance is greater than 0
                    if LoanApp."Outstanding Balance" > 0 then begin
                        LineN := LineN + 10000;
                        Gnljnline.Init;
                        Gnljnline."Journal Template Name" := Jtemplate;
                        Gnljnline."Journal Batch Name" := Jbatch;
                        Gnljnline."Line No." := LineN;
                        Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                        Gnljnline."Account No." := LoanApp."Client Code";
                        Gnljnline.Validate(Gnljnline."Account No.");
                        Gnljnline."Document No." := Rec."Document No";
                        Gnljnline."Posting Date" := Rec."Posting date";
                        Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Repayment ';

                        Gnljnline.Amount := AmountToDeduct * -1;
                        Gnljnline.Validate(Gnljnline.Amount);
                        Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                        Gnljnline."Loan No" := LoanApp."Loan  No.";
                        Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                        Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                        Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                        if Gnljnline.Amount <> 0 then
                            Gnljnline.Insert();
                        RunningBalance := RunningBalance - Abs(Gnljnline.Amount);
                    end;
                until LoanApp.Next() = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRunLoanRepayment(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; LoanCutoffDate: Date; loanCode: Code[10]): Decimal
    var
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        AmountToDeduct: Decimal;
        NewOutstandingBal: Decimal;
    begin

        if RunningBalance > 0 then begin
            varTotalRepay := 0;
            varMultipleLoan := 0;
            MonthlyRepay := 0;
            ScheduleRepayment := 0;
            AmountToDeduct := 0;

            LoanApp.Reset;
            LoanApp.SetCurrentkey(Source, "Issued Date", "Loan Product Type", "Client Code", "Staff No");
            LoanApp.SetRange(LoanApp."Client Code", ObjRcptBuffer."Member No");
            // LoanApp.SetRange(LoanApp."Recovery Mode", LoanApp."recovery mode"::"Payroll Deduction");//Comment kiasi here..Festus
            LoanApp.SetRange(LoanApp."Loan Product Type", loanCode);
            //LoanApp.SETRANGE(LoanApp."Issued Date",startDate,IssueDate);
            if LoanApp.Findset then begin

                repeat
                    if RunningBalance > 0 then begin
                        LoanApp.CalcFields(LoanApp."Outstanding Balance", LoanApp."Oustanding Interest");
                        if (LoanApp."Outstanding Balance" > 0) then begin
                            // if (LoanApp."Issued Date" <= LoanCutoffDate) then begin

                            if LoanApp."Outstanding Balance" > 0 then begin
                                if LoanApp."Outstanding Balance" >= RunningBalance then begin
                                    AmountToDeduct := RunningBalance;
                                end else if RunningBalance > LoanApp."Outstanding Balance" then begin
                                    AmountToDeduct := LoanApp."Outstanding Balance";
                                end;
                            end else begin
                                AmountToDeduct := 0;
                            end;

                            LineN := LineN + 10000;
                            Gnljnline.Init;
                            Gnljnline."Journal Template Name" := Jtemplate;
                            Gnljnline."Journal Batch Name" := Jbatch;
                            Gnljnline."Line No." := LineN;
                            Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                            Gnljnline."Account No." := LoanApp."Client Code";
                            Gnljnline.Validate(Gnljnline."Account No.");
                            Gnljnline."Document No." := Rec."Document No";
                            Gnljnline."Posting Date" := Rec."Posting date";
                            Gnljnline.Description := LoanApp."Loan Product Type" + '-Loan Repayment ';
                            Gnljnline.Amount := AmountToDeduct /* * -1 */;///Just repay the Loan...
                            Gnljnline.Validate(Gnljnline.Amount);
                            Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                            Gnljnline."Loan No" := LoanApp."Loan  No.";
                            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(LoanApp."Client Code");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                            if Gnljnline.Amount <> 0 then
                                Gnljnline.Insert();
                            RunningBalance := RunningBalance - Abs(Gnljnline.Amount);
                            // end;
                        end;
                    end;
                until LoanApp.Next = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnRecoverPrincipleFromExcess(ObjRcptBuffer: Record "ReceiptsProcessing_L-Checkoff"; RunningBalance: Decimal): Decimal
    var
        varTotalRepay: Decimal;
        varMultipleLoan: Decimal;
        varLRepayment: Decimal;
        ObjTempLoans: Record "Temp Loans Balances";
        AmountToDeduct: Decimal;
    begin
        if RunningBalance > 0 then begin
            varTotalRepay := 0;
            varMultipleLoan := 0;

            ObjTempLoans.Reset;
            ObjTempLoans.SetRange(ObjTempLoans."Loan No", ObjRcptBuffer."Member No");
            if ObjTempLoans.Find('-') then begin
                repeat
                    if RunningBalance > 0 then begin
                        if ObjTempLoans."Outstanding Balance" > 0 then begin
                            AmountToDeduct := RunningBalance;
                            if AmountToDeduct >= ObjTempLoans."Outstanding Balance" then
                                AmountToDeduct := ObjTempLoans."Outstanding Balance";
                            LineN := LineN + 10000;
                            Gnljnline.Init;
                            Gnljnline."Journal Template Name" := Jtemplate;
                            Gnljnline."Journal Batch Name" := Jbatch;
                            Gnljnline."Line No." := LineN;
                            Gnljnline."Account Type" := Gnljnline."bal. account type"::Customer;
                            Gnljnline."Account No." := LoanApp."Client Code";
                            Gnljnline.Validate(Gnljnline."Account No.");
                            Gnljnline."Document No." := Rec."Document No";
                            Gnljnline."Posting Date" := Rec."Posting date";
                            Gnljnline.Description := LoanApp."Loan Product Type" + '-Repayment from excess checkoff'; //TODO Change the Narrative after testing
                            Gnljnline.Amount := AmountToDeduct * -1;
                            Gnljnline.Validate(Gnljnline.Amount);
                            Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Loan Repayment";
                            Gnljnline."Loan No" := LoanApp."Loan  No.";
                            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
                            Gnljnline."Shortcut Dimension 2 Code" := FnGetMemberBranch(ObjTempLoans."Loan No");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
                            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
                            if Gnljnline.Amount <> 0 then
                                Gnljnline.Insert;
                            RunningBalance := RunningBalance - Abs(Gnljnline.Amount);
                        end;
                    end;
                until ObjTempLoans.Next = 0;
            end;
            exit(RunningBalance);
        end;
    end;

    local procedure FnGetMemberBranch(MemberNo: Code[50]): Code[100]
    var
        MemberBranch: Code[100];
    begin
        Cust.Reset;
        Cust.SetRange(Cust."No.", MemberNo);
        if Cust.Find('-') then begin
            MemberBranch := Cust."Global Dimension 2 Code";
        end;
        exit(MemberBranch);
    end;

    local procedure FnTransferExcessToUnallocatedFunds(ObjRcptBuffer: Record "Polytech CheckoffLines"; RunningBalance: Decimal; description: Code[50])
    var

        ObjMember: Record Customer;
    begin

        ObjMember.Reset;
        ObjMember.SetRange(ObjMember."No.", ObjRcptBuffer."Member No");
        // ObjMember.SetRange(ObjMember."Customer Type", ObjMember."customer type"::Member);
        if ObjMember.Find('-') then begin

            LineN := LineN + 10000;
            Gnljnline.Init;
            Gnljnline."Journal Template Name" := Jtemplate;
            Gnljnline."Journal Batch Name" := Jbatch;
            Gnljnline."Line No." := LineN;
            Gnljnline."Account Type" := Gnljnline."account type"::Customer;
            Gnljnline."Account No." := ObjRcptBuffer."Member No";
            Gnljnline.Validate(Gnljnline."Account No.");
            Gnljnline."Document No." := Rec."Document No";
            Gnljnline."Posting Date" := Rec."Posting date";
            Gnljnline.Description := description;
            Gnljnline.Amount := RunningBalance * -1;
            Gnljnline.Validate(Gnljnline.Amount);
            Gnljnline."Transaction Type" := Gnljnline."transaction type"::"Unallocated Funds";
            Gnljnline."Shortcut Dimension 1 Code" := 'BOSA';
            Gnljnline."Shortcut Dimension 2 Code" := ObjMember."Global Dimension 2 Code";
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 1 Code");
            Gnljnline.Validate(Gnljnline."Shortcut Dimension 2 Code");
            if Gnljnline.Amount <> 0 then
                Gnljnline.Insert;
        end;
    end;


}
