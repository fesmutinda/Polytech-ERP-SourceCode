// page 50013 "Polytech Dividend Lines"
// {
//     ApplicationArea = All;
//     Caption = 'Polytech Dividend Lines';
//     SourceTable = "Polytech Dividend Lines";
//     PageType = ListPart;
//     RefreshOnActivate = true;

//     layout
//     {
//         area(Content)
//         {
//             repeater(General)
//             {
//                 field("Receipt Line No"; Rec."Receipt Line No")
//                 {
//                     Visible = false;
//                 }
//                 field("Entry No"; Rec."Entry No")
//                 {
//                     Editable = false;
//                     ApplicationArea = Basic;
//                 }
//                 field("Member No"; Rec."Member No")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field(Name; Rec.Name)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("ID No."; Rec."ID No.")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Member Found"; Rec."Member Found")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Gross Dividend"; Rec."Gross Dividend") { ApplicationArea = Basic; }
//                 field("Interest on Deposits"; Rec."Interest on Deposits") { ApplicationArea = Basic; }
//                 field("Total Earning"; Rec."Total Earning") { ApplicationArea = Basic; }
//                 field("WTX Tax"; Rec."WTX Tax") { ApplicationArea = Basic; }
//                 field(Commision; Rec.Commision) { ApplicationArea = Basic; }
//                 field("Net Dividends"; Rec."Net Dividends") { ApplicationArea = Basic; }
//                 field("Loan Arrears"; Rec."Loan Arrears") { ApplicationArea = Basic; }

//             }
//         }
//     }
// }
