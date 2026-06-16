codeunit 27003017 "IBIZ - WF Req. Hdle.al-IBIZRFQ"
{
    procedure InsertPRDocumentApprovalWorkflow(VAR Workflow: Record Workflow; DocumentType: Option; ApproverType: Enum "Workflow Approval Type"; LimitType: Enum "Workflow Approver Limit Type"; WorkflowUserGroupCode: Code[20]; DueDateFormula: DateFormula)//Version 19.0.0.0>>
    var
        RFQHeader: Record "RFQ Comparison";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZRFQ";
    begin
        InsertWorkflow(Workflow, GetWorkflowCode(PurchReqApprWorkflowCodeTxt), PurchReqApprWorkflowDescTxt, RFQDocCategoryTxt);

        PopulateWorkflowStepArgument(WorkflowStepArgument, ApproverType, LimitType, 0,
          WorkflowUserGroupCode, DueDateFormula, TRUE);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow, BuildRFQHeaderTypeConditions(RFQHeader.Status::Open),
          WorkflowEventHandling.RunWorkflowOnSendRFQDocForApprovalCode,
          BuildRFQHeaderTypeConditions(RFQHeader.Status::"Pending Approval"),
          WorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode,
          WorkflowStepArgument, TRUE);
    end;

    /*    procedure InsertPRLOADocumentApprovalWorkflow(VAR Workflow: Record Workflow; DocumentType: Option; ApproverType: Enum "Workflow Approval Type"; LimitType: Enum "Workflow Approver Limit Type"; WorkflowUserGroupCode: Code[20]; DueDateFormula: DateFormula)//Version 19.0.0.0>>
    var
         RFQHeader: Record "RFQ Comparison";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZRFQ";
    begin
        InsertWorkflow(Workflow, GetWorkflowCode(PRLOAApprWorkflowCodeTxt), PRLOAApprWorkflowDescTxt, PRLOADocCategoryTxt);

        PopulateWorkflowStepArgument(WorkflowStepArgument, ApproverType, LimitType, 0,
          WorkflowUserGroupCode, DueDateFormula, TRUE);
        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow, BuildPRHeaderTypeConditions(RFQHeader."LOA Status"::Open),
          WorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode,
          BuildPRHeaderTypeConditions(PRHeader."LOA Status"::"Pending Approval"),
          WorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode,
          WorkflowStepArgument, TRUE);
    end; */

    procedure InsertWorkflow(VAR Workflow: Record Workflow; WorkflowCode: Code[20]; WorkflowDescription: Text[100]; CategoryCode: Code[20])
    begin
        Workflow.INIT;
        Workflow.Code := WorkflowCode;
        Workflow.Description := WorkflowDescription;
        Workflow.Category := CategoryCode;
        Workflow.Enabled := FALSE;
        Workflow.INSERT;
    end;

    procedure GetWorkflowCode(WorkflowCode: Text): Code[20]
    var
        Workflow: Record Workflow;
    begin
        EXIT(COPYSTR(FORMAT(Workflow.COUNT + 1) + '-' + WorkflowCode, 1, MAXSTRLEN(Workflow.Code)));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', false, false)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        WorkflowSetup: Codeunit "Workflow Setup";
        ApprovalEntry: Record "Approval Entry";
    begin
        WorkflowSetup.InsertTableRelation(DATABASE::"RFQ Comparison", 0, DATABASE::"Approval Entry", ApprovalEntry.FIELDNO("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', false, false)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        InsertWorkflowCategory(RFQDocCategoryTxt, RFQDocCategoryDescTxt);
        //  InsertWorkflowCategory(PRLOADocCategoryTxt, PRLOADocCategoryDescTxt);
    end;

    procedure RFQApprovalWorkflowCode(): Code[17]
    begin
        EXIT(PurchReqApprWorkflowCodeTxt);
    end;

    /*  procedure PRLOAApprovalWorkflowCode(): Code[17]
     begin
         EXIT(PRLOAApprWorkflowCodeTxt);
     end; */

    procedure InsertWorkflowCategory(Code: Code[20]; Description: Text[100])
    var
        WorkflowCategory: Record "Workflow Category";
    begin
        WorkflowCategory.INIT;
        WorkflowCategory.Code := Code;
        WorkflowCategory.Description := Description;
        IF WorkflowCategory.INSERT THEN;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', false, false)]
    local procedure OnInsertWorkflowTemplates()
    begin
        InsertRFQApprovalWorkflowTemplate;

    end;
    /* 
        procedure InsertPRLOAApprovalWorkflowTemplate()
        var
            Workflow: Record Workflow;
        begin
            InsertWorkflowTemplate(Workflow, PurchReqApprWorkflowCodeTxt, PurchReqApprWorkflowDescTxt, PRDocCategoryTxt);
            InsertPRApprovalWorkflowDetails(Workflow);
            MarkWorkflowAsTemplate(Workflow);
        end;
     */
    procedure MarkWorkflowAsTemplate(VAR Workflow: Record Workflow)
    begin
        Workflow.VALIDATE(Template, TRUE);
        Workflow.MODIFY(TRUE);
    end;

    procedure InsertRFQApprovalWorkflowTemplate()
    var
        Workflow: Record "Workflow";
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        InsertWorkflowTemplate(Workflow, PurchReqApprWorkflowCodeTxt, PurchReqApprWorkflowDescTxt, RFQDocCategoryTxt);
        InsertRFQApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    /*  procedure InsertPRLOAApprovalWorkflowDetails(VAR Workflow: Record Workflow)
     var
         WorkflowSetup: Codeunit "Workflow Setup";
         PRHeader: Record "PR Header";
         WorkflowStepArgument: Record "Workflow Step Argument";
         BlankDateFormula: DateFormula;
         WorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZPR";
     begin
         //Version 19.0.0.0>>
         // WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument,
         //   WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Approver Chain",
         //   0, '', BlankDateFormula, TRUE);

         WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument,
                   WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Approver Chain",
                   0, '', BlankDateFormula, TRUE);
         //Version 19.0.0.0<<
         WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
           BuildPRHeaderTypeConditions(PRHeader."LOA Status"::Open),
           WorkflowEventHandling.RunWorkflowOnSendPRLOADocForApprovalCode,
           BuildPRHeaderTypeConditions(PRHeader."LOA Status"::"Pending Approval"),
           WorkflowEventHandling.RunWorkflowOnCancelPRLOAApprovalRequestCode,
           WorkflowStepArgument, TRUE);
     end;
  */
    procedure InsertRFQApprovalWorkflowDetails(VAR Workflow: Record Workflow)
    var
        RFQHeader: Record "RFQ Comparison";
        WorkflowStepArgument: Record "Workflow Step Argument";
        BlankDateFormula: DateFormula;
        WorkflowSetup: Codeunit "Workflow Setup";
        WorkflowEventHandling: Codeunit "IBIZ - WF Eve. Hndl-IBIZRFQ";
    begin
        PopulateWorkflowStepArgument(WorkflowStepArgument,
          WorkflowStepArgument."Approver Type"::Approver, WorkflowStepArgument."Approver Limit Type"::"Approver Chain",
          0, '', BlankDateFormula, TRUE);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
          BuildRFQHeaderTypeConditions(RFQHeader.Status::Open),
          WorkflowEventHandling.RunWorkflowOnSendRFQDocForApprovalCode,
          BuildRFQHeaderTypeConditions(RFQHeader.Status::"Pending Approval"),
          WorkflowEventHandling.RunWorkflowOnCancelRFQApprovalRequestCode,
          WorkflowStepArgument, TRUE);
    end;

    procedure BuildRFQHeaderTypeConditions(Status: Option): Text
    var
        RFQHeader: Record "RFQ Comparison";
        RFQLine: Record "RFQ Compare Line";
    begin
        RFQHeader.SETRANGE(Status, Status);
        EXIT(STRSUBSTNO(PurchReqHeaderTypeCondnTxt, Encode(RFQHeader.GETVIEW(FALSE)), Encode(RFQLine.GETVIEW(FALSE))));
    end;

    /* procedure BuildPRLOAHeaderTypeConditions("LOA Status": Option): Text
    var
        PRHeader: Record "PR Header";
        PRLine: Record "PR Line";
    begin
        PRHeader.SETRANGE("LOA Status", "LOA Status");
        EXIT(STRSUBSTNO(PRLOAHeaderTypeCondnTxt, Encode(PRHeader.GETVIEW(FALSE)), Encode(PRLine.GETVIEW(FALSE))));
    end; */

    procedure Encode(Text: Text): Text
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
    begin
        EXIT(XMLDOMManagement.XMLEscape(Text));
    end;

    // procedure PopulateWorkflowStepArgument(VAR WorkflowStepArgument: Record "Workflow Step Argument"; ApproverType: Option; ApproverLimitType: Option; ApprovalEntriesPage: Integer; WorkflowUserGroupCode: Code[20]; DueDateFormula: DateFormula; ShowConfirmationMessage: Boolean)//Version 19.0.0.0>>
    procedure PopulateWorkflowStepArgument(VAR WorkflowStepArgument: Record "Workflow Step Argument"; ApproverType: Enum "Workflow Approval Type"; ApproverLimitType: enum "Workflow Approver Limit Type"; ApprovalEntriesPage: Integer; WorkflowUserGroupCode: Code[20]; DueDateFormula: DateFormula; ShowConfirmationMessage: Boolean)//Version 19.0.0.0>>
    begin
        WorkflowStepArgument.INIT;
        WorkflowStepArgument.Type := WorkflowStepArgument.Type::Response;
        WorkflowStepArgument."Approver Type" := ApproverType;
        WorkflowStepArgument."Approver Limit Type" := ApproverLimitType;
        WorkflowStepArgument."Workflow User Group Code" := WorkflowUserGroupCode;
        WorkflowStepArgument."Due Date Formula" := DueDateFormula;
        WorkflowStepArgument."Link Target Page" := ApprovalEntriesPage;
        WorkflowStepArgument."Show Confirmation Message" := ShowConfirmationMessage;
    end;

    procedure InsertWorkflowTemplate(VAR Workflow: Record Workflow; WorkflowCode: Code[17]; WorkflowDescription: Text[100]; CategoryCode: Code[20])
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        Workflow.INIT;
        Workflow.Code := WorkflowSetup.GetWorkflowTemplateCode(WorkflowCode);
        Workflow.Description := WorkflowDescription;
        Workflow.Category := CategoryCode;
        Workflow.Enabled := FALSE;
        IF Workflow.INSERT THEN;
    end;
    //CU-1502----End-------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure OnAfterInitWorkflowTemplates()
    var
        WorkflowRequestPageHandling: codeunit "Workflow Request Page Handling";
    begin
        InsertReqPageEntity(RFQDocumentCodeTxt, RFQDocumentDescTxt, DATABASE::"RFQ Comparison", DATABASE::"RFQ Compare Line");
        //  InsertReqPageEntity(PRLOADocumentCodeTxt, PRLOADocumentDescTxt, DATABASE::"PR Header", DATABASE::"PR Line");
        InsertRFQHeaderReqPageFields;
        InsertRFQLineReqPageFields;
        //InsertPRLOAHeaderReqPageFields;
        //InsertPRLOALineReqPageFields;
        AssignEntityToWorkflowEvent(DATABASE::"RFQ Comparison", RFQDocumentCodeTxt);
        //  AssignEntityToWorkflowEvent(DATABASE::"RFQ Comparison", RFQLOADocumentCodeTxt);
    end;

    procedure InsertRFQHeaderReqPageFields()
    var
        RFQHeader: Record "RFQ Comparison";
    begin
        InsertReqPageField(DATABASE::"RFQ Comparison", RFQHeader.FIELDNO(Requester));
    end;

    procedure InsertRFQLineReqPageFields()
    var
        RFQLine: Record "RFQ Compare Line";
    begin
        InsertReqPageField(DATABASE::"PR Line", RFQLine.FIELDNO("RFQ Compare No."));
        InsertReqPageField(DATABASE::"PR Line", RFQLine.FIELDNO(Quantity));
        InsertReqPageField(DATABASE::"PR Line", RFQLine.FIELDNO("Unit Price"));
    end;

    /* procedure InsertPRLOAHeaderReqPageFields()
    var
        PRHeader: Record "PR Header";
    begin
        InsertReqPageField(DATABASE::"PR Header", PRHeader.FIELDNO(Requester));
    end;

    procedure InsertPRLOALineReqPageFields()
    var
        PRLine: Record "PR Line";
    begin
        InsertReqPageField(DATABASE::"PR Line", PRLine.FIELDNO("No."));
        InsertReqPageField(DATABASE::"PR Line", PRLine.FIELDNO(Quantity));
        InsertReqPageField(DATABASE::"PR Line", PRLine.FIELDNO("Unit Cost"));
    end;
 */
    procedure InsertReqPageField(TableId: Integer; FieldId: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
    begin
        IF NOT DynamicRequestPageField.GET(TableId, FieldId) THEN
            CreateReqPageField(TableId, FieldId);
    end;

    procedure CreateReqPageField(TableId: Integer; FieldId: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
    begin
        DynamicRequestPageField.INIT;
        DynamicRequestPageField.VALIDATE("Table ID", TableId);
        DynamicRequestPageField.VALIDATE("Field ID", FieldId);
        DynamicRequestPageField.INSERT;
    end;

    procedure AssignEntityToWorkflowEvent(TableID: Integer; DynamicReqPageEntityName: Code[20])
    var
        WorkflowEvent: Record "Workflow Event";
    begin
        WorkflowEvent.SETRANGE("Table ID", TableID);
        IF NOT WorkflowEvent.ISEMPTY THEN
            WorkflowEvent.MODIFYALL("Dynamic Req. Page Entity Name", DynamicReqPageEntityName);
    end;

    procedure InsertReqPageEntity(Name: Code[20]; Description: Text[100]; TableId: Integer; RelatedTableId: Integer)
    begin
        IF NOT FindReqPageEntity(Name, TableId, RelatedTableId) THEN
            CreateReqPageEntity(Name, Description, TableId, RelatedTableId);
    end;

    procedure FindReqPageEntity(Name: Code[20]; TableId: Integer; RelatedTableId: Integer): Boolean
    var
        DynamicRequestPageEntity: Record "Dynamic Request Page Entity";
    begin
        DynamicRequestPageEntity.SETRANGE(Name, Name);
        DynamicRequestPageEntity.SETRANGE("Table ID", TableId);
        DynamicRequestPageEntity.SETRANGE("Related Table ID", RelatedTableId);
        EXIT(DynamicRequestPageEntity.FINDFIRST);
    end;

    procedure CreateReqPageEntity(Name: Code[20]; Description: Text[100]; TableId: Integer; RelatedTableId: Integer)
    var
        DynamicRequestPageEntity: Record "Dynamic Request Page Entity";
    begin
        DynamicRequestPageEntity.INIT;
        DynamicRequestPageEntity.Name := Name;
        DynamicRequestPageEntity.Description := Description;
        DynamicRequestPageEntity.VALIDATE("Table ID", TableId);
        DynamicRequestPageEntity.VALIDATE("Related Table ID", RelatedTableId);
        DynamicRequestPageEntity.INSERT(TRUE);
    end;

    var
        RFQDocumentCodeTxt: Label 'PRDOC';
        //  PRLOADocumentCodeTxt: Label 'PRLOADocumentCodeTxt';
        RFQDocumentDescTxt: Label 'PR Document';
        //  PRLOADocumentDescTxt: Label 'PR LOA Document';
        PurchReqApprWorkflowCodeTxt: Label 'RFQAPW';
        PurchReqApprWorkflowDescTxt: Label 'RFQ Approval Workflow';
        RFQDocCategoryTxt: Label 'RFQDOC';
        RFQDocCategoryDescTxt: Label 'RFQ Documents';
        PurchReqHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="RFQ Comparison">%1</DataItem><DataItem name="RFQ Compare Line">%2</DataItem></DataItems></ReportParameters>';
    //PRLOADocCategoryTxt: Label 'PRLOADOC';
    //PRLOADocCategoryDescTxt: Label 'PR LOA Documents';
    //PRLOAApprWorkflowCodeTxt: Label 'PRLOAAPW';
    //PRLOAApprWorkflowDescTxt: Label 'Purchase Requisition LOA Approval Workflow';
    //PRLOAHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="PR Header">%1</DataItem><DataItem name="PR Line">%2</DataItem></DataItems></ReportParameters>';
}