report 27003003 "Create Workflow Table Entry"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/Create Workflow Table Entry.rdlc';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            trigger OnAfterGetRecord();
            var
                WorkflowTableRelation: Record "Workflow - Table Relation";
            begin
                WorkflowTableRelation.SetRange("Table ID", Database::"PR Header");
                WorkflowTableRelation.SetRange("Field ID", 0);
                WorkflowTableRelation.SetRange("Related Table ID", Database::"Approval Entry");
                WorkflowTableRelation.SetRange("Related Field ID", 22);
                if not WorkflowTableRelation.FindFirst() then begin
                    WorkflowTableRelation.Init();
                    WorkflowTableRelation."Table ID" := Database::"PR Header";
                    WorkflowTableRelation."Field ID" := 0;
                    WorkflowTableRelation."Related Table ID" := Database::"Approval Entry";
                    WorkflowTableRelation."Related Field ID" := 22;
                    WorkflowTableRelation.SystemId := CreateGuid();
                    WorkflowTableRelation.Insert(true);
                end;
            end;
        }
    }

}