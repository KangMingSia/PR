report 27003023 "Request For Quotation"
{
    Caption = 'Request For Quotation';
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/RequestForQuotation.rdl';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(PageLoop; "Integer")
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));
            column(HomePage; CompanyInfo."Home Page")
            {
            }
            column(EMail; CompanyInfo."E-Mail")
            {
            }
            column(CompanyPicture; CompanyInfo.Picture)
            {
            }
            column(CompanyInfo2Picture; CompanyInfo2.Picture)
            {
            }
            column(CompanyInfo1Picture; CompanyInfo1.Picture)
            {
            }
            column(CompanyInfoPicture; CompanyInfo.Picture)
            {
            }
            column(CompanyInfo3Picture; CompanyInfo3.Picture)
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyInfoPhoneNo; CompanyInfo."Phone No.")
            {
            }
            column(CompanyInfoVATRegNo; CompanyInfo."VAT Registration No.")
            {
            }
            column(CompanyInfoGiroNo; CompanyInfo."Giro No.")
            {
            }
            column(CompanyInfoBankName; CompanyInfo."Bank Name")
            {
            }
            column(CompanyInfoBankAccNo; CompanyInfo."Bank Account No.")
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(CoRegNo; CompanyInfo."Registration No.")
            {
            }
            column(FaxNo; CompanyInfo."Fax No.")
            {
            }
            dataitem("PR Header"; "PR Header")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending);
                RequestFilterFields = "No.";
                column(No_PRHeader; "PR Header"."No.")
                {
                }
                column(RFQComparisonNo_PRHeader; RFQComparisonNo)
                {
                }

                column(VendorDueDate; VendorDueDate)
                { }
                column(DueDate; vendorDueDate)
                { }
                column(Description_PRHeader; "PR Header".Description)
                {
                }
                column(PRDate_PRHeader; "PR Header"."PR Date")
                {
                }
                column(DeliveryLocation_PRHeader; "PR Header"."Delivery Location")
                {
                }
                column(Requester_PRHeader; "PR Header".Requester)
                {
                }
                column(PRDocumentType_PRHeader; "PR Header"."PR Document Type")
                {
                }
                column(PRStatus_PRHeader; "PR Header"."PR Status")
                {
                }
                column(Coordinator_PRHeader; "PR Header"."Co-ordinator")
                {
                }
                column(Status_PRHeader; "PR Header".Status)
                {
                }
                column(ShortcutDimension1Code_PRHeader; "PR Header"."Shortcut Dimension 1 Code")
                {
                }
                column(LOAStatus_PRHeader; "PR Header"."LOA Status")
                {
                }
                column(Purchaser_Code; "PR Header"."Purchaser Code")
                { }
                dataitem(SuggestedVendor; "Suggested Vendor")
                {
                    DataItemLink = "PR No." = FIELD("No.");
                    DataItemTableView = SORTING("Document Type", "PR No.", "PR Line No.", "Line no.") ORDER(Ascending) WHERE("Document Type" = CONST("PR Header"));
                    column(SuggestedVendor_SuggestedVendor; SuggestedVendor."Suggested Vendor")
                    {
                    }
                    column(VendorName_SuggestedVendor; SuggestedVendor."Vendor Name")
                    {
                    }
                    column(VendorDueDate_SuggestedVendor; VendorDueDate)
                    {
                    }
                    column(RFQDate; rfqDate)
                    {
                    }
                    column(VendorName; VendorName)
                    {
                    }
                    column(VendorName2; VendorName2)
                    {
                    }
                    column(VendorAddress; VendorAddress)
                    {
                    }
                    column(VendorAddress2; VendorAddress2)
                    {
                    }
                    column(VendorPostCode; VendorPostCode)
                    {
                    }
                    column(VendorCity; VendorCity)
                    {
                    }
                    column(VendorCounty; VendorCounty)
                    {
                    }
                    column(VendorCountryRegionCode; VendorCountryRegionCode)
                    {
                    }
                    column(VendorContact; VendorContact)
                    {
                    }
                    column(VendorPhoneNo; VendorPhoneNo)
                    {
                    }
                    column(VendorEmail; VendorEmail)
                    {
                    }
                    dataitem("PR Line"; "PR Line")
                    {
                        DataItemLink = "Document No." = FIELD("PR No.");
                        DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);
                        column(No_PRLine; "PR Line"."No.")
                        {
                        }
                        column(Description_PRLine; "PR Line".Description)
                        {
                        }
                        column(Quantity_PRLine; "PR Line".Quantity)
                        {
                        }
                        column(UnitofMeasure_PRLine; "PR Line"."Unit of  Measure")
                        {
                        }
                        column(DeliveryLocation_PRLine; "PR Line"."Delivery Location")
                        {
                        }
                        column(PRStatus_PRLine; "PR Line"."PR Status")
                        {
                        }
                        column(UnitCost_PRLine; "PR Line"."Unit Cost")
                        {
                        }
                        column(Amount_PRLine; "PR Line".Amount)
                        {
                        }
                    }
                    trigger OnPreDataItem()
                    begin
                        if VendorFilter <> '' then
                            SetRange("Suggested Vendor", VendorFilter);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        Clear(VendorName);
                        Clear(VendorName2);
                        Clear(VendorAddress);
                        Clear(VendorAddress2);
                        Clear(VendorPostCode);
                        Clear(VendorCity);
                        Clear(VendorCounty);
                        Clear(VendorCountryRegionCode);
                        Clear(VendorContact);
                        Clear(VendorPhoneNo);
                        Clear(VendorEmail);
                        Clear(VendorDueDate);
                        Clear(rfqDate);

                        if VendorRec.Get(SuggestedVendor."Suggested Vendor") then begin
                            VendorName := VendorRec.Name;
                            VendorName2 := VendorRec."Name 2";
                            VendorAddress := VendorRec.Address;
                            VendorAddress2 := VendorRec."Address 2";
                            VendorPostCode := VendorRec."Post Code";
                            VendorCity := VendorRec.City;
                            VendorCounty := VendorRec.County;
                            VendorCountryRegionCode := VendorRec."Country/Region Code";
                            VendorContact := VendorRec.Contact;
                            VendorPhoneNo := VendorRec."Phone No.";
                            VendorEmail := VendorRec."E-Mail";
                        end;

                        PurchQuoteLine.Reset();
                        PurchQuoteLine.SetRange("Document Type", PurchQuoteLine."Document Type"::Quote);
                        PurchQuoteLine.SetRange("RFQ No.", RFQComparisonNo);
                        PurchQuoteLine.SetRange("Buy-from Vendor No.", SuggestedVendor."Suggested Vendor");
                        if PurchQuoteLine.FindFirst() then begin
                            if PurchQuoteLine."Vendor Due Date" <> 0D then
                                VendorDueDate := PurchQuoteLine."Vendor Due Date"
                            else
                                VendorDueDate := PurchQuoteLine."Expected Receipt Date";
                            rfqDate := PurchQuoteLine."RFQ Date";
                        end else
                            VendorDueDate := RFQComparisonRec."Due Date";
                    end;
                }
                trigger OnAfterGetRecord()
                begin
                    Clear(RFQComparisonNo);
                    RFQComparisonRec.Reset();
                    RFQComparisonRec.SetRange("PR No", "PR Header"."No.");
                    if RFQComparisonRec.FindFirst() then begin
                        RFQComparisonNo := RFQComparisonRec."No.";
                        RFQComparisonRec."RFQ Date" := Today;
                        RFQComparisonRec.Modify();
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(VendorFilter; VendorFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Filter';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            SuggestedVendorLookupRec.Reset();
                            SuggestedVendorLookupRec.SetRange("Document Type", SuggestedVendorLookupRec."Document Type"::"PR Header");
                            SuggestedVendorLookupRec.SetRange("PR Line No.", 0);

                            PRNoFilter := "PR Header".GetFilter("No.");
                            if PRNoFilter <> '' then
                                SuggestedVendorLookupRec.SetFilter("PR No.", PRNoFilter);

                            SuggestedVendorLookupRec.SetCurrentKey("Document Type", "PR No.", "PR Line No.", "Line no.");
                            SuggestedVendorLookupPage.SetTableView(SuggestedVendorLookupRec);
                            SuggestedVendorLookupPage.LookupMode(true);

                            if SuggestedVendorLookupPage.RunModal() = Action::LookupOK then begin
                                SuggestedVendorLookupPage.GetRecord(SuggestedVendorLookupRec);
                                VendorFilter := SuggestedVendorLookupRec."Suggested Vendor";
                                //exit(true);
                            end;

                            //exit(false);
                        end;
                    }
                }
            }
        }
    }

    trigger OnInitReport();
    begin
        CompanyInfo3.GET;
        CompanyInfo3.CALCFIELDS(Picture);
        CompanyInfo1.GET;
        CompanyInfo1.CALCFIELDS(Picture);
    end;

    trigger OnPreReport();
    begin

        CompanyInfo.GET;
        FormatAddr.Company(CompanyAddr, CompanyInfo);
    end;

    var
        CompanyInfo: Record "Company Information";
        CompanyInfo1: Record "Company Information";
        CompanyInfo2: Record "Company Information";
        CompanyInfo3: Record "Company Information";
        VendorRec: Record Vendor;
        CompanyAddr: array[8] of Text[50];
        VendorName: Text[100];
        VendorName2: Text[50];
        VendorAddress: Text[100];
        VendorAddress2: Text[50];
        VendorPostCode: Code[20];
        VendorCity: Text[30];
        rfqDate: Date;
        VendorCounty: Text[30];
        VendorCountryRegionCode: Code[10];
        VendorContact: Text[100];
        VendorPhoneNo: Text[30];
        VendorEmail: Text[80];
        VendorDueDate: Date;
        RFQComparisonRec: Record "RFQ Comparison";
        PurchQuoteLine: Record "Purchase Line";
        SuggestedVendorLookupRec: Record "Suggested Vendor";
        SuggestedVendorLookupPage: Page "Suggested vendor";
        RFQComparisonNo: Code[20];
        VendorFilter: Code[20];
        PRNoFilter: Text;
        RespCenter: Record "Responsibility Center";
        FormatAddr: Codeunit "Format Address";
}

