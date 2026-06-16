tableextension 27003018 "Item-IBIZPR" extends "Item"
{
    fields
    {
        field(27003000; "PR Budget Checking"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Lookup("Gen. Product Posting Group"."PR Budget Checking" WHERE(Code = FIELD("Gen. Prod. Posting Group")));
        }
    }

}