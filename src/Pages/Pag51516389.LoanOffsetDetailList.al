#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516389 "Loan Offset Detail List"
{
    PageType = List;
    SourceTable = 51516376;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan No."; "Loan No.")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                }
                field("Loan Top Up"; "Loan Top Up")
                {
                    ApplicationArea = Basic;
                    Caption = 'Loan to Offset';
                }
                field("Client Code"; "Client Code")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Enabled = false;
                }
                field("Loan Type"; "Loan Type")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Principle Top Up"; "Principle Top Up")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Age"; "Loan Age")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Remaining Installments"; "Remaining Installments")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Interest Top Up"; "Interest Top Up")
                {
                    ApplicationArea = Basic;
                }
                field("Monthly Repayment"; "Monthly Repayment")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Interest Paid"; "Interest Paid")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Outstanding Balance"; "Outstanding Balance")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Interest Rate"; "Interest Rate")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Commision; Commision)
                {
                    ApplicationArea = Basic;
                    Caption = 'Fee';
                }
                field("Interest Due at Clearance"; "Interest Due at Clearance")
                {
                    ApplicationArea = Basic;
                    Caption = ' Interest Due';
                    Visible = false;
                }
                field("Total Top Up"; "Total Top Up")
                {
                    ApplicationArea = Basic;
                    Caption = 'Total Recovery';
                    Editable = false;
                    Importance = Promoted;
                    Style = Attention;
                    StyleExpr = true;
                }
                field("Partial Bridged"; "Partial Bridged")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                    Visible = false;
                }
                field("Staff No"; "Staff No")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Loan Payoff")
            {
                ApplicationArea = Basic;
                Image = Document;
                Promoted = true;
                RunObject = Page "Loan PayOff List";
            }
            action(ReduceLoanBalance)
            {
                ApplicationArea = Basic;
                Image = Post;
                Promoted = true;

                trigger OnAction()
                begin

                    ObjLoanOffset.Reset;
                    ObjLoanOffset.SetRange(ObjLoanOffset."Loan Top Up", "Loan Top Up");
                    ObjLoanOffset.SetRange(ObjLoanOffset."FOSA Account", "FOSA Account");
                    if ObjLoanOffset.Find('-') then begin
                        if ObjLoanOffset."FOSA Account" = '' then begin
                            Error('Specify the FOSA Account to be Debited When reducing the Loan');
                        end;
                        Report.Run(51516934, true, false, ObjLoanOffset);
                    end;
                end;
            }
        }
    }

    var
        ObjLoanOffset: Record UnknownRecord51516376;
}

