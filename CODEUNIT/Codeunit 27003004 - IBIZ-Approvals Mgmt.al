codeunit 27003004 "IBIZ-Approvals Mgmt-IBIZPR"
{
    procedure CheckPRLOAApprovalsWorkflowEnabled(VAR PRHeader: Record "PR Header"): Boolean
    begin
        IF NOT IsPRLOAApprovalsWorkflowEnabled(PRHeader) THEN
            ERROR(NoWorkflowEnabledErr);
        EXIT(TRUE);
    end;

    procedure IsPRLOAApprovalsWorkflowEnabled(VAR PRHeader: Record "PR Header"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(PRHeader, RunWorkflowOnSendPRLOADocForApprovalCode));
    end;

    procedure CheckRFQCApprovalsWorkflowEnabled(VAR RFQComp: Record "RFQ Comparison"): Boolean
    begin
        IF NOT IsRFQCApprovalsWorkflowEnabled(RFQComp) THEN
            ERROR(NoWorkflowEnabledErr);

        EXIT(TRUE);
    end;

    procedure RunWorkflowOnSendPRLOADocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendPRLOADocForApproval'));
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPRLOADocForApproval(VAR PRHeader: Record "PR Header")
    begin
    end;
    //Convert PO---End---
    //Release PR--Start--
    procedure IsPRApprovalsWorkflowEnabled(VAR PRHeader: Record "PR Header"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(PRHeader, RunWorkflowOnSendPRDocForApprovalCode));
    end;

    procedure RunWorkflowOnSendPRDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendPRDocForApproval'));
    end;
    //Release PR---End---
    //Send for Approval--Start--
    procedure CheckPRApprovalsWorkflowEnabled(VAR PRHeader: Record "PR Header"): Boolean
    begin
        IF NOT IsPRApprovalsWorkflowEnabled(PRHeader) THEN
            ERROR(NoWorkflowEnabledErr);
        EXIT(TRUE);
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendPRDocForApproval(VAR PRHeader: Record "PR Header")
    begin
    end;
    //Send for Approval---End---

    [IntegrationEvent(false, false)]
    procedure OnCancelPRApprovalRequest(VAR PRHeader: Record "PR Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelPRLOAApprovalRequest(VAR PRHeader: Record "PR Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRFQCDocForApproval(VAR RFQC: Record "RFQ Comparison")
    begin
    end;

    procedure ShowPRApprovalStatus(PRHeader: Record "PR Header")
    begin
        PRHeader.FIND;

        CASE PRHeader.Status OF
            PRHeader.Status::Released:
                MESSAGE(DocStatusChangedMsg, '', PRHeader."No.", PRHeader.Status);
            PRHeader.Status::"Pending Approval":
                MESSAGE(PendingApprovalMsg);
            PRHeader.Status::Cancel:
                MESSAGE(DMT001);
            PRHeader.Status::Closed:
                MESSAGE(DMT002);
        END;
    end;

    procedure ShowPRLOAApprovalStatus(PRHeader: Record "PR Header")
    begin
        PRHeader.FIND;

        CASE PRHeader."LOA Status" OF
            PRHeader."LOA Status"::Released:
                MESSAGE(DocStatusChangedMsg, '', PRHeader."No.", PRHeader."LOA Status");
            PRHeader."LOA Status"::"Pending Approval":
                MESSAGE(PendingApprovalMsg);
            PRHeader."LOA Status"::Cancel:
                MESSAGE(DMT001);
            PRHeader."LOA Status"::Closed:
                MESSAGE(DMT002);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(VAR RecRef: RecordRef; VAR ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        PRHeader: Record "PR Header";
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"PR Header":
                BEGIN
                    RecRef.SETTABLE(PRHeader);
                    CalcPRDocAmount(PRHeader, ApprovalAmount, ApprovalAmountLCY);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."PR Document Type"::PR;
                    ApprovalEntryArgument."Document No." := PRHeader."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := PRHeader."Purchaser Code";
                    ApprovalEntryArgument.Amount := ApprovalAmount;
                    ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure OnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; VAR IsSufficient: Boolean)
    begin
        CASE ApprovalEntryArgument."Table ID" OF
            DATABASE::"PR Header":
                begin
                    IF IsSufficientPRApprover(UserSetup, ApprovalEntryArgument."Document Type", ApprovalEntryArgument."Amount (LCY)") = true then begin
                        IsSufficient := TRUE;
                    END else begin
                        IsSufficient := false;
                    end;
                END;
        end;
    end;

    // procedure IsSufficientPRApprover(UserSetup: Record "User Setup"; DocumentType: Option; ApprovalAmountLCY: Decimal): Boolean//Version 19.0.0.0>>
    procedure IsSufficientPRApprover(UserSetup: Record "User Setup"; DocumentType: Enum "Approval Document Type"; ApprovalAmountLCY: Decimal): Boolean//Version 19.0.0.0>>
    begin
        IF UserSetup."User ID" = UserSetup."Approver ID" THEN
            EXIT(TRUE);

        IF UserSetup."Unlimited Request Approval" OR
            ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") AND (UserSetup."Purchase Amount Approval Limit" <> 0))
        THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    procedure IsSufficientPRLOAApprover(UserSetup: Record "User Setup"; DocumentType: Option; ApprovalAmountLCY: Decimal): Boolean
    begin
        IF UserSetup."User ID" = UserSetup."Approver ID" THEN
            EXIT(TRUE);

        IF UserSetup."Unlimited Request Approval" OR
            ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") AND (UserSetup."Purchase Amount Approval Limit" <> 0))
        THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    procedure CheckApprPRDocument(PRHeader: Record "PR Header"): Boolean
    var
        ApprovalTemplate: Record "Approval Templates";
    begin
        ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
        ApprovalTemplate.SETRANGE("Table ID", DATABASE::"PR Header");
        ApprovalTemplate.SETRANGE(Enabled, TRUE);
        IF ApprovalTemplate.FIND('-') THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure CalcPRDocAmount(PRHeader: Record "PR Header"; VAR ApprovalAmount: Decimal; VAR ApprovalAmountLCY: Decimal)
    begin
        PRHeader.CALCFIELDS("PR Total Amount", "PR Total Amount (LCY)");
        ApprovalAmount := PRHeader."PR Total Amount";
        ApprovalAmountLCY := PRHeader."PR Total Amount (LCY)";
    end;

    procedure CheckApprPRLOADocument(PRHeader: Record "PR Header"): Boolean
    var
        ApprovalTemplate: Record "Approval Templates";
    begin
        ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
        ApprovalTemplate.SETRANGE("Table ID", DATABASE::"PR Header");
        ApprovalTemplate.SETRANGE(Enabled, TRUE);
        ApprovalTemplate.SETRANGE("LOA Approval", TRUE);
        IF ApprovalTemplate.FIND('-') THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);

    end;

    procedure CalcPRLOADocAmount(PRHeader: Record "PR Header"; VAR ApprovalAmount: Decimal; VAR ApprovalAmountLCY: Decimal)
    begin
        PRHeader.CALCFIELDS("PR Total Amount", "PR Total Amount (LCY)");
        ApprovalAmount := PRHeader."PR Total Amount";
        ApprovalAmountLCY := PRHeader."PR Total Amount (LCY)";
    end;

    procedure IsRFQCApprovalsWorkflowEnabled(VAR RFQC: Record "RFQ Comparison"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(RFQC, IbizWorkflowEventHandling.RunWorkflowOnSendRFQCDocForApprovalCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; VAR Variant: Variant; VAR IsHandled: Boolean)
    var
        PRHeader: Record "PR Header";
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"PR Header":
                BEGIN
                    RecRef.SETTABLE(PRHeader);
                    IF PRHeader.Status = PRHeader.Status::Released THEN BEGIN
                        PRHeader.VALIDATE("LOA Status", PRHeader."LOA Status"::"Pending Approval");
                        PRHeader.MODIFY(TRUE);
                        Variant := PRHeader;
                        IsHandled := true;
                    END ELSE BEGIN
                        PRHeader.VALIDATE(Status, PRHeader.Status::"Pending Approval");
                        PRHeader.MODIFY(TRUE);
                        Variant := PRHeader;
                        IsHandled := true;
                    END;
                END;
        end;
    end;

    var
        PRFunctions: Codeunit "PR Functions-IBIZPR";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        IbizWorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZPR";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        DocStatusChangedMsg: Label '%1 %2 has been automatically approved. The status has been changed to %3.';
        PendingApprovalMsg: Label 'An approval request has been sent.';
        DMT001: Label 'Approval request cancelled.';
        DMT002: Label 'Approval request close.';
}