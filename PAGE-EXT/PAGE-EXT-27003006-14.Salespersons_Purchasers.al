pageextension 27003006 "Salespersons/Purchasers-IBIZPR" extends "Salespersons/Purchasers"
{
    layout
    {
        addafter("Phone No.")
        {
            field("Purchaser"; "Purchaser")
            {
                ApplicationArea = All;
            }
        }
    }
}