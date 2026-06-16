tableextension 27003000 "G/L Account-IBIZPR" extends "G/L Account"
{
    fields
    {
        field(27003000; "Show in PR"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003001; "Budget Link A/C"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
    }
}