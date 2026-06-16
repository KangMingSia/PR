page 27003004 "Suggested vendor"
{
    AutoSplitKey = true;
    MultipleNewLines = true;
    PageType = List;
    SourceTable = "Suggested Vendor";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Suggested Vendor"; "Suggested Vendor")
                {
                    ApplicationArea = all;
                }
                field("Vendor card Name"; "Vendor card Name")
                {
                    ApplicationArea = all;
                    Caption = 'Vendor Name';
                }
            }
        }
    }
}

