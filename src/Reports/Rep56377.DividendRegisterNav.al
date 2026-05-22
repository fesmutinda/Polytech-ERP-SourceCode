#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 56377 "Dividend Register Nav"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Nav Layouts/Dividend Register.rdlc';

    dataset
    {
        dataitem(Customer; Customer)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = Status, "Date Filter", "Employer Code", "Dividend Amount", "Mode of Dividend Payment", "Dividends Capitalised %", "Customer Type", "Net Dividend Payable", "No.";
            column(ReportForNavId_6836; 6836)
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
            column(Customer__No__; Customer."No.")
            {
            }
            column(Company_Address; Company.Address)
            {
            }
            column(Company_Address2; Company."Address 2")
            {
            }
            column(Company_PhoneNo; Company."Phone No.")
            {
            }
            column(Company_Email; Company."E-Mail")
            {
            }
            column(Company_Picture; Company.Picture)
            {
            }
            column(Customer__Payroll_Staff_No_; "Personal No")
            {
            }
            column(Customer_Name; Customer.Name)
            {
            }
            column(Customer_Customer__Qualifying_Shares_; Customer."Qualifying Shares")
            {
            }
            column(Customer__Dividend_Amount_; "Dividend Amount")
            {
            }
            column(WithholdingTax; WithholdingTax)
            {
            }
            column(DividendWithholdingTax; Customer."Dividend Withholding Tax")
            {
            }
            column(DividendCapitalized; DividendCapitalized)
            {
            }
            column(DividendCapitalizedNew; Customer."Dividend Capitalized")
            {
            }
            column(SharesDiv; SharesDiv)
            {
            }
            column(CurrentShares; Customer."Current Shares")
            {
            }
            column(PayableDiv; Customer."Net Dividend Payable")
            {
            }
            column(Customer__Dividend_Amount__Control1000000022; "Dividend Amount")
            {
            }
            column(TWTax; TWTax)
            {
            }
            column(GrossDividend; Customer."Gross Dividend Amount Payable")
            {
            }
            column(TPDiv; TPDiv)
            {
            }
            column(RetainedShares; Customer."Shares Retained")
            {
            }
            column(TSharesDiv; TSharesDiv)
            {
            }
            column(Dividend_Amount____TSharesDiv; "Dividend Amount" - TSharesDiv)
            {
            }
            column(TDividendCapitalized; TDividendCapitalized)
            {
            }
            column(Dividends_RegisterCaption; Dividends_RegisterCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Customer__No__Caption; FieldCaption("No."))
            {
            }
            column(Customer__Payroll_Staff_No_Caption; FieldCaption("Personal No"))
            {
            }
            column(Customer_NameCaption; FieldCaption(Name))
            {
            }
            column(Qualifying_SharesCaption; Qualifying_SharesCaptionLbl)
            {
            }
            column(Gross_DividendsCaption; Gross_DividendsCaptionLbl)
            {
            }
            column(Withholding_TaxCaption; Withholding_TaxCaptionLbl)
            {
            }
            column(Dividend_CapitalizedCaption; Dividend_CapitalizedCaptionLbl)
            {
            }
            column(Dividends__Shares_Caption; Dividends__Shares_CaptionLbl)
            {
            }
            column(Dividends__Deposits_Caption; Dividends__Deposits_CaptionLbl)
            {
            }
            column(Dividend_PayableCaption; Dividend_PayableCaptionLbl)
            {
            }
            column(TotalsCaption; TotalsCaptionLbl)
            {
            }
            column(CommisionCharged; CommisionCharged)
            {
            }
            column(ExciseDuty; "Excise Duty(10%)")
            {
            }
            column(BankChargesonprocessings_Customer; Customer."Bank Charges on processings")
            {
            }
            column(WithholdingTaxongrossdiv_Customer; Customer."WithholdingTax on gross div")
            {
            }
            column(GrossIntOnDeposits_Customer; Customer."Gross Int On Deposits")
            {
            }
            column(GrossDivonshareCapital_Customer; Customer."Gross Div on share Capital")
            {
            }

            trigger OnAfterGetRecord()
            begin
                WithholdingTax := 0;
                PayableDiv := 0;
                DividendCapitalized := 0;
                CommisionCharged := 0;
                SharesDiv := 100;
                if "Net Dividend Payable" <= 0 then begin
                    CommisionCharged := 0;
                    "Excise Duty(10%)" := 0;
                end else begin
                    //CommisionCharged:=GenSetup."Dividend Processing Fee"*(1-0.1);
                    //"Excise Duty(10%)":=0.1*GenSetup."Dividend Processing Fee";
                end;
                if Customer."Dividend Amount" > 0 then begin
                    WithholdingTax := Customer."Dividend Amount" * (GenSetup."Withholding Tax (%)" / 100);
                    //PayableDiv:=Customer."Dividend Amount"-WithholdingTax;
                    //DividendCapitalized:=(PayableDiv*Customer."Dividends Capitalised %")*0.01;
                    //PayableDiv:=PayableDiv-DividendCapitalized;
                end;
                TWTax := TWTax + WithholdingTax;
                TPDiv := TPDiv + PayableDiv;
                //TDividendCapitalized:=TDividendCapitalized+DividendCapitalized;
                TSharesDiv := TSharesDiv + SharesDiv;
                //****************************************kk

                WithholdingTax := 0;
                PayableDiv := 0;
                SharesDiv := 100;
                GDiv := 0;

                TWTax := 0;
                TPDiv := 0;
                TSharesDiv := 0;

                CalcFields(Customer."Dividend Amount", Customer."Current Shares", Customer."Shares Retained");

                GDiv := Customer."Dividend Amount" / 1;
                WithholdingTax := GDiv * (GenSetup."Withholding Tax (%)" / 100);
                PayableDiv := Customer."Dividend Amount";
                PayableDiv := ROUND((Customer."Gross Dividend Amount Payable"), 0.01, '<');
                //MESSAGE('net %1',Customer."Dividend Amount");
                if (Customer."Gross Dividend Amount Payable" > 0) and (Customer."Gross Dividend Amount Payable" <= 250) then
                    CommisionCharged := 50;
                WithholdingTax := PayableDiv * 0.05;
                if Customer."Gross Dividend Amount Payable" > 250 then
                    CommisionCharged := 200;
                if Customer.Status = Customer.Status::Withdrawal then begin
                    CommisionCharged := 50;

                end;
                //WithholdingTax:=PayableDiv*0.05;
                Customer."Gross Dividend Amount Payable" := ROUND((Customer."Gross Dividend Amount Payable"), 0.01, '<');
                PayableDiv := Customer."Gross Dividend Amount Payable";
                WithholdingTax := (PayableDiv * 0.05);
                WithholdingTax := ROUND((WithholdingTax), 0.01, '<');
                TPDiv := PayableDiv - (WithholdingTax + CommisionCharged);

                TWTax := WithholdingTax;
                TPDiv := TPDiv;
                TSharesDiv := TSharesDiv + SharesDiv;

                //****************************************kk
                MemberRegister.Reset;
                MemberRegister.SetRange(MemberRegister."No.", "No.");
                if MemberRegister.Find('-') then begin
                    MemberRegister.CalcFields("Dividend Amount");
                    repeat
                        if MemberRegister."Dividend Amount" > 0 then begin
                            DividendsRegisterd.Init;
                            DividendsRegisterd."Member No" := MemberRegister."No.";
                            DividendsRegisterd."Member Name" := MemberRegister.Name;
                            DividendsRegisterd."Dividend year" := 'Div2025';
                            DividendsRegisterd."Net Dividends" := MemberRegister."Dividend Amount";
                            DividendsRegisterd.Modify;
                        end;
                    until MemberRegister.Next = 0;
                end;
            end;

            trigger OnPreDataItem()
            begin
                GenSetup.Get(0);
                CommisionCharged := 200;
                //"Excise Duty(10%)":=0.1*CommisionCharged;
                CommisionCharged := GenSetup."Dividend Processing Fee" - 0.1 * CommisionCharged;
            end;
        }
    }

    requestpage
    {

        layout
        {
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
        Company.Get();
        Company.CalcFields(Company.Picture)
    end;

    var
        WithholdingTax: Decimal;
        GenSetup: Record "Sacco General Set-Up";
        PayableDiv: Decimal;
        TWTax: Decimal;
        TPDiv: Decimal;
        SharesDiv: Decimal;
        TSharesDiv: Decimal;
        DividendCapitalized: Decimal;
        TDividendCapitalized: Decimal;
        Dividends_RegisterCaptionLbl: label 'Dividends Register';
        CurrReport_PAGENOCaptionLbl: label 'Page';
        Qualifying_SharesCaptionLbl: label 'Qualifying Shares';
        Gross_DividendsCaptionLbl: label 'Gross Dividends';
        Withholding_TaxCaptionLbl: label 'Withholding Tax';
        Dividend_CapitalizedCaptionLbl: label 'Dividend Capitalized';
        Dividends__Shares_CaptionLbl: label 'Dividends (Shares)';
        Dividends__Deposits_CaptionLbl: label 'Dividends (Deposits)';
        Dividend_PayableCaptionLbl: label 'Dividend Payable';
        TotalsCaptionLbl: label 'Totals';
        Company: Record "Company Information";
        CommisionCharged: Decimal;
        "Excise Duty(10%)": Decimal;
        GDiv: Decimal;
        DividendsRegisterd: Record "Dividends Registerd";
        MemberRegister: Record Customer;
}

