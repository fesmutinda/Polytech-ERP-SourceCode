page 50729 "Membership Applications Card"
{
    DeleteAllowed = false;
    InsertAllowed = false;
    Editable = false;
    PageType = Card;
    PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = "Membership Applications";
    // SourceTableView = where("Approval Status" = filter(<> open));
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
                }
                // field("Account To Open"; Rec."Account To Open")
                // {
                //     ApplicationArea = Basic;
                //     trigger OnValidate()
                //     begin
                //         FnUpdateControls();
                //     end;
                // }

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
                field("IPRS Status"; Rec."IPRS Status")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                    Style = Attention;

                    trigger OnValidate()
                    begin

                    end;
                }
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
                field(GroupName; Rec.Name)
                {
                    ApplicationArea = all;
                    Caption = 'Group Name';
                }
                field("FOSA Account No."; Rec."FOSA Account No.")
                {
                    ApplicationArea = all;

                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = all;

                }
                field(Address; Rec.Address)
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
                field("Registration Date"; Rec."Registration Date")
                {
                    ApplicationArea = all;


                }
                field("Employer Type"; Rec."Employer Type")
                {
                    ApplicationArea = all;
                }

            }


            group("Other Information")
            {
                Caption = 'Other Information';
                Visible = IsGroupApplication;

                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(" GroupGlobal Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Activity Code';
                }
                field("GroupGlobal Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Branch Code';
                    Editable = true;
                }
                field("Micro Group Code"; Rec."Micro Group Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Group Code';
                    Editable = false;
                    Visible = false;
                }

                field("Sales Code"; Rec."Sales Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'MC Officer';
                }
                field("Salesperson Name"; Rec."Salesperson Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'MC Officer Name';
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
                field(Name; Rec."Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }

                // field("Country of Residence"; Rec."Country of Residence")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                // }
                // field("County of Residence"; Rec."County of Residence")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                // }
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
                // field("Identity No"; Rec."Identity No")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                //     Enabled = Not JuniourAccountType;
                // }
                // field("Registration Type"; Rec."Registration Type")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                //     Enabled = Not JuniourAccountType;
                //     trigger OnValidate()
                //     begin
                //         FnUpdateControls();
                //     end;
                // }
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
                // field("How Did you know about us ?"; Rec."How Did you know about us ?")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'How Did you know about Us?';

                //     trigger OnValidate()
                //     begin
                //     end;
                // }
                field("Recruited By"; Rec."Recruited By")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Recruiter Name"; Rec."Recruiter Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Recruiter Name';
                    Editable = false;
                    ShowMandatory = true;
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
                field("Member Share Class"; Rec."Member Share Class")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                // field("Member Position"; Rec."Member Position")
                // {
                //     ApplicationArea = Basic;
                //     Editable = false;
                // }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                }
                field("Type Of Employment"; Rec."Employment Info")
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
            group("Junior Applicant Form")
            {
                Caption = 'Junior Application Form';
                Visible = IsIndividualApplication AND JuniourAccountType;
                field("FirstName"; Rec."First Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'First Name';
                    trigger OnValidate()
                    begin
                    end;
                }
                field("MiddleName"; Rec."Middle Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'Middle Name';
                    trigger OnValidate()
                    begin

                    end;
                }
                field("LastName"; Rec."Last Name")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'Last Name';
                    trigger OnValidate()
                    begin
                    end;
                }
                field(FullName; Rec."Name")
                {
                    ApplicationArea = Basic;
                    Caption = 'Name';
                    Editable = false;
                }
                // field("Birth Certificate No"; Rec."Birth Certificate No")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                //     trigger OnValidate()
                //     begin
                //     end;
                // }
                // field("CountryofResidence"; Rec."Country of Residence")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                //     Caption = 'Country of Residence';
                // }
                // field("CountyofResidence"; Rec."County of Residence")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'County of Residence';
                //     ShowMandatory = true;
                // }
                // field("SubCounty"; Rec."Sub County")
                // {
                //     ApplicationArea = Basic;
                //     ShowMandatory = true;
                //     Caption = 'Sub County';
                // }
                field(Loction; Rec.Location)
                {
                    ApplicationArea = Basic;
                    Caption = 'Location';
                    ShowMandatory = true;
                }
                field("SubLocation"; Rec."Sub-Location")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'Sub-Location';
                }
                field("Member'sResidence"; Rec."Member's Residence")
                {
                    ApplicationArea = Basic;
                    Caption = 'Current Residence';
                }
                // field("RegistrationType"; Rec."Registration Type")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'Registration Type';
                //     Editable = false;
                // }
                // field("ReceiveNotifications"; Rec."Receive Notifications")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'Receive Notifications';
                // }
                field("Date ofBirth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'Date Of Birth';
                }
                group("IsJuniorMember")
                {
                    Caption = '';
                    Visible = RegisteringAsMember;
                    field("MonthlyDeposits Contribution"; Rec."Monthly Contribution")
                    {
                        ApplicationArea = Basic;
                        ShowMandatory = true;
                        Caption = 'Monthly Junior Contribution';
                    }
                }
                field(Genders; Rec.Gender)
                {
                    ApplicationArea = Basic;
                    Caption = 'Gender';
                }
                // field("How Did youknow about us ?"; Rec."How Did you know about us ?")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'How Did you know about Us?';

                //     trigger OnValidate()
                //     begin
                //     end;
                // }
                field("RecruitedBy"; Rec."Recruited By")
                {
                    ApplicationArea = Basic;
                    Caption = 'Recruited By';
                }
                field("MembershipApplication Date"; Rec."Membership Application Date")
                {
                    ApplicationArea = Basic;
                    Caption = 'Application Date';
                    Editable = false;
                }

                field("MembershipApplication Status"; Rec."Membership Application Status")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Application Status';
                }
                field("GlobalDimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Caption = 'Activity';
                }
                field("Global Dimension 2Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                    ShowMandatory = true;
                    Caption = 'Branch';
                }
            }

        }
        area(factboxes)
        {
            part(Control149; "Applicant Picture")
            {

                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                //Visible = IsIndividualApplication;
                Enabled = true;

            }
            part(Control150; "Applicant Document")
            {
                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                // Visible = IsIndividualApplication;
                Enabled = true;
            }
            part(Control151; "Applicant Signature")
            {
                ApplicationArea = all;
                SubPageLink = "No." = FIELD("No.");
                //Visible = (IsIndividualApplication) AND NOT (JuniourAccountType);
                Enabled = true;
            }
        }


    }

    actions
    {
        area(navigation)
        {
            group("Function")
            {
                Caption = 'Function';
                // action("Select Products")
                // {
                //     ApplicationArea = Basic;
                //     Promoted = true;
                //     PromotedCategory = Process;
                //     RunObject = Page "Members Application Products";
                //     RunPageLink = "Membership Applicaton No" = field("No.");
                //     Caption = 'Applied Products';
                // }
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
                //     Visible = IsIndividualApplication and JuniourAccountType;
                //     Enabled = IsIndividualApplication and JuniourAccountType;
                //     PromotedCategory = Process;
                //     RunObject = Page "Account Guardian Application";
                //     RunPageLink = "Application No" = field("No.");
                //     trigger OnAction()
                //     var
                //     begin

                //     end;
                // }
                // action("Account Agent")
                // {
                //     ApplicationArea = Basic;
                //     Caption = 'Account Agent';
                //     Image = EmployeeAgreement;
                //     Promoted = true;
                //     Visible = IsIndividualApplication and not JuniourAccountType;
                //     Enabled = IsIndividualApplication and not JuniourAccountType;
                //     PromotedCategory = Process;
                //     RunObject = Page "Member Agent Applications List";
                //     RunPageLink = "Account No" = field("No.");
                //     trigger OnAction()
                //     var
                //     begin

                //     end;
                // }

                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cancel Approval Request';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    Visible = PendingApproval;
                    Enabled = PendingApproval;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        ApprovalCodeunit: Codeunit SurestepApprovalsCodeUnit;
                    begin
                        if Confirm('Are you sure to Cancel ' + Format(REC."Name") + ' Membership Application for Approval ?', false) = false then begin
                            exit;
                        end else begin
                            ApprovalCodeunit.CancelMembershipApplicationsRequestForApproval(rec."No.", Rec);
                            CurrPage.Update();
                        end;
                    end;
                }
                action("Create Account")
                {
                    ApplicationArea = Basic;
                    Caption = 'Create Account';
                    Image = CustomerSalutation;
                    Enabled = PendingCreation;
                    Visible = PendingCreation;
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction()
                    var
                        DialogBox: Dialog;
                        BOSAAccountNo: Code[50];
                        NewFOSAAccount: Code[50];
                    begin
                        rec.TestField(rec."Global Dimension 2 Code");
                        if Confirm('Are you sure to create  a ' + Format(Rec."Registration Type") + ' ' + Format(rec."Registration Type") + ' account for ' + Format(REC."Full Name") + ' ?', false) = false then begin
                            exit;
                        end else begin
                            DialogBox.Open('Registering BOSA Membership For %1 ', Rec."Full Name");
                            BOSAAccountNo := FnCreateBOSAMembership();
                            FnCreateNOK_Agent_Signatories_Guardians(BOSAAccountNo);
                            DialogBox.Close();
                            //Create Products
                            DialogBox.Open('Registering FOSA Membership For  %1 ', Rec."Full Name");
                            // FnFOSAProducts(BOSAAccountNo);
                            NewFOSAAccount := FnUpdateBOSAAccountToFOSAAccount(BOSAAccountNo);
                            DialogBox.Close();

                            //Recover Registration Fees(Acrual method)
                            DialogBox.Open('Accruing Registration Fees for  %1 ', Rec."Full Name");
                            FnInsertRegistrationFeesAccrued(BOSAAccountNo, NewFOSAAccount);
                            Sleep(100);
                            FnInsertProductRegistrationFees(BOSAAccountNo, NewFOSAAccount);
                            DialogBox.Close();
                            DialogBox.Open('Sending Account Opening Notifications %1 ', Rec."Full Name");
                            rec."Approval Status" := rec."Approval Status"::Closed;
                            rec."Created By" := UserId;
                            rec."Time Created" := Time;
                            REC."Membership Application Status" := Rec."Membership Application Status"::Closed;
                            rec."Approval Status" := rec."Approval Status"::Closed;
                            rec.Status := rec.Status::Closed;
                            rec.Modify(true);
                            //Send Notifications
                            SendAccountOpeningNotifications(BOSAAccountNo, NewFOSAAccount);
                            DialogBox.Close();
                            Message('Successfully created Account-' + Format(BOSAAccountNo));
                            CurrPage.Update();
                            Sleep(1000);
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
        Rec."Global Dimension 2 Code" := SystemFactory.FnGetUserBranch();
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
        PictureExists: Boolean;
        text001: label 'Status must be open';
        SystemFactory: Codeunit "Swizzsoft Factory";
        UserMgt: Codeunit "User Setup Management";
        IsIndividualApplication: Boolean;
        IsJointApplication: Boolean;
        IsGroupApplication: Boolean;
        IsCooporateApplication: Boolean;
        MemberIsEmployed: Boolean;
        JuniourAccountType: Boolean;
        MemberIsSelfEmployed: Boolean;
        MemberIsOthersEmployed: Boolean;
        RegisteringAsMember: Boolean;
        WelcomeMessage: label '<p style="font-family:Verdana,Arial;font-size:10pt">Dear<b> %1,</b></p><p style="font-family:Verdana,Arial;font-size:9pt">Welcome to Mafanikio Sacco</p><p style="font-family:Verdana,Arial;font-size:9pt">This is to confirm that your membership Application has been received and Undergoing Approval</p><p style="font-family:Verdana,Arial;font-size:9pt"> </b></p><br>Regards<p>%3</p><p><b></b></p>';
        RegistrationMessage: label '<p style="font-family:Verdana,Arial;font-size:10pt">Dear<b> %1,</b></p><p style="font-family:Verdana,Arial;font-size:9pt">Welcome to Mafanikio Sacco</p><p style="font-family:Verdana,Arial;font-size:9pt">This is to confirm that your membership registration has been successfully processed</p><p style="font-family:Verdana,Arial;font-size:9pt">Your membership number is <b>%2</b></p><br>Regards<p>%3</p><p><b></b></p>';
        Globa2Editable: Boolean;

    Local procedure FnUpdateControls();
    begin
        IsIndividualApplication := false;
        IsGroupApplication := false;
        IsJointApplication := false;
        IsCooporateApplication := false;
        MemberIsEmployed := false;
        MemberIsSelfEmployed := false;
        RegisteringAsMember := false;
        JuniourAccountType := false;
        if (rec."Account Category" = Rec."Account Category"::Individual) then begin
            IsIndividualApplication := true;
            Rec."Global Dimension 1 Code" := 'BOSA';
        end else
            if (rec."Account Category" = Rec."Account Category"::Joint) then begin
                IsJointApplication := true;
                Rec."Global Dimension 1 Code" := 'BOSA';
            end;// else
        //.........
        // if rec."Type Of Employment" = rec."Type Of Employment"::Employed then begin
        //     MemberIsEmployed := true;
        // end;
        // //.........
        // if rec."Type Of Employment" = rec."Type Of Employment"::"Self Employed" then begin
        //     MemberIsSelfEmployed := true;
        // end;
        // //.........
        // if Rec."Registration Type" = Rec."Registration Type"::Member then begin
        //     RegisteringAsMember := true;
        // end else
        //     if Rec."Registration Type" <> Rec."Registration Type"::Member then begin
        //         rec."Monthly Deposits Contribution" := 0;
        //     end;
        // //..........
        // IF Rec."Account To Open" = Rec."Account To Open"::"Junior Account" THEN begin
        //     JuniourAccountType := true;
        //     Rec."Type Of Employment" := Rec."Type Of Employment"::" ";
        //     Rec."Employer Code" := '';
        //     Rec.Occupation := '';
        //     Rec.Designation := '';
        //     Rec."KRA Pin" := '';
        //     Rec."Identity No" := '';
        //     Rec."Identity Type" := Rec."Identity Type"::"Birth Certificate";
        //     Rec."Marital Status" := Rec."Marital Status"::Single;
        //     Rec."Registration Type" := Rec."Registration Type"::Member;
        //     Rec."Account Category" := Rec."Account Category"::single;
        //     rec."Terms of Employment" := Rec."Terms of Employment"::" ";
        // end ELSE
        //     IF Rec."Account To Open" = Rec."Account To Open"::"Regular Account" THEN begin
        //         JuniourAccountType := false;
        //     end;
        // if (rec."Approval Status" = rec."Approval Status"::Pending) and (rec."Captured By" = UserId) then begin
        //     PendingApproval := true;
        // end;
        // if (rec."Approval Status" = rec."Approval Status"::Approved) and (rec."Captured By" = UserId) then begin
        //     PendingCreation := true;
        // end;
    end;

    local procedure FnCreateBOSAMembership(): Code[50]
    var
        CustomerTable: Record Customer;
        SaccoNoSeries: Record "Sacco No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NewMemberNo: Code[20];
    begin
        // IF REC."Account To Open" = REC."Account To Open"::"Regular Account" then begin
        //     if rec."Application Category" = rec."Application Category"::"New Application" then begin
        //         //Single Account
        //         if rec."Account Category" = rec."Account Category"::single then begin
        //             CustomerTable.Init();
        //             SaccoNoSeries.Get;
        //             SaccoNoSeries.TestField(SaccoNoSeries."Members Nos");
        //             NewMemberNo := NoSeriesMgt.GetNextNo(SaccoNoSeries."Members Nos", 0D, true);
        //             CustomerTable."No." := NewMemberNo;
        //             CustomerTable.Name := rec."Full Name";
        //             CustomerTable."First Name" := rec."First Name";
        //             CustomerTable."Middle Name" := rec."Middle Name";
        //             CustomerTable."Last Name" := rec."Last Name";
        //             CustomerTable."Customer Posting Group" := UpperCase(Format(rec."Registration Type"));
        //             CustomerTable."Customer Type" := rec."Registration Type";
        //             CustomerTable.Name := rec."Full Name";
        //             CustomerTable."Country of Residence" := rec."Country of Residence";
        //             CustomerTable."County of Residence" := rec."County of Residence";
        //             CustomerTable."Sub County" := rec."Sub County";
        //             CustomerTable."Sub-Location" := rec."Sub-Location";
        //             CustomerTable.Location := rec.Location;
        //             CustomerTable."Member's Residence" := rec."Member's Residence";
        //             CustomerTable."Phone No." := rec."Phone No.";
        //             CustomerTable."Mobile Phone No." := rec."Phone No.";
        //             CustomerTable."E-Mail" := rec."E-Mail Address";
        //             CustomerTable."Date of Birth" := rec."Date of Birth";
        //             CustomerTable."Identity Type" := rec."Identity Type";
        //             CustomerTable."ID No." := rec."Identity No";
        //             CustomerTable."Monthly Contribution" := rec."Monthly Deposits Contribution";
        //             CustomerTable.Gender := rec.Gender;
        //             CustomerTable.Name := rec."Full Name";
        //             CustomerTable."Marital Status" := rec."Marital Status";
        //             CustomerTable."How Did you know about us ?" := rec."How Did you know about us ?";
        //             CustomerTable."Recruited By" := rec."Recruited By";
        //             CustomerTable."Registration Date" := Today;
        //             //
        //             CustomerTable."Registration Type" := rec."Application Category";
        //             CustomerTable.Validate(CustomerTable."Registration Type");
        //             CustomerTable."Customer Type" := rec."Registration Type";
        //             CustomerTable.Validate(CustomerTable."Customer Type");
        //             //
        //             CustomerTable.Pin := rec."KRA Pin";
        //             CustomerTable."Receive Notifications" := rec."Receive Notifications";
        //             CustomerTable.Status := CustomerTable.Status::Active;
        //             CustomerTable."Type Of Employment" := rec."Type Of Employment";
        //             CustomerTable."Employer Code" := rec."Employer Code";
        //             CustomerTable."Employer Name" := rec."Employer Code";
        //             CustomerTable."Terms of Employment" := rec."Terms of Employment";
        //             CustomerTable.Occupation := rec.Occupation;
        //             CustomerTable.Designation := rec.Designation;
        //             CustomerTable."Personal No" := rec."Payroll No";
        //             CustomerTable.Image := rec.Picture;
        //             CustomerTable.Signature := rec.Signature;
        //             CustomerTable."Account Category" := rec."Account Category";
        //             CustomerTable.Account := rec."Account To Open";
        //             CustomerTable."IPRS Status" := rec."IPRS Status";
        //             CustomerTable."Member Share Class" := rec."Member Share Class";
        //             CustomerTable."Member Position" := rec."Member Position";
        //             CustomerTable.Insert(true);
        //             exit(NewMemberNo);
        //         end;
        //         //Cooporate Account
        //         //Group Account
        //     end else
        //         if rec."Application Category" = rec."Application Category"::Rejoining then begin
        //             Error('Functionality not Activated');
        //         end;
        // end;
        // IF REC."Account To Open" = REC."Account To Open"::"Junior Account" then begin
        //     if rec."Application Category" = rec."Application Category"::"New Application" then begin
        //         if rec."Account Category" = rec."Account Category"::single then begin
        //             CustomerTable.Init();
        //             SaccoNoSeries.Get;
        //             SaccoNoSeries.TestField(SaccoNoSeries."Junior Membership Nos");
        //             NewMemberNo := NoSeriesMgt.GetNextNo(SaccoNoSeries."Junior Membership Nos", 0D, true);
        //             CustomerTable."No." := NewMemberNo;
        //             CustomerTable."Full Name" := rec."Full Name";
        //             CustomerTable."First Name" := rec."First Name";
        //             CustomerTable."Middle Name" := rec."Middle Name";
        //             CustomerTable."Last Name" := rec."Last Name";
        //             CustomerTable."Recruited By" := REC."Recruited By";
        //             CustomerTable."Member class" := REC."Member class";
        //             CustomerTable."Country of Residence" := rec."Country of Residence";
        //             CustomerTable."County of Residence" := rec."County of Residence";
        //             CustomerTable."Sub County" := rec."Sub County";
        //             CustomerTable."Sub-Location" := rec."Sub-Location";
        //             CustomerTable.Location := rec.Location;
        //             CustomerTable."Customer Posting Group" := UpperCase(Format(rec."Registration Type"));
        //             CustomerTable."Customer Type" := rec."Registration Type";
        //             CustomerTable.Name := rec."Full Name";
        //             CustomerTable."Member's Residence" := rec."Member's Residence";
        //             CustomerTable."Phone No." := rec."Phone No.";
        //             CustomerTable."Mobile Phone No." := rec."Phone No.";
        //             CustomerTable."E-Mail" := rec."E-Mail Address";
        //             CustomerTable."Date of Birth" := rec."Date of Birth";
        //             CustomerTable."Monthly Contribution" := rec."Monthly Deposits Contribution";
        //             CustomerTable.Gender := rec.Gender;
        //             CustomerTable."Birth Certificate No" := Rec."Birth Certificate No";
        //             CustomerTable.Name := rec."Full Name";
        //             CustomerTable."Marital Status" := rec."Marital Status";
        //             CustomerTable."How Did you know about us ?" := rec."How Did you know about us ?";
        //             CustomerTable."Recruited By" := rec."Recruited By";
        //             CustomerTable."Registration Date" := Today;
        //             //
        //             CustomerTable."Registration Type" := rec."Application Category";
        //             CustomerTable.Validate(CustomerTable."Registration Type");
        //             CustomerTable."Customer Type" := rec."Registration Type";
        //             CustomerTable.Validate(CustomerTable."Customer Type");
        //             //
        //             CustomerTable."Receive Notifications" := rec."Receive Notifications";
        //             CustomerTable.Status := CustomerTable.Status::Active;
        //             CustomerTable."Member Share Class" := rec."Member Share Class";
        //             CustomerTable."Member Position" := rec."Member Position";
        //             CustomerTable.Image := rec.Picture;
        //             CustomerTable.Signature := rec."Identification Image";
        //             CustomerTable."Account Category" := rec."Account Category";
        //             CustomerTable.Account := rec."Account To Open";
        //             CustomerTable."IPRS Status" := rec."IPRS Status";
        //             CustomerTable.Insert(true);
        //             exit(NewMemberNo);
        //         end else
        //             if rec."Application Category" = rec."Application Category"::Rejoining then begin

        //             end;
        //     end else
        //         if rec."Application Category" = rec."Application Category"::Rejoining then begin
        //         end;
        // end;

    end;

    local procedure FnCreateNOK_Agent_Signatories_Guardians(BOSAAccountNo: Code[50])
    var
    // NextOfKinDetails: Record "Members NOK Details";
    // NextOfKinApplications: record "Membership Applications NOK";
    // MemberAgents: Record "Member Agent Details";
    // MemberAgentApplications: record "Member Agent Applications";
    // MemberSignatories: Record "Member Signatories Details";
    // MemberSignatoriesApplications: record "Member App Signatories";
    // GuardianDetails: Record "Guardian Details";
    // GuardianApplications: Record "Guardian Details Application";
    begin
        // IF REC."Account To Open" = REC."Account To Open"::"Regular Account" then begin
        //     if rec."Application Category" = rec."Application Category"::"New Application" then begin
        //         if rec."Account Category" = rec."Account Category"::single then begin
        //             //NOK
        //             NextOfKinApplications.Reset();
        //             NextOfKinApplications.SetRange(NextOfKinApplications."Account No", rec."No.");
        //             if NextOfKinApplications.Find('-') then begin
        //                 repeat
        //                     if NextOfKinApplications."Full Names" <> '' then begin
        //                         NextOfKinDetails.Init();
        //                         NextOfKinDetails."Account No" := BOSAAccountNo;
        //                         NextOfKinDetails.Validate(NextOfKinDetails."Account No");
        //                         NextOfKinDetails."Full Names" := NextOfKinApplications."Full Names";
        //                         NextOfKinDetails."Date of Birth" := NextOfKinApplications."Date of Birth";
        //                         NextOfKinDetails.Relationship := NextOfKinApplications.Relationship;
        //                         NextOfKinDetails.Email := NextOfKinApplications.Email;
        //                         NextOfKinDetails."Identification No." := NextOfKinApplications."Identification No.";
        //                         NextOfKinDetails."Phone No" := NextOfKinApplications."Phone No";
        //                         NextOfKinDetails."%Allocation" := NextOfKinApplications."%Allocation";
        //                         NextOfKinDetails.Beneficiary := NextOfKinApplications.Beneficiary;
        //                         NextOfKinDetails.Insert();
        //                     end;
        //                 until NextOfKinApplications.Next = 0;
        //             end;
        //             //Agent
        //             MemberAgentApplications.Reset();
        //             MemberAgentApplications.SetRange(MemberAgentApplications."Account No", rec."No.");
        //             if MemberAgentApplications.Find('-') then begin
        //                 repeat
        //                     if MemberAgentApplications."Full Name" <> '' then begin
        //                         MemberAgents.Init();
        //                         MemberAgents."Account No" := BOSAAccountNo;
        //                         MemberAgents.Validate(MemberAgents."Account No");
        //                         MemberAgents."First Name" := MemberAgentApplications."First Name";
        //                         MemberAgents."Middle Name" := MemberAgentApplications."Middle Name";
        //                         MemberAgents."Last Name" := MemberAgentApplications."Last Name";
        //                         MemberAgents."Activate Agent" := true;
        //                         MemberAgents."Allowed FOSA Withdrawals" := MemberAgentApplications."Allowed FOSA Withdrawals";
        //                         MemberAgents."Date Of Birth" := MemberAgentApplications."Date Of Birth";
        //                         MemberAgents."Email Address" := MemberAgentApplications."Email Address";
        //                         MemberAgents."ID No." := MemberAgentApplications."ID No.";
        //                         MemberAgents."Mobile No." := MemberAgentApplications."Mobile No.";
        //                         MemberAgents.Picture := MemberAgentApplications.Picture;
        //                         MemberAgents.Signature := MemberAgentApplications.Signature;
        //                         MemberAgents."Full Name" := MemberAgentApplications."Full Name";
        //                         MemberAgents.Insert();
        //                     end;
        //                 until MemberAgentApplications.Next = 0;
        //             end;
        //             //Signatory
        //             MemberSignatoriesApplications.Reset();
        //             MemberSignatoriesApplications.SetRange(MemberSignatoriesApplications."Account No", rec."No.");
        //             if MemberSignatoriesApplications.Find('-') then begin
        //                 repeat
        //                     if MemberSignatoriesApplications.Names <> '' then begin
        //                         MemberSignatories.Init();
        //                         MemberSignatories."Account No" := BOSAAccountNo;
        //                         MemberSignatories.Validate(MemberSignatories."Account No");
        //                         MemberSignatories."Full Names" := MemberSignatoriesApplications.Names;
        //                         MemberSignatories."BOSA No." := BOSAAccountNo;
        //                         MemberSignatories."Date Of Birth" := MemberSignatoriesApplications."Date Of Birth";
        //                         MemberSignatories.Designation := MemberSignatoriesApplications.Designation;
        //                         MemberSignatories."ID No." := MemberSignatoriesApplications."ID No.";
        //                         MemberSignatories."Mobile No." := MemberSignatoriesApplications."Mobile No.";
        //                         MemberSignatories."Email Address" := MemberSignatoriesApplications."Email Address";
        //                         MemberSignatories."Expiry Date" := MemberSignatoriesApplications."Expiry Date";
        //                         MemberSignatories."Maximum Withdrawal" := MemberSignatoriesApplications."Maximum Withdrawal";
        //                         MemberSignatories."Mobile No." := MemberSignatoriesApplications."Mobile No.";
        //                         MemberSignatories."Must be Present" := MemberSignatoriesApplications."Must be Present";
        //                         MemberSignatories."Must Sign" := MemberSignatoriesApplications."Must Sign";
        //                         MemberSignatories.Signatory := MemberSignatoriesApplications.Signatory;
        //                         MemberSignatories.Insert();
        //                     end;
        //                 until MemberSignatoriesApplications.Next = 0;
        //             end;
        //         end else
        //             if rec."Application Category" = rec."Application Category"::Rejoining then begin

        //             end;
        //     end;
        // end;
        // IF REC."Account To Open" = REC."Account To Open"::"Junior Account" then begin
        //     if rec."Application Category" = rec."Application Category"::"New Application" then begin
        //         if rec."Account Category" = rec."Account Category"::single then begin
        //             GuardianApplications.Reset();
        //             GuardianApplications.SetRange(GuardianApplications."Application No", rec."No.");
        //             if GuardianApplications.Find('-') then begin
        //                 repeat
        //                     if GuardianApplications."Full Name" <> '' then begin
        //                         GuardianDetails.Init();
        //                         GuardianDetails."Member No" := BOSAAccountNo;
        //                         GuardianDetails."First Name" := GuardianApplications."First Name";
        //                         GuardianDetails."Middle Name" := GuardianApplications."Middle Name";
        //                         GuardianDetails."Last Name" := GuardianApplications."Last Name";
        //                         GuardianDetails."Full Name" := GuardianApplications."Full Name";
        //                         GuardianDetails."Date Of Birth" := GuardianApplications."Date Of Birth";
        //                         GuardianDetails."Identity Type" := GuardianApplications."Identity Type";
        //                         GuardianDetails."Identity No" := GuardianApplications."Identity No";
        //                         GuardianDetails.Picture := GuardianApplications.Picture;
        //                         GuardianDetails.Signature := GuardianApplications.Signature;
        //                         GuardianDetails."Email Address" := GuardianApplications."Email Address";
        //                         GuardianDetails."Mobile No." := GuardianApplications."Mobile No.";
        //                         GuardianDetails."Relationship Type" := GuardianApplications."Relationship Type";
        //                         GuardianDetails."Receive Notifications" := GuardianApplications."Receive Notifications";
        //                         GuardianDetails."Can View Account Information" := GuardianApplications."Can View Account Information";
        //                         GuardianDetails."Can Deposit Funds" := GuardianApplications."Can Deposit Funds";
        //                         GuardianDetails."Can Withdraw Funds" := GuardianApplications."Can Withdraw Funds";
        //                         GuardianDetails."Can Manage Account Settings" := GuardianApplications."Can Manage Account Settings";
        //                         GuardianDetails."Can Close Account" := GuardianApplications."Can Close Account";
        //                         GuardianDetails.Insert(true);
        //                     end;
        //                 until GuardianApplications.Next = 0;
        //             end;
        //         end;
        //     end;
        // end;

    end;

    // local procedure FnFOSAProducts(BOSAAccountNo: Code[50]): Code[50]
    // var
    //     Vendortable: Record Vendor;
    //     ProductApplications: record "Membership Reg. Products Appli";
    //     ProductAccountNo: Code[50];
    // begin
    //     ProductApplications.Reset();
    //     ProductApplications.SetRange(ProductApplications."Membership Applicaton No", rec."No.");
    //     if ProductApplications.Find('-') then begin
    //         repeat
    //             ProductAccountNo := '';
    //             if ProductApplications.Product <> '' then begin
    //                 if rec."Global Dimension 2 Code" = 'MOMBASA' then
    //                     ProductAccountNo := FnGetNewAccountNo(ProductApplications.Product, BOSAAccountNo, '001') ELSE
    //                     if rec."Global Dimension 2 Code" = 'UKUNDA' then
    //                         ProductAccountNo := FnGetNewAccountNo(ProductApplications.Product, BOSAAccountNo, '002') ELSE
    //                         if rec."Global Dimension 2 Code" = 'LUNGALUNGA' then
    //                             ProductAccountNo := FnGetNewAccountNo(ProductApplications.Product, BOSAAccountNo, '003');
    //                 Vendortable.Init();
    //                 Vendortable."No." := ProductAccountNo;
    //                 //.........................
    //                 Vendortable.Name := rec."Full Name";
    //                 Vendortable."First Name" := rec."First Name";
    //                 Vendortable."Middle Name" := rec."Middle Name";
    //                 Vendortable."Last Name" := rec."Last Name";
    //                 Vendortable."Country of Residence" := rec."Country of Residence";
    //                 Vendortable."Phone No." := rec."Phone No.";
    //                 Vendortable."Account Type" := ProductApplications.Product;
    //                 Vendortable.Validate(Vendortable."Account Type");
    //                 Vendortable."Mobile Phone No." := rec."Phone No.";
    //                 Vendortable."E-Mail" := rec."E-Mail Address";
    //                 Vendortable."Birth Certificate No" := rec."Birth Certificate No";
    //                 Vendortable."Date of Birth" := rec."Date of Birth";
    //                 Vendortable."Identity Type" := rec."Identity Type";
    //                 Vendortable."ID No." := rec."Identity No";
    //                 Vendortable.Gender := rec.Gender;
    //                 Vendortable."Registration Date" := Today;
    //                 Vendortable."Global Dimension 1 Code" := 'FOSA';
    //                 Vendortable."Global Dimension 2 Code" := rec."Global Dimension 2 Code";
    //                 Vendortable."Receive Notifications" := rec."Receive Notifications";
    //                 Vendortable.Status := Vendortable.Status::Active;
    //                 Vendortable."Employer Name" := rec."Employer Code";
    //                 Vendortable."Employer Code" := rec."Employer Code";
    //                 Vendortable."Personal No." := rec."Payroll No";
    //                 Vendortable.Image := rec.Picture;
    //                 Vendortable.Signature := rec.Signature;
    //                 Vendortable."BOSA Account No" := BOSAAccountNo;
    //                 Vendortable."Account Type" := ProductApplications.Product;
    //                 Vendortable."Creditor Type" := Vendortable."Creditor Type"::Account;
    //                 Vendortable.Insert(true);
    //                 //.........................
    //                 Vendortable.Reset();
    //                 Vendortable.SetRange(Vendortable."BOSA Account No", BOSAAccountNo);
    //                 if Vendortable.Find('-') then begin
    //                     Vendortable."Global Dimension 1 Code" := 'FOSA';
    //                     Vendortable."Global Dimension 2 Code" := REC."Global Dimension 2 Code";
    //                     Vendortable."Account Type" := ProductApplications.Product;
    //                     Vendortable."Creditor Type" := Vendortable."Creditor Type"::Account;
    //                     Vendortable.Modify(true);
    //                 end;
    //             end;
    //         until ProductApplications.Next = 0;
    //     end;
    // end;

    local procedure FnGetNewAccountNo(Product: Code[20]; BOSAAccountNo: Code[50]; arg: Text): Code[50]
    var
        SavingsProductTypes: record "Account Types-Saving Products";
        NEWNo: text;
    begin
        NEWNo := '';
        SavingsProductTypes.Reset();
        SavingsProductTypes.SetRange(SavingsProductTypes.Code, Product);
        if SavingsProductTypes.Find('-') then begin
            NEWNo := (SavingsProductTypes."Account No Prefix" + '-' + Format(arg) + '-' + SavingsProductTypes."Last No Used");
            SavingsProductTypes."Last No Used" := IncStr(SavingsProductTypes."Last No Used");
            SavingsProductTypes.Modify(true);
            exit(NEWNo);
        end;
    end;

    local procedure FnUpdateBOSAAccountToFOSAAccount(BOSAAccountNo: Code[50]): Code[50]
    var
        VendorTable: Record Vendor;
        MemberTable: record Customer;
    begin
        VendorTable.Reset();
        VendorTable.SetRange(VendorTable."BOSA Account No", BOSAAccountNo);
        if VendorTable.Find('-') then begin
            MemberTable.Reset();
            MemberTable.SetRange(MemberTable."No.", BOSAAccountNo);
            if MemberTable.Find('-') then begin
                // MemberTable."FOSA Account No." := VendorTable."No.";
                MemberTable."Global Dimension 1 Code" := rec."Global Dimension 1 Code";
                MemberTable."Global Dimension 2 Code" := rec."Global Dimension 2 Code";
                MemberTable."Employer Code" := rec."Employer Code";
                MemberTable."Employer Name" := rec."Employer Code";
                MemberTable.Modify();
            end;
        end;
    end;

    local procedure FnInsertRegistrationFeesAccrued(BOSAAccountNo: Code[50]; NewFOSAAccount: Code[50])
    var

    begin

    end;

    local procedure FnInsertProductRegistrationFees(BOSAAccountNo: Code[50]; NewFOSAAccount: Code[50])
    var

    begin

    end;

    local procedure SendAccountOpeningNotifications(BOSAAccountNo: Code[50]; NewFOSAAccount: Code[50])
    var
        SMSMessages: record "SMS Messages";
        SaccoGeneralSetUp: record "Sacco General Set-Up";
        SystemFactory: Codeunit "Swizzsoft Factory";
        Msg: Text;
        VendorTable: record Vendor;
        CompanyInfo: record "Company Information";
        MembershipApplications: record "Membership Applications";
        Outstr: OutStream;
        Instr: InStream;
        RecRef: RecordRef;
        TempBlob: Codeunit "Temp Blob";
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SendTo: Text;
        Subject: Text;
        MessageBody: Text;
        Base64Convert: Codeunit "Base64 Convert";
    // JuniorAccountGuardians: Record "Guardian Details";
    begin
        // SaccoGeneralSetUp.Get();
        // CompanyInfo.get();
        // if SaccoGeneralSetUp."Send Membership Reg SMS" then begin
        //     Msg := '';
        //     if rec."Account To Open" = rec."Account To Open"::"Regular Account" then begin
        //         if Rec."Account Category" = rec."Account Category"::single then begin
        //             Msg := 'Hello ' + Format(rec."First Name") + 'Welcome to ' + Format(CompanyInfo.Name) + ' !Your ' + Format(rec."Account To Open") + ' membership has been successfully registered.Your BOSA account number is ' + Format(BOSAAccountNo) + '.';
        //             SystemFactory.FnSendSMS('MEMBERSHIP', Msg, '', REC."Phone No.");
        //             //.....................Send Message for the Products Opened
        //             Sleep(1000);
        //             VendorTable.Reset();
        //             VendorTable.SetRange(VendorTable."BOSA Account No", BOSAAccountNo);
        //             if VendorTable.Find('-') then begin
        //                 repeat
        //                     Msg := '';
        //                     Msg := 'Hello ' + Format(rec."First Name") + ',You have successfully registered for our ' + Format(VendorTable."Account Type") + ' product. To Deposit to ' + Format(VendorTable."Account Type") + ' account, use our paybill account ' + Format('854846') + ' and include your ' + Format(VendorTable."Account Type") + ' account number ' + Format(VendorTable."No.") + ' as the account number.';
        //                     SystemFactory.FnSendSMS('MEMBERSHIP', Msg, '', REC."Phone No.");
        //                 until VendorTable.Next = 0;
        //             end;
        //         end;
        //     end;
        //     if rec."Account To Open" = rec."Account To Open"::"Junior Account" then begin
        //         if Rec."Account Category" = rec."Account Category"::single then begin
        //             JuniorAccountGuardians.Reset();
        //             JuniorAccountGuardians.SetRange(JuniorAccountGuardians."Member No", BOSAAccountNo);
        //             if JuniorAccountGuardians.Find('-') then begin
        //                 repeat
        //                     if JuniorAccountGuardians."Receive Notifications" = true then begin
        //                         msg := '';
        //                         msg := 'Dear ' + Format(JuniorAccountGuardians."First Name") + ', Junior Account for ' + Format(rec."Full Name") + ' has successfully been registered. The Member Account Number is ' + Format(BOSAAccountNo);
        //                         SystemFactory.FnSendSMS('MEMBERSHIP', Msg, '', JuniorAccountGuardians."Mobile No.");
        //                     end;
        //                 until JuniorAccountGuardians.Next = 0;
        //             end;
        //             //.....................Send Message for the Products Opened
        //             Sleep(1000);
        //             VendorTable.Reset();
        //             VendorTable.SetRange(VendorTable."BOSA Account No", BOSAAccountNo);
        //             if VendorTable.Find('-') then begin
        //                 repeat
        //                     JuniorAccountGuardians.Reset();
        //                     JuniorAccountGuardians.SetRange(JuniorAccountGuardians."Member No", BOSAAccountNo);
        //                     if JuniorAccountGuardians.Find('-') then begin
        //                         repeat
        //                             if JuniorAccountGuardians."Receive Notifications" = true then begin
        //                                 msg := '';
        //                                 msg := 'Hello ' + Format(JuniorAccountGuardians."First Name") + ',' + Format(rec."Full Name") + ' has successfully been registered for our ' + Format(VendorTable."Account Type") + ' product. To Deposit Funds, use our paybill account ' + Format(SaccoGeneralSetUp."Paybill Business Number") + ' and include your ' + Format(VendorTable."Account Type") + ' account number ' + Format(VendorTable."No.") + ' as the account number.';
        //                                 SystemFactory.FnSendSMS('MEMBERSHIP', Msg, '', JuniorAccountGuardians."Mobile No.");
        //                             end;
        //                         until JuniorAccountGuardians.Next = 0;
        //                     end;
        //                 until VendorTable.Next = 0;
        //             end;
        //         end;
        //     end;
        // end;
        // if SaccoGeneralSetUp."Send Membership App Email" = true then begin//"Members Application-single"
        //     MembershipApplications.Reset();
        //     MembershipApplications.SetRange(MembershipApplications."No.", rec."No.");
        //     // if MembershipApplications.Find('-') then begin
        //     //     RecRef.GetTable(MembershipApplications);
        //     //     Clear(TempBlob);
        //     //     TempBlob.CreateOutStream(Outstr);
        //     //     TempBlob.CreateInStream(Instr);
        //     //     if Report.SaveAs(Report::"Members Application-single", '', ReportFormat::Pdf, Outstr, RecRef) then begin
        //     //         if rec."Account To Open" = rec."Account To Open"::"Regular Account" then begin
        //     //             if Rec."Receive Notifications" = true then begin
        //     //                 SendTo := '';
        //     //                 SendTo := Rec."E-Mail Address";
        //     //                 Subject := '';
        //     //                 Subject := UpperCase('Membership Report Ref:-' + Format(MembershipApplications."No."));
        //     //                 MessageBody := '';
        //     //                 MessageBody := 'individual';
        //     //                 EmailMessage.Create(SendTo, Subject, MessageBody);
        //     //                 EmailMessage.AddAttachment('MembershipApplicationForm' + rec."No." + '.pdf', 'application/pdf', Base64Convert.ToBase64(Instr));
        //     //                 Email.Send(EmailMessage, Enum::"Email Scenario"::Default)
        //     //             end;
        //     //         end;
        //     //         if rec."Account To Open" = rec."Account To Open"::"Junior Account" then begin
        //     //             if Rec."Receive Notifications" = true then begin
        //     //                 JuniorAccountGuardians.Reset();
        //     //                 JuniorAccountGuardians.SetRange(JuniorAccountGuardians."Member No", BOSAAccountNo);
        //     //                 if JuniorAccountGuardians.Find('-') then begin
        //     //                     Subject := '';
        //     //                     Subject := UpperCase('Membership Report Ref:-' + Format(BOSAAccountNo));
        //     //                     MessageBody := '';
        //     //                     MessageBody := 'junior';
        //     //                     repeat
        //     //                         if JuniorAccountGuardians."Receive Notifications" = true then begin
        //     //                             // ********Getting An Error when sending Emails
        //     //                             // SendTo := '';
        //     //                             // SendTo := JuniorAccountGuardians."Email Address";
        //     //                             // EmailMessage.Create(SendTo, Subject, MessageBody);
        //     //                             // EmailMessage.AddAttachment('MembershipApplicationForm' + BOSAAccountNo + '.pdf', 'application/pdf', Base64Convert.ToBase64(Instr));
        //     //                             //Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
        //     //                         end;
        //     //                     until JuniorAccountGuardians.Next = 0;
        //     //                 end;
        //     //             end;
        //     //         end;
        //     //     end;
        //     // end;


        // end;

    end;

    var
        IsCapturer: Boolean;
        PendingApproval: Boolean;
        PendingCreation: Boolean;

}

