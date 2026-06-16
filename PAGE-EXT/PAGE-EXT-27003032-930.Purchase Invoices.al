pageextension 27003032 "Purchase Invoices-IBIZPR" extends "Purchase Invoices"
{
    layout
    {
        addlast(Control1)
        {
            field("USERID PR to PO"; "USERID PR to PO") { ApplicationArea = All; }
            field("USERID PQ to PO"; "USERID PQ to PO") { ApplicationArea = All; }
            // field("USERID PR to PQ"; "USERID PR to PQ") { ApplicationArea = All; }
            field("PR Requester"; "PR Requester") { ApplicationArea = All; }
            field("PR No."; "PR No.") { ApplicationArea = All; }
            // field("Quote No."; "Quote No.") { ApplicationArea = All; }
            field("Purchaser Code1"; "Purchaser Code") { Caption = 'Purchaser Code'; ApplicationArea = All; }
        }
    }
}