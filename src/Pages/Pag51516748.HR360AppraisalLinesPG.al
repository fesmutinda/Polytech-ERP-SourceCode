#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516748 "HR 360 Appraisal Lines - PG"
{
    Caption = 'HR Appraisal Lines - Personal Goals/Objectives';
    PageType = ListPart;
    SourceTable = 51516217;
    SourceTableView = where("Categorize As" = const("Personal Goals/Objectives"));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sub Category"; "Sub Category")
                {
                    ApplicationArea = Basic;
                }
                field("Perfomance Goals and Targets"; "Perfomance Goals and Targets")
                {
                    ApplicationArea = Basic;
                }
                field("Min. Target Score"; "Min. Target Score")
                {
                    ApplicationArea = Basic;
                }
                field("Max Target Score"; "Max Target Score")
                {
                    ApplicationArea = Basic;
                }
                field("Self Rating"; "Self Rating")
                {
                    ApplicationArea = Basic;
                }
                field("Employee Comments"; "Employee Comments")
                {
                    ApplicationArea = Basic;
                }
                field("Supervisor Rating"; "Supervisor Rating")
                {
                    ApplicationArea = Basic;
                }
                field("Supervisor Comments"; "Supervisor Comments")
                {
                    ApplicationArea = Basic;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        "Categorize As" := "categorize as"::"Personal Goals/Objectives";
        "Sub Category" := "sub category"::"Personal Goals";
    end;
}

