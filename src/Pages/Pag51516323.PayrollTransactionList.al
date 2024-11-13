#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516323 "Payroll Transaction List."
{
    CardPageID = "payroll Transaction Code.";
    PageType = List;
    SourceTable = "Payroll Transaction Code.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Transaction Code"; Rec."Transaction Code")
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Name"; Rec."Transaction Name")
                {
                    ApplicationArea = Basic;
                }
                field("Is Formulae"; Rec."Is Formulae")
                {
                    ApplicationArea = Basic;
                }
                field(Formulae; Rec.Formulae)
                {
                    ApplicationArea = Basic;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = Basic;
                }
                field("G/L Account"; Rec."G/L Account")
                {
                    ApplicationArea = Basic;
                }
                field("G/L Account Name"; Rec."G/L Account Name")
                {
                    ApplicationArea = Basic;
                }
                field("IsCo-Op/LnRep"; Rec."IsCo-Op/LnRep")
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

