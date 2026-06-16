page 27003018 "Approval Code"
{
    Caption = 'Approval Code';
    PageType = List;
    SourceTable = "Approval Code";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Code"; Code)
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("Linked To Table No."; "Linked To Table No.")
                {
                    ApplicationArea = all;
                    LookupPageID = "Table Objects";
                }
                field("Linked To Table Name"; "Linked To Table Name")
                {
                    ApplicationArea = all;
                    Editable = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = all;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = all;
            }
        }
    }
}

