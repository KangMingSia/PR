pageextension 27003010 "Pos. Purch. Cr.M Subfrm-IBIZPR" extends "Posted Purch. Cr. Memo Subform"
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