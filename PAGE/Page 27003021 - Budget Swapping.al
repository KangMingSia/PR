page 27003021 "Budget Swapping"
{
    ApplicationArea = all;
    UsageCategory = Tasks;
    Caption = 'Budget Swapping';
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Budget Name"; "Budget Name")
                {
                    Caption = 'Budget Name';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        "G/LBudgetName".RESET;
                        if PAGE.RUNMODAL(121, "G/LBudgetName") = ACTION::LookupOK then
                            "Budget Name" := "G/LBudgetName".Name;
                    end;
                }
                field("Amount to Transfer"; "Amount to Transfer")
                {
                    Caption = 'Amount to Transfer';
                    NotBlank = true;
                }
                field("Transfer Date"; "Transfer Date")
                {
                    Caption = 'Transfer Date';
                    NotBlank = true;
                }
            }
            group(From)
            {
                field("From G/L Account"; "From G/L Account")
                {
                    Caption = 'G/L Account';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        "G/LAccount".RESET;
                        if PAGE.RUNMODAL(18, "G/LAccount") = ACTION::LookupOK then
                            "From G/L Account" := "G/LAccount"."No.";
                    end;

                    trigger OnValidate();
                    begin
                        "G/LAccount".RESET;
                        "G/LAccount".SETRANGE("G/LAccount"."No.", "From G/L Account");
                        if not "G/LAccount".FINDFIRST then
                            ERROR(TEXT001, "From G/L Account");
                    end;
                }
                field("From Cost center"; "From Cost center")
                {
                    CaptionClass = '1,1,1';
                    // Caption = 'From Cost center';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 1 Code");
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            "From Cost center" := DimensionValue.Code;
                    end;

                    trigger OnValidate();
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 1 Code");
                        DimensionValue.SETRANGE(Code, "From Cost center");
                        if not DimensionValue.FINDFIRST then
                            ERROR(TEXT002, "From Cost center");
                    end;
                }
                field("From Global Dimension 2 Code"; "From Global Dimension 2 Code")
                {
                    CaptionClass = '1,1,2';

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 2 Code");
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            "From Global Dimension 2 Code" := DimensionValue.Code;
                    end;

                    trigger OnValidate();
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 2 Code");
                        DimensionValue.SETRANGE(Code, "From Global Dimension 2 Code");
                        if not DimensionValue.FINDFIRST then
                            ERROR(TEXT002, "From Global Dimension 2 Code");
                    end;
                }
            }
            group(To)
            {
                field("To G/L Account"; "To G/L Account")
                {
                    Caption = 'G/L Account';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        "G/LAccount".RESET;

                        if PAGE.RUNMODAL(18, "G/LAccount") = ACTION::LookupOK then
                            "To G/L Account" := "G/LAccount"."No.";
                    end;

                    trigger OnValidate();
                    begin
                        "G/LAccount".RESET;
                        "G/LAccount".SETRANGE("G/LAccount"."No.", "To G/L Account");
                        if not "G/LAccount".FINDFIRST then
                            ERROR(TEXT001, "From G/L Account");
                    end;
                }
                field("To Cost center"; "To Cost center")
                {
                    CaptionClass = '1,1,1';
                    // Caption = 'To Cost center';
                    NotBlank = true;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 1 Code");
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            "To Cost center" := DimensionValue.Code;
                    end;

                    trigger OnValidate();
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 1 Code");
                        DimensionValue.SETRANGE(Code, "To Cost center");
                        if not DimensionValue.FINDFIRST then
                            ERROR(TEXT002, "To Cost center");
                    end;
                }
                field("To Global Dimension 2 Code"; "To Global Dimension 2 Code")
                {
                    CaptionClass = '1,1,2';

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 2 Code");
                        if PAGE.RUNMODAL(560, DimensionValue) = ACTION::LookupOK then
                            "To Global Dimension 2 Code" := DimensionValue.Code;
                    end;

                    trigger OnValidate();
                    begin
                        GLSetup.GET;
                        DimensionValue.RESET;
                        DimensionValue.SETRANGE("Dimension Code", GLSetup."Global Dimension 2 Code");
                        DimensionValue.SETRANGE(Code, "To Global Dimension 2 Code");
                        if not DimensionValue.FINDFIRST then
                            ERROR(TEXT002, "To Global Dimension 2 Code");
                    end;
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Confirm;
                action("<Action11>")
                {
                    Caption = 'P&ost';
                    Image = Post;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction();
                    begin
                        if ("Amount to Transfer" = 0) then
                            ERROR('Amount to Transfer field should not be Empty');
                        if ("Transfer Date" = 0D) then
                            ERROR('Transfer Date field should not be Empty');
                        if ("From G/L Account" = '') then
                            ERROR('From G/L Account field should not be Empty');
                        if ("From Cost center" = '') then
                            ERROR('From Cost center field should not be Empty');
                        if ("To G/L Account" = '') then
                            ERROR('To G/L Account field should not be Empty');
                        if ("To Cost center" = '') then
                            ERROR('To Cost center field should not be Empty');

                        CheckBudgetAvailability("From G/L Account", "From Cost center", "From Global Dimension 2 Code", "Amount to Transfer");

                        if not CONFIRM('Do you want to Swap the budget ?', true) then
                            exit;

                        BudjetSwapEntry.RESET;
                        BudjetSwapEntry.SETCURRENTKEY("Entry No.");
                        if BudjetSwapEntry.FINDLAST then
                            EntryNo := BudjetSwapEntry."Entry No." + 1
                        else
                            EntryNo := 1;

                        BudjetSwapEntry.INIT;
                        BudjetSwapEntry."Entry No." := EntryNo;
                        BudjetSwapEntry."Transfer Date" := "Transfer Date";
                        BudjetSwapEntry."Transfer Time" := TIME;
                        BudjetSwapEntry."From G/L Account" := "From G/L Account";
                        BudjetSwapEntry."From Cost center" := "From Cost center";
                        BudjetSwapEntry."From Global Dimension 2 Code" := "From Global Dimension 2 Code";
                        BudjetSwapEntry."To G/L Account" := "To G/L Account";
                        BudjetSwapEntry."To Cost center" := "To Cost center";
                        BudjetSwapEntry."To Global Dimension 2 Code" := "To Global Dimension 2 Code";
                        BudjetSwapEntry."Amount Transfer" := "Amount to Transfer";
                        BudjetSwapEntry."User ID" := USERID;
                        BudjetSwapEntry."Budget Name" := "Budget Name";
                        BudjetSwapEntry.INSERT;

                        "G/LBudgetEntry".RESET;
                        "G/LBudgetEntry".SETCURRENTKEY("Entry No.");
                        if "G/LBudgetEntry".FINDLAST then
                            GLEntryNo := "G/LBudgetEntry"."Entry No." + 1
                        else
                            GLEntryNo := 1;

                        "G/LBudgetEntry".INIT;
                        "G/LBudgetEntry"."Entry No." := GLEntryNo;
                        "G/LBudgetEntry"."Budget Name" := "Budget Name";
                        "G/LBudgetEntry"."G/L Account No." := "To G/L Account";
                        "G/LBudgetEntry".Date := "Transfer Date";
                        "G/LBudgetEntry".Amount := ("Amount to Transfer");
                        "G/LBudgetEntry"."Budget Swapping No." := EntryNo;
                        "G/LBudgetEntry"."Global Dimension 1 Code" := "To Cost center";
                        "G/LBudgetEntry"."Global Dimension 2 Code" := "To Global Dimension 2 Code";
                        "G/LBudgetEntry".Description := 'Budget Swapping';
                        "G/LBudgetEntry"."User ID" := USERID;
                        "G/LBudgetEntry".Date := "Transfer Date";
                        "G/LBudgetEntry".INSERT;

                        "G/LBudgetEntry".RESET;
                        "G/LBudgetEntry".SETCURRENTKEY("Entry No.");
                        if "G/LBudgetEntry".FINDLAST then
                            GLEntryNo := "G/LBudgetEntry"."Entry No." + 1
                        else
                            GLEntryNo := 1;

                        "G/LBudgetEntry".INIT;
                        "G/LBudgetEntry"."Entry No." := GLEntryNo;
                        "G/LBudgetEntry"."Budget Name" := "Budget Name";
                        "G/LBudgetEntry"."G/L Account No." := "From G/L Account";
                        "G/LBudgetEntry".Date := "Transfer Date";
                        "G/LBudgetEntry".Amount := -("Amount to Transfer");
                        "G/LBudgetEntry"."Budget Swapping No." := EntryNo;
                        "G/LBudgetEntry".Description := 'Budget Swapping';
                        "G/LBudgetEntry"."User ID" := USERID;
                        "G/LBudgetEntry".Date := "Transfer Date";
                        "G/LBudgetEntry"."Global Dimension 1 Code" := "From Cost center";
                        "G/LBudgetEntry"."Global Dimension 2 Code" := "From Global Dimension 2 Code";
                        "G/LBudgetEntry".INSERT;


                        if ("From G/L Account" = "To G/L Account") and ("From Cost center" = "To Cost center") then
                            ERROR(TEXT003);

                        MESSAGE('Budjet Swapping successfully posted.');

                        CLEAR("Transfer Date");
                        CLEAR("Amount to Transfer");
                        CLEAR("From G/L Account");
                        CLEAR("From Cost center");
                        CLEAR("From Global Dimension 2 Code");
                        CLEAR("To G/L Account");
                        CLEAR("To Cost center");
                        CLEAR("To Global Dimension 2 Code");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        CLEAR("Amount to Transfer");
        CLEAR("From G/L Account");
        CLEAR("From Cost center");
        CLEAR("From Global Dimension 2 Code");
        CLEAR("To G/L Account");
        CLEAR("To Cost center");
        CLEAR("To Global Dimension 2 Code");
    end;

    var
        "Budget Name": Code[10];
        "Amount to Transfer": Decimal;
        "Transfer Date": Date;
        "From G/L Account": Code[20];
        "From Cost center": Code[20];
        "From Global Dimension 2 Code": Code[20];
        "To G/L Account": Code[20];
        "To Cost center": Code[20];
        "To Global Dimension 2 Code": Code[20];
        "G/LAccount": Record "G/L Account";
        DimensionValue: Record "Dimension Value";
        "G/LBudgetName": Record "G/L Budget Name";
        BudjetSwapEntry: Record "Budget Swap Entry";
        "G/LBudgetEntry": Record "G/L Budget Entry";
        EntryNo: Integer;
        GLEntryNo: Integer;
        TEXT001: Label 'G/L Account No. %1 Doesn''t Exist in G/L Entry';
        TEXT002: Label 'Cost Center %1 Doesn''t Exists in Dimension Value';
        TEXT003: Label 'From G/L Account No. and To G/L Account No., From Cost Center and To Cost Center Should not be same';
        GLSetup: Record "General Ledger Setup";
        PPSetup: Record "Purchases & Payables Setup";

    procedure GetBudgetName(Name: Code[10]);
    begin
        "Budget Name" := Name;
    end;

    local procedure CheckBudgetAvailability(GLAccountNo: Code[20]; Dim1Code: Code[20]; Dim2Code: Code[20]; AmtToTransfer: Decimal)
    var
        GLBEntry: Record "G/L Budget Entry";
        GLEntry: Record "G/L Entry";
        PRLineRec: Record "PR Line";
        PurchLineRec: Record "Purchase Line";
        GLAccRec: Record "G/L Account";
        TotalBudgetAmt: Decimal;
        UtilisedAmt: Decimal;
        OnHoldAmt: Decimal;
        AvailableAmt: Decimal;
    begin
        PPSetup.GET;
        if PPSetup."PR Budget Name" = '' then
            ERROR('PR Budget Name is not set in Purchases & Payables Setup.');

        // Total Budget from G/L Budget Entry
        GLAccRec.GET(GLAccountNo);
        GLBEntry.RESET;
        if GLAccRec."Budget Link A/C" <> '' then
            GLBEntry.SETFILTER("G/L Account No.", '%1|%2', GLAccountNo, GLAccRec."Budget Link A/C")
        else
            GLBEntry.SETFILTER("G/L Account No.", '%1', GLAccountNo);
        GLBEntry.SETRANGE("Budget Name", PPSetup."PR Budget Name");
        if Dim1Code <> '' then
            GLBEntry.SETRANGE("Global Dimension 1 Code", Dim1Code);
        if Dim2Code <> '' then
            GLBEntry.SETRANGE("Global Dimension 2 Code", Dim2Code);
        GLBEntry.SETRANGE(Date, PPSetup."Budget Start Date", PPSetup."Budget End Date");
        if GLBEntry.FINDSET then
            repeat
                TotalBudgetAmt += GLBEntry.Amount;
            until GLBEntry.NEXT = 0;

        // Utilised = actual G/L Entries posted
        GLEntry.RESET;
        if GLAccRec."Budget Link A/C" <> '' then
            GLEntry.SETFILTER("G/L Account No.", '%1|%2', GLAccountNo, GLAccRec."Budget Link A/C")
        else
            GLEntry.SETRANGE("G/L Account No.", GLAccountNo);
        GLEntry.SETRANGE("Posting Date", PPSetup."Budget Start Date", PPSetup."Budget End Date");
        if Dim1Code <> '' then
            GLEntry.SETRANGE("Global Dimension 1 Code", Dim1Code);
        if Dim2Code <> '' then
            GLEntry.SETRANGE("Global Dimension 2 Code", Dim2Code);
        if GLEntry.FINDSET then
            repeat
                UtilisedAmt += GLEntry.Amount;
            until GLEntry.NEXT = 0;

        // On Hold = PR Lines (Released / Pending Approval / Closed, not converted to order)
        PRLineRec.RESET;
        if GLAccRec."Budget Link A/C" <> '' then
            PRLineRec.SETFILTER("No.", '%1|%2', GLAccountNo, GLAccRec."Budget Link A/C")
        else
            PRLineRec.SETRANGE("No.", GLAccountNo);
        if Dim1Code <> '' then
            PRLineRec.SETRANGE("Shortcut Dimension 1 Code", Dim1Code);
        if Dim2Code <> '' then
            PRLineRec.SETRANGE("Shortcut Dimension 2 Code", Dim2Code);
        PRLineRec.SETRANGE(ConvertedtoOrder, false);
        PRLineRec.SETFILTER(Status, '%1|%2|%3',
            PRLineRec.Status::Released, PRLineRec.Status::Closed, PRLineRec.Status::"Pending Approval");
        if PRLineRec.FINDSET then
            repeat
                OnHoldAmt += PRLineRec.Amount;
            until PRLineRec.NEXT = 0;

        // On Hold += Purchase Lines (outstanding commitments)
        PurchLineRec.RESET;
        if GLAccRec."Budget Link A/C" <> '' then
            PurchLineRec.SETFILTER("G/L Account No.", '%1|%2', GLAccountNo, GLAccRec."Budget Link A/C")
        else
            PurchLineRec.SETRANGE("G/L Account No.", GLAccountNo);
        if Dim1Code <> '' then
            PurchLineRec.SETRANGE("Shortcut Dimension 1 Code", Dim1Code);
        if Dim2Code <> '' then
            PurchLineRec.SETRANGE("Shortcut Dimension 2 Code", Dim2Code);
        if PurchLineRec.FINDSET then
            repeat
                OnHoldAmt += PurchLineRec."Outstanding Amount (LCY)" + PurchLineRec."Amt. Rcd. Not Invoiced (LCY)";
            until PurchLineRec.NEXT = 0;

        AvailableAmt := TotalBudgetAmt - UtilisedAmt - OnHoldAmt;

        if AvailableAmt < AmtToTransfer then
            ERROR('Insufficient budget for G/L Account %1 (Cost Center: %2). Budget: %3, Utilised: %4, On Hold: %5, Available: %6, Required: %7',
                GLAccountNo, Dim1Code, TotalBudgetAmt, UtilisedAmt, OnHoldAmt, AvailableAmt, AmtToTransfer);
    end;
}

