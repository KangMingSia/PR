table 27003007 "Budget Import"
{
    fields
    {
        field(1; "Project ID"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
            ValidateTableRelation = false;
        }
        field(2; "WBS ID"; Code[50])
        {
        }
        field(3; "WBS Name"; Text[150])
        {
        }
        field(4; "Activity ID"; Code[20])
        {

            trigger OnValidate();
            begin

                GBudgetImport.RESET;
                GBudgetImport.SETRANGE("Project ID", "Project ID");
                GBudgetImport.SETRANGE("WBS ID", "WBS ID");
                GBudgetImport.SETRANGE("Activity ID", "Activity ID");
                if GBudgetImport.FINDFIRST then
                    ERROR(GText001, "Project ID", "WBS ID", "Activity ID");
            end;
        }
        field(5; "Activity Name"; Text[150])
        {
        }
        field(6; "Budgeted Total Cost"; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "Project ID")
        {
        }
    }

    fieldgroups
    {
    }

    var
        GBudgetImport: Record "Budget Import";
        GText001: Label 'Budget Line with Project ID " %1  "  WBS ID  " %2 " and Activity ID "%3"';
}

