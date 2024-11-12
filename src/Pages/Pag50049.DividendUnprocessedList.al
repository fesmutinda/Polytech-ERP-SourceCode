#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 50049 "Dividend Unprocessed List"
{
    PageType = List;
    SourceTable = "Dividends Registerd";
    SourceTableView = where(Processed = const(No));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Member Name"; Rec."Member Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Enabled = false;
                }
                field("Payroll no"; Rec."Payroll no")
                {
                    ApplicationArea = Basic;
                }
                field("Dividend year"; Rec."Dividend year")
                {
                    ApplicationArea = Basic;
                }
                field(DividendAmount; DividendAmount)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Enabled = false;
                }
                field("Amount To Bank"; Rec."Amount To Bank")
                {
                    ApplicationArea = Basic;
                }
                field("Share Capital"; Rec."Share Capital")
                {
                    ApplicationArea = Basic;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = Basic;
                }
                field("Gross Dividend"; Rec."Gross Dividend")
                {
                    ApplicationArea = Basic;
                }
                field("Dont Pay"; Rec."Dont Pay")
                {
                    ApplicationArea = Basic;
                }
                field(Pay; Rec.Pay)
                {
                    ApplicationArea = Basic;
                    Caption = 'Pay To Bank';
                }
                field("Pay to Deposit"; Rec."Pay to Deposit")
                {
                    ApplicationArea = Basic;
                }
                field("Pay to Loan"; Rec."Pay to Loan")
                {
                    ApplicationArea = Basic;
                }
                label(Control25)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(ActionGroup17)
            {
            }
            action("Process Dividend to Bank")
            {
                ApplicationArea = Basic;
                Image = Bank;
                Promoted = true;
                RunObject = Report UnknownReport51516608;
            }
            action("Process Dividend to Loan")
            {
                ApplicationArea = Basic;
                Image = Payment;
                Promoted = true;
                Visible = false;

                trigger OnAction()
                begin
                    BATCH_TEMPLATE := 'General';
                    BATCH_NAME := 'DIVIDEND';
                    DOCUMENT_NO := 'DIVIDEND';
                    //cj
                    FnTransferToLoan();
                    Message('succefully Transfered To Journal');
                end;
            }
            action("Processing Dividend Transfer d&s")
            {
                ApplicationArea = Basic;
                Image = Payment;
                Promoted = true;
                RunObject = Report UnknownReport51516611;

                trigger OnAction()
                begin
                    /*BATCH_TEMPLATE:='PAYMENTS';
                    BATCH_NAME:='DIVIDEND';
                    DOCUMENT_NO:='DIVIDEND';
                    ObjGensetup.GET();
                    PostingDate:=TODAY;
                    RunnAmount:=0;
                    InterestAmount:=0;
                    outstandingBal:=0;
                    
                    GenJournalLine.RESET;
                    GenJournalLine.SETRANGE("Journal Template Name",BATCH_TEMPLATE);
                    GenJournalLine.SETRANGE("Journal Batch Name",BATCH_NAME);
                    GenJournalLine.DELETEALL;
                    ObjGensetup.GET();
                    
                    
                    RunBal:=0;
                    Pfee:=0;
                    PfeeEX:=0;
                    LoanAmount:=0;
                    ///***************************************************************
                    DIVREG.RESET;
                    DIVREG.SETRANGE(DIVREG."Member No","Member No");
                    IF DIVREG.FIND ('-') THEN BEGIN
                     REPEAT
                    Cust.RESET;
                    Cust.SETRANGE(Cust."No.","Member No");
                    IF Cust.FIND('-') THEN BEGIN
                    // REPEAT
                    Cust.CALCFIELDS(Cust."Dividend Amount");
                    
                    IF Cust."Dividend Amount" > 0 THEN BEGIN
                    
                    //*****************************************************************************************bank
                    IF DIVREG.Pay = TRUE THEN BEGIN
                    
                    FnTransferToBank ();
                    
                    END ELSE
                    //*****************************************************************************************Loan
                    IF DIVREG."Pay to Loan" = TRUE THEN BEGIN
                    
                    FnTransferToLoan();
                    
                    END ELSE
                    //*****************************************************************************************Deposit
                    IF DIVREG."Pay to Deposit" = TRUE THEN BEGIN
                    
                       FnTransferToDesposit();
                    
                      END;
                    //*****************************************************************************************post
                    
                    END;
                    //UNTIL Cust.NEXT=0;
                    END;
                    // DIVREG.Processed:=TRUE;
                    // DIVREG."Amount Payed":=Cust."Dividend Amount";
                    // DIVREG.MODIFY;
                    
                    UNTIL DIVREG.NEXT = 0;
                    
                    
                    END;
                      //CU posting
                    //   GenJournalLine.RESET;
                    //   GenJournalLine.SETRANGE("Journal Template Name",'PAYMENTS');
                    //   GenJournalLine.SETRANGE("Journal Batch Name",'DIVIDEND');
                    //   IF GenJournalLine.FIND('-') THEN
                    //   CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post",GenJournalLine);
                    
                    MESSAGE('Process Complete');
                    */

                end;
            }
            action("Processing Dividend Transfer")
            {
                ApplicationArea = Basic;
                Image = Payment;
                Promoted = true;
                RunObject = Report UnknownReport51516611;
                Visible = false;
            }
            action("Fetch Dividends Payment List")
            {
                ApplicationArea = Basic;
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Report UnknownReport51516615;
                Visible = false;
            }
            action("POST GENERATED LIST")
            {
                ApplicationArea = Basic;
                Image = POST;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Report UnknownReport51516617;
                Visible = false;

                trigger OnAction()
                begin
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'PAYMENTS');
                    GenJournalLine.SetRange("Journal Batch Name", 'DIVIDEND');
                    if GenJournalLine.Find('-') then begin
                        GenJournalLine.DeleteAll;
                    end;
                    /*
                    BATCH_TEMPLATE:='PAYMENTS';
                    BATCH_NAME:='DIVIDEND';
                    DOCUMENT_NO:='DIVIDEND';
                    
                    DividendsRegisterd.RESET;
                    SETCURRENTKEY("Member No");
                    DividendsRegisterd.SETRANGE (DividendsRegisterd."Member No","Member No");
                    DividendsRegisterd.SETRANGE(DividendsRegisterd.Pay,TRUE);
                    IF DividendsRegisterd.FINDSET THEN BEGIN
                      REPEAT
                        MESSAGE('Processing Completed');
                      IF (TRANSFER=TRUE) THEN BEGIN
                        FnTransferToBank();
                      END
                      ELSE IF ("Pay to Deposit"=TRUE) THEN BEGIN
                        FnTransferToDesposit();
                      END
                      ELSE
                      IF ("Pay to Loan"=TRUE) THEN BEGIN
                       FnTransferToLoan();
                      END;
                      UNTIL DividendsRegisterd.NEXT=0;
                    END;
                    
                       GenJournalLine.RESET;
                       GenJournalLine.SETRANGE("Journal Template Name",BATCH_TEMPLATE);
                       GenJournalLine.SETRANGE("Journal Batch Name",BATCH_NAME);
                       IF GenJournalLine.FIND('-') THEN BEGIN
                          CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post",GenJournalLine);
                          Processed:=TRUE;
                       END;
                    
                    
                    MESSAGE('Processing Completed');
                    */

                end;
            }
            action(journal)
            {
                ApplicationArea = Basic;
                Image = Journal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "General Journal";

                trigger OnAction()
                begin
                    GenJournalLine.Reset;
                    GenJournalLine.SetRange("Journal Template Name", 'PAYMENTS');
                    GenJournalLine.SetRange("Journal Batch Name", 'DIVIDEND');
                    if GenJournalLine.Find('-') then begin
                        GenJournalLine.DeleteAll;
                    end;
                    /*
                    BATCH_TEMPLATE:='PAYMENTS';
                    BATCH_NAME:='DIVIDEND';
                    DOCUMENT_NO:='DIVIDEND';
                    
                    DividendsRegisterd.RESET;
                    SETCURRENTKEY("Member No");
                    DividendsRegisterd.SETRANGE (DividendsRegisterd."Member No","Member No");
                    DividendsRegisterd.SETRANGE(DividendsRegisterd.Pay,TRUE);
                    IF DividendsRegisterd.FINDSET THEN BEGIN
                      REPEAT
                        MESSAGE('Processing Completed');
                      IF (TRANSFER=TRUE) THEN BEGIN
                        FnTransferToBank();
                      END
                      ELSE IF ("Pay to Deposit"=TRUE) THEN BEGIN
                        FnTransferToDesposit();
                      END
                      ELSE
                      IF ("Pay to Loan"=TRUE) THEN BEGIN
                       FnTransferToLoan();
                      END;
                      UNTIL DividendsRegisterd.NEXT=0;
                    END;
                    
                       GenJournalLine.RESET;
                       GenJournalLine.SETRANGE("Journal Template Name",BATCH_TEMPLATE);
                       GenJournalLine.SETRANGE("Journal Batch Name",BATCH_NAME);
                       IF GenJournalLine.FIND('-') THEN BEGIN
                          CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post",GenJournalLine);
                          Processed:=TRUE;
                       END;
                    
                    
                    MESSAGE('Processing Completed');
                    */

                end;
            }
            action(Import)
            {
                ApplicationArea = Basic;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = XMLport UnknownXMLport50060;
                Visible = false;
            }
            action(Validate)
            {
                ApplicationArea = Basic;
                Image = VATEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Report UnknownReport51516640;
                Visible = false;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Cust.Reset;
        Cust.SetRange(Cust."No.", Rec."Member No");
        if Cust.Find('-') then begin
            Cust.CalcFields("Dividend Amount");
            DividendAmount := Cust."Dividend Amount";
            //"Dividend Amount":=DividendAmount;
            Modify;
        end;
    end;

    var
        MjDividendsRegisterd: Record 51516099;
        DIVREG: Record 51516099;
        DividendAmount: Decimal;
        Jtemplate: Code[20];
        JBatch: Code[20];
        SwizzsoftFactory: Codeunit UnknownCodeunit51516007;
        TotalAmount: Decimal;
        DivProg: Record 51516393;
        GenSetup: Record 51516398;
        LastFieldNo: Integer;
        FooterPrinted: Boolean;
        LoanCount: Integer;
        LoansReg: Record 51516371;
        TotalLoanAmount: Decimal;
        LoanAmount: Decimal;
        LoanInt: Decimal;
        Sdividend: Decimal;
        RunBal: Decimal;
        Pfee: Decimal;
        PfeeEX: Decimal;
        Cust: Record 51516364;
        StartDate: Date;
        DateFilter: Text[100];
        FromDate: Date;
        ToDate: Date;
        FromDateS: Text[100];
        ToDateS: Text[100];
        DivTotal: Decimal;
        CDeposits: Decimal;
        CustDiv: Record 51516364;
        CDiv: Decimal;
        CInterest: Decimal;
        BDate: Date;
        CustR: Record 51516364;
        IntRebTotal: Decimal;
        CIntReb: Decimal;
        LineNo: Integer;
        Gnjlline: Record "Gen. Journal Line";
        PostingDate: Date;
        "W/Tax": Decimal;
        CommDiv: Decimal;
        GenJournalLine: Record "Gen. Journal Line";
        SFactory: Codeunit UnknownCodeunit51516007;
        BATCH_NAME: Code[50];
        BATCH_TEMPLATE: Code[50];
        DOCUMENT_NO: Code[50];
        ObjGensetup: Record 51516398;
        RunnAmount: Decimal;
        InterestAmount: Decimal;
        OutBalAmount: Decimal;
        outstandingBal: Decimal;
        DividendsRegisterd: Record 51516099;
        amountpayable: Decimal;
        payrollno: Code[30];

    local procedure FnTransferToBank()
    var
        DividendsRegisterd: Record 51516099;
    begin
        LineNo := LineNo + 1000;
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name" := BATCH_NAME;
        GenJournalLine."Document No." := DOCUMENT_NO;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
        GenJournalLine."Account No." := Rec."Member No";
        "Dividends Registerd"."Member No";
        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Dividend;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."Posting Date" := Today;
        GenJournalLine.Description := 'Dividend Bal transfer to Bank A/c- ' + Format(PostingDate);
        GenJournalLine.Amount := DividendAmount;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
        GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"Bank Account";
        GenJournalLine."Bal. Account No." := 'BNK_0001';
        GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
        GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
    end;

    local procedure FnTransferToLoan()
    var
        DividendsRegisterd: Record 51516099;
    begin
        /* IF "Pay to Loan" = TRUE THEN BEGIN
        LineNo:=LineNo+100;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name":=BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name":=BATCH_NAME;
        GenJournalLine."Document No.":=DOCUMENT_NO;
        GenJournalLine."Line No.":=LineNo;
        GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
        GenJournalLine."Account No.":="Member No";
        GenJournalLine."Transaction Type":=GenJournalLine."Transaction Type"::"Loan Repayment";
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Posting Date":=TODAY;
        GenJournalLine.Description:='Dividend Transfer to Loan'+FORMAT(TODAY);
        GenJournalLine.Amount:=-"Amount To Loan";
        GenJournalLine."Loan No" := "Loan No.";
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        GenJournalLine.VALIDATE( GenJournalLine."Transaction Type");
        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
         IF GenJournalLine.Amount<>0 THEN
         GenJournalLine.INSERT;
         //*************************************************************************************************
        
         LineNo:=LineNo+1000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name":=BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name":=BATCH_NAME;
        GenJournalLine."Document No.":=DOCUMENT_NO;
        GenJournalLine."Line No.":=LineNo;
        GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
        GenJournalLine."Account No.":="Member No";
        GenJournalLine."Transaction Type":=GenJournalLine."Transaction Type"::"Interest Paid";
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Posting Date":=TODAY;
        GenJournalLine.Description:='Dividend Transfer to Interest'+FORMAT(TODAY);
        GenJournalLine.Amount:=-"Amount To interest";
        GenJournalLine."Loan No" := "Loan No.";
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        GenJournalLine.VALIDATE( GenJournalLine."Transaction Type");
        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
         IF GenJournalLine.Amount<>0 THEN
         GenJournalLine.INSERT;
        
        LineNo:=LineNo+10000;
        GenJournalLine.INIT;
        GenJournalLine."Journal Template Name":=BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name":=BATCH_NAME;
        GenJournalLine."Document No.":=DOCUMENT_NO;
        GenJournalLine."Line No.":=LineNo;
        GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
        GenJournalLine."Account No.":="Member No";
        GenJournalLine."Transaction Type":=GenJournalLine."Transaction Type"::Dividend;
        GenJournalLine.VALIDATE(GenJournalLine."Account No.");
        GenJournalLine."Posting Date":=TODAY;
        GenJournalLine.Description:='Dividend Transfer to Loan '+FORMAT(TODAY);
        GenJournalLine.Amount:=("Amount To Loan"+"Amount To interest");
        GenJournalLine.VALIDATE(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
        IF GenJournalLine.Amount<>0 THEN
        GenJournalLine.INSERT;
        
        END;*/


        amountpayable := 0;
        InterestAmount := 0;
        outstandingBal := 0;
        LoansReg.Reset;
        LoansReg.SetRange("Client Code", Rec."Member No");
        LoansReg.SetAutocalcFields(LoansReg."Outstanding Balance", LoansReg."Oustanding Interest");
        if LoansReg.Find('-') then begin
            repeat
                // IF (LoansReg."Outstanding Balance"+LoansReg."Oustanding Interest")>DividendAmount THEN BEGIN
                if LoansReg."Amount in Arrears" > DividendAmount then begin
                    amountpayable := LoansReg."Amount in Arrears";//(LoansReg."Outstanding Balance"+LoansReg."Oustanding Interest");
                end else if
               LoansReg."Amount in Arrears" <= DividendAmount then begin
                    amountpayable := DividendAmount;
                end;
                //...........................................................
                if LoansReg."Oustanding Interest" > 0 then begin
                    if LoansReg."Oustanding Interest" > amountpayable then begin
                        InterestAmount := amountpayable;
                    end
                    else if LoansReg."Oustanding Interest" <= amountpayable then begin
                        InterestAmount := LoansReg."Oustanding Interest";
                    end;
                    LineNo := LineNo + 1000;
                    GenJournalLine.Init;
                    GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
                    GenJournalLine."Journal Batch Name" := BATCH_NAME;
                    GenJournalLine."Document No." := DOCUMENT_NO;
                    GenJournalLine."Line No." := LineNo;
                    GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                    GenJournalLine."Account No." := Rec."Member No";
                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Paid";
                    GenJournalLine.Validate(GenJournalLine."Account No.");
                    GenJournalLine."Posting Date" := Today;
                    GenJournalLine.Description := 'Dividend payment to Loan ' + Format(Today);
                    GenJournalLine.Amount := -InterestAmount;
                    GenJournalLine.Validate(GenJournalLine.Amount);
                    GenJournalLine."Loan No" := LoansReg."Loan  No.";
                    GenJournalLine.Validate(GenJournalLine."Transaction Type");
                    GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                    if GenJournalLine.Amount <> 0 then
                        GenJournalLine.Insert;
                end;
                //............................................................
                if LoansReg."Outstanding Balance" > (DividendAmount - InterestAmount) then begin
                    outstandingBal := DividendAmount - InterestAmount;
                end
                else if LoansReg."Outstanding Balance" <= (DividendAmount - InterestAmount) then begin
                    outstandingBal := (LoansReg."Outstanding Balance");
                end;
                LineNo := LineNo + 10000;
                GenJournalLine.Init;
                GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
                GenJournalLine."Journal Batch Name" := BATCH_NAME;
                GenJournalLine."Document No." := DOCUMENT_NO;
                GenJournalLine."Line No." := LineNo;
                GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
                GenJournalLine."Account No." := Rec."Member No";
                GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Loan Repayment";
                GenJournalLine.Validate(GenJournalLine."Account No.");
                GenJournalLine."Posting Date" := Today;
                GenJournalLine.Description := 'Dividend payment to Loan ' + Format(Today);
                GenJournalLine.Amount := -outstandingBal;
                GenJournalLine.Validate(GenJournalLine.Amount);
                GenJournalLine."Loan No" := LoansReg."Loan  No.";
                GenJournalLine.Validate(GenJournalLine."Transaction Type");
                GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
                if GenJournalLine.Amount <> 0 then
                    GenJournalLine.Insert;
                ///..............................................................
                // // RunnAmount:=(DividendAmount-(outstandingBal+InterestAmount));
                // // IF RunnAmount>0 THEN BEGIN
                // //  //........................Take to bank
                // //            LineNo:=LineNo+100000;
                // //            GenJournalLine.INIT;
                // //            GenJournalLine."Journal Template Name":=BATCH_TEMPLATE;
                // //            GenJournalLine."Journal Batch Name":=BATCH_NAME;
                // //            GenJournalLine."Document No.":=DOCUMENT_NO;
                // //            GenJournalLine."Line No.":=LineNo;
                // //            GenJournalLine."Account Type":=GenJournalLine."Account Type"::"Bank Account";
                // //            GenJournalLine."Account No.":='BNK_0001';
                // //            GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                // //            GenJournalLine."Posting Date":=TODAY;
                // //            GenJournalLine.Description:='Dividend Transfer to Bank A/c- '+FORMAT(TODAY);
                // //            GenJournalLine.Amount:=-RunnAmount;
                // //            GenJournalLine.VALIDATE(GenJournalLine.Amount);
                // //            GenJournalLine."Shortcut Dimension 1 Code":='BOSA';
                // //            GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                // //             IF GenJournalLine.Amount<>0 THEN
                // //             GenJournalLine.INSERT;
                // // END;
                //.............................................Remove amounta from member account

                //**************************************************************************************************
                Rec."Pay to Loan" := true;
                Rec.Modify;

            until LoansReg.Next = 0;
            LineNo := LineNo + 1000000;
            GenJournalLine.Init;
            GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
            GenJournalLine."Journal Batch Name" := BATCH_NAME;
            GenJournalLine."Document No." := DOCUMENT_NO;
            GenJournalLine."Line No." := LineNo;
            GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
            GenJournalLine."Account No." := Rec."Member No";
            GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Dividend;
            GenJournalLine.Validate(GenJournalLine."Account No.");
            GenJournalLine."Posting Date" := Today;
            GenJournalLine.Description := 'Dividend Transfer to Loan ' + Format(Today);
            GenJournalLine.Amount := DividendAmount;
            GenJournalLine.Validate(GenJournalLine.Amount);
            GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
            if GenJournalLine.Amount <> 0 then
                GenJournalLine.Insert;
        end;

        GenJournalLine.Reset;
        GenJournalLine.SetRange("Journal Template Name", 'BATCH_TEMPLATE');
        GenJournalLine.SetRange("Journal Batch Name", 'BATCH_NAME');
        if GenJournalLine.Find('-') then
;

        local procedure FnTransferToDesposit()
    var
        DividendsRegisterd: Record 51516099;
    begin
        LineNo := LineNo + 10000;
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name" := BATCH_NAME;
        GenJournalLine."Document No." := DOCUMENT_NO;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
        GenJournalLine."Account No." := Rec."Member No";
        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Deposit Contribution";
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."Posting Date" := Today;
        GenJournalLine.Description := 'Dividend payment to Deposit ' + Format(Today);
        GenJournalLine.Amount := -DividendAmount;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine.Validate(GenJournalLine."Transaction Type");
        GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;


        LineNo := LineNo + 10000;
        GenJournalLine.Init;
        GenJournalLine."Journal Template Name" := BATCH_TEMPLATE;
        GenJournalLine."Journal Batch Name" := BATCH_NAME;
        GenJournalLine."Document No." := DOCUMENT_NO;
        GenJournalLine."Line No." := LineNo;
        GenJournalLine."Account Type" := GenJournalLine."account type"::Member;
        GenJournalLine."Account No." := Rec."Member No";
        GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::Dividend;
        GenJournalLine.Validate(GenJournalLine."Account No.");
        GenJournalLine."Posting Date" := Today;
        GenJournalLine.Description := 'Dividend Bal transfer to Loan ' + Format(Today);
        GenJournalLine.Amount := DividendAmount;
        GenJournalLine.Validate(GenJournalLine.Amount);
        GenJournalLine."Shortcut Dimension 1 Code" := 'BOSA';
        if GenJournalLine.Amount <> 0 then
            GenJournalLine.Insert;
        //********************************************************************************
    end;
}

