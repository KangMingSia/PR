table 27003015 "G/L Account Scenario"
{

    LookupPageID = "G/L Account Scenarios";

    fields
    {
        field(1; "G/L Account No."; Code[20])
        {
            TableRelation = "G/L Account"."No.";
        }
        field(2; "GST Scenario"; Code[20])
        {
            TableRelation = "GST Scenario"."GST Scenario Code";
        }
        field(3; Description; Text[250])
        {
            CalcFormula = Lookup("GST Scenario".Description WHERE("GST Scenario Code" = FIELD("GST Scenario")));
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "G/L Account No.", "GST Scenario")
        {
        }
    }

}

