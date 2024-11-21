Page 52221 "Membership Application Card"
{
    DeleteAllowed = true;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = "Membership Applications";
    layout
    {
        area(content)
        {
            group("General Info")
            {
                Caption = 'General Info';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Application No';
                }
                field("Account To Open"; Rec."Account Type")
                {
                    ApplicationArea = Basic;
                    trigger OnValidate()
                    begin
                        FnUpdateControls();
                    end;
                }

                field("Application Category"; Rec."Application Category")
                {
                    ApplicationArea = Basic;
                }
                field("Account Category"; Rec."Account Category")
                {
                    ApplicationArea = Basic;
                    Enabled = Not JuniourAccountType;
                    trigger OnValidate()
                    begin
                        FnUpdateControls();
                    end;
                }
                // field("IPRS Status"; Rec."IPRS Status")
                // {
                //     ApplicationArea = Basic;
                //     Enabled = false;
                //     Style = Attention;

                //     trigger OnValidate()
                //     begin

                //     end;
                // }
                // field("IPRS Significance"; Rec."IPRS Significance")
                // {
                //     ApplicationArea = Basic;
                //     Enabled = false;
                //     Style = Attention;
                //     trigger OnValidate()
                //     begin

                //     end;
                // }
            }
            group("Group Application Form")
            {
                Visible = IsGroupApplication;
                field("BOSA Account No."; Rec."BOSA Account No.")

                {
                    ApplicationArea = all;

                }
                // field(GroupName; Name)
                // {
                //     ApplicationArea = all;
                //     Caption = 'Group Name';
                // }

                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = all;

                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = all;
                }
                field("Employer Type"; Rec."Employer Type")
                {
                    ApplicationArea = ALL;
                }
                field("Village/Residence"; Rec."Village/Residence")
                {
                    ApplicationArea = all;
                    Caption = 'Residence';

                }
                field("Postal Code"; Rec."Postal Code")
                {
                    ApplicationArea = all;
                }

                field("Group Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = all;
                    Caption = 'Phone No';

                }
                field("Group Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = all;
                    Caption = 'Marital Status';

                }
                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = all;
                    Caption = 'MC Officer';
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = all;
                    Caption = 'Mc Officer Name';
                }
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = all;

                }



            }
            group("Applicant Form")
            {
                Caption = 'Application Form';
                Visible = (IsIndividualApplication) AND not (JuniourAccountType);
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                    end;
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin

                    end;
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    trigger OnValidate()
                    begin
                    end;
                }
                field(Name; Rec."Full Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }

                field("Country of Residence"; Rec."Home Country")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("County of Residence"; Rec."County")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                // field("Sub County"; Rec."Sub County")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                // }
                field(Location; Rec.Location)
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Sub-Location"; Rec."Sub-Location")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Member's Residence"; Rec."Member's Residence")
                {
                    ApplicationArea = Basic;
                    Caption = 'Current Residence';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = Basic;
                }
                // field("Receive Notifications"; Rec."Receive Notifications")
                // {
                //     ApplicationArea = Basic;
                // }
                field("E-Mail Address"; Rec."E-Mail (Personal)")
                {
                    ApplicationArea = Basic;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Identity Type"; Rec."Identification Document")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Enabled = Not JuniourAccountType;
                }
                field("Identity No"; Rec."ID No.")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Enabled = Not JuniourAccountType;
                }
                field("Registration Type"; Rec."Registration Type")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Enabled = Not JuniourAccountType;
                    trigger OnValidate()
                    begin
                        FnUpdateControls();
                    end;
                }
                group("IsMember")
                {
                    Caption = '';
                    Visible = RegisteringAsMember;
                    field("Monthly Deposits Contribution"; Rec."Monthly Contribution")
                    {
                        ApplicationArea = Basic;
                        ShowMandatory = true;
                    }
                }
                field(Gender; Rec.Gender)
                {
                    ApplicationArea = Basic;
                }
                field("Marital Status"; Rec."Marital Status")
                {
                    ApplicationArea = Basic;
                }
                field("How Did you know about us ?"; Rec."How Did you know of KANISA")
                {
                    ApplicationArea = Basic;
                    Caption = 'How Did you know about Us?';

                    trigger OnValidate()
                    begin
                    end;
                }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic;
                }
                field("Membership Application Date"; Rec."Membership Application Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }

                field("Membership Application Status"; Rec."Membership Application Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Editable = true;
                }
                field("Member Share Class"; Rec."Member Share Class")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                // field("Member Position"; Rec."Member Position")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                // }
                field("Type Of Employment"; Rec."Terms of Employment")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Enabled = Not JuniourAccountType;
                    trigger OnValidate()
                    begin
                        FnUpdateControls();
                    end;
                }
                group("IsEmployed")
                {
                    Caption = '';
                    Visible = (MemberIsEmployed) and Not (JuniourAccountType);
                    field("Employer Code"; Rec."Employer Code")
                    {
                        ApplicationArea = Basic;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field("Terms of Employment"; Rec."Terms of Employment")
                    {
                        ApplicationArea = Basic;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field("Payroll No"; Rec."Payroll No")
                    {
                        ApplicationArea = Basic;
                        ShowMandatory = true;
                    }
                    field(Occupation; Rec.Occupation)
                    {
                        ApplicationArea = Basic;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field(Designation; Rec.Designation)
                    {
                        ApplicationArea = Basic;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field("KRA Pin"; Rec."KRA Pin")
                    {
                        ApplicationArea = Basic;
                    }
                }
                group("IsSelfEmployed")
                {
                    Caption = '';
                    Visible = MemberIsSelfEmployed;
                    field(Occupations; Rec.Occupation)
                    {
                        ApplicationArea = Basic;
                        Caption = 'Type Of Activity Engaged';
                        ShowMandatory = true;
                        trigger OnValidate()
                        begin
                        end;
                    }
                    field("KRAPin"; Rec."KRA Pin")
                    {
                        ApplicationArea = Basic;
                        ShowMandatory = true;
                        Caption = 'KRA Pin';
                    }
                }

            }

        }
        area(factboxes)
        {
            part(Control149; "Applicant Picture")
            {

                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                // Visible = IsIndividualApplication;
                Enabled = true;

            }
            part(Control150; "Applicant Document")
            {
                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                Visible = IsIndividualApplication;
                Enabled = true;
            }
            part(Control151; "Applicant Signature")
            {
                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                //   Visible = (IsIndividualApplication) AND NOT (JuniourAccountType);
                Enabled = true;
            }
            // part(Control152; "Applicant Logo")
            // {
            //     ApplicationArea = all;
            //     SubPageLink = "No." = FIELD("No.");
            //     Visible = (IsCooporateApplication);
            //     Enabled = true;
            // }
        }


    }

    actions
    {
        area(navigation)
        {
            group("Function")
            {
                Caption = 'Function';
                action("Select Products")
                {
                    ApplicationArea = Basic;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Membership App Products";// "Members Application Products";
                    RunPageLink = "Membership Applicaton No" = field("No.");
                    Caption = 'Applied Products';
                }
                action("Next of Kin Details")
                {
                    ApplicationArea = Basic;
                    Caption = 'Next of Kin Details';
                    Image = Relationship;
                    Promoted = true;
                    Enabled = (IsGroupApplication) OR (IsIndividualApplication) OR (IsJointApplication) and (Not JuniourAccountType);
                    PromotedCategory = Process;
                    RunObject = Page "Membership Applications NOK";
                    RunPageLink = "Account No" = field("No.");
                }
                action("Account Signatories ")
                {
                    ApplicationArea = Basic;
                    Caption = 'Signatories';
                    Image = Group;
                    Promoted = true;
                    Enabled = (IsGroupApplication) OR (IsCooporateApplication) OR (IsJointApplication) and (Not JuniourAccountType);
                    PromotedCategory = Process;
                    RunObject = Page "Membership App Signatories";
                    RunPageLink = "Account No" = field("No.");
                }
                // action("Account Guardian")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'Account Guardian';
                //     Image = EmployeeAgreement;
                //     Promoted = true;
                //     Enabled = IsIndividualApplication and JuniourAccountType;
                //     PromotedCategory = Process;
                //     RunObject = Page "Account Guardian Application";
                //     RunPageLink = "Application No" = field("No.");
                //     trigger OnAction()
                //     var
                //     begin

                //     end;
                // }
                action("Agent Details")
                {
                    ApplicationArea = Basic;
                    Caption = 'Account Agent';
                    Image = BusinessRelation;
                    Promoted = true;
                    Enabled = IsIndividualApplication and not JuniourAccountType;
                    PromotedCategory = Process;
                    RunObject = Page "Agent applications List";// "Member Agent Applications List";
                    RunPageLink = "Agent Code" = field("No.");
                    trigger OnAction()
                    var
                    begin

                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        ApprovalCodeunit: Codeunit SurestepApprovalsCodeUnit;
                    begin
                        Rec.TESTFIELD("Global Dimension 2 Code");
                        Rec.TESTFIELD("Monthly Contribution");
                        if Confirm('Are you sure to send ' + Format(REC."Full Name") + ' Membership Application for Approval ?', false) = false then begin
                            exit;
                        end else begin
                            ApprovalCodeunit.SendMembershipApplicationsRequestForApproval(rec."No.", Rec);
                            CurrPage.Close();
                        end;
                    end;
                }





            }



        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        FnUpdateControls();
    end;

    trigger OnAfterGetRecord()
    begin
        FnUpdateControls();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
    begin
    end;

    trigger OnOpenPage()
    begin
        FnUpdateControls();

    end;

    trigger OnModifyRecord(): Boolean
    begin

    end;

    var
        Cust: Record Customer;
        Accounts: Record Vendor;
        AcctNo: Code[20];

        Acc: Record Vendor;
        UsersID: Record User;

        BOSAACC: Code[20];
        PictureExists: Boolean;
        text001: label 'Status must be open';
        SystemFactory: Codeunit "Swizzsoft Factory";
        UserMgt: Codeunit "User Setup Management";
        IsIndividualApplication: Boolean;
        IsJointApplication: Boolean;
        IsGroupApplication: Boolean;

        RegisteringAsGroupMember: Boolean;
        RegisteringAsCorporate: Boolean;
        IsCooporateApplication: Boolean;
        MemberIsEmployed: Boolean;
        MemberIsSelfEmployed: Boolean;
        RegisteringAsMember: Boolean;
        IsCustomerType: boolean;
        JuniourAccountType: Boolean;

    Local procedure FnUpdateControls();
    begin
        IsIndividualApplication := false;
        IsGroupApplication := false;
        IsJointApplication := false;
        JuniourAccountType := false;
        IsCooporateApplication := false;
        MemberIsEmployed := false;
        MemberIsSelfEmployed := false;
        RegisteringAsMember := false;
        IsCustomerType := false;
        RegisteringAsGroupMember := false;
        RegisteringAsCorporate := false;
        if (rec."Account Category" = Rec."Account Category"::Single) then begin
            IsIndividualApplication := true;
            Rec."Global Dimension 1 Code" := 'BOSA';
        end else
            if (rec."Account Category" = Rec."Account Category"::Group) then begin
                IsGroupApplication := true;
                Rec."Global Dimension 1 Code" := 'MICRO';
                RegisteringAsGroupMember := true;
            end else
                if (rec."Account Category" = Rec."Account Category"::Joint) then begin
                    IsJointApplication := true;
                    Rec."Global Dimension 1 Code" := 'BOSA';
                end else
                    if (rec."Account Category" = Rec."Account Category"::Corporate) then begin
                        IsCooporateApplication := true;
                        RegisteringAsCorporate := true;
                        Rec."Global Dimension 1 Code" := 'BOSA';
                    end else
                        // if (rec."Account Type" = rec."Account Type"::"Junior Account") then begin
                        //     JuniourAccountType := true;
                        // end;
                        //.........
                        if rec."Employment Info" = rec."Employment Info"::Employed then begin
                            MemberIsEmployed := true;
                        end;
        //.........
        if rec."Employment Info" = rec."Employment Info"::"Self Employed" then begin
            MemberIsSelfEmployed := true;
        end;
        //.........
        if Rec."Registration Type" = Rec."Registration Type"::New then begin
            RegisteringAsMember := true;
        end else
            // if Rec."Registration Type" = Rec."Registration Type"::Customer then begin
            //     rec."Monthly Deposits Contribution" := 0;
                IsCustomerType := true;
        // end else
        //     if Rec."Registration Type" = Rec."Registration Type"::"Micro Finance" then begin
        //         IsCustomerType := false;
        //     end;
        //..........
        IF Rec."Account Type" = Rec."Account Type"::"Junior Account" THEN begin
            JuniourAccountType := true;
            Rec."Employment Info" := Rec."Employment Info"::" ";
            Rec."Employer Code" := '';
            Rec.Occupation := '';
            Rec.Designation := '';
            Rec."KRA Pin" := '';
            Rec."ID No." := '';
            Rec."Identification Document" := Rec."Identification Document"::"Birth Certificate";
            Rec."Marital Status" := Rec."Marital Status"::Single;
            Rec."Registration Type" := Rec."Registration Type"::New;
            Rec."Account Category" := Rec."Account Category"::Single;
            rec."Terms of Employment" := Rec."Terms of Employment"::" ";
        end ELSE
            IF Rec."Account Type" = Rec."Account Type"::Single THEN begin
                JuniourAccountType := false;
            end;
    end;
}

