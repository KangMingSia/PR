table 27003016 "Additional Approvers"
{
    Caption = 'Additional Approvers';

    fields
    {
        field(1; "Approval Code"; Code[20])
        {
            Caption = 'Approval Code';
            TableRelation = "Approval Templates"."Approval Code";
        }
        field(2; "Approver ID"; Code[50])
        {
            Caption = 'Approver ID';
            TableRelation = "User Setup"."User ID";

            trigger OnValidate();
            var
                AddAppr: Record "Additional Approvers";
                ApprTemplate: Record "Approval Templates";
            begin
                AddAppr.SETRANGE("Approval Code", "Approval Code");
                AddAppr.SETRANGE("Approval Type", "Approval Type");
                AddAppr.SETRANGE("Document Type", "Document Type");
                AddAppr.SETRANGE("Limit Type", "Limit Type");
                if "Approver ID" <> '' then begin
                    AddAppr.SETRANGE("Approver ID", "Approver ID");
                    if AddAppr.FINDFIRST then
                        ERROR(STRSUBSTNO(Text001, AddAppr."Approver ID"));
                end else begin
                    AddAppr.SETFILTER("Approver ID", '<>%1&<>%2', '', xRec."Approver ID");
                    if not AddAppr.FINDFIRST then
                        if ApprTemplate.GET("Approval Code", "Approval Type", "Document Type", "Limit Type") then
                            if ((ApprTemplate."Approval Type" = ApprTemplate."Approval Type"::" ") or
                                (ApprTemplate."Limit Type" = ApprTemplate."Limit Type"::"Credit Limits")) and ApprTemplate.Enabled
                            then
                                if CONFIRM(STRSUBSTNO(Text002, AddAppr.TABLECAPTION)) then begin
                                    ApprTemplate.VALIDATE(Enabled, false);
                                    ApprTemplate.MODIFY;
                                end else
                                    ERROR('');
                end;
            end;
        }

        // field(3; "Approval Type"; Option)//Version 19.0.0.0>>
        field(3; "Approval Type"; Enum "Workflow Approval Type")//Version 19.0.0.0>>
        {
            Caption = 'Approval Type';
            // OptionCaption = '" ,Sales Pers./Purchaser,Approver"';//Version 19.0.0.0>>
            // OptionMembers = " ","Sales Pers./Purchaser",Approver;//Version 19.0.0.0>>
        }
        field(4; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,None';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","None";
        }
        // field(5; "Limit Type"; Option)//Version 19.0.0.0>>
        field(5; "Limit Type"; Enum "Workflow Approval Limit Type")//Version 19.0.0.0>>
        {
            Caption = 'Limit Type';
            Editable = false;
            // OptionCaption = 'Approval Limits,Credit Limits,Request Limits,No Limits';//Version 19.0.0.0>>
            // OptionMembers = "Approval Limits","Credit Limits","Request Limits","No Limits";//Version 19.0.0.0>>
        }
        field(6; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Approver ID", "Approval Code", "Approval Type", "Document Type", "Limit Type", "Sequence No.")
        {
        }
        key(Key2; "Sequence No.")
        {
        }
    }

    trigger OnDelete();
    var
        AddAppr: Record "Additional Approvers";
        ApprTemplate: Record "Approval Templates";
    begin
        AddAppr.SETRANGE("Approval Code", "Approval Code");
        AddAppr.SETRANGE("Approval Type", "Approval Type");
        AddAppr.SETRANGE("Document Type", "Document Type");
        AddAppr.SETRANGE("Limit Type", "Limit Type");
        AddAppr.SETFILTER("Approver ID", '<>%1&<>%2', '', "Approver ID");
        if not AddAppr.FINDFIRST then
            if ApprTemplate.GET("Approval Code", "Approval Type", "Document Type", "Limit Type") then
                if ((ApprTemplate."Approval Type" = ApprTemplate."Approval Type"::" ") or
                    (ApprTemplate."Limit Type" = ApprTemplate."Limit Type"::"Credit Limits")) and ApprTemplate.Enabled
                then
                    if CONFIRM(STRSUBSTNO(Text002, AddAppr.TABLECAPTION)) then begin
                        ApprTemplate.VALIDATE(Enabled, false);
                        ApprTemplate.MODIFY;
                    end else
                        ERROR('');
    end;

    var
        Text001: Label 'Approver ID %1 is already an additional approver on this template.';
        Text002: Label 'The approval template will be disabled because no %1 are available.\Do you want to continue?';
}

