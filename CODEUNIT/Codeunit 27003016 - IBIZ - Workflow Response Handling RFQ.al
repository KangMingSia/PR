codeunit 27003016 "IBIZ-WF Response Handle-RFQ"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsesToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsesToLibrary()
    begin
        WorkflowResponseHandling.AddResponseToLibrary(RejectRFQDocumentCode, 0, RejectRFQDocumentTxt, 'GROUP 0');
        //  WorkflowResponseHandling.AddResponseToLibrary(RejectPRLOADocumentCode, 0, RejectPRLOADocumentTxt, 'GROUP 0');
    end;

    procedure RejectRFQDocumentCode(): Code[128]
    begin
        EXIT(UPPERCASE('RejectRFQDocument'));
    end;

    /* procedure RejectPRLOADocumentCode(): Code[128]
    begin
        EXIT(UPPERCASE('RejectPRLOADocument'));
    end; */

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        IBIZWorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZRFQ";
    begin
        CASE ResponseFunctionName OF
            WorkflowResponseHandling.SetStatusToPendingApprovalCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendRFQDocForApprovalCode);
                    //   WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.CreateApprovalRequestsCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnSendRFQDocForApprovalCode);
                    // WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CreateApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendRFQDocForApprovalCode);
                    // WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode, IBIZWorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode);
                end;
            WorkflowResponseHandling.OpenDocumentCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode);
                    //WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode);
                end;
            RejectRFQDocumentCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(RejectRFQDocumentCode, WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode);
                END;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode:
                BEGIN
                    WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode);
                    // WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode, IBIZWorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode);
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
                RejectRFQDocumentCode:
                    begin
                        RejectRFQDocument(Variant);
                        ResponseExecuted := true;
                    end;
            end;
    end;

    procedure RejectRFQDocument(VAR Variant: Variant)
    var
        ApprovalEntry: Record "Approval Entry";
        RecRef: RecordRef;
        TargetRecRef: RecordRef;
        ReleasePRDocument: Codeunit "Prepayment Mgt.";
        RFQFunction: Codeunit "PR Functions-IBIZRFQ";
    begin
        RecRef.GETTABLE(Variant);

        CASE RecRef.NUMBER OF
            DATABASE::"Approval Entry":
                BEGIN
                    ApprovalEntry := Variant;
                    TargetRecRef.GET(ApprovalEntry."Record ID to Approve");
                    Variant := TargetRecRef;
                    RejectRFQDocument(Variant);
                END;
            DATABASE::"RFQ Comparison":
                RFQFunction.WFCancelRFQDocument(Variant);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        RFQFunction: Codeunit "PR Functions-IBIZRFQ";
        RFQHeader: Record "RFQ Comparison";
    begin
        // 
        CASE RecRef.NUMBER OF
            DATABASE::"RFQ Comparison":
                begin
                    RecRef.SetTable(RFQHeader);
                    RFQHeader.Status := RFQHeader.Status::Released;

                    RFQFunction.MakeOrder(RFQHeader);
                    RFQHeader.Status := RFQHeader.Status::Closed;
                    RFQHeader.Modify();
                    // RFQFunction.WFReleaseRFQCDocument(RFQHeader);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; VAR Handled: Boolean)
    var
        RFQFunction: Codeunit "PR Functions-IBIZRFQ";
        RFQHeader: Record "RFQ Comparison";
    begin
        // RecRef.SetTable(RFQHeader);
        CASE RecRef.NUMBER OF
            DATABASE::"RFQ Comparison":
                BEGIN
                    RecRef.SetTable(RFQHeader);
                    RFQFunction.ReopenRFQCDocument(RFQHeader);
                    Handled := true;
                end;
        end;
    end;

    /*  procedure RejectPRLOADocument(VAR Variant: Variant)
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
  */
    var
        RejectRFQDocumentTxt: Label 'Reject the RFQ document.';
        //  RejectPRLOADocumentTxt: Label 'Reject the PR LOA document.';
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
}