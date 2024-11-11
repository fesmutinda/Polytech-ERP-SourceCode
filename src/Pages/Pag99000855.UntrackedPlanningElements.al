#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000855 "Untracked Planning Elements"
{
    Caption = 'Untracked Planning Elements';
    DataCaptionExpression = CaptionText;
    Editable = false;
    PageType = List;
    SourceTable = "Untracked Planning Element";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No.";"Item No.")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the number of the item in the requisition line for which untracked planning surplus exists.';
                    Visible = false;
                }
                field("Variant Code";"Variant Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Location Code";"Location Code")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the location code in the requisition line associated with the untracked planning surplus.';
                    Visible = false;
                }
                field(Source;Source)
                {
                    ApplicationArea = Advanced;
                    StyleExpr = SourceEmphasize;
                    ToolTip = 'Specifies what the source of this untracked surplus quantity is.';
                }
                field("Source ID";"Source ID")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the identification code for the source of the untracked planning quantity.';
                    Visible = false;
                }
                field("Parameter Value";"Parameter Value")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies the value of this planning parameter.';
                }
                field("Track Quantity From";"Track Quantity From")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies how much the total surplus quantity is, including the quantity from this entry.';
                    Visible = false;
                }
                field("Untracked Quantity";"Untracked Quantity")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies how much this planning parameter contributed to the total surplus quantity.';
                }
                field("Track Quantity To";"Track Quantity To")
                {
                    ApplicationArea = Advanced;
                    ToolTip = 'Specifies what the surplus quantity would be without the quantity from this entry.';
                    Visible = false;
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

    trigger OnAfterGetRecord()
    begin
        FormatLine;
    end;

    var
        CaptionText: Text[80];
        [InDataSet]
        SourceEmphasize: Text;

    procedure SetCaption(NewCaption: Text[80])
    begin
        CaptionText := NewCaption;
    end;

    local procedure FormatLine()
    begin
        if "Warning Level" > 0 then
          SourceEmphasize := 'Strong'
        else
          SourceEmphasize := '';
    end;
}

