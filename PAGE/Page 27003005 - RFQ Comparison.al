page 27003005 "RFQ Comparison"
{
    PageType = Document;
    SourceTable = "RFQ Comparison";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("RFQ Status"; "RFQ Status")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("PR No"; "PR No")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Requester; Requester)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("RFQ Total Amount"; "RFQ Total Amount")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            part(Control1000000008; "RFQ Compare Subform")
            {
                ApplicationArea = all;
                SubPageLink = "Document Type" = CONST(Quote),
                              "RFQ No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group(ActionGroup1000000009)
            {
                Caption = 'Function';
                action("Convert To PO")
                {
                    ApplicationArea = all;
                    Caption = 'Convert To PO';
                    Image = "Order";
                    Promoted = true;
                    PromotedCategory = Process;
                    trigger OnAction();
                    begin
                        // 19.0.0.4>>
                        if PPSetup.GET then begin
                            if Status = Status::Open then begin
                                if PPSetup."PR/RFQ LOA Approval" then begin
                                    LTanj.SendApprovalRequestRFQ(Rec)
                                end else
                                    LTanj.MakeOrder(Rec)
                            end else
                                ERROR('To Convert to PO, Status should be Open');
                        end;
                        /* if PPSetup.GET then begin
                            if Status = Status::Open then
                                LTanj.MakeOrder(Rec)
                            else
                                ERROR('To Convert to PO, Status should be Open');
                        end; */
                        // 19.0.0.4<<
                    end;
                }
                action("Cancel Approval")
                {
                    ApplicationArea = all;
                    Caption = 'Cancel Approval';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    Visible = false;
                    trigger OnAction();
                    begin
                        DocApproval.CancelRFQApproval(Rec);
                    end;
                }
                action("Print RFQ")
                {
                    ApplicationArea = all;
                    Caption = 'Print RFQ';
                    Image = Print;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    PromotedIsBig = true;
                    trigger OnAction();
                    begin
                        PRHeader.Reset();
                        PRHeader.SetRange("No.", Rec."PR No");
                        REPORT.RUNMODAL(Report::"Request For Quotation", true, false, PRHeader);
                    end;
                }
                action("Approval &Entries")
                {
                    ApplicationArea = all;
                    Caption = 'Approval &Entries';
                    Image = Approvals;
                    Promoted = true;
                    PromotedCategory = Process;
                    Visible = false;
                    trigger OnAction();
                    begin
                        AppEntryRec.RESET;
                        // ApprovalEntries.Setfilters(DATABASE::"RFQ Comparison", AppEntryRec."PR Document Type"::RFQC, "No.");//Version 19.0.0.0>>//19.0.0.7
                        ApprovalEntries.SetRecordFilters(DATABASE::"RFQ Comparison", AppEntryRec."PR Document Type"::RFQC, "No.");//Version 19.0.0.0>>//19.0.0.7
                        ApprovalEntries.RUN;
                    end;
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        CalcFields("RFQ Total Amount", "RFQ Total Amount (LCY)");
    end;

    var
        LTanj: Codeunit "PR Functions-IBIZRFQ";
        PPSetup: Record "Purchases & Payables Setup";
        DocApproval: Codeunit "Document Approval PR-IBIZPR";
        AppEntryRec: Record "Approval Entry";
        ApprovalEntries: Page "Approval Entries";
        PRHeader: Record "PR Header";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
}

