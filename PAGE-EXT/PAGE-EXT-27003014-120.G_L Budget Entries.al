pageextension 27003014 "G/L Budget Entries-IBIZPR" extends "G/L Budget Entries"
{
    layout
    {
        addafter(Amount)
        {
            field("Budget Swapping No."; "Budget Swapping No.")
            {
                ApplicationArea = All;
            }
        }
    }
}