table 27003010 "PR Arch. Suggested Vendor"
{
    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionCaption = '" ,PR Header,PR Line"';
            OptionMembers = " ","PR Header","PR Line";
        }
        field(2; "PR Arch. No."; Code[20])
        {
        }
        field(3; "PR Arch. Line No."; Integer)
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
        field(8; "PR No."; Code[20])
        {
        }
        field(9; "PR Line No."; Integer)
        {
        }
        field(10; "Version No."; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "Document Type", "PR Arch. No.", "PR Arch. Line No.", "Line no.", "Version No.")
        {
        }
    }
}

