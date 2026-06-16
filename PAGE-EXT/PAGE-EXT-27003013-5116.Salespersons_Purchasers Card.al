pageextension 27003013 "Salesp./Purchaser Card-IBIZPR" extends "Salesperson/Purchaser Card"
{
    layout
    {
        addafter("Next Task Date")
        {
            field("Purchaser"; "Purchaser")
            {
                ApplicationArea = All;
            }
        }
    }
}