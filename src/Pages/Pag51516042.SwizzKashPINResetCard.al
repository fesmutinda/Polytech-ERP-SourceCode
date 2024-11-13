#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516042 "SwizzKash PIN Reset Card"
{
    Editable = true;
    PageType = Card;
    SourceTable = "SwizzKash Applications";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Account No"; Rec."Account No")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Account Name"; Rec."Account Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Telephone; Rec.Telephone)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("ID No"; Rec."ID No")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Date Applied"; Rec."Date Applied")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Time Applied"; Rec."Time Applied")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Last PIN Reset"; Rec."Last PIN Reset")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Reset By"; Rec."Reset By")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field(SentToServer; Rec.SentToServer)
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Reset Pin")
            {
                ApplicationArea = Basic;
                Image = Answers;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'F5';

                trigger OnAction()
                begin
                    if Rec.SentToServer = false then begin
                        Error('Pin reset has already been Requested');
                    end else begin

                        Rec."Last PIN Reset" := Today;
                        Rec."Reset By" := UserId;
                        Rec.SentToServer := false;
                        Rec."PIN Requested" := true;

                        pinResetLogs.Reset;
                        pinResetLogs.Init;
                        pinResetLogs."Account Name" := Rec."Account Name";
                        pinResetLogs.No := Rec."No.";
                        pinResetLogs."ID No" := Rec."ID No";
                        pinResetLogs."Account No" := Rec."Account No";
                        pinResetLogs.Telephone := Rec.Telephone;
                        pinResetLogs.Date := CurrentDatetime;
                        pinResetLogs."Last PIN Reset" := CurrentDatetime;
                        pinResetLogs."Reset By" := UserId;

                        if pinResetLogs.Insert = true then
                            Message('Pin reset has been successfully been sent');

                    end;
                end;
            }
            action("PIN Reset Entries")
            {
                ApplicationArea = Basic;
                Image = CampaignEntries;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "SwizzKash PIN Reset Logs";
                RunPageLink = No = field("No.");
                RunPageOnRec = false;
                RunPageView = sorting(No)
                              order(descending);
            }
        }
    }

    trigger OnOpenPage()
    begin
        //ERROR('under maintenance');
    end;

    var
        SwizzKashapp: Record "SwizzKash Applications";
        pinResetLogs: Record "SwizzKash Pin Reset Logs";
}

