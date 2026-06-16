table 27003014 "GST Scenario"
{

    LookupPageID = "GST Scenarios";

    fields
    {
        field(1; "GST Scenario Code"; Code[20])
        {
        }
        field(2; Description; Text[250])
        {
        }
        field(3; "GST Prod. Posting Group"; Code[10])
        {
            TableRelation = "VAT Product Posting Group".Code;
        }
        field(4; "GST Bus. Posting Group"; Code[10])
        {
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(5; "Gen. Posting Type"; Option)
        {
            OptionCaption = '" ,Purchase,Sale"';
            OptionMembers = " ",Purchase,Sale;
        }
        field(6; "Bal. GST Prod. Posting Group"; Code[10])
        {
            TableRelation = "VAT Product Posting Group".Code;
        }
        field(7; "Bal. GST Bus. Posting Group"; Code[10])
        {
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(8; "Bal. Posting Type"; Option)
        {
            OptionCaption = '" ,Purchase,Sale"';
            OptionMembers = " ",Purchase,Sale;
        }
        field(9; "No Tax Code"; Boolean)
        {
        }
        field(10; "GST Identifier"; Code[20])
        {
            CalcFormula = Lookup("VAT Posting Setup"."VAT Identifier" WHERE("VAT Bus. Posting Group" = FIELD("GST Bus. Posting Group"),
                                                                             "VAT Prod. Posting Group" = FIELD("GST Prod. Posting Group")));
            Caption = 'GST Identifier';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "GST Scenario Code")
        {
        }
    }
}

