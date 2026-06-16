pageextension 27003027 "Posted Purchase Rcpt -IBIZPR" extends "Posted Purchase Receipt"
{
    layout
    {
        addlast(General)
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