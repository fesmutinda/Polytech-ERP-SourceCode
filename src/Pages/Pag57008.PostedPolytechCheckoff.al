page 57008 "Posted Polytech Checkoff"
{
    DeleteAllowed = false;
    PageType = Card;
    SourceTable = "Polytech Checkoff Header";
    SourceTableView = where(Posted = const(true));
    Editable = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(No; Rec.No)
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Date Entered"; Rec."Date Entered")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Posting date"; Rec."Posting date")
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Loan CutOff Date"; Rec."Loan CutOff Date")
                {
                    ApplicationArea = Basic;
                }
                // field(Remarks; Rec.Remarks)
                // {
                //     ApplicationArea = Basic;
                // }
                field("Total Count"; Rec."Total Count")
                {
                    ApplicationArea = Basic;
                }
                // field("Account Type"; Rec."Account Type")
                // {
                //     ApplicationArea = Basic;
                // }
                field("Account No"; Rec."Account No")
                {
                    Caption = 'Bank Account';
                    ApplicationArea = Basic;
                }
                field("Employer Code"; Rec."Employer Code")
                {
                    Visible = false;
                    ApplicationArea = Basic;
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = Basic;
                }
                field(Posted; Rec.Posted)
                {
                    ApplicationArea = Basic;
                    Editable = true;
                }
                field("Total Welfare"; Rec."Total Welfare") { }
                field(Amount; Rec.Amount)
                {
                    Caption = 'Cheque Amount';
                    ApplicationArea = Basic;
                }
                field("Scheduled Amount"; Rec."Scheduled Amount")
                {
                    ApplicationArea = Basic;
                }
                field("Entered By"; Rec."Entered By")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                }
                field("Posted By"; Rec."Posted By")
                {
                    ApplicationArea = Basic;
                    Enabled = false;
                }
            }
            part("Bosa receipt lines"; "Polytech CheckoffLines")
            {
                SubPageLink = "Receipt Header No" = field(No);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Processed Checkoff")
            {
                Caption = 'UnMark as Posted';
                ApplicationArea = Basic;
                Image = POST;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if Confirm('Are you sure you want to un-mark this Checkoff as Posted', false) = true then begin
                        Rec.Posted := false;
                        Rec."Posted By" := '';
                        Rec.Modify;
                        CurrPage.close();
                    end;
                end;
            }
            action("Re Post Welfare")
            {
                ApplicationArea = Basic;
                Caption = 'Re Post Welfare';
                Image = Post;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    dialogBox: Dialog;
                begin
                    Jtemplate := 'GENERAL';
                    Jbatch := 'CHECKOFF';
                    // end;
                    //Delete journal
                    Gnljnline.Reset();
                    Gnljnline.SetRange("Journal Template Name", Jtemplate);
                    Gnljnline.SetRange("Journal Batch Name", Jbatch);
                    if Gnljnline.Find('-') then begin
                        Gnljnline.DeleteAll;
                    end;

                    RcptBufLines.Reset;
                    RcptBufLines.SetRange(RcptBufLines."Receipt Header No", Rec.No);
                    RcptBufLines.SetRange(RcptBufLines.Posted, false);
                    if RcptBufLines.Find('-') then begin
                        repeat
                            dialogBox.Open('Processing Check Off for ' + Format(RcptBufLines."Member No") + ': ' + RcptBufLines.Name + '...');
                            LineN := LineN + 10000;

                            //Process Welfare.... Festus
                            //################KINDLY NOTE - WELFARE BALANCES ITSELF----
                            if RcptBufLines."Welfare Contribution" > 0 then begin
                                welfareProcessing.fnPostWelfare(RcptBufLines."Member No",
                                                                Jtemplate, Jbatch,
                                                                LineN,
                                                                Rec."Document No",
                                                                Rec."Posting date",
                                                                320,
                                                                Rec."Account Type",
                                                                Rec."Account No"
                                                            );

                                LineN := LineN + 40000;
                            end;
                            dialogBox.Close();

                        until RcptBufLines.Next = 0;
                    end;

                    // Reinitialize the record and open the journal page
                    Gnljnline.Reset();
                    Gnljnline.SetRange("Journal Template Name", Jtemplate);
                    Gnljnline.SetRange("Journal Batch Name", Jbatch);
                    if Gnljnline.Find('-') then begin
                        Page.Run(page::"General Journal", Gnljnline);
                        Message('CheckOff Successfully Generated');
                    end;

                end;
            }
        }
    }

    var
        myInt: Integer;
        Gnljnline: Record "Gen. Journal Line";
        Jbatch: Code[30];
        welfareProcessing: Codeunit WelfareProcessing;
        Jtemplate: Code[30];
        RcptBufLines: Record "Polytech CheckoffLines";
        LineN: Integer;
}