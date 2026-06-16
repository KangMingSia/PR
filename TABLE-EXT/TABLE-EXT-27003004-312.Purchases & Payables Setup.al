tableextension 27003004 "Purch. & Payables Setup-IBIZPR" extends "Purchases & Payables Setup"
{
    fields
    {
        field(27003000; "Purchase Requisition Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003001; "RFQ Comparison Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003002; "Purchase Requisition Arch Nos."; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(27003003; "Dimension for PR Approval"; Boolean)
        {
            DataClassification = CustomerContent;
            // Editable = false;
        }
        field(27003004; "PR/RFQ LOA Approval"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003005; "Budget Insufficient Email"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(27003006; "PR Budget Name"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "G/L Budget Name";
        }
        field(27003007; "Budget Start Date"; date)
        {
            DataClassification = CustomerContent;
        }
        field(27003008; "Budget End Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }

}