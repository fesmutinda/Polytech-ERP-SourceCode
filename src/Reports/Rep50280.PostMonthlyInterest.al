#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50280 "Post Monthly Interest."
{
    // DefaultLayout = RDLC;
    // RDLCLayout = './Layouts/Post Monthly Interest..rdlc';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Loans Register"; "Loans Register")
        {
            CalcFields = "Outstanding Balance";
            RequestFilterFields = "Date filter", "Issued Date", "Loan  No.", "Client Code";
            column(ReportForNavId_4645; 4645)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Loans__Loan__No__; "Loan  No.")
            {
            }
            column(Loans__Application_Date_; "Application Date")
            {
            }
            column(Loans__Loan_Product_Type_; "Loan Product Type")
            {
            }
            column(Loans__Client_Code_; "Client Code")
            {
            }
            column(Loans__Client_Name_; "Client Name")
            {
            }
            column(Loans__Outstanding_Balance_; "Outstanding Balance")
            {
            }
            column(Loan_Application_FormCaption; Loan_Application_FormCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Loans__Loan__No__Caption; FieldCaption("Loan  No."))
            {
            }
            column(Loans__Application_Date_Caption; FieldCaption("Application Date"))
            {
            }
            column(Loans__Loan_Product_Type_Caption; FieldCaption("Loan Product Type"))
            {
            }
            column(Loans__Client_Code_Caption; FieldCaption("Client Code"))
            {
            }
            column(Loans__Client_Name_Caption; FieldCaption("Client Name"))
            {
            }
            column(Loans__Outstanding_Balance_Caption; FieldCaption("Outstanding Balance"))
            {
            }

            trigger OnAfterGetRecord()
            begin
                PDate := "Loans Register".GetRangemax("Loans Register"."Date filter");
                SDATE := '..' + Format(PDate);
                DocNo := Format(PostDate);
                loanapp.Reset;
                loanapp.SetRange(loanapp."Loan  No.", "Loans Register"."Loan  No.");
                loanapp.SetFilter(loanapp."Date filter", SDATE);
                if loanapp.Find('-') then begin
                    repeat
                        loanapp.CalcFields(loanapp."Outstanding Balance");
                        if loanapp."Outstanding Balance" > 0 then begin

                            Cust.Reset;
                            Cust.SetRange(Cust."No.", "Loans Register"."Client Code");
                            Cust.SetFilter(Cust.Blocked, '%1', Cust.Blocked::" ");
                            Cust.SetFilter(Cust."Don't Charge Interest", '%1', false);
                            if Cust.FindSet then begin
                                repeat
                                    LineNo := LineNo + 10000;
                                    GenJournalLine.Init;
                                    GenJournalLine."Journal Template Name" := 'General';
                                    GenJournalLine."Journal Batch Name" := 'INT DUE';
                                    GenJournalLine."Line No." := LineNo;
                                    GenJournalLine."Account Type" := GenJournalLine."account type"::Customer;
                                    GenJournalLine."Account No." := loanapp."Client Code";
                                    GenJournalLine."Transaction Type" := GenJournalLine."transaction type"::"Interest Due";
                                    GenJournalLine.Validate(GenJournalLine."Account No.");
                                    GenJournalLine."Document No." := DocNo;
                                    GenJournalLine."Posting Date" := PostDate;
                                    GenJournalLine.Description := 'INT Charged' + ' ' + Format(PostDate);
                                    if LoanType.Get(loanapp."Loan Product Type") then begin
                                        GenJournalLine.Amount := ROUND(loanapp."Outstanding Balance" * (LoanType."Interest rate" / 1200), 1, '>');
                                        GenJournalLine.Validate(GenJournalLine.Amount);
                                        GenJournalLine."Bal. Account Type" := GenJournalLine."bal. account type"::"G/L Account";
                                        GenJournalLine."Bal. Account No." := LoanType."Loan Interest Account";
                                        GenJournalLine."Loan Product Type" := LoanType.Code;
                                        GenJournalLine.Validate(GenJournalLine."Bal. Account No.");
                                    end;
                                    if loanapp.Source = loanapp.Source::BOSA then begin
                                        GenJournalLine."Shortcut Dimension 1 Code" := Cust."Global Dimension 1 Code";
                                        GenJournalLine."Shortcut Dimension 2 Code" := Cust."Global Dimension 2 Code";
                                    end;
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 1 Code");
                                    GenJournalLine.Validate(GenJournalLine."Shortcut Dimension 2 Code");
                                    GenJournalLine."Loan No" := loanapp."Loan  No.";

                                    if GenJournalLine.Amount <> 0 then
                                        GenJournalLine.Insert;
                                until cust.Next = 0;
                            end;


                        end;

                    until loanapp.Next = 0;
                end;
                /* loanapp.RESET;
                 loanapp.SETRANGE(loanapp."Loan  No.","Loan  No.");
                 loanapp.SETFILTER(loanapp."Date filter",SDATE);
                 IF loanapp.FIND('-') THEN BEGIN
                 loanapp.CALCFIELDS(loanapp."Outstanding Balance");
                 IF loanapp."Outstanding Balance" > 0 THEN BEGIN
                 IF loanapp."Approved Amount" > 100000 THEN BEGIN
                 LineNo:=LineNo+10000;
                    GenJournalLine.INIT;
                    GenJournalLine."Journal Template Name":='General';
                    GenJournalLine."Journal Batch Name":='INT DUE';
                    GenJournalLine."Line No.":=LineNo;
                    GenJournalLine."Account Type":=GenJournalLine."Account Type"::Member;
                    GenJournalLine."Account No.":= loanapp."Client Code";
                    GenJournalLine."Transaction Type":=GenJournalLine."Transaction Type"::"Insurance Charge";
                    GenJournalLine.VALIDATE(GenJournalLine."Account No.");
                    GenJournalLine."Document No.":=DocNo;
                    GenJournalLine."Posting Date":=PostDate;
                    GenJournalLine.Description:=DocNo+' '+'Insurance charged';
                    GenJournalLine.Amount:=ROUND( loanapp."Outstanding Balance"*( 0.0166667/100),1,'>');
                    GenJournalLine.VALIDATE(GenJournalLine.Amount);
                     IF LoanType.GET(loanapp."Loan Product Type") THEN BEGIN
                    GenJournalLine."Bal. Account Type":=GenJournalLine."Bal. Account Type"::"G/L Account";
                    GenJournalLine."Bal. Account No.":=LoanType."Loan Insurance Accounts";
                    GenJournalLine.VALIDATE(GenJournalLine."Bal. Account No.");
                    END;
                    IF  loanapp.Source= loanapp.Source::BOSA THEN BEGIN
                    GenJournalLine."Shortcut Dimension 1 Code":='BOSA' ;
                    GenJournalLine."Shortcut Dimension 2 Code":= 'NAIROBI';
                    END;
                    IF  loanapp.Source= loanapp.Source::FOSA THEN BEGIN
                    GenJournalLine."Shortcut Dimension 1 Code":='FOSA' ;
                    GenJournalLine."Shortcut Dimension 2 Code":= 'NAIROBI';
                    END;
                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 1 Code");
                    GenJournalLine.VALIDATE(GenJournalLine."Shortcut Dimension 2 Code");
                    GenJournalLine."Loan No":= loanapp."Loan  No.";
                    IF GenJournalLine.Amount<>0 THEN
                    GenJournalLine.INSERT;
                 END;
                 END;
                 END;*/
                /*
                //Post New
                GenJournalLine.RESET;
                GenJournalLine.SETRANGE("Journal Template Name",'General');
                GenJournalLine.SETRANGE("Journal Batch Name",'INT DUE');
                IF GenJournalLine.FIND('-') THEN BEGIN
                CODEUNIT.RUN(CODEUNIT::"Gen. Jnl.-Post B",GenJournalLine);
                END; */
                //Post New

            end;

            trigger OnPostDataItem()
            begin

                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'General');
                GenJournalLine.SetRange("Journal Batch Name", 'INT DUE');
                page.Run(Page::"General Journal");

            end;

            trigger OnPreDataItem()
            begin
                if PostDate = 0D then
                    Error('Please create Interest period');

                // if DocNo = '' then
                //     Error('You must specify the Document No.');


                //delete journal line
                GenJournalLine.Reset;
                GenJournalLine.SetRange("Journal Template Name", 'General');
                GenJournalLine.SetRange("Journal Batch Name", 'INT DUE');
                GenJournalLine.DeleteAll;
                //end of deletion

                GenBatches.Reset;
                GenBatches.SetRange(GenBatches."Journal Template Name", 'General');
                GenBatches.SetRange(GenBatches.Name, 'INT DUE');
                if GenBatches.Find('-') = false then begin
                    GenBatches.Init;
                    GenBatches."Journal Template Name" := 'General';
                    GenBatches.Name := 'INT DUE';
                    GenBatches.Description := 'Interest Due';
                    //GenBatches.VALIDATE(GenBatches."Journal Template Name");
                    //GenBatches.VALIDATE(GenBatches.Name);
                    GenBatches.Insert;
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(PostDate; PostDate)
                {
                    ApplicationArea = Basic;
                    Caption = 'Posting Date';
                    Editable = true;
                }
                // field(DocNo; DocNo)
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'Document No.';
                //     Editable = true;
                // }


            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        //Accounting periods
        AccountingPeriod.SetRange(AccountingPeriod.Closed, false);
        if AccountingPeriod.Find('-') then begin
            FiscalYearStartDate := AccountingPeriod."Interest Calcuation Date";
            PostDate := (FiscalYearStartDate);
            DocNo := AccountingPeriod.Name + '  ' + Format(PostDate);
        end;
        //Accounting periods
    end;

    var
        GenBatches: Record "Gen. Journal Batch";
        PDate: Date;
        LoanType: Record "Loan Products Setup";
        PostDate: Date;
        Cust: Record Customer;

        LineNo: Integer;
        DocNo: Code[20];
        GenJournalLine: Record "Gen. Journal Line";
        GLPosting: Codeunit "Gen. Jnl.-Post Line";
        EndDate: Date;
        DontCharge: Boolean;
        Temp: Record "Funds User Setup";
        JBatch: Code[10];
        Jtemplate: Code[10];
        CustLedger: Record "ReceiptsProcessing_L-Checkoff";
        AccountingPeriod: Record "Interest Due Period";
        FiscalYearStartDate: Date;
        "ExtDocNo.": Text[30];
        Loan_Application_FormCaptionLbl: label 'Loan Application Form';
        CurrReport_PAGENOCaptionLbl: label 'Page';
        loanapp: Record "Loans Register";
        SDATE: Text[30];
}

