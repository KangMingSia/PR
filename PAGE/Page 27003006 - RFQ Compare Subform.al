page 27003006 "RFQ Compare Subform"
{
    AutoSplitKey = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Line";

    layout
    {
        area(content)
        {
            repeater(Control1000000012)
            {
                field("Create PO"; "Create PO")
                {
                    ApplicationArea = all;
                }

                field("Document No."; "Document No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Buy-from Vendor No."; "Buy-from Vendor No.")
                {
                    ApplicationArea = all;
                    Enabled = false;
                }
                field(Type; Type)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Vendor Due Date"; "Vendor Due Date")
                {
                    ApplicationArea = all;
                    //  Editable = false;
                }
                field("RFQ Date"; "RFQ Date")
                {
                    ApplicationArea = all;
                    //Editable = false;
                }
                field("No."; "No.")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = all;
                }
                field("Line Amount"; "Line Amount")
                {
                    ApplicationArea = all;
                }
                field("Outstanding Amount (LCY)"; "Outstanding Amount (LCY)")
                {
                    ApplicationArea = all;
                }
                field("Reason for Shortlist"; "Reason for Shortlist")
                {
                    ApplicationArea = all;
                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RFQ)
            {
                Caption = 'Quotation';
                ApplicationArea = all;
                trigger OnAction();
                begin
                    PQuote.SETRANGE("No.", Rec."Document No.");
                    PAGE.RUN(49, PQuote);
                end;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if rec."RFQ Date" = 0D then
            rec."RFQ Date" := WorkDate();
        if rec."Vendor Due Date" = 0D then
            rec."Vendor Due Date" := WorkDate();
        rec.Modify();
    end;

    var
        PQuote: Record "Purchase Header";
}

