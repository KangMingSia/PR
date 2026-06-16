table 27003004 "RFQ Compare Line"
{
    fields
    {
        field(1; "RFQ Compare No."; Code[20])
        {
        }
        field(2; "Purchase Quote No"; Code[20])
        {
        }
        field(3; "Purchase Quote Line No"; Integer)
        {
        }
        field(4; Type; Option)
        {
            OptionCaption = '" ,G/L Account,Item,,Fixed Asset,Charge (Item)"';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
        }
        field(5; No; Code[20])
        {
        }
        field(6; UOM; Code[10])
        {
        }
        field(7; Quantity; Decimal)
        {
        }
        field(8; "Unit Price"; Decimal)
        {
        }
        field(9; "Line Amount"; Decimal)
        {
        }
        field(10; Intendation; Integer)
        {
        }
    }

    keys
    {
        key(Key1; "RFQ Compare No.", "Purchase Quote No", "Purchase Quote Line No")
        {
        }
    }

    fieldgroups
    {
    }
}

