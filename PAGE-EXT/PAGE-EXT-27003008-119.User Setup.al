pageextension 27003008 "User Setup-IBIZPR" extends "User Setup"
{
    layout
    {
        addafter(Email)
        {
            field("Purchaser"; "Purchaser")
            {
                ApplicationArea = All;
            }
            field("Shortcut Dimension 1 code"; "Shortcut Dimension 1 code")
            {
                ApplicationArea = All;
            }
            field("Shortcut Dimension 2 code"; "Shortcut Dimension 2 code")
            {
                ApplicationArea = All;
            }
        }
    }
}