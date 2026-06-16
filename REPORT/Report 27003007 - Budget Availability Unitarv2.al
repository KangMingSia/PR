report 27003007 "Budget Availability-UnitarV2"
{
    Caption = 'Budget Availability';
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/Budget Availability UnitarV2.rdl';
    //ApplicationArea = All;
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
            column(CostCenterCaption; CostCenterCaption)
            {
            }
            column(Name_GLAccount; "G/L Account".Name)
            {
            }
            column(UserDim1; CostCenter)
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
                DataItemLink = "G/L Account No." = FIELD("No.");
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
                    SETRANGE("Posting Date", StartDate, EndDate);
                    if CostCenter <> '' then
                        SETFILTER("Global Dimension 1 Code", CostCenter);
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
                    //19.0.0.6>>
                    // column(No_PRLine3; PRLine3."No.")
                    // {
                    // }
                    column(No_PRLine3; PRLine3."G/L Account No.")
                    {
                    }
                    //19.0.0.6<<
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
                        if PRLine3.ConvertedtoQuote and not PRLine3.ConvertedtoOrder then begin
                            RFQComp.RESET;
                            RFQComp.SETRANGE("PR No", PRLine3."Document No.");
                            //AR RFQComp.SETRANGE(Status,RFQComp.Status::"Pending Approval");
                            RFQComp.SETFILTER(Status, '%1|%2', RFQComp.Status::"Pending Approval", RFQComp.Status::Open);
                            if RFQComp.FINDFIRST then begin
                                GPurchLine.RESET;
                                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
                                GPurchLine.SETRANGE("PR No.", PRLine3."Document No.");
                                GPurchLine.SETRANGE("PR Line No.", PRLine3."Line No.");
                                //19.0.0.6>>
                                // GPurchLine.SETRANGE("No.", PRLine3."No.");
                                GPurchLine.SETRANGE("G/L Account No.", PRLine3."G/L Account No.");
                                // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLine3."Shortcut dimension 1 code"); 
                                //19.0.0.6<<
                                if GPurchLine.FINDSET then
                                    RFQPendingAmt := GPurchLine."Outstanding Amount (LCY)";
                            end else
                                CurrReport.SKIP;

                        end else
                            RFQPendingAmt := PRLine3.Amount;
                        GTotalPReq += "Unit Cost (LCY)" * Quantity;
                    end;

                    trigger OnPreDataItem();
                    begin
                        if CostCenter <> '' then
                            SETRANGE("Shortcut dimension 1 code", CostCenter);

                        // SETRANGE("No.", "G/L Account"."No.");//19.0.0.6
                        SETRANGE("G/L Account No.", "G/L Account"."No.");//19.0.0.6
                        SETRANGE(ConvertedtoOrder, false);
                        SETFILTER(Status, '%1|%2|%3', Status::Released, Status::Closed, Status::"Pending Approval");
                    end;
                }

                trigger OnAfterGetRecord();
                begin
                    //19.0.0.6>>
                    // if (PRHeader3."PR Document Type" = PRHeader3."PR Document Type"::"Non-PO") and
                    //   (PRHeader3."LOA Status" = PRHeader3."LOA Status"::Released) then
                    //     CurrReport.SKIP;
                    //19.0.0.6<<
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
                    //19.0.0.6>>
                    // column(No_PurchaseLine; "Purchase Line"."No.")
                    // {
                    // }
                    column(No_PurchaseLine; "Purchase Line"."G/L Account No.")
                    {
                    }
                    //19.0.0.6<<
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
                            SETRANGE("Shortcut Dimension 1 Code", CostCenter);
                        // SETRANGE("No.", "G/L Account"."No.");//19.0.0.6
                        SETRANGE("G/L Account No.", "G/L Account"."No.");//19.0.0.6
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
                    //19.0.0.6>>
                    // column(No_PRLine4; PRLine4."No.")
                    // {
                    // }
                    column(No_PRLine4; PRLine4."G/L Account No.")
                    {
                    }
                    //19.0.0.6<<
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
                            SETRANGE("Shortcut dimension 1 code", CostCenter);

                        // SETRANGE("No.", "G/L Account"."No.");//19.0.0.6
                        SETRANGE("G/L Account No.", "G/L Account"."No.");//19.0.0.6
                        SETRANGE(ConvertedtoOrder, false);
                        SETRANGE(ConvertedtoQuote, false);
                        SETFILTER(Status, '%1', Status::Open);
                    end;
                }

                trigger OnPreDataItem();
                begin
                    SETRANGE("PR Date", StartDate, EndDate);
                end;
            }

            trigger OnAfterGetRecord();
            begin
                CLEAR(TotalBudgetAmount);
                gGLBudgetEntry.SETRANGE("G/L Account No.", "G/L Account"."No.");
                gGLBudgetEntry.SETRANGE("Budget Name", PPSetup."PR Budget Name");
                if CostCenter <> '' then
                    gGLBudgetEntry.SETFILTER("Global Dimension 1 Code", CostCenter);
                gGLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                if gGLBudgetEntry.FINDSET then
                    repeat
                        TotalBudgetAmount += gGLBudgetEntry.Amount;
                    until gGLBudgetEntry.NEXT = 0;
            end;

            trigger OnPreDataItem();
            begin
                Usersetup.GET(USERID);

                PPSetup.GET;

                StartDate := PPSetup."Budget Start Date";
                EndDate := PPSetup."Budget End Date";

                SETRANGE("Date Filter", StartDate, EndDate);
                if CostCenter <> '' then
                    SETFILTER("Global Dimension 1 Filter", CostCenter);

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
                    CaptionClass = '1,1,1';
                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 1);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            CostCenter := DimensionValue.Code;
                    end;
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        GLSetup.get();
        CostCenterCaption := GLSetup."Global Dimension 1 Code";
    end;

    var
        CostCenterCaption: Text[30];
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
        gGLBudgetEntry: Record "G/L Budget Entry";
        CostCenter: Code[10];
        DimensionValue: Record "Dimension Value";
        RFQPendingAmt: Decimal;
        RFQComp: Record "RFQ Comparison";
        GPurchLine: Record "Purchase Line";
        DimMgt: Codeunit DimensionManagement;
        DimensionSetID: Integer;
        DimensionsetEntry: Record "Dimension Set Entry";
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimVal: Record "Dimension Value";

}

