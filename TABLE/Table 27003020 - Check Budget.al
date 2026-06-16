table 27003020 "Check Budget Buffer"
{
    Caption = 'Check Budget Buffer';
    // TableType = Temporary;
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "PR No."; Code[20]) { }
        field(3; "PR Line No."; Integer) { }
        field(4; Type; Enum "Purchase Line Type")
        {
            Caption = 'Type';
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST("G/L Account")) "G/L Account"."No." WHERE("Show in PR" = CONST(true))
            ELSE
            IF (Type = CONST(Item)) Item."No."
            ELSE
            // IF (Type = CONST(Description)) "Standard Text"//19.0.0.5
            IF (Type = CONST(" ")) "Standard Text"//19.0.0.5
            ELSE
            IF (Type = CONST("Fixed Asset")) "Fixed Asset";
        }
        field(6; "Vendor No."; Code[20]) { }
        field(7; "Purchase Account"; Code[20]) { }
        field(8; "Available Budget"; Decimal) { }
        field(9; "Total Budget"; Decimal) { }
        field(10; "Used Budget"; Decimal) { }
        field(11; "On Hold"; Decimal) { BlankZero = true; }
        field(12; Utilised; Decimal) { BlankZero = true; }
    }

    keys { key(Key1; "Entry No.") { } }

    fieldgroups { }

    var
        Text001: Label 'You cannot have negative values in %1.';
}

