table 27003005 "Suggested Vendor"
{
    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionCaption = '" ,PR Header,PR Line"';
            OptionMembers = " ","PR Header","PR Line";
        }
        field(2; "PR No."; Code[20])
        {
        }
        field(3; "PR Line No."; Integer)
        {
        }
        field(4; "Suggested Vendor"; Code[20])
        {
            TableRelation = Vendor;
        }
        field(5; "Vendor Name"; Text[150])
        {
        }
        field(6; "Line no."; Integer)
        {
        }
        field(7; Converted; Boolean)
        {
        }
        field(8; "Vendor card Name"; Text[150])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Suggested Vendor")));
            Editable = false;
            FieldClass = FlowField;
        }
    }
    keys
    {
        key(Key1; "Document Type", "PR No.", "PR Line No.", "Line no.")
        {
        }
    }
}

