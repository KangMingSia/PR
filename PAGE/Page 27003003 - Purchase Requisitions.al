page 27003003 "Purchase Requisitions"
{
    CardPageID = "Purchase Requisition Card";
    DeleteAllowed = false;
    Editable = false;
    PageType = List;
    SourceTable = "PR Header";
    SourceTableView = SORTING("No.");
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
                field("Purchaser Code"; "Purchaser Code")
                {
                    ApplicationArea = all;
                }
                field(Requester; Requester)
                {
                    ApplicationArea = all;
                }
                field("Co-ordinator"; "Co-ordinator")
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
                field("PR Status"; "PR Status")
                {
                    ApplicationArea = all;
                }
                field(Status; Status)
                {
                    ApplicationArea = all;
                }
                field("PR Document Type"; "PR Document Type")
                {
                    ApplicationArea = all;
                }
                field("LOA Status"; "LOA Status")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = all;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = all;
                }
                field("Released By"; "Released By")
                {
                    ApplicationArea = all;
                }
                field("Due Date"; "Due Date")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control5; Notes)
            {
                ApplicationArea = all;
            }
            systempart(Control12; Links)
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            // action("Page Filter")
            // {
            //     trigger OnAction()
            //     var
            //         lPR: Record "PR Header";
            //     begin
            //         Message(Rec.GetFilters);
            //         // Message(rec.GetView());
            //         // lPR.SetRecFilter();
            //         CurrPage.SetSelectionFilter(lPR);
            //         Message(lPR.GetFilters);
            //         lPR.Reset();
            //         CurrPage.SetTableView(lPR);
            //         Message(lPR.GetFilters);
            //     end;
            // }
            action("Approval Entries")
            {
                Caption = 'Approval Entries';
                Image = Approvals;
                ApplicationArea = all;
                trigger OnAction();
                begin
                    AppEntryRec.RESET;
                    // ApprovalEntries.Setfilters(DATABASE::"PR Header", AppEntryRec."PR Document Type"::PR, "No.");//Version 19.0.0.0>>//19.0.0.7
                    ApprovalEntries.SetRecordFilters(DATABASE::"PR Header", AppEntryRec."PR Document Type"::PR, "No.");//Version 19.0.0.0>>//19.0.0.7
                    ApprovalEntries.RUN;
                end;
            }
            action("Show Archived Documents")
            {
                Image = Archive;
                ApplicationArea = all;
                RunObject = Page "PR Arch. List";
                RunPageLink = "PR No." = FIELD("No.");
            }
            // action("Update User")
            // {
            //     Image = User;
            //     ApplicationArea = all;
            //     trigger OnAction()
            //     var
            //         lUser: Record User;
            //         lUserCard: Page "User Card";
            //     begin
            //         lUser.SetRange("User Name", 'DEVSERVER4\ERLEEN');
            //         if lUser.FindFirst() then
            //             lUser.ModifyAll("Change Password", true, false);
            //     end;
            // }
        }
    }

    trigger OnOpenPage();
    var
        UserLocationFilter: Text[1024];
        UserBranchFilter: Text[1024];
        WhseEmployee: Record "Warehouse Employee";
        ObjectID: Integer;
    begin
        if UserSetup.GET(USERID) and (UserSetup."Shortcut Dimension 1 code" <> '') then begin
            FILTERGROUP(2);
            SETFILTER("Shortcut Dimension 1 Code", UserBranchFilter);
            FILTERGROUP(0);
        end;
        if UserSetup.GET(USERID) and (UserSetup."Shortcut Dimension 2 code" <> '') then begin
            FILTERGROUP(2);
            SETFILTER("Shortcut Dimension 2 Code", UserBranchFilter);
            FILTERGROUP(0);
        end;
    end;

    var
        AppEntryRec: Record "Approval Entry";
        ApprovalEntries: Page "Approval Entries";
        UserSetup: Record "User Setup";
}

