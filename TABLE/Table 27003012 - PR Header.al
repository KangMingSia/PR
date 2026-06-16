table 27003012 "PR Header"
{
    DrillDownPageID = "Purchase Requisitions";
    LookupPageID = "Purchase Requisitions";

    fields
    {
        field(1; "No."; Code[20])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                if "No." <> xRec."No." then begin
                    PurchSetup.GET;
                    NoSeriesMgt.TestManual(PurchSetup."Purchase Requisition Nos.");
                    "No. series" := '';
                end;
            end;
        }
        field(2; Description; Text[150])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(3; "PR Date"; Date)
        {
        }
        field(4; "Due Date"; Date)
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(5; "Delivery Location"; Code[20])
        {
            TableRelation = Location;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(6; "No. series"; Code[20])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(7; Requester; Text[150])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(9; "PR Document Type"; Option)
        {
            OptionMembers = RFQ,PO,PC;//19.0.0.4>>
                                      // OptionCaption = 'RFQ,PO,PC';//19.0.0.4>>
            OptionCaption = 'RFQ,PO';//19.0.0.4>>

            trigger OnValidate();
            begin
                //       TESTFIELD(Status, Status::Open);
                PurchSetup.GET;
                Noseries.RESET;
                Noseries.SETRANGE(Code, "No. series");
                if Noseries.FINDFIRST then;

                if xRec."PR Document Type" <> "PR Document Type" then begin
                    if "PR Document Type" = "PR Document Type"::PO then
                        if Noseries."PR Order" <> '' then
                            PONoseries := Noseries."PR Order"
                        else
                            PONoseries := PurchSetup."Order Nos.";
                    if "PR Document Type" = "PR Document Type"::RFQ then
                        if Noseries."PR Quote" <> '' then
                            PONoseries := Noseries."PR Quote"
                        else
                            PONoseries := PurchSetup."Quote Nos.";
                end;
            end;
        }
        field(10; "PR Status"; Option)
        {
            OptionMembers = PR,RFQ,"Order",Cancelled,Closed;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(11; "Co-ordinator"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(12; Status; Option)
        {
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";
        }
        field(13; "Last Modified Date"; Date)
        {
            Editable = false;
        }
        field(14; "Suggested Vendor"; Code[20])
        {
            TableRelation = Vendor."No.";

            trigger OnValidate();
            var
                TblSuggVendor3: Record "Suggested Vendor";
                TblSuggVendor4: Record "Suggested Vendor";
                prLineNo: Integer;
                LineNo: Integer;
            begin
                TESTFIELD(Status, Status::Open);
                TblSuggVendor2.RESET;
                TblSuggVendor2.SETRANGE("PR No.", "No.");
                if TblSuggVendor2.FINDSET then
                    TblSuggVendor2.DELETE;

                TblSuggVendor3.INIT;
                TblSuggVendor3.VALIDATE("Document Type", TblSuggVendor2."Document Type"::"PR Header");
                TblSuggVendor3.VALIDATE("PR No.", "No.");
                TblSuggVendor3.VALIDATE("Suggested Vendor", "Suggested Vendor");
                if TblVendor.GET("Suggested Vendor") then begin
                    TblSuggVendor3."Vendor Name" := TblVendor.Name;
                    TblSuggVendor3.INSERT(true);
                end;

                PRLine.RESET;
                PRLine.SETRANGE("Document No.", "No.");
                if PRLine.FINDSET then
                    PRLine.DELETEALL;
            end;
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                ValidateShortcutDimCode(1, "Shortcut Dimension 1 Code");
            end;
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
                ValidateShortcutDimCode(2, "Shortcut Dimension 2 Code");
            end;
        }
        field(17; PONoseries; Code[20])
        {
            TableRelation = "No. Series";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(18; "PR Type"; Option)
        {
            OptionCaption = 'Raw Material,General,Hardware,Fixed Asset,Projects';
            OptionMembers = "Raw Material",General,Hardware,"Fixed Asset",Projects;

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(19; "WBS ID"; Code[50])
        {
            TableRelation = "Budget Import"."WBS ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"));

            trigger OnValidate();
            begin
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", "No.");
                if PRLine.FINDSET then begin
                    repeat
                        PRLine."WBS ID" := "WBS ID";
                        PRLine.MODIFY;
                    until PRLine.NEXT = 0;
                end;
            end;
        }
        field(20; "Budgetary PR"; Boolean)
        {

            trigger OnValidate();
            begin

                PurchaseQuote.RESET;
                PurchaseQuote.SETRANGE("Document Type", PurchaseQuote."Document Type"::Quote);
                PurchaseQuote.SETRANGE("PR No.", "No.");
                if PurchaseQuote.FINDSET then
                    repeat
                        PurchaseQuote."Budgetary PR" := false;
                        PurchaseQuote.MODIFY;
                    until PurchaseQuote.NEXT = 0;
            end;
        }
        field(21; "Date Created"; Date)
        {
        }
        field(22; "Currency Code"; Code[10])
        {
            TableRelation = Currency;

            trigger OnValidate();
            begin
                if xRec."Currency Code" <> Rec."Currency Code" then begin
                    UpdateCurrencyFactor;
                    UpdatePRLine;
                end;
            end;
        }
        field(23; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(24; "Purchaser Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser".Code WHERE(Purchaser = CONST(true));
        }
        field(25; "PR Total Amount"; Decimal)
        {
            CalcFormula = Sum("PR Line".Amount WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(26; "LOA Status"; Option)
        {
            Description = 'PR2.1';
            Editable = false;
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";
        }
        field(27; "PR Total Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("PR Line"."Amount (LCY)" WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(28; "PR Available Budget"; Decimal)
        {
            CalcFormula = Sum("PR Line"."Available Budget" WHERE("Document No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(37; "No. of Archived Versions"; Integer)
        {
            CalcFormula = Max("PR Arch. Header"."Version No." WHERE("No." = FIELD("No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Description = 'PR4.0';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnLookup();
            begin
                ShowDocDim;
            end;

            trigger OnValidate()
            begin
                UpdatehortcutDimension("Dimension Set ID");//19.0.0.7
            end;
        }
        field(481; "Released By"; Code[50])
        {
            Editable = false;
        }
        //19.0.0.7>>
        field(50000; "Shortcut Dimension 3 Code"; Code[20]) { FieldClass = Normal; }
        field(50001; "Shortcut Dimension 4 Code"; Code[20]) { FieldClass = Normal; }
        field(50002; "Shortcut Dimension 5 Code"; Code[20]) { FieldClass = Normal; }
        field(50003; "Shortcut Dimension 6 Code"; Code[20]) { FieldClass = Normal; }
        field(50004; "Shortcut Dimension 7 Code"; Code[20]) { FieldClass = Normal; }
        field(50005; "Shortcut Dimension 8 Code"; Code[20]) { FieldClass = Normal; }
        //19.0.0.7<<
    }

    keys
    {
        key(Key1; "No.")
        {
        }
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
    begin

        PRLine.RESET;
        PRLine.SETRANGE("Document No.", "No.");
        if PRLine.FINDSET then
            PRLine.DELETEALL(true);
        SuggestedVendor.RESET;
        SuggestedVendor.SETRANGE("Document Type", SuggestedVendor."Document Type"::"PR Header");
        SuggestedVendor.SETRANGE("PR No.", "No.");
        if SuggestedVendor.FINDSET then
            SuggestedVendor.DELETEALL;
    end;

    trigger OnInsert();
    begin

        PurchSetup.GET;
        if "No." = '' then begin
            PurchSetup.TESTFIELD("Purchase Requisition Nos.");
            NoSeriesMgt.InitSeries(PurchSetup."Purchase Requisition Nos.", xRec."No. series", TODAY, "No.", "No. series");
        end;

        SelectPONoseries;
        "Co-ordinator" := USERID;
        "Last Modified Date" := WORKDATE;
        "Date Created" := WORKDATE;
        "PR Date" := WORKDATE;

        if UserSetup.GET(USERID) then
            "Shortcut Dimension 1 Code" := UserSetup."Shortcut Dimension 1 code";
        //"PR Document Type" := "PR Document Type"::PO; //19.0.0.3>>
    end;

    trigger OnModify();
    begin

        if (xRec.Description <> Description) or
          (xRec."PR Date" <> "PR Date") or
          (xRec."Due Date" <> "Due Date") or
          (xRec."Delivery Location" <> "Delivery Location") or
          (xRec.Requester <> Requester) or
          (xRec."PR Document Type" <> "PR Document Type") or
          (xRec."Shortcut Dimension 1 Code" <> "Shortcut Dimension 1 Code") or
          (xRec."Shortcut Dimension 2 Code" <> "Shortcut Dimension 2 Code") or
          (xRec."PR Type" <> "PR Type") then begin
            "Last Modified Date" := WORKDATE;
            MODIFY;
        end;
    end;

    trigger OnRename();
    begin
        ERROR(Text000, TABLECAPTION);
    end;

    var
        PRLine: Record "PR Line";
        PurchSetup: Record "Purchases & Payables Setup";
        SuggestedVendor: Record "Suggested Vendor";
        Noseries: Record "No. Series";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PurchaseQuote: Record "Purchase Header";
        CurrencyDate: Date;
        CurrExchRate: Record "Currency Exchange Rate";
        rNoSeries: Record "No. Series";
        rNoSeriesLine: Record "No. Series Line";
        Question: Text[250];
        UserSetup: Record "User Setup";
        Text001: Label 'Kindly update the unit cost in the Purchase Requisition Line';
        Text000: Label 'You cannot rename a %1.';
        Text002: Label 'You have changed a dimension.\\';
        Text003: Label 'Do you want to update the lines?';
        DimMgt: Codeunit DimensionManagement;
        Text051: Label 'You may have changed a dimension.\\Do you want to update the lines?';
        TblSuggVendor2: Record "Suggested Vendor";
        TblVendor: Record Vendor;

    procedure SelectPONoseries();
    begin
        Noseries.RESET;
        Noseries.SETRANGE(Code, PurchSetup."Purchase Requisition Nos.");
        if Noseries.FINDFIRST then;

        if PONoseries = '' then
            if Noseries."PR Quote" <> '' then
                PONoseries := Noseries."PR Quote"
            else
                PONoseries := PurchSetup."Quote Nos.";
    end;

    procedure AssistEdit(OldPurchHeader: Record "PR Header"): Boolean;
    begin
        PurchSetup.GET;
        if NoSeriesMgt.SelectSeries(PurchSetup."Purchase Requisition Nos.", OldPurchHeader."No. series", "No. series") then begin
            PurchSetup.GET;
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;

    local procedure UpdateCurrencyFactor();
    begin
        if "Currency Code" <> '' then begin
            if "PR Date" = 0D then
                CurrencyDate := WORKDATE
            else
                CurrencyDate := "PR Date";

            "Currency Factor" := CurrExchRate.ExchangeRate(CurrencyDate, "Currency Code")
        end else
            "Currency Factor" := 0;
    end;

    procedure UpdatePRLine();
    begin
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", "No.");
        if PRLine.FINDSET then begin
            MESSAGE(Text001);
            repeat
                PRLine.VALIDATE("Unit Cost", 0);
                PRLine.MODIFY;
            until PRLine.NEXT = 0;
        end;
    end;

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, "Dimension Set ID");
        if "No." <> '' then
            MODIFY;

        if OldDimSetID <> "Dimension Set ID" then begin
            MODIFY;
            if PRLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure PRLinesExist(): Boolean;
    begin
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", "No.");
        exit(PRLine.FINDFIRST);
    end;

    procedure ShowDocDim();
    var
        OldDimSetID: Integer;
    begin
        OldDimSetID := "Dimension Set ID";
        "Dimension Set ID" :=
          EditDimensionSet2(
            "Dimension Set ID", STRSUBSTNO('%1 %2', 'PR', "No."),
            "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");

        if OldDimSetID <> "Dimension Set ID" then begin
            MODIFY;
            if PRLinesExist then
                UpdateAllLineDim("Dimension Set ID", OldDimSetID);
        end;
    end;

    procedure EditDimensionSet2(DimSetID: Integer; NewCaption: Text[250]; VAR GlobalDimVal1: Code[20]; VAR GlobalDimVal2: Code[20]): Integer
    var
        DimSetEntry: Record "Dimension Set Entry";
        EditDimSetEntries: Page "Edit Dimension Set Entries";
        NewDimSetID: Integer;
    begin
        NewDimSetID := DimSetID;
        DimSetEntry.RESET;
        DimSetEntry.FILTERGROUP(2);
        DimSetEntry.SETRANGE("Dimension Set ID", DimSetID);
        DimSetEntry.FILTERGROUP(0);
        EditDimSetEntries.SETTABLEVIEW(DimSetEntry);
        EditDimSetEntries.SetFormCaption(NewCaption);
        EditDimSetEntries.RUNMODAL;
        NewDimSetID := EditDimSetEntries.GetDimensionID;
        DimMgt.UpdateGlobalDimFromDimSetID(NewDimSetID, GlobalDimVal1, GlobalDimVal2);
        EXIT(NewDimSetID);
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer);
    var
        NewDimSetID: Integer;
    begin
        if NewParentDimSetID = OldParentDimSetID then
            exit;
        if not CONFIRM(Text051) then
            exit;

        PRLine.RESET;
        PRLine.SETRANGE("Document No.", "No.");
        PRLine.LOCKTABLE;
        if PRLine.FIND('-') then
            repeat
                NewDimSetID := DimMgt.GetDeltaDimSetID(PRLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if PRLine."Dimension Set ID" <> NewDimSetID then begin
                    PRLine."Dimension Set ID" := NewDimSetID;
                    DimMgt.UpdateGlobalDimFromDimSetID(
                      PRLine."Dimension Set ID", PRLine."Shortcut Dimension 1 Code", PRLine."Shortcut Dimension 2 Code");
                    PRLine.UpdatehortcutDimension("Dimension Set ID");//19.0.0.7
                    PRLine.MODIFY;
                    PRLine.CheckBudget(Rec."No.");//19.0.0.3>>
                end;
            until PRLine.NEXT = 0;
    end;
}

