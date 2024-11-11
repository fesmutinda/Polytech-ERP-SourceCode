#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516550 "Membership App Products"
{
    PageType = List;
    SourceTable = 51516509;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Product; Product)
                {
                    ApplicationArea = Basic;
                }
                field("Product Name"; "Product Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Product Source"; "Product Source")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }
}

