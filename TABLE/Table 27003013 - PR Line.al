table 27003013 "PR Line"
{

    fields
    {
        field(1; "Document No."; Code[20])
        {
            TableRelation = "PR Header"."No.";
        }
        field(2; "Line No."; Integer)
        {
        }
        // field(3; Type; Option)
        // {
        //     OptionCaption = 'Item,G/L Account,Description,Fixed Asset';
        //     OptionMembers = Item,"G/L Account",Description,"Fixed Asset";
        //     trigger OnValidate();
        //     begin
        //         TESTFIELD(Status, Status::Open);
        //         if Type = Type::Description then begin
        //             VALIDATE("Unit Cost", 0);
        //             VALIDATE(Quantity, 0);
        //         end;
        //     end;
        // }
        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
            ValuesAllowed = 0, 1, 2;
            trigger OnValidate()
            begin
                TESTFIELD(Status, Status::Open);
                if Type = Type::" " then begin
                    VALIDATE("Unit Cost", 0);
                    VALIDATE(Quantity, 0);
                end;
            end;
        }

        field(4; "No."; Code[20])
        {
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account"."No." WHERE("Show in PR" = CONST(true))
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            // IF (Type = CONST(Description)) "Standard Text"//19.0.0.5
            IF (Type = CONST(" ")) "Standard Text"//19.0.0.5
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";

            trigger OnValidate();
            var
                lGeneralPostingSetup: Record "General Posting Setup"; //19.0.0.4>>
                lVendor: Record Vendor;
                lItem: Record Item;
                lPRHeader: Record "PR Header";
            begin
                TESTFIELD(Status, Status::Open);
                GETPRHeader;

                // "Shortcut Dimension 1 Code" := PRHeader."Shortcut Dimension 1 Code";
                // "Shortcut Dimension 2 Code" := PRHeader."Shortcut Dimension 2 Code";
                validate("Shortcut Dimension 1 Code", PRHeader."Shortcut Dimension 1 Code");
                validate("Shortcut Dimension 2 Code", PRHeader."Shortcut Dimension 2 Code");
                if Type = Type::Item then begin
                    if LItem.GET("No.") then begin
                        Description := LItem.Description;
                        Validate("Shortcut Dimension 1 Code", LItem."Global Dimension 1 Code");
                        Validate("Shortcut Dimension 2 Code", LItem."Global Dimension 2 Code");
                        "Unit of  Measure" := LItem."Purch. Unit of Measure";
                    end;
                end else
                    if Type = Type::"G/L Account" then begin
                        if GLAccount.GET("No.") then
                            Description := GLAccount.Name;
                        "VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
                        "VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";

                    end else
                        if Type = Type::"Fixed Asset" then begin
                            if FixedAsset.GET("No.") then
                                Description := FixedAsset.Description;
                            VALIDATE("Shortcut Dimension 1 Code", FixedAsset."Global Dimension 1 Code");
                        end;
                "WBS ID" := PRHeader."WBS ID";
                "Due Date" := PRHeader."Due Date";
                "Delivery Location" := PRHeader."Delivery Location";
                "PR Status" := PRHeader."PR Status";
                "PR Document Type" := PRHeader."PR Document Type";
                "PR No" := PRHeader."No.";
                //19.0.0.4>>
                if Rec.Type = Rec.Type::"G/L Account" then
                    "G/L Account No." := Rec."No."
                else
                    if Rec.Type = Rec.Type::Item then begin
                        if lPRHeader.Get(Rec."Document No.") then
                            if lVendor.get(lPRHeader."Suggested Vendor") then
                                Rec."Gen. Bus. Posting Group" := lVendor."Gen. Bus. Posting Group";

                        if lItem.get(Rec."No.") then
                            Rec."Gen. Prod. Posting Group" := lItem."Gen. Prod. Posting Group";

                        if lGeneralPostingSetup.Get(Rec."Gen. Bus. Posting Group", Rec."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            "G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end else begin
                            Error('General posting setup not found Gen. Bus. Posting Group:%1 and Gen. Prod. Posting Group:%2', Rec."Gen. Bus. Posting Group", Rec."Gen. Prod. Posting Group");
                        end;
                    end;
                //19.0.0.4>>
                CheckBudgetCurrentLine(Rec."Document No.");
            end;
        }
        field(5; Description; Text[50])
        {

            trigger OnValidate();
            begin
                GETPRHeader;
                "Shortcut Dimension 1 Code" := PRHeader."Shortcut Dimension 1 Code";
                "Shortcut Dimension 2 Code" := PRHeader."Shortcut Dimension 2 Code";
            end;
        }
        field(6; Quantity; Decimal)
        {
            BlankZero = true;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                // if Type = Type::Description then//19.0.0.5
                if Type = Type::" " then//19.0.0.5
                    Quantity := 0;

                Amount := Quantity * "Unit Cost";
            end;
        }
        field(7; "Unit of  Measure"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(8; "Due Date"; Date) { }
        field(9; "Delivery Location"; Code[10])
        {
            TableRelation = Location;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(10; "PR Status"; Option)
        {
            OptionCaption = 'PR,RFQ,Order,Cancel,Closed';
            OptionMembers = PR,RFQ,"Order",Cancel,Closed;
        }
        field(11; "Available Quantity"; Decimal)
        {
            BlankZero = true;
            CalcFormula = Sum("Item Ledger Entry".Quantity WHERE("Item No." = FIELD("No."),
                                                                  "Location Code" = FIELD("Delivery Location")));
            FieldClass = FlowField;
        }
        field(12; "PR Document Type"; Option)
        {
            OptionCaption = 'RFQ,PO,PC';
            OptionMembers = RFQ,PO,PC;
        }
        field(13; "PR No"; Code[20]) { }
        field(14; "Unit Cost"; Decimal)
        {
            BlankZero = true;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                // if Type = Type::Description then//19.0.0.5
                if Type = Type::" " then//19.0.0.5
                    "Unit Cost" := 0;
                Amount := Quantity * "Unit Cost";
                GETPRHeader;
                if PRHeader."PR Date" <> 0D then
                    GetDate := PRHeader."PR Date"
                else
                    GetDate := WORKDATE;

                if PRHeader."Currency Code" <> '' then begin
                    PRHeader.TESTFIELD("Currency Factor");
                    "Unit Cost (LCY)" :=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GetDate, PRHeader."Currency Code",
                        "Unit Cost", PRHeader."Currency Factor");
                end else
                    "Unit Cost (LCY)" := "Unit Cost";

                "Amount (LCY)" := Quantity * "Unit Cost (LCY)";
            end;
        }
        field(15; Amount; Decimal)
        {
            BlankZero = true;

            trigger OnValidate();
            begin
                // if Type = Type::Description then//19.0.0.5
                if Type = Type::" " then//19.0.0.5
                    CLEAR(Amount);
            end;
        }
        field(16; Status; Option)
        {
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";
        }
        field(17; "Description 2"; Text[50]) { }
        field(18; Remarks; Text[250]) { }
        field(19; "Suggested Supplier"; Code[20]) { }
        field(20; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");

                if Rec."Shortcut Dimension 1 Code" <> xRec."Shortcut Dimension 1 Code" then
                    CheckBudget("Document No.");
            end;
        }
        field(21; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");

                if Rec."Shortcut Dimension 2 Code" <> xRec."Shortcut Dimension 2 Code" then
                    CheckBudget("Document No.");
            end;
        }
        field(22; "Expected Receipt Date"; Date) { }
        field(23; "Qty Received"; Decimal) { BlankZero = true; }
        field(24; "No. of RFQ"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("Purchase Line" WHERE("PR No." = FIELD("Document No."),
                                                       "PR Line No." = FIELD("Line No."),
                                                       "Document Type" = FILTER(Quote)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "No. of PO"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("Purchase Line" WHERE("Document Type" = FILTER(Order),
                                                       "PR No." = FIELD("Document No."),
                                                       "PR Line No." = FIELD("Line No."),
                                                       "Document No." = FIELD("PO No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; Select; Boolean) { }
        field(27; ConvertedtoQuote; Boolean) { }
        field(28; "Quantity Converted to PO"; Decimal) { Editable = false; }
        field(29; "WBS ID"; Code[50])
        {
            TableRelation = "Budget Import"."WBS ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(30; "Activity ID"; Code[20])
        {
            TableRelation = "Budget Import"."Activity ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"),
                                                                 "WBS ID" = FIELD("WBS ID"));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(31; "Available Budget"; Decimal) { BlankZero = true; Editable = false; }
        field(32; ConvertedtoOrder; Boolean) { }
        field(33; "Reason for Shortlist"; Text[250]) { }
        field(34; "On Hold"; Decimal) { BlankZero = true; }
        field(35; Utilised; Decimal) { BlankZero = true; }
        field(36; "Unit Cost (LCY)"; Decimal) { AutoFormatType = 2; BlankZero = true; Caption = 'Unit Cost (LCY)'; }
        field(37; "Amount (LCY)"; Decimal) { BlankZero = true; }
        field(38; "PO No."; Code[20]) { }
        field(74; "Gen. Bus. Posting Group"; Code[20])
        {
            Caption = 'Gen. Bus. Posting Group';
            TableRelation = "Gen. Business Posting Group";

            trigger OnValidate()
            var
                GenBusPostingGrp: Record "Gen. Business Posting Group";
                GenProdPostingGrp: Record "Gen. Product Posting Group";
            begin
                if xRec."Gen. Bus. Posting Group" <> "Gen. Bus. Posting Group" then
                    if GenBusPostingGrp.ValidateVatBusPostingGroup(GenBusPostingGrp, "Gen. Bus. Posting Group") then
                        Validate("VAT Bus. Posting Group", GenBusPostingGrp."Def. VAT Bus. Posting Group");
            end;
        }
        field(75; "Gen. Prod. Posting Group"; Code[20])
        {
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";

            trigger OnValidate()
            var
                GenBusPostingGrp: Record "Gen. Business Posting Group";
                GenProdPostingGrp: Record "Gen. Product Posting Group";
            begin
                // TestStatusOpen();
                TESTFIELD(Status, Status::Open);
                if xRec."Gen. Prod. Posting Group" <> "Gen. Prod. Posting Group" then
                    if GenProdPostingGrp.ValidateVatProdPostingGroup(GenProdPostingGrp, "Gen. Prod. Posting Group") then
                        Validate("VAT Prod. Posting Group", GenProdPostingGrp."Def. VAT Prod. Posting Group");
            end;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDimensions;
            end;

            trigger OnValidate()
            begin
                UpdatehortcutDimension("Dimension Set ID");
            end;
        }
        field(481; "Suggested Vendor"; Code[20])
        {
            TableRelation = Vendor."No.";
            ValidateTableRelation = true;

            trigger OnValidate();
            begin
                TESTFIELD("PR Status", "PR Status"::PR);
            end;
        }
        field(50000; "VAT Bus. Posting Group"; Code[10])
        {
            Caption = 'GST Bus. Posting Group';
            TableRelation = "VAT Business Posting Group";
        }
        field(50001; "VAT Prod. Posting Group"; Code[10])
        {
            Caption = 'GST Prod. Posting Group';
            TableRelation = "VAT Product Posting Group";
        }
        field(50002; "GST Scenario Code"; Code[20])
        {
            Description = 'GST1.00';

            trigger OnLookup();
            begin
                if Type = Type::"G/L Account" then begin
                    CLEAR(rTempGSTScenario);
                    rTempGSTScenario.DELETEALL;
                    LookupGSTScenario;
                end;
            end;

            trigger OnValidate();
            begin
                rGSTScenario.RESET;
                rGSTScenario.SETRANGE("GST Scenario Code", "GST Scenario Code");
                if rGSTScenario.FINDFIRST then begin
                    if rGSTScenario."No Tax Code" then begin
                        if rGSTScenario."GST Bus. Posting Group" <> '' then
                            VALIDATE("VAT Bus. Posting Group", rGSTScenario."GST Bus. Posting Group");
                        if rGSTScenario."GST Prod. Posting Group" <> '' then
                            VALIDATE("VAT Prod. Posting Group", rGSTScenario."GST Prod. Posting Group");
                    end else begin
                        VALIDATE("VAT Bus. Posting Group", rGSTScenario."GST Bus. Posting Group");
                        VALIDATE("VAT Prod. Posting Group", rGSTScenario."GST Prod. Posting Group");
                    end;
                end;
            end;
        }
        field(50003; "STD Purchase Code"; Code[20])
        {
            TableRelation = "Standard Purchase Code";

            trigger OnValidate();
            begin
                if StdPurchCode.GET("STD Purchase Code") then;
            end;
        }
        field(50004; "Category Code"; Code[30]) { }
        field(50005; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50006; "Shortcut Dimension 3 Code"; Code[20]) { FieldClass = Normal; }
        field(50007; "Shortcut Dimension 4 Code"; Code[20]) { FieldClass = Normal; }
        field(50008; "Shortcut Dimension 5 Code"; Code[20]) { FieldClass = Normal; }
        field(50009; "Shortcut Dimension 6 Code"; Code[20]) { FieldClass = Normal; }
        field(50010; "Shortcut Dimension 7 Code"; Code[20]) { FieldClass = Normal; }
        field(50011; "Shortcut Dimension 8 Code"; Code[20]) { FieldClass = Normal; }
        field(50012; "Article Code"; Code[50]) { FieldClass = Normal; }

    }

    keys
    {
        key(Key1; "Document No.", "Line No.")
        {
            SumIndexFields = Amount, "Available Budget", "Amount (LCY)";
        }
        key(Key2; "No.") { }
    }

    procedure UpdatehortcutDimension(lDimensionSetID: Integer)
    var
        lShortcutDimCode: array[8] of Code[20];
        GLSetup: Record "General Ledger Setup";
        lDimensionSetEntry: Record "Dimension Set Entry";
    begin
        GLSetup.Get();
        Clear(lShortcutDimCode);
        lShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        lShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        lShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        lShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        lShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        lShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        lShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        lShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[3]) then
            "Shortcut Dimension 3 Code" := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[4]) then
            "Shortcut Dimension 4 Code" := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[5]) then
            "Shortcut Dimension 5 Code" := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[6]) then
            "Shortcut Dimension 6 Code" := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[7]) then
            "Shortcut Dimension 7 Code" := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[8]) then
            "Shortcut Dimension 8 Code" := lDimensionSetEntry."Dimension Value Code";
    end;

    trigger OnDelete();
    var
        SuggestedVendor: Record "Suggested Vendor";
        LPurchaseRequisitonheader: Record "PR Header";
    begin
        CheckPRStatus;
        SuggestedVendor.RESET;
        SuggestedVendor.SETRANGE("Document Type", SuggestedVendor."Document Type"::"PR Line");
        SuggestedVendor.SETRANGE("PR No.", "Document No.");
        SuggestedVendor.SETRANGE("PR Line No.", "Line No.");
        if SuggestedVendor.FINDSET then
            SuggestedVendor.DELETEALL;
        CheckBudget(Rec."Document No.");
    end;

    trigger OnInsert();
    var
        LPurchaseRequisitonheader: Record "PR Header";
    begin
        CheckPRStatus;
        GETPRHeader;
        if PRHeader."Shortcut Dimension 1 Code" <> '' then
            VALIDATE("Shortcut Dimension 1 Code", PRHeader."Shortcut Dimension 1 Code");
        if PRHeader."Shortcut Dimension 2 Code" <> '' then
            VALIDATE("Shortcut Dimension 2 Code", PRHeader."Shortcut Dimension 2 Code");
        CheckBudget(Rec."Document No.");
    end;

    trigger OnModify();
    var
        LPurchaseRequisitonheader: Record "PR Header";
    begin
        CheckPRStatus;
        // CheckBudget(Rec."Document No.");
    end;

    //19.0.0.7>>
    // procedure GetDefaultLineType(): Enum "Purchase Line Type"
    // begin
    //     PurchSetup.Get();
    //     if PurchSetup."Document Default Line Type" <> PurchSetup."Document Default Line Type"::" " then
    //         exit(PurchSetup."Document Default Line Type");
    // end;

    // procedure SetDefaultType()
    // begin
    //     // if xRec."Document No." = '' then
    //     Type := GetDefaultLineType();
    // end;
    //19.0.0.7<<
    var
        PurchSetup: Record "Purchases & Payables Setup";
        LItem: Record Item;
        GLAccount: Record "G/L Account";
        FixedAsset: Record "Fixed Asset";
        PRHeader: Record "PR Header";
        CurrExchRate: Record "Currency Exchange Rate";
        GetDate: Date;
        AccountingPeriod: Record "Accounting Period";
        GText001: Label 'Budget not present for the Project ID :"  %1  ",WBS ID :"  %2 " and Activity ID : " %3 "';
        DimMgt: Codeunit DimensionManagement;
        Text049: Label 'You have changed one or more dimensions on the %1, which is already shipped. When you post the line with the changed dimension to General Ledger, amounts on the Inventory Interim account will be out of balance when reported per dimension.\\Do you want to keep the changed dimension?';
        Text050: Label 'Cancelled.';
        rGSTScenario: Record "GST Scenario";
        rTempGSTScenario: Record "GST Scenario" temporary;
        rGLScenario: Record "G/L Account Scenario";
        StdPurchCode: Record "Standard Purchase Code";

    procedure GETPRHeader();
    begin
        PRHeader.GET("Document No.");
    end;

    procedure ShowSuggestedvendor();
    var
        SuggestedVendor: Record "Suggested Vendor";
        GSugggestedVendorForm: Page "Suggested vendor";
    begin
        SuggestedVendor.SETRANGE("Document Type", SuggestedVendor."Document Type"::"PR Line");
        SuggestedVendor.SETRANGE("PR No.", "Document No.");
        SuggestedVendor.SETRANGE("PR Line No.", "Line No.");
        GSugggestedVendorForm.SETTABLEVIEW(SuggestedVendor);
        GSugggestedVendorForm.RUNMODAL;
    end;

    procedure ShowDimensions();
    begin
        "Dimension Set ID" :=
          DimMgt.EditDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2 %3', "PR Document Type", "Document No.", "Line No."));
        VerifyItemLineDim;
        DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
    end;

    local procedure VerifyItemLineDim();
    begin
        if ("Dimension Set ID" <> xRec."Dimension Set ID") and (Type = Type::Item) then
            if not CONFIRM(Text049, true, TABLECAPTION) then
                ERROR(Text050);
    end;

    procedure LookupGSTScenario(): Boolean
    begin
        if (Type = Type::"G/L Account") and ("No." <> '') then begin
            rGLScenario.RESET;
            rGLScenario.SETRANGE("G/L Account No.", "No.");
            if rGLScenario.FINDFIRST then
                repeat
                    rGSTScenario.RESET;
                    rGSTScenario.SETRANGE("GST Scenario Code", rGLScenario."GST Scenario");
                    if rGSTScenario.FINDFIRST then
                        repeat
                            rTempGSTScenario."GST Scenario Code" := rGSTScenario."GST Scenario Code";
                            rTempGSTScenario.Description := rGSTScenario.Description;
                            rTempGSTScenario."GST Prod. Posting Group" := rGSTScenario."GST Prod. Posting Group";
                            rTempGSTScenario."GST Bus. Posting Group" := rGSTScenario."GST Bus. Posting Group";
                            rTempGSTScenario."Gen. Posting Type" := rGSTScenario."Gen. Posting Type";
                            rTempGSTScenario."Bal. GST Prod. Posting Group" := rGSTScenario."Bal. GST Prod. Posting Group";
                            rTempGSTScenario."Bal. GST Bus. Posting Group" := rGSTScenario."Bal. GST Bus. Posting Group";
                            rTempGSTScenario."Bal. Posting Type" := rGSTScenario."Bal. Posting Type";
                            rTempGSTScenario."No Tax Code" := rGSTScenario."No Tax Code";
                            rTempGSTScenario.INSERT;
                        until rGSTScenario.NEXT = 0;
                until rGLScenario.NEXT = 0;
        end else begin
            rGSTScenario.RESET;
            if rGSTScenario.FINDFIRST then
                repeat
                    rTempGSTScenario."GST Scenario Code" := rGSTScenario."GST Scenario Code";
                    rTempGSTScenario.Description := rGSTScenario.Description;
                    rTempGSTScenario."GST Prod. Posting Group" := rGSTScenario."GST Prod. Posting Group";
                    rTempGSTScenario."GST Bus. Posting Group" := rGSTScenario."GST Bus. Posting Group";
                    rTempGSTScenario."Gen. Posting Type" := rGSTScenario."Gen. Posting Type";
                    rTempGSTScenario."Bal. GST Prod. Posting Group" := rGSTScenario."Bal. GST Prod. Posting Group";
                    rTempGSTScenario."Bal. GST Bus. Posting Group" := rGSTScenario."Bal. GST Bus. Posting Group";
                    rTempGSTScenario."Bal. Posting Type" := rGSTScenario."Bal. Posting Type";
                    rTempGSTScenario."No Tax Code" := rGSTScenario."No Tax Code";
                    rTempGSTScenario.INSERT;
                until rGSTScenario.NEXT = 0;
        end;

        CLEAR(rTempGSTScenario);
        rTempGSTScenario.SETCURRENTKEY("GST Scenario Code");
        if rTempGSTScenario.FIND('=><') then;
        if PAGE.RUNMODAL(PAGE::"GST Scenarios", rTempGSTScenario) = ACTION::LookupOK then begin
            VALIDATE("GST Scenario Code", rTempGSTScenario."GST Scenario Code");
            exit(true);
        end;
    end;

    local procedure CheckPRStatus();
    var
        LPurchaseRequisitonheader: Record "PR Header";
    begin
        LPurchaseRequisitonheader.RESET;
        LPurchaseRequisitonheader.SETRANGE("No.", "Document No.");
        if LPurchaseRequisitonheader.FINDFIRST then
            LPurchaseRequisitonheader.TESTFIELD(LPurchaseRequisitonheader.Status,
            LPurchaseRequisitonheader.Status::Open);
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
    end;

    procedure LookupShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.LookupDimValueCode(FieldNumber, ShortcutDimCode);
        ValidateShortcutDimCode(FieldNumber, ShortcutDimCode);
    end;

    local procedure GetPurchaseAccount(lType: Enum "Purchase Line Type"; lNo: code[20]; lVendorNo: Code[20]): Code[20]
    var
        lGeneralPostingSetup: Record "General Posting Setup";
        lVendor: Record Vendor;
        lItem: Record Item;
    begin
        if lType = lType::Item then begin
            if lItem.Get(lNo) then
                lItem.TestField("Gen. Prod. Posting Group");
            if lVendorNo <> '' then begin
                if lVendor.Get(lVendorNo) then
                    lVendor.TESTFIELD("Gen. Bus. Posting Group");
                if lGeneralPostingSetup.Get(lVendor."Gen. Bus. Posting Group", lItem."Gen. Prod. Posting Group") then
                    lGeneralPostingSetup.TestField("Purch. Account");
                exit(lGeneralPostingSetup."Purch. Account");
            end else
                if lGeneralPostingSetup.Get('', lItem."Gen. Prod. Posting Group") then
                    lGeneralPostingSetup.TestField("Purch. Account");
            exit(lGeneralPostingSetup."Purch. Account");
        end else
            if lType = lType::"G/L Account" then begin
                exit(lNo);
            end;
    end;

    local procedure GetUsedBudgetAmount(PurchaseAccount: Code[20]; lPRLine: Record "PR Line"; lStartDate: Date; lEndDate: Date): Decimal
    var
        lUsedBudgetAmount: Decimal;
        lGLAccount: Record "G/L Account";
        lGLAccount2: Record "G/L Account";
    begin
        lGLAccount.RESET();
        lGLAccount2.GET(PurchaseAccount);
        if lGLAccount2."Budget Link A/C" <> '' then
            lGLAccount.SETFILTER("No.", '%1|%2', lGLAccount2."No.", lGLAccount2."Budget Link A/C")
        else
            lGLAccount.SETRANGE("No.", lGLAccount2."No.");
        // lGLAccount.SETFILTER("Global Dimension 1 Filter", lPRLine."Shortcut dimension 1 code");//19.0.0.5
        // lGLAccount.SETFILTER("Global Dimension 2 Filter", lPRLine."Shortcut dimension 2 code");//19.0.0.5
        lGLAccount.SETFILTER("Date Filter", '%1..%2', lStartDate, lEndDate);
        // if lPRLine."Dimension Set ID" <> 0 then//19.0.0.5
        lGLAccount.SETFILTER("Dimension set ID Filter", '%1', lPRLine."Dimension Set ID");
        if lGLAccount.FINDSET then begin
            repeat
                lGLAccount.CALCFIELDS("Net Change");
                lUsedBudgetAmount += lGLAccount."Net Change";
            until lGLAccount.NEXT = 0;
        end;
        exit(lUsedBudgetAmount);
    end;

    local procedure GetTotalBudgetAmount(PurchaseAccount: Code[20]; lPRLine: Record "PR Line"; lStartDate: Date; lEndDate: Date): Decimal
    var
        lTotalBudgetAmount: Decimal;
        lGLBudgetEntry: Record "G/L Budget Entry";
        lPurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        CLEAR(lTotalBudgetAmount);
        lPurchasesPayablesSetup.Get();
        lGLBudgetEntry.RESET;
        lGLBudgetEntry.SETFILTER("Budget Name", lPurchasesPayablesSetup."PR Budget Name");
        lGLBudgetEntry.SETRANGE("G/L Account No.", PurchaseAccount);
        // lGLBudgetEntry.SETFILTER("Global Dimension 1 Code", lPRLine."Shortcut dimension 1 code");//19.0.0.5>>
        // lGLBudgetEntry.SETFILTER("Global Dimension 2 Code", lPRLine."Shortcut dimension 2 code");//19.0.0.5>>
        lGLBudgetEntry.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5>>
        // GLAccount.SETFILTER("Date Filter", '%1..%2', lStartDate, lEndDate);//19.0.0.3>>
        lGLBudgetEntry.SETFILTER(Date, '%1..%2', lStartDate, lEndDate);//19.0.0.3>>
        // if lPRLine."Dimension Set ID" <> 0 then//19.0.0.5>>
        //     lGLBudgetEntry.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5>>
        if lGLBudgetEntry.FINDSET then
            repeat
                lTotalBudgetAmount += lGLBudgetEntry.Amount;
            until lGLBudgetEntry.NEXT = 0;
        exit(lTotalBudgetAmount);
    end;

    procedure GetBalancePurchaseLine(PurchaseAccount: Code[20]; lPRLine: Record "PR Line"; lStartDate: Date; lEndDate: Date): Decimal
    var
        lGPurchHdr: Record "Purchase Header";
        lGPurchLine: Record "Purchase Line";
        lGTotalPurchaseLines: Decimal;
    begin
        Clear(lGTotalPurchaseLines);
        lGPurchHdr.RESET;
        lGPurchHdr.SETCURRENTKEY("Document Type", "Posting Date");
        lGPurchHdr.SETRANGE("Document Type", lGPurchHdr."Document Type"::Order);
        lGPurchHdr.SETRANGE("Posting Date", lStartDate, lEndDate);
        if lGPurchHdr.FINDSET then
            repeat
                lGPurchLine.RESET;
                lGPurchLine.SETCURRENTKEY("Document Type", "Document No.", "No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                lGPurchLine.SETRANGE("Document No.", lGPurchHdr."No.");
                lGPurchLine.SETRANGE("Document Type", lGPurchLine."Document Type"::Order);
                lGPurchLine.SETRANGE("G/L Account No.", PurchaseAccount);
                // lGPurchLine.SETFILTER("Shortcut Dimension 1 Code", lPRLine."Shortcut Dimension 1 Code");//19.0.0.5
                // lGPurchLine.SETFILTER("Shortcut Dimension 2 Code", lPRLine."Shortcut Dimension 2 Code");//19.0.0.5
                lGPurchLine.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5
                if lGPurchLine.FINDSET then
                    repeat
                        lGPurchLine.CALCFIELDS("PR In G/L", "G/L Total Amt for PR");
                        if lGPurchLine."PR In G/L" then
                            lGTotalPurchaseLines += lGPurchLine."Outstanding Amount (LCY)" + lGPurchLine."Amt. Rcd. Not Invoiced (LCY)" - lGPurchLine."G/L Total Amt for PR"
                        else
                            lGTotalPurchaseLines += lGPurchLine."Outstanding Amount (LCY)" + lGPurchLine."Amt. Rcd. Not Invoiced (LCY)";
                    until lGPurchLine.NEXT = 0;
            until lGPurchHdr.NEXT = 0;
        exit(lGTotalPurchaseLines);
    end;

    /////////////////////////////////
    procedure GetBudgetOnhold(PurchaseAccount: Code[20]; lPRLine: Record "PR Line"; lStartDate: Date; lEndDate: Date): Decimal
    var
        lPRHeader2: Record "PR Header";
        lPRLine2: Record "PR Line";
        lGPurchLine: Record "Purchase Line";
        lRFQComp: Record "RFQ Comparison";
        lGTotalBudgetOnHold: Decimal;
    begin
        Clear(lGTotalBudgetOnHold);
        lPRHeader2.RESET;
        lPRHeader2.SETFILTER("PR Document Type", '<>%1', lPRHeader2."PR Document Type"::PC);
        lPRHeader2.SETRANGE("PR Date", lStartDate, lEndDate);
        lPRHeader2.SETFILTER(Status, '%1|%2|%3', lPRHeader2.Status::Released, lPRHeader2.Status::Closed, lPRHeader2.Status::"Pending Approval");
        if lPRHeader2.FINDSET then
            repeat
                lPRLine2.RESET;
                lPRLine2.SETRANGE("Document No.", lPRHeader2."No.");
                // lPRLine2.SETRANGE("No.", lPRLine."No.");//19.0.0.5>>
                lPRLine2.SETRANGE("G/L Account No.", lPRLine."G/L Account No.");//19.0.0.5>>
                lPRLine2.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5>>
                // lPRLine2.SETFILTER("Shortcut dimension 1 code", lPRLine."Shortcut dimension 1 code");//19.0.0.5>>
                // lPRLine2.SETFILTER("Shortcut dimension 2 code", lPRLine."Shortcut dimension 2 code");//19.0.0.5>>
                if lPRLine2.FINDSET then
                    repeat
                        if (lPRLine2.ConvertedtoOrder) then begin
                            ////////////////////////////////////
                            // BCalcPurchaseOrderForOnHold(lPRHeader2."No.", lPRLine2."Line No.")
                            // procedure BCalcPurchaseOrderForOnHold(PRNo: Code[20];PRLineNo: Integer);
                            // begin
                            lGPurchLine.RESET;
                            lGPurchLine.SETRANGE("Document Type", lGPurchLine."Document Type"::Order);
                            lGPurchLine.SETRANGE("Document No.", lPRHeader2."No.");
                            lGPurchLine.SETRANGE("Line No.", lPRLine2."Line No.");
                            lGPurchLine.SETRANGE("G/L Account No.", PurchaseAccount);
                            lGPurchLine.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5>>
                            // lGPurchLine.SETFILTER("Shortcut Dimension 1 Code", lPRLine."Shortcut dimension 1 code");//19.0.0.5>>
                            // lGPurchLine.SETFILTER("Shortcut Dimension 2 Code", lPRLine."Shortcut dimension 2 code");//19.0.0.5>>
                            if lGPurchLine.FINDFIRST then
                                if lGPurchLine."Quantity Received" = 0 then
                                    lGTotalBudgetOnHold += lGPurchLine."Outstanding Amount (LCY)";
                            // end;
                            ////////////////////////////////////
                        end else
                            if (lPRLine2.ConvertedtoQuote) then begin
                                ////////////////////////////////////
                                // BCalcPurchaseQuoteForOnHold(lPRHeader2."No.", lPRLine2."Line No.")
                                // procedure BCalcPurchaseQuoteForOnHold(PRNo: Code[20];PRLineNo: Integer);
                                // var
                                // LQuoteConvertedToOrder: Boolean;
                                // RFQComp: Record "RFQ Comparison";
                                // begin
                                // CLEAR(LQuoteConvertedToOrder);
                                // CLEAR(LHighestAmt);
                                lRFQComp.RESET;
                                lRFQComp.SETRANGE("PR No", lPRHeader2."No.");
                                lRFQComp.SETRANGE(Status, lRFQComp.Status::"Pending Approval");
                                if lRFQComp.FINDFIRST then begin
                                    lGPurchLine.RESET;
                                    lGPurchLine.SETRANGE("Document Type", lGPurchLine."Document Type"::Quote);
                                    lGPurchLine.SETRANGE("PR No.", lPRHeader2."No.");
                                    lGPurchLine.SETRANGE("PR Line No.", lPRLine2."Line No.");
                                    lGPurchLine.SETRANGE("G/L Account No.", PurchaseAccount);
                                    lGPurchLine.SETRANGE("Dimension Set ID", lPRLine."Dimension Set ID");//19.0.0.5>>
                                    // lGPurchLine.SETFILTER("Shortcut Dimension 1 Code", lPRLine."Shortcut dimension 1 code");//19.0.0.5>>
                                    // lGPurchLine.SETFILTER("Shortcut Dimension 2 Code", lPRLine."Shortcut dimension 2 code");//19.0.0.5>>
                                    if lGPurchLine.FINDSET then
                                        lGTotalBudgetOnHold += lGPurchLine."Outstanding Amount (LCY)";
                                end;
                                // end;
                                ////////////////////////////////////
                            end else
                                lGTotalBudgetOnHold += (lPRLine2."Unit Cost (LCY)" * lPRLine2.Quantity);
                    until lPRLine2.NEXT = 0;
            until lPRHeader2.NEXT = 0;
        exit(lGTotalBudgetOnHold);
    end;
    /////////////////////////////////
    procedure CheckBudgetCurrentLine(DocumentNo: Code[20])
    var
        lStartDate: Date;
        lEndDate: Date;
        lPRHeader: Record "PR Header";
        lPRHeader2: Record "PR Header";
        lPurchasesPayablesSetup: Record "Purchases & Payables Setup";
        lGLAccount: Record "G/L Account";
        lGLAccount2: Record "G/L Account";
        lGLBudgetEntry: Record "G/L Budget Entry";
        lGPurchHdr: Record "Purchase Header";
        lGPurchLine: Record "Purchase Line";
        lRFQComp: Record "RFQ Comparison";
        lNoSeries: Record "No. Series";
        lItem: Record Item;
        lTotalBudgetAmount: Decimal;
        lGTotalPReq: Decimal;
        lGTotalBudgetOnHold: Decimal;
    begin
        if lPRHeader.Get(DocumentNo) and lNoSeries.GET(lPRHeader."No. series") and lNoSeries."Enable GL Budget" then begin
            lPurchasesPayablesSetup.GET();
            lPurchasesPayablesSetup.TESTFIELD("PR Budget Name");
            lPurchasesPayablesSetup.TESTFIELD("Budget Start Date");
            lPurchasesPayablesSetup.TESTFIELD("Budget End Date");
            lStartDate := DMY2DATE(DATE2DMY(lPurchasesPayablesSetup."Budget Start Date", 1), DATE2DMY(lPurchasesPayablesSetup."Budget Start Date", 2), DATE2DMY(lPRHeader."PR Date", 3));
            lEndDate := DMY2DATE(DATE2DMY(lPurchasesPayablesSetup."Budget End Date", 1), DATE2DMY(lPurchasesPayablesSetup."Budget End Date", 2), DATE2DMY(lPRHeader."PR Date", 3));
            // Rec.Reset();
            // Rec.SetRange("Document No.", lPRHeader."No.");
            if (Rec.Type in [Rec.Type::Item]) and (Rec."No." <> '') and lItem.Get(Rec."No.") then begin
                lItem.CALCFIELDS("PR Budget Checking");
                if lItem."PR Budget Checking" = true then begin
                    // Rec."G/L Account No." := GetPurchaseAccount(Rec.Type, Rec."No.", lCheckBudgetBuffer."Vendor No.");
                    Rec.Utilised := GetUsedBudgetAmount(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    Rec."On Hold" := GetBudgetOnhold(Rec."G/L Account No.", Rec, lStartDate, lEndDate) + GetBalancePurchaseLine(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    lTotalBudgetAmount := GetTotalBudgetAmount(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    if lTotalBudgetAmount <> 0 then
                        Rec."Available Budget" := lTotalBudgetAmount - Rec.Utilised - Rec."On Hold"
                    else
                        Rec."Available Budget" := 0;
                    // Rec.Modify(false);
                end;
            end else
                if (Rec.Type in [Rec.Type::"G/L Account"]) and (Rec."No." <> '') then begin
                    // lPRLine."Total Budget" := GetTotalBudgetAmount(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                    Rec.Utilised := GetUsedBudgetAmount(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    Rec."On Hold" := GetBudgetOnhold(Rec."G/L Account No.", Rec, lStartDate, lEndDate) + GetBalancePurchaseLine(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    lTotalBudgetAmount := GetTotalBudgetAmount(Rec."G/L Account No.", Rec, lStartDate, lEndDate);
                    if lTotalBudgetAmount <> 0 then
                        Rec."Available Budget" := lTotalBudgetAmount - Rec.Utilised - Rec."On Hold"
                    else
                        Rec."Available Budget" := 0;
                    // Rec.Modify(false);
                end;
        end;
    end;

    procedure CheckBudget(DocumentNo: Code[20])
    var
        lStartDate: Date;
        lEndDate: Date;
        // lSuggestedVendor: Record "Suggested Vendor";
        lCheckBudgetBuffer: Record "Check Budget Buffer";
        lPRLine: Record "PR Line";
        lPRLine2: Record "PR Line";
        lPRHeader: Record "PR Header";
        lPRHeader2: Record "PR Header";
        lPurchasesPayablesSetup: Record "Purchases & Payables Setup";
        lGLAccount: Record "G/L Account";
        lGLAccount2: Record "G/L Account";
        lGLBudgetEntry: Record "G/L Budget Entry";
        lGPurchHdr: Record "Purchase Header";
        lGPurchLine: Record "Purchase Line";
        lRFQComp: Record "RFQ Comparison";
        lNoSeries: Record "No. Series";
        lItem: Record Item;
        lEntryNo: Integer;
        lGTotalPReq: Decimal;
        lGTotalBudgetOnHold: Decimal;
    // lText001: Label 'To add a Type Item or Fixed Asset ,you should added Suggested Vendor to check available budget';
    begin
        if lPRHeader.Get(DocumentNo) and lNoSeries.GET(lPRHeader."No. series") and lNoSeries."Enable GL Budget" then begin
            lPurchasesPayablesSetup.GET();
            lPurchasesPayablesSetup.TESTFIELD("PR Budget Name");
            lPurchasesPayablesSetup.TESTFIELD("Budget Start Date");
            lPurchasesPayablesSetup.TESTFIELD("Budget End Date");
            lStartDate := DMY2DATE(DATE2DMY(lPurchasesPayablesSetup."Budget Start Date", 1), DATE2DMY(lPurchasesPayablesSetup."Budget Start Date", 2), DATE2DMY(lPRHeader."PR Date", 3));
            lEndDate := DMY2DATE(DATE2DMY(lPurchasesPayablesSetup."Budget End Date", 1), DATE2DMY(lPurchasesPayablesSetup."Budget End Date", 2), DATE2DMY(lPRHeader."PR Date", 3));

            lPRLine.Reset();
            lPRLine.SetRange("Document No.", lPRHeader."No.");
            if lPRLine.FindSet() then begin
                lCheckBudgetBuffer.Reset();
                lCheckBudgetBuffer.DeleteAll();
                lEntryNo := 0;
            end;
            repeat
                if (lPRLine.Type in [lPRLine.Type::Item]) and (lPRLine."No." <> '') and lItem.Get(lPRLine."No.") then begin
                    lItem.CALCFIELDS("PR Budget Checking");
                    if lItem."PR Budget Checking" = true then begin
                        // lSuggestedVendor.Reset();
                        // lSuggestedVendor.SetRange("Document Type", lSuggestedVendor."Document Type"::"PR Header");
                        // lSuggestedVendor.SetRange("PR No.", lPRHeader."No.");
                        // lSuggestedVendor.SetRange("PR Line No.", 0);
                        // if lSuggestedVendor.FindSet() then begin
                        // repeat
                        lCheckBudgetBuffer.Reset();
                        lCheckBudgetBuffer.Init();
                        lEntryNo := lEntryNo + 1;
                        lCheckBudgetBuffer."Entry No." := lEntryNo;
                        lCheckBudgetBuffer."PR No." := lPRLine."Document No.";
                        lCheckBudgetBuffer."PR Line No." := lPRLine."Line No.";
                        lCheckBudgetBuffer.Type := lPRLine.Type;
                        lCheckBudgetBuffer."No." := lPRLine."No.";
                        // lCheckBudgetBuffer."Vendor No." := lSuggestedVendor."Suggested Vendor";
                        lCheckBudgetBuffer."Vendor No." := lPRHeader."Suggested Vendor";
                        lCheckBudgetBuffer."Purchase Account" := GetPurchaseAccount(lCheckBudgetBuffer.Type, lCheckBudgetBuffer."No.", lCheckBudgetBuffer."Vendor No.");
                        lCheckBudgetBuffer."Total Budget" := GetTotalBudgetAmount(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        lCheckBudgetBuffer."Used Budget" := GetUsedBudgetAmount(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        lCheckBudgetBuffer.Utilised := lCheckBudgetBuffer."Used Budget";
                        lCheckBudgetBuffer."On Hold" := GetBudgetOnhold(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate) + GetBalancePurchaseLine(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        if lCheckBudgetBuffer."Total Budget" <> 0 then
                            lCheckBudgetBuffer."Available Budget" := lCheckBudgetBuffer."Total Budget" - lCheckBudgetBuffer.Utilised - lCheckBudgetBuffer."On Hold"
                        else
                            lCheckBudgetBuffer."Available Budget" := 0;
                        lCheckBudgetBuffer.Insert(true);
                        // until lSuggestedVendor.Next() = 0;
                        // end else begin
                        //     Error(lText001);
                        // end;
                        lPRLine."Available Budget" := lCheckBudgetBuffer."Available Budget";
                        lPRLine.Utilised := lCheckBudgetBuffer.Utilised;
                        lPRLine."On Hold" := lCheckBudgetBuffer."On Hold";
                        lPRLine.Modify(false);
                    end;
                end else
                    if (lPRLine.Type in [lPRLine.Type::"G/L Account"]) and (lPRLine."No." <> '') then begin
                        lCheckBudgetBuffer.Reset();
                        lCheckBudgetBuffer.Init();
                        lEntryNo := lEntryNo + 1;
                        lCheckBudgetBuffer."Entry No." := lEntryNo;
                        lCheckBudgetBuffer."PR No." := lPRLine."Document No.";
                        lCheckBudgetBuffer."PR Line No." := lPRLine."Line No.";
                        lCheckBudgetBuffer.Type := lPRLine.Type;
                        lCheckBudgetBuffer."No." := lPRLine."No.";
                        // lCheckBudgetBuffer."Vendor No." := lSuggestedVendor."Suggested Vendor";
                        lCheckBudgetBuffer."Purchase Account" := GetPurchaseAccount(lCheckBudgetBuffer.Type, lCheckBudgetBuffer."No.", lPRLine."Suggested Vendor");
                        lCheckBudgetBuffer."Total Budget" := GetTotalBudgetAmount(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        lCheckBudgetBuffer."Used Budget" := GetUsedBudgetAmount(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        lCheckBudgetBuffer.Utilised := lCheckBudgetBuffer."Used Budget";
                        lCheckBudgetBuffer."On Hold" := GetBudgetOnhold(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate) + GetBalancePurchaseLine(lCheckBudgetBuffer."Purchase Account", lPRLine, lStartDate, lEndDate);
                        if lCheckBudgetBuffer."Total Budget" <> 0 then
                            lCheckBudgetBuffer."Available Budget" := lCheckBudgetBuffer."Total Budget" - lCheckBudgetBuffer.Utilised - lCheckBudgetBuffer."On Hold"
                        else
                            lCheckBudgetBuffer."Available Budget" := 0;

                        lCheckBudgetBuffer.Insert(true);
                        lPRLine."Available Budget" := lCheckBudgetBuffer."Available Budget";
                        lPRLine.Utilised := lCheckBudgetBuffer.Utilised;
                        lPRLine."On Hold" := lCheckBudgetBuffer."On Hold";
                        lPRLine.Modify(false);
                    end;
            until lPRLine.Next() = 0;
        end;
    end;
}

