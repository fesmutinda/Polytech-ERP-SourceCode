#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516519 "SMS Messages"
{
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = 51516471;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No"; "Entry No")
                {
                    ApplicationArea = Basic;
                }
                field(Source; Source)
                {
                    ApplicationArea = Basic;
                }
                field("Telephone No"; "Telephone No")
                {
                    ApplicationArea = Basic;
                }
                field("SMS Message"; "SMS Message")
                {
                    ApplicationArea = Basic;
                }
                field("Date Entered"; "Date Entered")
                {
                    ApplicationArea = Basic;
                }
                field("Time Entered"; "Time Entered")
                {
                    ApplicationArea = Basic;
                }
                field("Entered By"; "Entered By")
                {
                    ApplicationArea = Basic;
                }
                field("Sent To Server"; "Sent To Server")
                {
                    ApplicationArea = Basic;
                }
                field("Bulk SMS Balance"; "Bulk SMS Balance")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        if Usersetup.Get(UserId) then begin
            if Usersetup."View Payroll" = false then Error('You dont have permissions for SMS Page Due To Opt, Contact your system administrator! ')
        end;
    end;

    var
        Usersetup: Record "User Setup";
}

