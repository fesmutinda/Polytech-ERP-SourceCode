#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
table 50031 "Funds User Setup"
{

    fields
    {
        field(10; UserID; Code[50])
        {
            NotBlank = true;

            trigger OnLookup()
            begin
                UserManager.LookupUserID(UserID);
            end;

            trigger OnValidate()
            begin
                UserManager.ValidateUserID(UserID);
            end;
        }
        field(11; "Receipt Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name;
        }
        field(12; "Receipt Journal Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Receipt Journal Template"));

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                UserTemp.Reset;
                UserTemp.SetRange(UserTemp."Receipt Journal Template", "Receipt Journal Template");
                UserTemp.SetRange(UserTemp."Receipt Journal Batch", "Receipt Journal Batch");
                if UserTemp.FindFirst then begin
                    repeat
                        if (UserTemp.UserID <> UserID) and ("Receipt Journal Batch" <> '') then begin
                            Error(SameBatch, "Receipt Journal Batch");
                        end;
                    until UserTemp.Next = 0;
                end;

            end;
        }
        field(13; "Payment Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(Payments));
        }
        field(14; "Payment Journal Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Payment Journal Template"));

            trigger OnValidate()
            begin
                //Check if the batch has been allocated to another user
                UserTemp.Reset;
                UserTemp.SetRange(UserTemp."Payment Journal Template", "Payment Journal Template");
                UserTemp.SetRange(UserTemp."Payment Journal Batch", "Payment Journal Batch");
                if UserTemp.FindFirst then begin
                    repeat
                        if (UserTemp.UserID <> Rec.UserID) and ("Payment Journal Batch" <> '') then begin
                            Error(SameBatch, "Receipt Journal Batch", "Payment Journal Batch");
                        end;
                    until UserTemp.Next = 0;
                end;
            end;
        }
        field(15; "Petty Cash Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(Payments));
        }
        field(16; "Petty Cash Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Petty Cash Template"));

            trigger OnValidate()
            begin
                //Check if the batch has been allocated to another user
                UserTemp.Reset;
                UserTemp.SetRange(UserTemp."Petty Cash Template", "Petty Cash Template");
                UserTemp.SetRange(UserTemp."Petty Cash Batch", "Petty Cash Batch");
                if UserTemp.FindFirst then begin
                    repeat
                        if (UserTemp.UserID <> Rec.UserID) and ("Petty Cash Batch" <> '') then begin
                            Error(SameBatch, "Receipt Journal Batch", "Petty Cash Batch");
                        end;
                    until UserTemp.Next = 0;
                end;
            end;
        }
        field(17; "FundsTransfer Template Name"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(Payments));
        }
        field(18; "FundsTransfer Batch Name"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("FundsTransfer Template Name"));
            trigger OnValidate()
            begin
                //Check if the batch has been allocated to another user
                UserTemp.Reset;
                UserTemp.SetRange(UserTemp."FundsTransfer Template Name", "FundsTransfer Template Name");
                UserTemp.SetRange(UserTemp."FundsTransfer Batch Name", "FundsTransfer Batch Name");
                if UserTemp.FindFirst then begin
                    repeat
                        if (UserTemp.UserID <> Rec.UserID) and ("FundsTransfer Batch Name" <> '') then begin
                            Error(SameBatch, "Receipt Journal Batch", "Petty Cash Batch");
                        end;
                    until UserTemp.Next = 0;
                end;
            end;
        }
        field(19; "Default Receipts Bank"; Code[20])
        {
            TableRelation = "Bank Account"."No.";

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                /*UserTemp.RESET;
                UserTemp.SETRANGE(UserTemp."Default Receipts Bank","Default Receipts Bank");
                IF UserTemp.FINDFIRST THEN
                  BEGIN
                    REPEAT
                      IF UserTemp.UserID<>Rec.UserID THEN
                        BEGIN
                          ERROR('Please note that another user has been assigned the same bank.');
                        END;
                    UNTIL UserTemp.NEXT=0;
                  END;
                 */

            end;
        }
        field(20; "Default Payment Bank"; Code[20])
        {
            TableRelation = "Bank Account";

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                /*UserTemp.RESET;
                UserTemp.SETRANGE(UserTemp."Default Payment Bank","Default Payment Bank");
                IF UserTemp.FINDFIRST THEN
                  BEGIN
                    REPEAT
                      IF UserTemp.UserID<>Rec.UserID THEN
                        BEGIN
                          ERROR('Please note that another user has been assigned the same bank.');
                        END;
                    UNTIL UserTemp.NEXT=0;
                  END;
                 */

            end;
        }
        field(21; "Default Petty Cash Bank"; Code[20])
        {
            TableRelation = "Bank Account"."No.";

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                /*UserTemp.RESET;
                UserTemp.SETRANGE(UserTemp."Default Petty Cash Bank","Default Petty Cash Bank");
                IF UserTemp.FINDFIRST THEN
                  BEGIN
                    REPEAT
                      IF UserTemp.UserID<>Rec.UserID THEN
                        BEGIN
                          ERROR('Please note that another user has been assigned the same bank.');
                        END;
                    UNTIL UserTemp.NEXT=0;
                  END;
                 */

            end;
        }
        field(22; "Max. Cash Collection"; Decimal)
        {
        }
        field(23; "Max. Cheque Collection"; Decimal)
        {
        }
        field(24; "Max. Deposit Slip Collection"; Decimal)
        {
        }
        field(25; "Supervisor ID"; Code[50])
        {

            trigger OnLookup()
            begin
                /*LoginMgt.LookupUserID("Supervisor ID");*/

            end;

            trigger OnValidate()
            begin
                /*LoginMgt.ValidateUserID("Supervisor ID");*/

            end;
        }
        field(26; "Bank Pay In Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(General));
        }
        field(27; "Bank Pay In Journal Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Bank Pay In Journal Template"));

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                /*UserTemp.RESET;
                UserTemp.SETRANGE(UserTemp."Bank Pay In Journal Template","Bank Pay In Journal Template");
                UserTemp.SETRANGE(UserTemp."Bank Pay In Journal Batch","Bank Pay In Journal Batch");
                IF UserTemp.FINDFIRST THEN
                  BEGIN
                    REPEAT
                      IF UserTemp.UserID<>Rec.UserID THEN
                        BEGIN
                          ERROR('Please note that another user has been assigned the same batch.');
                        END;
                    UNTIL UserTemp.NEXT=0;
                  END;
                 */

            end;
        }
        field(28; "Imprest Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(29; "Imprest  Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name;
        }
        field(30; "Claim Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(31; "Claim  Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Claim Template"));
        }
        field(32; "Advance Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(33; "Advance  Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Advance Template"));
        }
        field(34; "Advance Surr Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template";
        }
        field(35; "Advance Surr Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Advance Surr Template"));
        }
        field(36; "Dim Change Journal Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(General));
        }
        field(37; "Dim Change Journal Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Dim Change Journal Template"));

            trigger OnValidate()
            begin
                /*Check if the batch has been allocated to another user*/
                /*UserTemp.RESET;
                UserTemp.SETRANGE(UserTemp."Payment Journal Template","Payment Journal Template");
                UserTemp.SETRANGE(UserTemp."Payment Journal Batch","Payment Journal Batch");
                IF UserTemp.FINDFIRST THEN
                  BEGIN
                    REPEAT
                IF (UserTemp.UserID<>Rec.UserID) AND ("Payment Journal Batch"<>'') THEN
                        BEGIN
                          ERROR('Please note that another user has been assigned the same batch.');
                        END;
                    UNTIL UserTemp.NEXT=0;
                  END;
                 */

            end;
        }
        field(38; "Journal Voucher Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(General));
        }
        field(39; "Journal Voucher Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Voucher Template"));
        }
        field(40; "Checkoff Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name;
        }
        field(41; "Checkoff Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name;
        }
        field(42; "Payroll Template"; Code[20])
        {
        }
        field(43; "Payroll Batch"; Code[20])
        {
        }
        field(44; "Salaries Template"; Code[20])
        {
            TableRelation = "Gen. Journal Template".Name where(Type = const(General));
        }
        field(45; "Salaries Batch"; Code[20])
        {
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Salaries Template"));

            trigger OnValidate()
            begin
                UserTemp.Reset;
                UserTemp.SetRange(UserTemp."Salaries Template", "Salaries Template");
                UserTemp.SetRange(UserTemp."Salaries Batch", "Salaries Batch");
                if UserTemp.FindFirst then begin
                    repeat
                        if (UserTemp.UserID <> Rec.UserID) and ("Salaries Batch" <> '') then begin
                            Error(SameBatch, "Receipt Journal Batch", "Salaries Batch");
                        end;
                    until UserTemp.Next = 0;
                end;
            end;
        }
    }

    keys
    {
        key(Key1; UserID)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        UserTemp: Record "Funds User Setup";
        UserManager: Codeunit "Polytech User Management";
        SameBatch: label 'Another User has been assign to the batch:%1';
}

