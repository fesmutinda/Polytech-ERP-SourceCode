#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50348 "NHIF Schedule W.."
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layout/NHIF Schedule W...rdlc';

    dataset
    {
        dataitem("Payroll Employee."; "Payroll Employee.")
        {
            DataItemTableView = where(Status = const(Active));
            column(ReportForNavId_6207; 6207)
            {
            }
            column(USERID; UserId)
            {
            }
            column(TODAY; Today)
            {
            }
            column(PeriodName; PeriodName)
            {
            }
            column(CurrReport_PAGENO; CurrReport.PageNo)
            {
            }
            column(Companyinfo_Picture; Companyinfo.Picture)
            {
            }
            column(COMPANYNAME; COMPANYNAME)
            {
            }
            column(Address; Address)
            {
            }
            column(EmployerNHIFNo; EmployerNHIFNo)
            {
            }
            column(Tel; Tel)
            {
            }
            column(CompPINNo; CompPINNo)
            {
            }
            column(NhifAmount; NhifAmount)
            {
            }
            column(IDNumber; IDNumber)
            {
            }
            column(NhifNo; NhifNo)
            {
            }
            column(EmployeeName; EmployeeName)
            {
            }
            column(prSalary_Card__prSalary_Card___Employee_Code_; "Payroll Employee."."No.")
            {
            }
            column(Dob; Dob)
            {
            }
            column(TotNhifAmount; TotNhifAmount)
            {
            }
            column(NATIONAL_HOSPITAL_INSURANCE_FUNDCaption; NATIONAL_HOSPITAL_INSURANCE_FUNDCaptionLbl)
            {
            }
            column(User_Name_Caption; User_Name_CaptionLbl)
            {
            }
            column(Print_Date_Caption; Print_Date_CaptionLbl)
            {
            }
            column(Period_Caption; Period_CaptionLbl)
            {
            }
            column(Page_Nov_Caption; Page_No_CaptionLbl)
            {
            }
            column(PERIOD_Caption_Control1102755032; PERIOD_Caption_Control1102755032Lbl)
            {
            }
            column(ADDRESS_Caption; ADDRESS_CaptionLbl)
            {
            }
            column(EMPLOYER_Caption; EMPLOYER_CaptionLbl)
            {
            }
            column(EMPOLOYER_NO_Caption; EMPOLOYER_NO_CaptionLbl)
            {
            }
            column(EMPLOYER_PIN_NO_Caption; EMPLOYER_PIN_NO_CaptionLbl)
            {
            }
            column(TEL_NO_Caption; TEL_NO_CaptionLbl)
            {
            }
            column(AmountCaption; AmountCaptionLbl)
            {
            }
            column(ID_Number_Caption; ID_Number_CaptionLbl)
            {
            }
            column(NHIF_No_Caption; NHIF_No_CaptionLbl)
            {
            }
            column(Employee_NameCaption; Employee_NameCaptionLbl)
            {
            }
            column(No_Caption; No_CaptionLbl)
            {
            }
            column(Date_Of_BirthCaption; Date_Of_BirthCaptionLbl)
            {
            }
            column(Prepared_by_______________________________________Date_________________Caption; Prepared_by_______________________________________Date_________________CaptionLbl)
            {
            }
            column(Checked_by________________________________________Date_________________Caption; Checked_by________________________________________Date_________________CaptionLbl)
            {
            }
            column(Authorized_by____________________________________Date_________________Caption; Authorized_by____________________________________Date_________________CaptionLbl)
            {
            }
            column(Total_NHIF_Caption; Total_NHIF_CaptionLbl)
            {
            }
            column(Approved_by______________________________________Date_________________Caption; Approved_by______________________________________Date_________________CaptionLbl)
            {
            }
            column(Page_No_Caption; Page_No_CaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin

                NhifAmount := 0;
                objEmp.Reset;
                objEmp.SetRange(objEmp."No.", "No.");
                if objEmp.Find('-') then;
                EmployeeName := objEmp."Full Name";
                NhifNo := objEmp."NHIF No";
                IDNumber := objEmp."National ID No";
                //Dob:=objEmp."Date Of Birth";

                PeriodTrans.Reset;
                PeriodTrans.SetRange(PeriodTrans."Employee Code", "Payroll Employee."."No.");
                PeriodTrans.SetRange(PeriodTrans."Payroll Period", SelectedPeriod);
                PeriodTrans.SetRange(PeriodTrans."Transaction Code", 'NHIF');
                // PeriodTrans.SetRange(PeriodTrans."Sub Group Order", 2);
                // PeriodTrans.SetCurrentkey(PeriodTrans."Employee Code", PeriodTrans."Period Month", PeriodTrans."Period Year",
                // PeriodTrans."Group Order", PeriodTrans."Sub Group Order");
                if PeriodTrans.FindSet() then begin
                    if PeriodTrans.Amount = 0 then CurrReport.Skip;
                    NhifAmount := PeriodTrans.Amount;
                    TotNhifAmount := TotNhifAmount + PeriodTrans.Amount;
                end;
            end;

            trigger OnPreDataItem()
            begin
                // NhifAmount := 0;


                if CompInfoSetup.Get() then
                    //EmployerNHIFNo := CompInfoSetup.;
                CompPINNo := CompInfoSetup."Company P.I.N";
                Address := CompInfoSetup.Address;
                Tel := CompInfoSetup."Phone No.";
                // Clear(TotNhifAmount);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Basic;
                    Caption = 'Period Filter';
                    TableRelation = "Payroll Calender.";
                }
            }
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
        objPeriod.Reset;
        objPeriod.SetRange(objPeriod.Closed, false);
        if objPeriod.Find('-') then;
        PeriodFilter := objPeriod."Date Opened";
    end;

    trigger OnPreReport()
    begin
        if UserSetup.Get(UserId) then begin
            if UserSetup."Payroll User" = false then Error('You dont have permissions for payroll, Contact your system administrator! ')
        end;


        SelectedPeriod := DateFilter;

        objPeriod.Reset;
        objPeriod.SetRange(objPeriod."Date Opened", SelectedPeriod);
        if objPeriod.Find('-') then begin
            PeriodName := objPeriod."Period Name";
        end;


        if Companyinfo.Get() then
            Companyinfo.CalcFields(Companyinfo.Picture);
    end;

    var
        UserSetup: Record "User Setup";
        PeriodTrans: Record "prPeriod Transactions.";
        NhifAmount: Decimal;
        TotNhifAmount: Decimal;
        EmployeeName: Text[150];
        NhifNo: Text[30];
        IDNumber: Text[30];
        objPeriod: Record "Payroll Calender.";
        SelectedPeriod: Date;
        PeriodName: Text[30];
        PeriodFilter: Date;
        objEmp: Record "Payroll Employee.";
        CompInfoSetup: Record "Company Information";
        EmployerNHIFNo: Code[20];
        CompPINNo: Code[20];
        Address: Text[90];
        Tel: Text[30];
        Dob: Date;
        Companyinfo: Record "Company Information";
        NATIONAL_HOSPITAL_INSURANCE_FUNDCaptionLbl: label 'NATIONAL HOSPITAL INSURANCE FUND';
        User_Name_CaptionLbl: label 'User Name:';
        Print_Date_CaptionLbl: label 'Print Date:';
        Period_CaptionLbl: label 'Period:';
        Page_No_CaptionLbl: label 'Page No:';
        PERIOD_Caption_Control1102755032Lbl: label 'PERIOD:';
        ADDRESS_CaptionLbl: label 'ADDRESS:';
        EMPLOYER_CaptionLbl: label 'EMPLOYER:';
        EMPOLOYER_NO_CaptionLbl: label 'EMPLOYER NO:';
        EMPLOYER_PIN_NO_CaptionLbl: label 'EMPLOYER PIN NO:';
        TEL_NO_CaptionLbl: label 'TEL NO:';
        AmountCaptionLbl: label 'Amount';
        ID_Number_CaptionLbl: label 'ID Number:';
        NHIF_No_CaptionLbl: label 'NHIF No:';
        Employee_NameCaptionLbl: label 'Employee Name';
        No_CaptionLbl: label 'No:';
        Date_Of_BirthCaptionLbl: label 'Date Of Birth';
        Prepared_by_______________________________________Date_________________CaptionLbl: label 'Prepared by……………………………………………………..                 Date……………………………………………';
        Checked_by________________________________________Date_________________CaptionLbl: label 'Checked by…………………………………………………..                   Date……………………………………………';
        Authorized_by____________________________________Date_________________CaptionLbl: label 'Authorized by……………………………………………………..              Date……………………………………………';
        Total_NHIF_CaptionLbl: label 'Total NHIF:';
        Approved_by______________________________________Date_________________CaptionLbl: label 'Approved by……………………………………………………..                Date……………………………………………';
        DateFilter: Date;
}

