page 27003020 "Check Budget"
{
    ApplicationArea = All;
    Caption = 'Check Budget';
    PageType = ListPart;
    SourceTable = "Check Budget Buffer";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("PR No."; Rec."PR No.")
                {
                    ToolTip = 'Specifies the value of the PR No. field.';
                    ApplicationArea = All;
                    Visible = false;
                }
                field("PR Line No."; Rec."PR Line No.")
                {
                    ToolTip = 'Specifies the value of the PR Line No. field.';
                    ApplicationArea = All;
                }
                field("Type"; Rec."Type")
                {
                    ToolTip = 'Specifies the value of the Type field.';
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the value of the No. field.';
                    ApplicationArea = All;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                    ApplicationArea = All;
                }
                field("Purchase Account"; Rec."Purchase Account")
                {
                    ToolTip = 'Specifies the value of the Purchase Account field.';
                    ApplicationArea = All;
                }
                field("Total Budget"; Rec."Total Budget")
                {
                    ToolTip = 'Specifies the value of the Total Budget field.';
                    ApplicationArea = All;
                }
                field("Used Budget"; Rec."Used Budget")
                {
                    ToolTip = 'Specifies the value of the Used Budget field.';
                    ApplicationArea = All;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ToolTip = 'Specifies the value of the On Hold Budget field.';
                    ApplicationArea = All;
                }
                field(Utilised; Rec.Utilised)
                {
                    ToolTip = 'Specifies the value of the Utilised Budget field.';
                    ApplicationArea = All;
                }
                field("Available Budget"; Rec."Available Budget")
                {
                    ToolTip = 'Specifies the value of the Available Budget field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
