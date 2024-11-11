#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516944 "SCustody Package Register List"
{
    CardPageID = "SCustody Package Card";
    Editable = false;
    PageType = List;
    SourceTable = 51516904;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Package ID"; "Package ID")
                {
                    ApplicationArea = Basic;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Package Type"; "Package Type")
                {
                    ApplicationArea = Basic;
                }
                field("Package Description"; "Package Description")
                {
                    ApplicationArea = Basic;
                }
                field("Custody Period"; "Custody Period")
                {
                    ApplicationArea = Basic;
                }
                field("Charge Account"; "Charge Account")
                {
                    ApplicationArea = Basic;
                }
                field("Maturity Instruction"; "Maturity Instruction")
                {
                    ApplicationArea = Basic;
                }
                field("File Serial No"; "File Serial No")
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

