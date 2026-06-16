pageextension 27003003 "General Ledger Entries-IBIZPR" extends "General Ledger Entries"
{
    layout
    {
        addafter("External Document No.")
        {
            field("PR No."; "PR No.")
            {
                ApplicationArea = All;
            }
            field("PR Line No."; "PR Line No.")
            {
                ApplicationArea = All;
            }
        }
    }
}