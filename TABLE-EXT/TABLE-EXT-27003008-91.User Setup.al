tableextension 27003008 "User Setup-IBIZPR" extends "User Setup"
{
    fields
    {
        field(27003000; "Purchaser"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003001; "Shortcut Dimension 1 code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,1,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(27003002; "Shortcut Dimension 2 code"; Code[20])
        {
            DataClassification = CustomerContent;
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
    }
}