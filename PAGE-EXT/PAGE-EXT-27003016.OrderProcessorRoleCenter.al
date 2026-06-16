pageextension 27003016 "OrderProcessorRoleCenter-Link" extends "Order Processor Role Center"
{

    actions
    {
        addlast(Reporting)
        {
            group("IBIZCS-PR")
            {
                action("Purchases & Payables Setup")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Purchases & Payables Setup";
                }
                action("General Ledger Setup")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "General Ledger Setup";
                }
                action("No. Series")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "No. Series";
                }
                action("Salespersons/Purchasers")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Salespersons/Purchasers";
                }
                action("Gen. Product Posting Groups")
                {
                    ApplicationArea = All;
                    Caption = 'Gen. Product Posting Groups';
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Gen. Product Posting Groups";
                }
                action("Item List")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Caption = 'Items';
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Item List";
                }
                action("G/L Budget Names")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Caption = 'G/L Budget';
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "G/L Budget Names";
                }
                action("Chart of Accounts")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Caption = 'G/L Account';
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Chart of Accounts";
                }
                action("Purchase Requisitions")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Purchase Requisitions";
                }
                action("Approval Entries")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Approval Entries";
                }
                action("Requests to Approve")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Requests to Approve";
                }
                action("RFQ Comparisons")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "RFQ Comparisons";
                }
                action("PR Arch. List")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "PR Arch. List";
                }
                action("Purchase Quotes1")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Caption = 'Purchase Quotes';
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Purchase Quotes";
                }
                action("Purchase Order List")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Caption = 'Purchase Orders';
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Purchase Order List";
                }
                action("Budget Swapping")
                {
                    ApplicationArea = All;
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = Page "Budget Swapping";
                }
                // action("Budget Availability Final")
                // {
                //     ApplicationArea = All;
                //     Image = Continue;
                //     Promoted = true;
                //     PromotedCategory = Category8;
                //     RunObject = report "Budget Availability Final";
                // }
                // action("Budget Availability Report")
                // {
                //     ApplicationArea = All;
                //     Image = Continue;
                //     Promoted = true;
                //     PromotedCategory = Category8;
                //     RunObject = report "Budget Availability-Unitar";
                // }
                // action("Budget Availability Report-v2")
                // {
                //     ApplicationArea = All;
                //     Image = Continue;
                //     Promoted = true;
                //     PromotedCategory = Category8;
                //     RunObject = report "Budget Availability-UnitarV2";
                // }
                action("Budget Availability-Multi Dimension")
                {
                    ApplicationArea = All;
                    Caption = 'Budget Availability-Multi Dimension';
                    Image = Continue;
                    Promoted = true;
                    PromotedCategory = Category8;
                    RunObject = report "Budget Avail.-Multi Dimension";
                }
            }
        }
    }
}