#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Table 51516012 "Payments Header Board"
{

    fields
    {
        field(1; "Transaction No."; Code[10])
        {
        }
        field(2; Amount; Decimal)
        {
        }
        field(3; "Cheque No."; Code[20])
        {
        }
        field(4; "Cheque Date"; Date)
        {
        }
        field(5; Posted; Boolean)
        {
        }
        field(6; "Bank No."; Code[10])
        {
            TableRelation = "Bank Account"."No.";
        }
        field(7; "User ID"; Code[50])
        {
        }
        field(8; "Allocated Amount"; Decimal)
        {
            CalcFormula = sum("Payment Line Board".Amount where("Document No" = field("Transaction No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(9; "Transaction Date"; Date)
        {
        }
        field(10; "Transaction Time"; Time)
        {
        }
        field(11; "No. Series"; Code[10])
        {
        }
        field(12; Status; Option)
        {
            Editable = false;
            OptionCaption = 'Open,Pending Approval,Approved,Posted,Cancelled';
            OptionMembers = Open,"Pending Approval",Approved,Posted,Cancelled;
        }
        field(13; "Posted By"; Code[50])
        {
        }
        field(14; "File Location"; Text[30])
        {
        }
        field(15; Remarks; Text[50])
        {
        }
        field(67; "Pay Mode"; Option)
        {
            OptionCaption = 'FOSA,CASH';
            OptionMembers = FOSA,CASH;
        }
        field(68; "Payment Type"; Option)
        {
            OptionMembers = Board,Staff;
        }
        field(69; "Responsibility Center"; Code[10])
        {
            Editable = true;
            TableRelation = "Responsibility Center";
        }
        field(70; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            Caption = 'Shortcut Dimension 1 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(71; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            Caption = 'Shortcut Dimension 2 Code';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(72; "Paying Bank"; Code[20])
        {
            TableRelation = if ("Pay Mode" = const(CASH)) "Bank Account" where("Bank Type" = filter("Petty Cash" | Cash));

            trigger OnValidate()
            begin
                "Paying Bank Name" := '';

                if BankAcc.Get("Paying Bank") then
                    "Paying Bank Name" := BankAcc.Name;
            end;
        }
        field(73; "Paying Bank Name"; Text[50])
        {
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Transaction No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        if (Posted) or (Status <> Status::Open) then
            Error('You can only delete an open transaction');
    end;

    trigger OnInsert()
    begin

        if "Transaction No." = '' then begin
            NoSetup.Get();
            if "Payment Type" = "payment type"::Board then begin
                NoSetup.TestField(NoSetup."Board PVs Nos.");
                NoSeriesMgt.InitSeries(NoSetup."Board PVs Nos.", xRec."No. Series", 0D, "Transaction No.", "No. Series");
            end
            else if "Payment Type" = "payment type"::Staff then begin
                NoSetup.TestField(NoSetup."Board PVs Nos.");
                NoSeriesMgt.InitSeries(NoSetup."Imprest Req No", xRec."No. Series", 0D, "Transaction No.", "No. Series");
            end
        end;

        "Transaction Date" := Today;
        "User ID" := UserId;
        "Transaction Time" := Time;
        UserSetup.Get(UserId);
        //BEGIN
        UserSetup.TestField("Global Dimension 1 Code");
        UserSetup.TestField("Global Dimension 2 Code");
        UserSetup.TestField("Responsibility Centre");

        "Shortcut Dimension 1 Code" := UserSetup."Global Dimension 1 Code";
        "Shortcut Dimension 2 Code" := UserSetup."Global Dimension 2 Code";
        "Responsibility Center" := UserSetup."Responsibility Centre";
    end;

    trigger OnModify()
    begin

        if (Posted) or (Status <> Status::Open) then
            Error('You can only modify an open transaction');
    end;

    var
        Cust: Record "Member Register";
        NoSetup: Record "Funds User Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        BOSARcpt: Record "Receipt Header";
        GLAcct: Record "G/L Account";
        UserSetup: Record "User Setup";
        BankAcc: Record "Bank Account";
}

