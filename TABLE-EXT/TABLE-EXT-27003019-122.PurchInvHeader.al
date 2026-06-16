tableextension 27003019 "Purch. Inv. Header-IBIZPR" extends "Purch. Inv. Header"
{
    fields
    {
        field(27003000; "RFQ No"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003001; "USERID PR to PQ"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003002; "USERID PR to PO"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003003; "USERID PQ to PO"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003004; "WBS ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003005; "Activity ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003006; "Budgetary PR"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003007; "PR No."; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003008; "PR Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003009; "Converted To PO"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003011; "Prospect Vendor"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27003012; "PR Requester"; Text[150])
        {

            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}