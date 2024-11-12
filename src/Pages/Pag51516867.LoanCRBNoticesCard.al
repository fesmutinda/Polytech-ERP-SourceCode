#pragma warning disable AA0005, AA0008, AA0018, AA0021, AA0072, AA0137, AA0201, AA0204, AA0206, AA0218, AA0228, AL0254, AL0424, AS0011, AW0006 // ForNAV settings
Page 51516867 "Loan CRB Notices Card"
{
    PageType = Card;
    SourceTable = 51516926;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Document No"; "Document No")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Member No"; "Member No")
                {
                    ApplicationArea = Basic;
                }
                field("Member Name"; "Member Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan In Default"; "Loan In Default")
                {
                    ApplicationArea = Basic;
                }
                field("Loan Product Name"; "Loan Product Name")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan Instalments"; "Loan Instalments")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan Disbursement Date"; "Loan Disbursement Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Expected Completion Date"; "Expected Completion Date")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Amount In Arrears"; "Amount In Arrears")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Loan Outstanding Balance"; "Loan Outstanding Balance")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Outstanding Interest"; "Outstanding Interest")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Notice Type"; "Notice Type")
                {
                    ApplicationArea = Basic;

                    trigger OnValidate()
                    begin
                        FNenableVisbility();
                    end;
                }
                group("Auctioneer Details")
                {
                    Visible = VarAuctioneerDetailsVisible;
                    field("Auctioneer No"; "Auctioneer No")
                    {
                        ApplicationArea = Basic;
                    }
                    field("Auctioneer  Name"; "Auctioneer  Name")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                    field("Auctioneer Address"; "Auctioneer Address")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                    field("Auctioneer Mobile No"; "Auctioneer Mobile No")
                    {
                        ApplicationArea = Basic;
                        Editable = false;
                    }
                }
                field("Demand Notice Date"; "Demand Notice Date")
                {
                    ApplicationArea = Basic;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = Basic;
                    Editable = false;
                }
                field("Email Sent"; "Email Sent")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
                field("SMS Sent"; "SMS Sent")
                {
                    ApplicationArea = Basic;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            group("Demand Letters")
            {
                action("1st Notice Letter")
                {
                    ApplicationArea = Basic;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = "Report";
                    Visible = false;

                    trigger OnAction()
                    begin
                        ObjDemands.Reset;
                        ObjDemands.SetRange(ObjDemands."Loan In Default", "Loan In Default");
                        ObjDemands.SetFilter(ObjDemands."Document No", '<>%1', "Document No");
                        if ObjDemands.Find('-') = false then begin
                            "Notice Type" := "notice type"::"1st Demand Notice";
                            "Demand Notice Date" := Today;
                            ObjLoans.Reset;
                            ObjLoans.SetRange(ObjLoans."Loan  No.", "Loan In Default");
                            if ObjLoans.FindSet then begin
                                Report.Run(51516925, true, true, ObjLoans);
                            end;
                        end;

                        //  ObjDemands.RESET;
                        //  ObjDemands.SETRANGE(ObjDemands."Loan In Default","Loan In Default");
                        //  IF ObjDemands.FINDSET THEN BEGIN
                        //    IF ObjDemands.COUNT>1 THEN BEGIN
                        //    "Notice Type":="Notice Type"::"2nd Demand Notice";
                        //    "Demand Notice Date":=TODAY;
                        //        ObjLoans.RESET;
                        //        ObjLoans.SETRANGE(ObjLoans."Loan  No.","Loan In Default");
                        //        IF ObjLoans.FINDSET THEN BEGIN
                        //          REPORT.RUN(51516915,TRUE,TRUE,ObjLoans);
                        //          END;
                        //         END;
                        //      END;

                    end;
                }
                action("2nd Notice Letter")
                {
                    ApplicationArea = Basic;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = "Report";
                    Visible = false;

                    trigger OnAction()
                    begin
                        ObjDemands.Reset;
                        ObjDemands.SetRange(ObjDemands."Loan In Default", "Loan In Default");
                        ObjDemands.SetFilter(ObjDemands."Document No", '<>%1', "Document No");
                        if ObjDemands.Find('-') = false then begin
                            "Notice Type" := "notice type"::"2nd Demand Notice";
                            "Demand Notice Date" := Today;
                            ObjLoans.Reset;
                            ObjLoans.SetRange(ObjLoans."Loan  No.", "Loan In Default");
                            if ObjLoans.FindSet then begin
                                Report.Run(51516915, true, true, ObjLoans);
                            end;
                        end;
                        // //
                        // //  ObjDemands.RESET;
                        // //  ObjDemands.SETRANGE(ObjDemands."Loan In Default","Loan In Default");
                        // //  IF ObjDemands.FINDSET THEN BEGIN
                        // //    //IF ObjDemands.COUNT>1 THEN BEGIN
                        // //    "Notice Type":="Notice Type"::"2nd Demand Notice";
                        // //    "Demand Notice Date":=TODAY;
                        // //        ObjLoans.RESET;
                        // //        ObjLoans.SETRANGE(ObjLoans."Loan  No.","Loan In Default");
                        // //        IF ObjLoans.FINDSET THEN BEGIN
                        // //          REPORT.RUN(51516915,TRUE,TRUE,ObjLoans);
                        // //          END;
                        // //        // END;
                        // //      END;

                    end;
                }
                action("CRB Demand Letter")
                {
                    ApplicationArea = Basic;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = "Report";
                    Visible = true;

                    trigger OnAction()
                    begin
                        ObjDemands.Reset;
                        ObjDemands.SetRange(ObjDemands."Document No", "Document No");
                        if ObjDemands.FindSet then begin
                            "Notice Type" := "notice type"::"CRB Notice";
                            "Demand Notice Date" := Today;
                        end;

                        ObjLoans.Reset;
                        ObjLoans.SetRange(ObjLoans."Loan  No.", "Loan In Default");
                        if ObjLoans.FindSet then begin
                            Report.Run(51516926, true, true, ObjLoans);
                        end;
                    end;
                }
                action("3rd Notice Letter")
                {
                    ApplicationArea = Basic;
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = "Report";
                    Visible = false;

                    trigger OnAction()
                    begin
                        ObjDemands.Reset;
                        ObjDemands.SetRange(ObjDemands."Document No", "Document No");
                        if ObjDemands.FindSet then begin
                            "Notice Type" := "notice type"::"3rd Notice";
                            "Demand Notice Date" := Today;
                        end;

                        ObjLoans.Reset;
                        ObjLoans.SetRange(ObjLoans."Loan  No.", "Loan In Default");
                        if ObjLoans.FindSet then begin
                            Report.Run(51516916, true, true, ObjLoans);
                        end;
                    end;
                }
            }
            group(Approvals)
            {
                Caption = 'Approvals';
                action(Approval)
                {
                    ApplicationArea = Basic;
                    Caption = 'Approvals';
                    Image = Approval;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ApprovalEntries: Page "Approval Entries";
                    begin
                        /*
                        DocumentType:=DocumentType::PackageLodging;
                        ApprovalEntries.Setfilters(DATABASE::"Safe Custody Package Register",DocumentType,"Package ID");
                        ApprovalEntries.RUN;
                        */

                    end;
                }
                action("Send Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Send A&pproval Request';
                    Enabled = (not OpenApprovalEntriesExist) and EnabledApprovalWorkflowsExist;
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Text001: label 'This transaction is already pending approval';
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        /*//Check Item and Agent Attachment
                        ObjAgents.RESET;
                        ObjAgents.SETRANGE(ObjAgents."Package ID","Package ID");
                        ObjAgents.SETFILTER(ObjAgents."Agent Name",'<>%1','');
                        IF ObjAgents.FINDSET=FALSE THEN BEGIN
                          ERROR('You have to specify atleast 1 package agent');
                          END;
                        
                        ObjItems.RESET;
                        ObjItems.SETRANGE(ObjItems."Package ID","Package ID");
                        ObjItems.SETFILTER(ObjItems."Item Description",'<>%1','');
                        IF ObjItems.FINDSET=FALSE THEN BEGIN
                          ERROR('You have to specify atleast 1 package item');
                          END;
                        
                        IF ApprovalsMgmt.CheckPackageLodgeApprovalsWorkflowEnabled(Rec) THEN
                          ApprovalsMgmt.OnSendPackageLodgeForApproval(Rec)
                        
                          */

                    end;
                }
                action("Cancel Approval Request")
                {
                    ApplicationArea = Basic;
                    Caption = 'Cancel Approval Request';
                    Enabled = CanCancelApprovalForRecord;
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        /*IF ApprovalsMgmt.CheckPackageLodgeApprovalsWorkflowEnabled(Rec) THEN
                          ApprovalsMgmt.OnCancelPackageLodgeApprovalRequest(Rec);*/


                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        /*
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RECORDID);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RECORDID);
        EnabledApprovalWorkflowsExist :=TRUE;
        IF Rec.Status=Status::Approved THEN BEGIN
          OpenApprovalEntriesExist:=FALSE;
          CanCancelApprovalForRecord:=FALSE;
          EnabledApprovalWorkflowsExist:=FALSE;
          END;
          */

    end;

    trigger OnAfterGetRecord()
    begin
        FNenableVisbility();
        FNenableEditing();
    end;

    trigger OnOpenPage()
    begin
        FNenableVisbility();
        FNenableEditing();
    end;

    var
        DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"," ","Purchase Requisition",RFQ,"Store Requisition","Payment Voucher",MembershipApplication,LoanApplication,LoanDisbursement,ProductApplication,StandingOrder,MembershipWithdrawal,ATMCard,GuarantorRecovery,ChangeRequest,TreasuryTransactions,FundsTransfer,SaccoTransfers,ChequeDiscounting,ImprestRequisition,ImprestSurrender,LeaveApplication,BulkWithdrawal,PackageLodging,PackageRetrieval;
        OpenApprovalEntriesExist: Boolean;
        EnabledApprovalWorkflowsExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        SwizzsoftFactory: Codeunit UnknownCodeunit51516007;
        JTemplate: Code[20];
        JBatch: Code[20];
        GenSetup: Record 51516398;
        DocNo: Code[20];
        LineNo: Integer;
        TransType: Option " ","Registration Fee","Share Capital","Interest Paid","Loan Repayment","Deposit Contribution","Insurance Contribution","Benevolent Fund",Loan,"Unallocated Funds",Dividend,"FOSA Account","Loan Insurance Charged","Loan Insurance Paid","Recovery Account","FOSA Shares","Additional Shares";
        AccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner",Employee,Member,Investor;
        BalAccountType: Option "G/L Account",Customer,Vendor,"Bank Account","Fixed Asset","IC Partner",Employee;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ObjVendors: Record Vendor;
        ObjAccTypes: Record 51516436;
        AvailableBal: Decimal;
        ObjLoans: Record 51516371;
        ObjDemands: Record 51516926;
        VarAuctioneerDetailsVisible: Boolean;

    local procedure FNenableVisbility()
    begin
        VarAuctioneerDetailsVisible := false;

        if "Notice Type" = "notice type"::"3rd Notice" then begin
            VarAuctioneerDetailsVisible := true;
        end
    end;

    local procedure FNenableEditing()
    begin
    end;
}

