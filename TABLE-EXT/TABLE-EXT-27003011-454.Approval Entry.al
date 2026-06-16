tableextension 27003011 "Approval Entry-IBIZPR" extends "Approval Entry"
{
    fields
    {
        field(27003000; "Record Links Exist"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("Record Link" WHERE("Record ID" = FIELD("Record ID to Approve"), Type = CONST(Link)));
            Editable = false;
        }

        // field(27003001; "PR Document Type"; Option)//Version 19.0.0.0>>
        field(27003001; "PR Document Type"; Enum "Approval Document Type")//Version 19.0.0.0>>
        {
            // OptionMembers = Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order",,,,,PR,RFQC,MR,;//Version 19.0.0.0>>
            DataClassification = CustomerContent;
        }
    }

}