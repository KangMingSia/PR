page 27003017 "G/L Account Scenarios"
{
    PageType = List;
    SourceTable = "G/L Account Scenario";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("G/L Account No."; "G/L Account No.")
                {
                    Visible = false;
                    ApplicationArea = all;
                }
                field("GST Scenario"; "GST Scenario")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
            }
        }
    }
    trigger OnInit();
    begin
        GLSetup.GET;
        // if not GLSetup."GST Malaysia" = true then
        //   ERROR(Text50002);
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Text50002: Label 'You must first enable GST Malaysia in General Ledger Setup';
}

