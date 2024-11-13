#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516430 "Mwanangu Applications List"
{
    CardPageID = "Mwanangu Savings Application";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Reports,Approval,Budgetary Control,Cancellation,Category7_caption,Category8_caption,Category9_caption,Category10_caption';
    SourceTable = "Mwanangu Savings Application";
    SourceTableView = where("Application Status" = filter(<> Converted));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                }
                field("BOSA Account No"; Rec."BOSA Account No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member No';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                    Caption = 'Member Name';
                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member ID No';
                }
                field("Mobile Phone No"; Rec."Mobile Phone No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Member Phone';
                }
                field("Child Name"; Rec."Child Name")
                {
                    ApplicationArea = Basic;
                }
                field("Date of Birth"; Rec."Date of Birth")
                {
                    ApplicationArea = Basic;
                }
                field("Monthly Contribution"; Rec."Monthly Contribution")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
        }
        area(processing)
        {
            action(Approve)
            {
                ApplicationArea = Basic;
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    //TESTFIELD("Employer Code");
                    Rec.TestField("Account Type");
                    Rec.TestField("ID No.");
                    Rec.TestField("Staff No");
                    //TESTFIELD("BOSA Account No");
                    Rec.TestField("Date of Birth");
                    Rec.TestField("Global Dimension 2 Code");
                    /*
                    IF ("Micro Group"=FALSE) OR ("Micro Single"=FALSE) THEN
                    IF "BOSA Account No"='' THEN
                    ERROR('Please specify the Bosa Account.');
                    //TESTFIELD("BOSA Account No");
                    //TESTFIELD("Employer Code");
                    */

                    /*IF "Global Dimension 2 Code" = '' THEN
                    ERROR('Please specify the branch.');
                     */
                    if Rec."Application Status" = Rec."application status"::Converted then
                        Error('Application has already been converted.');

                    if (Rec."Account Type" = 'SAVINGS') then begin
                        Nok.Reset;
                        Nok.SetRange(Nok."Account No", Rec."No.");
                        /*IF Nok.FIND('-') = FALSE THEN BEGIN
                        ERROR('Next of Kin have not been specified.');
                        END;*/

                    end;


                    if Confirm('Are you sure you want to approve & create this account', true) = false then
                        exit;


                    Rec."Application Status" := Rec."application status"::Converted;
                    Rec.Modify;



                    BranchC := '';
                    IncrementNo := '';
                    /*
                    DimensionValue.RESET;
                    DimensionValue.SETRANGE(DimensionValue.Code,"Global Dimension 2 Code");
                    IF DimensionValue.FIND('-') THEN
                    BranchC:=DimensionValue."Account Code";
                    IncrementNo:=INCSTR(DimensionValue."No. Series");
                    
                    DimensionValue."No. Series":=IncrementNo;
                    DimensionValue.MODIFY;
                    */

                    if AccoutTypes.Get(Rec."Account Type") then begin
                        if AccoutTypes."Fixed Deposit" = true then begin
                            Rec.TestField("Savings Account No.");
                            //TESTFIELD("Maturity Type");
                            //TESTFIELD("Fixed Deposit Type");
                        end;



                        //Based on BOSA
                        /*
                        IF (AccoutTypes.Code = 'CHILDREN') OR (AccoutTypes.Code = 'FIXED') THEN BEGIN
                        IF  "Kin No" = '' THEN
                          AcctNo:=AccoutTypes."Account No Prefix" + '-' + BranchC + '-' + PADSTR("BOSA Account No",6,'0') + '-' + AccoutTypes."Ending Series
                        "
                        ELSE
                        AcctNo:=AccoutTypes."Account No Prefix" + '-' + BranchC + '-' + PADSTR("BOSA Account No",6,'0') + '-' + "Kin No";
                        END ELSE BEGIN
                          AcctNo:=AccoutTypes."Account No Prefix" + '-' + BranchC + '-' + PADSTR("BOSA Account No",6,'0') + '-' + AccoutTypes."Ending Series
                        ";
                        END;
                        */
                        //Based on BOSA
                        ///////
                        /*
                        IF "Parent Account No." = '' THEN BEGIN
                        IF DimensionValue.GET('BRANCH',"Global Dimension 2 Code") THEN BEGIN
                        //DimensionValue.TESTFIELD(DimensionValue."Account Code");
                        //AcctNo:=AccoutTypes."Account No Prefix" + '-' + DimensionValue."Account Code" + '-' + DimensionValue."No. Series"
                        // + '-' + AccoutTypes."Ending Series";
                        //AcctNo:=AccoutTypes."Account No Prefix" + '-' + INCSTR(DimensionValue."No. Series")
                         //+ '-' + AccoutTypes."Ending Series";


                        IF (AccoutTypes."Use Savings Account Number" = TRUE)  THEN BEGIN
                        TESTFIELD("Savings Account No.");
                        AcctNo:=AccoutTypes."Account No Prefix" + COPYSTR("Savings Account No.",4)
                        END ELSE
                        //DimensionValue."No. Series":=INCSTR(DimensionValue."No. Series");
                        //DimensionValue.MODIFY;
                        END;

                        END ELSE BEGIN
                        TESTFIELD("Kin No");
                        AcctNo:=COPYSTR("Parent Account No.",1,14) + "Kin No";
                        END;
                        IF AccoutTypes."Fixed Deposit" = TRUE THEN BEGIN
                        IF "Kin No" <> '' THEN
                        AcctNo:=COPYSTR(AcctNo,1,14) + "Kin No";
                        END;
                        ///////

                        */
                        Accounts.Init;
                        //Accounts."No.":=AcctNo;
                        Accounts."No." := Rec."No.";
                        AcctNo := Rec."No.";
                        Accounts."Date of Birth" := Rec."Date of Birth";
                        Accounts.Name := Rec.Name;
                        Accounts."Creditor Type" := Accounts."creditor type"::"Savings Account";
                        Accounts."Debtor Type" := "Debtor Type";
                        if Rec."Micro Single" = true then
                            Accounts."Group Account" := false
                        else if Random()ec."Micro Group" = true then
                            Accounts."Group Account" := false;
                        Accounts."Personal No." := Rec."Staff No";
                        Accounts."ID No." := Rec."ID No.";
                        Accounts."Mobile Phone No" := Rec."Mobile Phone No";
                        Accounts."Registration Date" := Rec."Registration Date";
                        //Accounts."Marital Status":="Marital Status";
                        Accounts."BOSA Account No" := Rec."BOSA Account No";
                        Accounts.Picture := Rec.Picture;
                        Accounts.Signature := Rec.Signature;
                        Accounts."Passport No." := Rec."Passport No.";
                        Accounts."Employer Code" := Rec."Employer Code";
                        Accounts.Status := Accounts.Status::New;
                        Accounts."Account Type" := "Account Type";
                        Accounts."Account Category" := Rec."Account Category";
                        Accounts."Date of Birth" := Rec."Date of Birth";
                        Accounts."Global Dimension 1 Code" := 'FOSA';
                        Accounts."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                        Accounts.Address := Rec.Address;
                        Accounts."Address 2" := Rec."Address 2";
                        Accounts.City := Rec.City;
                        Accounts."Phone No." := Rec."Phone No.";
                        Accounts."Telex No." := Rec."Telex No.";
                        Accounts."Post Code" := Rec."Post Code";
                        Accounts.County := Rec.County;
                        Accounts."E-Mail" := Rec."E-Mail";
                        Accounts."Home Page" := Rec."Home Page";
                        Accounts."Registration Date" := Today;
                        //Accounts.Status:=Status::New;
                        Accounts.Status := Rec.Status::Open;
                        Accounts.Section := Rec.Section;
                        Accounts."Home Address" := Rec."Home Address";
                        Accounts.District := Rec.District;
                        Accounts.Location := Rec.Location;
                        Accounts."Sub-Location" := Rec."Sub-Location";
                        Accounts."Savings Account No." := Rec."Savings Account No.";
                        //Accounts."Signing Instructions":="Signing Instructions";
                        Accounts."Fixed Deposit Type" := Rec."Fixed Deposit Type";
                        Accounts."FD Maturity Date" := Rec."FD Maturity Date";
                        Accounts."Registration Date" := Today;
                        Accounts."Monthly Contribution" := Rec."Monthly Contribution";
                        Accounts."Formation/Province" := Rec."Formation/Province";
                        Accounts."Division/Department" := Rec."Division/Department";
                        Accounts."Station/Sections" := Rec."Station/Sections";
                        Accounts."Force No." := Rec."Force No.";
                        Accounts."Vendor Posting Group" := Rec."Account Type";
                        Accounts.Insert;

                    end;


                    Accounts.Reset;
                    if Accounts.Get(AcctNo) then begin
                        Accounts.Validate(Accounts.Name);
                        Accounts.Validate(Accounts."Account Type");
                        Accounts.Validate(Accounts."Global Dimension 1 Code");
                        Accounts.Validate(Accounts."Global Dimension 2 Code");
                        Accounts.Modify;

                        //Update BOSA with FOSA Account
                        if (Rec."Account Type" = 'ORDINARY') then begin
                            if Cust.Get(Rec."BOSA Account No") then begin
                                Cust."FOSA Account No." := AcctNo;
                                Cust."FOSA Account" := AcctNo;
                                Cust.Modify;
                            end;
                        end;

                    end;

                    NextOfKinApp.Reset;
                    NextOfKinApp.SetRange(NextOfKinApp."Account No", Rec."No.");
                    if NextOfKinApp.Find('-') then begin
                        repeat
                            NextOfKin.Init;
                            //NextOfKin."Account No":=AcctNo;
                            NextOfKin."Account No" := Rec."No.";

                            NextOfKin.Name := NextOfKinApp.Name;
                            NextOfKin.Relationship := NextOfKinApp.Relationship;
                            NextOfKin.Beneficiary := NextOfKinApp.Beneficiary;
                            NextOfKin."Date of Birth" := NextOfKinApp."Date of Birth";
                            NextOfKin.Address := NextOfKinApp.Address;
                            NextOfKin.Telephone := NextOfKinApp.Telephone;
                        /*NextOfKin.Fax:=NextOfKinApp.Fax;
                        NextOfKin.Email:=NextOfKinApp.Email;
                        NextOfKin."ID No.":=NextOfKinApp."ID No.";
                        NextOfKin."%Allocation":=NextOfKinApp."%Allocation";
                        NextOfKin.INSERT;*/

                        until NextOfKinApp.Next = 0;
                    end;

                    AccountSignApp.Reset;
                    AccountSignApp.SetRange(AccountSignApp."Account No", Rec."No.");
                    if AccountSignApp.Find('-') then begin
                        repeat
                            AccountSign.Init;
                            AccountSign."Account No" := AcctNo;
                            AccountSign.Names := AccountSignApp.Names;
                            AccountSign."Date Of Birth" := AccountSignApp."Date Of Birth";
                            AccountSign."Staff/Payroll" := AccountSignApp."Staff/Payroll";
                            AccountSign."ID No." := AccountSignApp."ID No.";
                            AccountSign.Signatory := AccountSignApp.Signatory;
                            AccountSign."Must Sign" := AccountSignApp."Must Sign";
                            AccountSign."Must be Present" := AccountSignApp."Must be Present";
                            AccountSign.Picture := AccountSignApp.Picture;
                            AccountSign.Signature := AccountSignApp.Signature;
                            AccountSign."Expiry Date" := AccountSignApp."Expiry Date";
                            AccountSign.Insert;

                        until AccountSignApp.Next = 0;
                    end;


                    Message('Account approved & created successfully.');

                end;
            }
            action(Reject)
            {
                ApplicationArea = Basic;
                Caption = 'Reject';
                Image = Reject;
                Promoted = true;
                PromotedCategory = Process;
                Visible = false;

                trigger OnAction()
                begin
                    if Rec."Application Status" = Rec."application status"::Converted then
                        Error('Application has already been converted.');

                    if Confirm('Are you sure you want to reject this application', true) = true then begin
                        Rec."Application Status" := Rec."application status"::Rejected;
                        Rec.Modify;
                    end;
                end;
            }
            group(Approvals)
            {
                action(Create)
                {
                    ApplicationArea = Basic;
                    Caption = 'Create Product';
                    Enabled = EnableCreateMember;
                    Image = BankAccount;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;

                    trigger OnAction()
                    begin

                        //-----Check Mandatory Fields---------
                        Rec.TestField("Employer Code");
                        Rec.TestField("Account Type");
                        Rec.TestField("ID No.");
                        Rec.TestField("Staff No");
                        Rec.TestField("BOSA Account No");
                        Rec.TestField("Date of Birth");
                        Rec.TestField("Global Dimension 2 Code");
                        if Rec."Global Dimension 2 Code" = '' then
                            Error('Please specify the branch.');

                        //-----End Check Mandatory Fields---------

                        //----Check If account Already Exists------
                        Acc.Reset;
                        Acc.SetRange(Acc."ID No.", Rec."ID No.");
                        Acc.SetRange(Acc."Account Type", Rec."Account Type");
                        Acc.SetRange(Acc.Status, Acc.Status::Active);
                        if Acc.Find('-') then
                            Error('Account already exists. %1', Acc."No.");
                        //----End Check If account Already Exists------


                        //---Checkfields If Fixed Deposit------------
                        if AccoutTypes.Get(Rec."Account Type") then begin
                            if AccoutTypes."Fixed Deposit" = true then begin
                                Rec.TestField("Savings Account No.");
                                //TESTFIELD("Maturity Type");
                                //TESTFIELD("Fixed Deposit Type");
                            end;
                            //---End Checkfields If Fixed Deposit------------

                            if Rec."Application Status" = Rec."application status"::Converted then
                                Error('Application has already been converted.');


                            /*
                            Approvalusers.RESET;
                            Approvalusers.SETRANGE(Approvalusers."User ID",USERID);
                            Approvalusers.SETRANGE(Approvalusers."Function",Approvalusers."Function"::"Account Opening");
                            IF Approvalusers.FIND('-') = FALSE THEN
                            IF Approvalusers."Function"<> Approvalusers."Function"::"Account Opening" THEN
                            ERROR('You do not have permissions to open an Account.');
                            */


                            if Confirm('Are you sure you want to create this account?', true) = false then
                                exit;
                            Rec."Application Status" := Rec."application status"::Converted;
                            Rec."Registration Date" := Today;
                            Rec.Modify;

                            //--Assign Account Nos Based On The Product Type-----
                            //FOSA A/C FORMAT =PREFIX-MEMBERNO-PRODUCTCODE
                            if AccoutTypes.Get(Rec."Account Type") then
                                AcctNo := AccoutTypes."Account No Prefix" + '-' + Rec."BOSA Account No" + '-' + AccoutTypes."Product Code";

                            //---Create Account on Vendor Table----
                            Accounts.Init;
                            Accounts."No." := AcctNo;
                            Accounts."Date of Birth" := Rec."Date of Birth";
                            Accounts.Name := Rec.Name;
                            Accounts."Creditor Type" := Accounts."creditor type"::"Savings Account";
                            Accounts."Personal No." := Rec."Staff No";
                            Accounts."ID No." := Rec."ID No.";
                            Accounts."Mobile Phone No" := Rec."Mobile Phone No";
                            Accounts."Registration Date" := Rec."Registration Date";
                            Accounts."Employer Code" := Rec."Employer Code";
                            Accounts."BOSA Account No" := Rec."BOSA Account No";
                            Accounts.Picture := Rec.Picture;
                            Accounts.Signature := Rec.Signature;
                            Accounts."Passport No." := Rec."Passport No.";
                            Accounts.Status := Accounts.Status::Active;
                            Accounts."Account Type" := Rec."Account Type";
                            Accounts."Account Category" := Rec."Account Category";
                            Accounts."Date of Birth" := Rec."Date of Birth";
                            Accounts."Global Dimension 1 Code" := 'FOSA';
                            Accounts."Global Dimension 2 Code" := Rec."Global Dimension 2 Code";
                            Accounts.Address := Rec.Address;
                            Accounts."Address 2" := Rec."Address 2";
                            Accounts.City := Rec.City;
                            Accounts."Phone No." := Rec."Phone No.";
                            Accounts."Telex No." := Rec."Telex No.";
                            Accounts."Post Code" := Rec."Post Code";
                            Accounts.County := Rec.County;
                            Accounts."E-Mail" := Rec."E-Mail";
                            Accounts."Home Page" := Rec."Home Page";
                            Accounts."Registration Date" := Today;
                            Accounts.Status := Status::Approved;
                            Accounts.Section := Rec.Section;
                            Accounts."Home Address" := Rec."Home Address";
                            Accounts.District := Rec.District;
                            Accounts.Location := Rec.Location;
                            Accounts."Sub-Location" := Rec."Sub-Location";
                            Accounts."Savings Account No." := Rec."Savings Account No.";
                            Accounts."Registration Date" := Today;
                            Accounts."Vendor Posting Group" := Rec."Vendor Posting Group";
                            Accounts.Insert;
                            "Application Status" := Rec."application status"::Converted;
                        end;
                        AccoutTypes."Last No Used" := IncStr(AccoutTypes."Last No Used");
                        AccoutTypes.Modify;

                        Accounts.Reset;
                        if Accounts.Get(AcctNo) then begin
                            Accounts.Validate(Accounts.Name);
                            Accounts.Validate(Accounts."Account Type");
                            Accounts.Validate(Accounts."Global Dimension 1 Code");
                            Accounts.Validate(Accounts."Global Dimension 2 Code");
                            Accounts.Modify;

                            //---Update BOSA with FOSA Account----
                            if (Rec."Account Type" = 'ORDINARY') then begin
                                if Cust.Get(Rec."BOSA Account No") then begin
                                    Cust."FOSA Account No." := AcctNo;
                                    Cust."FOSA Account" := AcctNo;
                                    Cust.Modify;
                                end;
                            end;
                            //---End Update BOSA with FOSA Account----
                        end;

                        //----Insert Nominee Information------
                        NextOfKinApp.Reset;
                        NextOfKinApp.SetRange(NextOfKinApp."Account No", Rec."No.");
                        if NextOfKinApp.Find('-') then begin
                            repeat
                                NextOfKin.Init;
                                NextOfKin."Account No" := Rec."No.";
                                NextOfKin.Name := NextOfKinApp.Name;
                                NextOfKin.Relationship := NextOfKinApp.Relationship;
                                NextOfKin.Beneficiary := NextOfKinApp.Beneficiary;
                                NextOfKin."Date of Birth" := NextOfKinApp."Date of Birth";
                                NextOfKin.Address := NextOfKinApp.Address;
                                NextOfKin.Telephone := NextOfKinApp.Telephone;
                                //NextOfKin.Fax:=NextOfKinApp.Fax;
                                NextOfKin.Email := NextOfKinApp.Email;
                                NextOfKin."ID No." := NextOfKinApp."ID No.";
                                NextOfKin."%Allocation" := NextOfKinApp."%Allocation";
                                NextOfKin.Insert;
                            until NextOfKinApp.Next = 0;
                        end;
                        //----End Insert Nominee Information------

                        //Insert Account Signatories------
                        AccountSignApp.Reset;
                        AccountSignApp.SetRange(AccountSignApp."Account No", Rec."No.");
                        if AccountSignApp.Find('-') then begin
                            repeat
                                AccountSign.Init;
                                AccountSign."Account No" := AcctNo;
                                AccountSign.Names := AccountSignApp.Names;
                                AccountSign."Date Of Birth" := AccountSignApp."Date Of Birth";
                                AccountSign."Staff/Payroll" := AccountSignApp."Staff/Payroll";
                                AccountSign."ID No." := AccountSignApp."ID No.";
                                AccountSign.Signatory := AccountSignApp.Signatory;
                                AccountSign."Must Sign" := AccountSignApp."Must Sign";
                                AccountSign."Must be Present" := AccountSignApp."Must be Present";
                                AccountSign.Picture := AccountSignApp.Picture;
                                AccountSign.Signature := AccountSignApp.Signature;
                                AccountSign."Expiry Date" := AccountSignApp."Expiry Date";
                                AccountSign.Insert;
                                Rec."Application Status" := Rec."application status"::Converted;
                            until AccountSignApp.Next = 0;
                        end;
                        //Insert Account Signatories------

                        //--Send Confirmation Sms to The Member------
                        SFactory.FnSendSMS('FOSA ACC', 'Your Account successfully created.Account No=' + AcctNo, AcctNo, "Mobile Phone No");
                        Message('You have successfully created a %1 Product, A/C No=%2. Member will be notified via SMS', "Account Type", AcctNo);

                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Suite;
                    Caption = 'Send Approval Request';
                    Enabled = (not OpenApprovalEntriesExist) and EnabledApprovalWorkflowsExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        Text001: label 'This request is already pending approval';
                        Approvalmgt: Codeunit "Approvals Mgmt.";
                    begin
                        if Confirm('Are you sure you want to send Approval request for this record?', true) = false then
                            exit;
                        if Rec."Micro Group" <> true then begin
                            Rec.TestField("Account Type");
                            Rec.TestField("ID No.");
                            //TESTFIELD("Staff No");
                            //TESTFIELD("BOSA Account No");
                            Rec.TestField("Date of Birth");
                            Rec.TestField("Global Dimension 2 Code");
                        end;

                        if ("Micro Single" = true) then begin
                            Rec.TestField("Group Code");
                            Rec.TestField("Global Dimension 2 Code");
                            Rec.TestField("Account Type");
                        end;

                        if (Rec."Micro Single" <> true) and (Rec."Micro Group" <> true) then
                            if Rec."Account Type" = 'SAVINGS' then begin
                                Rec.TestField("BOSA Account No");
                            end;

                        if Rec.Status <> Rec.Status::Open then
                            Error(Text001);
                        //IF ApprovalsMgmt.CheckFAccountApplicationApprovalsWorkflowEnabled(Rec) THEN
                        //ApprovalsMgmt.OnSendFAccountApplicationForApproval(Rec);
                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Suite;
                    Caption = 'Cancel Approval Request';
                    Enabled = CanCancelApprovalForRecord;
                    Image = CancelApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        Approvalmgt: Codeunit "Approvals Mgmt.";
                    begin
                        if Confirm('Are you sure you want cancel Approval request for this record?', true) = false then
                            exit;
                        //Approvalmgt.OnCancelFAccountApplicationApprovalRequest(Rec);
                    end;
                }
                action(Approval)
                {
                    AccessByPermission = TableData "Approval Entry" = R;
                    ApplicationArea = Suite;
                    Caption = 'Approvals';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                    begin
                        DocumentType := Documenttype::ProductApplication;
                        ApprovalEntries.Setfilters(Database::"Mwanangu Savings Application", DocumentType, "No.");
                        ApprovalEntries.Run;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin

        EnableCreateMember := false;
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        EnabledApprovalWorkflowsExist := true;
        if Rec.Status = Rec.Status::Approved then begin
            OpenApprovalEntriesExist := false;
            CanCancelApprovalForRecord := false;
            EnabledApprovalWorkflowsExist := false;
        end;
        if (Rec.Status = Rec.Status::Approved) then
            EnableCreateMember := true;
    end;

    trigger OnOpenPage()
    begin
        ObjUserSetup.Reset;
        ObjUserSetup.SetRange("User ID", UserId);
        if ObjUserSetup.Find('-') then begin
            if ObjUserSetup."Approval Administrator" <> true then
                Rec.SetRange("Created By", UserId);
        end;
    end;

    var
        CalendarMgmt: Codeunit "Calendar Management";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        CustomizedCalEntry: Record "Customized Calendar Entry";
        CustomizedCalendar: Record "Customized Calendar Change";
        PictureExists: Boolean;
        AccoutTypes: Record "Account Types-Saving Products";
        Accounts: Record Vendor;
        AcctNo: Code[50];
        DimensionValue: Record "Dimension Value";
        NextOfKin: Record "FOSA Account NOK Details";
        NextOfKinApp: Record "FOSA Account App Kin Details";
        AccountSign: Record "Witness Details";
        AccountSignApp: Record "FOSA Account App Signatories";
        Acc: Record Vendor;
        UsersID: Record User;
        Nok: Record "FOSA Account App Kin Details";
        Cust: Record "Member Register";
        NOKBOSA: Record "FOSA Account NOK Details";
        BranchC: Code[20];
        DimensionV: Record "Dimension Value";
        IncrementNo: Code[20];
        MicSingle: Boolean;
        MicGroup: Boolean;
        BosaAcnt: Boolean;
        EmailEdiatble: Boolean;
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal,ATMCard,GuarantorRecovery,ChangeRequest,TreasuryTransactions;
        SaccoSetup: Record "Sacco No. Series";
        MicroGroupCode: Boolean;
        Vendor: Record Vendor;
        NameEditable: Boolean;
        NoEditable: Boolean;
        AddressEditable: Boolean;
        GlobalDim1Editable: Boolean;
        GlobalDim2Editable: Boolean;
        VendorPostingGroupEdit: Boolean;
        PhoneEditable: Boolean;
        MaritalstatusEditable: Boolean;
        IDNoEditable: Boolean;
        RegistrationDateEdit: Boolean;
        EmployerCodeEditable: Boolean;
        DOBEditable: Boolean;
        StaffNoEditable: Boolean;
        GenderEditable: Boolean;
        MonthlyContributionEdit: Boolean;
        PostCodeEditable: Boolean;
        CityEditable: Boolean;
        RecruitedEditable: Boolean;
        ContactPEditable: Boolean;
        ContactPRelationEditable: Boolean;
        ContactPOccupationEditable: Boolean;
        ContactPPhoneEditable: Boolean;
        Accountype: Boolean;
        Approvalusers: Record "Status Change Permision";
        Member: Record "Member Register";
        IncrementNoF: Code[20];
        SMSMessage: Record "SMS Messages";
        iEntryNo: Integer;
        ParentEditable: Boolean;
        SavingsEditable: Boolean;
        OpenApprovalEntriesExist: Boolean;
        EnabledApprovalWorkflowsExist: Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        CanCancelApprovalForRecord: Boolean;
        EventFilter: Text;
        EnableCreateMember: Boolean;
        SFactory: Codeunit "Swizzsoft Factory.";
        ObjUserSetup: Record "User Setup";
}

