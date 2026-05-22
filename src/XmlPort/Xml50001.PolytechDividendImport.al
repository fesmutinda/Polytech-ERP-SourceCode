// xmlport 50001 "Polytech Dividend Import"
// {
//     Format = VariableText;
//     Caption = 'Polytech Dividend Import';
//     schema
//     {
//         textelement(RootNodeName)
//         {
//             tableelement(PolytechDividendLines; "Polytech Dividend Lines")
//             {
//                 fieldelement(DivYear; PolytechDividendLines."Receipt Dividend Year") { }
//                 fieldelement(memberNumber; PolytechDividendLines."Member No") { }
//                 fieldelement(GrosDividend; PolytechDividendLines."Gross Dividend") { }
//                 fieldelement(IntersetDeposits; PolytechDividendLines."Interest on Deposits") { }
//                 fieldelement(TotalEarning; PolytechDividendLines."Total Earning") { }
//                 fieldelement(wtxTax; PolytechDividendLines."WTX Tax") { }
//                 fieldelement(commision; PolytechDividendLines.Commision) { }
//                 fieldelement(NetDividend; PolytechDividendLines."Net Dividends") { }
//                 fieldelement(LoanArrears; PolytechDividendLines."Loan Arrears") { }
//             }
//         }
//     }
// }