#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516671 "Checkoff Proc Line-D"
{
    PageType = ListPart;
    SourceTable = "Funds Tax Codes";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Receipt Header No";"Receipt Header No")
                {
                    ApplicationArea = Basic;
                }
                field("Entry No";"Entry No")
                {
                    ApplicationArea = Basic;
                }
                field("Staff/Payroll No";"Staff/Payroll No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No.";"Member No.")
                {
                    ApplicationArea = Basic;
                }
                field(Name;Name)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("DEVELOPMENT LOAN Amount_25";"DEVELOPMENT LOAN Amount")
                {
                    ApplicationArea = Basic;
                }
                field("DEVELOPMENT LOAN Principal_ 25";"DEVELOPMENT LOAN Principal")
                {
                    ApplicationArea = Basic;
                }
                field("DEVELOPMENT LOAN Int_25";"DEVELOPMENT LOAN Int")
                {
                    ApplicationArea = Basic;
                }
                field("DEVELOPMENT LOAN No_25";"DEVELOPMENT LOAN No")
                {
                    ApplicationArea = Basic;
                }
                field("DEVELOPMENT LOAN 1 Amount_23";"DEVELOPMENT LOAN 1 Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<DEVELOPMENT LOAN 1 Principal_23";"DEVELOPMENT LOAN 1 Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<DEVELOPMENT LOAN 1  Int_23";"DEVELOPMENT LOAN 1  Int")
                {
                    ApplicationArea = Basic;
                }
                field("<DEVELOPMENT LOAN 1  No_23";"DEVELOPMENT LOAN 1  No")
                {
                    ApplicationArea = Basic;
                }
                field("<EMERGENCY LOAN Amount_12";"EMERGENCY LOAN Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<EMERGENCY LOAN Principal_12";"EMERGENCY LOAN Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<EMERGENCY LOAN Int_12";"EMERGENCY LOAN Int")
                {
                    ApplicationArea = Basic;
                }
                field("<EMERGENCY LOAN No-12";"EMERGENCY LOAN No")
                {
                    ApplicationArea = Basic;
                }
                field("<SCHOOL FEES LOAN Amount_17";"SCHOOL FEES LOAN Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<SCHOOL FEES LOAN Principal_17";"SCHOOL FEES LOAN Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<SCHOOL FEES LOAN Int_17";"SCHOOL FEES LOAN Int")
                {
                    ApplicationArea = Basic;
                }
                field("<SCHOOL FEES LOAN No_17";"SCHOOL FEES LOAN No")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Emergency Amount_13";"Super Emergency Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Emergency Principal_13";"Super Emergency Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Emergency Int_13";"Super Emergency Int")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Emergency Loan No_13";"Super Emergency Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Quick Amount_16";"Super Quick Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Quick Principal_16";"Super Quick Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Quick Int_16";"Super Quick Int")
                {
                    ApplicationArea = Basic;
                }
                field("<Super Quick Loan No_16";"Super Quick Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("<Quick Loan Amount_15";"Quick Loan Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Quick Loan Principal_15";"Quick Loan Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Quick Loan Int-15";"Quick Loan Int")
                {
                    ApplicationArea = Basic;
                }
                field("<Quick Loan No_15";"Quick Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("<Super School Fees Amount_18";"Super School Fees Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Super School Fees Principal_18";"Super School Fees Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Super School Fees Int_18";"Super School Fees Int")
                {
                    ApplicationArea = Basic;
                }
                field("<Super School Fees Loan No_18";"Super School Fees Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("<Investment  Amount_19";"Investment  Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Investment  Principal_19";"Investment  Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Investment  Int_19";"Investment  Int")
                {
                    ApplicationArea = Basic;
                }
                field("<Investment Loan No_19";"Investment Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("Share Capital";"Share Capital")
                {
                    ApplicationArea = Basic;
                }
                field("Deposit Contribution";"Deposit Contribution")
                {
                    ApplicationArea = Basic;
                }
                field("Insurance Fee";"Insurance Fee")
                {
                    ApplicationArea = Basic;
                }
                field("Benevolent Fund";"Benevolent Fund")
                {
                    ApplicationArea = Basic;
                }
                field("Registration Fee";"Registration Fee")
                {
                    ApplicationArea = Basic;
                }
                field("Normal Amount 20";"Normal Amount 20")
                {
                    ApplicationArea = Basic;
                }
                field("Normal Pri (20)";"Normal Pri (20)")
                {
                    ApplicationArea = Basic;
                }
                field("Normal Int (20)";"Normal Int (20)")
                {
                    ApplicationArea = Basic;
                }
                field("Normal Loan No.(20)";"Normal Loan No.(20)")
                {
                    ApplicationArea = Basic;
                }
                field("<Normal Loan Amount_21";"Normal Loan Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Normal Loan Principal_21";"Normal Loan Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<Normal Loan Int_21";"Normal Loan Int")
                {
                    ApplicationArea = Basic;
                }
                field("<NORMAL LOAN NO_21";"NORMAL LOAN NO")
                {
                    ApplicationArea = Basic;
                    Caption = 'Normal Loan No';
                }
                field("<Normal Loan 1 Amount_22";"Normal Loan 1 Amount")
                {
                    ApplicationArea = Basic;
                }
                field("<Normal Loan 1 Principal_22";"Normal Loan 1 Principal")
                {
                    ApplicationArea = Basic;
                }
                field("<NORMAL LOAN 1 NO_22";"NORMAL LOAN 1 NO")
                {
                    ApplicationArea = Basic;
                    Caption = 'Normal Loan 1 Loan No';
                }
                field("Holiday savings";"Holiday savings")
                {
                    ApplicationArea = Basic;
                }
                field("MERCHANDISE Loan No";"MERCHANDISE Loan No")
                {
                    ApplicationArea = Basic;
                }
                field("MERCHANDISE Amount";"MERCHANDISE Amount")
                {
                    ApplicationArea = Basic;
                }
                field("MERCHANDISE Pri";"MERCHANDISE Pri")
                {
                    ApplicationArea = Basic;
                }
                field("MERCHANDISE Int";"MERCHANDISE Int")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

