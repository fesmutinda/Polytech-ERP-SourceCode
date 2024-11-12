#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516935 "Loan Other Charges"
{
    PageType = List;
    SourceTable = 51516656;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Loan No."; "Loan No.")
                {
                    ApplicationArea = Basic;
                }
                field("Client Code"; "Client Code")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Type"; "Loan Type")
                {
                    ApplicationArea = Basic;
                }
                field("Code"; Code)
                {
                    ApplicationArea = Basic;
                }
                field("G/L Account"; "G/L Account")
                {
                    ApplicationArea = Basic;
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin

        ObjLoans.Reset;
        ObjLoans.SetRange(ObjLoans."Loan  No.", "Loan No.");
        if ObjLoans.FindSet then begin

            if "Loan Type" = '' then
                "Loan Type" := ObjLoans."Loan Product Type";
            Modify(true);
            if ObjLoans."Loan Product Type" = '' then
                Error('Please select the loan type');
        end;
    end;

    var
        ObjLoans: Record 51516371;
}

