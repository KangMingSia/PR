page 27003016 "GST Scenarios"
{
    PageType = List;
    SourceTable = "GST Scenario";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("GST Scenario Code"; "GST Scenario Code")
                {
                    ApplicationArea = all;
                }
                field(Description; Description)
                {
                    ApplicationArea = all;
                }
                field("GST Prod. Posting Group"; "GST Prod. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("GST Bus. Posting Group"; "GST Bus. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Gen. Posting Type"; "Gen. Posting Type")
                {
                    ApplicationArea = all;
                }
                field("GST Identifier"; "GST Identifier")
                {
                    ApplicationArea = all;
                }
                field("Bal. GST Prod. Posting Group"; "Bal. GST Prod. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Bal. GST Bus. Posting Group"; "Bal. GST Bus. Posting Group")
                {
                    ApplicationArea = all;
                }
                field("Bal. Posting Type"; "Bal. Posting Type")
                {
                    ApplicationArea = all;
                }
                field("No Tax Code"; "No Tax Code")
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

    trigger OnOpenPage();
    begin

        CurrPage.EDITABLE(not CurrPage.LOOKUPMODE); //GST2.00
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Text50002: Label 'You must first enable GST Malaysia in General Ledger Setup';
}

