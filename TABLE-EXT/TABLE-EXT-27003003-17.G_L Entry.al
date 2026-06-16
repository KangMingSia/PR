tableextension 27003003 "G/L Entry-IBIZPR" extends "G/L Entry"
{
    fields
    {
        field(27003000; "PR No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(27003001; "PR Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
    }
}