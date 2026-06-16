page 27003010 "PR Archive Line subform"
{
    AutoSplitKey = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "PR Arch. Line";
    Editable = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Type; Type)
                {
                    ApplicationArea = all;
                }
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = all;
                }
                field("Unit of  Measure"; "Unit of  Measure")
                {
                    ApplicationArea = all;
                }
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = all;
                }
                field("Expected Receipt Date"; "Expected Receipt Date")
                {
                    ApplicationArea = all;
                }
                field("PR Status"; "PR Status")
                {
                    ApplicationArea = all;
                }
                field("Unit Cost"; "Unit Cost")
                {
                    ApplicationArea = all;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = all;
                }
                field(Remarks; Remarks)
                {
                    ApplicationArea = all;
                }
                field("Shortcut dimension 1 code"; "Shortcut dimension 1 code")
                {
                    ApplicationArea = all;
                }
                field("PO No."; "PO No.")
                {
                    ApplicationArea = all;
                }
                field("RFQ No."; "RFQ No.")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}

