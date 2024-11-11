#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 99000882 "Change Status on Prod. Order"
{
    Caption = 'Change Status on Prod. Order';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    InstructionalText = 'Do you want to change the status of this production order?';
    ModifyAllowed = false;
    PageType = ConfirmationDialog;

    layout
    {
        area(content)
        {
            field(FirmPlannedStatus;ProdOrderStatus.Status)
            {
                ApplicationArea = Manufacturing;
                Caption = 'New Status';
                ValuesAllowed = "Firm Planned",Released,Finished;

                trigger OnValidate()
                begin
                    case ProdOrderStatus.Status of
                      ProdOrderStatus.Status::Finished:
                        CheckStatus(FinishedStatusEditable);
                      ProdOrderStatus.Status::Released:
                        CheckStatus(ReleasedStatusEditable);
                      ProdOrderStatus.Status::"Firm Planned":
                        CheckStatus(FirmPlannedStatusEditable);
                    end;
                end;
            }
            field(PostingDate;PostingDate)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Posting Date';
            }
            field(ReqUpdUnitCost;ReqUpdUnitCost)
            {
                ApplicationArea = Manufacturing;
                Caption = 'Update Unit Cost';
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        FinishedStatusEditable := true;
        ReleasedStatusEditable := true;
        FirmPlannedStatusEditable := true;
    end;

    var
        ProdOrderStatus: Record "Production Order";
        PostingDate: Date;
        ReqUpdUnitCost: Boolean;
        [InDataSet]
        FirmPlannedStatusEditable: Boolean;
        [InDataSet]
        ReleasedStatusEditable: Boolean;
        [InDataSet]
        FinishedStatusEditable: Boolean;
        Text666: label '%1 is not a valid selection.';

    procedure Set(ProdOrder: Record "Production Order")
    begin
        if ProdOrder.Status = ProdOrder.Status::Finished then
          ProdOrder.FieldError(Status);
        FirmPlannedStatusEditable := ProdOrder.Status < ProdOrder.Status::"Firm Planned";
        ReleasedStatusEditable := ProdOrder.Status <> ProdOrder.Status::Released;
        FinishedStatusEditable := ProdOrder.Status = ProdOrder.Status::Released;

        if ProdOrder.Status > ProdOrder.Status::Simulated then
          ProdOrderStatus.Status := ProdOrder.Status + 1
        else
          ProdOrderStatus.Status := ProdOrderStatus.Status::"Firm Planned";

        PostingDate := WorkDate;
    end;

    procedure ReturnPostingInfo(var Status: Option Simulated,Planned,"Firm Planned",Released,Finished;var PostingDate2: Date;var UpdUnitCost: Boolean)
    begin
        Status := ProdOrderStatus.Status;
        PostingDate2 := PostingDate;
        UpdUnitCost := ReqUpdUnitCost;
    end;

    local procedure CheckStatus(StatusEditable: Boolean)
    begin
        if not StatusEditable then
          Error(Text666,ProdOrderStatus.Status);
    end;
}

