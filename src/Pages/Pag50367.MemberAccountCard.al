page 50367 "Member Account Card"
{
    Caption = 'Member Card';
    Editable = false;
    InsertAllowed = false;
    DelayedInsert = false;
    DeleteAllowed = false;
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            group("Account Details")
            {
                Caption = 'General Info';
                field("Member No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Account Category"; Rec."Account Category")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Joint Account Name"; Rec."Joint Account Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                    Visible = false;
                }
                field("Member Name"; Rec.Name)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Application No."; Rec."Application No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Application No';
                    Style = StrongAccent;
                }
                field("Payroll No"; Rec."Personal No")
                {
                    Caption = 'Payroll No';
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                    Visible = true;
                }
                field("Postal Code"; Rec.Address)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }

                field(City; Rec.City)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Country/Region Code';
                    Editable = false;
                }

                field("Pension No"; Rec."Pension No")
                {
                    ApplicationArea = Basic;
                }
                field("Identification Document"; Rec."Identification Document")
                {
                    ApplicationArea = Basic;
                    Caption = 'Identification Document';
                    Editable = false;
                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'ID Number';
                    Editable = false;
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Gender';
                    Style = StrongAccent;
                }
                field("KRA Pin"; Rec.Pin)
                {
                    ApplicationArea = Basic;
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = Basic;
                }
                field("Dateof Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic;
                    Caption = 'Date of Birth';
                    Editable = false;
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = Basic;
                }
                field("Application Date"; Rec."Application Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Style = StrongAccent;
                }
                field("Account Status"; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    trigger OnValidate()
                    begin

                    end;
                }
                field("Activity Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Activity';
                }
                field("Branch Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Branch';
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = Basic;
                }
                field(Blocked; Rec.Blocked)
                {
                    ApplicationArea = Basic;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = Basic;
                }
                field("Last Payment Date"; Rec."Last Payment Date")
                {
                    ApplicationArea = Basic;
                }
                field(Section; Rec.Section)
                {
                    ApplicationArea = Basic;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic;
                }
            }
            group(Contacts)
            {
                Caption = 'Contact Info';
                field("E-Mail"; Rec."E-Mail")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Email Indemnified"; Rec."Email Indemnified")
                {
                    ApplicationArea = Basic;
                }
                field("Send E-Statements"; Rec."Send E-Statements")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Mobile Phone No"; rec."Mobile Phone No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Mobile Phone No';
                    Style = StrongAccent;
                    Editable = false;
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Enabled = false;
                    Style = StandardAccent;
                    trigger OnValidate()
                    begin

                    end;
                }
                field("Contact Person Phone"; Rec."Contact Person Phone")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Contact Person"; Rec."Contact Person")
                {
                    ApplicationArea = Basic;
                }

            }
            group("Employment Details")
            {
                Caption = 'Employment Details';
                Visible = true;
                field("Employment Info"; Rec."Employment Info")
                {
                    ApplicationArea = all;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                    // Visible = MemberIsEmployed;
                }
                field(Department; Rec.Department)
                {
                    Caption = 'Employer Name';
                    ApplicationArea = Basic;
                    Editable = false;
                    // Visible = MemberIsEmployed;
                }
                field("Terms of Employment"; Rec."Terms of Employment")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Editable = true;
                }
                field(Occupation; Rec.Occupation)
                {
                    ApplicationArea = Basic;
                }
                field("Others Details"; Rec."Others Details")
                {
                    ApplicationArea = all;
                }
            }
            group("Bank Account Details")
            {
                Caption = 'Bank Account Details';
                Visible = true;
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Editable = true;
                }
                field("Bank Name"; Rec."Bank Account Name")
                {
                    ApplicationArea = Basic;
                    // ShowMandatory = true;
                    Editable = false;
                }
                field("Bank Branch"; Rec."Bank Branch Code")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Bank Account No"; Rec."Bank Account No.")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
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
                    RunObject = Page "Customer Ledger Entries";
                    RunPageLink = "Customer No." = field("No.");
                    RunPageView = sorting("Customer No.");
                    Promoted = true;
                    PromotedCategory = process;

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
                    Visible = false;
                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.FindFirst then begin
                            Report.Run(50279, true, false, Cust);
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
                    PromotedIsBig = true;
                    RunObject = Page "Members Kin Details List";
                    RunPageLink = "Account No" = field("No.");
                }
                action("Members Nominee Details List")
                {
                    ApplicationArea = Basic;
                    Caption = 'Members Nominee Details';
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
                                TbExit.Reset;
                                TbExit.SetRange(TbExit."Member No.", Rec."No.");
                                if TbExit.Find('-') then begin
                                    Error('The withdraw Application already exists.');
                                    CurrPage.Close();
                                end;
                                SwizzsoftFactory.FnCreateMembershipWithdrawalApplication(Rec."No.", Rec."Withdrawal Application Date", Rec."Reason For Membership Withdraw", Rec."Withdrawal Date");
                            end;
                        end else
                            Error('The withdraw Application has been denied');

                    end;
                }
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
                            Report.Run(50226, true, false, Cust);
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
                            Report.Run(50225, true, false, Cust);
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
                            Report.Run(50223, true, false, Cust);
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
                            Report.Run(50051, true, false, Cust);
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
                                Report.Run(50227, true, false, Cust);
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

                    action("Loans Perfomance Statement")
                    {
                        ApplicationArea = Basic;
                        Image = "Report";
                        Promoted = true;
                        PromotedCategory = "Report";

                        trigger OnAction()
                        var
                            LoansReg: Record "Loans Register";
                        begin
                            LoansReg.Reset;
                            LoansReg.SetRange(LoansReg."Client Code", Rec."No.");
                            if LoansReg.Find('-') then
                                Report.Run(50207, true, false, LoansReg);
                        end;
                    }
                    /*  action("Historical BOSA Loan Statement")
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
                     } */
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
                            Report.Run(50225, true, false, Cust);
                    end;
                }
                action("Shares Certificate")
                {
                    ApplicationArea = Basic;
                    Promoted = true;
                    PromotedCategory = "Report";

                    trigger OnAction()
                    begin
                        Cust.Reset;
                        Cust.SetRange(Cust."No.", Rec."No.");
                        if Cust.Find('-') then
                            Report.Run(50303, true, false, Cust);
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
        if rec."Account Category" = rec."Account Category"::Individual then begin//end "Regular Account" then begin
            IsRegularAccount := true;
        end;
        if rec."Account Category" = rec."Account Category"::Corporate then begin
            IsJuniorAccount := true;
        end;
    end;

    var
        Cust: record Customer;
        Vend: record Vendor;
        CurrentAge: Text;
        TypeIsEmployed: Boolean;
        IsRegularAccount: Boolean;
        IsJuniorAccount: Boolean;
        SwizzsoftFactory: Codeunit "Swizzsoft Factory";
        TbExit: Record "Membership Exist";
}

