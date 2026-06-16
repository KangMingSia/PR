pageextension 27003017 "Gen. Product Post. Grp-Link" extends "Gen. Product Posting Groups"
{
    layout
    {
        addbefore("Auto Insert Default")
        {
            field("PR Budget Checking"; Rec."PR Budget Checking")
            {
                ApplicationArea = All;
            }
        }
    }
}