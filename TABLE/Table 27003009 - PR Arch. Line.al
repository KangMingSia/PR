table 27003009 "PR Arch. Line"
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
        // }
        field(3; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';

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
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account"."No."
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            // IF (Type = CONST(Description)) "Standard Text"//19.0.0.5
            IF (Type = CONST(" ")) "Standard Text"//19.0.0.5
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(5; Description; Text[50])
        {
        }
        field(6; Quantity; Decimal)
        {
            BlankZero = true;
        }
        field(7; "Unit of  Measure"; Code[10])
        {
            TableRelation = "Unit of Measure".Code;
        }
        field(8; "Due Date"; Date)
        {
        }
        field(9; "Delivery Location"; Code[10])
        {
            TableRelation = Location;
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
        field(12; "Document Type"; Option)
        {
            OptionCaption = 'RFQ,PO';
            OptionMembers = RFQ,PO;
        }
        field(13; "PR No"; Code[20])
        {
        }
        field(14; "Unit Cost"; Decimal)
        {
            BlankZero = true;
        }
        field(15; Amount; Decimal)
        {
            BlankZero = true;
        }
        field(16; Status; Option)
        {
            Editable = false;
            OptionMembers = Open,Released,Cancel,Closed;
        }
        field(17; "Description 2"; Text[50])
        {
        }
        field(18; Remarks; Text[250])
        {
        }
        field(19; "Suggested Supplier"; Code[20])
        {
        }
        field(20; "Shortcut dimension 1 code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(21; "Shortcut dimension 2 code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(22; "Expected Receipt Date"; Date)
        {
        }
        field(23; "Qty Received"; Decimal)
        {
            BlankZero = true;
        }
        field(24; "RFQ No."; Integer)
        {
            // CalcFormula = Count("Purchase Line" WHERE("PR No." = FIELD("Document No."), "PR Line No." = FIELD("Line No."), "Document Type" = FILTER(Quote)));
            // CalcFormula = Count("Purchase Line Archive" WHERE("PR No." = FIELD("Document No."), "Doc. No. Occurrence" = FILTER(0), "PR Line No." = FIELD("Line No."), "Version No." = field("Version No."), "Document Type" = FILTER(Quote)));
            // CalcFormula = Max("Purchase Header Archive"."Version No." WHERE("Document Type" = FILTER(Quote), "PR No." = FIELD("Document No."), "Version No." = field("Version No."), "Doc. No. Occurrence" = FILTER(0)));
            CalcFormula = Count("Purchase Header Archive" WHERE("Document Type" = FILTER(Quote), "PR No." = FIELD("Document No."), "Version No." = field("Version No."), "Doc. No. Occurrence" = FILTER(0)));
            FieldClass = FlowField;
        }
        field(25; "PO No."; Integer)
        {
            CalcFormula = Count("Purchase Line Archive" WHERE("Document Type" = FILTER(Order), "PR No." = FIELD("Document No."), "PR Line No." = FIELD("Line No.")));
            FieldClass = FlowField;
        }
        field(26; Select; Boolean)
        {
        }
        field(27; ConvertedtoQuote; Boolean)
        {
        }
        field(28; "Quantity Converted to PO"; Decimal)
        {
            BlankZero = true;
            Editable = false;
        }
        field(29; "WBS ID"; Code[50])
        {
            Description = '#2';
            TableRelation = "Budget Import"."WBS ID" WHERE("Project ID" = FIELD("Shortcut dimension 2 code"));
        }
        field(30; "Activity ID"; Code[20])
        {
            Description = '#2';
            TableRelation = "Budget Import"."Activity ID" WHERE("Project ID" = FIELD("Shortcut dimension 2 code"),
                                                     "WBS ID" = FIELD("WBS ID"));
        }
        field(31; "Available Budget"; Decimal)
        {
            BlankZero = true;
            Editable = false;
        }
        field(32; ConvertedtoOrder; Boolean)
        {
        }
        field(33; "Reason for Shortlist"; Text[250])
        {
            Description = '#3';
        }
        field(34; "On Hold"; Decimal)
        {
            BlankZero = true;
        }
        field(35; Utilised; Decimal)
        {
            BlankZero = true;
        }
        field(36; "Unit Cost (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Unit Cost (LCY)';
        }
        field(37; "Amount (LCY)"; Decimal)
        {
            BlankZero = true;
        }
        field(38; "Archive Date Time"; DateTime)
        {
        }
        field(39; "Archive UserID"; Code[50])
        {
        }
        field(40; "Version No."; Integer)
        {
        }
        field(50005; "G/L Account No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Description = 'PR4.0';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "Document No.", "Line No.", "Version No.")
        {
        }
    }
}
