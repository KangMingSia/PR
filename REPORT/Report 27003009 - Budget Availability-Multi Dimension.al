report 27003009 "Budget Avail.-Multi Dimension"
{
    Caption = 'Budget Availability-Multi Dimension';
    DefaultLayout = RDLC;
    RDLCLayout = '.vscode/ReportLayout/BudgetAvailabilityMultiDimension.rdl';

    dataset
    {
        dataitem("G/L Account"; "G/L Account")
        {
            DataItemTableView = SORTING("No.") ORDER(Ascending) WHERE("Account Type" = CONST(Posting));
            RequestFilterFields = "No.";
            column(GLAccountFilters; GetFilters) { }
            column(No_GLAccount; "G/L Account"."No.") { }
            column(CostCenterCaption; CostCenterCaption) { }
            column(gDim1Caption; gDim1Caption) { }
            column(gDim2Caption; gDim2Caption) { }
            column(gDim3Caption; gDim3Caption) { }
            column(gDim4Caption; gDim4Caption) { }
            column(gDim5Caption; gDim5Caption) { }
            column(gDim6Caption; gDim6Caption) { }
            column(gDim7Caption; gDim7Caption) { }
            column(gDim8Caption; gDim8Caption) { }
            column(gDim1; gDim1) { }
            column(gDim2; gDim2) { }
            column(gDim3; gDim3) { }
            column(gDim4; gDim4) { }
            column(gDim5; gDim5) { }
            column(gDim6; gDim6) { }
            column(gDim7; gDim7) { }
            column(gDim8; gDim8) { }
            column(Name_GLAccount; "G/L Account".Name) { }
            // column(UserDim1; CostCenter) { }//19.0.0.7>>
            column(UserDim1; '') { }//19.0.0.7>>
            column(TotalBudgetAmount; TotalBudgetAmount) { }
            column(OnHold; OnHold) { }
            column(Utilised; Utilised) { }
            column(gShortcutDimCode; gShortcutDimCode[1]) { }

            column(AvailableBudget; AvailableBudget) { }
            dataitem("G/L Entry"; "G/L Entry")
            {
                DataItemLink = "G/L Account No." = FIELD("No.");
                DataItemTableView = SORTING("G/L Account No.", "Business Unit Code", "Global Dimension 1 Code", "Global Dimension 2 Code", "Posting Date") ORDER(Ascending) WHERE("G/L Account No." = FILTER(<> ''));
                column(GLAccountNo_GLEntry; "G/L Entry"."G/L Account No.") { }
                column(DocumentNo_GLEntry; "G/L Entry"."Document No.") { }
                column(Description_GLEntry; "G/L Entry".Description) { }
                column(Amount_GLEntry; "G/L Entry".Amount) { }
                column(GlobalDimension1Code_GLEntry; "G/L Entry"."Global Dimension 1 Code") { }
                column(GlobalDimension2Code_GLEntry; "G/L Entry"."Global Dimension 2 Code") { }
                column(GlobalDimension3Code_GLEntry; "G/L Entry"."Shortcut Dimension 3 Code") { }
                column(GlobalDimension4Code_GLEntry; "G/L Entry"."Shortcut Dimension 4 Code") { }
                column(GlobalDimension5Code_GLEntry; "G/L Entry"."Shortcut Dimension 5 Code") { }
                column(GlobalDimension6Code_GLEntry; "G/L Entry"."Shortcut Dimension 6 Code") { }
                column(GlobalDimension7Code_GLEntry; "G/L Entry"."Shortcut Dimension 7 Code") { }
                column(GlobalDimension8Code_GLEntry; "G/L Entry"."Shortcut Dimension 8 Code") { }
                column(Ext_No; "G/L Entry"."External Document No.") { }

                trigger OnAfterGetRecord();
                begin
                    UsedBudgetAmount += "G/L Entry".Amount;
                end;

                trigger OnPreDataItem();
                begin
                    SETRANGE("Posting Date", StartDate, EndDate);
                    //19.0.0.7>>
                    if gDim1 <> '' then SETFILTER("Global Dimension 1 Code", gDim1);
                    if gDim2 <> '' then SETFILTER("Global Dimension 2 Code", gDim2);
                    if gDim3 <> '' then SETFILTER("Shortcut Dimension 3 Code", gDim3);
                    if gDim4 <> '' then SETFILTER("Shortcut Dimension 4 Code", gDim4);
                    if gDim5 <> '' then SETFILTER("Shortcut Dimension 5 Code", gDim5);
                    if gDim6 <> '' then SETFILTER("Shortcut Dimension 6 Code", gDim6);
                    if gDim7 <> '' then SETFILTER("Shortcut Dimension 7 Code", gDim7);
                    if gDim8 <> '' then SETFILTER("Shortcut Dimension 8 Code", gDim8);
                    //19.0.0.7<<
                end;
            }
            dataitem(PRHeader3; "PR Header")
            {
                DataItemTableView = SORTING("No.") ORDER(Ascending);
                dataitem(PRLine3; "PR Line")
                {
                    DataItemLink = "Document No." = FIELD("No.");
                    DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);
                    column(DocumentNo_PRLine3; PRLine3."Document No.") { }
                    //19.0.0.6>>
                    // column(No_PRLine3; PRLine3."No.")
                    // {
                    // }
                    column(No_PRLine3; PRLine3."G/L Account No.") { }
                    //19.0.0.6<<
                    column(Description_PRLine3; PRLine3.Description) { }
                    column(Quantity_PRLine3; PRLine3.Quantity) { }
                    column(UnitCost_PRLine3; PRLine3."Unit Cost") { }
                    column(Amount_PRLine3; RFQPendingAmt) { }
                    column(Status_PRLine3; PRLine3.Status) { }
                    column(Globaldim_PRLine3; PRLine3."Shortcut dimension 1 code") { }
                    column(Globaldim2_PRLine3; PRLine3."Shortcut dimension 2 code") { }
                    column(Globaldim3_PRLine3; PRLine3."Shortcut dimension 3 code") { }
                    column(Globaldim4_PRLine3; PRLine3."Shortcut dimension 4 code") { }
                    column(Globaldim5_PRLine3; PRLine3."Shortcut dimension 5 code") { }
                    column(Globaldim6_PRLine3; PRLine3."Shortcut dimension 6 code") { }
                    column(Globaldim7_PRLine3; PRLine3."Shortcut dimension 7 code") { }
                    column(Globaldim8_PRLine3; PRLine3."Shortcut dimension 8 code") { }

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
                        //19.0.0.7>>
                        // if CostCenter <> '' then
                        //     SETRANGE("Shortcut dimension 1 code", CostCenter);
                        if gDim1 <> '' then SETFILTER("Shortcut Dimension 1 Code", gDim1);
                        if gDim2 <> '' then SETFILTER("Shortcut Dimension 2 Code", gDim2);
                        if gDim3 <> '' then SETFILTER("Shortcut Dimension 3 Code", gDim3);
                        if gDim4 <> '' then SETFILTER("Shortcut Dimension 4 Code", gDim4);
                        if gDim5 <> '' then SETFILTER("Shortcut Dimension 5 Code", gDim5);
                        if gDim6 <> '' then SETFILTER("Shortcut Dimension 6 Code", gDim6);
                        if gDim7 <> '' then SETFILTER("Shortcut Dimension 7 Code", gDim7);
                        if gDim8 <> '' then SETFILTER("Shortcut Dimension 8 Code", gDim8);
                        //19.0.0.7<<
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
                    column(DocumentNo_PurchaseLine; "Purchase Line"."Document No.") { }
                    //19.0.0.6>>
                    // column(No_PurchaseLine; "Purchase Line"."No.")
                    // {
                    // }
                    column(No_PurchaseLine; "Purchase Line"."G/L Account No.") { }
                    //19.0.0.6<<
                    column(Description_PurchaseLine; "Purchase Line".Description) { }
                    column(Quantity_PurchaseLine; "Purchase Line".Quantity) { }
                    column(UnitCost_PurchaseLine; "Purchase Line"."Unit Cost") { }
                    column(Amount_PurchaseLine; "Purchase Line"."Outstanding Amount (LCY)" + "Purchase Line"."Amt. Rcd. Not Invoiced (LCY)") { }
                    column(ShortcustDim_PurchaseLine; "Purchase Line"."Shortcut Dimension 1 Code") { }
                    column(ShortcustDim2_PurchaseLine; "Purchase Line"."Shortcut Dimension 2 Code") { }
                    column(ShortcustDim3_PurchaseLine; "Purchase Line"."Shortcut Dimension 3 Code") { }
                    column(ShortcustDim4_PurchaseLine; "Purchase Line"."Shortcut Dimension 4 Code") { }
                    column(ShortcustDim5_PurchaseLine; "Purchase Line"."Shortcut Dimension 5 Code") { }
                    column(ShortcustDim6_PurchaseLine; "Purchase Line"."Shortcut Dimension 6 Code") { }
                    column(ShortcustDim7_PurchaseLine; "Purchase Line"."Shortcut Dimension 7 Code") { }
                    column(ShortcustDim8_PurchaseLine; "Purchase Line"."Shortcut Dimension 8 Code") { }

                    trigger OnAfterGetRecord();
                    begin
                        GTotalPurchaseLines += "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)";
                        if "Outstanding Amount (LCY)" + "Amt. Rcd. Not Invoiced (LCY)" <= 0 then
                            CurrReport.SKIP;
                    end;

                    trigger OnPreDataItem();
                    begin
                        //19.0.0.7>>
                        // if CostCenter <> '' then
                        //     SETRANGE("Shortcut Dimension 1 Code", CostCenter);
                        if gDim1 <> '' then SETFILTER("Shortcut Dimension 1 Code", gDim1);
                        if gDim2 <> '' then SETFILTER("Shortcut Dimension 2 Code", gDim2);
                        if gDim3 <> '' then SETFILTER("Shortcut Dimension 3 Code", gDim3);
                        if gDim4 <> '' then SETFILTER("Shortcut Dimension 4 Code", gDim4);
                        if gDim5 <> '' then SETFILTER("Shortcut Dimension 5 Code", gDim5);
                        if gDim6 <> '' then SETFILTER("Shortcut Dimension 6 Code", gDim6);
                        if gDim7 <> '' then SETFILTER("Shortcut Dimension 7 Code", gDim7);
                        if gDim8 <> '' then SETFILTER("Shortcut Dimension 8 Code", gDim8);
                        //19.0.0.7<<
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
                    column(DocumentNo_PRLine4; PRLine4."Document No.") { }
                    //19.0.0.6>>
                    // column(No_PRLine4; PRLine4."No.")
                    // {
                    // }
                    column(No_PRLine4; PRLine4."G/L Account No.") { }
                    //19.0.0.6<<
                    column(Description_PRLine4; PRLine4.Description) { }
                    column(Quantity_PRLine4; PRLine4.Quantity) { }
                    column(UnitCost_PRLine4; PRLine4."Unit Cost") { }
                    column(Amount_PRLine4; PRLine4.Amount) { }
                    column(Status_PRLine4; PRLine4.Status) { }
                    column(Globaldim_PRLine4; PRLine4."Shortcut dimension 1 code") { }
                    column(Globaldim2_PRLine4; PRLine4."Shortcut dimension 2 code") { }
                    column(Globaldim3_PRLine4; PRLine4."Shortcut dimension 3 code") { }
                    column(Globaldim4_PRLine4; PRLine4."Shortcut dimension 4 code") { }
                    column(Globaldim5_PRLine4; PRLine4."Shortcut dimension 5 code") { }
                    column(Globaldim6_PRLine4; PRLine4."Shortcut dimension 6 code") { }
                    column(Globaldim7_PRLine4; PRLine4."Shortcut dimension 7 code") { }
                    column(Globaldim8_PRLine4; PRLine4."Shortcut dimension 8 code") { }

                    trigger OnPreDataItem();
                    begin
                        //19.0.0.7<<
                        // if CostCenter <> '' then
                        //     SETRANGE("Shortcut dimension 1 code", CostCenter);
                        if gDim1 <> '' then SETFILTER("Shortcut Dimension 1 Code", gDim1);
                        if gDim2 <> '' then SETFILTER("Shortcut Dimension 2 Code", gDim2);
                        if gDim3 <> '' then SETFILTER("Shortcut Dimension 3 Code", gDim3);
                        if gDim4 <> '' then SETFILTER("Shortcut Dimension 4 Code", gDim4);
                        if gDim5 <> '' then SETFILTER("Shortcut Dimension 5 Code", gDim5);
                        if gDim6 <> '' then SETFILTER("Shortcut Dimension 6 Code", gDim6);
                        if gDim7 <> '' then SETFILTER("Shortcut Dimension 7 Code", gDim7);
                        if gDim8 <> '' then SETFILTER("Shortcut Dimension 8 Code", gDim8);
                        //19.0.0.7<<
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

            trigger OnAfterGetRecord()
            begin
                CLEAR(TotalBudgetAmount);
                gGLBudgetEntry.SETRANGE("G/L Account No.", "G/L Account"."No.");
                gGLBudgetEntry.SETRANGE("Budget Name", PPSetup."PR Budget Name");
                // //19.0.0.7<<
                // if CostCenter <> '' then
                //     gGLBudgetEntry.SETFILTER("Global Dimension 1 Code", CostCenter);
                if gDim1 <> '' then gGLBudgetEntry.SETFILTER("Global Dimension 1 Code", gDim1);
                if gDim2 <> '' then gGLBudgetEntry.SETFILTER("Global Dimension 2 Code", gDim2);
                if gDim3 <> '' then gGLBudgetEntry.SETFILTER("Budget Dimension 1 Code", gDim3);
                if gDim4 <> '' then gGLBudgetEntry.SETFILTER("Budget Dimension 2 Code", gDim4);
                if gDim5 <> '' then gGLBudgetEntry.SETFILTER("Budget Dimension 3 Code", gDim5);
                if gDim6 <> '' then gGLBudgetEntry.SETFILTER("Budget Dimension 4 Code", gDim6);
                // if gDim7 <> '' then gGLBudgetEntry.SETFILTER("Shortcut Dimension 7 Code", gDim7);
                // if gDim8 <> '' then gGLBudgetEntry.SETFILTER("Shortcut Dimension 8 Code", gDim8);
                //19.0.0.7<<
                gGLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                if gGLBudgetEntry.FINDSET then
                    repeat
                        TotalBudgetAmount += gGLBudgetEntry.Amount;
                    until gGLBudgetEntry.NEXT = 0;
                Clear(gShortcutDimCode);
                Clear(gShortcutDimValueCode);
                // GetShortcutDimension(gGLBudgetEntry."Dimension Set ID", gShortcutDimCode, gShortcutDimValueCode);
            end;

            trigger OnPreDataItem();
            begin
                // Usersetup.GET(USERID);
                PPSetup.GET;
                StartDate := PPSetup."Budget Start Date";
                EndDate := PPSetup."Budget End Date";
                SETRANGE("Date Filter", StartDate, EndDate);
                //19.0.0.7>>
                // if CostCenter <> '' then
                //     SETFILTER("Global Dimension 1 Filter", CostCenter);
                // if gDim1 <> '' then SETFILTER("Global Dimension 1 Code", gDim1);
                // if gDim2 <> '' then SETFILTER("Global Dimension 2 Code", gDim2);
                // if gDim3 <> '' then SETFILTER("Shortcut Dimension 3 Code", gDim3);
                // if gDim4 <> '' then SETFILTER("Shortcut Dimension 4 Code", gDim4);
                // if gDim5 <> '' then SETFILTER("Shortcut Dimension 5 Code", gDim5);
                // if gDim6 <> '' then SETFILTER("Shortcut Dimension 6 Code", gDim6);
                // if gDim7 <> '' then SETFILTER("Shortcut Dimension 7 Code", gDim7);
                // if gDim8 <> '' then SETFILTER("Shortcut Dimension 8 Code", gDim8);
                //19.0.0.7<<
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
                field(gDim1; gDim1)
                {
                    CaptionClass = '1,1,1';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 1);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim1 := DimensionValue.Code;
                    end;
                }
                field(gDim2; gDim2)
                {
                    CaptionClass = '1,1,2';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 2);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim2 := DimensionValue.Code;
                    end;
                }
                field(gDim3; gDim3)
                {
                    caption = 'Shortcut Dimension 3 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 3);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim3 := DimensionValue.Code;
                    end;
                }
                field(gDim4; gDim4)
                {
                    caption = 'Shortcut Dimension 4 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 4);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim4 := DimensionValue.Code;
                    end;
                }
                field(gDim5; gDim5)
                {
                    caption = 'Shortcut Dimension 5 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 5);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim5 := DimensionValue.Code;
                    end;
                }
                field(gDim6; gDim6)
                {
                    caption = 'Shortcut Dimension 6 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 6);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim6 := DimensionValue.Code;
                    end;
                }
                field(gDim7; gDim7)
                {
                    caption = 'Shortcut Dimension 7 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 7);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim7 := DimensionValue.Code;
                    end;
                }
                field(gDim8; gDim8)
                {
                    caption = 'Shortcut Dimension 8 Code';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Global Dimension No.", 8);
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            gDim8 := DimensionValue.Code;
                    end;
                }
            }
        }
    }

    trigger OnInitReport()
    begin
        GLSetup.get();
        CostCenterCaption := GLSetup."Global Dimension 1 Code";
        gDim1Caption := GLSetup."Shortcut Dimension 1 Code";
        gDim2Caption := GLSetup."Shortcut Dimension 2 Code";
        gDim3Caption := GLSetup."Shortcut Dimension 3 Code";
        gDim4Caption := GLSetup."Shortcut Dimension 4 Code";
        gDim5Caption := GLSetup."Shortcut Dimension 5 Code";
        gDim6Caption := GLSetup."Shortcut Dimension 6 Code";
        gDim7Caption := GLSetup."Shortcut Dimension 7 Code";
        gDim8Caption := GLSetup."Shortcut Dimension 8 Code";
    end;

    procedure GetShortcutDimension(lDimensionSetID: Integer; var lShortcutDimCode: array[8] of Code[20]; var lShortcutDimValueCode: array[8] of Code[20])
    var
        GLSetup: Record "General Ledger Setup";
        DimVal: Record "Dimension Value";
        lDimensionSetEntry: Record "Dimension Set Entry";
    begin
        GLSetup.Get();
        Clear(lShortcutDimCode);
        lShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        lShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        lShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        lShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        lShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        lShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        lShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        lShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
        Clear(lShortcutDimValueCode);
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[1]) then
            lShortcutDimValueCode[1] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[2]) then
            lShortcutDimValueCode[2] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[3]) then
            lShortcutDimValueCode[3] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[4]) then
            lShortcutDimValueCode[4] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[5]) then
            lShortcutDimValueCode[5] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[6]) then
            lShortcutDimValueCode[6] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[7]) then
            lShortcutDimValueCode[7] := lDimensionSetEntry."Dimension Value Code";
        if lDimensionSetEntry.Get(lDimensionSetID, lShortcutDimCode[8]) then
            lShortcutDimValueCode[8] := lDimensionSetEntry."Dimension Value Code";
    end;

    // procedure LookupDimValueCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]; var GLSetupShortcutDimCode: array[8] of Code[20])
    // var
    //     DimVal: Record "Dimension Value";
    //     GLSetup: Record "General Ledger Setup";
    // begin
    //     GetGLSetup(GLSetupShortcutDimCode);
    //     if GLSetupShortcutDimCode[FieldNumber] = '' then
    //         Error(Text002, GLSetup.TableCaption);
    //     DimVal.SetRange("Dimension Code", GLSetupShortcutDimCode[FieldNumber]);
    //     DimVal."Dimension Code" := GLSetupShortcutDimCode[FieldNumber];
    //     DimVal.Code := ShortcutDimCode;
    //     if PAGE.RunModal(0, DimVal) = ACTION::LookupOK then begin
    //         ShortcutDimCode := DimVal.Code;
    //     end;
    // end;

    var
        CostCenterCaption: Text[30];
        // AccountingPeriod: Record "Accounting Period";
        TotalBudgetAmount: Decimal;
        UsedBudgetAmount: Decimal;
        StartDate: Date;
        EndDate: Date;

        // UPCPRTotal: Decimal;
        // LHighestAmt: Decimal;
        // HoldUPCPRTotal: Decimal;
        // GTotalInvoice: Decimal;
        // GTotalCrLine: Decimal;
        GLSetup: Record "General Ledger Setup";
        // CurrExchRate: Record "Currency Exchange Rate";
        GTotalPurchaseLines: Decimal;
        // GTotalReturn: Decimal;
        GTotalPReq: Decimal;
        // GTotalBudgetOnHold: Decimal;
        // GTotalPurchaseLinesUtilised: Decimal;
        // GetDate: Date;
        PPSetup: Record "Purchases & Payables Setup";
        // Usersetup: Record "User Setup";
        AvailableBudget: Decimal;
        Utilised: Decimal;
        OnHold: Decimal;
        gGLBudgetEntry: Record "G/L Budget Entry";
        // CostCenter: Code[10];
        DimensionValue: Record "Dimension Value";
        RFQPendingAmt: Decimal;
        RFQComp: Record "RFQ Comparison";
        GPurchLine: Record "Purchase Line";
        DimMgt: Codeunit DimensionManagement;
        // DimensionSetID: Integer;
        // DimensionsetEntry: Record "Dimension Set Entry";
        // TempDimSetEntry: Record "Dimension Set Entry" temporary;
        // DimVal: Record "Dimension Value";
        gShortcutDimCode: array[8] of Code[20];
        gShortcutDimValueCode: array[8] of Code[20];
        gDim1, gDim2, gDim3, gDim4, gDim5, gDim6, gDim7, gDim8 : Code[20];
        gDim1Caption, gDim2Caption, gDim3Caption, gDim4Caption, gDim5Caption, gDim6Caption, gDim7Caption, gDim8Caption : Text[30];
}

