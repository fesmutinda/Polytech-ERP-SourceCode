#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
page 50579 "SwizzKash Paybill Trans"
{
    CardPageID = "SwizzKash Paybill Tran Card";
    PageType = List;
    SourceTable = "SwizzKash MPESA Trans";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic;
                }
                field(Telephone; Rec.Telephone)
                {
                    ApplicationArea = Basic;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                }
                field("Needs Manual Posting"; Rec."Needs Manual Posting")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Time"; Rec."Transaction Time")
                {
                    ApplicationArea = Basic;
                }
                field("Paybill Acc Balance"; Rec."Paybill Acc Balance")
                {
                    ApplicationArea = Basic;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic;
                }
                field("Date Posted"; Rec."Date Posted")
                {
                    ApplicationArea = Basic;
                }
                field("Time Posted"; Rec."Time Posted")
                {
                    ApplicationArea = Basic;
                }
                field("Approved By"; Rec."Approved By")
                {
                    ApplicationArea = Basic;
                }
                field("Key Word"; Rec."Key Word")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }
}

