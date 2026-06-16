tableextension 27003013 "Std. Ven. Purch. Code-IBIZPR" extends "Standard Vendor Purchase Code"
{
    procedure InsertPurchLinesPR(PRHeader: Record "PR Header")
    var
        StdVendPurchCode: Record "Standard Vendor Purchase Code";
        StdPurchCode: Record "Standard Purchase Code";
        StdVendPurchCodes: Page "Standard Vendor Purchase Codes";
        StdPurchCodes: Page "Standard Purchase Codes";
    begin
        PRHeader.TESTFIELD("No.");
        IF PRHeader."Suggested Vendor" <> '' THEN BEGIN
            StdVendPurchCode.SETRANGE("Vendor No.", PRHeader."Suggested Vendor");
            StdVendPurchCodes.SETTABLEVIEW(StdVendPurchCode);
            StdVendPurchCodes.LOOKUPMODE(TRUE);
            IF StdVendPurchCodes.RUNMODAL = ACTION::LookupOK THEN BEGIN
                StdVendPurchCodes.GetSelected(StdVendPurchCode);
                IF StdVendPurchCode.FINDSET THEN
                    REPEAT
                        ApplyStdCodesToPurchaseLinesPR(PRHeader, StdVendPurchCode);
                    UNTIL StdVendPurchCode.NEXT = 0;
            END;
        END ELSE BEGIN
            StdPurchCodes.LOOKUPMODE(TRUE);
            IF StdPurchCodes.RUNMODAL = ACTION::LookupOK THEN BEGIN
                // StdPurchCodes.GetSelected(StdPurchCode);
                IF StdPurchCode.FINDSET THEN
                    REPEAT
                        ApplyStdCodesToPR(PRHeader, StdPurchCode);
                    UNTIL StdPurchCode.NEXT = 0;
            END;

        END;
    end;

    procedure ApplyStdCodesToPurchaseLinesPR(PRHeader: Record "PR Header"; StdVendPurchCode: Record "Standard Vendor Purchase Code")
    var
        Currency: Record Currency;
        PRLine: Record "PR Line";
        StdPurchLine: Record "Standard Purchase Line";
        StdPurchCode: Record "Standard Purchase Code";
        Factor: Integer;
    begin
        IF PRHeader."Currency Code" = '' THEN
            Currency.InitRoundingPrecision
        ELSE
            Currency.GET(PRHeader."Currency Code");

        StdVendPurchCode.TESTFIELD(Code);
        StdVendPurchCode.TESTFIELD("Vendor No.", PRHeader."Suggested Vendor");
        StdPurchCode.GET(StdVendPurchCode.Code);
        StdPurchCode.TESTFIELD("Currency Code", PRHeader."Currency Code");
        StdPurchLine.SETRANGE("Standard Purchase Code", StdVendPurchCode.Code);
        PRLine."PR Document Type" := PRHeader."PR Document Type";
        PRLine."Document No." := PRHeader."No.";
        PRLine.SETRANGE("PR Document Type", PRHeader."PR Document Type");
        PRLine.SETRANGE("Document No.", PRHeader."No.");

        PRLine.LOCKTABLE;
        StdPurchLine.LOCKTABLE;
        IF StdPurchLine.FIND('-') THEN
            REPEAT
                PRLine.INIT;
                PRLine."Line No." := 0;

                IF StdPurchLine.Type = StdPurchLine.Type::Item THEN
                    PRLine.VALIDATE(Type, PRLine.Type::Item);
                IF StdPurchLine.Type = StdPurchLine.Type::"G/L Account" THEN
                    PRLine.VALIDATE(Type, PRLine.Type::"G/L Account");
                IF StdPurchLine.Type = StdPurchLine.Type::" " THEN BEGIN
                    PRLine.VALIDATE("No.", StdPurchLine."No.");
                    PRLine.Description := StdPurchLine.Description
                END ELSE
                    IF NOT StdPurchLine.EmptyLine THEN BEGIN
                        IF StdPurchLine."No." <> '' THEN
                            PRLine.VALIDATE("No.", StdPurchLine."No.");

                        PRLine.VALIDATE(Quantity, StdPurchLine.Quantity);
                        IF StdPurchLine."Unit of Measure Code" <> '' THEN
                            PRLine.VALIDATE("Unit of  Measure", StdPurchLine."Unit of Measure Code");
                        PRLine.Description := StdPurchLine.Description;

                        IF (StdPurchLine.Type = StdPurchLine.Type::"G/L Account") OR
                           (StdPurchLine.Type = StdPurchLine.Type::"Charge (Item)")
                        THEN
                            PRLine.VALIDATE("Unit Cost",
                              ROUND(StdPurchLine."Amount Excl. VAT", Currency."Unit-Amount Rounding Precision"));

                    END;

                PRLine.VALIDATE("Shortcut Dimension 1 Code", StdPurchLine."Shortcut Dimension 1 Code");
                PRLine.VALIDATE("Shortcut Dimension 2 Code", StdPurchLine."Shortcut Dimension 2 Code");

                CombineDimensionsPR(PRLine, StdPurchLine);

                IF StdPurchLine.InsertLine THEN BEGIN
                    PRLine."Line No." := GetNextLineNoPR(PRLine);
                    PRLine.INSERT(TRUE);
                    //InsertExtendedTextPR(PRLine);
                END;
            UNTIL StdPurchLine.NEXT = 0;
    end;

    procedure ApplyStdCodesToPR(PRHeader: Record "PR Header"; StdPurchCode: Record "Standard Purchase Code")
    var
        Currency: Record Currency;
        PRLine: Record "PR Line";
        StdPurchLine: Record "Standard Purchase Line";
        Factor: Integer;
    begin
        IF PRHeader."Currency Code" = '' THEN
            Currency.InitRoundingPrecision
        ELSE
            Currency.GET(PRHeader."Currency Code");

        StdPurchLine.SETRANGE("Standard Purchase Code", StdPurchCode.Code);
        PRLine."PR Document Type" := PRHeader."PR Document Type";
        PRLine."Document No." := PRHeader."No.";
        PRLine.SETRANGE("PR Document Type", PRHeader."PR Document Type");
        PRLine.SETRANGE("Document No.", PRHeader."No.");

        PRLine.LOCKTABLE;
        StdPurchLine.LOCKTABLE;
        IF StdPurchLine.FIND('-') THEN
            REPEAT
                PRLine.INIT;
                PRLine."Line No." := 0;

                IF StdPurchLine.Type = StdPurchLine.Type::Item THEN
                    PRLine.VALIDATE(Type, PRLine.Type::Item);
                IF StdPurchLine.Type = StdPurchLine.Type::"G/L Account" THEN
                    PRLine.VALIDATE(Type, PRLine.Type::"G/L Account");
                IF StdPurchLine.Type = StdPurchLine.Type::" " THEN BEGIN
                    PRLine.VALIDATE("No.", StdPurchLine."No.");
                    PRLine.Description := StdPurchLine.Description
                END ELSE
                    IF NOT StdPurchLine.EmptyLine THEN BEGIN
                        IF StdPurchLine."No." <> '' THEN
                            PRLine.VALIDATE("No.", StdPurchLine."No.");

                        PRLine.VALIDATE(Quantity, StdPurchLine.Quantity);
                        IF StdPurchLine."Unit of Measure Code" <> '' THEN
                            PRLine.VALIDATE("Unit of  Measure", StdPurchLine."Unit of Measure Code");
                        PRLine.Description := StdPurchLine.Description;

                        IF (StdPurchLine.Type = StdPurchLine.Type::"G/L Account") OR
                           (StdPurchLine.Type = StdPurchLine.Type::"Charge (Item)")
                        THEN
                            PRLine.VALIDATE("Unit Cost",
                              ROUND(StdPurchLine."Amount Excl. VAT", Currency."Unit-Amount Rounding Precision"));
                    END;

                PRLine.VALIDATE("Shortcut Dimension 1 Code", StdPurchLine."Shortcut Dimension 1 Code");
                PRLine.VALIDATE("Shortcut Dimension 2 Code", StdPurchLine."Shortcut Dimension 2 Code");

                CombineDimensionsPR(PRLine, StdPurchLine);

                IF StdPurchLine.InsertLine THEN BEGIN
                    PRLine."Line No." := GetNextLineNoPR(PRLine);
                    PRLine.INSERT(TRUE);
                    //InsertExtendedTextPR(PRLine);
                END;
            UNTIL StdPurchLine.NEXT = 0;
    end;

    local procedure CombineDimensionsPR(VAR PRLine: Record "PR Line"; StdPurchaseLine: Record "Standard Purchase Line")
    var
        DimensionManagement: Codeunit DimensionManagement;
        DimensionSetIDArr: array[10] of Integer;
    begin
        DimensionSetIDArr[1] := PRLine."Dimension Set ID";
        DimensionSetIDArr[2] := StdPurchaseLine."Dimension Set ID";

        PRLine."Dimension Set ID" :=
          DimensionManagement.GetCombinedDimensionSetID(
            DimensionSetIDArr, PRLine."Shortcut Dimension 1 Code", PRLine."Shortcut Dimension 2 Code");
    end;

    local procedure GetNextLineNoPR(PRLine: Record "PR Line"): Integer
    begin
        PRLine.SETRANGE("Document No.", PRLine."Document No.");
        IF PRLine.FINDLAST THEN
            EXIT(PRLine."Line No." + 10000);

        EXIT(10000);
    end;

    LOCAL procedure InsertExtendedTextPR(PRLine: Record "PR Line")
    var
        TransferExtendedText: Codeunit "Transfer Extended Text";
    begin

    end;
}