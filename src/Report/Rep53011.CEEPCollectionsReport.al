Report 53011 "CEEP Collections Report"
{
    Caption = 'CEEP Collections Report';
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/CEEP Collections Report.rdlc';
    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.") order(ascending) where("Global Dimension 1 Code" = filter('MICRO'), "Customer Posting Group" = filter('MICRO'), "Group Account" = filter(false));
            // RequestFilterFields = "Global Dimension 2 Code", "Group Officer", "Group Account No", "Date Filter";
            column(No; "No.")
            {
            }
            column(SharesClosingBal; SharesClosingBal)
            {
            }
            column(LoanClosingBal; LoanClosingBal)
            {
            }
            column(InterestClosingBal; InterestClosingBal)
            {
            }
            column(TotalAmountCollected; TotalAmountCollected)
            {
            }
            // column(Group_Account_No; "Group Account No")
            // {
            // }
            column(Name; Name)
            {
            }
            column(Mobile_Phone_No_; "Phone No.")
            {
            }
            column(ID_No_; "ID No.")
            {
            }
            column(SharesBD; SharesBD)
            {
            }
            column(LoanBD; LoanBD)
            {
            }
            column(InterestBD; InterestBD)
            {
            }
            column(SharesCollected; SharesCollected)
            {
            }
            column(LoanCollected; LoanCollected)
            {
            }
            column(InterestCollected; InterestCollected)
            {
            }

            trigger OnPreDataItem()
            begin
                Customer.SetFilter(Customer."Date Filter", DateFilter);
                SharesBD := 0;
                CollectedAmount := 0;
                LoanBD := 0;
                InterestBD := 0;
                SharesCollected := 0;
                LoanCollected := 0;
                InterestCollected := 0;
                TotalAmountCollected := 0;
                SharesClosingBal := 0;
                LoanClosingBal := 0;
                InterestClosingBal := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                //..................1)Get core member details
                //....Name,No,Phoneno,Bal B/D before datefilter,
                if CustomerTable.get(Customer."No.") then begin
                    CustomerTable.SetFilter(CustomerTable."Date Filter", DateFilter);
                    CustomerTable.SetAutoCalcFields(CustomerTable."Current Shares", CustomerTable."Outstanding Balance", CustomerTable."Outstanding Interest");
                    //...........Brought downs
                    SharesBD := 0;
                    SharesBD := GetSharesBeforeFilter(CustomerTable."No.", DateFilter);
                    LoanBD := 0;
                    LoanBD := GetLoansBeforeFilter(CustomerTable."No.", DateFilter);
                    InterestBD := 0;
                    InterestBD := GetInterestBeforeFilter(CustomerTable."No.", DateFilter);
                    //..................2)Get Amount contributed
                    SharesCollected := 0;
                    SharesCollected := GetSharesCollected(CustomerTable."No.", DateFilter);
                    IF SharesCollected <= 0 THEN begin
                        SharesCollected := 0;
                    end;
                    LoanCollected := 0;
                    LoanCollected := GetLoanCollected(CustomerTable."No.", DateFilter);
                    InterestCollected := 0;
                    InterestCollected := GetInterestCollected(CustomerTable."No.", DateFilter);
                    //..................3)Get the closing balance
                    SharesClosingBal := 0;
                    SharesClosingBal := GetSharesClosingBal(CustomerTable."No.", DateFilter);
                    LoanClosingBal := 0;
                    LoanClosingBal := GetLoansClosingBal(CustomerTable."No.", DateFilter);
                    InterestClosingBal := 0;
                    InterestClosingBal := GetInterestClosingBal(CustomerTable."No.", DateFilter);
                    //..........Get Total AMount Collected
                    TotalAmountCollected := 0;
                    TotalAmountCollected := SharesCollected + LoanCollected + InterestCollected;
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
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    trigger OnInitReport()
    begin

    end;

    trigger OnPreReport()
    begin
        DateFilter := Customer.GetFilter(Customer."Date Filter");
        if DateFilter = '' then DateFilter := '..' + Format(Today);
    end;

    trigger OnPostReport()
    begin

    end;

    local procedure GetSharesBeforeFilter(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end;
        if STRLEN(DateFilter) = 18 then begin
            DateBD := 0D;
            // Evaluate(DateBD, CopyStr(DateFilter,1, 100));
            Evaluate(DateBD, CopyStr(DateFilter, 1, 8));
            NewFilter := '';
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                DateBD := 0D;
                Evaluate(DateBD, CopyStr(DateFilter, 1, 100));
                NewFilter := '';
                NewFilter := '..' + Format(CalcDate('-1D', DateBD));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Current Shares");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Current Shares");
        end;
        exit(0);
    end;

    local procedure GetLoansBeforeFilter(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end;
        if STRLEN(DateFilter) = 18 then begin
            DateBD := 0D;
            Evaluate(DateBD, CopyStr(DateFilter, 1, 8));
            NewFilter := '';
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                DateBD := 0D;
                Evaluate(DateBD, CopyStr(DateFilter, 1, 100));
                NewFilter := '';
                NewFilter := '..' + Format(CalcDate('-1D', DateBD));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Outstanding Balance");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Outstanding Balance");
        end;
        exit(0);
    end;

    local procedure GetInterestBeforeFilter(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end;
        if STRLEN(DateFilter) = 18 then begin
            DateBD := 0D;
            Evaluate(DateBD, CopyStr(DateFilter, 1, 8));
            NewFilter := '';
            NewFilter := '..' + Format((CalcDate('-1D', DateBD)));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                DateBD := 0D;
                Evaluate(DateBD, CopyStr(DateFilter, 1, 100));
                NewFilter := '';
                NewFilter := '..' + Format(CalcDate('-1D', DateBD));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Outstanding Interest");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Outstanding Interest");
        end;
        exit(0);
    end;

    local procedure GetSharesCollected(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            NewFilter := DateFilter;
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := DateFilter;
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Current Shares");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Current Shares");
        end;
        exit(0);
    end;

    local procedure GetLoanCollected(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            NewFilter := DateFilter;
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := DateFilter;
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Principal Paid");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Principal Paid");
        end;
        exit(0);
    end;

    local procedure GetInterestCollected(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            NewFilter := DateFilter;
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := DateFilter;
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Interest Paid");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Interest Paid");
        end;
        exit(0);
    end;

    local procedure GetSharesClosingBal(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            Evaluate(DateBD, CopyStr(DateFilter, 11, 100));
            NewFilter := '..' + Format((DateBD));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := '..' + Format((DateFilter));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Current Shares");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Current Shares");
        end;
        exit(0);
    end;

    local procedure GetLoansClosingBal(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            Evaluate(DateBD, CopyStr(DateFilter, 11, 100));
            NewFilter := '..' + Format((DateBD));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := '..' + Format((DateFilter));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Outstanding Balance");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Outstanding Balance");
        end;
        exit(0);
    end;

    local procedure GetInterestClosingBal(No: Code[20]; DateFilter: Text): Decimal
    var
        CustomerRecord: Record Customer;
        NewFilter: Text;
        DateBD: date;
    begin
        if CopyStr(DateFilter, 1, 2) = '..' then begin
            Evaluate(DateBD, CopyStr(DateFilter, 3, 100));
            NewFilter := '..' + Format((DateBD));
        end;
        if STRLEN(DateFilter) = 18 then begin
            NewFilter := '';
            Evaluate(DateBD, CopyStr(DateFilter, 11, 100));
            NewFilter := '..' + Format((DateBD));
        end
        else
            if CopyStr(DateFilter, 1, 8) = DateFilter then begin
                NewFilter := '';
                NewFilter := '..' + Format((DateFilter));
            end;
        CustomerRecord.Reset();
        CustomerRecord.SetRange(CustomerRecord."Global Dimension 1 Code", 'MICRO');
        CustomerRecord.SetRange(CustomerRecord."No.", No);
        CustomerRecord.SetFilter(CustomerRecord."Date Filter", NewFilter);
        CustomerRecord.SetAutoCalcFields(CustomerRecord."Outstanding Interest");
        if CustomerRecord.Find('-') then begin
            exit(CustomerRecord."Outstanding Interest");
        end;
        exit(0);
    end;

    var
        DateFilter: Text;
        SharesBD: Decimal;
        CollectedAmount: Decimal;
        CustomerTable: Record Customer;
        LoanBD: Decimal;
        InterestBD: Decimal;
        SharesCollected: Decimal;
        LoanCollected: Decimal;
        InterestCollected: Decimal;
        TotalAmountCollected: Decimal;
        SharesClosingBal: Decimal;
        LoanClosingBal: Decimal;
        InterestClosingBal: Decimal;

}
