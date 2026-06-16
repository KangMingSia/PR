pageextension 27003018 "Item Card-Link" extends "Item Card"
{
    layout
    {
        addbefore("Gen. Prod. Posting Group")
        {
            group("IBIZ-PR")
            {
                field("PR Budget Checking"; Rec."PR Budget Checking")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
        addbefore(Inventory)
        {
            field("Inventory Value Zero."; "Inventory Value Zero") { ApplicationArea = all; }
        }
    }
}