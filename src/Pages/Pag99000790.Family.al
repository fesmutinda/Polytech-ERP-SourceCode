#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000790 Family
{
    Caption = 'Family';
    PageType = ListPlus;
    SourceTable = Family;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No.";"No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the production family number.';
                }
                field(Description;Description)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a description for a product family.';
                }
                field("Description 2";"Description 2")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies an additional description of the product family if there is not enough space in the Description field.';
                }
                field("Search Name";"Search Name")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies a search name.';
                }
                field("Routing No.";"Routing No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the number of the routing which is used for the production of the family.';
                }
                field(Blocked;Blocked)
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies whether the family is blocked.';
                }
                field("Last Date Modified";"Last Date Modified")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies when the standard data of this production family was last modified.';
                }
            }
            part(Control13;"Family Lines")
            {
                ApplicationArea = Manufacturing;
                SubPageLink = "Family No."=field("No.");
                SubPageView = sorting("Family No.","Line No.");
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207;Links)
            {
                Visible = false;
            }
            systempart(Control1905767507;Notes)
            {
                Visible = false;
            }
        }
    }

    actions
    {
    }
}

