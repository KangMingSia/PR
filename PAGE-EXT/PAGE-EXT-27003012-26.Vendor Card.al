pageextension 27003012 "Vendor Card-IBIZPR" extends "Vendor Card"
{
    layout
    {
        addafter("Balance (LCY)")
        {
            field("Prospect Vendor"; "Prospect Vendor")
            {
                ApplicationArea = All;
            }
        }
    }
}