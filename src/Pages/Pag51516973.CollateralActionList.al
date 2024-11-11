#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516973 "Collateral Action List"
{
    CardPageID = "Collateral Action Card";
    PageType = List;
    SourceTable = 51516512;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document No"; "Document No")
                {
                    ApplicationArea = Basic;
                }
                field("Registered Owner"; "Registered Owner")
                {
                    ApplicationArea = Basic;
                }
                field("Member No."; "Member No.")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                }
                field("Collateral Type"; "Collateral Type")
                {
                    ApplicationArea = Basic;
                }
                field("Asset Value"; "Asset Value")
                {
                    ApplicationArea = Basic;
                }
                field("Depreciation Completion Date"; "Depreciation Completion Date")
                {
                    ApplicationArea = Basic;
                }
                field("Asset Depreciation Amount"; "Asset Depreciation Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Asset Value @Loan Completion"; "Asset Value @Loan Completion")
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

