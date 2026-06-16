pageextension 27003000 "G/L Account Card-IBIZPR" extends "G/L Account Card"
{
    layout
    {
        addafter("Last Date Modified")
        {
            field("Show in PR"; "Show in PR")
            {
                ApplicationArea = All;
            }
            field("Budget Link A/C"; "Budget Link A/C")
            {
                ApplicationArea = All;
            }
        }
    }

}