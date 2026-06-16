page 27003015 "PR Line subform"
{
    AutoSplitKey = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "PR Line";
    SourceTableView = SORTING("Document No.", "Line No.")
                      ORDER(Ascending);

    layout
    {
        area(content)
        {
            repeater(Control1000000016)
            {
                field(Type; Type)
                {
                    ApplicationArea = all;
                }
                field("No."; "No.")
                {
                    ApplicationArea = all;
                    trigger OnValidate()
                    begin
                        CurrPage.Update();//"20.0.0.4"
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("STD Purchase Code"; "STD Purchase Code")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Suggested Vendor"; "Suggested Vendor")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                    trigger OnValidate();
                    begin
                        // Amount := Quantity * "Unit Cost";
                        CurrPage.UPDATE(true); //"20.0.0.4"
                    end;
                }
                field("Unit of  Measure"; "Unit of  Measure")
                {
                    ApplicationArea = all;
                }
              /*   field("Article Code"; "Article Code")
                {
                    ApplicationArea = all;
                    Visible = IsACV;
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
                            if Evaluate(UC, TranslatedValue) then
                                Rec.Validate("Unit Cost", UC);
                        end
                        else
                            Validate("Unit Cost", 0);


                    end;
                } */
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = all;
                    Visible = false;
                    trigger OnValidate();
                    begin
                        // CurrPage.UPDATE;//"20.0.0.4"
                    end;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                    //Editable = false;
                    trigger OnValidate();
                    begin
                        // CurrPage.UPDATE;//"20.0.0.4"
                    end;
                }
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = all;
                }
                field("Shortcut dimension 1 code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Shortcut dimension 2 code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("Available Budget"; "Available Budget")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("On Hold"; "On Hold")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Utilised; Utilised)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Dimension Set ID"; "Dimension Set ID")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
                field("No. of RFQ"; "No. of RFQ")
                {
                    ApplicationArea = all;
                }
                field("No. of PO"; "No. of PO")
                {
                    ApplicationArea = all;
                }
                field("PO No."; "PO No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Remarks; Remarks)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Dimensions)
            {
                Caption = 'Dimensions';
                ApplicationArea = all;

                trigger OnAction();
                begin
                    "Dimension Set ID" :=
                      DimMgt.EditDimensionSet("Dimension Set ID", STRSUBSTNO('%1 %2 %3', "PR Document Type", "Document No.", "Line No."));
                    DimMgt.UpdateGlobalDimFromDimSetID("Dimension Set ID", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CheckACVisibility();
    end;

    trigger OnAfterGetRecord()
    begin
        CheckACVisibility();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CheckACVisibility();
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        // Type := Type::Item;//19.0.0.7
        // Type := xRec.Type;
        // SetDefaultType();//19.0.0.7
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckBudget(Rec."Document No.");
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // CheckBudget(Rec."Document No.");
    end;

    procedure CheckACVisibilityOpen()
    var
        PLS: Page "PR Line subform";
    begin
        if PRH.Get("Document No.") then
            if PRH."PR Document Type" = PRH."PR Document Type"::PO then
                IsACV := true
            else
                IsACV := false;
    end;

    procedure CheckACVisibility()
    var
        PLS: Page "PR Line subform";
    begin
        if PRH.Get("Document No.") then
            if PRH."PR Document Type" = PRH."PR Document Type"::PO then
                IsACV := true
            else begin
                IsACV := false;
                Clear("Article Code");
                Clear("Unit Cost");
                Clear("Unit Cost (LCY)");
                Clear(Amount);
                Clear("Amount (LCY)");
                // Rec.Modify(true);
            end;
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        PRH: Record "PR Header";

        [InDataSet]
        IsACV: Boolean; //Is Article Code Visible

}

