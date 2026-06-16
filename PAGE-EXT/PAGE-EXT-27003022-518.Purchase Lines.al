pageextension 27003022 "Purchase Lines-IBIZPR" extends "Purchase Lines"
{
    actions
    {
        modify("Show Document") { Visible = false; }
        addafter("Show Document")
        {
            action("Show Document PR")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Document';
                Image = View;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Shift+F7';
                ToolTip = 'Open the document that the selected line exists on.';

                trigger OnAction()
                var
                    PageManagement: Codeunit "Page Management";
                    PurchHeader: Record "Purchase Header";
                begin
                    if rec."Document Type" = rec."Document Type"::Order then begin
                        PurchHeader.Get("Document Type", "Document No.");
                        Page.RunModal(Page::"Purchase Order", PurchHeader);
                    end else begin
                        PurchHeader.Get("Document Type", "Document No.");
                        PageManagement.PageRun(PurchHeader);
                    end;
                end;
            }
        }
    }
}