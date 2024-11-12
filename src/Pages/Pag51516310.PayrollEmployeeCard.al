#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516310 "Payroll Employee Card."
{
    DeleteAllowed = false;
    InsertAllowed = true;
    PageType = Card;
    SourceTable = "Payroll Employee.";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Caption = 'Staff No';
                }
                field("Payroll No"; Rec."Payroll No")
                {
                    ApplicationArea = Basic;
                    Caption = 'Sacco Member No.';
                }
                field(Surname; Rec.Surname)
                {
                    ApplicationArea = Basic;
                }
                field(Firstname; Rec.Firstname)
                {
                    ApplicationArea = Basic;
                }
                field(Lastname; Rec.Lastname)
                {
                    ApplicationArea = Basic;
                }
                field("Employee Email"; Rec."Employee Email")
                {
                    ApplicationArea = Basic;
                }
                field("Joining Date"; Rec."Joining Date")
                {
                    ApplicationArea = Basic;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Global Dimension 1"; Rec."Global Dimension 1")
                {
                    ApplicationArea = Basic;
                }
                field("Global Dimension 2"; Rec."Global Dimension 2")
                {
                    ApplicationArea = Basic;
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                }
                field("National ID No"; Rec."National ID No")
                {
                    ApplicationArea = Basic;
                }
                field("NSSF No"; Rec."NSSF No")
                {
                    ApplicationArea = Basic;
                }
                field("NHIF No"; Rec."NHIF No")
                {
                    ApplicationArea = Basic;
                }
                field("PIN No"; Rec."PIN No")
                {
                    ApplicationArea = Basic;
                }
                field("Job Group"; Rec."Job Group")
                {
                    ApplicationArea = Basic;
                }
                field(Category; Rec.Category)
                {
                    ApplicationArea = Basic;
                }
                field(Department; Rec.Department)
                {
                    ApplicationArea = Basic;
                }
                field("Is Management"; Rec."Is Management")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Pay Details")
            {
                field("Basic Pay"; Rec."Basic Pay")
                {
                    ApplicationArea = Basic;
                }
                field("Paid per Hour"; Rec."Paid per Hour")
                {
                    ApplicationArea = Basic;
                }
                field("Pays PAYE"; rec."Pays PAYE")
                {
                    ApplicationArea = Basic;
                }
                field("Pays NSSF"; Rec."Pays NSSF")
                {
                    ApplicationArea = Basic;
                }
                field("Pays NHIF"; Rec."Pays NHIF")
                {
                    ApplicationArea = Basic;
                }
                field("Payment Mode"; Rec."Payment Mode")
                {
                    ApplicationArea = Basic;
                }
                field("Insurance Premium"; Rec."Insurance Premium")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Bank Details")
            {
                field("Bank Code"; Rec."Bank Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Bank Name"; Rec."Bank Name")
                {
                    ApplicationArea = Basic;
                }
                field("Branch Code"; ReC."Branch Code")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("Branch Name"; Rec."Branch Name")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Account No"; Rec."Bank Account No")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Other Details")
            {
                field("Payslip Message"; Rec."Payslip Message")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Cummulative Figures")
            {
                Editable = false;
                field("Cummulative Basic Pay"; Rec."Cummulative Basic Pay")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative Gross Pay"; Rec."Cummulative Gross Pay")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative Allowances"; Rec."Cummulative Allowances")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative Deductions"; Rec."Cummulative Deductions")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative Net Pay"; Rec."Cummulative Net Pay")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative PAYE"; Rec."Cummulative PAYE")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative NSSF"; Rec."Cummulative NSSF")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative Pension"; Rec."Cummulative Pension")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative HELB"; Rec."Cummulative HELB")
                {
                    ApplicationArea = Basic;
                }
                field("Cummulative NHIF"; Rec."Cummulative NHIF")
                {
                    ApplicationArea = Basic;
                }
            }
            group("Suspension of Payment")
            {
                field("Suspend Pay"; Rec."Suspend Pay")
                {
                    ApplicationArea = Basic;
                }
                field("Suspend Date"; Rec."Suspend Date")
                {
                    ApplicationArea = Basic;
                }
                field("Suspend Reason"; Rec."Suspend Reason")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Process Payroll")
            {
                ApplicationArea = Basic;
                Image = Allocations;
                Promoted = true;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin

                    ContrInfo.Get;

                    objPeriod.Reset;
                    objPeriod.SetRange(objPeriod.Closed, false);
                    if objPeriod.Find('-') then begin
                        SelectedPeriod := objPeriod."Date Opened";
                        varPeriodMonth := objPeriod."Period Month";
                        SalCard.Get(Rec."No.");
                    end;

                    //For Multiple Payroll
                    if ContrInfo."Multiple Payroll" then begin
                        PayrollDefined := '';
                        PayrollType.Reset;
                        PayrollType.SetCurrentkey(EntryNo);
                        if PayrollType.FindFirst then begin
                            NoofRecords := PayrollType.Count;
                            i := 0;
                            repeat
                                i += 1;
                                PayrollDefined := PayrollDefined + '&' + PayrollType."Payroll Code";
                                if i < NoofRecords then
                                    PayrollDefined := PayrollDefined + ','
                            until PayrollType.Next = 0;
                        end;
                        //Selection := STRMENU(PayrollDefined,NoofRecords);

                        PayrollType.Reset;
                        PayrollType.SetRange(PayrollType.EntryNo, Selection);
                        if PayrollType.Find('-') then begin
                            PayrollCode := PayrollType."Payroll Code";
                        end;
                    end;

                    //Delete all Records from the prPeriod Transactions for Reprocessing
                    objPeriod.Reset;
                    objPeriod.SetRange(objPeriod.Closed, false);
                    if objPeriod.FindFirst then begin

                        //IF ContrInfo."Multiple Payroll" THEN BEGIN
                        ObjPayrollTransactions.Reset;
                        ObjPayrollTransactions.SetRange(ObjPayrollTransactions."Payroll Period", objPeriod."Date Opened");
                        if ObjPayrollTransactions.Find('-') then begin
                            ObjPayrollTransactions.DeleteAll;
                        end;
                    end;

                    PayrollEmployerDed.Reset;
                    PayrollEmployerDed.SetRange(PayrollEmployerDed."Payroll Period", SelectedPeriod);
                    if PayrollEmployerDed.Find('-') then
                        PayrollEmployerDed.DeleteAll;

                    //MESSAGE ('Member is %1',PayrollEmployerDed."Membership No");


                    if ContrInfo."Multiple Payroll" then
                        HrEmployee.Reset;
                    HrEmployee.SetRange(HrEmployee.Status, HrEmployee.Status::Active);
                    if HrEmployee.Find('-') then begin
                        ProgressWindow.Open('Processing Salary for Employee No. #1#######');
                        repeat
                            Sleep(100);
                            if not SalCard."Suspend Pay" then begin
                                ProgressWindow.Update(1, HrEmployee."No." + ':' + HrEmployee.Firstname + ' ' + HrEmployee.Lastname + ' ' + HrEmployee.Surname);
                                if SalCard.Get(HrEmployee."No.") then
                                    ProcessPayroll.fnProcesspayroll(HrEmployee."No.", HrEmployee."Joining Date", SalCard."Basic Pay", SalCard."Pays PAYE"
                                    , SalCard."Pays NSSF", SalCard."Pays NHIF", SelectedPeriod, SelectedPeriod, HrEmployee."Payroll No", '',
                                    HrEmployee."Date of Leaving", true, HrEmployee."Branch Code", PayrollCode);
                            end;
                        until HrEmployee.Next = 0;
                        ProgressWindow.Close;
                    end;
                    Message('Payroll processing completed successfully.');

                    //Send Payroll SMS
                    SMSMessage.Reset;
                    if SMSMessage.Find('+') then begin
                        iEntryNo := SMSMessage."Entry No";
                        iEntryNo := iEntryNo + 1;
                    end
                    else begin
                        iEntryNo := 1;
                    end;
                    GenSetup.Get;
                    compinfo.Get;

                    SMSMessage.Init;
                    SMSMessage."Entry No" := iEntryNo;
                    //SMSMessage."Batch No":="Batch No.";
                    SMSMessage."Payroll No" := Rec."Payroll No";
                    //SMSMessage."Document No":="Loans Register"."Loan  No.";
                    //SMSMessage."Account No":="Loans Register"."Client Code";
                    SMSMessage."Date Entered" := Today;
                    SMSMessage."Time Entered" := Time;
                    SMSMessage.Source := 'Loan Payment Remainder';
                    SMSMessage."Entered By" := UserId;
                    SMSMessage."Sent To Server" := SMSMessage."sent to server"::No;
                    SMSMessage."SMS Message" := 'Dear , ' + Rec.Firstname + 'Your Salary For' + PayrollCalender."Period Name" + ' Has been processed.Kindly Confirm with your bank';


                    //nthale

                    /*HrEmployee.GET(Cust."Personal No");
                    IF HrEmployee.FINDFIRST THEN BEGIN
                    SMSMessage."Telephone No":=Cust."Mobile Phone No";
                    END;*/
                    if Cust."Mobile Phone No" <> '' then
                        SMSMessage.Insert;


                    //END;
                    //END;
                    //END;
                    //END;

                end;
            }
            action("Employee Earnings")
            {
                ApplicationArea = Basic;
                Image = AllLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payroll Employee Earnings.";
                RunPageLink = "No." = field("No.");
                RunPageView = where("Transaction Type" = filter(Income));
            }
            action("Employee Deductions")
            {
                ApplicationArea = Basic;
                Image = EntriesList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payroll Employee Deductions.";
                RunPageLink = "No." = field("No.");
                RunPageView = where("Transaction Type" = filter(Deduction));
            }
            action("Employee Assignments")
            {
                ApplicationArea = Basic;
                Image = Apply;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payroll Employee Assignments.";
                RunPageLink = "No." = field("No.");
            }
            action("Employee Cummulatives")
            {
                ApplicationArea = Basic;
                Image = History;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Payroll Employee Cummulatives.";
                RunPageLink = "No." = field("No.");
            }
            action("View PaySlip")
            {
                ApplicationArea = Basic;
                Image = PaymentHistory;
                Promoted = true;
                PromotedCategory = "Report";
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    PayrollEmp.Reset;
                    PayrollEmp.SetRange(PayrollEmp."No.", Rec."No.");
                    if PayrollEmp.FindFirst then begin
                        Report.Run(50010, true, false, PayrollEmp);
                    end;
                end;
            }
        }
    }

    trigger OnInit()
    begin
        //TODO
        /*IF UserSetup.GET(USERID) THEN
        BEGIN
        IF UserSetup."View Payroll"=FALSE THEN ERROR ('You dont have permissions for payroll, Contact your system administrator! ')
        END;*/

    end;

    var
        PayrollEmp: Record "Payroll Employee.";
        PayrollManager: Codeunit 51516002;
        "Payroll Period": Date;
        PayrollCalender: Record "Payroll Calender.";
        PayrollMonthlyTrans: Record "Payroll Monthly Transactions.";
        PayrollEmployeeDed: Record "Payroll Employee Deductions.";
        PayrollEmployerDed: Record "Payroll Employer Deductions.";
        objEmp: Record "Salary Processing Header";
        SalCard: Record "Payroll Employee.";
        objPeriod: Record "Payroll Calender.";
        SelectedPeriod: Date;
        PeriodName: Text[30];
        PeriodMonth: Integer;
        PeriodYear: Integer;
        ProcessPayroll: Codeunit 51516015;
        HrEmployee: Record "Payroll Employee.";
        ProgressWindow: Dialog;
        prPeriodTransactions: Record "prPeriod Transactions..";
        prEmployerDeductions: Record "Payroll Employer Deductions.";
        PayrollType: Record "Payroll Type.";
        Selection: Integer;
        PayrollDefined: Text[30];
        PayrollCode: Code[10];
        NoofRecords: Integer;
        i: Integer;
        ContrInfo: Record "Control-Information.";
        UserSetup: Record "User Setup";
        ObjPayrollTransactions: Record "prPeriod Transactions.";
        varPeriodMonth: Integer;
        SMSMessage: Record "SMS Messages";
        iEntryNo: Integer;
        GenSetup: Record "Sacco General Set-Up";
        compinfo: Record "Company Information";
        Cust: Record "Member Register";

    local procedure RemoveTrans(EmpNo: Code[20]; PayrollPeriod: Date)
    begin
    end;
}

