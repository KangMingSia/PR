pageextension 27003031 "Purchase Invoice-IBIZPR" extends "Purchase Invoice"
{
    layout
    {
        addafter(Status)
        {
            field("RFQ No"; "RFQ No") { ApplicationArea = All; }
            field("USERID PR to PO"; "USERID PR to PO") { ApplicationArea = All; Editable = false; }
            field("USERID PQ to PO"; "USERID PQ to PO") { ApplicationArea = All; Editable = false; }
            field("PR No."; "PR No.") { ApplicationArea = All; }
            field("PR Requester"; "PR Requester") { ApplicationArea = All; }
        }
        modify("Buy-from Vendor No.") { Enabled = boolEnablePrField; }
        modify("Buy-from Vendor Name") { Enabled = boolEnablePrField; }
        modify("Buy-from Address") { Enabled = boolEnablePrField; }
        modify("Buy-from Address 2") { Enabled = boolEnablePrField; }
        modify("Buy-from City") { Enabled = boolEnablePrField; }
        modify("Buy-from County") { Enabled = boolEnablePrField; }
        modify("Buy-from Post Code") { Enabled = boolEnablePrField; }
        modify("Buy-from Country/Region Code") { Enabled = boolEnablePrField; }
        modify("Buy-from Contact No.") { Enabled = boolEnablePrField; }
        modify("Buy-from Contact") { Enabled = boolEnablePrField; }
        modify("Shortcut Dimension 1 Code") { Enabled = boolEnablePrField; }
        modify("Shortcut Dimension 2 Code") { Enabled = boolEnablePrField; }
    }
    trigger OnAfterGetCurrRecord()
    begin
        if Rec."PR No." = '' then
            boolEnablePrField := true
        else
            boolEnablePrField := false;
    end;

    var
        boolEnablePrField: Boolean;
}