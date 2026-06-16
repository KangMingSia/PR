report 27003004 "Change Vendor"
{
    ApplicationArea = all;
    UsageCategory = Lists;
    ProcessingOnly = true;

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Vendor Code"; gVendorCode)
                {
                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        GVendor.RESET();
                        GVendor.SETRANGE("Prospect Vendor", false);
                        if PAGE.RUNMODAL(Page::"Vendor List", GVendor) = ACTION::LookupOK then
                            gVendorCode := GVendor."No.";
                    end;
                }
            }
        }


    }


    procedure SetPrQuoteNo(lPrQuoteNo: Code[20])
    begin
        gPrQuoteNo := lPrQuoteNo;
    end;

    trigger OnPostReport()
    var
        lPurchaseHeader: Record "Purchase Header";
    begin
        lPurchaseHeader.Reset();
        lPurchaseHeader.SetRange("Document Type", lPurchaseHeader."Document Type"::Quote);
        lPurchaseHeader.SetRange("No.", gPrQuoteNo);
        if lPurchaseHeader.FindFirst() then begin
            lPurchaseHeader.SetHideValidationDialog(true);
            lPurchaseHeader."Prospect Vendor" := lPurchaseHeader."Buy-from Vendor No.";
            lPurchaseHeader.Validate("Buy-from Vendor No.", gVendorCode);
            // Error('');
            lPurchaseHeader.Modify();
        end;
    end;

    var
        Window: Dialog;
        gVendorCode: Code[20];
        GVendor: Record Vendor;
        gPrQuoteNo: Code[20];
}

