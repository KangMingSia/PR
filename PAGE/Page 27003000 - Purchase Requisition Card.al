page 27003000 "Purchase Requisition Card"
{
    CardPageID = "Purchase Requisition Card";
    DeleteAllowed = false;
    PageType = Document;
    SourceTable = "PR Header";
    PromotedActionCategories = 'New,Process,Report,Approve,Release,Convert,Functions,Order,Request Approval,Print/Send,Navigate';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {

                    trigger OnAssistEdit();
                    begin
                        if AssistEdit(xRec) then
                            CurrPage.UPDATE;
                    end;
                }
                field("Suggested Vendor"; "Suggested Vendor")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = all;
                }
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = all;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                }
                field("PR Total Amount"; "PR Total Amount")
                {
                    ApplicationArea = all;
                }
                field("No. of Archived Versions"; "No. of Archived Versions")
                {
                    ApplicationArea = all;
                }
                field(Requester; Requester)
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                }
                field("PR Document Type"; "PR Document Type")
                {
                    ApplicationArea = all;
                    ShowMandatory = true;
                    trigger OnValidate()
                    var
                        PRLS: Page "PR Line subform";
                        PRC: Page "Purchase Requisition Card";
                    begin
                        PRC.SetRecord(Rec);
                        PRLS.CheckACVisibility();
                        PRLS.Update(true);
                        CurrPage.Update(true);
                        // CurrPage.Close();
                        // CurrPage.SaveRecord();
                        // PRC.Run();
                    end;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("PR Status"; "PR Status")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("LOA Status"; "LOA Status")
                {
                    ApplicationArea = all;
                }
            }
            group(Miscellanous)
            {
                field("Co-ordinator"; "Co-ordinator")
                {
                    ApplicationArea = all;
                }
                field("Released By"; "Released By")
                {
                    ApplicationArea = all;
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = all;
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("PR Date"; "PR Date")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;

                    trigger OnValidate();
                    begin
                        ShortcutDimension1CodeOnAfterV;
                    end;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = all;
                }
                field("No. series"; "No. series")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
            part("PR Line subform"; "PR Line subform")
            {
                ApplicationArea = all;
                SubPageLink = "Document No." = FIELD("No.");
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
        {
            part(Control1901138007; "Check Budget")
            {
                ApplicationArea = All;
                SubPageLink = "PR No." = FIELD("No.");
            }
            systempart(Control8; Notes)
            {
                ApplicationArea = all;
            }
            systempart(Control12; Links)
            {
                ApplicationArea = all;
            }
            part(WorkflowStatus; "Workflow Status FactBox")
            {
                ApplicationArea = all;
                Editable = false;
                Enabled = false;
                ShowFilter = false;
                Visible = ShowWorkflowStatus;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Dimensions)
            {
                Image = Dimensions;
                ShortCutKey = 'Shift+Ctrl+D';
                ApplicationArea = all;
                trigger OnAction();
                begin
                    ShowDocDim;
                    UpdatehortcutDimension("Dimension Set ID");//19.0.0.7
                    CurrPage.SAVERECORD;
                end;
            }
            action("Suggest Vendor")
            {
                ApplicationArea = all;
                Caption = 'Suggest Document Vendor';
                Image = Vendor;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "Suggested vendor";
                RunPageLink = "Document Type" = FILTER("PR Header"),
                              "PR No." = FIELD("No."),
                              "PR Line No." = CONST(0);
            }
            action("Copy Document")
            {
                Image = CopyDocument;
                ApplicationArea = all;
                PromotedCategory = Category7;
                PromotedOnly = true;
                Promoted = true;
                trigger OnAction();
                begin
                    CopyPRDoc.ToUpdatePR("No.");
                    CopyPRDoc.RUN;
                end;
            }
            action("Import Items")
            {
                ApplicationArea = all;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                visible = false;
                trigger OnAction();
                begin
                    GetItems.SetPRHeader(Rec);
                    GetItems.RUNMODAL;
                    CLEAR(GetItems);
                end;
            }
            action("Convert to PO")
            {
                Image = "Order";
                Promoted = true;
                PromotedCategory = Category6;
                ApplicationArea = all;
                PromotedOnly = true;
                trigger OnAction();
                begin
                    if PPSetup.GET then
                        if PPSetup."PR/RFQ LOA Approval" then begin
                            ConverttoPO.WFSendApprovalRequestLOA(Rec);
                            if IBIZApprovalsMgmt.CheckPRLOAApprovalsWorkflowEnabled(Rec) then begin
                                IBIZApprovalsMgmt.OnSendPRLOADocForApproval(Rec);
                            end;
                        end else
                            ConverttoPO.ConvertToOrder(Rec);
                end;
            }
            action("Convert to Quote")
            {
                Image = Quote;
                Promoted = true;
                PromotedCategory = Category6;
                PromotedOnly = true;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    ConverttoPO.ConvertToQuote(Rec);
                end;
            }

            action("Quote for Added Vendor")
            {
                Image = Quote;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    ConverttoPO.ConvertToQuoteFrPurchaserEntry(Rec);
                end;
            }
            separator(Separator5)
            {
            }
            action("RFQ Comparison")
            {
                ApplicationArea = all;
                Image = Quote;
                RunObject = Page "RFQ Comparison";
                RunPageLink = "PR No" = FIELD("No.");
            }
            action("Approval Entries")
            {
                Image = Approvals;
                ApplicationArea = all;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedOnly = true;

                trigger OnAction();
                begin
                    AppEntryRec.RESET;
                    //ApprovalEntries.Setfilters(DATABASE::"PR Header", AppEntryRec."PR Document Type"::PR, "No.");//Version 19.0.0.0>>//19.0.0.7
                    ApprovalEntries.SetRecordFilters(DATABASE::"PR Header", AppEntryRec."PR Document Type"::PR, "No.");//Version 19.0.0.0>>//19.0.0.7
                    ApprovalEntries.RUN;
                end;
            }
            action("Show Archived Documents")
            {
                ApplicationArea = all;
                Image = Archive;
                PromotedCategory = Category7;
                Promoted = true;
                PromotedOnly = true;
                RunObject = Page "PR Arch. List";
                RunPageLink = "PR No." = FIELD("No.");
            }
            separator(Separator6)
            {
            }
            action("Print PR")
            {
                Image = PrintAcknowledgement;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    PRHeader.RESET;
                    PRHeader.SETRANGE("No.", "No.");
                    REPORT.RUNMODAL(Report::"PR Report", true, false, PRHeader);
                end;
            }
            action("Print RFQ")
            {
                Caption = 'Print RFQ';
                Image = Print;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    PRHeader.RESET;
                    PRHeader.SETRANGE("No.", "No.");
                    REPORT.RUNMODAL(Report::"Request For Quotation", true, false, PRHeader);
                end;
            }
            group(Action13)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                action(Release)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&lease';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Ctrl+F9';
                    trigger OnAction();
                    begin
                        if IBIZApprovalsMgmt.IsPRApprovalsWorkflowEnabled(Rec) and (Rec.Status = Rec.Status::Open) then
                            ERROR(Text002)
                        else
                            ConverttoPO.ReleasePRDocument(Rec);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = Suite;
                    Caption = 'Re&open';
                    Enabled = Status <> Status::Open;
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    trigger OnAction();
                    begin
                        ConverttoPO.ReopenPRDocument(Rec);
                    end;
                }
            }
            group(Functions)
            {
                Caption = 'Functions';

                action(Cancel)
                {
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        ConverttoPO.CancelPRDocument(Rec);
                    end;
                }
                action("Archi&ve Document")
                {
                    Image = Archive;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    ApplicationArea = all;
                    PromotedOnly = true;

                    trigger OnAction();
                    begin
                        ConverttoPO.ArchivePR(Rec);
                    end;
                }
                action("Send For Approval")
                {
                    Image = Approval;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        CheckPRLineDimensionsBeforeApproval();
                        CheckPRBudgetBeforeApproval();
                        if IBIZApprovalsMgmt.CheckPRApprovalsWorkflowEnabled(Rec) then
                            IBIZApprovalsMgmt.OnSendPRDocForApproval(Rec);
                    end;
                }
                action("Cancel Approval Request")
                {
                    Image = Cancel;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;

                    trigger OnAction();
                    begin
                        DocApproval.CancelPurchaseApprovalRequest(Rec);
                    end;
                }
                action("Get STD Code")
                {
                    Caption = 'Get St&d. Vend. Purchase Codes';
                    Ellipsis = true;
                    Image = VendorCode;
                    ApplicationArea = all;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction();
                    var
                        StdVendPurchCode: Record "Standard Vendor Purchase Code";
                    begin
                        StdVendPurchCode.InsertPurchLinesPR(Rec);
                    end;
                }
                action("Refresh Budget")
                {
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Category7;
                    PromotedIsBig = true;
                    ApplicationArea = all;
                    PromotedOnly = true;
                    trigger OnAction();
                    begin
                        // if Status = Status::Open then begin
                        //     PRLine.RESET;
                        //     PRLine.SETRANGE(PRLine."Document No.", "No.");
                        //     PRLine.SETRANGE(Type, PRLine.Type::"G/L Account");//19.0.0.3>>
                        //     if PRLine.FINDFIRST then
                        //         repeat
                        //             PRLine.CheckBudget(Rec."No.");
                        //             PRLine.MODIFY;
                        //         until PRLine.NEXT = 0;
                        // end;
                        // if Rec.Status = Rec.Status::Open then begin
                        PRLine.CheckBudget(Rec."No.");
                        //end;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord();
    begin
        ShowWorkflowStatus := CurrPage.WorkflowStatus.PAGE.SetFilterOnWorkflowRecord(RECORDID);
         PRLine.CheckBudget(Rec."No.");
    end;

    trigger OnOpenPage();
    var
        UserLocationFilter: Text[1024];
        UserLocationFilter1: Text[1024];
        UserLocationFilter2: Text[1024];
        UserBranchFilter: Text[1024];
        WhseEmployee: Record "Warehouse Employee";
        ObjectID: Integer;
    begin

    end;

    var
        ChangeExchangeRate: Page "Change Exchange Rate";
        ConverttoPO: Codeunit "PR Functions-IBIZPR";
        DocApproval: Codeunit "Document Approval PR-IBIZPR";
        ApprovalEntries: Page "Approval Entries";
        AppEntryRec: Record "Approval Entry";
        LinkExist: Boolean;
        RecordLinkExist: Record "Record Link";
        CurrentRecordID: Text[100];
        PPSetup: Record "Purchases & Payables Setup";
        PRHeader: Record "PR Header";
        PRLine: Record "PR Line";
        PRSubForm: Page "PR Line subform";
        Dimensionvalue: Record "Dimension Value";
        UserSetup: Record "User Setup";
        CopyPRDoc: Report "Copy PR Doucment";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        IBIZApprovalsMgmt: Codeunit "IBIZ-Approvals Mgmt-IBIZPR";
        ShowWorkflowStatus: Boolean;
        Text001: Label 'There is nothing to release for the document of type %1 with the number %2.';
        Text002: Label 'This document can only be released when the approval process is complete.';
        Text003: Label 'The approval process must be cancelled or completed to reopen this document.';
        Text004: Label 'Dimensions are required before sending for approval. Please fill Shortcut Dimension 1 and Shortcut Dimension 2 on PR %1, line %2.';
        Text005: Label 'Amount exceeds the available budget for %1 : %2, Line No:%3';
        GetItems: Report "PR Excel Import";

    local procedure ShortcutDimension1CodeOnAfterV();
    begin
        CurrPage.UPDATE;
    end;

    local procedure ShortcutDimension2CodeOnAfterV();
    begin
        CurrPage.UPDATE;
    end;

    local procedure CheckPRLineDimensionsBeforeApproval();
    var
        PRLineToCheck: Record "PR Line";
        LocalPPSetup: Record "Purchases & Payables Setup";
    begin
        if not LocalPPSetup.Get() then
            exit;

        if not LocalPPSetup."Dimension for PR Approval" then
            exit;

        PRLineToCheck.Reset();
        PRLineToCheck.SetRange("Document No.", Rec."No.");
        PRLineToCheck.SetFilter(Type, '<>%1', PRLineToCheck.Type::" ");
        if PRLineToCheck.FindSet() then
            repeat
                if (PRLineToCheck."Shortcut Dimension 1 Code" = '') or (PRLineToCheck."Shortcut Dimension 2 Code" = '') then
                    Error(Text004, PRLineToCheck."Document No.", PRLineToCheck."Line No.");
            until PRLineToCheck.Next() = 0;
    end;

    local procedure CheckPRBudgetBeforeApproval();
    var
        PRLineToCheck: Record "PR Line";
        PRLineSameKey: Record "PR Line";
        LocalNoSeries: Record "No. Series";
        LineAmountLCY: Decimal;
        IsRFQOrPO: Boolean;
    begin
        IsRFQOrPO := Rec."PR Document Type" in [Rec."PR Document Type"::RFQ, Rec."PR Document Type"::PO];
        if not IsRFQOrPO then
            exit;

        if Rec."Budgetary PR" then
            exit;

        if not LocalNoSeries.Get(Rec."No. series") then
            exit;

        PRLineToCheck.CheckBudget(Rec."No.");

        if LocalNoSeries."Enable Project Budget" then begin
            PRLineToCheck.Reset();
            PRLineToCheck.SetRange("Document No.", Rec."No.");
            PRLineToCheck.SetFilter(Type, '<>%1', PRLineToCheck.Type::" ");
            if PRLineToCheck.FindSet() then
                repeat
                    PRLineToCheck.TestField("WBS ID");
                    PRLineToCheck.TestField("Activity ID");
                    LineAmountLCY := PRLineToCheck.Quantity * PRLineToCheck."Unit Cost (LCY)";

                    PRLineSameKey.Reset();
                    PRLineSameKey.SetRange("Document No.", PRLineToCheck."Document No.");
                    PRLineSameKey.SetFilter(Type, '<>%1', PRLineSameKey.Type::" ");
                    PRLineSameKey.SetRange("WBS ID", PRLineToCheck."WBS ID");
                    PRLineSameKey.SetRange("Activity ID", PRLineToCheck."Activity ID");
                    PRLineSameKey.SetFilter("Line No.", '<>%1', PRLineToCheck."Line No.");
                    if PRLineSameKey.FindSet() then
                        repeat
                            LineAmountLCY += (PRLineSameKey.Quantity * PRLineSameKey."Unit Cost (LCY)");
                        until PRLineSameKey.Next() = 0;

                    if LineAmountLCY > PRLineToCheck."Available Budget" then
                        Error(Text005, PRLineToCheck.Type, PRLineToCheck."No.", PRLineToCheck."Line No.");
                until PRLineToCheck.Next() = 0;
        end;

        if LocalNoSeries."Enable GL Budget" then begin
            PRLineToCheck.Reset();
            PRLineToCheck.SetRange("Document No.", Rec."No.");
            PRLineToCheck.SetRange(Type, PRLineToCheck.Type::"G/L Account");
            if PRLineToCheck.FindSet() then
                repeat
                    LineAmountLCY := PRLineToCheck.Quantity * PRLineToCheck."Unit Cost (LCY)";

                    PRLineSameKey.Reset();
                    PRLineSameKey.SetRange("Document No.", PRLineToCheck."Document No.");
                    PRLineSameKey.SetRange(Type, PRLineSameKey.Type::"G/L Account");
                    PRLineSameKey.SetRange("No.", PRLineToCheck."No.");
                    PRLineSameKey.SetRange("Dimension Set ID", PRLineToCheck."Dimension Set ID");
                    PRLineSameKey.SetFilter("Line No.", '<>%1', PRLineToCheck."Line No.");
                    if PRLineSameKey.FindSet() then
                        repeat
                            LineAmountLCY += (PRLineSameKey.Quantity * PRLineSameKey."Unit Cost (LCY)");
                        until PRLineSameKey.Next() = 0;

                    if LineAmountLCY > PRLineToCheck."Available Budget" then
                        Error(Text005, PRLineToCheck.Type, PRLineToCheck."No.", PRLineToCheck."Line No.");
                until PRLineToCheck.Next() = 0;
        end;
    end;
}

