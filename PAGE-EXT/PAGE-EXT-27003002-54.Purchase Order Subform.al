pageextension 27003002 "Purchase Order Subform-IBIZPR" extends "Purchase Order Subform"
{
    layout
    {
        addbefore("Direct Unit Cost")
        {
           /*  field("Article Code"; "Article Code")
            {
                ApplicationArea = All;
                trigger OnValidate()
                var
                    ArticleCodeMap: Record "Article Code Mapping";
                    I: Integer;
                    CodeLen: Integer;
                    ArticleChar: Code[1];
                    UC: Decimal;
                    TranslatedValue: Text;
                begin
                    Clear(Rec."Unit Cost");
                    Clear(TranslatedValue);
                    if "Article Code" <> '' then begin
                        CodeLen := StrLen(Rec."Article Code");
                        for i := 2 to CodeLen do begin
                            ArticleChar := CopyStr(Rec."Article Code", I, 1);
                            ArticleCodeMap.Get(ArticleChar);
                            TranslatedValue += ArticleCodeMap.Value;
                        end;
                        if Evaluate(UC, TranslatedValue) then begin
                            Rec.Validate("Direct Unit Cost", UC);
                            Rec.Modify(false);
                            // Rec.Validate("Unit Cost", UC);
                        end;
                    end
                    else begin
                        Rec.Validate("Direct Unit Cost", DirectUnitCostOri);
                        Rec.Modify(false);
                    end;
                end;
            } */
        }
        addafter("Quantity Invoiced")
        {
            field("Create PO"; "Create PO")
            {
                ApplicationArea = All;
            }
            field("PQ No"; "PQ No")
            {
                ApplicationArea = All;
            }
            field("RFQ No."; "RFQ No.")
            {
                ApplicationArea = All;
            }
            /*
            field("Converted to PO"; "Converted to PO")
            {
                ApplicationArea = All;
            }
            field("PQ Line No"; "PQ Line No")
            {
                ApplicationArea = All;
            }
            field("PO No"; "PO No")
            {
                ApplicationArea = All;
            }
            field("PO Line No."; "PO Line No.")
            {
                ApplicationArea = All;
            }
            */
            field("Requested Quantity"; "Requested Quantity")
            {
                ApplicationArea = All;
            }
            field("WBS ID"; "WBS ID")
            {
                ApplicationArea = All;
            }
            field("Activity ID"; "Activity ID")
            {
                ApplicationArea = All;
            }
            field("Remarks"; "Remarks")
            {
                ApplicationArea = All;
            }
            field("Reason for Shortlist"; "Reason for Shortlist")
            {
                ApplicationArea = All;
            }
            field("Bold"; "Bold")
            {
                ApplicationArea = All;
            }
            field("PR In G/L"; "PR In G/L")
            {
                ApplicationArea = All;
            }
            field("G/L Total Amt for PR"; "G/L Total Amt for PR")
            {
                ApplicationArea = All;
            }
            field("PR No."; "PR No.")
            {
                ApplicationArea = All;
                Enabled = false;
            }
            field("PR Line No."; "PR Line No.")
            {
                Enabled = false;
                ApplicationArea = All;
            }
        }
        modify(Type) { Enabled = boolEnablePrField; }
        modify("No.")
        {
            Enabled = boolEnablePrField;
            trigger OnAfterValidate()
            begin
                Clear(DirectUnitCostOri);
                DirectUnitCostOri := Rec."Direct Unit Cost";
            end;
        }
        modify(Quantity) { Enabled = boolEnablePrField; }
        modify("Unit of Measure Code") { Enabled = boolEnablePrField; }
        modify("Direct Unit Cost") { Visible = false; Enabled = boolEnablePrField; }
        modify("Line Amount") { Enabled = boolEnablePrField; }
        modify("Shortcut Dimension 1 Code") { Enabled = boolEnablePrField; }
        modify("Shortcut Dimension 2 Code") { Enabled = boolEnablePrField; }
    }
    trigger OnAfterGetRecord()
    begin
        if Rec."PR No." = '' then
            boolEnablePrField := true
        else
            boolEnablePrField := false;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."PR No." = '' then
            boolEnablePrField := true
        else
            boolEnablePrField := false;
    end;

    var
        boolEnablePrField: Boolean;
        DirectUnitCostOri: Decimal;
}