codeunit 59024 "Activity Logger"
{
    // Caption = 'Activity Logger';
    SingleInstance = true;

    procedure LogActivity(Action: Text[100]; TableID: Integer; DocNo: Code[30]; Amount: Decimal; DescriptionTxt: Text[250])
    var
        Activity: Record "User Activity Log";
    begin
        Activity.Init();
        Activity."User ID" := UserId();
        Activity."Activity Date" := Today();
        Activity."Activity Time" := Time();
        Activity."Activity Type" := Action;
        Activity."Table ID" := TableID;
        Activity."Document No." := DocNo;
        Activity.Amount := Amount;
        Activity.Description := DescriptionTxt;
        Activity.Insert();
    end;
}
