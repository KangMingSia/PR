codeunit 27003018 "Install Code Unit-IBIZRFQ"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    begin
        InsertWorkflowEvent();
        InsertWorkflowTableRelation();
    end;


    local procedure InsertWorkflowEvent()
    begin
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASERFQDOC', 27003003, 'A RFQ Comparision document is released.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003003, 'An approval request for a RFQ Comparision document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQLOAAPPROVALREQUEST', 27003003, 'An approval request for a RFQ document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003003, 'Approval of a RFQ Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQLOADOCFORAPPROVAL', 27003003, 'Approval of a RFQ LOA Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003003, 'Approval of a RFQ Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003003, 'An approval request for a RFQ Comparision document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
    end;

    procedure CheckAndInsertWorkflowEvent(FunctionName: Code[128]; TableID: Integer; Desc: Text[250]; RequestPageID: Integer;
                                        DynamicReqPageEntityName: Code[20]; UsedforRecordChange: Boolean; Indepnt: Boolean; SysId: Guid)
    var
        WorkflowEvent: Record "Workflow Event";
    begin
        with WorkflowEvent do begin
            if not Get(FunctionName) then begin
                Init();
                "Function Name" := FunctionName;
                "Table ID" := TableID;
                Description := Desc;
                "Request Page ID" := RequestPageID;
                "Dynamic Req. Page Entity Name" := DynamicReqPageEntityName;
                "Used for Record Change" := UsedforRecordChange;
                Independent := Indepnt;
                SystemId := SysId;
                Insert(true);
            end;
        end;
    end;

    procedure InsertWorkflowTableRelation()
    var
        tt: Record 454;
    begin
        CheckAndInsertWorkflowTableRelation(27003003, 0, 454, 22, CreateGuid());
    end;

    procedure CheckAndInsertWorkflowTableRelation(TableID: Integer; FieldID: Integer; RelatedTableID: Integer; RelatedFieldID: Integer; SysId: Guid)
    var
        WorkflowTableRelation: Record 1505;
    begin
        with WorkflowTableRelation do begin
            if not Get(TableID, FieldID, RelatedTableID, RelatedFieldID) then begin
                Init();
                "Table ID" := TableID;
                "Field ID" := FieldID;
                "Related Table ID" := RelatedTableID;
                "Related Field ID" := RelatedFieldID;
                SystemId := SysId;
                Insert(true);
            end;
        end;
    end;
}
codeunit 27003019 "Update Code UnitRFQ"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    begin
        InsertWorkflowEvent();
        InsertWorkflowTableRelation();
    end;


    trigger OnCheckPreconditionsPerCompany()
    begin
        //InsertWorkflowEvent();
    end;

    trigger OnValidateUpgradePerCompany()
    begin
        //InsertWorkflowEvent();
    end;

    local procedure InsertWorkflowEvent()
    begin
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASERFQDOC', 27003003, 'A RFQ Comparision document is released.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASERFQLOADOC', 27003003, 'A RFQ LOA Comparision document is released.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003003, 'An approval request for a RFQ document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQLOAAPPROVALREQUEST', 27003003, 'An approval request for a RFQ Comparision LOA document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003003, 'Approval of a RFQ Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQLOADOCFORAPPROVAL', 27003003, 'Approval of a RFQ LOA Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003003, 'Approval of a RFQ Comparision document is requested.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003003, 'An approval request for a RFQ Comparision document is canceled.', 0, 'RFLOADOCCODETXT', false, false, CreateGuid());
    end;

    local procedure CheckAndInsertWorkflowEvent(FunctionName: Code[128]; TableID: Integer; Desc: Text[250]; RequestPageID: Integer;
                                        DynamicReqPageEntityName: Code[20]; UsedforRecordChange: Boolean; Indepnt: Boolean; SysId: Guid)
    var
        WorkflowEvent: Record "Workflow Event";
    begin
        with WorkflowEvent do begin
            if not Get(FunctionName) then begin
                Init();
                "Function Name" := FunctionName;
                "Table ID" := TableID;
                Description := Desc;
                "Request Page ID" := RequestPageID;
                "Dynamic Req. Page Entity Name" := DynamicReqPageEntityName;
                "Used for Record Change" := UsedforRecordChange;
                Independent := Indepnt;
                SystemId := SysId;
                Insert(true);
            end;
        end;
    end;

    local procedure InsertWorkflowTableRelation()
    begin
        CheckAndInsertWorkflowTableRelation(27003003, 0, 454, 22, CreateGuid());
    end;

    local procedure CheckAndInsertWorkflowTableRelation(TableID: Integer; FieldID: Integer; RelatedTableID: Integer; RelatedFieldID: Integer; SysId: Guid)
    var
        WorkflowTableRelation: Record "Workflow - Table Relation";
    begin
        with WorkflowTableRelation do begin
            if not Get(TableID, FieldID, RelatedTableID, RelatedFieldID) then begin
                Init();
                "Table ID" := TableID;
                "Field ID" := FieldID;
                "Related Table ID" := RelatedTableID;
                "Related Field ID" := RelatedFieldID;
                SystemId := SysId;
                Insert(true);
            end;
        end;
    end;

}