// page 50011 "Polytech Dividend Receipt"
// {
//     Caption = 'Polytech Dividend Receipt';
//     PageType = List;
//     SourceTable = "Polytech Dividend Receipt";
//     ApplicationArea = Basic;
//     CardPageID = "Polytech Dividend Card";
//     Editable = false;
//     SourceTableView = where(Posted = filter(false));
//     UsageCategory = Lists;

//     layout
//     {
//         area(content)
//         {
//             repeater(Group)
//             {
//                 field(No; Rec.DividendYear)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Posted By"; Rec."Posted By")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Document No"; Rec."Document No")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field(Amount; Rec.Amount)
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Scheduled Amount"; Rec."Scheduled Amount")
//                 {
//                     ApplicationArea = Basic;
//                 }
//                 field("Dividend Year"; Rec."Dividend Year")
//                 {
//                     ApplicationArea = Basic;
//                 }
//             }
//         }
//     }

//     actions
//     {
//     }
// }
