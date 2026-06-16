page 27003012 "PR Arch. Suggested vendor"
{
    PageType = List;
    SourceTable = "PR Arch. Suggested Vendor";
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
                field("Vendor Name"; "Vendor Name")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}

