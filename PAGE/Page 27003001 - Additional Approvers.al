page 27003001 "Additional Approvers"
{
    AutoSplitKey = true;
    Caption = 'Additional Approvers';
    PageType = List;
    SourceTable = "Additional Approvers";
    SourceTableView = SORTING("Sequence No.");
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Approver ID"; "Approver ID")
                {
                    ApplicationArea = all;
                }
                field("Limit Type"; "Limit Type")
                {
                    ApplicationArea = all;
                }
                field("Approval Code"; "Approval Code")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Approval Type"; "Approval Type")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("Sequence No."; "Sequence No.")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = all;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = all;
                Visible = false;
            }
        }
    }

}

