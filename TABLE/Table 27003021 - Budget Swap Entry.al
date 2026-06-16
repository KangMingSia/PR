table 27003021 "Budget Swap Entry"
{
    // version SWAP1.0


    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = false;
            Caption = 'Entry No.';
        }
        field(2; "Budget Name"; Code[10])
        {
        }
        field(12; "User ID"; Code[50])
        {
            Caption = 'User ID';
            Editable = false;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;

            trigger OnLookup();
            var
                UserMgt: Codeunit "User Management";
            begin
            end;
        }
        field(13; "Transfer Date"; Date)
        {
        }
        field(14; "Transfer Time"; Time)
        {
        }
        field(15; "From G/L Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(16; "From Cost center"; Code[20])
        {
            TableRelation = "Dimension Value" WHERE("Dimension Code" = CONST('COSTCENTER'));
        }
        field(17; "To G/L Account"; Code[20])
        {
            TableRelation = "G/L Account";
        }
        field(18; "To Cost center"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = CONST('COSTCENTER'));
        }
        field(19; "Amount Transfer"; Decimal)
        {
        }
        field(20; "From Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("From Global Dimension 2 Code"));
        }
        field(21; "To Global Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,1,2';
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("To Global Dimension 2 Code"));
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

