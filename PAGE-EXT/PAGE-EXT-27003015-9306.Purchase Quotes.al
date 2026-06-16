pageextension 27003015 "Purchase Quotes-IBIZPR" extends "Purchase Quotes"
{
    layout
    {
        addafter("Buy-from Vendor No.")
        {
            field("PR No."; "PR No.")
            {
                ApplicationArea = All;
            }
        }
    }
}