pageextension 27003019 "Budget-Link" extends "Budget"
{
    actions
    {
        addafter("Reverse Lines and Columns")
        {
            action("Budget Swapping")
            {
                Image = Change;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    Page.Run(Page::"Budget Swapping");
                end;
            }
        }
    }
}