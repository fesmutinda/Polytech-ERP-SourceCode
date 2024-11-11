#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000958 "Order Promising Setup"
{
    Caption = 'Order Promising Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Order Promising Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Offset (Time)";"Offset (Time)")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the period of time to wait before issuing a new purchase order, production order, or transfer order.';
                }
                field("Order Promising Nos.";"Order Promising Nos.")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the code that identifies the number series that you select for order promising.';
                }
                field("Order Promising Template";"Order Promising Template")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the name of the requisition worksheet template that you select for order promising.';
                }
                field("Order Promising Worksheet";"Order Promising Worksheet")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the name of the requisition worksheet that you select for order promising.';
                }
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

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
          Init;
          Insert;
        end;
    end;
}

