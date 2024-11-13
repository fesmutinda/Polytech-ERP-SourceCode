#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516418 "Paybill Processing Line"
{
    PageType = ListPart;
    SourceTable = "Paybill Processing Lines";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Receipt Line No"; Rec."Receipt Line No")
                {
                    ApplicationArea = Basic;
                }
                field("Trans Type"; Rec."Trans Type")
                {
                    ApplicationArea = Basic;
                }
                field("Staff/Payroll No"; Rec."Staff/Payroll No")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; Rec."Member No")
                {
                    ApplicationArea = Basic;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic;
                }
                field("Mobile No"; Rec."Mobile No")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction No"; Rec."Transaction No")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Prefix"; Rec."Transaction Prefix")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic;
                }
                field("ID No."; Rec."ID No.")
                {
                    ApplicationArea = Basic;
                }
                field("Loan No"; Rec."Loan No")
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic;
                }
                field("Staff Not Found"; Rec."Staff Not Found")
                {
                    ApplicationArea = Basic;
                }
                field("Member Found"; Rec."Member Found")
                {
                    ApplicationArea = Basic;
                }
                field("Search Index"; Rec."Search Index")
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

