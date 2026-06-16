report 27003005 "Budget Availability"
{
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/Budget Availability.rdl';
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
            column(Name_GLAccount; "G/L Account".Name)
            {
            }
            column(UserDim1; CostCenter)
            {
            }
            column(UserDim2; GlobalDimension2Code)
            {
            }
            column(GlobalDim1Caption; GlobalDim1Caption)
            {
            }
            column(GlobalDim2Caption; GlobalDim2Caption)
            {
            }
            column(GLAccountFilter; GLAccountFilter)
            {
            }
            column(ReportDateFilter; ReportDateFilter)
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
                column(Ext_No; "G/L Entry"."External Document No.")
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
                        SETRANGE("G/L Account No.", "G/L Account"."No.");
                    SETRANGE("Posting Date", StartDate, EndDate);
                    if CostCenter <> '' then
                        SETFILTER("Global Dimension 1 Code", CostCenter);
                    if GlobalDimension2Code <> '' then
                        SETFILTER("Global Dimension 2 Code", GlobalDimension2Code);
                    //SETFILTER("Dimension Set ID",'%1',DimensionSetID);
                end;
            }
            dataitem(PRHeader3; "PR Header")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending);
                dataitem(PRLine3; "PR Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);
                    column(DocumentNo_PRLine3; PRLine3."Document No.")
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
                    column(Globaldim_PRLine3; PRLine3."Shortcut dimension 1 code")
                    {
                    }

                    trigger OnAfterGetRecord();
                    begin
                        CLEAR(RFQPendingAmt);
                        if not PRLine3.ConvertedtoOrder then begin
                            RFQComp.RESET;
                            RFQComp.SETRANGE("PR No", PRLine3."Document No.");
                            //AR RFQComp.SETRANGE(Status,RFQComp.Status::"Pending Approval");
                            RFQComp.SETFILTER(Status, '%1|%2', RFQComp.Status::"Pending Approval", RFQComp.Status::Open);
                            if RFQComp.FINDFIRST then begin
                                GPurchLine.RESET;
                                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
                                GPurchLine.SETRANGE("PR No.", PRLine3."Document No.");
                                GPurchLine.SETRANGE("PR Line No.", PRLine3."Line No.");
                                GPurchLine.SETRANGE("G/L Account No.", PRLine3."G/L Account No.");
                                GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLine3."Shortcut dimension 1 code");//Dimension
                                GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLine3."Shortcut dimension 2 code");//Dimension
                                if GPurchLine.FINDSET then
                                    repeat
                                        RFQPendingAmt += GPurchLine."Outstanding Amount (LCY)";
                                    until GPurchLine.NEXT = 0;
                            end;

                            if RFQPendingAmt = 0 then
                                RFQPendingAmt := PRLine3."Unit Cost (LCY)" * PRLine3.Quantity;

                        end else
                            RFQPendingAmt := PRLine3."Unit Cost (LCY)" * PRLine3.Quantity;
                        GTotalPReq += "Unit Cost (LCY)" * Quantity;
                    end;

                    trigger OnPreDataItem();
                    begin
                        if CostCenter <> '' then
                            SETRANGE("Shortcut dimension 1 code", CostCenter);//Dimension
                        if GlobalDimension2Code <> '' then
                            SETRANGE("Shortcut dimension 2 code", GlobalDimension2Code);//Dimension

                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("G/L Account No.", "G/L Account"."No.");
                        SETRANGE(ConvertedtoOrder, false);
                        SETFILTER(Status, '%1|%2|%3', Status::Released, Status::Closed, Status::"Pending Approval");
                        //SETFILTER("Dimension Set ID",'%1',DimensionSetID);//PR2.0
                    end;
                }

                trigger OnAfterGetRecord();
                begin

                    //19.0.0.6>>
                    // if (PRHeader3."PR Document Type" = PRHeader3."PR Document Type"::"Non-PO") and
                    //   (PRHeader3."LOA Status" = PRHeader3."LOA Status"::Released) then
                    //     CurrReport.SKIP;
                    //19.0.0.6>>
                end;

                trigger OnPreDataItem();
                begin
                    SETRANGE("PR Date", StartDate, EndDate);
                end;
            }
            dataitem("Purchase Header"; "Purchase Header")
            {
                DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending);
                dataitem("Purchase Line"; "Purchase Line")
                {
                    DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                    column(DocumentNo_PurchaseLine; "Purchase Line"."Document No.")
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
                    column(Amount_PurchaseLine; "Purchase Line"."Outstanding Amount (LCY)" + "Purchase Line"."Amt. Rcd. Not Invoiced (LCY)")
                    {
                    }
                    column(ShortcustDim_PurchaseLine; "Purchase Line"."Shortcut Dimension 1 Code")
                    {
                    }

                    trigger OnAfterGetRecord();
                    begin

                        GTotalPurchaseLines += "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)";

                        //AR>>
                        if "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)" <= 0 then
                            CurrReport.SKIP;
                        //AR<<
                    end;

                    trigger OnPreDataItem();
                    begin
                        if CostCenter <> '' then
                            SETRANGE("Shortcut Dimension 1 Code", CostCenter);//Dimension
                        if GlobalDimension2Code <> '' then
                            SETRANGE("Shortcut Dimension 2 Code", GlobalDimension2Code);//Dimension
                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("G/L Account No.", "G/L Account"."No.");
                        //SETFILTER("Dimension Set ID",'%1',DimensionSetID);//PR2.0
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("Posting Date", StartDate, EndDate);
                end;
            }
            dataitem(PRHeader4; "PR Header")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending);
                dataitem(PRLine4; "PR Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);
                    column(DocumentNo_PRLine4; PRLine4."Document No.")
                    {
                    }
                    column(No_PRLine4; PRLine4."No.")
                    {
                    }
                    column(Description_PRLine4; PRLine4.Description)
                    {
                    }
                    column(Quantity_PRLine4; PRLine4.Quantity)
                    {
                    }
                    column(UnitCost_PRLine4; PRLine4."Unit Cost")
                    {
                    }
                    column(Amount_PRLine4; PRLine4.Amount)
                    {
                    }
                    column(Status_PRLine4; PRLine4.Status)
                    {
                    }
                    column(Globaldim_PRLine4; PRLine4."Shortcut dimension 1 code")
                    {
                    }

                    trigger OnPreDataItem();
                    begin
                        if CostCenter <> '' then
                            SETRANGE("Shortcut dimension 1 code", CostCenter);//Dimension
                        if GlobalDimension2Code <> '' then
                            SETRANGE("Shortcut dimension 2 code", GlobalDimension2Code);//Dimension

                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("G/L Account No.", "G/L Account"."No.");
                        SETRANGE(ConvertedtoOrder, false);
                        SETRANGE(ConvertedtoQuote, false);
                        SETFILTER(Status, '%1', Status::Open);
                        //SETFILTER("Dimension Set ID",'%1',DimensionSetID);//PR2.0
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("PR Date", StartDate, EndDate);
                end;
            }

            trigger OnAfterGetRecord();
            var
                GLEntrySummary: Record "G/L Entry";
                PRHeaderSummary: Record "PR Header";
                PRLineSummary: Record "PR Line";
                RFQCompSummary: Record "RFQ Comparison";
                PurchHeaderSummary: Record "Purchase Header";
                PurchLineSummary: Record "Purchase Line";
                QuoteLineSummary: Record "Purchase Line";
                LineOnHoldAmt: Decimal;
            begin
                CLEAR(UsedBudgetAmount);
                CLEAR(OnHold);
                CLEAR(Utilised);
                CLEAR(AvailableBudget);
                CLEAR(TotalBudgetAmount);
                "G/LBEntry".RESET;
                if "G/L Account"."Budget Link A/C" <> '' then
                    "G/LBEntry".SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                else
                    "G/LBEntry".SETFILTER("G/L Account No.", '%1', "G/L Account"."No.");
                "G/LBEntry".SETRANGE("Budget Name", PPSetup."PR Budget Name");
                if CostCenter <> '' then
                    "G/LBEntry".SETFILTER("Global Dimension 1 Code", CostCenter);//budget by dimension
                if GlobalDimension2Code <> '' then
                    "G/LBEntry".SETFILTER("Global Dimension 2 Code", GlobalDimension2Code);//budget by dimension
                "G/LBEntry".SETRANGE(Date, StartDate, EndDate);
                //"G/LBEntry".SETFILTER("Dimension Set ID",'%1',DimensionSetID);
                if "G/LBEntry".FINDSET then
                    repeat
                        TotalBudgetAmount += "G/LBEntry".Amount;
                    until "G/LBEntry".NEXT = 0;

                GLEntrySummary.RESET;
                if "G/L Account"."Budget Link A/C" <> '' then
                    GLEntrySummary.SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                else
                    GLEntrySummary.SETRANGE("G/L Account No.", "G/L Account"."No.");
                GLEntrySummary.SETRANGE("Posting Date", StartDate, EndDate);
                if CostCenter <> '' then
                    GLEntrySummary.SETFILTER("Global Dimension 1 Code", CostCenter);
                if GlobalDimension2Code <> '' then
                    GLEntrySummary.SETFILTER("Global Dimension 2 Code", GlobalDimension2Code);
                if GLEntrySummary.FINDSET then
                    repeat
                        UsedBudgetAmount += GLEntrySummary.Amount;
                    until GLEntrySummary.NEXT = 0;

                PRHeaderSummary.RESET;
                PRHeaderSummary.SETRANGE("PR Date", StartDate, EndDate);
                if PRHeaderSummary.FINDSET then
                    repeat
                        PRLineSummary.RESET;
                        PRLineSummary.SETRANGE("Document No.", PRHeaderSummary."No.");
                        PRLineSummary.SETRANGE(ConvertedtoOrder, false);
                        PRLineSummary.SETFILTER(Status, '%1|%2|%3', PRLineSummary.Status::Released, PRLineSummary.Status::Closed, PRLineSummary.Status::"Pending Approval");
                        if CostCenter <> '' then
                            PRLineSummary.SETRANGE("Shortcut dimension 1 code", CostCenter);
                        if GlobalDimension2Code <> '' then
                            PRLineSummary.SETRANGE("Shortcut dimension 2 code", GlobalDimension2Code);
                        if "G/L Account"."Budget Link A/C" <> '' then
                            PRLineSummary.SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            PRLineSummary.SETRANGE("G/L Account No.", "G/L Account"."No.");
                        if PRLineSummary.FINDSET then
                            repeat
                                LineOnHoldAmt := PRLineSummary."Unit Cost (LCY)" * PRLineSummary.Quantity;

                                RFQCompSummary.RESET;
                                RFQCompSummary.SETRANGE("PR No", PRLineSummary."Document No.");
                                RFQCompSummary.SETFILTER(Status, '%1|%2', RFQCompSummary.Status::"Pending Approval", RFQCompSummary.Status::Open);
                                if RFQCompSummary.FINDFIRST then begin
                                    CLEAR(LineOnHoldAmt);
                                    QuoteLineSummary.RESET;
                                    QuoteLineSummary.SETRANGE("Document Type", QuoteLineSummary."Document Type"::Quote);
                                    QuoteLineSummary.SETRANGE("PR No.", PRLineSummary."Document No.");
                                    QuoteLineSummary.SETRANGE("PR Line No.", PRLineSummary."Line No.");
                                    QuoteLineSummary.SETRANGE("G/L Account No.", PRLineSummary."G/L Account No.");
                                    if CostCenter <> '' then
                                        QuoteLineSummary.SETRANGE("Shortcut Dimension 1 Code", CostCenter);
                                    if GlobalDimension2Code <> '' then
                                        QuoteLineSummary.SETRANGE("Shortcut Dimension 2 Code", GlobalDimension2Code);
                                    if QuoteLineSummary.FINDSET then
                                        repeat
                                            LineOnHoldAmt += QuoteLineSummary."Outstanding Amount (LCY)";
                                        until QuoteLineSummary.NEXT = 0;

                                    if LineOnHoldAmt = 0 then
                                        LineOnHoldAmt := PRLineSummary."Unit Cost (LCY)" * PRLineSummary.Quantity;
                                end;

                                OnHold += LineOnHoldAmt;
                            until PRLineSummary.NEXT = 0;
                    until PRHeaderSummary.NEXT = 0;

                PurchHeaderSummary.RESET;
                PurchHeaderSummary.SETRANGE("Posting Date", StartDate, EndDate);
                if PurchHeaderSummary.FINDSET then
                    repeat
                        PurchLineSummary.RESET;
                        PurchLineSummary.SETRANGE("Document Type", PurchHeaderSummary."Document Type");
                        PurchLineSummary.SETRANGE("Document No.", PurchHeaderSummary."No.");
                        if CostCenter <> '' then
                            PurchLineSummary.SETRANGE("Shortcut Dimension 1 Code", CostCenter);
                        if GlobalDimension2Code <> '' then
                            PurchLineSummary.SETRANGE("Shortcut Dimension 2 Code", GlobalDimension2Code);
                        if "G/L Account"."Budget Link A/C" <> '' then
                            PurchLineSummary.SETFILTER("G/L Account No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            PurchLineSummary.SETRANGE("G/L Account No.", "G/L Account"."No.");
                        if PurchLineSummary.FINDSET then
                            repeat
                                if (PurchLineSummary."Outstanding Amount (LCY)" + PurchLineSummary."Amt. Rcd. Not Invoiced (LCY)") > 0 then
                                    OnHold += PurchLineSummary."Outstanding Amount (LCY)" + PurchLineSummary."Amt. Rcd. Not Invoiced (LCY)";
                            until PurchLineSummary.NEXT = 0;
                    until PurchHeaderSummary.NEXT = 0;

                Utilised := UsedBudgetAmount;
                AvailableBudget := TotalBudgetAmount - Utilised - OnHold;
            end;

            trigger OnPreDataItem();
            begin
                /*
                //AR>>
                DimensionSetID := GetDimensionSetID;
                //AR
                */

                Usersetup.GET(USERID);
                /*
                AccountingPeriod.RESET;
                AccountingPeriod.SETRANGE("New Fiscal Year",FALSE);
                AccountingPeriod.SETRANGE(Closed,FALSE);
                IF AccountingPeriod.FINDLAST THEN
                  EndDate := CALCDATE('+1M-1D',AccountingPeriod."Starting Date");
                
                AccountingPeriod.RESET;
                //IBIZ MY AccountingPeriod.SETRANGE("Date Locked",FALSE);
                AccountingPeriod.SETRANGE(Closed,FALSE);
                IF AccountingPeriod.FINDFIRST THEN
                  StartDate :=AccountingPeriod."Starting Date"; //AR 070214
                */
                PPSetup.GET;

                if GETFILTER("Date Filter") <> '' then begin
                    StartDate := GETRANGEMIN("Date Filter");
                    EndDate := GETRANGEMAX("Date Filter");
                end else begin
                    StartDate := PPSetup."Budget Start Date";//
                    EndDate := PPSetup."Budget End Date";//
                end;
                Clear(CostCenter);
                Clear(GlobalDimension2Code);
                SETRANGE("Date Filter", StartDate, EndDate);
                if GetFilter("Global Dimension 1 Filter") <> '' then
                    CostCenter := GETFILTER("Global Dimension 1 Filter");
                if GetFilter("Global Dimension 2 Filter") <> '' then
                    GlobalDimension2Code := GETFILTER("Global Dimension 2 Filter");
                GLAccountFilter := GETFILTER("No.");
                if GLAccountFilter = '' then
                    GLAccountFilter := 'ALL';
                ReportDateFilter :=
                  StrSubstNo('%1..%2',
                    FORMAT(StartDate, 0, '<Day,2>/<Month,2>/<Year4>'),
                    FORMAT(EndDate, 0, '<Day,2>/<Month,2>/<Year4>'));
                GlobalDim1Caption := "G/L Entry".FieldCaption("Global Dimension 1 Code");
                GlobalDim2Caption := "G/L Entry".FieldCaption("Global Dimension 2 Code");
                if CostCenter <> '' then
                    SETFILTER("Global Dimension 1 Filter", CostCenter);
                if GlobalDimension2Code <> '' then
                    SETFILTER("Global Dimension 2 Filter", GlobalDimension2Code);

                //SETFILTER("Dimension set ID Filter",'%1',DimensionSetID);

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
                field(CostCenter; CostCenter)
                {
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 1);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            CostCenter := DimensionValue.Code;

                    end;
                }
                field(GlobalDimension2Code; GlobalDimension2Code)
                {
                    Visible = false;
                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 2);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            GlobalDimension2Code := DimensionValue.Code;
                    end;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

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
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        GTotalPurchaseLines: Decimal;
        GTotalReturn: Decimal;
        GTotalPReq: Decimal;
        GTotalBudgetOnHold: Decimal;
        GTotalPurchaseLinesUtilised: Decimal;
        tt: Report 8;
        GetDate: Date;
        PPSetup: Record "Purchases & Payables Setup";
        Usersetup: Record "User Setup";
        AvailableBudget: Decimal;
        Utilised: Decimal;
        OnHold: Decimal;
        "G/LBEntry": Record "G/L Budget Entry";
        CostCenter: Code[10];
        GlobalDimension2Code: Code[20];
        GlobalDim1Caption: Text[100];
        GlobalDim2Caption: Text[100];
        GLAccountFilter: Text[100];
        ReportDateFilter: Text[50];
        DimensionValue: Record "Dimension Value";
        RFQPendingAmt: Decimal;
        RFQComp: Record "RFQ Comparison";
        GPurchLine: Record "Purchase Line";
        DimMgt: Codeunit DimensionManagement;
        DimensionSetID: Integer;
        DimensionsetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";

    procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]);
    begin
        DimMgt.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, DimensionSetID);
    end;

    local procedure GetDimensionSetID() DSetID: Integer;
    begin
        GLSetup.GET;
        if CostCenter <> '' then begin
            DimVal.GET(GLSetup."Global Dimension 1 Code", CostCenter);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Global Dimension 1 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", CostCenter);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        /*
        IF GlobalDimension2Code <>'' THEN BEGIN
          DimVal.GET(GLSetup."Global Dimension 2 Code",GlobalDimension2Code);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Global Dimension 2 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",GlobalDimension2Code);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[3] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 3 Code",ShortcutDimCode[3]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 3 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[3]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[4] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 4 Code",ShortcutDimCode[4]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 4 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[4]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[5] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 5 Code",ShortcutDimCode[5]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 5 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[5]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[6] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 6 Code",ShortcutDimCode[6]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 6 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[6]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[7] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 7 Code",ShortcutDimCode[7]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 7 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[7]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        IF ShortcutDimCode[8] <>'' THEN BEGIN
          DimVal.GET(GLSetup."Shortcut Dimension 8 Code",ShortcutDimCode[8]);
          TempDimSetEntry.INIT;
          TempDimSetEntry.VALIDATE("Dimension Code",GLSetup."Shortcut Dimension 8 Code");
          TempDimSetEntry.VALIDATE("Dimension Value Code",ShortcutDimCode[8]);
          TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
          TempDimSetEntry.INSERT;
        END;
        */
        exit(DimMgt.GetDimensionSetID(TempDimSetEntry));

    end;
}

