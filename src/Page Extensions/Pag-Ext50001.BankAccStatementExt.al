
pageextension 50001 "Bank Acc Statement Ext" extends "Bank Account Statement List"
{
    actions
    {
        addafter(Print)
        {
            action(Report)
            {
                ApplicationArea = Basic;
                Caption = 'Print Statement';
                Image = "Report";

                trigger OnAction()
                begin


                    Report.Run(51007, true, false, Rec);
                end;
            }
        }
    }
    trigger OnOpenPage()// OnInit()
    var
        UserSetup: Record "User Setup";
    begin
        IF Usersetup.GET(USERID) THEN BEGIN
            IF Usersetup."Bank Account Reconciliations" = FALSE THEN ERROR('You dont have permissions for Bank Account Reconciliations, Contact your system administrator! ')
        END;
    end;
}
