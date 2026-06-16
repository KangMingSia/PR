report 27003018 "Budget Availability V1"
{
    Caption = 'Budget Availability';
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/Budget Availability V1.rdlc';
    // ApplicationArea = All;
    // UsageCategory = ReportsAndAnalysis;

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

                    SETFILTER("Dimension Set ID", '%1', DimensionSetID);

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
                            GPurchLine.SETRANGE("Dimension Set ID", PRLine3."Dimension Set ID");
                            if GPurchLine.FINDSET then
                                RFQPendingAmt := GPurchLine."Outstanding Amount (LCY)";
                        end else
                            RFQPendingAmt := PRLine3.Amount;

                        GTotalPReq += "Unit Cost (LCY)" * Quantity;
                    end;

                    trigger OnPreDataItem();
                    begin
                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("No.", "G/L Account"."No.");
                        SETRANGE(ConvertedtoOrder, false);
                        SETFILTER(Status, '%1|%2|%3', Status::Released, Status::Closed, Status::"Pending Approval");
                        SETFILTER("Dimension Set ID", '%1', DimensionSetID);
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("PR Date", StartDate, EndDate);
                end;
            }
            dataitem("Purchase Header"; "Purchase Header")
            {
                // DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order), "Order Indicator" = CONST(Open));//Version 19.0.0.0>>
                DataItemTableView = SORTING("Document Type", "No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order));//Version 19.0.0.0>>
                dataitem("Purchase Line"; "Purchase Line")
                {
                    CalcFields = "PR In G/L", "G/L Total Amt for PR";
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

                        if ("Outstanding Amount (LCY)" = 0) and ("Amt. Rcd. Not Invoiced (LCY)" = 0) then
                            CurrReport.SKIP;


                        GTotalPurchaseLines += "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)";


                    end;

                    trigger OnPreDataItem();
                    begin
                        if "G/L Account"."Budget Link A/C" <> '' then
                            SETFILTER("No.", '%1|%2', "G/L Account"."No.", "G/L Account"."Budget Link A/C")
                        else
                            SETRANGE("No.", "G/L Account"."No.");
                        SETFILTER("Dimension Set ID", '%1', DimensionSetID);

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

                "G/LBEntry".SETFILTER("Dimension Set ID", '%1', DimensionSetID);
                "G/LBEntry".SETRANGE(Date, StartDate, EndDate);
                if "G/LBEntry".FINDSET then
                    repeat
                        TotalBudgetAmount += "G/LBEntry".Amount;
                    until "G/LBEntry".NEXT = 0;

            end;

            trigger OnPreDataItem();
            begin
                DimensionSetID := GetDimensionSetID;
                if Usersetup.GET(USERID) then;
                PPSetup.GET;
                PPSetup.TESTFIELD("Budget End Date");
                PPSetup.TESTFIELD("Budget Start Date");
                PPSetup.TESTFIELD("PR Budget Name");
                EndDate := PPSetup."Budget End Date";
                StartDate := PPSetup."Budget Start Date";

                SETRANGE("Date Filter", StartDate, EndDate);
                if GlobalDimension1Code <> '' then
                    SETFILTER("Global Dimension 1 Filter", GlobalDimension1Code);
                SETFILTER("Global Dimension 2 Filter", GlobalDimension2Code);
                SETFILTER("Dimension set ID Filter", '%1', DimensionSetID);
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
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(3),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(4),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(5),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(6),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(7),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(8),
                                                                  "Dimension Value Type" = CONST(Standard),
                                                                  Blocked = CONST(false));

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field(Summary; Summary)
                {
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
        ShortcutDimCode: array[8] of Code[20];
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
        if GlobalDimension1Code <> '' then begin
            DimVal.GET(GLSetup."Global Dimension 1 Code", GlobalDimension1Code);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Global Dimension 1 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", GlobalDimension1Code);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if GlobalDimension2Code <> '' then begin
            DimVal.GET(GLSetup."Global Dimension 2 Code", GlobalDimension2Code);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Global Dimension 2 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", GlobalDimension2Code);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[3] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 3 Code", ShortcutDimCode[3]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 3 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[3]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[4] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 4 Code", ShortcutDimCode[4]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 4 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[4]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[5] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 5 Code", ShortcutDimCode[5]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 5 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[5]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[6] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 6 Code", ShortcutDimCode[6]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 6 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[6]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[7] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 7 Code", ShortcutDimCode[7]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 7 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[7]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;
        if ShortcutDimCode[8] <> '' then begin
            DimVal.GET(GLSetup."Shortcut Dimension 8 Code", ShortcutDimCode[8]);
            TempDimSetEntry.INIT;
            TempDimSetEntry.VALIDATE("Dimension Code", GLSetup."Shortcut Dimension 8 Code");
            TempDimSetEntry.VALIDATE("Dimension Value Code", ShortcutDimCode[8]);
            TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
            TempDimSetEntry.INSERT;
        end;

        exit(DimMgt.GetDimensionSetID(TempDimSetEntry));
    end;
}

