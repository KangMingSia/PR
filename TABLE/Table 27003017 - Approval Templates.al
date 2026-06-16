table 27003017 "Approval Templates"
{

    Caption = 'Approval Templates';

    fields
    {
        field(1; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            Editable = false;
        }
        field(2; "Approval Code"; Code[20])
        {
            Caption = 'Approval Code';
            TableRelation = "Approval Code".Code;

            trigger OnValidate();
            begin
                TESTFIELD(Enabled, false);
                ApprCode.GET("Approval Code");
                ApprCode.TESTFIELD("Linked To Table No.");
                "Table ID" := ApprCode."Linked To Table No.";
            end;
        }
        // field(3; "Approval Type"; Option)//Version 19.0.0.0>>
        field(3; "Approval Type"; Enum "Workflow Approval Type")//Version 19.0.0.0>>
        {
            Caption = 'Approval Type';
            // OptionCaption = '" ,Sales Pers./Purchaser,Approver"';//Version 19.0.0.0>>
            // OptionMembers = " ","Sales Pers./Purchaser",Approver;//Version 19.0.0.0>>

            trigger OnValidate();
            begin
                TESTFIELD(Enabled, false);
            end;
        }
        field(4; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,None,,,,,PR,RFQC';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","None",,,,,PR,RFQC;

            trigger OnValidate();
            begin
                TESTFIELD(Enabled, false);
            end;
        }

        // field(5; "Limit Type"; Option)//Version 19.0.0.0>>
        field(5; "Limit Type"; Enum "Workflow Approval Limit Type")//Version 19.0.0.0>>
        {
            Caption = 'Limit Type';
            // OptionCaption = 'Approval Limits,Credit Limits,Request Limits,No Limits';//Version 19.0.0.0>>
            // OptionMembers = "Approval Limits","Credit Limits","Request Limits","No Limits";//Version 19.0.0.0>>

            trigger OnValidate();
            begin
                TESTFIELD(Enabled, false);
            end;
        }
        field(6; "Additional Approvers"; Boolean)
        {
            CalcFormula = Exist("Additional Approvers" WHERE("Approval Code" = FIELD("Approval Code"),
                                                              "Approval Type" = FIELD("Approval Type"),
                                                              "Document Type" = FIELD("Document Type"),
                                                              "Limit Type" = FIELD("Limit Type"),
                                                              "Approver ID" = FILTER(<> '')));
            Caption = 'Additional Approvers';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; Enabled; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate();
            var
                Salesheader: Record "Sales Header";
                PurchaseHeader: Record "Purchase Header";
                ApprovalEntry: Record "Approval Entry";
                TempApprovalTemplate: Record "Approval Templates";
            begin
                if (Enabled = false) and (xRec.Enabled = true) then begin
                    TempApprovalTemplate.SETRANGE("Approval Code", "Approval Code");
                    TempApprovalTemplate.SETRANGE("Document Type", "Document Type");
                    if not TempApprovalTemplate.FINDFIRST then
                        case "Table ID" of
                            DATABASE::"Sales Header":
                                begin
                                    Salesheader.SETCURRENTKEY("Document Type", Status);
                                    Salesheader.SETRANGE("Document Type", "Document Type");
                                    Salesheader.SETRANGE(Status, Salesheader.Status::"Pending Approval");
                                    if Salesheader.FINDFIRST then begin
                                        if CONFIRM(Text006) then begin
                                            ApprovalEntry.SETRANGE("Table ID", DATABASE::"Sales Header");
                                            ApprovalEntry.SETRANGE("Document Type", "Document Type");
                                            ApprovalEntry.SETFILTER(
                                              Status, '%1|%2|%3', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open, ApprovalEntry.Status::Approved);
                                            if ApprovalEntry.FINDFIRST then
                                                ApprovalEntry.MODIFYALL(Status, ApprovalEntry.Status::Canceled);
                                        end;
                                        Salesheader.MODIFYALL(Status, Salesheader.Status::Open);
                                    end;
                                end;
                            DATABASE::"Purchase Header":
                                begin
                                    PurchaseHeader.SETCURRENTKEY("Document Type", Status);
                                    PurchaseHeader.SETRANGE("Document Type", "Document Type");
                                    PurchaseHeader.SETRANGE(Status, PurchaseHeader.Status::"Pending Approval");
                                    if PurchaseHeader.FINDFIRST then begin
                                        if CONFIRM(Text006) then begin
                                            ApprovalEntry.SETRANGE("Table ID", DATABASE::"Purchase Header");
                                            ApprovalEntry.SETRANGE("Document Type", "Document Type");
                                            ApprovalEntry.SETFILTER(
                                              Status, '%1|%2|%3', ApprovalEntry.Status::Created, ApprovalEntry.Status::Open, ApprovalEntry.Status::Approved);
                                            if ApprovalEntry.FINDFIRST then
                                                ApprovalEntry.MODIFYALL(Status, ApprovalEntry.Status::Canceled);
                                        end;
                                        PurchaseHeader.MODIFYALL(Status, Salesheader.Status::Open);
                                    end;
                                end;
                        end;
                end;

                if "Approval Type" = "Approval Type"::" " then begin
                    CALCFIELDS("Additional Approvers");
                    if not "Additional Approvers" and Enabled then
                        ERROR(STRSUBSTNO(Text005, FIELDCAPTION("Approval Type")));
                end;
                if ("Approval Type" <> "Approval Type"::" ") and ("Limit Type" = "Limit Type"::"Credit Limits") then begin
                    CALCFIELDS("Additional Approvers");
                    if not "Additional Approvers" and Enabled then
                        ERROR(STRSUBSTNO(Text007, FIELDCAPTION("Approval Type"), FORMAT("Approval Type"),
                            FIELDCAPTION("Limit Type")));
                end;
            end;
        }
        field(90000; "Approval Routing"; Code[20])
        {
            Description = 'PR1.0';
        }
        field(90001; "No. series"; Code[20])
        {
            Description = 'PR1.0';
            TableRelation = "No. Series";
            ValidateTableRelation = false;
        }
        field(90002; "Direct Approver"; Boolean)
        {
            Description = 'PR1.0';
        }
        field(90003; "PR to PO Amount Limit"; Decimal)
        {
            Description = 'PR1.0';
        }
        field(90004; "Petty Cash Limit"; Decimal)
        {
            Description = 'PR1.0';
        }
        field(90005; "LOA Approval"; Boolean)
        {
            Description = 'PR1.0';
        }
    }

    keys
    {
        key(Key1; "Approval Code", "Approval Type", "Document Type", "Limit Type", "Approval Routing")
        {
        }
        key(Key2; "Table ID", "Approval Type", Enabled)
        {
        }
        key(Key3; "Approval Code", "Approval Type", Enabled)
        {
        }
        key(Key4; Enabled)
        {
        }
        key(Key5; "Limit Type", "Document Type", "Approval Type", Enabled)
        {
        }
        key(Key6; "Table ID", "Document Type", Enabled)
        {
        }
    }

    trigger OnDelete();
    begin
        AdditionalApprovers.SETRANGE("Approval Code", "Approval Code");
        AdditionalApprovers.SETRANGE("Approval Type", "Approval Type");
        AdditionalApprovers.SETRANGE("Document Type", "Document Type");
        AdditionalApprovers.SETRANGE("Limit Type", "Limit Type");
        AdditionalApprovers.DELETEALL;
    end;

    trigger OnInsert();
    begin
        TestValidation;
    end;

    trigger OnRename();
    begin
        TestValidation;
        RenameAddApprovers(Rec, xRec);
    end;

    var
        ApprCode: Record "Approval Code";
        AdditionalApprovers: Record "Additional Approvers";
        Text001: Label '%1 is not a valid limit type for table %2.';
        Text002: Label '%1 is only valid for table %2.';
        Text004: Label '%1 is only valid when document type is Quote and Table ID is %2.';
        Text005: Label 'Additional Approvers must be inserted if %1 is blank.';
        Text006: Label '"Do you want to cancel all outstanding approvals? "';
        Text007: Label 'Additional Approvers must be inserted if %1 is %2 and %3 is Credit Limit.';

    procedure TestValidation();
    var
        AppSetup: Record "Approval Setup";
    begin
        AppSetup.GET;
        if ("Table ID" = DATABASE::"Purchase Header") and
           ("Limit Type" = "Limit Type"::"Credit Limits")
        then
            ERROR(STRSUBSTNO(Text001, FORMAT("Limit Type"), DATABASE::"Purchase Header"));

        if ("Table ID" <> DATABASE::"Purchase Header") and
           ("Limit Type" = "Limit Type"::"Request Limits")
        then
            ERROR(STRSUBSTNO(Text002, FORMAT("Limit Type"), DATABASE::"Purchase Header"));

        if ("Table ID" = DATABASE::"Purchase Header") and
           ("Limit Type" = "Limit Type"::"Request Limits") and
           ("Document Type" <> "Document Type"::Quote)
        then
            ERROR(STRSUBSTNO(Text004, FORMAT("Limit Type"), "Table ID"));
    end;

    procedure RenameAddApprovers(Template: Record "Approval Templates"; xTemplate: Record "Approval Templates");
    var
        AddApprovers: Record "Additional Approvers";
        RenamedAddApprovers: Record "Additional Approvers";
    begin
        AddApprovers.SETRANGE("Approval Code", xTemplate."Approval Code");
        AddApprovers.SETRANGE("Approval Type", xTemplate."Approval Type");
        AddApprovers.SETRANGE("Document Type", xTemplate."Document Type");
        AddApprovers.SETRANGE("Limit Type", xTemplate."Limit Type");
        if AddApprovers.FIND('-') then
            repeat
                RenamedAddApprovers := AddApprovers;
                RenamedAddApprovers."Approval Code" := Template."Approval Code";
                RenamedAddApprovers."Approval Type" := Template."Approval Type";
                RenamedAddApprovers."Document Type" := Template."Document Type";
                RenamedAddApprovers."Limit Type" := Template."Limit Type";
                AddApprovers.DELETE;
                RenamedAddApprovers.INSERT;
            until AddApprovers.NEXT = 0;
    end;
}

