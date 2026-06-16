pageextension 27003011 "Approval Entries-IBIZPR" extends "Approval Entries"
{
    layout
    {
        addafter("Approver ID")
        {
            field("Record Links Exist"; "Record Links Exist")
            {
                ApplicationArea = All;
            }
            field("PR Document Type"; "PR Document Type")
            {
                ApplicationArea = All;
            }
        }
    }
}