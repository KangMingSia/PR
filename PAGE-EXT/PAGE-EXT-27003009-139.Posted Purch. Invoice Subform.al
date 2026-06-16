pageextension 27003009 "Pos. Purch. Inv. Subfrm-IBIZPR" extends "Posted Purch. Invoice Subform"
{
    layout
    {
        addafter("Deferral Code")
        {
            field("WBS ID"; "WBS ID")
            {
                ApplicationArea = All;
            }
            field("Activity ID"; "Activity ID")
            {
                ApplicationArea = All;
            }
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