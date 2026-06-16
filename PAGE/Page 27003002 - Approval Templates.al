page 27003002 "Approval Templates"
{
    Caption = 'Approval Templates';
    PageType = List;
    SourceTable = "Approval Templates";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Approval Code"; "Approval Code")
                {
                    ApplicationArea = all;
                }
                field("Approval Type"; "Approval Type")
                {
                    ApplicationArea = all;
                }
                field("Document Type"; "Document Type")
                {
                    ApplicationArea = all;
                }
                field("Approval Routing"; "Approval Routing")
                {
                    ApplicationArea = all;
                }
                field("Limit Type"; "Limit Type")
                {
                    ApplicationArea = all;
                }
                field("PR to PO Amount Limit"; "PR to PO Amount Limit")
                {
                    ApplicationArea = all;
                }
                field("Petty Cash Limit"; "Petty Cash Limit")
                {
                    ApplicationArea = all;
                }
                field("No. series"; "No. series")
                {
                    ApplicationArea = all;
                }
                field("LOA Approval"; "LOA Approval")
                {
                    ApplicationArea = all;
                }
                field("Additional Approvers"; "Additional Approvers")
                {
                    ApplicationArea = all;
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = all;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = all;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = all;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = all;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(AdditionalAppr)
            {
                ApplicationArea = all;
                Caption = '&Additional Appr.';
                Image = Approval;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    AddApprovers.INIT;
                    AddApprovers.SETRANGE("Approval Code", "Approval Code");
                    AddApprovers.SETRANGE("Approval Type", "Approval Type");
                    AddApprovers.SETRANGE("Document Type", "Document Type");
                    AddApprovers.SETRANGE("Limit Type", "Limit Type");
                    AddApproverForm.SETTABLEVIEW(AddApprovers);
                    AddApproverForm.RUN;
                end;
            }
        }
    }

    var
        AddApprovers: Record "Additional Approvers";
        AddApproverForm: Page "Additional Approvers";
}

