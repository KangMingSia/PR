report 27003019 "Budget Availability Final"
{
    Caption = 'Budget Availability Final';
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/Budget Availability Final.rdl';
    // ApplicationArea = All;
    // UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("Account Type" = CONST(Posting));
            RequestFilterFields = "No.";
            column(No_GLAccount; "G/L Account"."No.")
            {
            }
            column(Dim1Caption; Dim1Caption)
            {
            }
            column(Dim2Caption; Dim2Caption)
            {
            }
            column(Name_GLAccount; "G/L Account".Name)
            {
            }
            column(UserDim1; GlobalDimension1Code)
            {
            }
            column(UserDim2; GlobalDimension2Code)
            {
            }
            column(TotalBudgetAmount; TotalBudgetAmount)
            {
            }
            column(OnHold; OnHold)
            {
            }
            column(Utilised; Utilised)
            {
            }
            column(AvailableBudget; AvailableBudget)
            {
            }
            column(Summary; Summary)
            {
            }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemTableView = SORTING("G/L Account No.", "Business Unit Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date") ORDER(Ascending) WHERE("G/L Account No." = FILTER(<> ''));
                column(GLAccountNo_GLEntry; "G/L Entry"."G/L Account No.")
                {
                }
                column(DocumentNo_GLEntry; "G/L Entry"."Document No.")
                {
                }
                column(Description_GLEntry; "G/L Entry".Description)
                {
                }
                column(Amount_GLEntry; "G/L Entry".Amount)
                {
                }
                column(GlobalDimension1Code_GLEntry; "G/L Entry"."Global Dimension 1 Code")
                {
                }
                column(GlobalDimension2Code_GLEntry; "G/L Entry"."Global Dimension 2 Code")
                {
                }
                column(Ext_No; "G/L Entry"."External Document No.")
                {
                }
                column(PostingDate_GLEntry; "G/L Entry"."Posting Date")
                {
                }

                trigger OnAfterGetRecord();
                begin
                    UsedBudgetAmount += "G/L Entry".Amount;
                end;

                trigger OnPreDataItem();
                begin
                    if "G/L Account"."Budget Link A/C" <> '' then
                        SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                    else
                        SETFILTER("G/L Account No.", "G/L Account"."No.");
                    SETRANGE("Posting Date", StartDate, EndDate);
                    if GlobalDimension1Code <> '' then
                        SETFILTER("Global Dimension 1 Code", GlobalDimension1Code);
                    if GlobalDimension2Code <> '' then
                        SETFILTER("Global Dimension 2 Code", GlobalDimension2Code);
                end;
            }
            dataitem(PRHeader3; "PR Header")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("PR Document Type" = FILTER(<> PC));
                dataitem(PRLine3; "PR Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending) WHERE("PR Document Type" = FILTER(<> PC));
                    column(DocumentNo_PRLine3; PRLine3."Document No.")
                    {
                    }
                    column(LineNo_PRLine3; PRLine3."Line No.")
                    {
                    }
                    column(No_PRLine3; PRLine3."No.")
                    {
                    }
                    column(Description_PRLine3; PRLine3.Description)
                    {
                    }
                    column(Quantity_PRLine3; PRLine3.Quantity)
                    {
                    }
                    column(UnitCost_PRLine3; PRLine3."Unit Cost")
                    {
                    }
                    column(Amount_PRLine3; RFQPendingAmt)
                    {
                    }
                    column(Status_PRLine3; PRLine3.Status)
                    {
                    }
                    column(Globaldim1_PRLine3; PRLine3."Shortcut Dimension 1 Code")
                    {
                    }
                    column(Globaldim2_PRLine3; PRLine3."Shortcut Dimension 2 Code")
                    {
                    }
                    column(PRDate_PRLine3; PRHeader3."PR Date")
                    {
                    }

                    trigger OnAfterGetRecord();
                    begin
                        if PRLine3.ConvertedtoQuote and not PRLine3.ConvertedtoOrder then begin
                            RFQComp.RESET;
                            RFQComp.SETRANGE("PR No", PRLine3."Document No.");
                            RFQComp.SETFILTER(Status, '%1|%2', RFQComp.Status::"Pending Approval", RFQComp.Status::Open);
                            if RFQComp.FINDFIRST then
                                GPurchLine.RESET;
                            GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
                            GPurchLine.SETRANGE("PR No.", PRLine3."Document No.");
                            GPurchLine.SETRANGE("PR Line No.", PRLine3."Line No.");
                            GPurchLine.SETRANGE("No.", PRLine3."No.");
                            GPurchLine.SETFILTER("Shortcut Dimension 1 Code", PRLine3."Shortcut Dimension 1 Code");
                            GPurchLine.SETFILTER("Shortcut Dimension 2 Code", PRLine3."Shortcut Dimension 2 Code");
                            if GPurchLine.FINDSET then
                                RFQPendingAmt := GPurchLine."Outstanding Amount (LCY)";
                        end else
                            RFQPendingAmt := PRLine3.Amount;

                        GTotalPReq += "Unit Cost (LCY)" * Quantity;
                    end;

                    trigger OnPreDataItem();
                    begin
                        if GlobalDimension1Code <> '' then
                            SETFILTER("Shortcut Dimension 1 Code", GlobalDimension1Code);
                        if GlobalDimension2Code <> '' then
                            SETFILTER("Shortcut Dimension 2 Code", GlobalDimension2Code);
                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("No.", "G/L Account"."No.");
                        SETRANGE(ConvertedtoOrder, false);
                        SETFILTER(Status, '%1|%2|%3', Status::Released, Status::Closed, Status::"Pending Approval");
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("PR Date", StartDate, EndDate);
                end;
            }
            dataitem("Purchase Header"; "Purchase Header")
            {
                // DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending) WHERE("Order Indicator" = CONST(Open));//Version 19.0.0.0>>
                DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending);//Version 19.0.0.0>>
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                    column(DocumentNo_PurchaseLine; "Purchase Line"."Document No.")
                    {
                    }
                    column(LineNo_PurchaseLine; "Purchase Line"."Line No.")
                    {
                    }
                    column(No_PurchaseLine; "Purchase Line"."No.")
                    {
                    }
                    column(Description_PurchaseLine; "Purchase Line".Description)
                    {
                    }
                    column(Quantity_PurchaseLine; "Purchase Line".Quantity)
                    {
                    }
                    column(UnitCost_PurchaseLine; "Purchase Line"."Unit Cost")
                    {
                    }
                    column(Amount_PurchaseLine; GTotalPurchaseLines)
                    {
                        DecimalPlaces = 2 : 2;
                    }
                    column(ShortcustDim1_PurchaseLine; "Purchase Line"."Shortcut Dimension 1 Code")
                    {
                    }
                    column(ShortcustDim2_PurchaseLine; "Purchase Line"."Shortcut Dimension 2 Code")
                    {
                    }
                    column(PostingDate_PurchaseLine; "Purchase Header"."Posting Date")
                    {
                    }

                    trigger OnAfterGetRecord();
                    begin
                        CLEAR(GTotalPurchaseLines);

                        if ("Outstanding Amount (LCY)" = 0) then
                            CurrReport.SKIP;
                        if "PR In G/L" then
                            GTotalPurchaseLines += "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)" - "G/L Total Amt for PR"
                        else
                            GTotalPurchaseLines += "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)";

                    end;

                    trigger OnPreDataItem();
                    begin
                        if GlobalDimension1Code <> '' then
                            SETFILTER("Shortcut Dimension 1 Code", GlobalDimension1Code);
                        if GlobalDimension2Code <> '' then
                            SETFILTER("Shortcut Dimension 2 Code", GlobalDimension2Code);
                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("No.", "G/L Account"."No.");
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("Posting Date", StartDate, EndDate);
                end;
            }

            trigger OnAfterGetRecord();
            begin
                CLEAR(TotalBudgetAmount);
                if "G/L Account"."Budget Link A/C" <> '' then
                    "G/LBEntry".SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                else
                    "G/LBEntry".SETRANGE("G/L Account No.", "G/L Account"."No.");
                "G/LBEntry".SETRANGE("Budget Name", PPSetup."PR Budget Name");
                if GlobalDimension1Code <> '' then
                    "G/LBEntry".SETFILTER("Global Dimension 1 Code", GlobalDimension1Code);
                "G/LBEntry".SETFILTER("Global Dimension 2 Code", GlobalDimension2Code);
                "G/LBEntry".SETRANGE(Date, StartDate, EndDate);
                if "G/LBEntry".FINDSET then
                    repeat
                        TotalBudgetAmount += "G/LBEntry".Amount;
                    until "G/LBEntry".NEXT = 0;
            end;

            trigger OnPreDataItem();
            begin
                if Usersetup.GET(USERID) then;

                AccountingPeriod.RESET;
                AccountingPeriod.SETRANGE("Date Locked", false);
                AccountingPeriod.SETRANGE(Closed, false);
                if AccountingPeriod.FINDLAST then
                    EndDate := CALCDATE('+1M-1D', AccountingPeriod."Starting Date");

                AccountingPeriod.RESET;
                AccountingPeriod.SETRANGE(Closed, false);
                if AccountingPeriod.FINDFIRST then
                    StartDate := AccountingPeriod."Starting Date";

                SETRANGE("Date Filter", StartDate, EndDate);
                if GlobalDimension1Code <> '' then
                    SETFILTER("Global Dimension 1 Filter", GlobalDimension1Code);
                SETFILTER("Global Dimension 2 Filter", GlobalDimension2Code);
                PPSetup.GET;
                if PPSetup."PR Budget Name" = '' then
                    ERROR('Select PR Budget Name in Purchases & Payables Setup');
            end;
        }
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(content)
            {
                field("Global Dimension 1 Code"; GlobalDimension1Code)
                {
                    CaptionClass = '1,1,1';

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 1);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            GlobalDimension1Code := DimensionValue.Code;
                    end;
                }
                field("Global Dimension 2 Code"; GlobalDimension2Code)
                {
                    CaptionClass = '1,1,2';
                    Caption = '<Global Dimension 2 Code>';

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 2);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            GlobalDimension2Code := DimensionValue.Code;
                    end;
                }
                field(Summary; Summary)
                {
                }
            }
        }


    }

    trigger OnPreReport()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if GLSetup.Get() then begin
            Dim1Caption := GLSetup."Global Dimension 1 Code";
            Dim2Caption := GLSetup."Global Dimension 2 Code";
        end;
    end;

    var
        AccountingPeriod: Record "Accounting Period";
        TotalBudgetAmount: Decimal;
        UsedBudgetAmount: Decimal;
        StartDate: Date;
        EndDate: Date;
        UPCPRTotal: Decimal;
        LHighestAmt: Decimal;
        HoldUPCPRTotal: Decimal;
        GTotalInvoice: Decimal;
        GTotalCrLine: Decimal;
        Dim1Caption: Code[20];
        Dim2Caption: Code[20];
        CurrExchRate: Record "Currency Exchange Rate";
        GTotalPurchaseLines: Decimal;
        GTotalReturn: Decimal;
        GTotalPReq: Decimal;
        GTotalBudgetOnHold: Decimal;
        GTotalPurchaseLinesUtilised: Decimal;
        GetDate: Date;
        PPSetup: Record "Purchases & Payables Setup";
        Usersetup: Record "User Setup";
        AvailableBudget: Decimal;
        Utilised: Decimal;
        OnHold: Decimal;
        "G/LBEntry": Record "G/L Budget Entry";
        GlobalDimension1Code: Code[10];
        GlobalDimension2Code: Code[10];
        DimensionValue: Record "Dimension Value";
        Summary: Boolean;
        RFQComp: Record "RFQ Comparison";
        GPurchLine: Record "Purchase Line";
        RFQPendingAmt: Decimal;
}

