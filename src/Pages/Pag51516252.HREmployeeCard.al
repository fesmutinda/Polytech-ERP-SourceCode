#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516252 "HR Employee Card"
{
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Print,Functions,Employee,Attachments';
    SourceTable = "HR Employees";

    layout
    {
        area(content)
        {
            group("General Details")
            {
                Caption = 'General Details';
                field("Contract Type"; Rec."Contract Type")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("No."; "No.")
                {
                    ApplicationArea = Basic;
                    AssistEdit = true;
                    Importance = Promoted;

                    trigger OnAssistEdit()
                    begin
                        // IF AssistEdit() THEN
                        CurrPage.Update;
                    end;
                }
                field(Title; Title)
                {
                    ApplicationArea = Basic;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("ID Number"; "ID Number")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Passport Number"; "Passport Number")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Visible = false;
                }
                field(Citizenship; Citizenship)
                {
                    ApplicationArea = Basic;
                }
                field("Citizenship Text"; "Citizenship Text")
                {
                    ApplicationArea = Basic;
                    Caption = 'Country / Region Code';
                    Editable = false;
                }
                field("Global Dimension 1 Code"; "Global Dimension 1 Code")
                {
                    ApplicationArea = Basic;
                }
                field("Global Dimension 2 Code"; "Global Dimension 2 Code")
                {
                    ApplicationArea = Basic;
                }
                field(IsBoard; IsBoard)
                {
                    ApplicationArea = Basic;
                    Caption = 'Board Member';
                    Visible = false;
                }
                field(IsBoardChair; IsBoardChair)
                {
                    ApplicationArea = Basic;
                    Caption = 'Board Chair';
                    Visible = false;
                }
                field(IsCommette; IsCommette)
                {
                    ApplicationArea = Basic;
                    Caption = 'Committee Member';
                    Visible = false;
                }
                field("Post Code"; "Post Code")
                {
                    ApplicationArea = Basic;
                }
                field("Postal Address"; "Postal Address")
                {
                    ApplicationArea = Basic;
                }
                field(City; City)
                {
                    ApplicationArea = Basic;
                }
                field(County; County)
                {
                    ApplicationArea = Basic;
                }
                field(Picture; Picture)
                {
                    ApplicationArea = Basic;
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = all;
                    Caption = 'Employee User Id';

                }
                field("Fosa Account"; "Fosa Account")
                {
                    ApplicationArea = Basic;
                }
                field(SupervisorNames; SupervisorNames)
                {
                    ApplicationArea = Basic;
                    Caption = 'Supervisor ';
                    Editable = false;
                    Visible = false;
                }
                field(Status; Status)
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Style = Strong;
                    StyleExpr = true;
                }
                field(Supervisor; Supervisor)
                {
                    ApplicationArea = Basic;
                    Caption = 'Is Supervisor';
                    Visible = false;
                }
            }
            group("Communication Details")
            {
                Caption = 'Communication Details';
                field("Cell Phone Number"; "Cell Phone Number")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = PhoneNo;
                    Importance = Promoted;
                }
                field("Home Phone Number"; "Home Phone Number")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = PhoneNo;
                    Importance = Promoted;
                }
                field("Fax Number"; "Fax Number")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = PhoneNo;
                    Importance = Promoted;
                }
                field("Work Phone Number"; "Work Phone Number")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = PhoneNo;
                }
                field("Ext."; "Ext.")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = PhoneNo;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = EMail;
                }
                field("Company E-Mail"; "Company E-Mail")
                {
                    ApplicationArea = Basic;
                    ExtendedDatatype = EMail;
                    Importance = Promoted;
                }
            }
            group("Personal Details")
            {
                Caption = 'Personal Details';
                field(Gender; Gender)
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Marital Status"; "Marital Status")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                // field(Signature; Signature)
                // {
                //     ApplicationArea = Basic;
                // }
                field("First Language (R/W/S)"; "First Language (R/W/S)")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Visible = false;
                }
                field("First Language Read"; "First Language Read")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("First Language Write"; "First Language Write")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("First Language Speak"; "First Language Speak")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Second Language (R/W/S)"; "Second Language (R/W/S)")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Visible = false;
                }
                field("Second Language Read"; "Second Language Read")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Second Language Write"; "Second Language Write")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Second Language Speak"; "Second Language Speak")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Additional Language"; "Additional Language")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Vehicle Registration Number"; "Vehicle Registration Number")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Number Of Dependants"; "Number Of Dependants")
                {
                    ApplicationArea = Basic;
                }
                field(Disabled; Disabled)
                {
                    ApplicationArea = Basic;
                }
                field("Health Assesment?"; "Health Assesment?")
                {
                    ApplicationArea = Basic;
                }
                field("Medical Scheme No."; "Medical Scheme No.")
                {
                    ApplicationArea = Basic;
                }
                field("Medical Scheme Head Member"; "Medical Scheme Head Member")
                {
                    ApplicationArea = Basic;
                }
                field("Medical Scheme Name"; "Medical Scheme Name")
                {
                    ApplicationArea = Basic;
                }
                field("Cause of Inactivity Code"; "Cause of Inactivity Code")
                {
                    ApplicationArea = Basic;
                }
                field("Health Assesment Date"; "Health Assesment Date")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Bank Details")
            {
                Caption = 'Bank Details';
                field("Main Bank"; "Main Bank")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("<Bank Code>"; "Bank Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Bank Code';
                }
                field("Branch Bank"; "Branch Bank")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("<Branch Code>"; "Branch Code")
                {
                    ApplicationArea = Basic;
                    Caption = 'Branch Code';
                }
                field("Bank Account Number"; "Bank Account Number")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
            }
            group("Important Dates")
            {
                Caption = 'Important Dates';
                field("Date Of Birth"; "Date Of Birth")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        if "Date Of Birth" >= Today then begin
                            Error('Invalid Entry');
                        end;
                        DAge := Dates.DetermineAge("Date Of Birth", Today);
                    end;
                }
                field(DAge; DAge)
                {
                    ApplicationArea = Basic;
                    Caption = 'Age';
                    Editable = false;
                    Enabled = false;
                    Importance = Promoted;
                }
                field("Date Of Join"; "Date Of Join")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                    Visible = true;

                    trigger OnValidate()
                    begin
                        DService := Dates.DetermineAge("Date Of Join", Today);
                    end;
                }
                field(DService; DService)
                {
                    ApplicationArea = Basic;
                    Caption = 'Length of Service';
                    Editable = false;
                    Enabled = false;
                }
                field("End Of Probation Date"; "End Of Probation Date")
                {
                    ApplicationArea = Basic;
                }
                field("Pension Scheme Join Date"; "Pension Scheme Join Date")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        DPension := Dates.DetermineAge("Pension Scheme Join Date", Today);
                    end;
                }
                field("Medical Scheme Join Date"; "Medical Scheme Join Date")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        DMedical := Dates.DetermineAge("Medical Scheme Join Date", Today);
                    end;
                }
                field(DMedical; DMedical)
                {
                    ApplicationArea = Basic;
                    Caption = 'Time On Medical Aid Scheme';
                    Editable = false;
                    Enabled = false;
                }
                field("Wedding Anniversary"; "Wedding Anniversary")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Job Details")
            {
                Caption = 'Job Details';
                field("Job Specification"; "Job Specification")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Job Title"; "Job Title")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field(Grade; Grade)
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Payroll Code"; "Payroll Code")
                {
                    ApplicationArea = Basic;
                }
                field("Posting Group"; "Posting Group")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Terms of Service")
            {
                Caption = 'Terms of Service';
                field("Secondment Institution"; "Secondment Institution")
                {
                    ApplicationArea = Basic;
                    Caption = 'Seondment';
                }
                field("Contract End Date"; "Contract End Date")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                    Importance = Promoted;
                }
                field("Notice Period"; "Notice Period")
                {
                    ApplicationArea = Basic;
                }
                field("Send Alert to"; "Send Alert to")
                {
                    ApplicationArea = Basic;
                }
                field("Full / Part Time"; "Full / Part Time")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
            }
            group("Payment Information")
            {
                Caption = 'Payment Information';
                field("PIN No."; "PIN No.")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("NSSF No."; "NSSF No.")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("NHIF No."; "NHIF No.")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
            }
            group("Separation Details")
            {
                Caption = 'Separation Details';
                field("Date Of Leaving the Company"; "Date Of Leaving the Company")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        /*
                        FrmCalendar.SetDate("Date Of Leaving the Company");
                        FrmCalendar.RUNMODAL;
                        D := FrmCalendar.GetDate;
                        CLEAR(FrmCalendar);
                        IF D <> 0D THEN
                          "Date Of Leaving the Company":= D;
                        //DAge:= Dates.DetermineAge("Date Of Birth",TODAY);
                        
                        */

                    end;
                }
                field("Termination Grounds"; "Termination Grounds")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Exit Interview Date"; "Exit Interview Date")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Exit Interview Done by"; "Exit Interview Done by")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
            }
            group("Leave Details/Medical Claims")
            {
                Caption = 'Leave Details/Medical Claims';
                field("Reimbursed Leave Days"; "Reimbursed Leave Days")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Allocated Leave Days"; "Allocated Leave Days")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Total (Leave Days)"; "Total (Leave Days)")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Total Leave Taken"; "Total Leave Taken")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Importance = Promoted;
                }
                field("Leave Balance"; "Leave Balance")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                    Importance = Promoted;
                }
                field("Acrued Leave Days"; "Acrued Leave Days")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Cash per Leave Day"; "Cash per Leave Day")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Cash - Leave Earned"; "Cash - Leave Earned")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Leave Status"; "Leave Status")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Leave Type Filter"; "Leave Type Filter")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Leave Period Filter"; "Leave Period Filter")
                {
                    ApplicationArea = Basic;
                    Importance = Promoted;
                }
                field("Claim Limit"; "Claim Limit")
                {
                    ApplicationArea = Basic;
                }
                field("Claim Amount Used"; "Claim Amount Used")
                {
                    ApplicationArea = Basic;
                }
                field("Claim Remaining Amount"; "Claim Remaining Amount")
                {
                    ApplicationArea = Basic;
                }
            }
        }
        area(factboxes)
        {
            part(Control1102755004; "HR Employees Factbox")
            {
                SubPageLink = "No." = field("No.");
            }

        }
    }

    actions
    {
        area(navigation)
        {

            group("&Employee")
            {
                Caption = '&Employee';
                action("Next of Kin")
                {
                    ApplicationArea = Basic;
                    Caption = 'Next of Kin';
                    Image = Relatives;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "HR Employee Kin SF";
                    RunPageLink = "Employee Code" = field("No.");
                    RunPageView = where(Type = filter("Next of Kin"));
                }
                action(Beneficiaries)
                {
                    ApplicationArea = Basic;
                    Caption = 'Beneficiaries';
                    Image = Opportunity;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "HR Employee Kin SF";
                    RunPageLink = "Employee Code" = field("No.");
                    RunPageView = where(Type = filter(Beneficiary));
                }

                action(Qualifications)
                {
                    ApplicationArea = Basic;
                    Caption = 'Qualifications';
                    Image = QualificationOverview;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "HR Employee Qualification Line";
                    RunPageLink = "Employee No." = field("No.");
                }
                action("Employment History")
                {
                    ApplicationArea = Basic;
                    Caption = 'Employment History';
                    Image = History;
                    Promoted = true;
                    PromotedCategory = Category6;
                    RunObject = Page "HR Employment History Lines";
                    RunPageLink = "Employee No." = field("No.");
                }


                action(Supervisees)
                {
                    ApplicationArea = Basic;
                    Caption = 'Supervisees';
                    RunObject = Page "HR Employees Supervisee";
                    Visible = FALSE;
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        DAge := '';
        DService := '';
        DPension := '';
        DMedical := '';

        //Recalculate Important Dates
        if ("Date Of Leaving the Company" = 0D) then begin
            if ("Date Of Birth" <> 0D) then
                DAge := Dates.DetermineAge("Date Of Birth", Today);
            if ("Date Of Joining the Company" <> 0D) then
                DService := Dates.DetermineAge("Date Of Joining the Company", Today);
            if ("Pension Scheme Join Date" <> 0D) then
                DPension := Dates.DetermineAge("Pension Scheme Join Date", Today);
            if ("Medical Scheme Join Date" <> 0D) then
                DMedical := Dates.DetermineAge("Medical Scheme Join Date", Today);
            //MODIFY;
        end else begin
            if ("Date Of Birth" <> 0D) then
                DAge := Dates.DetermineAge("Date Of Birth", "Date Of Leaving the Company");
            if ("Date Of Joining the Company" <> 0D) then
                DService := Dates.DetermineAge("Date Of Joining the Company", "Date Of Leaving the Company");
            if ("Pension Scheme Join Date" <> 0D) then
                DPension := Dates.DetermineAge("Pension Scheme Join Date", "Date Of Leaving the Company");
            if ("Medical Scheme Join Date" <> 0D) then
                DMedical := Dates.DetermineAge("Medical Scheme Join Date", "Date Of Leaving the Company");
            //MODIFY;
        end;

        //Recalculate Leave Days
        Validate("Allocated Leave Days");
        SupervisorNames := GetSupervisor("User ID");
    end;

    trigger OnClosePage()
    begin
        /* TESTFIELD("First Name");
         TESTFIELD("Middle Name");
         TESTFIELD("Last Name");
         TESTFIELD("ID Number");
         TESTFIELD("Cellular Phone Number");
        */

    end;



    var
        PictureExists: Boolean;
        Text001: label 'Do you want to replace the existing picture of %1 %2?';
        Text002: label 'Do you want to delete the picture of %1 %2?';
        Dates: Codeunit "HR Datess";
        DAge: Text[100];
        DService: Text[100];
        DPension: Text[100];
        DMedical: Text[100];
        D: Date;
        // DoclLink: Record "HR Employee Attachments";
        "Filter": Boolean;
        prEmployees: Record "HR Employees";
        prPayrollType: Record "prPayroll Type";
        Mail: Codeunit Mail;
        HREmp: Record "HR Employees";
        SupervisorNames: Text[60];
        Misc: Record "Misc. Article Information";
        Conf: Record "Confidential Information";
        HRValueChange: Record "HR Value Change";
        CompInfo: Record "Company Information";
        Body: Text[1024];
        Text003: label 'Welcome to Lotus Capital Limited';
        Filename: Text;
        Recordlink: Record "Record Link";
        Text004a: label 'It is a great pleasure to welcome you to Moi Teaching and Referral Hospital. You are now part of an organization that has its own culture and set of values. On your resumption and during your on-boarding process,  to help you to understand and adapt quickly and easily to the LOTUS CAPITAL culture and values, HR Unit shall provide you with various important documents that you are encouraged to read and understand.';
        Text004b: label 'On behalf of the Managing Director, I congratulate you for your success in the interview process and I look forward to welcoming you on board LOTUS CAPITAL Limited.';
        Text004c: label 'Adebola SAMSON-FATOKUN';
        Text004d: label 'Strategy & Corporate Services';
        NL: Char;
        LF: Char;
        objpostingGroup: Record "prEmployee Posting Group";
        objDimVal: Record "Dimension Value";
        "Citizenship Text": Text[200];


    procedure GetSupervisor(var sUserID: Code[50]) SupervisorName: Text[200]
    var
        UserSetup: Record "User Setup";
    begin
        if sUserID <> '' then begin
            UserSetup.Reset;
            if UserSetup.Get(sUserID) then begin

                SupervisorName := UserSetup."Approver ID";
                if SupervisorName <> '' then begin

                    HREmp.SetRange(HREmp."User ID", SupervisorName);
                    if HREmp.Find('-') then
                        SupervisorName := HREmp.FullName;

                end else begin
                    SupervisorName := '';
                end;


            end else begin
                Error('User' + ' ' + sUserID + ' ' + 'does not exist in the user setup table');
                SupervisorName := '';
            end;
        end;
    end;


    procedure GetSupervisorID(var EmpUserID: Code[50]) SID: Text[200]
    var
        UserSetup: Record "User Setup";
        SupervisorID: Code[20];
    begin
        if EmpUserID <> '' then begin
            SupervisorID := '';

            UserSetup.Reset;
            if UserSetup.Get(EmpUserID) then begin
                SupervisorID := UserSetup."Approver ID";
                if SupervisorID <> '' then begin
                    SID := SupervisorID;
                end else begin
                    SID := '';
                end;
            end else begin
                Error('User' + ' ' + EmpUserID + ' ' + 'does not exist in the user setup table');
            end;
        end;
    end;
}

