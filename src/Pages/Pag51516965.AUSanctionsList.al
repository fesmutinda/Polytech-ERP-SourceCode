#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516965 "AU Sanctions List"
{
    PageType = List;
    SourceTable = 51516917;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(UserId; UserId)
                {
                    ApplicationArea = Basic;
                }
                field(EmployerCode; EmployerCode)
                {
                    ApplicationArea = Basic;
                }
                field("Date of Birth"; "Date of Birth")
                {
                    ApplicationArea = Basic;
                }
                field("Palace Of Birth"; "Palace Of Birth")
                {
                    ApplicationArea = Basic;
                }
                field(Citizenship; Citizenship)
                {
                    ApplicationArea = Basic;
                }
                field("Listing Information"; "Listing Information")
                {
                    ApplicationArea = Basic;
                }
                field("Control Date"; "Control Date")
                {
                    ApplicationArea = Basic;
                }
                field("AU Sactions kenya"; "AU Sactions kenya")
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

