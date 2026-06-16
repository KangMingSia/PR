page 27003007 "RFQ Comparisons"
{
    CardPageID = "RFQ Comparison";
    Editable = false;
    PageType = List;
    SourceTable = "RFQ Comparison";
    ApplicationArea = All;
    UsageCategory = Documents;

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
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }


                field("Co-ordinator"; "Co-ordinator")
                {
                    ApplicationArea = all;
                }
                field(Requester; Requester)
                {
                    ApplicationArea = all;
                }
                field("PR No"; "PR No")
                {
                    ApplicationArea = all;
                }
            }
        }
    }

}

