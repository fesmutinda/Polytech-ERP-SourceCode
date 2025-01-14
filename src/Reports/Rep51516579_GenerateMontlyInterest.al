// Report 51516579 "Generate Monthly Interest"
// {
//     dataset
//     {
//         dataitem("Loans Register"; "Loans Register")
//         {

//         }
//     }


//     trigger OnPreReport()
//     begin





//         dWindow.OPEN('Generating Interest:                #1#########\'
//                             + 'Total Loans:                #2#########\'
//                             + 'Counter:                    #3#########\'
//                             + 'Progress:                   @4@@@@@@@@@\'
//                             + 'Press Esc to abort');


//         IF BillDate = 0D THEN
//             BillDate := TODAY;


//         //BillDate:=CALCDATE('-CM',BillDate);
//         //BillDate:=CALCDATE('CM',TODAY);
//         //MESSAGE('Datetetet %1',BillDate);

//         //Loans.SETFILTER("Date Filter",'..%1',CALCDATE('-1M+CM',BillDate));
//         //Loans.SETFILTER("Outstanding Balance",'>0');
//     end;

//     trigger OnAfterGetRecord()
//     begin


// {IF "Loans Register"."Loan Product Type" = 'HISTORICAL' THEN
//             CurrReport.SKIP;}
//    //MESSAGE('Datetetet1 %1',BillDate);
//    IF "Loans Register"."Repayment Start Date" > BillDate THEN
//    CurrReport.SKIP;
//    //MESSAGE('Datetetet2 %1',BillDate);
// NoOfRecords:="Loans Register".COUNT;
// dWindow.UPDATE(2,NoOfRecords);

// dWindow.UPDATE(1,"Loans Register"."Client Name");
// CurrentRecordNo += 1;
// Exception:=FALSE;

// IF "Loans Register"."Loan Product Type" = '24' THEN 
// CurrReport.SKIP;

// IF ProdFact.GET("Loans Register"."Loan Product Type") THEN BEGIN
//   //MESSAGE('prod %1',"Loans Register"."Loan Product Type");
//     IF "Loans Register".Interest <> ProdFact."Interest rate" THEN BEGIN
//         "Loans Register".Interest := ProdFact."Interest rate";
//         "Loans Register".MODIFY;
//     END;
//     IF ProdFact."Interest Calculation Method" = ProdFact."Interest Calculation Method"::"Flat Rate" THEN BEGIN
//         IF BillDate <= "Loans Register"."Expected Date of Completion" THEN BEGIN
//             IF "Loans Register"."Interest Calculation Method" <> "Loans Register"."Interest Calculation Method"::"Flat Rate" THEN BEGIN
//                 "Loans Register"."Interest Calculation Method" := "Loans Register"."Interest Calculation Method"::"Flat Rate";
//                "Loans Register".MODIFY;
//                 COMMIT;
//             END;
//         END
//         ELSE BEGIN
//             IF "Loans Register"."Interest Calculation Method" <> "Loans Register"."Interest Calculation Method"::"Reducing Balances" THEN BEGIN
//                "Loans Register"."Interest Calculation Method" := "Loans Register"."Interest Calculation Method"::"Reducing Balances";
//                "Loans Register".MODIFY;
//                 COMMIT;
//             END;
//         END;
//     END;

// END;
// end;


// Periodic.GenerateLoanMonthlyInterest("Loans Register"."Loan  No.",BillDate);

// dWindow.UPDATE(3,CurrentRecordNo);
// dWindow.UPDATE(4,ROUND(CurrentRecordNo /  NoOfRecords * 10000,1));

// Loans Register - OnPostDataItem()
// //dWindow.CLOSE;
// {IF Options = Options::"Generate & Post" THEN BEGIN
//     InterestHeader.RESET;
//     InterestHeader.SETRANGE("No.",'INTEREST');
//     IF InterestHeader.FINDFIRST THEN BEGIN
//         Periodic.PostLoanInterest(InterestHeader);
//     END;
// END;
// }
// }