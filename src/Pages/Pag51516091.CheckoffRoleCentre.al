#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516091 "Checkoff  Role Centre"
{
    Caption = 'Accounts  Role Centre';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            group(Control1000000015)
            {
            }
            part(Control3; "My Job Queue")
            {
                ApplicationArea = Advanced;
                Visible = false;
            }
            part(Control2; "Membership Cue")
            {
                AccessByPermission = TableData "Sales Shipment Header" = R;
                ApplicationArea = Basic, Suite;
            }
            part(Control1; "Team Member Activities")
            {
                ApplicationArea = Suite;
            }
        }
    }

    actions
    {
        area(reporting)
        {
            action("Customer Care logs")
            {
                ApplicationArea = Basic;
                Caption = 'Customer Care logs';
                Image = "Report";
                RunObject = Report 51516507;
            }
            action("Member dependants ")
            {
                ApplicationArea = Basic;
                Image = Absence;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516506;
            }
            action("Benovelent fund report")
            {
                ApplicationArea = Basic;
                Image = Web;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516918;
            }
            action("Fosa shares")
            {
                ApplicationArea = Basic;
                Image = Alerts;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516907;
            }
            action("Member Deposit balance")
            {
                ApplicationArea = Basic;
                Image = "Action";
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516873;
            }
            action("Member Shares")
            {
                ApplicationArea = Basic;
                Image = Allocate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516872;
            }
            action("Member Register list")
            {
                ApplicationArea = Basic;
                Image = LineDescription;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516887;
            }
            action("Member application list")
            {
                ApplicationArea = Basic;
                Image = List;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Report 51516489;
            }
            action("Member Statement")
            {
                ApplicationArea = Basic;
                Caption = 'Member Statement';
                Image = "Report";
                RunObject = Report 51516223;
            }
        }
        area(embedding)
        {
            action("51516435")
            {
                ApplicationArea = Basic;
                Caption = 'Fosa Accounts';
                RunObject = Page "FOSA Accounts Details Master";
            }
            action("Member List")
            {
                ApplicationArea = Basic;
                Caption = 'Member List';
                RunObject = Page "Member List";
            }
        }
    }
}

