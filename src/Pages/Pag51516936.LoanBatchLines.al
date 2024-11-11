#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516936 "Loan Batch Lines"
{
    PageType = ListPart;
    SourceTable = 51516645;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Batch No."; "Batch No.")
                {
                    ApplicationArea = Basic;
                }
                field("Mode Of Disbursement"; "Mode Of Disbursement")
                {
                    ApplicationArea = Basic;
                }
                field("Bank Account"; "Bank Account")
                {
                    ApplicationArea = Basic;
                }
                field("Cheque No."; "Cheque No.")
                {
                    ApplicationArea = Basic;
                }
                field("Amount to Disburse"; "Amount to Disburse")
                {
                    ApplicationArea = Basic;
                }
                field("EFT Fees"; "EFT Fees")
                {
                    ApplicationArea = Basic;
                }
                field(Unallocated; Unallocated)
                {
                    ApplicationArea = Basic;
                }
                field("Available Amount"; "Available Amount")
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

