#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51516013 "Payment Line Board"
{

    fields
    {
        field(1;"Document No";Code[20])
        {
            NotBlank = true;
        }
        field(2;"Payment Types";Code[20])
        {
            NotBlank = true;
            TableRelation = "Receipts and Payment Types".Code where (Type=const(Payment));

            trigger OnValidate()
            begin
                "W/Tax Amount" := 0;
                RecTypes.Reset;
                RecTypes.SetRange(RecTypes."No.","Payment Types");
                if RecTypes.Find('-') then begin
                    Description:=RecTypes.Description;
                    //"Tax Exempt":=RecTypes."Daily Tax Exempt. Amount";

                    if RecTypes."Account No"='' then
                    Error('The G/L account no. must be specified')
                    else
                    "G/L Account No.":=RecTypes."Account No";
                end;

                getDestinationRateAndAmounts;
            end;
        }
        field(3;"Transaction Type";Option)
        {
            OptionCaption = ' ,Repayment,Deposits Contribution,Rejoining Fee,Registration Fee,Insurance Contribution,Shares Capital,Investment,Un-allocated Funds';
            OptionMembers = " ",Repayment,"Deposits Contribution","Rejoining Fee","Registration Fee","Insurance Contribution","Shares Capital",Investment,"Un-allocated Funds";
        }
        field(4;"Loan No.";Code[20])
        {
        }
        field(5;Amount;Decimal)
        {
        }
        field(6;"W/Tax Amount";Decimal)
        {
            Editable = true;
        }
        field(7;"Net Amount";Decimal)
        {
            Editable = true;
        }
        field(8;"Amount Balance";Decimal)
        {
            Enabled = false;
        }
        field(9;"Interest Balance";Decimal)
        {
            Enabled = false;
        }
        field(10;"Shortcut Dimension 1 Code";Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where ("Global Dimension No."=const(1));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(1,"Shortcut Dimension 1 Code");
                //"Dimension Set ID" := DimMgt.ValidateShortcutDimValues2(1,"Shortcut Dimension 1 Code","Dimension Set ID");
            end;
        }
        field(11;Description;Text[50])
        {
        }
        field(12;"Shortcut Dimension 2 Code";Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where ("Global Dimension No."=const(2));

            trigger OnValidate()
            begin
                ValidateShortcutDimCode(2,"Shortcut Dimension 2 Code");
                //"Dimension Set ID" := DimMgt.ValidateShortcutDimValues2(2,"Shortcut Dimension 2 Code","Dimension Set ID");
            end;
        }
        field(13;"G/L Account No.";Code[20])
        {

            trigger OnValidate()
            begin
                GLAccount.Get("G/L Account No.");
                "Budgetary Control A/C" := GLAccount."Budget Controlled";
            end;
        }
        field(14;"Member No.";Code[20])
        {

            trigger OnValidate()
            begin
                if Cust.Get("Member No.") then begin
                "Member Name":=Cust.Name;
                end;

                SavingsAccounts.Reset;
                SavingsAccounts.SetRange(SavingsAccounts."No.","Member No.");
                if SavingsAccounts.FindSet then
                  "Savings Account" := SavingsAccounts."No.";

                getDestinationRateAndAmounts();



                Member.Reset;
                Member.SetRange(Member."No.","Member No.");
                if Member.Find('-') then begin
                    "Shortcut Dimension 1 Code":=Member."Global Dimension 1 Code";
                    "Shortcut Dimension 2 Code":=Member."Global Dimension 2 Code";
                    "Staff No." := Members."Personal No";

                end
            end;
        }
        field(15;"Member Name";Text[30])
        {
        }
        field(16;"Savings Account";Code[20])
        {
            Description = 'FOSA';
        }
        field(17;"Perdiem Amount";Decimal)
        {
        }
        field(18;"External DOC No";Code[35])
        {
        }
        field(19;"Send SMS";Boolean)
        {
        }
        field(20;Committed;Boolean)
        {
        }
        field(21;"Budgetary Control A/C";Boolean)
        {
        }
        field(90;"Employee Job Group";Code[10])
        {
            Editable = false;
        }
        field(91;"Daily Rate(Amount)";Decimal)
        {

            trigger OnValidate()
            begin
                getDestinationRateAndAmounts;
            end;
        }
        field(480;"Dimension Set ID";Integer)
        {
        }
        field(481;"Destination Code";Code[20])
        {
            TableRelation = "Travel Destination"."Destination Code";

            trigger OnValidate()
            begin
                getDestinationRateAndAmounts();
            end;
        }
        field(482;"No of Days";Decimal)
        {

            trigger OnValidate()
            begin
                getDestinationRateAndAmounts();
            end;
        }
        field(483;"Line No";Integer)
        {
            AutoIncrement = true;
        }
        field(484;"Staff No.";Code[20])
        {
        }
        field(485;"Customer Type";Option)
        {
            OptionCaption = 'Staff,Board Member';
            OptionMembers = Staff,"Board Member";
        }
        field(486;"Tax Exempt";Decimal)
        {
        }
        field(487;"Taxable Amount";Decimal)
        {
        }
        field(488;"Total Tax Exemption";Decimal)
        {
        }
    }

    keys
    {
        key(Key1;"Document No","Line No")
        {
            Clustered = true;
        }
        key(Key2;"Document No","Member No.")
        {
            SumIndexFields = Amount,"Net Amount";
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        /*
        IF PaymentsHeaderBoard.GET("Document No") THEN
            IF PaymentsHeaderBoard.Posted OR (PaymentsHeaderBoard.Status<>PaymentsHeaderBoard.Status::Pending) THEN
              ERROR('You can only delete open transactions');
              */

    end;

    trigger OnModify()
    begin
        if PaymentsHeaderBoard.Get("Document No") then
            if PaymentsHeaderBoard.Posted or (PaymentsHeaderBoard.Status<>PaymentsHeaderBoard.Status::Open) then
              Error('You can only modify open transactions');
    end;

    var
        Loans: Record "Loans reg";
        Cust: Record "Member Register";
        ReceiptsPayments: Record "Receipt Header";
        RecTypes: Record "Receipt Header";
        DimMgt: Codeunit DimensionManagement;
        GLAccount: Record "G/L Account";
        Member: Record "Member Register";
        HREmp: Record "HR Employees";
        Members: Record "Member Register";
        HREmployees: Record "HR Employees";
        EmpGrade: Code[20];
        PaymentsHeaderBoard: Record "Payments Header Board";
        TariffCodes: Record "Tariff Codes";
        SavingsAccounts: Record "Member Register";


    procedure ValidateShortcutDimCode(FieldNumber: Integer;var ShortcutDimCode: Code[20])
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber,ShortcutDimCode,"Dimension Set ID");
    end;


    procedure getDestinationRateAndAmounts()
    var
        Members: Record "Member Register";
        HREmployees: Record "HR Employees";
        EmpGrade: Code[20];
        TariffCodes: Record "Tariff Codes";
    begin
        //Reset the brare fields
        
        "W/Tax Amount" := 0;
        "Total Tax Exemption" := 0;
        
        ReceiptsPayments.Reset;
        ReceiptsPayments.SetRange(ReceiptsPayments."No.","Payment Types");
        if ReceiptsPayments.FindFirst then begin
        
           // "Tax Exempt":=ReceiptsPayments."Daily Tax Exempt. Amount";
        
            if "Daily Rate(Amount)" < "Tax Exempt" then
                "Tax Exempt" := "Daily Rate(Amount)";
        
           "Total Tax Exemption" := "No of Days"*"Tax Exempt";
        
            Amount := "No of Days" * "Daily Rate(Amount)";
            "Taxable Amount" := Amount - "Total Tax Exemption";
        
            if TariffCodes.Get(ReceiptsPayments."Withholding Tax Code") then
                "W/Tax Amount" := ROUND(TariffCodes.Percentage/100 * "Taxable Amount",1,'>');
        
        end;
        
        
        "Net Amount" := Amount - "W/Tax Amount";
        
        
        /*
        IF Members.GET("Member No.") THEN BEGIN
            "Staff No." := Members."Payroll/Staff No.";
        
            {
            //Get the Emp No
            HREmployees.RESET;
            HREmployees.SETRANGE(HREmployees."No.",Members."Payroll/Staff No.");
            IF HREmployees.FIND('-') THEN BEGIN
                //EmpNo:=objCust."Employee Job Group"
                EmpGrade := HREmployees.Grade;
            END;
        
        
            //get the destination rate for the grade
            objDestRateEntry.RESET;
            objDestRateEntry.SETRANGE(objDestRateEntry."Destination Code","Destination Code");
            objDestRateEntry.SETRANGE(objDestRateEntry."Advance Code","Payment Types");
            IF objDestRateEntry.FIND('-') THEN BEGIN
                "Daily Rate(Amount)":=objDestRateEntry."Daily Rate (Amount)";
                VALIDATE(Amount,objDestRateEntry."Daily Rate (Amount)"*"No of Days");
            END;
            }
        END;
        */

    end;
}

