page 27003022 "Budget Swapping Entries"
{
    ApplicationArea = all;
    UsageCategory = History;
    Editable = false;
    PageType = List;
    SourceTable = "Budget Swap Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                }
                field("Budget Name"; "Budget Name")
                {
                }
                field("User ID"; "User ID")
                {
                }
                field("Transfer Date"; "Transfer Date")
                {
                }
                field("Transfer Time"; "Transfer Time")
                {
                }
                field("From G/L Account"; "From G/L Account")
                {
                }
                field("From Cost center"; "From Cost center")
                {
                }
                field("To G/L Account"; "To G/L Account")
                {
                }
                field("To Cost center"; "To Cost center")
                {
                }
                field("Amount Transfer"; "Amount Transfer")
                {
                }
            }
        }
    }

    actions
    {
    }
}

