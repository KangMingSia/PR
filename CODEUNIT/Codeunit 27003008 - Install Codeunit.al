codeunit 27003008 "Install Code Unit-IBIZPR"
{
    Subtype = Install;
    trigger OnInstallAppPerCompany()
    begin
        InsertWorkflowEvent();
        InsertWorkflowTableRelation();
        // InsertPurchaseAccount()
    end;

    local procedure InsertPurchaseAccount()
    var
        lGeneralPostingSetup: Record "General Posting Setup";
        lPurchaseLine: Record "Purchase Line";
        lPRLine: Record "PR Line";
        lItem: Record Item;
    begin
        lPurchaseLine.Reset();
        lPurchaseLine.SetRange("G/L Account No.", '');
        if lPurchaseLine.FindSet() then
            repeat
                if lPurchaseLine.Type = lPurchaseLine.Type::"G/L Account" then
                    lPurchaseLine."G/L Account No." := lPurchaseLine."No."
                else
                    if lPurchaseLine.Type = lPurchaseLine.Type::Item then
                        if lGeneralPostingSetup.Get(lPurchaseLine."Gen. Bus. Posting Group", lPurchaseLine."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            lPurchaseLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end;
                lPurchaseLine.Modify(false);
            until lPurchaseLine.Next() = 0;

        lPRLine.Reset();
        lPRLine.SetRange("Gen. Prod. Posting Group", '');
        lPRLine.SetRange(lPRLine.Type, lPRLine.Type::Item);
        if lPRLine.FindSet() then
            repeat
                if lItem.Get(lPRLine."No.") then;
                lPRLine."Gen. Prod. Posting Group" := lItem."Gen. Prod. Posting Group";
                if lGeneralPostingSetup.Get('', lPRLine."Gen. Prod. Posting Group") then begin
                    // lGeneralPostingSetup.TestField("Purch. Account");
                    lPRLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                end;
                lPRLine.Modify(false);
            until lPRLine.Next() = 0;

        lPRLine.Reset();
        lPRLine.SetRange("G/L Account No.", '');
        if lPRLine.FindSet() then
            repeat
                if lPRLine.Type = lPRLine.Type::"G/L Account" then
                    lPRLine."G/L Account No." := lPRLine."No."
                else
                    if lPRLine.Type = lPRLine.Type::Item then
                        if lGeneralPostingSetup.Get('', lPRLine."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            lPRLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end;
                lPRLine.Modify(false);
            until lPRLine.Next() = 0;
    end;

    local procedure InsertWorkflowEvent()
    begin
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASEPRDOC', 27003012, 'A PR document is released.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASEPRLOADOC', 27003012, 'A PR LOA document is released.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELPRAPPROVALREQUEST', 27003012, 'An approval request for a PR document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELPRLOAAPPROVALREQUEST', 27003012, 'An approval request for a PR LOA document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDPRDOCFORAPPROVAL', 27003012, 'Approval of a PR document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDPRLOADOCFORAPPROVAL', 27003012, 'Approval of a PR LOA document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003012, 'Approval of a RFQ document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003012, 'An approval request for a RFQ document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
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
        CheckAndInsertWorkflowTableRelation(27003012, 0, 454, 22, CreateGuid());
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
codeunit 27003009 "Update Code Unit"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    begin
        InsertWorkflowEvent();
        InsertWorkflowTableRelation();
        // InsertPurchaseAccount();
    end;

    local procedure InsertPurchaseAccount()
    var
        lGeneralPostingSetup: Record "General Posting Setup";
        lPurchaseLine: Record "Purchase Line";
        lPRLine: Record "PR Line";
        lPRHeader: Record "PR Header";
        lItem: Record Item;
    begin
        lPurchaseLine.Reset();
        lPurchaseLine.SetRange("G/L Account No.", '');
        if lPurchaseLine.FindSet() then
            repeat
                if lPurchaseLine.Type = lPurchaseLine.Type::"G/L Account" then
                    lPurchaseLine."G/L Account No." := lPurchaseLine."No."
                else
                    if lPurchaseLine.Type = lPurchaseLine.Type::Item then
                        if lGeneralPostingSetup.Get(lPurchaseLine."Gen. Bus. Posting Group", lPurchaseLine."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            lPurchaseLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end;
                lPurchaseLine.Modify(false);
            until lPurchaseLine.Next() = 0;

        lPRLine.Reset();
        lPRLine.SetRange("Gen. Prod. Posting Group", '');
        lPRLine.SetRange(lPRLine.Type, lPRLine.Type::Item);
        if lPRLine.FindSet() then
            repeat
                if lItem.Get(lPRLine."No.") then;
                lPRLine."Gen. Prod. Posting Group" := lItem."Gen. Prod. Posting Group";
                lPRHeader.Reset();
                lPRHeader.SetRange("No.", lPRLine."Document No.");
                if lPRHeader.FindFirst() then
                    if lGeneralPostingSetup.Get(lPRHeader."Suggested Vendor", lPRLine."Gen. Prod. Posting Group") then begin
                        // lGeneralPostingSetup.TestField("Purch. Account");
                        lPRLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                    end;
                lPRLine.Modify(false);
            until lPRLine.Next() = 0;

        lPRLine.Reset();
        lPRLine.SetRange("G/L Account No.", '');
        if lPRLine.FindSet() then
            repeat
                if lPRLine.Type = lPRLine.Type::"G/L Account" then
                    lPRLine."G/L Account No." := lPRLine."No."
                else
                    if lPRLine.Type = lPRLine.Type::Item then
                        if lGeneralPostingSetup.Get('', lPRLine."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            lPRLine."G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end;
                lPRLine.Modify(false);
            until lPRLine.Next() = 0;
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
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASEPRDOC', 27003012, 'A PR document is released.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONAFTERRELEASEPRLOADOC', 27003012, 'A PR LOA document is released.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELPRAPPROVALREQUEST', 27003012, 'An approval request for a PR document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELPRLOAAPPROVALREQUEST', 27003012, 'An approval request for a PR LOA document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDPRDOCFORAPPROVAL', 27003012, 'Approval of a PR document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDPRLOADOCFORAPPROVAL', 27003012, 'Approval of a PR LOA document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONSENDRFQDOCFORAPPROVAL', 27003012, 'Approval of a RFQ document is requested.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
        CheckAndInsertWorkflowEvent('RUNWORKFLOWONCANCELRFQAPPROVALREQUEST', 27003012, 'An approval request for a RFQ document is canceled.', 0, 'PRLOADOCUMENTCODETXT', false, false, CreateGuid());
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
        CheckAndInsertWorkflowTableRelation(27003012, 0, 454, 22, CreateGuid());
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

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", 'OnUpdateUserSettings', '', true, true)]
    // local procedure OnUpdateUserSettings()
    // begin
    //     Message('1');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"User Settings", 'OnAfterQueryClosePage', '', true, true)]
    // local procedure OnAfterQueryClosePage()
    // begin
    //     Message('2');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'GetGlobalTableTriggerMask', '', true, true)]
    // local procedure GetGlobalTableTriggerMask()
    // begin
    //     Message('7');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'GetDatabaseTableTriggerSetup', '', true, true)]
    // local procedure GetDatabaseTableTriggerSetup()
    // begin
    //     Message('3');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Log Management", 'OnAfterIsAlwaysLoggedTable', '', true, true)]
    // local procedure OnAfterIsAlwaysLoggedTable()
    // begin
    //     Message('4');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnGetIntegrationDisabled', '', true, true)]
    // local procedure OnGetIntegrationDisabled()
    // begin
    //     Message('5');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Integration Management", 'OnGetIntegrationEnabledOnSystem', '', true, true)]
    // local procedure OnGetIntegrationEnabledOnSystem()
    // begin
    //     Message('6');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', true, true)]
    // procedure OnCompanyOpen()
    // begin
    //     Message('Company Open');
    // end;

    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyClose', '', true, true)]
    // procedure OnCompanyClose()
    // begin
    //     Message('Company Close')
    // end;
}