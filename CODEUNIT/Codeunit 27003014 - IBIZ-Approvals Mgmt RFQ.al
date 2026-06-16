codeunit 27003014 "IBIZ-Approvals Mgmt-IBIZRFQ"
{


    procedure CheckRFQCApprovalsWorkflowEnabled(VAR RFQComp: Record "RFQ Comparison"): Boolean
    begin
        IF NOT IsRFQCApprovalsWorkflowEnabled(RFQComp) THEN
            ERROR(NoWorkflowEnabledErr);

        EXIT(TRUE);
    end;

    procedure IsRFQApprovalsWorkflowEnabled(VAR RFQHeader: Record "RFQ Comparison"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(RFQHeader, RunWorkflowOnSendRFQDocForApprovalCode));
    end;

    procedure RunWorkflowOnSendRFQDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendRFQDocForApproval'));
    end;
    //Release PR---End---
    //Send for Approval--Start--
    procedure CheckRFQApprovalsWorkflowEnabled(VAR RFQHeader: Record "RFQ Comparison"): Boolean
    begin
        IF NOT IsRFQApprovalsWorkflowEnabled(RFQHeader) THEN
            ERROR(NoWorkflowEnabledErr);
        EXIT(TRUE);
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRFQDocForApproval(VAR RFQHeader: Record "RFQ Comparison")
    begin
    end;
    //Send for Approval---End---

    [IntegrationEvent(false, false)]
    procedure OnCancelRFQApprovalRequest(VAR RFQHeader: Record "RFQ Comparison")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelRFQLOAApprovalRequest(VAR RFQHeader: Record "RFQ Comparison")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSendRFQCDocForApproval(VAR RFQC: Record "RFQ Comparison")
    begin
    end;

    procedure ShowPRApprovalStatus(RFQHeader: Record "RFQ Comparison")
    begin
        RFQHeader.FIND;

        CASE RFQHeader.Status OF
            RFQHeader.Status::Released:
                MESSAGE(DocStatusChangedMsg, '', RFQHeader."No.", RFQHeader.Status);
            RFQHeader.Status::"Pending Approval":
                MESSAGE(PendingApprovalMsg);
            RFQHeader.Status::Cancel:
                MESSAGE(DMT001);
            RFQHeader.Status::Closed:
                MESSAGE(DMT002);
        END;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(VAR RecRef: RecordRef; VAR ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RFQHeader: Record "RFQ Comparison";
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"RFQ Comparison":
                BEGIN
                    RecRef.SETTABLE(RFQHeader);
                    CalcRFQDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."PR Document Type"::PR;
                    ApprovalEntryArgument."Document No." := RFQHeader."No.";
                    ApprovalEntryArgument."Salespers./Purch. Code" := RFQHeader."Purchaser Code";
                    ApprovalEntryArgument.Amount := ApprovalAmount;
                    ApprovalEntryArgument."Amount (LCY)" := ApprovalAmountLCY;
                END;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnAfterIsSufficientApprover', '', false, false)]
    local procedure OnAfterIsSufficientApprover(UserSetup: Record "User Setup"; ApprovalEntryArgument: Record "Approval Entry"; VAR IsSufficient: Boolean)
    begin
        CASE ApprovalEntryArgument."Table ID" OF
            DATABASE::"RFQ Comparison":
                begin
                    IF IsSufficientRFQApprover(UserSetup, ApprovalEntryArgument."Document Type", ApprovalEntryArgument."Amount (LCY)") = true then begin
                        IsSufficient := TRUE;
                    END else begin
                        IsSufficient := false;
                    end;
                END;
        end;
    end;

    // procedure IsSufficientPRApprover(UserSetup: Record "User Setup"; DocumentType: Option; ApprovalAmountLCY: Decimal): Boolean//Version 19.0.0.0>>
    procedure IsSufficientRFQApprover(UserSetup: Record "User Setup"; DocumentType: Enum "Approval Document Type"; ApprovalAmountLCY: Decimal): Boolean//Version 19.0.0.0>>
    begin
        IF UserSetup."User ID" = UserSetup."Approver ID" THEN
            EXIT(TRUE);

        IF UserSetup."Unlimited Request Approval" OR
            ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") AND (UserSetup."Purchase Amount Approval Limit" <> 0))
        THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;


    procedure CheckApprRFQDocument(RFQHeader: Record "RFQ Comparison"): Boolean
    var
        ApprovalTemplate: Record "Approval Templates";
    begin
        ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
        ApprovalTemplate.SETRANGE("Table ID", DATABASE::"RFQ Comparison");
        ApprovalTemplate.SETRANGE(Enabled, TRUE);
        IF ApprovalTemplate.FIND('-') THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure CalcRFQDocAmount(RFQHeader: Record "RFQ Comparison"; VAR ApprovalAmount: Decimal; VAR ApprovalAmountLCY: Decimal)
    begin
        RFQHeader.CALCFIELDS("RFQ Total Amount", "RFQ Total Amount (LCY)");
        ApprovalAmount := RFQHeader."RFQ Total Amount";
        ApprovalAmountLCY := RFQHeader."RFQ Total Amount (LCY)";
    end;

    procedure IsRFQCApprovalsWorkflowEnabled(VAR RFQC: Record "RFQ Comparison"): Boolean
    begin
        EXIT(WorkflowManagement.CanExecuteWorkflow(RFQC, IbizWorkflowEventHandling.RunWorkflowOnSendRFQCDocForApprovalCode));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; VAR Variant: Variant; VAR IsHandled: Boolean)
    var
        RFQHeader: Record "RFQ Comparison";
    begin
        CASE RecRef.NUMBER OF
            DATABASE::"RFQ Comparison":
                BEGIN
                    RecRef.SETTABLE(RFQHeader);
                    IF RFQHeader.Status = RFQHeader.Status::Released THEN BEGIN
                        RFQHeader.VALIDATE("LOA Status", RFQHeader."LOA Status"::"Pending Approval");
                        RFQHeader.MODIFY(TRUE);
                        Variant := RFQHeader;
                        IsHandled := true;
                    END ELSE BEGIN
                        RFQHeader.VALIDATE(Status, RFQHeader.Status::"Pending Approval");
                        RFQHeader.MODIFY(TRUE);
                        Variant := RFQHeader;
                        IsHandled := true;
                    END;
                END;
        end;
    end;

    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        IbizWorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZRFQ";
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        DocStatusChangedMsg: Label '%1 %2 has been automatically approved. The status has been changed to %3.';
        PendingApprovalMsg: Label 'An approval request has been sent.';
        DMT001: Label 'Approval request cancelled.';
        DMT002: Label 'Approval request close.';
}