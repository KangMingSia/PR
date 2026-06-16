pageextension 27003005 "No. Series-IBIZPR" extends "No. Series"
{
    layout
    {
        addafter("Date Order")
        {
            field("PR Quote"; "PR Quote")
            {
                ApplicationArea = All;
            }
            field("PR Order"; "PR Order")
            {
                ApplicationArea = All;
            }
            field("RFQ Comparison"; "RFQ Comparison")
            {
                ApplicationArea = All;
            }
            field("Enable Project Budget"; "Enable Project Budget")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("Enable GL Budget"; "Enable GL Budget")
            {
                ApplicationArea = All;
            }
        }
    }
}