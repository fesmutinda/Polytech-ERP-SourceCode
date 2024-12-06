pageextension 50881 CustomerList extends "Customer List"

{

    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnOpenPage()
    var
        myInt: Integer;
    begin
        Rec.Reset();
        Rec.SetRange(rec."Customer Type", Rec."Customer Type"::Checkoff);
    end;

    var
        myInt: Integer;
}