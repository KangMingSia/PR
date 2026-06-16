tableextension 27003005 "No. Series-IBIZPR" extends "No. Series"
{
    fields
    {
        field(27003000; "PR Quote"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003001; "PR Order"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003002; "RFQ Comparison"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003003; "Enable Project Budget"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003004; "Enable GL Budget"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

}