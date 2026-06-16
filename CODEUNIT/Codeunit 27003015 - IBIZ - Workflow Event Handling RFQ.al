codeunit 27003015 "IBIZ - WF Eve. Hndl-IBIZRFQ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRFQDocForApprovalCode, DATABASE::"RFQ Comparison", RFQDocSendForApprovalEventDescTxt, 0, FALSE);
        // WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRFQLOADocForApprovalCode, DATABASE::"RFQ Comparison", RFQLOADocSendForApprovalEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRFQApprovalRequestCode, DATABASE::"RFQ Comparison", RFQDocApprReqCancelledEventDescTxt, 0, FALSE);
        // WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRFQLOAApprovalRequestCode, DATABASE::"RFQ Comparison", RFQLOADocApprReqCancelledEventDescTxt, 0, FALSE);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnAfterReleaseRFQDocCode, DATABASE::"RFQ Comparison", RFQDocReleasedEventDescTxt, 0, FALSE);
        //WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnAfterReleaseRFQLOADocCode, DATABASE::"RFQ Comparison", RFQLOADocReleasedEventDescTxt, 0, FALSE);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        CASE EventFunctionName OF
            RunWorkflowOnCancelRFQApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRFQApprovalRequestCode, RunWorkflowOnSendRFQDocForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRFQDocForApprovalCode);
                    //  WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendRFQDocForApprovalCode);
                    //WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode:
                begin
                    WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendRFQDocForApprovalCode);
                    // WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode, RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
        end;
    end;

    procedure RunWorkflowOnSendRFQDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendRFQDocForApproval'));
    end;

    procedure RunWorkflowOnSendRFQCDocForApprovalCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnSendRFQCDocForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IBIZ-Approvals Mgmt-IBIZRFQ", 'OnSendRFQDocForApproval', '', false, false)]
    procedure RunWorkflowOnSendRFQDocForApproval(VAR RFQHeader: Record "RFQ Comparison")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRFQDocForApprovalCode, RFQHeader);
    end;

    procedure RunWorkflowOnCancelRFQApprovalRequestCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnCancelRFQApprovalRequest'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"IBIZ-Approvals Mgmt-IBIZRFQ", 'OnCancelRFQApprovalRequest', '', false, false)]
    procedure RunWorkflowOnCancelRFQApprovalRequest(VAR RFQHeader: Record "RFQ Comparison")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRFQApprovalRequestCode, RFQHeader);
    end;

    procedure RunWorkflowOnAfterReleaseRFQDocCode(): Code[128]
    begin
        EXIT(UPPERCASE('RunWorkflowOnAfterReleaseRFQDoc'));
    end;

    procedure RunWorkflowOnAfterReleaseRFQDoc(VAR RFQHeader: Record "RFQ Comparison")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleaseRFQDocCode, RFQHeader);
    end;

    /* procedure RunWorkflowOnSendPRLOADocForApprovalCode(): Code[128]
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
 */
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";

        RFQDocSendForApprovalEventDescTxt: Label 'Approval of a RFQ document is requested.';
        RFQDocApprReqCancelledEventDescTxt: Label 'An approval request for a RFQ document is canceled.';
        RFQDocReleasedEventDescTxt: Label 'A RFQ document is released.';
    /* PRLOADocSendForApprovalEventDescTxt: Label 'Approval of a PR LOA document is requested.';
    PRLOADocApprReqCancelledEventDescTxt: Label 'An approval request for a PR LOA document is canceled.';
    PRLOADocReleasedEventDescTxt: Label 'A PR LOA document is released.'; */
}