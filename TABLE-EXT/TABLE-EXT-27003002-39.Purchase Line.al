tableextension 27003002 "Purchase Line-IBIZPR" extends "Purchase Line"
{
    fields
    {
        field(27003000; "Create PO"; Boolean)
        {
            DataClassification = CustomerContent;
            // Editable = false;
        }
        field(27003001; "PQ No"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003002; "PQ Line No"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003003; "RFQ No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003004; "Converted to PO"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003005; "PO No"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(27003006; "PO Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003007; "Requested Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003008; "WBS ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Enabled = false;
            //ValidateTableRelation = true;
        }
        field(27003009; "Activity ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Enabled = false;
            //ValidateTableRelation = true;
        }
        field(27003010; "Remarks"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(27003011; "Reason for Shortlist"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(27003012; "Bold"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003013; "PR In G/L"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("G/L Entry" WHERE("PR No." = FIELD("PR No."), "PR Line No." = FIELD("PR Line No.")));
            Editable = false;
        }
        field(27003014; "G/L Total Amt for PR"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("No."), "PR No." = FIELD("PR No."), "PR Line No." = FIELD("PR Line No.")));
            Editable = false;
        }
        field(27003015; "PR No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003016; "PR Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003017; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003027; "Linked GL Account"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        modify("No.")
        {
            trigger OnAfterValidate()
            var
                lGeneralPostingSetup: Record "General Posting Setup";
                lItem: Record Item;
            begin
                if Rec.Type = Rec.Type::"G/L Account" then begin
                    "G/L Account No." := Rec."No."
                end else
                    if Rec.Type = Rec.Type::Item then begin
                        if lItem.Get(Rec."No.") then begin
                            if lGeneralPostingSetup.Get(Rec."Gen. Bus. Posting Group", lItem."Gen. Prod. Posting Group") then begin
                                lGeneralPostingSetup.TestField("Purch. Account");
                                "Linked GL Account" := lGeneralPostingSetup."Purch. Account";
                                "G/L Account No." := lGeneralPostingSetup."Purch. Account";
                            end;
                        end;
                    end else begin
                        Clear("Linked GL Account");
                    end;
                if Rec.Type <> Rec.Type::Item then
                    Clear("Linked GL Account");
                if Rec.Type <> Rec.Type::"G/L Account" then
                    if Rec.Type <> Rec.Type::Item then
                        Clear("G/L Account No.");
                if Rec.Type = Rec.Type::Item then
                    if "Linked GL Account" = '' then
                        if lGeneralPostingSetup.Get(Rec."Gen. Bus. Posting Group", Rec."Gen. Prod. Posting Group") then begin
                            lGeneralPostingSetup.TestField("Purch. Account");
                            "Linked GL Account" := lGeneralPostingSetup."Purch. Account";
                            "G/L Account No." := lGeneralPostingSetup."Purch. Account";
                        end;
            end;
        }
        //19.0.0.7>>
        field(27003018; "Shortcut Dimension 3 Code"; Code[20]) { FieldClass = Normal; }
        field(27003019; "Shortcut Dimension 4 Code"; Code[20]) { FieldClass = Normal; }
        field(27003020; "Shortcut Dimension 5 Code"; Code[20]) { FieldClass = Normal; }
        field(27003021; "Shortcut Dimension 6 Code"; Code[20]) { FieldClass = Normal; }
        field(27003022; "Shortcut Dimension 7 Code"; Code[20]) { FieldClass = Normal; }
        field(27003023; "Shortcut Dimension 8 Code"; Code[20]) { FieldClass = Normal; }
        //19.0.0.7<<
        field(27003024; "Article Code"; Code[50]) { FieldClass = Normal; }
        field(27003025; "Vendor Due Date"; Date)
        {
            DataClassification = CustomerContent;
            // Editable = false;
        }
        field(27003026; "RFQ Date"; Date)
        {
            //Editable = false;

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


}