tableextension 27003009 "Purch. Inv. Line-IBIZPR" extends "Purch. Inv. Line"
{
    fields
    {
        field(27003008; "WBS ID"; Code[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "Budget Import"."WBS ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"));
        }
        field(27003009; "Activity ID"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "Budget Import"."Activity ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"), "WBS ID" = FIELD("WBS ID"));
        }
        field(27003015; "PR No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(27003016; "PR Line No."; Integer)
        {
            DataClassification = CustomerContent;
        }
    }

}