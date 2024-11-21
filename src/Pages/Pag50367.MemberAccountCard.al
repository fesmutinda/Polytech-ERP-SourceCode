page 50367 "Member Account Card"
{
    Caption = 'Member Card';
    Editable = false;
    InsertAllowed = false;
    DelayedInsert = false;
    DeleteAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Member Register";

    layout
    {
        area(content)
        {
            //...................Regular Accounts Form
            group(RegularAccounts)
            {
                Caption = 'General';
                Editable = true;
                Visible = IsRegularAccount and not IsJuniorAccount;
                group("Account Details")
                {
                    field("No."; Rec."No.")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }
                    // field("First Name"; Rec."First Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Style = StrongAccent;
                    // }
                    // field("Middle Name"; Rec."Middle Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Style = StrongAccent;
                    // }
                    // field("Last Name"; Rec."Last Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Style = StrongAccent;
                    // }
                    field("Full Name"; Rec.Name)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Full Name';
                        Style = StrongAccent;
                    }
                    field("Identity Type"; Rec."Identification Document")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }
                    field("Identity No"; Rec."ID No.")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }

                    field(Gender; Rec.Gender)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }
                    field("Date of Birth"; Rec."Date of Birth")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Date of Birth';
                        Editable = false;
                    }
                    field(CurrentAge; CurrentAge)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Age';
                        Style = StrongAccent;
                        Editable = false;
                    }
                    field("Savings Account No"; Rec."FOSA Account No.")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Enabled = false;
                        Style = StandardAccent;
                        trigger OnValidate()
                        begin

                        end;
                    }
                    field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                    {
                        ApplicationArea = Basic;
                    }

                }
                group("Location Details")
                {
                    // field("Country of Residence"; Rec."Country of Residence")
                    // {
                    //     ApplicationArea = Basic;
                    //     Caption = 'Country';
                    //     Editable = false;
                    // }
                    // field("County of Residence"; Rec."County of Residence")
                    // {
                    //     ApplicationArea = Basic;
                    //     Caption = 'County';
                    //     Editable = false;
                    // }
                    // field("Sub County"; Rec."Sub County")
                    // {
                    //     ApplicationArea = Basic;
                    // }
                    field(Location; Rec.Location)
                    {
                        ApplicationArea = Basic;
                    }
                    field("Member's Residence"; Rec."Member's Residence")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Current Residency';
                    }

                }
                group(Contacts)
                {
                    field("Phone No."; Rec."Phone No.")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Mobile No.';
                        Editable = false;
                        Style = StrongAccent;
                    }
                    field("E-Mail"; Rec."E-Mail")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                    // field("Receives Notifications"; Rec."Receive Notifications")
                    // {
                    //     ApplicationArea = Basic;
                    // }

                }
                group("Employment Details")
                {
                    Visible = TypeIsEmployed;
                    field("Employer Code"; Rec."Employer Code")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }
                    field("Terms of Employment"; Rec."Terms of Employment")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                    field(Occupation; Rec.Occupation)
                    {
                        ApplicationArea = Basic;
                    }
                    field(Designation; Rec.Designation)
                    {
                        ApplicationArea = Basic;
                    }
                    field("Payroll No."; Rec."Personal No")
                    {
                        ApplicationArea = Basic;
                    }
                    field("KRA Pin"; Rec.Pin)
                    {
                        ApplicationArea = Basic;
                    }
                    // field("Pension No"; "Pension No")
                    // {
                    //     ApplicationArea = Basic;
                    // }

                }
                group("Creation Details")
                {
                    field("Registration Date"; Rec."Registration Date")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Style = StrongAccent;
                    }
                    field(Account; Rec."Account Category")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Account Type';
                    }
                    field("Account Category"; Rec."Account Category")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Account Category';
                    }
                    field("Customer Type"; Rec."Customer Type")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Membership Type';
                    }
                    field("Account Status"; Rec.Status)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        trigger OnValidate()
                        begin

                        end;
                    }
                    // field("FOSA Accounts"; Rec."Member Savings Accounts")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     trigger OnValidate()
                    //     begin

                    //     end;
                    // }
                }

            }

            //....................Junior Accounts Form
            group(JuniorAccounts)
            {
                Caption = 'General';
                Editable = true;
                Visible = IsJuniorAccount and not IsRegularAccount;
                group("Junior Account Details")
                {
                    Caption = 'Account Details';
                    field("No"; Rec."No.")
                    {
                        ApplicationArea = Basic;
                        Caption = 'No.';
                        Editable = false;
                        Style = StrongAccent;
                    }
                    // field("FirstName"; Rec."First Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Caption = 'First Name';
                    //     Style = StrongAccent;
                    // }
                    // field("MiddleName"; Rec."Middle Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Caption = 'Middle Name';
                    //     Style = StrongAccent;
                    // }
                    // field("LastName"; Rec."Last Name")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Caption = 'Last Name';
                    //     Style = StrongAccent;
                    // }
                    field("FullName"; Rec.Name)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Full Name';
                        Style = StrongAccent;
                    }
                    // field("Birth Certificate No"; Rec."Birth Certificate No")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Style = StrongAccent;
                    // }
                    field(JGender; Rec.Gender)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Gender';
                        Style = StrongAccent;
                    }
                    field("Dateof Birth"; Rec."Date of Birth")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Date of Birth';
                        Editable = false;
                    }
                    field(CurrentAgeJ; CurrentAge)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Age';
                        Style = StrongAccent;
                        Editable = false;
                    }
                    field("SavingsAccount No"; Rec."FOSA Account No.")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Enabled = false;
                        Caption = 'Savings Account No';
                        Style = StandardAccent;
                        trigger OnValidate()
                        begin

                        end;
                    }
                    field("Global Dimension2 Code"; Rec."Global Dimension 2 Code")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Branch';
                    }

                }
                group("LocationDetails")
                {
                    Caption = 'Location Details';
                    // field("Countryof Residence"; Rec."Country of Residence")
                    // {
                    //     ApplicationArea = Basic;
                    //     Caption = 'Country';
                    //     Editable = false;
                    // }
                    // field("Countyof Residence"; Rec."County of Residence")
                    // {
                    //     ApplicationArea = Basic;
                    //     Caption = 'County';
                    //     Editable = false;
                    // }
                    // field("SubCounty"; Rec."Sub County")
                    // {
                    //     ApplicationArea = Basic;
                    //     Caption = 'Sub-County';
                    // }
                    field(Locations; Rec.Location)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Location';
                    }
                    field("Member'sResidence"; Rec."Member's Residence")
                    {
                        ApplicationArea = Basic;
                        Caption = 'Current Residency';
                    }

                }
                group("CreationDetails")
                {
                    Caption = 'Creation Details';
                    field("RegistrationDate"; Rec."Registration Date")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Registration Date';
                        Style = StrongAccent;
                    }
                    field(Accountss; Rec."Account Category")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Account Type';
                    }
                    field("AccountCategory"; Rec."Account Category")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Account Category';
                    }
                    field("CustomerType"; Rec."Customer Type")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Membership Type';
                    }
                    field("AccountStatus"; Rec.Status)
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                        Caption = 'Account Status';
                        trigger OnValidate()
                        begin

                        end;
                    }
                    // field("FOSA =Accounts"; Rec."Member Savings Accounts")
                    // {
                    //     ApplicationArea = Basic;
                    //     Editable = false;
                    //     Caption = 'FOSA Accounts';
                    //     trigger OnValidate()
                    //     begin

                    //     end;
                    // }
                }
            }


        }
        area(factboxes)
        {
            part(Control1000000021; "Member Statistics FactBox")
            {
                SubPageLink = "No." = field("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Member")
            {
                Caption = '&Member';
                action("Member Ledger Entries")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member Ledger Entries';
                    Image = CustomerLedger;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Member Ledger Entries";
                    RunPageLink = "Customer No." = field("No.");
                    RunPageView = sorting("Customer No.");

                }
            }
            group(ActionGroup1102755023)
            {
                action("Member Card")
                {
                    ApplicationArea = Basic;
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.FindFirst then begin
                            Report.Run(51516279, true, false, Cust);
                        end;
                    end;
                }
                action("Members Kin Details List")
                {
                    ApplicationArea = Basic;
                    Caption = 'Members Kin Details';
                    Image = Relationship;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Members Nominee Details List";
                    RunPageLink = "Account No" = field("No.");
                }
                action("Create Withdrawal Application")
                {
                    ApplicationArea = Basic;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        Rec.CalcFields(Rec."Current Shares", "Outstanding Balance");

                        if Rec."Current Shares" >= Rec."Outstanding Balance" then begin
                            if Confirm('Are you sure you want to create a Withdrawal Application for this Member', false) = true then begin
                                SurestepFactory.FnCreateMembershipWithdrawalApplication(Rec."No.", Rec."Withdrawal Application Date", Rec."Reason For Membership Withdraw", Rec."Withdrawal Date");
                            end;
                        end else
                            Error('The withdraw Application has been denied');

                    end;
                }



                // action("Fosa Member is  Guaranteed")
                // {
                //     ApplicationArea = Basic;
                //     Image = JobPurchaseInvoice;
                //     Promoted = true;
                //     PromotedCategory = Report;
                //     trigger OnAction()
                //     begin
                //         Cust.Reset;
                //         Cust.SetRange(Cust."FOSA Account No.", "FOSA Account No.");
                //         if Cust.Find('-') then
                //             Report.Run(51516512, true, false, Cust);
                //     end;
                // }
                // action("Fosa Member is  a Guarantor")
                // {
                //     ApplicationArea = Basic;

                //     Image = JobPurchaseInvoice;
                //     Promoted = true;
                //     PromotedCategory = Report;

                //     trigger OnAction()
                //     begin

                //         Cust.Reset;
                //         Cust.SetRange(Cust."FOSA Account No.", "FOSA Account No.");
                //         if Cust.Find('-') then
                //             Report.Run(Report::"Fosa Memb Loans Guaranted", true, false, Cust);
                //     end;
                // }

                action("Member is  a Guarantor")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member is  a Guarantor';
                    Image = JobPurchaseInvoice;
                    Promoted = true;
                    PromotedCategory = Report;

                    trigger OnAction()
                    begin

                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(51516503, true, false, Cust);
                    end;
                }
                action("Member is  Guaranteed")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member is  Guaranteed';
                    Image = JobPurchaseInvoice;
                    Promoted = true;
                    PromotedCategory = Report;
                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(51516504, true, false, Cust);
                    end;
                }
                action("Detailed Statement")
                {
                    ApplicationArea = Basic;
                    Caption = 'Detailed Statement';
                    Image = Report;
                    Promoted = true;
                    PromotedCategory = Report;

                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(51516886, true, false, Cust);
                    end;
                }
                action("Deposit Statement")
                {
                    ApplicationArea = Basic;
                    Image = "Report";
                    Promoted = true;
                    PromotedCategory = Report;

                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(51516522, true, false, Cust);
                    end;
                }
                group("Loan Statements")
                {
                    action("BOSA Loans Statement")
                    {
                        ApplicationArea = Basic;
                        Image = "Report";
                        Promoted = true;
                        PromotedCategory = Report;

                        trigger OnAction()
                        begin
                            Cust.Reset;
                            Cust.SetRange(Cust."No.", Rec."No.");
                            if Cust.Find('-') then
                                Report.Run(51516531, true, false, Cust);
                        end;
                    }
                    // action("FOSA Loan Statement")
                    // {
                    //     ApplicationArea = Basic;
                    //     Image = "Report";
                    //     Promoted = true;
                    //     PromotedCategory = Report;

                    //     trigger OnAction()
                    //     begin
                    //         Cust.Reset;
                    //         Cust.SetRange(Cust."FOSA Account No.", "FOSA Account No.");
                    //         if Cust.Find('-') then
                    //             Report.Run(51516533, true, false, Cust);
                    //     end;
                    // }
                    action("Historical BOSA Loan Statement")
                    {
                        ApplicationArea = Basic;
                        Promoted = true;
                        Caption = 'All BOSA Loan Statement';
                        PromotedCategory = Report;

                        trigger OnAction()
                        begin
                            Cust.Reset;
                            Cust.SetRange(Cust."No.", Rec."No.");
                            if Cust.Find('-') then
                                Report.Run(51516017, true, false, Cust);
                        end;
                    }
                    // action("Historical FOSA Loan Statement")
                    // {
                    //     ApplicationArea = Basic;
                    //     Promoted = true;
                    //     Caption = 'All FOSA Loan Statement';
                    //     PromotedCategory = Report;

                    //     trigger OnAction()
                    //     begin
                    //         Cust.Reset;
                    //         Cust.SetRange(Cust."FOSA Account No.", "FOSA Account No.");
                    //         if Cust.Find('-') then
                    //             Report.Run(51516018, true, false, Cust);
                    //     end;
                    // }

                }
                // action("FOSA Statement")
                // {
                //     ApplicationArea = Basic;
                //     Promoted = true;
                //     PromotedCategory = Report;
                //     Caption = 'FOSA Account Statement';

                //     trigger OnAction()
                //     begin
                //         Vend.Reset;
                //         Vend.SetRange(Vend."No.", "FOSA Account No.");
                //         if Vend.Find('-') then
                //             Report.Run(51516890, true, false, Vend);
                //     end;


                // }
                action("Share Capital Statement")
                {
                    ApplicationArea = Basic;
                    Promoted = true;
                    PromotedCategory = Report;

                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(51516533, true, false, Cust);
                    end;
                }

            }
        }
    }


    trigger OnAfterGetRecord()
    var
    begin
        FnUpdateControls();
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    begin
        FnUpdateControls();
    end;



    trigger OnInit()
    var
    begin

    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin

    end;

    trigger OnOpenPage()
    var
    begin

    end;

    local procedure FnUpdateControls()
    var
        Dates: Codeunit "Dates Calculation";
    begin
        // if rec."Type Of Employment" = rec."Type Of Employment"::Employed then begin
        //     TypeIsEmployed := true;
        // end;
        if (Rec."Date of Birth" <> 0D) AND (REC."Date of Birth" <= Today) then begin
            CurrentAge := '';
            CurrentAge := Dates.DetermineAge(Rec."Date Of Birth", Today);
        end;
        if rec."Account Category" = rec."Account Category"::Single then begin//end "Regular Account" then begin
            IsRegularAccount := true;
        end;
        if rec."Account Category" = rec."Account Category"::Corporate then begin
            IsJuniorAccount := true;
        end;
    end;

    var
        Cust: record customer;
        Vend: record Vendor;
        CurrentAge: Text;
        TypeIsEmployed: Boolean;
        IsRegularAccount: Boolean;
        IsJuniorAccount: Boolean;
        SurestepFactory: Codeunit "Swizzsoft Factory";
}

