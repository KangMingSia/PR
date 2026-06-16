page 27003008 "Document Approval PR"
{
    PageType = List;
    SourceTable = "Document Approval Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; "User ID")
                {
                    ApplicationArea = all;
                }
                field("Approval Routing"; "Approval Routing")
                {
                    ApplicationArea = all;
                }
                field("Approver ID"; "Approver ID")
                {
                    ApplicationArea = all;
                }
                field("Salespers./Purch. Code"; "Salespers./Purch. Code")
                {
                    ApplicationArea = all;
                }
                field("Purchase Amount Approval Limit"; "Purchase Amount Approval Limit")
                {
                    ApplicationArea = all;
                }
                field("Unlimited Purchase Approval"; "Unlimited Purchase Approval")
                {
                    ApplicationArea = all;
                }
                field(Substitute; Substitute)
                {
                    ApplicationArea = all;
                }
                field("E-Mail"; "E-Mail")
                {
                    ApplicationArea = all;
                }
                field("Request Amount Approval Limit"; "Request Amount Approval Limit")
                {
                    ApplicationArea = all;
                }
                field("Unlimited Request Approval"; "Unlimited Request Approval")
                {
                    ApplicationArea = all;
                }
                field("Finance User"; "Finance User")
                {
                    ApplicationArea = all;
                }
            }
        }
    }
}

