#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Report 50054 "Loan Defaulter 2nd Notice"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Layouts/LoanDefaulter_2ndNotice.rdl';

    dataset
    {
        dataitem("Loans Register"; "Loans Register")
        {
            RequestFilterFields = "Client Code", "Loan  No.", "Loans Category-SASRA";
            column(ReportForNavId_1102755000; 1102755000)
            {
            }
            column(OutstandingBalance_Loans; "Loans Register"."Outstanding Balance")
            {
            }
            column(LoanNo_Loans; "Loans Register"."Loan  No.")
            {
            }
            column(ClientName_Loans; "Loans Register"."Client Name")
            {
            }
            column(LoanProductType_LoansRegister; "Loans Register"."Loan Product Type")
            {
            }
            column(LoanProductTypeName_LoansRegister; "Loans Register"."Loan Product Type Name")
            {
            }
            column(ClientCode_Loans; "Loans Register"."Client Code")
            {
            }

            column(LoanNo_LoansPrinciple; "Loans Register"."Approved Amount")
            {
            }
            column(LoanNo_LoanDate; "Loans Register"."Issued Date")
            {
            }
            column(LoanNo_LoanPeriod; "Loans Register"."Instalment Period")
            {
            }
            column(LoanNo_LoanPeriodInt; "Loans Register".Installments)
            {
            }
            column(recoverNoticedate; recoverNoticedate)
            {
            }

            //
            column(AmountInArrears; AmountInArrears) { }
            column(LoanOutstanding_Balance; "LoanOutstanding Balance") { }
            column(LoanOutstanding_Interest; "LOutstanding Interest") { }
            column(LInstallments; LInstallments) { }
            column(RemainingPeriod; RemainingPeriod) { }

            column(GNo; GNo)
            {
            }
            column(Gname; Gname)
            {
            }

            dataitem("Members Register"; Customer)
            {
                DataItemLink = "No." = field("Client Code");
                column(ReportForNavId_1102755005; 1102755005)
                {
                }
                column(City_Members; "Members Register".City)
                {
                }
                column(Address2_Members; "Members Register"."Address 2")
                {
                }
                column(Address_Members; "Members Register".Address)
                {
                }
                column(DOCNAME; DOCNAME)
                {
                }
                column(CName; CompanyInfo.Name)
                {
                }
                column(Caddress; CompanyInfo.Address)
                {
                }
                column(CmobileNo; CompanyInfo."Phone No.")
                {
                }
                column(clogo; CompanyInfo.Picture)
                {
                }
                column(Cwebsite; CompanyInfo."Home Page")
                {
                }
                column(Email; CompanyInfo."E-Mail")
                {
                }
                column(loansOFFICER; Lofficer)
                {
                }

                // trigger OnAfterGetRecord()
                // begin
                //     // workString := CONVERTSTR(Customer.Name, ' ', ',');
                //     // DearM := SELECTSTR(1, workString);
                //     // //LastPDate := 0D;
                //     // Balance := 0;
                //     // SharesB := 0;
                // end;


            }
            dataitem("Loans Register1"; "Loans Register")
            {
                DataItemLink = "Loan  No." = field("Loan  No.");
                dataitem("Loans Guarantee Details"; "Loans Guarantee Details")
                {
                    DataItemLink = "Loan No" = field("Loan  No.");
                    column(ReportForNavId_1102755009; 1102755009)
                    {
                    }
                    column(MemberNo_LoanGuarantors; "Loans Guarantee Details"."Member No")
                    {
                    }
                    column(Name_LoanGuarantors; "Loans Guarantee Details".Name)
                    {
                    }
                }
            }
            trigger OnAfterGetRecord()
            var
                LoanGuar: Record "Loans Guarantee Details";

            begin
                /* LoanGuar.Reset;
                LoanGuar.SetRange(LoanGuar."Loan No", "Loans Register"."Loan  No.");
                if LoanGuar.FindSet() then begin
                    repeat
                        Gname := LoanGuar.Name;
                        GNo := LoanGuar."Member No";
                    //MESSAGE('Guar No is %1 Name of %2', GNo, Gname)
                    until LoanGuar.Next = 0;
                end; */

                RemainingPeriod := Round(ObjLoans.Installments - ObjSwizzsoft.KnGetCurrentPeriodForLoan("Loan  No."));

                ObjLoans.Reset();
                ObjLoans.SetRange("Loan  No.", "Loans Register"."Loan  No.");
                if ObjLoans.FindLast() then begin
                    ObjLoans.CalcFields(ObjLoans."Outstanding Balance", "Oustanding Interest");
                    LInstallments := ObjLoans.Installments;
                    DisbursementDate := ObjLoans."Loan Disbursement Date";
                    ExpectedCompleteDate := ObjLoans."Expected Date of Completion";
                    AmountInArrears := ROUND(ObjSwizzsoft.FnGetLoanInArrears("Loans Register"."Loan  No.", ObjLoans."Outstanding Balance"), 1, '=') + ObjLoans."Oustanding Interest";
                    "LoanOutstanding Balance" := ObjLoans."Outstanding Balance";
                    "LoanIssued" := ObjLoans."Approved Amount";
                    "LOutstanding Interest" := ObjLoans."Oustanding Interest";
                    "Loan Product Name" := ObjLoans."Loan Product Type Name";
                    //Message('Amount in Arrears is %1 + %2 = %3 disbursed on %4', "LOutstanding Interest", "LoanOutstanding Balance", AmountInArrears, DisbursementDate);
                end;
                recoverNoticedate := CALCDATE('1M', TODAY);
            end;


            /* trigger OnAfterGetRecord()
            var
                LoanGuar: Record "Loans Guarantee Details";

            begin
                LoanGuar.Reset;
                LoanGuar.SetRange(LoanGuar."Loan No", "Loans Register"."Loan  No.");
                if LoanGuar.Find('-') then begin
                    AllGnames := '';
                    AllGNos := '';
                    repeat
                        AllGnames := AllGnames + LoanGuar.Name + ', ';
                        AllGNos := AllGNos + LoanGuar."Member No" + ', ';
                    until LoanGuar.Next = 0;

                    // Remove trailing comma and space
                    AllGnames := CopyStr(AllGnames, 1, StrLen(AllGnames) - 2);
                    AllGNos := CopyStr(AllGNos, 1, StrLen(AllGNos) - 2);

                    // MESSAGE('Gnames: %1\nGNos: %2', AllGnames, AllGNos);
                end;
            end;
 */
            /*  trigger OnAfterGetRecord()
             var
                 LoanGuar: Record "Loans Guarantee Details";

             begin
                 LoanGuar.Reset;
                 LoanGuar.SetRange(LoanGuar."Loan No", "Loans Register"."Loan  No.");
                 Index := 1;
                 if LoanGuar.Find('-') then begin
                     repeat
                         if Index <= ArrayLen(Gnames) then begin
                             Gnames[Index] := LoanGuar.Name;
                             GNos[Index] := LoanGuar."Member No";
                             Index += 1;
                         end;
                     until LoanGuar.Next = 0;

                     // Example: Display all values in the array
                     //     for Index := 1 to ArrayLen(Gnames) do
                     //         if Gnames[Index] <> '' then
                     //             MESSAGE('Name: %1, Member No: %2', Gnames[Index], GNos[Index]);
                 end;
             end;
  */
            /*  trigger OnAfterGetRecord()
             var
                 LoanGuar: Record "Loans Guarantee Details";
                 TempLoanGuar: Record "Loans Guarantee Details" temporary;

             begin
                 LoanGuar.Reset;
                 LoanGuar.SetRange(LoanGuar."Loan No", "Loans Register"."Loan  No.");
                 if LoanGuar.Find('-') then begin
                     repeat
                         TempLoanGuar.Init();
                         TempLoanGuar.Name := LoanGuar.Name;
                         Gname := TempLoanGuar.Name;
                         TempLoanGuar."Member No" := LoanGuar."Member No";
                         GNo := TempLoanGuar."Member No";
                         TempLoanGuar.Insert();
                     until LoanGuar.Next = 0;

                     // The TempLoanGuar table now contains all the records for the report
                     MESSAGE('Temporary table populated.');
                 end;
             end;
  */

        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInfo.Get;
        CompanyInfo.CalcFields(Picture);

        DOCNAME := 'SECOND DEMAND NOTICE';
        Lofficer := UserId;
    end;

    var
        DOCNAME: Text[30];
        CompanyInfo: Record "Company Information";
        Lofficer: Text;
        recoverNoticedate: Date;
        RemainingPeriod: Integer;
        Gname: Text;
        GNo: Code[20];
        ObjLoans: Record "Loans Register";
        "Loan Product Name": Text;
        "LOutstanding Interest": Decimal;
        LoanIssued: Decimal;
        "LoanOutstanding Balance": Decimal;
        AmountInArrears: Decimal;
        LInstallments: Integer;
        ExpectedCompleteDate: date;
        DisbursementDate: date;
        ObjSwizzsoft: Codeunit "Swizzsoft Factory.";

        Gnames: array[100] of Text[100];
        GNos: array[100] of Text[100];
        Index: Integer;

        AllGnames: Text;
        AllGNos: Text;


}

