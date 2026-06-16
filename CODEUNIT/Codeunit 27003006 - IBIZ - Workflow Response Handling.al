codeunit 27003006 "IBIZ-WF Response Handle-IBIZPR"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsesToLibrary()
    begin
        WorkflowResponseHandling.AddResponseToLibrary(RejectPRDocumentCode, 0, RejectPRDocumentTxt, 'GROUP 0');
        WorkflowResponseHandling.AddResponseToLibrary(RejectPRLOADocumentCode, 0, RejectPRLOADocumentTxt, 'GROUP 0');
    end;

    procedure RejectPRDocumentCode(): Code[128]
    begin
        EXIT(UPPERCASE('RejectPRDocument'));
    end;

    procedure RejectPRLOADocumentCode(): Code[128]
    begin
        EXIT(UPPERCASE('RejectPRLOADocument'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        IBIZWorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZPR";
    begin
        CASE ResponseFunctionName OF
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.CreateApprovalRequestsCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRDocForApprovalCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.OpenDocumentCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRApprovalRequestCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode);
                end;
            RejectPRDocumentCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(RejectPRDocumentCode, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode);
                END;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRApprovalRequestCode);
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnExecuteWorkflowResponse', '', false, false)]
    local procedure OnExecuteWorkflowResponse(VAR ResponseExecuted: Boolean; Variant: Variant; xVariant: Variant; ResponseWorkflowStepInstance: Record "Workflow Step Instance")
    var
        WorkflowResponse: Record "Workflow Response";
    begin
        IF WorkflowResponse.GET(ResponseWorkflowStepInstance."Function Name") THEN
            CASE WorkflowResponse."Function Name" OF
                RejectPRDocumentCode:
                    begin
                        RejectPRDocument(Variant);
                        ResponseExecuted := true;
                    end;
            end;
    end;

    procedure RejectPRDocument(VAR Variant: Variant)
    var
        ApprovalEntry: Record "Approval Entry";
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ReleasePRDocument: Codeunit "Prepayment Mgt.";
        PRFunction: Codeunit "PR Functions-IBIZPR";
    begin
        RecRef.GETTABLE(Variant);

        CASE RecRef.NUMBER OF
            DATABASE::"Approval Entry":
                BEGIN
                    ApprovalEntry := Variant;
                    TargetRecRef.GET(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    RejectPRDocument(Variant);
                END;
            DATABASE::"PR Header":
                PRFunction.WFCancelPRDocument(Variant);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        PRFunction: Codeunit "PR Functions-IBIZPR";
        PRHeader: Record "PR Header";
    begin
        //RecRef.SetTable(PRHeader);
        CASE RecRef.NUMBER OF
            DATABASE::"PR Header":
                begin
                    RecRef.SetTable(PRHeader);
                    PRFunction.WFReleasePRDocument(PRHeader);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        PRFunctions: Codeunit "PR Functions-IBIZPR";
        PRHeader: Record "PR Header";
    begin
        //
        CASE RecRef.NUMBER OF
            DATABASE::"PR Header":
                BEGIN
                    RecRef.SetTable(PRHeader);
                    PRFunctions.ReopenPRDocument(PRHeader);
                    Handled := true;
                end;
        end;
    end;

    procedure RejectPRLOADocument(VAR Variant: Variant)
    var
        ApprovalEntry: Record "Approval Entry";
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ReleasePRDocument: Codeunit "Prepayment Mgt.";
        PRFunction: Codeunit "PR Functions-IBIZPR";
    begin
        RecRef.GETTABLE(Variant);

        CASE RecRef.NUMBER OF
            DATABASE::"Approval Entry":
                BEGIN
                    ApprovalEntry := Variant;
                    TargetRecRef.GET(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    RejectPRLOADocument(Variant);
                END;
            DATABASE::"PR Header":
                PRFunction.WFCancelPRDocument(Variant);
        END;
    end;

    var
        RejectPRDocumentTxt: Label 'Reject the PR document.';
        RejectPRLOADocumentTxt: Label 'Reject the PR LOA document.';
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
}