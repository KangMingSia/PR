page 27003009 "PR Archive Card"
{
    PageType = Document;
    SourceTable = "PR Arch. Header";
    Editable = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("No."; "No.")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
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
                field("Delivery Location"; "Delivery Location")
                {
                    ApplicationArea = all;
                }
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = all;
                }
                field("Version No."; "Version No.")
                {
                    ApplicationArea = all;
                }
                field(Requester; Requester)
                {
                    ApplicationArea = all;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }
                field("PR Type"; "PR Type")
                {
                    ApplicationArea = all;
                }
                field("PR Status"; "PR Status")
                {
                    ApplicationArea = all;
                }
            }
            group(Miscellanous)
            {
                field("USER ID"; "USER ID")
                {
                    ApplicationArea = all;
                }
                field("Date Created"; "Date Created")
                {
                    ApplicationArea = all;
                }
                field("Last Modified Date"; "Last Modified Date")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = all;
                }
            }
            part(Control1000000021; "PR Archive Line subform")
            {
                Caption = 'Line';
                ApplicationArea = all;
                SubPageLink = "Document No." = FIELD("No."), "Version No." = field("Version No.");
                SubPageView = SORTING("Document No.")
                              ORDER(Ascending);
            }
        }
    }
}

