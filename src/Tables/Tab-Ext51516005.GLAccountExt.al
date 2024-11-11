#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
tableextension 51516005 GLAccountExt extends "G/L Account"
{

    fields
    {
        field(10001; "GIFI Code"; Code[10])
        {
            Caption = 'GIFI Code';
        }
        field(27000; "SAT Account Code"; Code[20])
        {
            Caption = 'SAT Account Code';
        }
        field(50000; "Budget Controlled"; Boolean)
        {
        }
        field(50004; "Expense Code"; Code[10])
        {
            TableRelation = "Expense Code";

            trigger OnValidate()
            begin
                //Expense code only applicable if account type is posting and Budgetary control is applicable
                TestField("Account Type", "account type"::Posting);
                TestField("Budget Controlled", true);
            end;
        }
        field(50005; "Donor defined Account"; Boolean)
        {
            Description = 'Select if the Account is donor Defined';
        }
        field(54245; "Grant Expense"; Boolean)
        {
        }
        field(54246; Status; Option)
        {
            Editable = true;
            OptionMembers = New,"Pending Approval",Approved,Rejected;
        }
        field(54247; "Responsibility Center"; Code[20])
        {
        }
        field(54248; "Old No."; Code[20])
        {
        }
        field(54249; "Date Created"; Date)
        {
        }
        field(54250; "Created By"; Code[20])
        {
        }
    }

    keys
    {
        key(Key10; "GIFI Code")
        {
        }
        key(Key11; "Account Category")
        {
        }
    }

    fieldgroups
    {

    }
    var
        Text000: label 'You cannot change %1 because there are one or more ledger entries associated with this account.';
        Text001: label 'You cannot change %1 because this account is part of one or more budgets.';
        GLSetup: Record "General Ledger Setup";
        CostAccSetup: Record "Cost Accounting Setup";
        DimMgt: Codeunit DimensionManagement;
        CostAccMgt: Codeunit "Cost Account Mgt";
        GLSetupRead: Boolean;
        Text002: label 'There is another %1: %2; which refers to the same %3, but with a different %4: %5.';
        NoAccountCategoryMatchErr: label 'There is no subcategory description for %1 that matches ''%2''.', Comment = '%1=account category value, %2=the user input.';
        GLEntry: Record "G/L Entry";
        Usersetup: Record "User Setup";
}