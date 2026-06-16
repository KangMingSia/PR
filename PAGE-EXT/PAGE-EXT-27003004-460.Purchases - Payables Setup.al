pageextension 27003004 "Pur. & Payables Setup-IBIZPR" extends "Purchases & Payables Setup"
{
    layout
    {
        addafter("Ignore Updated Addresses")
        {
            group("IBIZ-PR1")
            {
                Caption = 'IBIZ-PR';
                field("Dimension for PR Approval"; "Dimension for PR Approval")
                {
                    ApplicationArea = All;
                    Visible = false;//19.0.0.8
                }
                field("PR/RFQ LOA Approval"; "PR/RFQ LOA Approval")
                {
                    ApplicationArea = All;
                }
                field("Budget Insufficient Email"; "Budget Insufficient Email")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("PR Budget Name"; "PR Budget Name")
                {
                    ApplicationArea = All;
                }
                field("Budget Start Date"; "Budget Start Date")
                {
                    ApplicationArea = All;
                }
                field("Budget End Date"; "Budget End Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        addafter("Price List Nos.")
        {
            group("IBIZ-PR")
            {
                field("Purchase Requisition Nos."; "Purchase Requisition Nos.")
                {
                    ApplicationArea = All;
                }
                field("RFQ Comparison Nos."; "RFQ Comparison Nos.")
                {
                    ApplicationArea = All;
                }
                field("Purchase Requisition Arch Nos."; "Purchase Requisition Arch Nos.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}