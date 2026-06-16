tableextension 27003016 "Purchase Line Archive-IBIZPR" extends "Purchase Line Archive"
{
    fields
    {
        field(27003000; "Create PO"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003001; "PQ No"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003002; "PQ Line No"; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003003; "RFQ No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003004; "Converted to PO"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003005; "PO No"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(27003006; "PO Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003007; "Requested Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003008; "WBS ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Enabled = false;
            //ValidateTableRelation = true;
        }
        field(27003009; "Activity ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Enabled = false;
            //ValidateTableRelation = true;
        }
        field(27003010; "Remarks"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(27003011; "Reason for Shortlist"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(27003012; "Bold"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003013; "PR In G/L"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = Exist("G/L Entry" WHERE("PR No." = FIELD("PR No."), "PR Line No." = FIELD("PR Line No.")));
            Editable = false;
        }
        field(27003014; "G/L Total Amt for PR"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = Sum("G/L Entry".Amount WHERE("G/L Account No." = FIELD("No."), "PR No." = FIELD("PR No."), "PR Line No." = FIELD("PR Line No.")));
            Editable = false;
        }
        field(27003015; "PR No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003016; "PR Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

}