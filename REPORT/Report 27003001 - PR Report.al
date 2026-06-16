report 27003001 "PR Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/PR Report.rdl';
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
                dataitem("PR Line"; "PR Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
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
            }
        }
    }

    trigger OnInitReport();
    begin
        CompanyInfo3.GET;
        CompanyInfo3.CALCFIELDS(Picture);
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
        CompanyAddr: array[8] of Text[50];
        RespCenter: Record "Responsibility Center";
        FormatAddr: Codeunit "Format Address";
}

