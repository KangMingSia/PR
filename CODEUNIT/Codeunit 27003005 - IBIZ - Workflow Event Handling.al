codeunit 27003005 "IBIZ - WF Eve. Hndl-IBIZPR"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPRDocForApprovalCode, DATABASE::"PR Header", PRDocSendForApprovalEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendPRLOADocForApprovalCode, DATABASE::"PR Header", PRLOADocSendForApprovalEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPRApprovalRequestCode, DATABASE::"PR Header", PRDocApprReqCancelledEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelPRLOAApprovalRequestCode, DATABASE::"PR Header", PRLOADocApprReqCancelledEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnAfterReleasePRDocCode, DATABASE::"PR Header", PRDocReleasedEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnAfterReleasePRLOADocCode, DATABASE::"PR Header", PRLOADocReleasedEventDescTxt, 0, FALSE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        CASE EventFunctionName OF
            RunWorkflowOnCancelPRApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPRApprovalRequestCode, RunWorkflowOnSendPRDocForApprovalCode);
            RunWorkflowOnCancelPRLOAApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelPRLOAApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
        end;
    end;

    procedure RunWorkflowOnSendPRDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendPRDocForApproval'));
    end;

    procedure RunWorkflowOnSendRFQCDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendRFQCDocForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IBIZ-Approvals Mgmt-IBIZPR", 'OnSendPRDocForApproval', '', false, false)]
    procedure RunWorkflowOnSendPRDocForApproval(VAR PRHeader: Record "PR Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPRDocForApprovalCode, PRHeader);
    end;

    procedure RunWorkflowOnCancelPRApprovalRequestCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnCancelPRApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IBIZ-Approvals Mgmt-IBIZPR", 'OnCancelPRApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPRApprovalRequest(VAR PRHeader: Record "PR Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPRApprovalRequestCode, PRHeader);
    end;

    procedure RunWorkflowOnAfterReleasePRDocCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnAfterReleasePRDoc'));
    end;

    procedure RunWorkflowOnAfterReleasePRDoc(VAR PRHeader: Codeunit "PR Functions-IBIZPR")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleasePRDocCode, PRHeader);
    end;

    procedure RunWorkflowOnSendPRLOADocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendPRLOADocForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"IBIZ-Approvals Mgmt-IBIZPR", 'OnSendPRLOADocForApproval', '', false, false)]
    procedure RunWorkflowOnSendPRLOADocForApproval(VAR PRHeader: Record "PR Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPRLOADocForApprovalCode, PRHeader);
    end;

    procedure RunWorkflowOnCancelPRLOAApprovalRequestCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnCancelPRLOAApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, codeunit::"IBIZ-Approvals Mgmt-IBIZPR", 'OnCancelPRLOAApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelPRLOAApprovalRequest(VAR PRHeader: Record "PR Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPRLOAApprovalRequestCode, PRHeader);
    end;

    procedure RunWorkflowOnAfterReleasePRLOADocCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnAfterReleasePRLOADoc'));
    end;

    procedure RunWorkflowOnAfterReleasePRLOADoc(VAR PRHeader: Codeunit "PR Functions-IBIZPR")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleasePRLOADocCode, PRHeader);
    end;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";

        PRDocSendForApprovalEventDescTxt: Label 'Approval of a PR document is requested.';
        PRDocApprReqCancelledEventDescTxt: Label 'An approval request for a PR document is canceled.';
        PRDocReleasedEventDescTxt: Label 'A PR document is released.';
        PRLOADocSendForApprovalEventDescTxt: Label 'Approval of a PR LOA document is requested.';
        PRLOADocApprReqCancelledEventDescTxt: Label 'An approval request for a PR LOA document is canceled.';
        PRLOADocReleasedEventDescTxt: Label 'A PR LOA document is released.';
}