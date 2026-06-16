page 27003011 "PR Arch. List"
{
    CardPageID = "PR Archive Card";
    Editable = false;
    PageType = List;
    SourceTable = "PR Arch. Header";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field("Version No."; "Version No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("PR Date"; "PR Date")
                {
                    ApplicationArea = all;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}

