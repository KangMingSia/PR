codeunit 27003010 "PR Functions-IBIZRFQ"
{

    /* 

      [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnUpdateAllLineDimOnBeforePurchLineModify', '', false, false)]
      local procedure OnUpdateAllLineDimOnBeforePurchLineModify(var PurchaseLine: Record "Purchase Line")
      var
          lShortcutDimCode: array[8] of Code[20];
          GLSetup: Record "General Ledger Setup";
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
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[3]) then
              PurchaseLine."Shortcut Dimension 3 Code" := lDimensionSetEntry."Dimension Value Code";
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[4]) then
              PurchaseLine."Shortcut Dimension 4 Code" := lDimensionSetEntry."Dimension Value Code";
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[5]) then
              PurchaseLine."Shortcut Dimension 5 Code" := lDimensionSetEntry."Dimension Value Code";
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[6]) then
              PurchaseLine."Shortcut Dimension 6 Code" := lDimensionSetEntry."Dimension Value Code";
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[7]) then
              PurchaseLine."Shortcut Dimension 7 Code" := lDimensionSetEntry."Dimension Value Code";
          if lDimensionSetEntry.Get(PurchaseLine."Dimension Set ID", lShortcutDimCode[8]) then
              PurchaseLine."Shortcut Dimension 8 Code" := lDimensionSetEntry."Dimension Value Code";
      end;

      [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterShowDimensions', '', false, false)]
      local procedure OnAfterShowDimensions(var PurchaseLine: Record "Purchase Line"; xPurchaseLine: Record "Purchase Line")
      begin
          if PurchaseLine."PR No." <> '' then
              if PurchaseLine."Dimension Set ID" <> xPurchaseLine."Dimension Set ID" then begin
                  PurchaseLine."Dimension Set ID" := xPurchaseLine."Dimension Set ID";
                  Message('Document created from PR, not possible to change dimension.');
              end;
      end;
     */  //19.0.0.7>>
         // [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnShowDocDimOnAfterSetDimensionSetID', '', false, false)]
         // local procedure OnShowDocDimOnAfterSetDimensionSetID(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header")
         // begin
         //     if PurchaseHeader."PR No." <> '' then
         //         if PurchaseHeader."Dimension Set ID" <> xPurchaseHeader."Dimension Set ID" then begin
         //             PurchaseHeader."Dimension Set ID" := xPurchaseHeader."Dimension Set ID";
         //             Message('Document created from PR, not possible to change dimension.');
         //         end;
         // end;

    /*  [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeShowDocDim', '', false, false)]
     local procedure OnBeforeShowDocDim(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
     begin
         if PurchaseHeader."PR No." <> '' then
             if PurchaseHeader."Dimension Set ID" <> xPurchaseHeader."Dimension Set ID" then begin
                 PurchaseHeader."Dimension Set ID" := xPurchaseHeader."Dimension Set ID";
                 Message('Document created from PR, not possible to change dimension.');
             end;
         IsHandled := true;
     end; */
    //19.0.0.7<<
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnCreateDimOnBeforeUpdateLines', '', false, false)]
    local procedure OnCreateDimOnBeforeUpdateLines(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; CurrentFieldNo: Integer)
    var
        PurchasePaysetup: Record "Purchases & Payables Setup";
    begin
        PurchasePaysetup.GET;
        if PurchasePaysetup."Dimension for PR Approval" then begin
            PurchaseHeader."Converted to PO" := xPurchaseHeader."Converted to PO";
            PurchaseHeader."WBS ID" := xPurchaseHeader."WBS ID";
            PurchaseHeader."Activity ID" := xPurchaseHeader."Activity ID";
            PurchaseHeader."PR No." := xPurchaseHeader."PR No.";
            PurchaseHeader."PR Line No." := xPurchaseHeader."PR Line No.";
            PurchaseHeader."Shortcut Dimension 1 Code" := xPurchaseHeader."Shortcut Dimension 1 Code";
            PurchaseHeader."Shortcut Dimension 2 Code" := xPurchaseHeader."Shortcut Dimension 2 Code";
            PurchaseHeader."Dimension Set ID" := xPurchaseHeader."Dimension Set ID";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnRecreatePurchLinesOnBeforeInsertPurchLine', '', false, false)]
    local procedure OnRecreatePurchLinesOnBeforeInsertPurchLine(var PurchaseLine: Record "Purchase Line"; var TempPurchaseLine: Record "Purchase Line" temporary; ChangedFieldName: Text[100])
    begin
        PurchaseLine."Create PO" := TempPurchaseLine."Create PO";
        PurchaseLine."PQ No" := TempPurchaseLine."PQ No";
        PurchaseLine."PQ Line No" := TempPurchaseLine."PQ Line No";
        PurchaseLine."RFQ No." := TempPurchaseLine."RFQ No.";
        PurchaseLine."Converted to PO" := TempPurchaseLine."Converted to PO";
        PurchaseLine."PO No" := TempPurchaseLine."PO No";
        PurchaseLine."PO Line No." := TempPurchaseLine."PO Line No.";
        PurchaseLine."Requested Quantity" := TempPurchaseLine."Requested Quantity";
        PurchaseLine."WBS ID" := TempPurchaseLine."WBS ID";
        PurchaseLine."Activity ID" := TempPurchaseLine."Activity ID";
        PurchaseLine."Remarks" := TempPurchaseLine."Remarks";
        PurchaseLine."Reason for Shortlist" := TempPurchaseLine."Reason for Shortlist";
        PurchaseLine."Bold" := TempPurchaseLine."Bold";
        PurchaseLine."PR In G/L" := TempPurchaseLine."PR In G/L";
        PurchaseLine."G/L Total Amt for PR" := TempPurchaseLine."G/L Total Amt for PR";
        PurchaseLine."PR No." := TempPurchaseLine."PR No.";
        PurchaseLine."PR Line No." := TempPurchaseLine."PR Line No.";
        PurchaseLine."Shortcut Dimension 1 Code" := TempPurchaseLine."Shortcut Dimension 1 Code";
        PurchaseLine."Shortcut Dimension 2 Code" := TempPurchaseLine."Shortcut Dimension 2 Code";
        PurchaseLine."Dimension Set ID" := TempPurchaseLine."Dimension Set ID";
        //19.0.0.7>>
        PurchaseLine."Shortcut Dimension 3 Code" := TempPurchaseLine."Shortcut Dimension 3 Code";
        PurchaseLine."Shortcut Dimension 4 Code" := TempPurchaseLine."Shortcut Dimension 4 Code";
        PurchaseLine."Shortcut Dimension 5 Code" := TempPurchaseLine."Shortcut Dimension 5 Code";
        PurchaseLine."Shortcut Dimension 6 Code" := TempPurchaseLine."Shortcut Dimension 6 Code";
        PurchaseLine."Shortcut Dimension 7 Code" := TempPurchaseLine."Shortcut Dimension 7 Code";
        PurchaseLine."Shortcut Dimension 8 Code" := TempPurchaseLine."Shortcut Dimension 8 Code";
        //19.0.0.7<<
    end;

    var
        RFQHeader: Record "RFQ Comparison";
        GVend: Record Vendor;
        GQuotes: Text[1024];
        GLSetup: Record "General Ledger Setup";
        PRLine: Record "PR Line";
        PRLine2: Record "PR Line";
        PRCode: Code[20];
        VendorDesc: Text[200];
        Noseries: Record "No. Series";
        DocDim: Codeunit DimensionManagement;
        GImportBudget: Record "Budget Import";
        GTotalInvoice: Decimal;
        GTotalCrLine: Decimal;
        GTotalPurchaseLines: Decimal;
        GTotalReturn: Decimal;
        GTotalPReq: Decimal;
        GTotalBudgetOnHold: Decimal;
        GTotalPurchaseLinesUtilised: Decimal;
        GRFQHeader: Record "RFQ Comparison";
        GPRLine: Record "PR Line";
        GPurchInvHdr: Record "Purch. Inv. Header";
        GPurchInvLine: Record "Purch. Inv. Line";
        GPurchCrHdr: Record "Purch. Cr. Memo Hdr.";
        GPurchCrLine: Record "Purch. Cr. Memo Line";
        GPurchHdr: Record "Purchase Header";
        GPurchLine: Record "Purchase Line";
        CurrExchRate: Record "Currency Exchange Rate";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
        RFQHeaderRec: Record "PR Header";
        StartDate: Date;
        EndDate: Date;
        GText001: Label '"Following Purchase Quote(s) has been created.\%1 "';
        // GText002: Label '"Following Purchase Order(s) has been created.\%1 "';//19.0.0.9
        GText002: Label '"Following Retail Purchase Order(s) has been created.\%1 "';//19.0.0.9
        GText003: Label 'Enter Suggested Vendor for the Document';
        GText004: Label 'Purchase Requisition %1 has been Released';
        GText005: Label 'Purchase Requisition %1 has been Reopened';
        GText006: Label 'Purchase Quote has already been converted to PO';
        GText007: Label 'User setup does not exist';
        GText008: Label 'Amount exceeds the available budget for %1 : %2, Line No:%3';
        GText009: Label 'Document needs to approved before release';
        GText010: Label 'Cannot have more than one Vendor for PO';
        GText011: Label 'No newly added vendor';
        GText012: Label '"Purchase Quote number series is empty and needs to be setup "';
        GText013: Label 'Purchase Order number series is empty and needs to be setup';
        GText014: Label 'Purchase Quote Comparison number series is empty and needs to be setup';
        GText015: Label 'RFQ Comparision %1 has been released';
        GText017: Label 'RFQ Comparision %1 has been Reopened';
        Text007: Label 'Archive PR no.: %1?';
        Lvendor: Integer;
        HoldUPCPRTotal: Decimal;
        TempSuggestVend: Code[20];
        Linevendor: Boolean;
        PPSetup: Record "Purchases & Payables Setup";
        GText016: Label 'Purchase Requisition %1 has been Cancelled';
        Text032: Label 'The combination of dimensions used in %1 is blocked. %2';
        Text033: Label 'The combination of dimensions used in %1, line no. %2 is blocked. %3';
        Text034: Label 'The dimensions used in %1 are invalid. %2';
        Text035: Label 'The dimensions used in %1, line no. %2 are invalid. %3';
        GLAccount2: Record "G/L Account";

    procedure ConvertToQuote(var lPRHdr: Record "PR Header");
    var
        lPRLine: Record "PR Line";
        lPRLineToChangeConvertToQuote: Record "PR Line";
        lSuggestedVendor: Record "Suggested Vendor";
        lPurchSetup: Record "Purchases & Payables Setup";
        lNoSeriesMgt: Codeunit NoSeriesManagement;
        lPReqQuote: Record "RFQ Comparison";
        lSugVend: Record "Suggested Vendor";
        lDescriptionPRLine: Record "PR Line";
        lPurchaseQuoteDescription: Record "Purchase Header";
        lpurchaseQuoteLineDesc: Record "Purchase Line";
    begin
        lPRHdr.TESTFIELD("PR Document Type", lPRHdr."PR Document Type"::RFQ);
        lPRHdr.TESTFIELD("Purchaser Code");
        lPRHdr.TESTFIELD(Status, lPRHdr.Status::Released);

        lSugVend.RESET;
        lSugVend.SETRANGE("PR No.", lPRHdr."No.");
        lSugVend.SETFILTER("Suggested Vendor", '<>%1', '');
        if not lSugVend.FINDSET then
            ERROR(GText003);

        Noseries.RESET;
        Noseries.SETRANGE(Code, lPRHdr."No. series");
        if Noseries.FINDFIRST then
            if Noseries."RFQ Comparison" = '' then
                ERROR(GText014);

        CLEAR(GQuotes);
        CLEAR(PRCode);
        lSuggestedVendor.RESET;
        lSuggestedVendor.SETRANGE("Document Type", lSuggestedVendor."Document Type"::"PR Header");
        lSuggestedVendor.SETRANGE("PR No.", lPRHdr."No.");
        lSuggestedVendor.SETFILTER("Suggested Vendor", '<>%1', '');
        if lSuggestedVendor.FINDSET then begin
            if PRCode = '' then begin
                lPReqQuote.INIT;
                lPReqQuote."No." := lNoSeriesMgt.GetNextNo(Noseries."RFQ Comparison", TODAY, true);
                lPReqQuote.Description := lPRHdr.Description;
                lPReqQuote."PR No" := lPRHdr."No.";
                lPReqQuote."No. series" := Noseries."RFQ Comparison";
                lPReqQuote.Requester := lPRHdr.Requester;
                lPReqQuote."Co-ordinator" := lPRHdr."Co-ordinator";
                PRCode := lPReqQuote."No.";
                lPReqQuote.INSERT;
            end;
            repeat
                CLEAR(VendorDesc);
                if GVend.GET(lSuggestedVendor."Suggested Vendor") then;
                MakeQuoteForVendor(GVend, lPRHdr);
                lSuggestedVendor.Converted := true;
                lSuggestedVendor.MODIFY;
            until lSuggestedVendor.NEXT = 0;
        end;
        lPRHdr.Status := lPRHdr.Status::Closed;
        lPRHdr."PR Status" := lPRHdr."PR Status"::RFQ;
        lPRHdr.MODIFY;

        lDescriptionPRLine.RESET;
        lDescriptionPRLine.SETRANGE("Document No.", lPRHdr."No.");
        // LDescriptionPRLine.SETRANGE(Type, PRLine.Type::Description);//19.0.0.5
        lDescriptionPRLine.SETRANGE(Type, lPRLine.Type::" ");//19.0.0.5
        if lDescriptionPRLine.FINDSET then
            repeat
                lPurchaseQuoteDescription.RESET;
                lPurchaseQuoteDescription.SETRANGE("Document Type", lPurchaseQuoteDescription."Document Type"::Quote);
                lPurchaseQuoteDescription.SETRANGE("PR No.", lPRHdr."No.");
                if lPurchaseQuoteDescription.FINDSET then
                    repeat
                        lpurchaseQuoteLineDesc.RESET;
                        lpurchaseQuoteLineDesc.SETRANGE("Document Type", lpurchaseQuoteLineDesc."Document Type"::Quote);
                        lpurchaseQuoteLineDesc.SETRANGE("Document No.", lPurchaseQuoteDescription."No.");
                        lpurchaseQuoteLineDesc.SETRANGE("Line No.", lDescriptionPRLine."Line No.");
                        if not lpurchaseQuoteLineDesc.FINDFIRST then begin
                            lpurchaseQuoteLineDesc.INIT;
                            lpurchaseQuoteLineDesc."Document Type" := lpurchaseQuoteLineDesc."Document Type"::Quote;
                            lpurchaseQuoteLineDesc.VALIDATE("Document No.", lPurchaseQuoteDescription."No.");
                            lpurchaseQuoteLineDesc."Line No." := lDescriptionPRLine."Line No.";
                            lpurchaseQuoteLineDesc.INSERT;
                            lpurchaseQuoteLineDesc.VALIDATE(Type, lpurchaseQuoteLineDesc.Type::" ");
                            lpurchaseQuoteLineDesc.VALIDATE("Location Code", lDescriptionPRLine."Delivery Location");
                            lpurchaseQuoteLineDesc.Description := lDescriptionPRLine.Description;
                            lpurchaseQuoteLineDesc."PR No." := lDescriptionPRLine."Document No.";
                            lpurchaseQuoteLineDesc."PR Line No." := lDescriptionPRLine."Line No.";
                            if lpurchaseQuoteLineDesc."G/L Account No." = '' then//19.0.0.4>>
                                lpurchaseQuoteLineDesc."G/L Account No." := lDescriptionPRLine."G/L Account No.";//19.0.0.4>>
                            lpurchaseQuoteLineDesc.Remarks := lDescriptionPRLine.Remarks;
                            lpurchaseQuoteLineDesc."Reason for Shortlist" := lDescriptionPRLine."Reason for Shortlist";
                            //19.0.0.7>>
                            lpurchaseQuoteLineDesc."Shortcut Dimension 3 Code" := lDescriptionPRLine."Shortcut Dimension 3 Code";
                            lpurchaseQuoteLineDesc."Shortcut Dimension 4 Code" := lDescriptionPRLine."Shortcut Dimension 4 Code";
                            lpurchaseQuoteLineDesc."Shortcut Dimension 5 Code" := lDescriptionPRLine."Shortcut Dimension 5 Code";
                            lpurchaseQuoteLineDesc."Shortcut Dimension 6 Code" := lDescriptionPRLine."Shortcut Dimension 6 Code";
                            lpurchaseQuoteLineDesc."Shortcut Dimension 7 Code" := lDescriptionPRLine."Shortcut Dimension 7 Code";
                            lpurchaseQuoteLineDesc."Shortcut Dimension 8 Code" := lDescriptionPRLine."Shortcut Dimension 8 Code";
                            //19.0.0.7<<
                            lpurchaseQuoteLineDesc.MODIFY;
                        end;
                    until lPurchaseQuoteDescription.NEXT = 0;
            until lDescriptionPRLine.NEXT = 0;
        lPRLineToChangeConvertToQuote.RESET;
        lPRLineToChangeConvertToQuote.SETRANGE("Document No.", lPRHdr."No.");
        if lPRLineToChangeConvertToQuote.FINDSET then
            repeat
                lPRLineToChangeConvertToQuote.ConvertedtoQuote := true;
                lPRLineToChangeConvertToQuote.Status := lPRLineToChangeConvertToQuote.Status::Closed;
                lPRLineToChangeConvertToQuote.MODIFY;
            until lPRLineToChangeConvertToQuote.NEXT = 0;
        MESSAGE(GText001, GQuotes);
    end;

    procedure ConvertToQuoteFrPurchaserEntry(var PRHdr: Record "PR Header");
    var
        PRLine: Record "PR Line";
        LPRLineToChangeConvertToQuote: Record "PR Line";
        LSuggestedVendor: Record "Suggested Vendor";
        VendorFound: Boolean;
        PReqQuote: Record "RFQ Comparison";
    begin
        CLEAR(PRCode);
        CLEAR(GQuotes);
        CLEAR(VendorFound);

        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then begin
            repeat
                PRLine.ConvertedtoQuote := false;
                PRLine.MODIFY;
            until PRLine.NEXT = 0;
        end;
        PReqQuote.RESET;
        PReqQuote.SETRANGE("PR No", PRHdr."No.");
        if PReqQuote.FINDFIRST then
            PRCode := PReqQuote."No.";


        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then begin
            repeat
                if PRLine.Quantity <> 0 then begin
                    LSuggestedVendor.RESET;
                    LSuggestedVendor.SETRANGE("Document Type", LSuggestedVendor."Document Type"::"PR Line");
                    LSuggestedVendor.SETRANGE("PR No.", PRLine."Document No.");

                    LSuggestedVendor.SETRANGE("PR Line No.", PRLine."Line No.");
                    LSuggestedVendor.SETRANGE(Converted, false);
                    if LSuggestedVendor.FINDSET then begin
                        repeat
                            CLEAR(VendorDesc);
                            if GVend.GET(LSuggestedVendor."Suggested Vendor") then begin
                                MakeQuoteForVendorLine(GVend, PRHdr, PRLine)
                            end;
                            LSuggestedVendor.Converted := true;
                            LSuggestedVendor.MODIFY;
                        until LSuggestedVendor.NEXT = 0;
                        VendorFound := true;
                    end;
                end;
            until PRLine.NEXT = 0;
        end;
        LSuggestedVendor.RESET;
        LSuggestedVendor.SETRANGE("Document Type", LSuggestedVendor."Document Type"::"PR Header");
        LSuggestedVendor.SETRANGE("PR No.", PRHdr."No.");
        LSuggestedVendor.SETRANGE(Converted, false);
        LSuggestedVendor.SETFILTER(LSuggestedVendor."Suggested Vendor", '<>%1', '');
        if LSuggestedVendor.FINDSET then begin
            repeat
                CLEAR(VendorDesc);
                if GVend.GET(LSuggestedVendor."Suggested Vendor") then;
                MakeQuoteForVendor(GVend, PRHdr);
                LSuggestedVendor.Converted := true;
                LSuggestedVendor.MODIFY;
            until LSuggestedVendor.NEXT = 0;
            VendorFound := true;
        end;
        if VendorFound then
            MESSAGE(GText001, GQuotes)
        else
            MESSAGE(GText011);
    end;

    procedure ConvertToOrder(var lPRHdr: Record "PR Header");
    var
        lPRLine: Record "PR Line";
        lSuggestedVendor: Record "Suggested Vendor";
        lText001: Label 'Prospect vendor '' %1 ''cannot be used to create  Purchase Order';
        lSugVend: Record "Suggested Vendor";
        lApprovalTemp: Record "Approval Templates";
        lTotalAmt: Decimal;
        lNoSeries: Record "No. Series";
        lNoSeriesMgmt: Codeunit NoSeriesManagement;
        lPurchaseHdr: Record "Purchase Header";
        lPurchaseLine: Record "Purchase Line";
        lPOCreated: Boolean;
        lConfirm: Label 'Unit Cost is not entered for one or more lines, Do you want to continue.';
    begin
        lPRHdr.TESTFIELD("PR Document Type", lPRHdr."PR Document Type"::PO);
        lPRHdr.TESTFIELD(lPRHdr."Purchaser Code");//19.0.0.6>>
        lPRHdr.TESTFIELD("Budgetary PR", false);
        lPRHdr.TESTFIELD(Status, lPRHdr.Status::Released);
        lPRHdr.TESTFIELD("PR Status", lPRHdr."PR Status"::PR);
        PPSetup.GET;
        if PPSetup."Dimension for PR Approval" then begin
            lPRHdr.TESTFIELD("Shortcut Dimension 1 Code");
            lPRHdr.TESTFIELD("Shortcut Dimension 2 Code");
        end;
        //19.0.0.6>>
        lPRLine.Reset();
        lPRLine.SETRANGE("Document No.", lPRHdr."No.");
        lPRLine.SETFILTER(lPRLine."Unit Cost", '%1', 0);
        if lPRLine.FindFirst() then
            if not Dialog.Confirm(lConfirm, false) then
                exit;
        //19.0.0.6<<
        CLEAR(Linevendor);
        lPRLine.RESET;
        lPRLine.SETRANGE("Document No.", lPRHdr."No.");
        lPRLine.SETFILTER("Suggested Vendor", '<>%1', '');
        if lPRLine.FINDSET then begin
            Linevendor := true;
            PRLine2.RESET;
            PRLine2.SETRANGE("Document No.", lPRLine."Document No.");
            if PRLine2.FINDSET then
                repeat
                    PRLine2.TESTFIELD("Suggested Vendor");
                until PRLine2.NEXT = 0;
        end else begin
            lSugVend.RESET;
            lSugVend.SETRANGE("PR No.", lPRHdr."No.");
            lSugVend.SETFILTER("Suggested Vendor", '<>%1', '');
            if not lSugVend.FINDSET then
                ERROR(GText003);
        end;

        CLEAR(lTotalAmt);
        lPRLine.RESET;
        lPRLine.SETRANGE("Document No.", lPRHdr."No.");
        // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
        lPRLine.SETFILTER(lPRLine.Type, '<>%1', lPRLine.Type::" ");//19.0.0.5
        if lPRLine.FINDSET then
            repeat
                if PPSetup."Dimension for PR Approval" then begin
                    lPRLine.TESTFIELD("Shortcut Dimension 1 Code");
                    lPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                end;
                lTotalAmt += lPRLine.Amount;
            until lPRLine.NEXT = 0;
        lApprovalTemp.RESET;
        lApprovalTemp.SETRANGE("Document Type", lApprovalTemp."Document Type"::PR);
        lApprovalTemp.SETRANGE(lApprovalTemp."No. series", lPRHdr."No. series");
        if lApprovalTemp.FINDFIRST then begin
            if (lApprovalTemp."PR to PO Amount Limit" <> 0) and (lTotalAmt > lApprovalTemp."PR to PO Amount Limit") then
                ERROR('Convert to PO limit exceeded. Kindly select Document Type RFQ');
        end;
        CLEAR(TempSuggestVend);
        CLEAR(lPOCreated);
        if Linevendor then begin
            lPRLine.RESET;
            lPRLine.SETCURRENTKEY(lPRLine."Document No.", lPRLine."Suggested Vendor");
            lPRLine.SETRANGE("Document No.", lPRHdr."No.");
            if lPRLine.FINDFIRST then begin
                repeat
                    if TempSuggestVend <> lPRLine."Suggested Vendor" then begin
                        PRLine2.RESET;
                        PRLine2.SETRANGE("Document No.", lPRLine."Document No.");
                        PRLine2.SETRANGE("Suggested Vendor", lPRLine."Suggested Vendor");
                        if PRLine2.FINDSET then begin
                            Noseries.RESET;
                            Noseries.SETRANGE(Code, lPRHdr."No. series");
                            if Noseries.FINDFIRST then
                                if Noseries."PR Order" = '' then
                                    ERROR(GText013);

                            if GVend.GET(lPRLine."Suggested Vendor") then
                                if GVend."Prospect Vendor" then
                                    ERROR(lText001, GVend."No.");

                            lPurchaseHdr.INIT;
                            lPurchaseHdr."Document Type" := lPurchaseHdr."Document Type"::Order;
                            lPurchaseHdr."No." := lNoSeriesMgmt.GetNextNo(Noseries."PR Order", lPRHdr."PR Date", true);
                            lPurchaseHdr."No. Series" := Noseries."PR Order";
                            lPurchaseHdr.VALIDATE("Document Date", TODAY);
                            lPurchaseHdr."Your Reference" := lPRHdr.Requester;
                            lPOCreated := lPurchaseHdr.INSERT(true);
                            lPurchaseHdr.VALIDATE("Buy-from Vendor No.", GVend."No.");
                            lPurchaseHdr.COPYLINKS(lPRHdr);

                            lPurchaseHdr.VALIDATE("Shortcut Dimension 1 Code", lPRHdr."Shortcut Dimension 1 Code");
                            lPurchaseHdr.VALIDATE("Shortcut Dimension 2 Code", lPRHdr."Shortcut Dimension 2 Code");
                            lPurchaseHdr."PR No." := lPRHdr."No.";
                            lPurchaseHdr."USERID PR to PO" := USERID;
                            lPurchaseHdr."Purchaser Code" := lPRHdr."Purchaser Code";
                            lPurchaseHdr."Your Reference" := lPRHdr.Requester;
                            if lPRHdr."Currency Code" <> '' then begin
                                lPurchaseHdr.VALIDATE("Currency Code", lPRHdr."Currency Code");
                            end;
                            lPurchaseHdr."Expected Receipt Date" := lPRHdr."Due Date";
                            lPurchaseHdr."Your Reference" := lPRHdr.Requester;
                            lPurchaseHdr.MODIFY;
                            lPRHdr."PR Status" := lPRHdr."PR Status"::Order;
                            lPRHdr.Status := lPRHdr.Status::Closed;
                            lPRHdr."LOA Status" := lPRHdr."LOA Status"::Closed;
                            lPRHdr.MODIFY;
                            repeat
                                lPurchaseLine.INIT;
                                lPurchaseLine."Document Type" := lPurchaseLine."Document Type"::Order;
                                lPurchaseLine.VALIDATE("Document No.", lPurchaseHdr."No.");
                                lPurchaseLine."Line No." := PRLine2."Line No.";
                                lPurchaseLine.INSERT;
                                if lPRLine.Type = lPRLine.Type::Item then
                                    lPurchaseLine.VALIDATE(Type, lPurchaseLine.Type::Item)
                                else
                                    if (lPRLine.Type = lPRLine.Type::"G/L Account") then
                                        lPurchaseLine.VALIDATE(Type, lPurchaseLine.Type::"G/L Account")
                                    else
                                        if (lPRLine.Type = lPRLine.Type::"Fixed Asset") then
                                            lPurchaseLine.VALIDATE(Type, lPurchaseLine.Type::"Fixed Asset")
                                        else
                                            // if (PRLine.Type = PRLine.Type::Description) then//19.0.0.5
                                            if (lPRLine.Type = lPRLine.Type::" ") then//19.0.0.5
                                                lPurchaseLine.VALIDATE(Type, lPurchaseLine.Type::" ");

                                lPurchaseLine.VALIDATE("No.", PRLine2."No.");
                                lPurchaseLine.VALIDATE("Location Code", PRLine2."Delivery Location");
                                lPurchaseLine.VALIDATE("Unit of Measure Code", PRLine2."Unit of  Measure");
                                lPurchaseLine.VALIDATE("Direct Unit Cost", PRLine2."Unit Cost");
                                lPurchaseLine.VALIDATE(Quantity, PRLine2.Quantity);
                                lPurchaseLine.Description := PRLine2.Description;
                                lPurchaseLine."Description 2" := PRLine2."Description 2";
                                lPurchaseLine."PR No." := PRLine2."Document No.";
                                lPurchaseLine."PR Line No." := PRLine2."Line No.";
                                if lPurchaseLine."G/L Account No." = '' then
                                    lPurchaseLine."G/L Account No." := PRLine2."G/L Account No.";
                                lPurchaseLine."WBS ID" := PRLine2."WBS ID";
                                lPurchaseLine."Activity ID" := PRLine2."Activity ID";
                                lPurchaseLine.Remarks := PRLine2.Remarks;
                                lPurchaseLine."Reason for Shortlist" := PRLine2."Reason for Shortlist";
                                //19.0.0.7>>
                                lPurchaseLine."Shortcut Dimension 1 Code" := PRLine2."Shortcut Dimension 1 Code";
                                lPurchaseLine."Shortcut Dimension 2 Code" := PRLine2."Shortcut Dimension 2 Code";
                                lPurchaseLine."Shortcut Dimension 3 Code" := PRLine2."Shortcut Dimension 3 Code";
                                lPurchaseLine."Shortcut Dimension 4 Code" := PRLine2."Shortcut Dimension 4 Code";
                                lPurchaseLine."Shortcut Dimension 5 Code" := PRLine2."Shortcut Dimension 5 Code";
                                lPurchaseLine."Shortcut Dimension 6 Code" := PRLine2."Shortcut Dimension 6 Code";
                                lPurchaseLine."Shortcut Dimension 7 Code" := PRLine2."Shortcut Dimension 7 Code";
                                lPurchaseLine."Shortcut Dimension 8 Code" := PRLine2."Shortcut Dimension 8 Code";
                                //19.0.0.7<<
                                lPurchaseLine.MODIFY;
                                PRLine2.Status := PRLine2.Status::Closed;
                                PRLine2."PR Status" := PRLine2."PR Status"::Order;
                                PRLine2.ConvertedtoOrder := true;
                                PRLine2."PO No." := lPurchaseHdr."No.";
                                PRLine2."Quantity Converted to PO" += PRLine2.Quantity;
                                PRLine2.MODIFY;
                            until PRLine2.NEXT = 0;
                            GQuotes := GQuotes + ' ' + lPurchaseLine."Document No.";
                        end;
                    end;
                    TempSuggestVend := lPRLine."Suggested Vendor";
                until lPRLine.NEXT = 0;
                if lPOCreated then begin
                    lPRHdr."PR Status" := lPRHdr."PR Status"::Order;
                    lPRHdr.Status := lPRHdr.Status::Closed;
                    lPRHdr."LOA Status" := lPRHdr."LOA Status"::Closed;
                    lPRHdr.MODIFY(true);
                end;
            end;
        end else begin
            lSuggestedVendor.RESET;
            lSuggestedVendor.SETRANGE("Document Type", lSuggestedVendor."Document Type"::"PR Header");
            lSuggestedVendor.SETRANGE("PR No.", lPRHdr."No.");
            lSuggestedVendor.SETFILTER("Suggested Vendor", '<>%1', '');
            if lSuggestedVendor.FINDSET then begin
                if lSuggestedVendor.COUNT > 1 then
                    ERROR(GText010);
                repeat
                    if GVend.GET(lSuggestedVendor."Suggested Vendor") then;
                    if not GVend."Prospect Vendor" then
                        MakeOrderForVendor(GVend, lPRHdr)
                    else
                        ERROR(lText001, GVend."No.")
                until lSuggestedVendor.NEXT = 0
            end else
                ERROR(GText003);
        end;
        MESSAGE(GText002, GQuotes);
    end;

    procedure ReleaseRFQDocument(var RFQHeader: Record "RFQ Comparison");
    var
        LSugVend: Record "Suggested Vendor";
        LPRLine: Record "PR Line";
        LApprovalTemp: Record "Approval Templates";
        LAmountLCY: Decimal;
        PurchasePaysetup: Record "Purchases & Payables Setup";
    begin
        //  CheckDim(RFQHeader);
        GLSetup.GET;
        //  if RFQHeader."PR Document Type" = RFQHeader."PR Document Type"::PC then begin
        if RFQHeader.Status = RFQHeader.Status::Closed then
            ERROR('Can not release already closed');
        //end;

        /*    PurchasePaysetup.GET;
           if PurchasePaysetup."Dimension for PR Approval" then begin
               if (RFQHeader."Shortcut Dimension 1 Code" = '') then
                   ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
               if (RFQHeader."Shortcut Dimension 2 Code" = '') then
                   ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");
           end;
    */
        Noseries.RESET;
        Noseries.SETRANGE(Code, RFQHeader."No. series");
        if Noseries.FINDFIRST then;

        RFQHeader.TESTFIELD(Requester);

        /*   LPRLine.RESET;
          LPRLine.SETRANGE("Document No.", RFQHeader."No.");
          if LPRLine.FINDSET then
              repeat
                  LPRLine.TESTFIELD("Shortcut Dimension 1 Code", RFQHeader."Shortcut Dimension 1 Code");
              until LPRLine.NEXT = 0;
          if ((not RFQHeader."Budgetary PR") and (Noseries."Enable Project Budget" or Noseries."Enable GL Budget")) then begin
              LPRLine.RESET;
              LPRLine.SETRANGE("Document No.", RFQHeader."No.");
              // LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::Description);//19.0.0.5
              LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::" ");//19.0.0.5
              if LPRLine.FINDSET then
                  repeat
                      CLEAR(LAmountLCY);
                      LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                      if PurchasePaysetup."Dimension for PR Approval" then//19.0.0.6
                          LPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                      if Noseries."Enable Project Budget" then begin
                          LPRLine.TESTFIELD("WBS ID");
                          LPRLine.TESTFIELD("Activity ID");
                      end;
                      if LAmountLCY > LPRLine."Available Budget" then begin
                          ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                      end;
                  until LPRLine.NEXT = 0;
          end; */
        RFQHeader.Status := RFQHeader.Status::Released;
        //  RFQHeader."Released By" := USERID;
        RFQHeader.MODIFY;
        PRLine.SETRANGE("Document No.", RFQHeader."No.");
        if PRLine.FINDSET then
            repeat
                PRLine.Status := PRLine.Status::Released;
                PRLine.MODIFY;
            until PRLine.NEXT = 0;
        MESSAGE(GText004, RFQHeader."No.");
    end;
    /* 
        procedure WFReleaseRFQDocument(var RFQHeader: Record "RFQ Comparison");
        var
            LSugVend: Record "Suggested Vendor";
            LPRLine: Record "PR Line";
            LApprovalTemp: Record "Approval Templates";
            LAmountLCY: Decimal;
            PurchasePaysetup: Record "Purchases & Payables Setup";
        begin
            if RFQHeader.Status = RFQHeader.Status::Released then begin
                if RFQHeader."PR Document Type" = RFQHeader."PR Document Type"::PC then
                    RFQHeader."LOA Status" := RFQHeader."LOA Status"::Closed
                else
                    RFQHeader."LOA Status" := RFQHeader."LOA Status"::Released;
                RFQHeader.MODIFY;

                ConvertToOrder(RFQHeader);
                MESSAGE(GText004, RFQHeader."No.");
            end else begin
                CheckDim(RFQHeader);
                GLSetup.GET;
                if RFQHeader."PR Document Type" = RFQHeader."PR Document Type"::PC then begin
                    if RFQHeader.Status = RFQHeader.Status::Closed then
                        ERROR('Can not release already closed');
                end;

                PurchasePaysetup.GET;

                if PurchasePaysetup."Dimension for PR Approval" then begin
                    if (RFQHeader."Shortcut Dimension 1 Code" = '') then
                        ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
                    if (RFQHeader."Shortcut Dimension 2 Code" = '') then
                        ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");
                end;

                Noseries.RESET;
                Noseries.SETRANGE(Code, RFQHeader."No. series");
                if Noseries.FINDFIRST then;

                RFQHeader.TESTFIELD(Requester);

                LPRLine.RESET;
                LPRLine.SETRANGE("Document No.", RFQHeader."No.");
                if LPRLine.FINDSET then
                    repeat
                        LPRLine.TESTFIELD("Shortcut Dimension 1 Code", RFQHeader."Shortcut Dimension 1 Code");
                    until LPRLine.NEXT = 0;
                if ((not RFQHeader."Budgetary PR") and (Noseries."Enable Project Budget" or Noseries."Enable GL Budget")) then begin
                    LPRLine.RESET;
                    LPRLine.SETRANGE("Document No.", RFQHeader."No.");
                    // LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::Description);//19.0.0.5
                    LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::" ");//19.0.0.5
                    if LPRLine.FINDSET then
                        repeat
                            CLEAR(LAmountLCY);
                            LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                            if PurchasePaysetup."Dimension for PR Approval" then//19.0.0.6
                                LPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                            if Noseries."Enable Project Budget" then begin
                                LPRLine.TESTFIELD("WBS ID");
                                LPRLine.TESTFIELD("Activity ID");
                            end;
                            if LAmountLCY > LPRLine."Available Budget" then begin
                                ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                            end;
                        until LPRLine.NEXT = 0;
                end;
                RFQHeader.Status := RFQHeader.Status::Released;
                RFQHeader."Released By" := USERID;
                RFQHeader.MODIFY;
                PRLine.SETRANGE("Document No.", RFQHeader."No.");
                if PRLine.FINDSET then
                    repeat
                        PRLine.Status := PRLine.Status::Released;
                        PRLine.MODIFY;
                    until PRLine.NEXT = 0;

                LApprovalTemp.RESET;
                LApprovalTemp.SETRANGE("Table ID", 27003012);
                LApprovalTemp.SETRANGE(Enabled, true);
                LApprovalTemp.SETRANGE("LOA Approval", false);
                if LApprovalTemp.FINDFIRST then
                    ERROR(GText009);

                MESSAGE(GText004, RFQHeader."No.");
            end;
        end; */

    procedure WFReleaseRFQCDocument(var RFQComparision: Record "RFQ Comparison");
    var
        LApprovalTemp: Record "Approval Templates";
        LPLine: Record "Purchase Line";
        LDocApprovalPurchReq: Codeunit "Document Approval PR-IBIZRFQ";
        LSugVend: Record "Suggested Vendor";
        LAmountLCY: Decimal;
        LPLine2: Record "Purchase Line";
        Lvendor: Record Vendor;
        ApprovalTemp: Record "Approval Templates";
        TotalAmt: Decimal;
        PurchasePaysetup: Record "Purchases & Payables Setup";
        AvailableBudget: Decimal;
        Utilised: Decimal;
        OnHold: Decimal;
        TotalBudgetAmount: Decimal;
        UsedBudgetAmount: Decimal;
        AccountingPeriod: Record "Accounting Period";
        GLAccount: Record "G/L Account";
        UPCPRTotal: Decimal;
        GLBudgetEntry: Record "G/L Budget Entry";
        ApprovalSetup: Record "Approval Setup";
        TotalBudget: Decimal;
    begin
        RFQComparision.TESTFIELD(Requester);

        LPLine.RESET;
        LPLine.SETRANGE("Document Type", LPLine."Document Type"::Quote);
        LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
        LPLine.SETFILTER(LPLine.Type, '<>%1', LPLine.Type::" ");
        LPLine.SETRANGE("Create PO", true);
        if not LPLine.FINDSET then
            ERROR('No line selected for Convert to PO');

        LPLine.SETRANGE("Create PO", true);
        LPLine.SETRANGE("Converted to PO", false);
        if LPLine.FINDSET then
            repeat
                if Lvendor.GET(LPLine."Buy-from Vendor No.") then begin
                    Lvendor.TESTFIELD("Prospect Vendor", false);
                    Lvendor.TESTFIELD(Blocked, Lvendor.Blocked::" ");
                end;
            until LPLine.NEXT = 0;

        RFQHeaderRec.RESET;
        RFQHeaderRec.SETRANGE("No.", RFQComparision."PR No");
        if RFQHeaderRec.FINDFIRST then begin
            Noseries.RESET;
            Noseries.SETRANGE(Code, RFQHeaderRec."No. series");
            if Noseries.FINDFIRST then;
            PurchasePaysetup.GET;
            GLSetup.GET;
            if ((not RFQHeaderRec."Budgetary PR") and Noseries."Enable Project Budget") then begin
                CLEAR(TotalBudget);
                LPLine.RESET;
                LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
                LPLine.SETFILTER(LPLine.Type, '<>%1', LPLine.Type::" ");
                LPLine.SETRANGE("Create PO", true);
                if LPLine.FINDSET then begin
                    repeat
                        if Lvendor.GET(LPLine."Buy-from Vendor No.") then begin
                            Lvendor.TESTFIELD("Prospect Vendor", false);
                            Lvendor.TESTFIELD(Blocked, Lvendor.Blocked::" ");
                        end;

                        CLEAR(GTotalInvoice);
                        CLEAR(GTotalCrLine);
                        CLEAR(GTotalPurchaseLines);
                        CLEAR(GTotalReturn);
                        CLEAR(GTotalPReq);

                        CalcInvoiceTotal(LPLine);
                        CalcCreditMemoTotal(LPLine);
                        CalcPurchaseOrder(LPLine);
                        CalcPurchaseReturnOrderTotal(LPLine);
                        CalcPurchaseReqTotal(LPLine);
                        CalcPurchaseOrderForUtilised(LPLine);
                        CalcPurchaseReqTotalForOnHold(LPLine);

                        GImportBudget.RESET;
                        GImportBudget.SETRANGE("Project ID", LPLine."Shortcut Dimension 2 Code");
                        GImportBudget.SETRANGE("WBS ID", LPLine."WBS ID");
                        GImportBudget.SETRANGE("Activity ID", LPLine."Activity ID");
                        if GImportBudget.FINDFIRST then begin
                            AvailableBudget := GImportBudget."Budgeted Total Cost" -
                             (GTotalInvoice + GTotalPurchaseLines + GTotalPReq - GTotalCrLine - GTotalReturn);
                            Utilised := (GTotalInvoice + GTotalPurchaseLinesUtilised - GTotalCrLine - GTotalReturn);
                            OnHold := GTotalBudgetOnHold;
                        end;

                        TotalBudget += AvailableBudget;

                        CLEAR(LAmountLCY);
                        LAmountLCY := LPLine.Quantity * LPLine."Unit Cost (LCY)";
                        if PurchasePaysetup."Dimension for PR Approval" then//19.0.0.6
                            LPLine.TESTFIELD("Shortcut Dimension 2 Code");
                        LPLine.TESTFIELD("WBS ID");
                        LPLine.TESTFIELD("Activity ID");
                        if LAmountLCY > AvailableBudget then begin
                            ApprovalsMgtNotification.SendRFQBudgetNotificationMail(RFQComparision, LPLine, TotalBudget);
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;

                        LPLine2.RESET;
                        LPLine2.SETRANGE("Document No.", LPLine."Document No.");
                        LPLine2.SETFILTER(LPLine2.Type, '<>%1', LPLine2.Type::" ");
                        LPLine2.SETRANGE("WBS ID", LPLine."WBS ID");
                        LPLine2.SETRANGE("Activity ID", LPLine."Activity ID");
                        LPLine2.SETFILTER("Line No.", '<>%1', LPLine."Line No.");
                        if LPLine2.FINDSET then
                            repeat
                                LAmountLCY += (LPLine2.Quantity * LPLine2."Unit Cost (LCY)");
                            until LPLine2.NEXT = 0;

                        if LAmountLCY > AvailableBudget then begin
                            if ApprovalSetup.GET and ApprovalSetup.Approvals then
                                ApprovalsMgtNotification.SendRFQBudgetNotificationMail(RFQComparision, LPLine, TotalBudget);
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;

                        LPLine.VALIDATE("Activity ID");
                        LPLine.MODIFY;
                    until LPLine.NEXT = 0;
                end else
                    ERROR('Create PO not Selected');
            end;
            if ((not RFQHeaderRec."Budgetary PR") and Noseries."Enable GL Budget") then begin
                PurchasePaysetup.TESTFIELD("PR Budget Name");
                PurchasePaysetup.TESTFIELD("Budget End Date");
                PurchasePaysetup.TESTFIELD("Budget Start Date");
                CLEAR(TotalBudget);
                LPLine.RESET;
                LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
                // LPLine.SETFILTER(LPLine.Type, '%1', LPLine.Type::"G/L Account");//19.0.0.5
                LPLine.SETRANGE("Create PO", true);
                if LPLine.FINDSET then begin
                    repeat
                        CLEAR(TotalBudgetAmount);
                        CLEAR(UsedBudgetAmount);
                        CLEAR(GTotalInvoice);
                        CLEAR(GTotalCrLine);
                        CLEAR(GTotalPurchaseLines);
                        CLEAR(GTotalReturn);
                        CLEAR(GTotalPReq);
                        CLEAR(GTotalBudgetOnHold);
                        EndDate := PurchasePaysetup."Budget End Date";
                        StartDate := PurchasePaysetup."Budget Start Date";
                        GLAccount.RESET;
                        GLAccount2.GET(LPLine."No.");
                        if GLAccount2."Budget Link A/C" <> '' then
                            GLAccount.SETFILTER("No.", '%1|%2', GLAccount2."No.", GLAccount2."Budget Link A/C")
                        else
                            GLAccount.SETRANGE("No.", LPLine."No.");
                        // GLAccount.SETRANGE("Global Dimension 1 Filter", LPLine."Shortcut Dimension 1 Code");//19.0.0.5
                        GLAccount.SETFILTER("Dimension set ID Filter", '%1', LPLine."Dimension Set ID");
                        GLAccount.SETRANGE("Date Filter", AccountingPeriod."Starting Date", EndDate);
                        if GLAccount.FINDSET then begin
                            repeat
                                GLAccount.CALCFIELDS("Balance at Date");
                                UsedBudgetAmount += GLAccount."Balance at Date";
                            until GLAccount.NEXT = 0;
                        end;
                        CLEAR(UPCPRTotal);
                        CLEAR(HoldUPCPRTotal);
                        GLBudgetEntry.RESET;
                        GLBudgetEntry.SETRANGE("Budget Name", PurchasePaysetup."PR Budget Name");
                        // GLBudgetEntry.SETRANGE("Global Dimension 1 Code", LPLine."Shortcut Dimension 1 Code");//19.0.0.5
                        GLBudgetEntry.SETRANGE("G/L Account No.", GLAccount."No.");
                        GLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                        GLBudgetEntry.SETFILTER("Dimension Set ID", '%1', LPLine."Dimension Set ID");
                        if GLBudgetEntry.FINDSET then
                            repeat
                                TotalBudgetAmount += GLBudgetEntry.Amount;
                            until GLBudgetEntry.NEXT = 0;

                        BCalcPurchaseOrder(LPLine);
                        //   BCalcPurchaseReqTotalForOnHold(LPLine);

                        Utilised := UsedBudgetAmount + UPCPRTotal + (GTotalInvoice - GTotalCrLine - GTotalReturn);
                        OnHold := GTotalBudgetOnHold + HoldUPCPRTotal;
                        if TotalBudgetAmount <> 0 then
                            AvailableBudget := TotalBudgetAmount - Utilised - OnHold
                        else
                            AvailableBudget := 0;
                        TotalBudget += AvailableBudget;

                        CLEAR(LAmountLCY);

                        LPLine2.RESET;
                        LPLine2.SETRANGE("Document No.", LPLine."Document No.");
                        LPLine2.SETRANGE(LPLine2.Type, LPLine2.Type::"G/L Account");
                        LPLine2.SETRANGE("No.", LPLine."No.");
                        if LPLine2.FINDSET then
                            repeat
                                LAmountLCY += (LPLine2.Quantity * LPLine2."Unit Cost (LCY)");
                            until LPLine2.NEXT = 0;

                        if LAmountLCY > AvailableBudget then begin
                            if ApprovalSetup.GET and ApprovalSetup.Approvals then
                                ApprovalsMgtNotification.SendRFQBudgetNotificationMail(RFQComparision, LPLine, TotalBudget);
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;
                    until LPLine.NEXT = 0;
                    RFQComparision."Total Budget" := TotalBudget;
                    RFQComparision.MODIFY;
                end else
                    ERROR('Create PO not Selected');
            end;
        end;
    end;

    procedure SendApprovalRequest(var RFQHeader: Record "RFQ Comparison");
    var
        LPRLine: Record "PR Line";
        LDocApprovalPurchReq: Codeunit "Document Approval PR-IBIZRFQ";
        LSugVend: Record "Suggested Vendor";
        Lamount: Decimal;
        LAmountLCY: Decimal;
        LPRLine2: Record "PR Line";
        ApprovalTemp: Record "Approval Templates";
        TotalAmt: Decimal;
        TotalBudget: Decimal;
        PurchasePaysetup: Record "Purchases & Payables Setup";
        ApprovalSetup: Record "Approval Setup";
        ItemNo: Code[20];
    begin
        RFQHeader.TESTFIELD(RFQHeader.Requester);
        Noseries.RESET;
        Noseries.SETRANGE(Code, RFQHeader."No. series");
        if Noseries.FINDFIRST then;
        PurchasePaysetup.GET;
        CLEAR(TotalBudget);
        GLSetup.GET;

        /*  if PurchasePaysetup."Dimension for PR Approval" then begin
             if (RFQHeader."Shortcut Dimension 1 Code" = '') then
                 ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");

             if (RFQHeader."Shortcut Dimension 2 Code" = '') then
                 ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
         end; */
        //if RFQHeader."PR Document Type" = RFQHeader."PR Document Type"::PC then begin
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", RFQHeader."No.");
        // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
        PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
        if PRLine.FINDSET then
            repeat
                PRLine.TESTFIELD("Unit Cost");
                TotalAmt += PRLine.Amount;
            until PRLine.NEXT = 0;

        ApprovalTemp.RESET;
        ApprovalTemp.SETRANGE("Document Type", ApprovalTemp."Document Type"::PR);
        ApprovalTemp.SETRANGE(ApprovalTemp."No. series", RFQHeader."No. series");
        if ApprovalTemp.FINDFIRST then begin
            if (ApprovalTemp."Petty Cash Limit" <> 0) and (TotalAmt > ApprovalTemp."Petty Cash Limit") then begin

                ERROR('The PR amount exceeded the limit, please raise normal PR');
            end;
        end;
        //end;
        /* GLSetup.GET;
        if ((not RFQHeader."Budgetary PR") and Noseries."Enable Project Budget") then begin
            if (RFQHeader."Shortcut Dimension 1 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
            if (RFQHeader."Shortcut Dimension 2 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");

            LPRLine.RESET;
            LPRLine.SETCURRENTKEY("No.");
            LPRLine.SETRANGE("Document No.", RFQHeader."No.");
            // LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::Description);//19.0.0.5
            LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::" ");//19.0.0.5
            if LPRLine.FINDSET then
                repeat
                    CLEAR(LAmountLCY);
                    LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                    Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                    if ItemNo <> LPRLine."No." then
                        TotalBudget += LPRLine."Available Budget";
                    if PurchasePaysetup."Dimension for PR Approval" then//19.0.0.6
                        LPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                    LPRLine.TESTFIELD("WBS ID");
                    LPRLine.TESTFIELD("Activity ID");

                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;

                    LPRLine2.RESET;
                    LPRLine2.SETRANGE("Document No.", LPRLine."Document No.");
                    // LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::Description);//19.0.0.5
                    LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::" ");//19.0.0.5
                    LPRLine2.SETRANGE("WBS ID", LPRLine."WBS ID");
                    LPRLine2.SETRANGE("Activity ID", LPRLine."Activity ID");
                    LPRLine2.SETFILTER("Line No.", '<>%1', LPRLine."Line No.");
                    if LPRLine2.FINDSET then
                        repeat
                            LAmountLCY += (LPRLine2.Quantity * LPRLine2."Unit Cost (LCY)");
                            Lamount += (LPRLine2.Quantity * LPRLine2."Unit Cost");
                        until LPRLine2.NEXT = 0;

                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;
                    LPRLine.VALIDATE("Activity ID");
                    LPRLine.MODIFY;
                    ItemNo := LPRLine."No.";
                until LPRLine.NEXT = 0;
        end;
        //GL Budget
        if ((not RFQHeader."Budgetary PR") and Noseries."Enable GL Budget") then begin
            if (RFQHeader."Shortcut Dimension 1 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
            if (RFQHeader."Shortcut Dimension 2 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");
            CLEAR(ItemNo);
            LPRLine.RESET;
            LPRLine.SETCURRENTKEY("No.");
            LPRLine.SETRANGE("Document No.", RFQHeader."No.");
            LPRLine.SETFILTER(LPRLine.Type, '%1', LPRLine.Type::"G/L Account");
            if LPRLine.FINDSET then
                repeat
                    CLEAR(LAmountLCY);
                    LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                    Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                    if ItemNo <> LPRLine."No." then
                        TotalBudget += LPRLine."Available Budget";
                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;
                    LPRLine2.RESET;
                    LPRLine2.SETRANGE("Document No.", LPRLine."Document No.");
                    LPRLine2.SETFILTER(LPRLine2.Type, '%1', LPRLine2.Type::"G/L Account");
                    LPRLine2.SETFILTER("Line No.", '<>%1', LPRLine."Line No.");
                    LPRLine2.SETRANGE("No.", LPRLine."No.");
                    LPRLine2.SETFILTER("Dimension Set ID", '%1', LPRLine."Dimension Set ID");
                    if LPRLine2.FINDSET then
                        repeat
                            LAmountLCY += (LPRLine2.Quantity * LPRLine2."Unit Cost (LCY)");
                            Lamount += (LPRLine2.Quantity * LPRLine2."Unit Cost");
                        until LPRLine2.NEXT = 0;

                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;
                    ItemNo := LPRLine."No.";
                until LPRLine.NEXT = 0;
        end;
 */
        LDocApprovalPurchReq.SendPurchaseReqApproval(RFQHeader, TotalBudget);

    end;

    procedure ReopenRFQDocument(var PRHdr: Record "PR Header");
    begin
        if (PRHdr.Status = PRHdr.Status::Closed) then
            ERROR('PR Status Close can not Re-open');

        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then
            repeat
                if PRLine."PO No." <> '' then
                    ERROR('PR Can not Reopen PO Created already');
            until PRLine.NEXT = 0;

        PRHdr.Status := PRHdr.Status::Open;
        PRHdr."LOA Status" := PRHdr."LOA Status"::Open;
        PRHdr.MODIFY;
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then
            repeat
                PRLine.Status := PRLine.Status::Open;
                PRLine.MODIFY;
            until PRLine.NEXT = 0;

        MESSAGE(GText005, PRHdr."No.");

    end;

    procedure ReopenRFQCDocument(var RFQCHeader: Record "RFQ Comparison");
    begin

        if (RFQCHeader.Status = RFQCHeader.Status::Closed) then
            ERROR('RFQC Status Close can not Re-open');

        //        if (RFQCHeader.Status = RFQCHeader.Status::"Pending Approval") then
        //          ERROR('RFQC Status pending for approval cannot be Re-opened');

        RFQCHeader.Status := RFQCHeader.Status::Open;
        RFQCHeader.MODIFY;

        MESSAGE(GText017, RFQCHeader."No.");
    end;

    procedure CancelPRDocument(var PRHdr: Record "PR Header");
    begin
        if (PRHdr.Status = PRHdr.Status::Closed) then
            ERROR('PR Status Close can not Cancel');

        if (PRHdr.Status = PRHdr.Status::"Pending Approval") then
            ERROR('PR Status pending for approval cannot be Cancel');
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then
            repeat
                if PRLine."PO No." <> '' then
                    ERROR('PR Can not Cancel PO Created already');
            until PRLine.NEXT = 0;

        PRHdr.Status := PRHdr.Status::Cancel;
        PRHdr.MODIFY;
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", PRHdr."No.");
        if PRLine.FINDSET then
            repeat
                PRLine.Status := PRLine.Status::Cancel;
                PRLine.MODIFY;
            until PRLine.NEXT = 0;
        MESSAGE(GText016, PRHdr."No.");
    end;

    procedure WFCancelRFQDocument(var RFQHdr: Record "RFQ Comparison");
    begin
        if (RFQHdr.Status = RFQHdr.Status::Closed) then
            ERROR('RFQ Status Close can not Cancel');

        if (RFQHdr.Status = RFQHdr.Status::"Pending Approval") then
            ERROR('RFQ Status pending for approval cannot be Cancel');

        RFQHdr.Status := RFQHdr.Status::Open;
        RFQHdr.MODIFY;

        MESSAGE(GText017, RFQHdr."No.");

    end;

    procedure WFCancelRFQCDocument(var RFQCHdr: Record "RFQ Comparison");
    begin
        if (RFQCHdr.Status = RFQCHdr.Status::Closed) then
            ERROR('RFQC Status Close can not Cancel');

        if (RFQCHdr.Status = RFQCHdr.Status::"Pending Approval") then
            ERROR('RFQC Status pending for approval cannot be Cancel');

        RFQCHdr.Status := RFQCHdr.Status::Open;
        RFQCHdr.MODIFY;

        MESSAGE(GText017, RFQCHdr."No.");
    end;

    procedure MakeQuoteForVendorLine(var Vend: Record Vendor; var LPRHdr: Record "PR Header"; var LPRLine: Record "PR Line");
    var
        LNoSeries: Record "No. Series";
        LNoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchaseHdr: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin

        Noseries.RESET;
        Noseries.SETRANGE(Code, LPRHdr."No. series");
        if Noseries.FINDFIRST then
            if Noseries."PR Quote" = '' then
                ERROR(GText012);

        PurchaseHdr.RESET;
        PurchaseHdr.INIT;
        PurchaseHdr."Document Type" := PurchaseHdr."Document Type"::Quote;
        PurchaseHdr."No." := LNoSeriesMgmt.GetNextNo(Noseries."PR Quote", LPRHdr."PR Date", true);
        PurchaseHdr.VALIDATE("Document Date", TODAY);

        PurchaseHdr.INSERT;

        PurchaseHdr.VALIDATE("Buy-from Vendor No.", Vend."No.");
        if VendorDesc <> '' then
            PurchaseHdr."Buy-from Vendor Name" := VendorDesc;

        PurchaseHdr.COPYLINKS(LPRHdr);

        PurchaseHdr.VALIDATE("Shortcut Dimension 1 Code", LPRHdr."Shortcut Dimension 1 Code");
        PurchaseHdr.VALIDATE("Shortcut Dimension 2 Code", LPRHdr."Shortcut Dimension 2 Code");
        PurchaseHdr.VALIDATE("Currency Code", LPRHdr."Currency Code");
        PurchaseHdr.VALIDATE("Currency Factor", LPRHdr."Currency Factor");
        PurchaseHdr."PR No." := LPRHdr."No.";
        PurchaseHdr."RFQ No" := PRCode;
        PurchaseHdr."USERID PR to PQ" := USERID;
        PurchaseHdr."Purchaser Code" := LPRHdr."Purchaser Code";
        PurchaseHdr."Budgetary PR" := LPRHdr."Budgetary PR";
        PurchaseHdr."Expected Receipt Date" := LPRHdr."Due Date";
        PurchaseHdr.MODIFY;

        PurchaseLine.INIT;
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::Quote;
        PurchaseLine.VALIDATE("Document No.", PurchaseHdr."No.");
        PurchaseLine."Line No." := LPRLine."Line No.";
        PurchaseLine.INSERT;
        if LPRLine.Type = LPRLine.Type::Item then
            PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item)
        else
            if (LPRLine.Type = LPRLine.Type::"G/L Account") then
                PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account")
            else
                if (LPRLine.Type = LPRLine.Type::"Fixed Asset") then
                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"Fixed Asset")
                else
                    // if (LPRLine.Type = LPRLine.Type::Description) then//19.0.0.5
                    if (LPRLine.Type = LPRLine.Type::" ") then//19.0.0.5
                        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::" ");

        PurchaseLine.VALIDATE("No.", LPRLine."No.");
        PurchaseLine.VALIDATE("Location Code", LPRLine."Delivery Location");
        PurchaseLine.VALIDATE("Unit of Measure Code", LPRLine."Unit of  Measure");
        PurchaseLine.VALIDATE(Quantity, LPRLine.Quantity);
        PurchaseLine.VALIDATE("Direct Unit Cost", 0);
        PurchaseLine.Description := LPRLine.Description;
        PurchaseLine."PR No." := LPRLine."Document No.";
        PurchaseLine."PR Line No." := LPRLine."Line No.";
        if PurchaseLine."G/L Account No." = '' then
            PurchaseLine."G/L Account No." := LPRLine."G/L Account No.";
        PurchaseLine."RFQ No." := PRCode;
        PurchaseLine."Requested Quantity" := LPRLine.Quantity;
        PurchaseLine."WBS ID" := LPRLine."WBS ID";
        PurchaseLine."Activity ID" := LPRLine."Activity ID";
        PurchaseLine.Remarks := LPRLine.Remarks;
        PurchaseLine."Reason for Shortlist" := LPRLine."Reason for Shortlist";
        PurchaseLine.MODIFY;
        LPRLine.Status := LPRLine.Status::Closed;
        LPRLine.ConvertedtoQuote := true;
        LPRLine.MODIFY;

        GQuotes := GQuotes + ' ' + PurchaseLine."Document No.";

    end;

    procedure MakeQuoteForVendor(var LVend: Record Vendor; var PR_Hdr: Record "PR Header");
    var
        PRLine1: Record "PR Line";
        LNoSeries: Record "No. Series";
        LNoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchaseHdr: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin

        Noseries.RESET;
        Noseries.SETRANGE(Code, PR_Hdr."No. series");
        if Noseries.FINDFIRST then
            if Noseries."PR Quote" = '' then
                ERROR(GText012);
        PRLine1.RESET;
        PRLine1.SETRANGE("Document No.", PR_Hdr."No.");
        PRLine1.SETRANGE(ConvertedtoQuote, false);
        // PRLine1.SETFILTER(PRLine1.Type, '<>%1', PRLine1.Type::Description);//19.0.0.5
        PRLine1.SETFILTER(PRLine1.Type, '<>%1', PRLine1.Type::" ");//19.0.0.5
        if PRLine1.FINDSET then begin
            PurchaseHdr.RESET;
            PurchaseHdr.INIT;
            PurchaseHdr."Document Type" := PurchaseHdr."Document Type"::Quote;
            PurchaseHdr."No." := LNoSeriesMgmt.GetNextNo(Noseries."PR Quote", PR_Hdr."PR Date", true);
            PurchaseHdr.VALIDATE("Document Date", TODAY);
            PurchaseHdr.INSERT;

            PurchaseHdr.VALIDATE("Buy-from Vendor No.", LVend."No.");
            if VendorDesc <> '' then
                PurchaseHdr."Buy-from Vendor Name" := VendorDesc;

            PurchaseHdr.COPYLINKS(PR_Hdr);

            PurchaseHdr.VALIDATE("Location Code", PR_Hdr."Delivery Location");
            PurchaseHdr.VALIDATE("Shortcut Dimension 1 Code", PR_Hdr."Shortcut Dimension 1 Code");
            PurchaseHdr.VALIDATE("Shortcut Dimension 2 Code", PR_Hdr."Shortcut Dimension 2 Code");
            PurchaseHdr.VALIDATE("Dimension Set ID", PR_Hdr."Dimension Set ID");//19.0.0.5
            PurchaseHdr.VALIDATE("Currency Code", PR_Hdr."Currency Code");
            PurchaseHdr.VALIDATE("Currency Factor", PR_Hdr."Currency Factor");

            PurchaseHdr."PR No." := PR_Hdr."No.";
            PurchaseHdr."RFQ No" := PRCode;
            PurchaseHdr."Purchaser Code" := PR_Hdr."Purchaser Code";
            PurchaseHdr."USERID PR to PQ" := USERID;
            PurchaseHdr."Budgetary PR" := PR_Hdr."Budgetary PR";
            PurchaseHdr."Expected Receipt Date" := PR_Hdr."Due Date";
            PurchaseHdr.MODIFY;
            repeat
                PurchaseLine.INIT;
                PurchaseLine."Document Type" := PurchaseLine."Document Type"::Quote;
                PurchaseLine.VALIDATE("Document No.", PurchaseHdr."No.");
                PurchaseLine."Line No." := PRLine1."Line No.";
                PurchaseLine.INSERT;
                if PRLine1.Type = PRLine1.Type::Item then
                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item)
                else
                    if (PRLine1.Type = PRLine1.Type::"G/L Account") then
                        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account")
                    else
                        if (PRLine1.Type = PRLine1.Type::"Fixed Asset") then
                            PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"Fixed Asset")
                        else
                            // if (PRLine1.Type = PRLine1.Type::Description) then//19.0.0.5
                            if (PRLine1.Type = PRLine1.Type::" ") then//19.0.0.5
                                PurchaseLine.VALIDATE(Type, PurchaseLine.Type::" ");

                PurchaseLine.VALIDATE("No.", PRLine1."No.");
                PurchaseLine."Shortcut Dimension 1 Code" := PRLine1."Shortcut Dimension 1 Code";
                PurchaseLine."Shortcut Dimension 2 Code" := PRLine1."Shortcut Dimension 2 Code";
                PurchaseLine."Dimension Set ID" := PRLine1."Dimension Set ID";//19.0.0.5
                //19.0.0.7>>
                PurchaseLine."Shortcut Dimension 3 Code" := PRLine1."Shortcut Dimension 3 Code";
                PurchaseLine."Shortcut Dimension 4 Code" := PRLine1."Shortcut Dimension 4 Code";
                PurchaseLine."Shortcut Dimension 5 Code" := PRLine1."Shortcut Dimension 5 Code";
                PurchaseLine."Shortcut Dimension 6 Code" := PRLine1."Shortcut Dimension 6 Code";
                PurchaseLine."Shortcut Dimension 7 Code" := PRLine1."Shortcut Dimension 7 Code";
                PurchaseLine."Shortcut Dimension 8 Code" := PRLine1."Shortcut Dimension 8 Code";
                //19.0.0.7<<
                PurchaseLine.VALIDATE("Location Code", PRLine1."Delivery Location");
                PurchaseLine.VALIDATE(Quantity, PRLine1.Quantity);
                PurchaseLine.VALIDATE("Direct Unit Cost", 0);
                PurchaseLine.VALIDATE("Unit of Measure Code", PRLine1."Unit of  Measure");
                PurchaseLine."PR No." := PRLine1."Document No.";
                PurchaseLine."PR Line No." := PRLine1."Line No.";
                if PurchaseLine."G/L Account No." = '' then
                    PurchaseLine."G/L Account No." := PRLine1."G/L Account No.";
                PurchaseLine.Description := PRLine1.Description;
                PurchaseLine."RFQ No." := PRCode;
                PurchaseLine."Requested Quantity" := PRLine1.Quantity;
                PurchaseLine."WBS ID" := PRLine1."WBS ID";
                PurchaseLine."Activity ID" := PRLine1."Activity ID";
                PurchaseLine.Remarks := PRLine1.Remarks;
                PurchaseLine.MODIFY;
                // PRLine1."PO No." := PurchaseHdr."No."; //19.0.0.3>>
                PRLine1.Status := PRLine1.Status::Closed;
                PRLine1.MODIFY;
            until PRLine1.NEXT = 0;
        end;
        GQuotes := GQuotes + ' ' + PurchaseLine."Document No.";
    end;

    procedure MakeOrderForVendorLine(var Vend: Record Vendor; var LPRHdr: Record "PR Header"; var LPRLine: Record "PR Line");
    var
        LNoSeries: Record "No. Series";
        LNoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchaseHdr: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin

        Noseries.RESET;
        Noseries.SETRANGE(Code, LPRHdr."No. series");
        if Noseries.FINDFIRST then
            if Noseries."PR Order" = '' then
                ERROR(GText013);

        PurchaseHdr.INIT;
        PurchaseHdr."Document Type" := PurchaseHdr."Document Type"::Order;
        PurchaseHdr."No." := LNoSeriesMgmt.GetNextNo(Noseries."PR Order", LPRHdr."PR Date", true);
        PurchaseHdr."No. Series" := Noseries."PR Order";
        PurchaseHdr.VALIDATE("Document Date", TODAY);
        PurchaseHdr.INSERT(true);

        PurchaseHdr.VALIDATE("Buy-from Vendor No.", Vend."No.");
        PurchaseHdr.COPYLINKS(LPRHdr);

        PurchaseHdr.VALIDATE("Shortcut Dimension 1 Code", LPRHdr."Shortcut Dimension 1 Code");
        PurchaseHdr.VALIDATE("Shortcut Dimension 2 Code", LPRHdr."Shortcut Dimension 2 Code");
        PurchaseHdr.VALIDATE("Dimension Set ID", LPRHdr."Dimension Set ID");//19.0.0.5
        PurchaseHdr."PR No." := LPRHdr."No.";
        PurchaseHdr."USERID PR to PO" := USERID;
        PurchaseHdr."Purchaser Code" := LPRHdr."Purchaser Code";
        PurchaseHdr."Your Reference" := LPRHdr.Requester;
        PurchaseHdr.VALIDATE("Currency Code", LPRHdr."Currency Code");
        PurchaseHdr.VALIDATE("Currency Factor", LPRHdr."Currency Factor");
        PurchaseHdr."Expected Receipt Date" := LPRHdr."Due Date";
        PurchaseHdr.MODIFY;

        PurchaseLine.INIT;
        PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
        PurchaseLine.VALIDATE("Document No.", PurchaseHdr."No.");
        PurchaseLine."Line No." := LPRLine."Line No.";
        PurchaseLine.INSERT;
        if LPRLine.Type = LPRLine.Type::Item then
            PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item)
        else
            if (LPRLine.Type = LPRLine.Type::"G/L Account") then
                PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account")
            else
                PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"Fixed Asset");

        PurchaseLine.VALIDATE("No.", LPRLine."No.");
        PurchaseLine.VALIDATE("Location Code", LPRLine."Delivery Location");
        PurchaseLine.VALIDATE("Unit of Measure", LPRLine."Unit of  Measure");
        PurchaseLine.VALIDATE("Direct Unit Cost", LPRLine."Unit Cost");
        PurchaseLine.VALIDATE(Quantity, LPRLine.Quantity);
        PurchaseLine.Description := LPRLine.Description;
        PurchaseLine."PR No." := LPRLine."Document No.";
        PurchaseLine."PR Line No." := LPRLine."Line No.";
        if PurchaseLine."G/L Account No." = '' then
            PurchaseLine."G/L Account No." := LPRLine."G/L Account No.";
        PurchaseLine."WBS ID" := LPRLine."WBS ID";
        PurchaseLine."Activity ID" := LPRLine."Activity ID";
        PurchaseLine.Remarks := LPRLine.Remarks;
        PurchaseLine."Reason for Shortlist" := LPRLine."Reason for Shortlist";
        PurchaseLine.MODIFY;
        LPRLine.Status := LPRLine.Status::Closed;
        LPRLine.ConvertedtoOrder := true;
        LPRLine."PO No." := PurchaseHdr."No.";
        LPRLine."Quantity Converted to PO" += LPRLine.Quantity;
        LPRLine.MODIFY;
        GQuotes := GQuotes + ' ' + PurchaseLine."Document No.";
    end;

    procedure MakeOrderForVendor(var LVend: Record Vendor; var PR_Hdr: Record "PR Header");
    var
        PRLine1: Record "PR Line";
        LNoSeries: Record "No. Series";
        LNoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchaseHdr: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        Noseries.RESET;
        Noseries.SETRANGE(Code, PR_Hdr."No. series");
        if Noseries.FINDFIRST then
            if Noseries."PR Order" = '' then
                ERROR(GText013);

        PRLine1.RESET;
        PRLine1.SETRANGE("Document No.", PR_Hdr."No.");
        PRLine1.SETRANGE(ConvertedtoQuote, false);
        if PRLine1.FINDSET then begin
            PurchaseHdr.INIT;
            PurchaseHdr."Document Type" := PurchaseHdr."Document Type"::Order;
            PurchaseHdr."No." := LNoSeriesMgmt.GetNextNo(Noseries."PR Order", PR_Hdr."PR Date", true);
            PurchaseHdr."No. Series" := Noseries."PR Order";
            PurchaseHdr.VALIDATE("Document Date", TODAY);
            PurchaseHdr."Your Reference" := PR_Hdr.Requester;
            PurchaseHdr.INSERT(true);
            PurchaseHdr.VALIDATE("Buy-from Vendor No.", LVend."No.");
            PurchaseHdr.COPYLINKS(PR_Hdr);
            PurchaseHdr.VALIDATE("Shortcut Dimension 1 Code", PR_Hdr."Shortcut Dimension 1 Code");
            PurchaseHdr.VALIDATE("Shortcut Dimension 2 Code", PR_Hdr."Shortcut Dimension 2 Code");
            PurchaseHdr.VALIDATE("Dimension Set ID", PR_Hdr."Dimension Set ID");//19.0.0.5
            PurchaseHdr.VALIDATE("Location Code", PR_Hdr."Delivery Location");
            PurchaseHdr.MODIFY;
            PurchaseHdr.VALIDATE("Currency Code", PR_Hdr."Currency Code");
            PurchaseHdr.VALIDATE("Currency Factor", PR_Hdr."Currency Factor");
            PurchaseHdr."PR No." := PR_Hdr."No.";
            PurchaseHdr."USERID PR to PO" := USERID;
            PurchaseHdr."Purchaser Code" := PR_Hdr."Purchaser Code";
            PurchaseHdr."Your Reference" := PR_Hdr.Requester;
            PurchaseHdr."Expected Receipt Date" := PR_Hdr."Due Date";
            PurchaseHdr.MODIFY;
            repeat
                PurchaseLine.INIT;
                PurchaseLine."Document Type" := PurchaseLine."Document Type"::Order;
                PurchaseLine.VALIDATE("Document No.", PurchaseHdr."No.");
                PurchaseLine."Line No." := PRLine1."Line No.";
                PurchaseLine.INSERT;
                if PRLine1.Type = PRLine1.Type::Item then
                    PurchaseLine.VALIDATE(Type, PurchaseLine.Type::Item)
                else
                    if (PRLine1.Type = PRLine1.Type::"G/L Account") then
                        PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"G/L Account")
                    else
                        if (PRLine1.Type = PRLine1.Type::"Fixed Asset") then
                            PurchaseLine.VALIDATE(Type, PurchaseLine.Type::"Fixed Asset")
                        else
                            // if (PRLine1.Type = PRLine1.Type::Description) then//19.0.0.5
                            if (PRLine1.Type = PRLine1.Type::" ") then//19.0.0.5
                                PurchaseLine.VALIDATE(Type, PurchaseLine.Type::" ");
                PurchaseLine.Description := PRLine1.Description;
                // if (PRLine1.Type <> PRLine1.Type::Description) then begin//19.0.0.5
                if (PRLine1.Type <> PRLine1.Type::" ") then begin//19.0.0.5
                    PurchaseLine.VALIDATE("No.", PRLine1."No.");
                    PurchaseLine."Shortcut Dimension 1 Code" := PRLine1."Shortcut Dimension 1 Code";
                    PurchaseLine."Shortcut Dimension 2 Code" := PRLine1."Shortcut Dimension 2 Code";
                    PurchaseLine."Dimension Set ID" := PRLine1."Dimension Set ID";//19.0.0.5
                    //19.0.0.7>>
                    PurchaseLine."Shortcut Dimension 3 Code" := PRLine1."Shortcut Dimension 3 Code";
                    PurchaseLine."Shortcut Dimension 4 Code" := PRLine1."Shortcut Dimension 4 Code";
                    PurchaseLine."Shortcut Dimension 5 Code" := PRLine1."Shortcut Dimension 5 Code";
                    PurchaseLine."Shortcut Dimension 6 Code" := PRLine1."Shortcut Dimension 6 Code";
                    PurchaseLine."Shortcut Dimension 7 Code" := PRLine1."Shortcut Dimension 7 Code";
                    PurchaseLine."Shortcut Dimension 8 Code" := PRLine1."Shortcut Dimension 8 Code";
                    //19.0.0.7<<
                    PurchaseLine.VALIDATE("Location Code", PRLine1."Delivery Location");
                    PurchaseLine.VALIDATE("Unit of Measure", PRLine1."Unit of  Measure");
                    if PRLine1."Unit Cost" <> 0 then
                        PurchaseLine.VALIDATE("Direct Unit Cost", PRLine1."Unit Cost");
                    PurchaseLine.VALIDATE(Quantity, PRLine1.Quantity);
                    PurchaseLine.Description := PRLine1.Description;
                    PurchaseLine."Description 2" := PRLine1."Description 2";
                    PurchaseLine."PR No." := PRLine1."Document No.";
                    PurchaseLine."PR Line No." := PRLine1."Line No.";
                    if PurchaseLine."G/L Account No." = '' then
                        PurchaseLine."G/L Account No." := PRLine1."G/L Account No.";
                    PurchaseLine."WBS ID" := PRLine1."WBS ID";
                    PurchaseLine."Activity ID" := PRLine1."Activity ID";
                    PurchaseLine.Remarks := PRLine1.Remarks;
                    PurchaseLine."Reason for Shortlist" := PRLine1."Reason for Shortlist";
                end;
                PurchaseLine.MODIFY;
                PRLine1."PO No." := PurchaseHdr."No.";
                PRLine1.Status := PRLine1.Status::Closed;
                PRLine1.ConvertedtoOrder := true;
                PRLine1."Quantity Converted to PO" += PRLine1.Quantity;
                PRLine1.MODIFY;
            until PRLine1.NEXT = 0;
            PR_Hdr."PR Status" := PR_Hdr."PR Status"::Order;
            PR_Hdr.Status := PR_Hdr.Status::Closed;
            PR_Hdr.MODIFY;
        end;
        GQuotes := GQuotes + ' ' + PurchaseLine."Document No.";
    end;
    //Version 19.0.0.0>>
    procedure CheckProspectVendorInPurchaseLine(RFQNo: Code[20]): Boolean
    var
        lCheckProspectVendorPurchaseLine: Record "Purchase Line";
        Lvendor: Record Vendor;
        lChangeVendor: report "Change Vendor";
        Question: Label 'Selected vendor: %1 is a Prospect Vendor, you can not create order for Prospect Vendor, do you want to select another vendor to continue.';
    begin
        lCheckProspectVendorPurchaseLine.RESET();
        lCheckProspectVendorPurchaseLine.SETRANGE("Document Type", lCheckProspectVendorPurchaseLine."Document Type"::Quote);
        lCheckProspectVendorPurchaseLine.SETRANGE("RFQ No.", RFQNo);
        lCheckProspectVendorPurchaseLine.SETRANGE("Create PO", true);
        lCheckProspectVendorPurchaseLine.SETRANGE("Converted to PO", false);
        if lCheckProspectVendorPurchaseLine.FINDSET then
            repeat
                if Lvendor.GET(lCheckProspectVendorPurchaseLine."Buy-from Vendor No.") then
                    if Lvendor."Prospect Vendor" = true then
                        if Dialog.Confirm(Question, true, Lvendor."No.") then begin
                            lChangeVendor.SetPrQuoteNo(lCheckProspectVendorPurchaseLine."Document No.");
                            lChangeVendor.RunModal();
                        end;
            until lCheckProspectVendorPurchaseLine.Next() = 0;
    end;
    //Version 19.0.0.0<<
    procedure MakeOrder(var RFQNo: Record "RFQ Comparison");
    var
        LRFQ: Record "RFQ Comparison";
        LPurchaseLine: Record "Purchase Line";
        LPurchaseHdr: Record "Purchase Header";
        LPL: Record "Purchase Line";
        LPhdr: Record "Purchase Header";
        LPL1: Record "Purchase Line";
        Converted: Boolean;
        LPurchaseReqLine: Record "PR Line";
        LPurchaseLine2: Record "Purchase Line";
        LExistingQty: Decimal;
        LText001: Label 'Quantity for the item %1 has exceeded the PR Quantity';
        Lvendor: Record Vendor;
        ExistingOrder: Record "Purchase Header";
        UpdateQtyinPR: Record "PR Line";
        Vend: Record Vendor;
        DocDim: Codeunit DimensionManagement;
        LPurchaseReqLine9: Record "PR Line";
        LText002: Label 'Amout greater than the available budget for Document %1 :%2';
        LRFQHeaderForNoSeries: Record "PR Header";
        LNoSeries: Record "No. Series";
        LNoseriesMgmt: Codeunit NoSeriesManagement;
        LNoseriesBudget: Record "No. Series";
        LPurchReqBud: Record "PR Header";
        lCheckProspectVendorPurchaseLine: Record "Purchase Line";
    begin
        RFQNo.TESTFIELD("RFQ Status", RFQNo."RFQ Status"::Open);

        //Version 19.0.0.0>>
        CheckProspectVendorInPurchaseLine(RFQNo."No.");
        //Version 19.0.0.0<<

        CLEAR(Converted);
        LPurchaseLine.RESET;
        LPurchaseLine.SETRANGE("Document Type", LPurchaseLine."Document Type"::Quote);
        LPurchaseLine.SETRANGE("RFQ No.", RFQNo."No.");
        LPurchaseLine.SETRANGE("Create PO", true);
        LPurchaseLine.SETRANGE("Converted to PO", false);
        if LPurchaseLine.FINDSET then
            repeat
                if Lvendor.GET(LPurchaseLine."Buy-from Vendor No.") then begin
                    Lvendor.TESTFIELD("Prospect Vendor", false);
                    Lvendor.TESTFIELD(Blocked, Lvendor.Blocked::" ");
                end;
                LPurchReqBud.RESET;
                LPurchReqBud.SETRANGE("No.", LPurchaseLine."PR No.");
                if LPurchReqBud.FINDFIRST then begin
                    LNoseriesBudget.RESET;
                    LNoseriesBudget.SETRANGE(Code, LPurchReqBud."No. series");
                    if LNoseriesBudget.FINDFIRST then begin
                        if LNoseriesBudget."Enable Project Budget" then begin
                            LPurchaseReqLine9.RESET;
                            LPurchaseReqLine9.SETRANGE("Document No.", LPurchaseLine."PR No.");
                            LPurchaseReqLine9.SETRANGE("Line No.", LPurchaseLine."PR Line No.");
                            if LPurchaseReqLine9.FINDFIRST then
                                if LPurchaseReqLine9."Available Budget" < LPurchaseLine."Line Amount" then
                                    ERROR(LText002, LPurchaseLine."Document No.", LPurchaseLine."Line No.");
                        end;
                    end;
                end;
                CheckforQuantity(LPurchaseLine);
                LPurchaseHdr.RESET;
                LPurchaseHdr.SETRANGE("Document Type", LPurchaseHdr."Document Type"::Quote);
                LPurchaseHdr.SETRANGE("No.", LPurchaseLine."Document No.");
                if LPurchaseHdr.FINDFIRST then begin
                    LPurchaseHdr.TESTFIELD("Budgetary PR", false);
                    LPL.RESET;
                    LPL.SETRANGE("Document Type", LPurchaseLine."Document Type"::Quote);
                    LPL.SETRANGE("Document No.", LPurchaseHdr."No.");
                    LPL.SETRANGE("Create PO", true);
                    LPL.SETRANGE("Converted to PO", false);
                    if LPL.FINDSET then begin
                        Converted := true;
                        ExistingOrder.RESET;
                        ExistingOrder.SETRANGE("Document Type", ExistingOrder."Document Type"::Order);
                        ExistingOrder.SETRANGE("Quote No.", LPL."Document No.");
                        if ExistingOrder.FINDFIRST then begin
                            GQuotes := GQuotes + ' ' + ExistingOrder."No.";
                            repeat
                                LPL1.INIT;
                                LPL1 := LPL;
                                LPL1."Document Type" := ExistingOrder."Document Type";
                                LPL1."Document No." := ExistingOrder."No.";
                                LPL1."PR No." := ExistingOrder."PR No.";
                                LPL1."PR Line No." := LPL."PR Line No.";
                                if LPL1."G/L Account No." = '' then
                                    LPL1."G/L Account No." := LPL."G/L Account No.";
                                LPL1."PQ No" := LPL."Document No.";
                                LPL1."Line No." := LPL."Line No.";
                                LPL1."WBS ID" := LPL."WBS ID";
                                LPL1."Activity ID" := LPL."Activity ID";
                                LPL1."Reason for Shortlist" := LPL."Reason for Shortlist";
                                LPL1.INSERT;

                                UpdateQtyinPR.RESET;
                                UpdateQtyinPR.SETRANGE("Document No.", ExistingOrder."PR No.");
                                UpdateQtyinPR.SETRANGE("Line No.", LPL."PR Line No.");
                                if UpdateQtyinPR.FINDFIRST then begin
                                    UpdateQtyinPR."Quantity Converted to PO" += LPL1.Quantity;
                                    UpdateQtyinPR.ConvertedtoOrder := true;
                                    UpdateQtyinPR."PO No." := LPL1."Document No.";
                                    UpdateQtyinPR.MODIFY;
                                end;
                                LPL."Converted to PO" := true;
                                LPL."PO No" := LPL1."Document No.";
                                LPL."PO Line No." := LPL1."Line No.";
                                LPL.MODIFY;
                            until LPL.NEXT = 0;
                        end else begin
                            LPhdr.INIT;
                            LPhdr := LPurchaseHdr;
                            LPhdr."Document Type" := LPhdr."Document Type"::Order;
                            LPhdr."No. Printed" := 0;
                            LRFQHeaderForNoSeries.RESET;
                            LRFQHeaderForNoSeries.SETRANGE("No.", LPurchaseLine."PR No.");
                            if LRFQHeaderForNoSeries.FINDFIRST then begin
                                LNoSeries.RESET;
                                LNoSeries.SETRANGE(Code, LRFQHeaderForNoSeries."No. series");
                                if LNoSeries.FINDFIRST then
                                    if LNoSeries."PR Order" <> '' then begin
                                        LPhdr."No." := LNoseriesMgmt.GetNextNo(LNoSeries."PR Order", TODAY, true);
                                        LPhdr."No. Series" := LNoSeries."PR Order";
                                    end;
                            end;
                            LPhdr.Status := LPhdr.Status::Open;
                            LPhdr."Quote No." := LPurchaseHdr."No.";
                            LPhdr."PR No." := LPurchaseHdr."PR No.";
                            LPL1.LOCKTABLE;
                            LPhdr."Purchaser Code" := LPurchaseHdr."Purchaser Code";//19.0.0.6
                            LPhdr.INSERT(true);
                            LPhdr.COPYLINKS(LPurchaseHdr);

                            LPurchaseHdr."Converted To PO" := true;
                            LPurchaseHdr."USERID PQ to PO" := USERID;
                            LPurchaseHdr."Expected Receipt Date" := LPhdr."Due Date";
                            LPurchaseHdr.MODIFY;
                            GQuotes := GQuotes + ' ' + LPhdr."No.";
                            repeat
                                LPL1.INIT;
                                LPL1 := LPL;
                                LPL1."Document Type" := LPhdr."Document Type";
                                LPL1."Document No." := LPhdr."No.";
                                LPL1."PR No." := LPhdr."PR No.";
                                LPL1."PR Line No." := LPL."PR Line No.";
                                if LPL1."G/L Account No." = '' then
                                    LPL1."G/L Account No." := LPL."G/L Account No.";
                                LPL1."PQ No" := LPL."Document No.";
                                LPL1."Line No." := LPL."Line No.";
                                LPL1."WBS ID" := LPL."WBS ID";
                                LPL1."Activity ID" := LPL."Activity ID";
                                LPL1."Reason for Shortlist" := LPL."Reason for Shortlist";
                                LPL1.INSERT;

                                UpdateQtyinPR.RESET;
                                UpdateQtyinPR.SETRANGE("Document No.", LPhdr."PR No.");
                                UpdateQtyinPR.SETRANGE("Line No.", LPL."PR Line No.");
                                if UpdateQtyinPR.FINDFIRST then begin
                                    UpdateQtyinPR."Quantity Converted to PO" += LPL1.Quantity;
                                    UpdateQtyinPR.ConvertedtoOrder := true;
                                    UpdateQtyinPR."PO No." := LPL1."Document No.";
                                    UpdateQtyinPR.MODIFY;
                                end;
                                LPL."Converted to PO" := true;
                                LPL."PO No" := LPL1."Document No.";
                                LPL."PO Line No." := LPL1."Line No.";
                                LPL.MODIFY;
                            until LPL.NEXT = 0;
                        end;
                    end;
                end;
            until LPurchaseLine.NEXT = 0;
        if VerifyIfAllQtyConvertedToPO(RFQNo) then begin
            RFQNo."RFQ Status" := RFQNo."RFQ Status"::Closed;
            RFQNo.MODIFY;
            LPurchReqBud.RESET;
            LPurchReqBud.SETRANGE("No.", LPurchaseLine."PR No.");
            if LPurchReqBud.FINDFIRST then begin
                LPurchReqBud."LOA Status" := LPurchReqBud."LOA Status"::Released;
                LPurchReqBud.Modify();
            end;
        end;
        if Converted then
            MESSAGE(GText002, GQuotes)
        else
            MESSAGE(GText006);
    end;

    procedure PurchaserAllowConvertoPO(): Boolean;
    var
        LUsersetup: Record "User Setup";
    begin
        if not LUsersetup.GET(USERID) then
            ERROR(GText007);

        if LUsersetup.Purchaser then
            exit(true)
        else
            exit(false)
    end;

    procedure CheckforQuantity(var PurchLine: Record "Purchase Line");
    var
        LExistingQty: Decimal;
        LPurchaseReqLine: Record "PR Line";
        LPurchaseLine2: Record "Purchase Line";
        LTotal: Decimal;
        LText001: Label 'Quantity for the item %1 has exceeded the PR Quantity';
    begin
        CLEAR(LExistingQty);
        CLEAR(LTotal);
        LPurchaseReqLine.RESET;
        LPurchaseReqLine.SETRANGE("Document No.", PurchLine."PR No.");
        LPurchaseReqLine.SETRANGE("Line No.", PurchLine."PR Line No.");
        if LPurchaseReqLine.FINDFIRST then;
        LPurchaseLine2.RESET;
        LPurchaseLine2.SETRANGE("Document Type", LPurchaseLine2."Document Type"::Order);
        LPurchaseLine2.SETRANGE("PR No.", PurchLine."PR No.");
        LPurchaseLine2.SETRANGE("PR Line No.", PurchLine."PR Line No.");
        if LPurchaseLine2.FINDSET then
            repeat
                LExistingQty += LPurchaseLine2.Quantity
            until LPurchaseLine2.NEXT = 0;
        LTotal := PurchLine.Quantity + LExistingQty;
        if (PurchLine.Quantity + LExistingQty) > LPurchaseReqLine.Quantity then
            ERROR(LText001, PurchLine."No.");
    end;

    procedure VerifyIfAllQtyConvertedToPO(var RFQForPR: Record "RFQ Comparison"): Boolean;
    var
        LPurchaseReq: Record "PR Header";
        LPurchaseReqLine: Record "PR Line";
    begin

        LPurchaseReq.RESET;
        LPurchaseReq.SETRANGE("No.", RFQForPR."PR No");
        if LPurchaseReq.FINDFIRST then begin
            LPurchaseReqLine.RESET;
            LPurchaseReqLine.SETRANGE("Document No.", LPurchaseReq."No.");
            if LPurchaseReqLine.FINDSET then
                repeat
                    if (LPurchaseReqLine.Quantity <> LPurchaseReqLine."Quantity Converted to PO") then
                        exit(false)
                until LPurchaseReqLine.NEXT = 0;
            exit(true);
        end;
    end;

    procedure ReleaseRFQDocAfterApprove(RFQHeader: Record "RFQ Comparison");
    var
        LSugVend: Record "Suggested Vendor";
        LPRLine: Record "PR Line";
    begin
        //  if RFQHeader."PR Document Type" = RFQHeader."PR Document Type"::PC then begin
        //    RFQHeader.Status := RFQHeader.Status::Closed;
        //  RFQHeader."PR Status" := RFQHeader."PR Status"::Closed;
        //end else begin
        RFQHeader.Status := RFQHeader.Status::Released;
        //end;
        //  RFQHeader."Released By" := USERID;
        RFQHeader.MODIFY;


        MESSAGE(GText004, RFQHeader."No.");
    end;


    procedure ArchivePR(PRNoRecPAR: Record "PR Header");
    var
        RFQHeaderLoc: Record "PR Header";
        PRLineLoc: Record "PR Line";
        PRArchHeaderLoc: Record "PR Arch. Header";
        PRArchHeaderLoc2: Record "PR Arch. Header";
        PRArchLineLoc: Record "PR Arch. Line";
        SuggestedVendorLoc: Record "Suggested Vendor";
        PRArchSuggestedVendorLoc: Record "PR Arch. Suggested Vendor";
        WindowLoc: Dialog;
        PPSetup: Record "Purchases & Payables Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        //19.0.0.1>>
        ArchiveManagement: codeunit ArchiveManagement;
        lPurchaseHeader: Record "Purchase Header";
    //19.0.0.1<<
    begin
        if CONFIRM(Text007, true, PRNoRecPAR."No.") then begin
            WindowLoc.OPEN('Copying...#1#################');
            PRArchHeaderLoc.INIT;
            PRArchHeaderLoc."No." := PRNoRecPAR."No.";
            PRArchHeaderLoc2.RESET;
            PRArchHeaderLoc2.SETRANGE(PRArchHeaderLoc2."No.", PRNoRecPAR."No.");
            if PRArchHeaderLoc2.FINDLAST then
                PRArchHeaderLoc."Version No." := PRArchHeaderLoc2."Version No." + 1
            else
                PRArchHeaderLoc."Version No." := 1;
            PRArchHeaderLoc.Description := PRNoRecPAR.Description;
            PRArchHeaderLoc."PR Date" := PRNoRecPAR."PR Date";
            PRArchHeaderLoc."Due Date" := PRNoRecPAR."Due Date";
            PRArchHeaderLoc."Delivery Location" := PRNoRecPAR."Delivery Location";
            PRArchHeaderLoc."No. series" := PRNoRecPAR."No. series";
            PRArchHeaderLoc.Requester := PRNoRecPAR.Requester;
            PRArchHeaderLoc."Document Type" := PRNoRecPAR."PR Document Type";
            PRArchHeaderLoc."PR Status" := PRNoRecPAR."PR Status";
            PRArchHeaderLoc."USER ID" := PRNoRecPAR."Co-ordinator";
            PRArchHeaderLoc.Status := PRNoRecPAR.Status;
            PRArchHeaderLoc."Last Modified Date" := PRNoRecPAR."Last Modified Date";
            PRArchHeaderLoc."Suggested Supplier" := PRNoRecPAR."Suggested Vendor";
            PRArchHeaderLoc."Shortcut Dimension 1 Code" := PRNoRecPAR."Shortcut Dimension 1 Code";
            PRArchHeaderLoc."Shortcut Dimension 2 Code" := PRNoRecPAR."Shortcut Dimension 2 Code";
            PRArchHeaderLoc."Dimension Set ID" := PRNoRecPAR."Dimension Set ID";//19.0.0.5
            PRArchHeaderLoc.PONoseries := PRNoRecPAR.PONoseries;
            PRArchHeaderLoc."PR Type" := PRNoRecPAR."PR Type";
            PRArchHeaderLoc."WBS ID" := PRNoRecPAR."WBS ID";
            PRArchHeaderLoc."Budgetary PR" := PRNoRecPAR."Budgetary PR";
            PRArchHeaderLoc."Date Created" := PRNoRecPAR."Date Created";
            PRArchHeaderLoc."Currency Code" := PRNoRecPAR."Currency Code";
            PRArchHeaderLoc."Currency Factor" := PRNoRecPAR."Currency Factor";
            PRArchHeaderLoc."Purchaser Code" := PRNoRecPAR."Purchaser Code";
            PRArchHeaderLoc."PR No." := PRNoRecPAR."No.";
            PRArchHeaderLoc."Archive Date Time" := CURRENTDATETIME;
            PRArchHeaderLoc."Archive UserID" := USERID;
            PRArchHeaderLoc.INSERT(true);
            if PRArchHeaderLoc."No." <> '' then begin
                PRLineLoc.RESET;
                PRLineLoc.SETRANGE(PRLineLoc."Document No.", PRNoRecPAR."No.");
                if PRLineLoc.FINDFIRST then
                    repeat
                        WindowLoc.UPDATE(1, PRLineLoc."No.");
                        PRArchLineLoc.INIT;
                        PRArchLineLoc."Document No." := PRArchHeaderLoc."No.";
                        PRArchLineLoc."Version No." := PRArchHeaderLoc."Version No.";
                        PRArchLineLoc."Line No." := PRLineLoc."Line No.";
                        PRArchLineLoc.Type := PRLineLoc.Type;
                        PRArchLineLoc."No." := PRLineLoc."No.";
                        PRArchLineLoc.Description := PRLineLoc.Description;
                        PRArchLineLoc.Quantity := PRLineLoc.Quantity;
                        PRArchLineLoc."Unit of  Measure" := PRLineLoc."Unit of  Measure";
                        PRArchLineLoc."Due Date" := PRLineLoc."Due Date";
                        PRArchLineLoc."Delivery Location" := PRLineLoc."Delivery Location";
                        PRArchLineLoc."PR Status" := PRLineLoc."PR Status";
                        PRArchLineLoc."Document Type" := PRLineLoc."PR Document Type";
                        PRArchLineLoc."Unit Cost" := PRLineLoc."Unit Cost";
                        PRArchLineLoc.Amount := PRLineLoc.Amount;
                        PRArchLineLoc.Status := PRLineLoc.Status;
                        PRArchLineLoc."Description 2" := PRLineLoc."Description 2";
                        PRArchLineLoc.Remarks := PRLineLoc.Remarks;
                        PRArchLineLoc."Suggested Supplier" := PRLineLoc."Suggested Supplier";
                        PRArchLineLoc."Shortcut dimension 1 code" := PRLineLoc."Shortcut Dimension 1 Code";
                        PRArchLineLoc."Shortcut dimension 2 code" := PRLineLoc."Shortcut Dimension 2 Code";
                        PRArchLineLoc."Dimension Set ID" := PRLineLoc."Dimension Set ID";//19.0.0.5
                        PRArchLineLoc."Expected Receipt Date" := PRLineLoc."Expected Receipt Date";
                        PRArchLineLoc."Qty Received" := PRLineLoc."Qty Received";
                        PRArchLineLoc.Select := PRLineLoc.Select;
                        PRArchLineLoc.ConvertedtoQuote := PRLineLoc.ConvertedtoQuote;
                        PRArchLineLoc."Quantity Converted to PO" := PRLineLoc."Quantity Converted to PO";
                        PRArchLineLoc."WBS ID" := PRLineLoc."WBS ID";
                        PRArchLineLoc."Activity ID" := PRLineLoc."Activity ID";
                        PRArchLineLoc."Available Budget" := PRLineLoc."Available Budget";
                        PRArchLineLoc.ConvertedtoOrder := PRLineLoc.ConvertedtoOrder;
                        PRArchLineLoc."Reason for Shortlist" := PRLineLoc."Reason for Shortlist";
                        PRArchLineLoc."On Hold" := PRLineLoc."On Hold";
                        PRArchLineLoc.Utilised := PRLineLoc.Utilised;
                        PRArchLineLoc."Unit Cost (LCY)" := PRLineLoc."Unit Cost (LCY)";
                        PRArchLineLoc."Amount (LCY)" := PRLineLoc."Amount (LCY)";
                        PRArchLineLoc."Available Quantity" := PRLineLoc."Available Quantity";
                        PRArchLineLoc."RFQ No." := PRLineLoc."No. of RFQ";
                        PRArchLineLoc."PO No." := PRLineLoc."No. of PO";
                        PRArchLineLoc."PR No" := PRNoRecPAR."No.";
                        if PRArchLineLoc."G/L Account No." = '' then
                            PRArchLineLoc."G/L Account No." := PRLineLoc."G/L Account No.";
                        PRArchLineLoc."Archive Date Time" := CURRENTDATETIME;
                        PRArchLineLoc."Archive UserID" := USERID;
                        PRArchLineLoc.INSERT;
                    until PRLineLoc.NEXT = 0;
                SuggestedVendorLoc.RESET;
                SuggestedVendorLoc.SETRANGE("Document Type", SuggestedVendorLoc."Document Type"::"PR Header");
                SuggestedVendorLoc.SETRANGE("PR No.", PRNoRecPAR."No.");
                if SuggestedVendorLoc.FINDFIRST then
                    repeat
                        PRArchSuggestedVendorLoc.INIT;
                        PRArchSuggestedVendorLoc."Document Type" := SuggestedVendorLoc."Document Type";
                        PRArchSuggestedVendorLoc."PR Arch. No." := PRArchHeaderLoc."No.";
                        PRArchSuggestedVendorLoc."Version No." := PRArchHeaderLoc."Version No.";
                        PRArchSuggestedVendorLoc."Suggested Vendor" := SuggestedVendorLoc."Suggested Vendor";
                        PRArchSuggestedVendorLoc."Line no." := SuggestedVendorLoc."Line no.";
                        PRArchSuggestedVendorLoc."Vendor Name" := SuggestedVendorLoc."Vendor Name";
                        PRArchSuggestedVendorLoc.Converted := SuggestedVendorLoc.Converted;
                        PRArchSuggestedVendorLoc."PR No." := SuggestedVendorLoc."PR No.";
                        PRArchSuggestedVendorLoc."PR Line No." := SuggestedVendorLoc."PR Line No.";
                        PRArchSuggestedVendorLoc.INSERT;
                    until SuggestedVendorLoc.NEXT = 0;
                //19.0.0.1>>
                lPurchaseHeader.Reset();
                lPurchaseHeader.SetRange("Document Type", lPurchaseHeader."Document Type"::Quote);
                lPurchaseHeader.SetRange("PR No.", PRNoRecPAR."No.");
                if lPurchaseHeader.FindSet() then
                    repeat
                        ArchiveManagement.StorePurchDocument(lPurchaseHeader, false);
                    until lPurchaseHeader.Next() = 0;
                //19.0.0.1<<
                WindowLoc.CLOSE;
                MESSAGE('PR No. %1 Archived to Version %2 Successfully', PRNoRecPAR."No.", PRArchHeaderLoc."Version No.");
            end;
        end;
    end;

    procedure SendApprovalRequestRFQ(var RFQComparision: Record "RFQ Comparison");
    var
        LPLine: Record "Purchase Line";
        LDocApprovalPurchReq: Codeunit "Document Approval PR-IBIZRFQ";
        LSugVend: Record "Suggested Vendor";
        LAmountLCY: Decimal;
        LPLine2: Record "Purchase Line";
        Lvendor: Record Vendor;
        ApprovalTemp: Record "Approval Templates";
        TotalAmt: Decimal;
        PurchasePaysetup: Record "Purchases & Payables Setup";
        AvailableBudget: Decimal;
        Utilised: Decimal;
        OnHold: Decimal;
        TotalBudgetAmount: Decimal;
        UsedBudgetAmount: Decimal;
        AccountingPeriod: Record "Accounting Period";
        GLAccount: Record "G/L Account";
        UPCPRTotal: Decimal;
        GLBudgetEntry: Record "G/L Budget Entry";
        ApprovalSetup: Record "Approval Setup";
        TotalBudget: Decimal;
        IBIZApprovalsMgmt: Codeunit "IBIZ-Approvals Mgmt-IBIZRFQ";
    begin

        //Version 19.0.0.0>>
        RFQComparision.TESTFIELD("RFQ Status", RFQComparision."RFQ Status"::Open);
        CheckProspectVendorInPurchaseLine(RFQComparision."No.");
        //Version 19.0.0.0<<
        RFQComparision.TESTFIELD(Requester);

        LPLine.RESET;
        LPLine.SETRANGE("Document Type", LPLine."Document Type"::Quote);
        LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
        LPLine.SETFILTER(LPLine.Type, '<>%1', LPLine.Type::" ");
        LPLine.SETRANGE("Create PO", true);
        if not LPLine.FINDSET then
            ERROR('No line selected for Convert to PO');

        LPLine.SETRANGE("Create PO", true);
        LPLine.SETRANGE("Converted to PO", false);
        if LPLine.FINDSET then
            repeat
                if Lvendor.GET(LPLine."Buy-from Vendor No.") then begin
                    Lvendor.TESTFIELD("Prospect Vendor", false);
                    Lvendor.TESTFIELD(Blocked, Lvendor.Blocked::" ");
                end;
            until LPLine.NEXT = 0;

        //Project Budget
        RFQHeaderRec.RESET;
        RFQHeaderRec.SETRANGE("No.", RFQComparision."PR No");
        if RFQHeaderRec.FINDFIRST then begin
            Noseries.RESET;
            Noseries.SETRANGE(Code, RFQHeaderRec."No. series");
            if Noseries.FINDFIRST then;
            PurchasePaysetup.GET;
            GLSetup.GET;
            if ((not RFQHeaderRec."Budgetary PR") and Noseries."Enable Project Budget") then begin
                CLEAR(TotalBudget);
                LPLine.RESET;
                LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
                LPLine.SETFILTER(LPLine.Type, '<>%1', LPLine.Type::" ");
                LPLine.SETRANGE("Create PO", true);
                if LPLine.FINDSET then begin
                    repeat
                        if Lvendor.GET(LPLine."Buy-from Vendor No.") then begin
                            Lvendor.TESTFIELD("Prospect Vendor", false);
                            Lvendor.TESTFIELD(Blocked, Lvendor.Blocked::" ");
                        end;

                        CLEAR(GTotalInvoice);
                        CLEAR(GTotalCrLine);
                        CLEAR(GTotalPurchaseLines);
                        CLEAR(GTotalReturn);
                        CLEAR(GTotalPReq);

                        CalcInvoiceTotal(LPLine);
                        CalcCreditMemoTotal(LPLine);
                        CalcPurchaseOrder(LPLine);
                        CalcPurchaseReturnOrderTotal(LPLine);
                        CalcPurchaseReqTotal(LPLine);
                        CalcPurchaseOrderForUtilised(LPLine);
                        CalcPurchaseReqTotalForOnHold(LPLine);

                        GImportBudget.RESET;
                        GImportBudget.SETRANGE("Project ID", LPLine."Shortcut Dimension 2 Code");
                        GImportBudget.SETRANGE("WBS ID", LPLine."WBS ID");
                        GImportBudget.SETRANGE("Activity ID", LPLine."Activity ID");
                        if GImportBudget.FINDFIRST then begin
                            AvailableBudget := GImportBudget."Budgeted Total Cost" -
                             (GTotalInvoice + GTotalPurchaseLines + GTotalPReq - GTotalCrLine - GTotalReturn);
                            Utilised := (GTotalInvoice + GTotalPurchaseLinesUtilised - GTotalCrLine - GTotalReturn);
                            OnHold := GTotalBudgetOnHold;
                        end;

                        TotalBudget += AvailableBudget;

                        CLEAR(LAmountLCY);
                        LAmountLCY := LPLine.Quantity * LPLine."Unit Cost (LCY)";
                        if PurchasePaysetup."Dimension for PR Approval" then//19.0.0.6
                            LPLine.TESTFIELD("Shortcut Dimension 2 Code");
                        LPLine.TESTFIELD("WBS ID");
                        LPLine.TESTFIELD("Activity ID");
                        if LAmountLCY > AvailableBudget then begin
                            ApprovalsMgtNotification.SendRFQBudgetNotificationMail(RFQComparision, LPLine, TotalBudget);
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;

                        LPLine2.RESET;
                        LPLine2.SETRANGE("Document No.", LPLine."Document No.");
                        LPLine2.SETFILTER(LPLine2.Type, '<>%1', LPLine2.Type::" ");
                        LPLine2.SETRANGE("WBS ID", LPLine."WBS ID");
                        LPLine2.SETRANGE("Activity ID", LPLine."Activity ID");
                        LPLine2.SETFILTER("Line No.", '<>%1', LPLine."Line No.");
                        if LPLine2.FINDSET then
                            repeat
                                LAmountLCY += (LPLine2.Quantity * LPLine2."Unit Cost (LCY)");
                            until LPLine2.NEXT = 0;

                        if LAmountLCY > AvailableBudget then begin
                            if ApprovalSetup.GET and ApprovalSetup.Approvals then
                                ApprovalsMgtNotification.SendRFQBudgetNotificationMail(RFQComparision, LPLine, TotalBudget);
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;

                        LPLine.VALIDATE("Activity ID");
                        LPLine.MODIFY;
                    until LPLine.NEXT = 0;
                end else
                    ERROR('Create PO not Selected');
            end;
            //GL Budget
            if ((not RFQHeaderRec."Budgetary PR") and Noseries."Enable GL Budget") then begin
                PurchasePaysetup.TESTFIELD("PR Budget Name");
                PurchasePaysetup.TESTFIELD("Budget End Date");
                PurchasePaysetup.TESTFIELD("Budget Start Date");
                CLEAR(TotalBudget);
                LPLine.RESET;
                LPLine.SETRANGE(LPLine."RFQ No.", RFQComparision."No.");
                LPLine.SETFILTER(LPLine.Type, '<>%1', LPLine.Type::" ");
                LPLine.SETRANGE("Create PO", true);
                if LPLine.FINDSET then begin
                    repeat
                        CLEAR(TotalBudgetAmount);
                        CLEAR(UsedBudgetAmount);
                        CLEAR(GTotalInvoice);
                        CLEAR(GTotalCrLine);
                        CLEAR(GTotalPurchaseLines);
                        CLEAR(GTotalReturn);
                        CLEAR(GTotalPReq);
                        CLEAR(GTotalBudgetOnHold);
                        EndDate := PurchasePaysetup."Budget End Date";
                        StartDate := PurchasePaysetup."Budget Start Date";
                        GLAccount.RESET;
                        if LPLine.Type = LPLine.Type::"G/L Account" then Begin
                            GLAccount2.GET(LPLine."No.");

                            if GLAccount2."Budget Link A/C" <> '' then
                                GLAccount.SETFILTER("No.", '%1|%2', GLAccount2."No.", GLAccount2."Budget Link A/C")
                            else
                                GLAccount.SETRANGE("No.", LPLine."No.");
                            // GLAccount.SetRange("Global Dimension 1 Code", LPLine."Shortcut Dimension 1 Code");//19.0.0.4>>
                            // GLAccount.SetRange("Global Dimension 2 Code", LPLine."Shortcut Dimension 2 Code");//19.0.0.4>>
                            GLAccount.SETFILTER("Dimension set ID Filter", '%1', LPLine."Dimension Set ID");//19.0.0.4>>
                                                                                                            // GLAccount.SetRange("Global Dimension 1 Filter", LPLine."Shortcut Dimension 1 Code");//19.0.0.4>>
                                                                                                            // GLAccount.SetRange("Global Dimension 2 Filter", LPLine."Shortcut Dimension 2 Code");//19.0.0.4>>
                            GLAccount.SETRANGE("Date Filter", StartDate, EndDate);
                            if GLAccount.FINDSET() then begin
                                repeat
                                    GLAccount.CALCFIELDS("Balance at Date");
                                    UsedBudgetAmount += GLAccount."Balance at Date";
                                until GLAccount.NEXT = 0;
                            end;
                        End;
                        //PR with petty cash released
                        CLEAR(UPCPRTotal);
                        CLEAR(HoldUPCPRTotal);

                        GLBudgetEntry.RESET;
                        GLBudgetEntry.SETRANGE("Budget Name", PurchasePaysetup."PR Budget Name");
                        GLBudgetEntry.SETRANGE("G/L Account No.", LPLine."No.");
                        GLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                        // GLBudgetEntry.SetRange("Global Dimension 1 Code", LPLine."Shortcut Dimension 1 Code");//19.0.0.4>>
                        // GLBudgetEntry.SetRange("Global Dimension 2 Code", LPLine."Shortcut Dimension 2 Code");//19.0.0.4>>
                        GLBudgetEntry.SETRANGE("Dimension Set ID", LPLine."Dimension Set ID");//19.0.0.5>>
                        if GLBudgetEntry.FINDSET then
                            repeat
                                TotalBudgetAmount += GLBudgetEntry.Amount;
                            until GLBudgetEntry.NEXT = 0;

                        BCalcPurchaseOrder(LPLine);
                        //  BCalcPurchaseReqTotalForOnHold(LPLine);

                        Utilised := UsedBudgetAmount + UPCPRTotal + (GTotalInvoice - GTotalCrLine - GTotalReturn);
                        OnHold := GTotalBudgetOnHold + HoldUPCPRTotal;
                        if TotalBudgetAmount <> 0 then
                            AvailableBudget := TotalBudgetAmount - Utilised - OnHold
                        else
                            AvailableBudget := 0;
                        TotalBudget += AvailableBudget;

                        CLEAR(LAmountLCY);

                        LPLine2.RESET;
                        LPLine2.SETRANGE("Document No.", LPLine."Document No.");
                        LPLine2.SETRANGE(LPLine2.Type, LPLine2.Type::"G/L Account");
                        LPLine2.SETRANGE("No.", LPLine."No.");
                        if LPLine2.FINDSET then
                            repeat
                                LAmountLCY += (LPLine2.Quantity * LPLine2."Unit Cost (LCY)");
                            until LPLine2.NEXT = 0;

                        if LAmountLCY > AvailableBudget then begin
                            ERROR(GText008, LPLine.Type, LPLine."No.", PRLine."Line No.");
                        end;
                    until LPLine.NEXT = 0;
                    RFQComparision."Total Budget" := TotalBudget;
                    RFQComparision.MODIFY;
                    // 19.0.0.4>>
                    if IBIZApprovalsMgmt.IsRFQApprovalsWorkflowEnabled(RFQComparision) then
                        IBIZApprovalsMgmt.OnSendRFQDocForApproval(RFQComparision);
                    // 19.0.0.4<<
                end else
                    ERROR('Create PO not Selected');
            end;
        end;
    end;

    procedure ReleaseRFQCDocAfterApprove(RFQComp: Record "RFQ Comparison");
    var
        LSugVend: Record "Suggested Vendor";
    begin

        RFQComp.Status := RFQComp.Status::Released;
        RFQComp.MODIFY;

        MakeOrder(RFQComp);
        MESSAGE(GText015, RFQComp."No.");

    end;
    /* 
        procedure SendApprovalRequestLOA(var RFQHeaderLoc: Record "PR Header");
        var
            LPRLine: Record "PR Line";
            LDocApprovalPurchReq: Codeunit "Document Approval PR-IBIZRFQ";
            LSugVend: Record "Suggested Vendor";
            Lamount: Decimal;
            LAmountLCY: Decimal;
            LPRLine2: Record "PR Line";
            ApprovalTemp: Record "Approval Templates";
            TotalAmt: Decimal;
            PPSetup: Record "Purchases & Payables Setup";
            Approvalsetup: Record "Approval Setup";
            TotalBudget: Decimal;
            ItemNo: Code[20];
            AccountingPeriod: Record "Accounting Period";
            TotalBudgetAmount: Decimal;
            UsedBudgetAmount: Decimal;
            GLAccount: Record "G/L Account";
            GLBudgetEntry: Record "G/L Budget Entry";
            Utilised: Decimal;
            OnHold: Decimal;
            UPCPRTotal: Decimal;
            AvailableBudget: Decimal;
        begin
            RFQHeaderLoc.TESTFIELD(Status, RFQHeaderLoc.Status::Released);
            RFQHeaderLoc.TESTFIELD(RFQHeaderLoc.Requester);
            RFQHeaderLoc.TESTFIELD(RFQHeaderLoc."Purchaser Code");

            CLEAR(TotalBudget);
            Noseries.RESET;
            Noseries.SETRANGE(Code, RFQHeaderLoc."No. series");
            if Noseries.FINDFIRST then;
            PPSetup.GET;


            if PPSetup."Dimension for PR Approval" then begin
                if (RFQHeaderLoc."Shortcut Dimension 1 Code" = '') then
                    ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
                if (RFQHeaderLoc."Shortcut Dimension 2 Code" = '') then
                    ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");
            end;

            LSugVend.RESET;
            LSugVend.SETRANGE("Document Type", LSugVend."Document Type"::"PR Header");
            LSugVend.SETRANGE("PR No.", RFQHeaderLoc."No.");
            LSugVend.SETFILTER("Suggested Vendor", '<>%1', '');
            if LSugVend.FINDFIRST then begin
                if LSugVend.COUNT > 1 then
                    ERROR(GText010);
            end else begin
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
                // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
                PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
                if PRLine.FINDSET then
                    repeat
                        if PRLine."Suggested Vendor" = '' then
                            ERROR('Please Suggest a Vendor in the Header.');
                    until PRLine.NEXT = 0;
            end;
            //Petty Cash Limit Check >>
            if RFQHeaderLoc."PR Document Type" = RFQHeaderLoc."PR Document Type"::PC then begin
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
                // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
                PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
                if PRLine.FINDSET then
                    repeat
                        PRLine.TESTFIELD("Unit Cost");
                        TotalAmt += PRLine.Amount;
                    until PRLine.NEXT = 0;

                ApprovalTemp.RESET;
                ApprovalTemp.SETRANGE("Document Type", ApprovalTemp."Document Type"::PR);
                ApprovalTemp.SETRANGE(ApprovalTemp."No. series", RFQHeaderLoc."No. series");
                if ApprovalTemp.FINDFIRST then begin
                    if (ApprovalTemp."Petty Cash Limit" <> 0) and (TotalAmt > ApprovalTemp."Petty Cash Limit") then
                        ERROR('The PR amount exceeded the limit, please raise normal PR');
                end;
            end;
            //Petty Cash Limit Check <<
            //Project Budget
            GLSetup.GET;
            if ((not RFQHeaderLoc."Budgetary PR") and Noseries."Enable Project Budget") then begin
                if (RFQHeaderLoc."Shortcut Dimension 1 Code" = '') then
                    ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
                if (RFQHeaderLoc."Shortcut Dimension 2 Code" = '') then
                    ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");

                LPRLine.RESET;
                LPRLine.SETRANGE("Document No.", RFQHeader."No.");
                // LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::Description);//19.0.0.5
                LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::" ");//19.0.0.5
                if LPRLine.FINDSET then
                    repeat
                        CLEAR(LAmountLCY);
                        LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                        Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                        if PPSetup."Dimension for PR Approval" then//19.0.0.6
                            LPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                        LPRLine.TESTFIELD("WBS ID");
                        LPRLine.TESTFIELD("Activity ID");
                        if LAmountLCY > LPRLine."Available Budget" then begin
                            ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                        end;

                        LPRLine2.RESET;
                        LPRLine2.SETRANGE("Document No.", LPRLine."Document No.");
                        // LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::Description);//19.0.0.5
                        LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::" ");//19.0.0.5
                        LPRLine2.SETRANGE("WBS ID", LPRLine."WBS ID");
                        LPRLine2.SETRANGE("Activity ID", LPRLine."Activity ID");
                        LPRLine2.SETFILTER("Line No.", '<>%1', LPRLine."Line No.");
                        if LPRLine2.FINDSET then
                            repeat
                                LAmountLCY += (LPRLine2.Quantity * LPRLine2."Unit Cost (LCY)");
                                Lamount += (LPRLine2.Quantity * LPRLine2."Unit Cost");
                            until LPRLine2.NEXT = 0;

                        if LAmountLCY > LPRLine."Available Budget" then begin
                            ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                        end;
                        LPRLine.VALIDATE("Activity ID");
                        LPRLine.MODIFY;
                    until LPRLine.NEXT = 0;
            end;
            //GL Budget
            if ((not RFQHeaderLoc."Budgetary PR") and Noseries."Enable GL Budget") then begin
                PPSetup.TESTFIELD(PPSetup."Budget End Date");
                PPSetup.TESTFIELD(PPSetup."Budget Start Date");
                PPSetup.TESTFIELD(PPSetup."PR Budget Name");
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
                // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
                PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
                if PRLine.FINDSET then
                    repeat
                        PRLine.TESTFIELD("Unit Cost");
                        CLEAR(TotalBudgetAmount);
                        CLEAR(UsedBudgetAmount);
                        CLEAR(GTotalInvoice);
                        CLEAR(GTotalCrLine);
                        CLEAR(GTotalPurchaseLines);
                        CLEAR(GTotalReturn);
                        CLEAR(GTotalPReq);
                        CLEAR(GTotalBudgetOnHold);
                        CLEAR(AvailableBudget);
                        CLEAR(Utilised);
                        CLEAR(OnHold);
                        EndDate := PPSetup."Budget End Date";
                        StartDate := PPSetup."Budget Start Date";
                        GLAccount.RESET;
                        GLAccount2.GET(PRLine."No.");
                        if GLAccount2."Budget Link A/C" <> '' then
                            GLAccount.SETFILTER("No.", '%1|%2', GLAccount2."No.", GLAccount2."Budget Link A/C")
                        else
                            GLAccount.SETRANGE("No.", PRLine."No.");
                        // GLAccount.SETRANGE("Global Dimension 1 Filter", PRLine."Shortcut Dimension 1 Code");//19.0.0.5
                        // GLAccount.SETRANGE("Global Dimension 2 Filter", PRLine."Shortcut Dimension 2 Code");//19.0.0.5
                        GLAccount.SETRANGE("Date Filter", StartDate, EndDate);
                        GLAccount.SETFILTER("Dimension set ID Filter", '%1', PRLine."Dimension Set ID");
                        if GLAccount.FINDSET then begin
                            GLAccount.CALCFIELDS("Balance at Date");
                            UsedBudgetAmount += GLAccount."Balance at Date";
                        end;

                        //PR with petty cash released
                        GLBudgetEntry.RESET;
                        GLBudgetEntry.SETRANGE("Budget Name", PPSetup."PR Budget Name");
                        GLBudgetEntry.SETRANGE("G/L Account No.", PRLine."No.");
                        // GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PRLine."Shortcut Dimension 1 Code");//19.0.0.5
                        // GLBudgetEntry.SETRANGE("Global Dimension 2 Code", PRLine."Shortcut Dimension 2 Code");//19.0.0.5
                        GLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                        GLBudgetEntry.SETRANGE(GLBudgetEntry."Dimension Set ID", PRLine."Dimension Set ID");//19.0.0.5
                        if GLBudgetEntry.FINDSET then
                            repeat
                                TotalBudgetAmount += GLBudgetEntry.Amount;
                            until GLBudgetEntry.NEXT = 0;
                        BCalcPurchaseOrderPR(PRLine);
                        BCalcPurchaseReqTotalForOnHoldPR(PRLine);

                        Utilised := UsedBudgetAmount + UPCPRTotal + (GTotalInvoice - GTotalCrLine - GTotalReturn);
                        OnHold := GTotalBudgetOnHold + HoldUPCPRTotal + GTotalPurchaseLines;
                        AvailableBudget := TotalBudgetAmount - Utilised - OnHold;
                        TotalBudget += AvailableBudget;
                        LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                        Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                        if LAmountLCY > AvailableBudget then begin

                            ERROR(GText008, PRLine.Type, PRLine."No.", PRLine."Line No.");
                        end;
                    until PRLine.NEXT = 0;
            end;
            LDocApprovalPurchReq.SendPurchaseReqApprovalLOA(RFQHeaderLoc, TotalBudget);

        end; */

    procedure WFSendApprovalRequestLOA(var RFQHeaderLoc: Record "PR Header");
    var
        LPRLine: Record "PR Line";
        LDocApprovalPurchReq: Codeunit "Document Approval PR-IBIZRFQ";
        LSugVend: Record "Suggested Vendor";
        Lamount: Decimal;
        LAmountLCY: Decimal;
        LPRLine2: Record "PR Line";
        ApprovalTemp: Record "Approval Templates";
        TotalAmt: Decimal;
        PPSetup: Record "Purchases & Payables Setup";
        Approvalsetup: Record "Approval Setup";
        TotalBudget: Decimal;
        ItemNo: Code[20];
        AccountingPeriod: Record "Accounting Period";
        TotalBudgetAmount: Decimal;
        UsedBudgetAmount: Decimal;
        GLAccount: Record "G/L Account";
        GLBudgetEntry: Record "G/L Budget Entry";
        Utilised: Decimal;
        OnHold: Decimal;
        UPCPRTotal: Decimal;
        AvailableBudget: Decimal;
    begin
        RFQHeaderLoc.TESTFIELD(Status, RFQHeaderLoc.Status::Released);
        RFQHeaderLoc.TESTFIELD(RFQHeaderLoc.Requester);
        RFQHeaderLoc.TESTFIELD(RFQHeaderLoc."Purchaser Code");

        CLEAR(TotalBudget);
        Noseries.RESET;
        Noseries.SETRANGE(Code, RFQHeaderLoc."No. series");
        if Noseries.FINDFIRST then;
        PPSetup.GET;

        //Dimension checking if setup done in Purchase and payable setup
        if PPSetup."Dimension for PR Approval" then begin
            if (RFQHeaderLoc."Shortcut Dimension 1 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
            if (RFQHeaderLoc."Shortcut Dimension 2 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");
        end;

        LSugVend.RESET;
        LSugVend.SETRANGE("Document Type", LSugVend."Document Type"::"PR Header");
        LSugVend.SETRANGE("PR No.", RFQHeaderLoc."No.");
        LSugVend.SETFILTER("Suggested Vendor", '<>%1', '');
        if LSugVend.FINDFIRST then begin
            if LSugVend.COUNT > 1 then
                ERROR(GText010);
        end else begin
            PRLine.RESET;
            PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
            // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
            PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
            if PRLine.FINDSET then
                repeat
                    if PRLine."Suggested Vendor" = '' then
                        ERROR('Please Suggest a Vendor in the Header.');
                until PRLine.NEXT = 0;
        end;

        //Petty Cash Limit Check >>
        if RFQHeaderLoc."PR Document Type" = RFQHeaderLoc."PR Document Type"::PC then begin
            PRLine.RESET;
            PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
            // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
            PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
            if PRLine.FINDSET then
                repeat
                    PRLine.TESTFIELD("Unit Cost");
                    TotalAmt += PRLine.Amount;
                until PRLine.NEXT = 0;

            ApprovalTemp.RESET;
            ApprovalTemp.SETRANGE("Document Type", ApprovalTemp."Document Type"::PR);
            ApprovalTemp.SETRANGE(ApprovalTemp."No. series", RFQHeaderLoc."No. series");
            if ApprovalTemp.FINDFIRST then begin
                if (ApprovalTemp."Petty Cash Limit" <> 0) and (TotalAmt > ApprovalTemp."Petty Cash Limit") then
                    ERROR('The PR amount exceeded the limit, please raise normal PR');
            end;
        end;
        //Petty Cash Limit Check <<
        //Project Budget
        GLSetup.GET;
        if ((not RFQHeaderLoc."Budgetary PR") and Noseries."Enable Project Budget") then begin
            if (RFQHeaderLoc."Shortcut Dimension 1 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 1 Code");
            if (RFQHeaderLoc."Shortcut Dimension 2 Code" = '') then
                ERROR('%1 Should not be empty', GLSetup."Shortcut Dimension 2 Code");

            LPRLine.RESET;
            LPRLine.SETRANGE("Document No.", RFQHeader."No.");
            // LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::Description);//19.0.0.5
            LPRLine.SETFILTER(LPRLine.Type, '<>%1', LPRLine.Type::" ");//19.0.0.5
            if LPRLine.FINDSET then
                repeat
                    CLEAR(LAmountLCY);
                    LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                    Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                    if PPSetup."Dimension for PR Approval" then//19.0.0.6
                        LPRLine.TESTFIELD("Shortcut Dimension 2 Code");
                    LPRLine.TESTFIELD("WBS ID");
                    LPRLine.TESTFIELD("Activity ID");
                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;

                    LPRLine2.RESET;
                    LPRLine2.SETRANGE("Document No.", LPRLine."Document No.");
                    // LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::Description);//19.0.0.5
                    LPRLine2.SETFILTER(LPRLine2.Type, '<>%1', LPRLine2.Type::" ");//19.0.0.5
                    LPRLine2.SETRANGE("WBS ID", LPRLine."WBS ID");
                    LPRLine2.SETRANGE("Activity ID", LPRLine."Activity ID");
                    LPRLine2.SETFILTER("Line No.", '<>%1', LPRLine."Line No.");
                    if LPRLine2.FINDSET then
                        repeat
                            LAmountLCY += (LPRLine2.Quantity * LPRLine2."Unit Cost (LCY)");
                            Lamount += (LPRLine2.Quantity * LPRLine2."Unit Cost");
                        until LPRLine2.NEXT = 0;

                    if LAmountLCY > LPRLine."Available Budget" then begin
                        ERROR(GText008, LPRLine.Type, LPRLine."No.", PRLine."Line No.");
                    end;
                    LPRLine.VALIDATE("Activity ID");
                    LPRLine.MODIFY;
                until LPRLine.NEXT = 0;
        end;
        //GL Budget
        if ((not RFQHeaderLoc."Budgetary PR") and Noseries."Enable GL Budget") then begin
            PPSetup.TESTFIELD(PPSetup."Budget End Date");
            PPSetup.TESTFIELD(PPSetup."Budget Start Date");
            PPSetup.TESTFIELD(PPSetup."PR Budget Name");
            PRLine.RESET;
            PRLine.SETRANGE("Document No.", RFQHeaderLoc."No.");
            // PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::Description);//19.0.0.5
            PRLine.SETFILTER(PRLine.Type, '<>%1', PRLine.Type::" ");//19.0.0.5
            if PRLine.FINDSET then
                repeat
                    PRLine.TESTFIELD("Unit Cost");
                    CLEAR(TotalBudgetAmount);
                    CLEAR(UsedBudgetAmount);
                    CLEAR(GTotalInvoice);
                    CLEAR(GTotalPurchaseLines);
                    CLEAR(GTotalPReq);
                    CLEAR(GTotalBudgetOnHold);
                    CLEAR(AvailableBudget);
                    CLEAR(Utilised);
                    CLEAR(OnHold);
                    EndDate := PPSetup."Budget End Date";
                    StartDate := PPSetup."Budget Start Date";
                    GLAccount.RESET;
                    // GLAccount2.GET(PRLine."No.");//19.0.0.4>>
                    GLAccount2.GET(PRLine."G/L Account No.");//19.0.0.4>>
                    if GLAccount2."Budget Link A/C" <> '' then
                        GLAccount.SETFILTER("No.", '%1|%2', GLAccount2."No.", GLAccount2."Budget Link A/C")
                    else
                        // GLAccount.SETRANGE("No.", PRLine."No.");//19.0.0.4>>
                        GLAccount.SETRANGE("No.", PRLine."G/L Account No.");//19.0.0.4>>
                    // GLAccount.SETRANGE("Global Dimension 1 Filter", PRLine."Shortcut Dimension 1 Code");//19.0.0.5
                    // GLAccount.SETRANGE("Global Dimension 2 Filter", PRLine."Shortcut Dimension 2 Code");//19.0.0.5
                    GLAccount.SETRANGE("Date Filter", StartDate, EndDate);
                    GLAccount.SETFILTER("Dimension set ID Filter", '%1', PRLine."Dimension Set ID");
                    if GLAccount.FINDSET then begin
                        GLAccount.CALCFIELDS("Balance at Date");
                        UsedBudgetAmount += GLAccount."Balance at Date";
                    end;

                    //PR with petty cash released
                    GLBudgetEntry.RESET;
                    GLBudgetEntry.SETRANGE("Budget Name", PPSetup."PR Budget Name");
                    // GLBudgetEntry.SETRANGE("G/L Account No.", PRLine."No.");//19.0.0.4>>
                    GLBudgetEntry.SETRANGE("G/L Account No.", PRLine."G/L Account No.");//19.0.0.4>>
                    // GLBudgetEntry.SETRANGE("Global Dimension 1 Code", PRLine."Shortcut Dimension 1 Code");//19.0.0.5
                    // GLBudgetEntry.SETRANGE("Global Dimension 2 Code", PRLine."Shortcut Dimension 2 Code");//19.0.0.5
                    GLBudgetEntry.SETRANGE(Date, StartDate, EndDate);
                    GLBudgetEntry.SETRANGE(GLBudgetEntry."Dimension Set ID", PRLine."Dimension Set ID");//19.0.0.5
                    if GLBudgetEntry.FINDSET then
                        repeat
                            TotalBudgetAmount += GLBudgetEntry.Amount;
                        until GLBudgetEntry.NEXT = 0;
                    BCalcPurchaseOrderPR(PRLine);
                    //BCalcPurchaseReqTotalForOnHoldPR(PRLine);

                    Utilised := UsedBudgetAmount + UPCPRTotal + (GTotalInvoice - GTotalCrLine - GTotalReturn);
                    OnHold := GTotalBudgetOnHold + HoldUPCPRTotal + GTotalPurchaseLines;
                    AvailableBudget := TotalBudgetAmount - Utilised - OnHold;
                    TotalBudget += AvailableBudget;
                    LAmountLCY := LPRLine.Quantity * LPRLine."Unit Cost (LCY)";
                    Lamount := LPRLine.Quantity * LPRLine."Unit Cost";
                    if LAmountLCY > AvailableBudget then begin
                        ERROR(GText008, PRLine.Type, PRLine."No.", PRLine."Line No.");
                    end;
                until PRLine.NEXT = 0;
        end;
    end;

    procedure CalcInvoiceTotal(Pline: Record "Purchase Line");
    var
        LPurchInvHdr: Record "Purch. Inv. Header";
        Currency: Record Currency;
        VendAmount: Decimal;
        AmountInclVAT: Decimal;
        InvDiscAmount: Decimal;
        AmountLCY: Decimal;
        LineQty: Decimal;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        VATAmount: Decimal;
        VATPercentage: Decimal;
        VATAmountText: Text[30];
        IsPrePaymentLine: Boolean;
    begin
        GLSetup.GET;

        GPurchInvLine.RESET;
        GPurchInvLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPurchInvLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPurchInvLine.SETRANGE("Activity ID", Pline."Activity ID");
        if GPurchInvLine.FINDSET then
            repeat
                CLEAR(IsPrePaymentLine);
                CLEAR(VendAmount);
                CLEAR(AmountInclVAT);
                CLEAR(InvDiscAmount);
                CLEAR(VATAmount);
                LPurchInvHdr.RESET;
                LPurchInvHdr.SETRANGE("No.", GPurchInvLine."Document No.");
                if LPurchInvHdr.FINDFIRST then;
                if LPurchInvHdr."Currency Code" = '' then
                    Currency.InitRoundingPrecision
                else
                    Currency.GET(LPurchInvHdr."Currency Code");

                VendAmount := VendAmount + GPurchInvLine.Amount;
                AmountInclVAT := AmountInclVAT + GPurchInvLine."Amount Including VAT";
                if LPurchInvHdr."Prices Including VAT" then
                    InvDiscAmount := InvDiscAmount + GPurchInvLine."Inv. Discount Amount" / (1 + GPurchInvLine."VAT %" / 100)
                else
                    InvDiscAmount := InvDiscAmount + GPurchInvLine."Inv. Discount Amount";

                VATAmount := AmountInclVAT - VendAmount;
                InvDiscAmount := ROUND(InvDiscAmount, Currency."Amount Rounding Precision");
                if LPurchInvHdr."Currency Code" = '' then
                    GTotalInvoice += (VendAmount + VATAmount - InvDiscAmount)
                else
                    GTotalInvoice +=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, LPurchInvHdr."Currency Code", (VendAmount + VATAmount - InvDiscAmount), LPurchInvHdr."Currency Factor");

            until GPurchInvLine.NEXT = 0;
    end;

    procedure CalcCreditMemoTotal(Pline: Record "Purchase Line");
    var
        LPurchCreditHdr: Record "Purch. Cr. Memo Hdr.";
        Currency: Record Currency;
        VendAmount: Decimal;
        AmountInclVAT: Decimal;
        InvDiscAmount: Decimal;
        AmountLCY: Decimal;
        LineQty: Decimal;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        VATAmount: Decimal;
        VATPercentage: Decimal;
        VATAmountText: Text[30];
        IsPrePaymentLine: Boolean;
    begin
        GPurchCrLine.RESET;
        GPurchCrLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPurchCrLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPurchCrLine.SETRANGE("Activity ID", Pline."Activity ID");
        if GPurchCrLine.FINDSET then
            repeat
                CLEAR(IsPrePaymentLine);
                CLEAR(VendAmount);
                CLEAR(AmountInclVAT);
                CLEAR(InvDiscAmount);
                CLEAR(VATAmount);

                LPurchCreditHdr.RESET;
                LPurchCreditHdr.SETRANGE("No.", GPurchCrLine."Document No.");
                if LPurchCreditHdr.FINDFIRST then;
                if LPurchCreditHdr."Currency Code" = '' then
                    Currency.InitRoundingPrecision
                else
                    Currency.GET(LPurchCreditHdr."Currency Code");

                VendAmount := VendAmount + GPurchCrLine.Amount;
                AmountInclVAT := AmountInclVAT + GPurchCrLine."Amount Including VAT";
                if LPurchCreditHdr."Prices Including VAT" then
                    InvDiscAmount := InvDiscAmount + GPurchCrLine."Inv. Discount Amount" / (1 + GPurchCrLine."VAT %" / 100)
                else
                    InvDiscAmount := InvDiscAmount + GPurchCrLine."Inv. Discount Amount";
                VATAmount := AmountInclVAT - VendAmount;
                InvDiscAmount := ROUND(InvDiscAmount, Currency."Amount Rounding Precision");
                if LPurchCreditHdr."Currency Code" = '' then
                    GTotalCrLine += (VendAmount + VATAmount - InvDiscAmount)
                else
                    GTotalCrLine +=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        WORKDATE, LPurchCreditHdr."Currency Code", (VendAmount + VATAmount - InvDiscAmount), LPurchCreditHdr."Currency Factor");
            until GPurchCrLine.NEXT = 0
    end;

    procedure CalcPurchaseOrder(Pline: Record "Purchase Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
        GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPurchLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPurchLine.SETRANGE("Activity ID", Pline."Activity ID");
        if GPurchLine.FINDSET then
            repeat
                GTotalPurchaseLines += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)";
            until GPurchLine.NEXT = 0;
    end;

    procedure CalcPurchaseReturnOrderTotal(Pline: Record "Purchase Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::"Return Order");
        GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPurchLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPurchLine.SETRANGE("Activity ID", Pline."Activity ID");
        if GPurchLine.FINDSET then
            repeat
                GTotalReturn += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Return Shpd. Not Invd. (LCY)";
            until GPurchLine.NEXT = 0;
    end;

    procedure CalcPurchaseReqTotal(Pline: Record "Purchase Line");
    var
        GPRLine: Record "PR Line";
    begin
        GPRLine.RESET;
        GPRLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPRLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPRLine.SETRANGE("Activity ID", Pline."Activity ID");
        if GPRLine.FINDSET then
            repeat
                if not GPRLine.ConvertedtoOrder then
                    if GPRLine."Document No." <> Pline."Document No." then
                        GTotalPReq += (GPRLine."Unit Cost (LCY)" * GPRLine.Quantity);
            until GPRLine.NEXT = 0;
    end;

    procedure CalcPurchaseReqTotalForOnHold(Pline: Record "Purchase Line");
    var
        GPRLine: Record "PR Line";
    begin
        GPRLine.RESET;
        GPRLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPRLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPRLine.SETRANGE("Activity ID", Pline."Activity ID");
        GPRLine.SETFILTER(Status, '%1|%2', GPRLine.Status::Released, GPRLine.Status::Closed);
        if GPRLine.FINDSET then
            repeat
                if (not GPRLine.ConvertedtoQuote) and (not GPRLine.ConvertedtoOrder) then
                    GTotalBudgetOnHold += (GPRLine."Unit Cost (LCY)" * GPRLine.Quantity);
                if (GPRLine.ConvertedtoOrder) then
                    CalcPurchaseOrderForOnHold(GPRLine);
                if (GPRLine.ConvertedtoQuote) then
                    CalcPurchaseQuoteForOnHold(GPRLine);
            until GPRLine.NEXT = 0;
    end;

    procedure CalcPurchaseOrderForUtilised(Pline: Record "Purchase Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
        GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");
        GPurchLine.SETRANGE("WBS ID", Pline."WBS ID");
        GPurchLine.SETRANGE("Activity ID", Pline."Activity ID");
        GPurchLine.SETFILTER("Quantity Received", '<>0');
        if GPurchLine.FINDSET then
            repeat
                GTotalPurchaseLinesUtilised += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)";
            until GPurchLine.NEXT = 0;
    end;

    procedure CalcPurchaseOrderForOnHold(PRline: Record "PR Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
        GPurchLine.SETRANGE("PR No.", PRline."Document No.");
        GPurchLine.SETRANGE("PR Line No.", PRline."Line No.");
        if GPurchLine.FINDFIRST then
            if GPurchLine."Quantity Received" = 0 then
                GTotalBudgetOnHold += GPurchLine."Outstanding Amount (LCY)";
    end;

    procedure CalcPurchaseQuoteForOnHold(Prline: Record "PR Line");
    var
        LQuoteConvertedToOrder: Boolean;
        LHighestAmt: Decimal;
    begin
        CLEAR(LQuoteConvertedToOrder);
        CLEAR(LHighestAmt);
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
        GPurchLine.SETRANGE("PR No.", Prline."Document No.");
        GPurchLine.SETRANGE("PR Line No.", Prline."Line No.");
        if GPurchLine.FINDSET then
            repeat
                if GPurchLine."PO No" <> '' then
                    LQuoteConvertedToOrder := true;
            until GPurchLine.NEXT = 0;
        if not LQuoteConvertedToOrder then begin
            GPurchLine.RESET;
            GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
            GPurchLine.SETRANGE("PR No.", Prline."Document No.");
            GPurchLine.SETRANGE("PR Line No.", Prline."Line No.");
            if GPurchLine.FINDSET then
                repeat
                    if (LHighestAmt < GPurchLine."Outstanding Amount (LCY)") then
                        LHighestAmt := GPurchLine."Outstanding Amount (LCY)";
                until GPurchLine.NEXT = 0;
        end;
        if not LQuoteConvertedToOrder then
            GTotalBudgetOnHold += LHighestAmt;
    end;

    procedure BCalcInvoiceTotal(Pline: Record "Purchase Line");
    var
        LPurchInvHdr: Record "Purch. Inv. Header";
        Currency: Record Currency;
        VendAmount: Decimal;
        AmountInclVAT: Decimal;
        InvDiscAmount: Decimal;
        AmountLCY: Decimal;
        LineQty: Decimal;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        VATAmount: Decimal;
        VATPercentage: Decimal;
        VATAmountText: Text[30];
        IsPrePaymentLine: Boolean;
    begin
        GLSetup.GET;
        GPurchInvHdr.RESET;
        GPurchInvHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchInvHdr.FINDSET then
            repeat
                GPurchInvLine.RESET;
                GPurchInvLine.SETRANGE("Document No.", GPurchInvHdr."No.");
                GPurchInvLine.SETRANGE("Shortcut Dimension 1 Code", RFQHeaderRec."Shortcut Dimension 1 Code");
                GPurchInvLine.SETRANGE("No.", Pline."No.");
                if GPurchInvLine.FINDSET then
                    repeat
                        CLEAR(IsPrePaymentLine);
                        CLEAR(VendAmount);
                        CLEAR(AmountInclVAT);
                        CLEAR(InvDiscAmount);
                        CLEAR(VATAmount);
                        LPurchInvHdr.RESET;
                        LPurchInvHdr.SETRANGE("No.", GPurchInvLine."Document No.");
                        if LPurchInvHdr.FINDFIRST then;
                        if LPurchInvHdr."Currency Code" = '' then
                            Currency.InitRoundingPrecision
                        else
                            Currency.GET(LPurchInvHdr."Currency Code");

                        VendAmount := VendAmount + GPurchInvLine.Amount;
                        AmountInclVAT := AmountInclVAT + GPurchInvLine."Amount Including VAT";
                        if LPurchInvHdr."Prices Including VAT" then
                            InvDiscAmount := InvDiscAmount + GPurchInvLine."Inv. Discount Amount" / (1 + GPurchInvLine."VAT %" / 100)
                        else
                            InvDiscAmount := InvDiscAmount + GPurchInvLine."Inv. Discount Amount";

                        VATAmount := AmountInclVAT - VendAmount;
                        InvDiscAmount := ROUND(InvDiscAmount, Currency."Amount Rounding Precision");
                        if LPurchInvHdr."Currency Code" = '' then
                            GTotalInvoice += (VendAmount + VATAmount - InvDiscAmount)
                        else
                            GTotalInvoice +=
                              CurrExchRate.ExchangeAmtFCYToLCY(
                                WORKDATE, LPurchInvHdr."Currency Code", (VendAmount + VATAmount - InvDiscAmount), LPurchInvHdr."Currency Factor");

                    until GPurchInvLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    procedure BCalcCreditMemoTotal(Pline: Record "Purchase Line");
    var
        LPurchCreditHdr: Record "Purch. Cr. Memo Hdr.";
        Currency: Record Currency;
        VendAmount: Decimal;
        AmountInclVAT: Decimal;
        InvDiscAmount: Decimal;
        AmountLCY: Decimal;
        LineQty: Decimal;
        TotalNetWeight: Decimal;
        TotalGrossWeight: Decimal;
        TotalVolume: Decimal;
        TotalParcels: Decimal;
        VATAmount: Decimal;
        VATPercentage: Decimal;
        VATAmountText: Text[30];
        IsPrePaymentLine: Boolean;
    begin
        GPurchCrHdr.RESET;
        GPurchCrHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchCrHdr.FINDSET then
            repeat
                GPurchCrLine.RESET;
                GPurchCrLine.SETRANGE("Document No.", GPurchCrHdr."No.");
                GPurchCrLine.SETRANGE("Shortcut Dimension 1 Code", RFQHeaderRec."Shortcut Dimension 1 Code");
                GPurchCrLine.SETRANGE("No.", Pline."No.");
                if GPurchCrLine.FINDSET then
                    repeat
                        CLEAR(IsPrePaymentLine);
                        CLEAR(VendAmount);
                        CLEAR(AmountInclVAT);
                        CLEAR(InvDiscAmount);
                        CLEAR(VATAmount);

                        LPurchCreditHdr.RESET;
                        LPurchCreditHdr.SETRANGE("No.", GPurchCrLine."Document No.");
                        if LPurchCreditHdr.FINDFIRST then;
                        if LPurchCreditHdr."Currency Code" = '' then
                            Currency.InitRoundingPrecision
                        else
                            Currency.GET(LPurchCreditHdr."Currency Code");

                        VendAmount := VendAmount + GPurchCrLine.Amount;
                        AmountInclVAT := AmountInclVAT + GPurchCrLine."Amount Including VAT";
                        if LPurchCreditHdr."Prices Including VAT" then
                            InvDiscAmount := InvDiscAmount + GPurchCrLine."Inv. Discount Amount" / (1 + GPurchCrLine."VAT %" / 100)
                        else
                            InvDiscAmount := InvDiscAmount + GPurchCrLine."Inv. Discount Amount";
                        VATAmount := AmountInclVAT - VendAmount;
                        InvDiscAmount := ROUND(InvDiscAmount, Currency."Amount Rounding Precision");
                        if LPurchCreditHdr."Currency Code" = '' then
                            GTotalCrLine += (VendAmount + VATAmount - InvDiscAmount)
                        else
                            GTotalCrLine +=
                              CurrExchRate.ExchangeAmtFCYToLCY(
                                WORKDATE, LPurchCreditHdr."Currency Code", (VendAmount + VATAmount - InvDiscAmount), LPurchCreditHdr."Currency Factor");
                    until GPurchCrLine.NEXT = 0
            until GPurchCrHdr.NEXT = 0;
    end;

    procedure BCalcPurchaseOrder(Pline: Record "Purchase Line");
    begin
        GPurchHdr.RESET;
        GPurchHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchHdr.FINDSET then
            repeat
                GPurchLine.RESET;
                GPurchLine.SETRANGE("Document No.", GPurchHdr."No.");
                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
                // GPurchLine.SETRANGE("No.", Pline."No.");//19.0.0.5>>
                GPurchLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5>>
                // GPurchLine.SetRange("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.4>>
                // GPurchLine.SetRange("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.4>>
                GPurchLine.SETRANGE("Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5>>
                if GPurchLine.FINDSET then
                    repeat
                        GPurchLine.CALCFIELDS("PR In G/L", "G/L Total Amt for PR");
                        if GPurchLine."PR In G/L" then
                            GTotalPurchaseLines += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)" - GPurchLine."G/L Total Amt for PR"
                        else
                            GTotalPurchaseLines += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)";
                    until GPurchLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    procedure BCalcPurchaseReturnOrderTotal(Pline: Record "Purchase Line");
    begin
        GPurchHdr.RESET;
        GPurchHdr.SETRANGE("Document Type", GPurchLine."Document Type"::"Return Order");
        GPurchHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchHdr.FINDSET then
            repeat
                GPurchLine.RESET;
                GPurchLine.SETRANGE("Document No.", GPurchHdr."No.");
                // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.5
                // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.5
                GPurchLine.SETRANGE("Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5
                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::"Return Order");
                // GPurchLine.SETRANGE("No.", Pline."No.");//19.0.0.5
                GPurchLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5
                if GPurchLine.FINDSET then
                    repeat
                        GTotalReturn += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Return Shpd. Not Invd. (LCY)";
                    until GPurchLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    procedure BCalcPurchaseReqTotal(Pline: Record "Purchase Line");
    var
        GPRLine: Record "PR Line";
    begin
        GRFQHeader.RESET;
        // GRFQHeader.SETRANGE(date, StartDate, EndDate);
        if GRFQHeader.FINDSET then
            repeat
                GPRLine.RESET;
                GPRLine.SETRANGE("Document No.", GRFQHeader."No.");
                // GPRLine.SETRANGE("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.5
                // GPRLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.5
                // GPRLine.SETRANGE("No.", Pline."No.");//19.0.0.5
                GPRLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5
                GPRLine.SETRANGE("Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5
                if GPRLine.FINDSET then
                    repeat
                        if not GPRLine.ConvertedtoOrder then
                            if GPRLine."Document No." <> Pline."PR No." then
                                GTotalPReq += (GPRLine."Unit Cost (LCY)" * GPRLine.Quantity);
                    until GPRLine.NEXT = 0;
            until GRFQHeader.NEXT = 0;
    end;
    /* 
        procedure BCalcPurchaseReqTotalForOnHold(Pline: Record "Purchase Line");
        var
            GPRLine: Record "PR Line";
        begin
            GRFQHeader.RESET;
            GRFQHeader.SETFILTER("PR Document Type", '<>%1', GRFQHeader."PR Document Type"::PC);
            GRFQHeader.SETRANGE("PR Date", StartDate, EndDate);
            GRFQHeader.SETFILTER(Status, '%1|%2|%3', GPRLine.Status::Released, GRFQHeader.Status::Closed, GRFQHeader.Status::"Pending Approval");
            if GRFQHeader.FINDSET then
                repeat
                    GPRLine.RESET;
                    GPRLine.SETRANGE("Document No.", GRFQHeader."No.");
                    // GPRLine.SETRANGE("No.", Pline."No.");//19.0.0.5
                    GPRLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5
                    // GPRLine.SETRANGE("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.5
                    // GPRLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.5
                    GPRLine.SETFILTER(Status, '%1|%2', GPRLine.Status::Released, GPRLine.Status::Closed);
                    GPRLine.SETRANGE(GPRLine."Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5>>
                    if GPRLine.FINDSET then
                        repeat
                            if (GPRLine.ConvertedtoOrder) then
                                BCalcPurchaseOrderForOnHold(Pline)
                            else
                                if (GPRLine.ConvertedtoQuote) then
                                    BCalcPurchaseQuoteForOnHold(Pline)
                                else
                                    GTotalBudgetOnHold += (GPRLine."Unit Cost (LCY)" * GPRLine.Quantity);
                        until GPRLine.NEXT = 0;
                until GRFQHeader.NEXT = 0;
        end;

     */
    procedure BCalcPurchaseOrderForUtilised(Pline: Record "Purchase Line");
    begin
        GPurchHdr.RESET;
        GPurchHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchHdr.FINDSET then
            repeat
                GPurchLine.RESET;
                GPurchLine.SETRANGE("Document No.", GPurchHdr."No.");
                // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.5
                // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.5
                GPurchLine.SETRANGE("Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5
                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
                // GPurchLine.SETRANGE("No.", Pline."No.");//19.0.0.5
                GPurchLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5
                GPurchLine.SETFILTER("Quantity Received", '<>0');
                if GPurchLine.FINDSET then
                    repeat
                        GTotalPurchaseLinesUtilised += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)";
                    until GPurchLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    procedure BCalcPurchaseOrderForOnHold(Pline: Record "Purchase Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
        GPurchLine.SETRANGE("PR No.", Pline."PR No.");
        GPurchLine.SETRANGE("PR Line No.", Pline."PR Line No.");
        // GPurchLine.SETRANGE("No.", Pline."No.");//19.0.0.5>>
        GPurchLine.SETRANGE("G/L Account No.", Pline."G/L Account No.");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", Pline."Shortcut Dimension 1 Code");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", Pline."Shortcut Dimension 2 Code");//19.0.0.5>>
        GPurchLine.SETRANGE(GPurchLine."Dimension Set ID", Pline."Dimension Set ID");//19.0.0.5>>
        if GPurchLine.FINDFIRST then
            if GPurchLine."Quantity Received" = 0 then
                GTotalBudgetOnHold += GPurchLine."Outstanding Amount (LCY)";
    end;

    procedure BCalcPurchaseQuoteForOnHold(Pline: Record "Purchase Line");
    var
        LQuoteConvertedToOrder: Boolean;
        LHighestAmt: Decimal;
        RFQComp: Record "RFQ Comparison";
    begin
        CLEAR(LQuoteConvertedToOrder);
        CLEAR(LHighestAmt);
        RFQComp.RESET;
        RFQComp.SETRANGE("PR No", PRLine."No.");
        RFQComp.SETRANGE(Status, RFQComp.Status::"Pending Approval");
        if RFQComp.FINDFIRST then
            GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
        GPurchLine.SETRANGE("PR No.", Pline."No.");
        GPurchLine.SETRANGE("PR Line No.", PRLine."Line No.");
        // GPurchLine.SETRANGE("No.", PRLine."No.");//19.0.0.5>>
        GPurchLine.SETRANGE("G/L Account No.", PRLine."G/L Account No.");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLine."Shortcut Dimension 1 Code");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLine."Shortcut Dimension 2 Code");//19.0.0.5>>
        GPurchLine.SETRANGE(GPurchLine."Dimension Set ID", PRLine."Dimension Set ID");//19.0.0.5>>
        if GPurchLine.FINDSET then
            GTotalBudgetOnHold += GPurchLine."Outstanding Amount (LCY)";
    end;

    procedure BCalcPurchaseOrderPR(PRLinePar: Record "PR Line");
    begin
        GPurchHdr.RESET;
        GPurchHdr.SETCURRENTKEY("Document Type", "Posting Date");
        GPurchHdr.SETRANGE("Document Type", GPurchHdr."Document Type"::Order);
        GPurchHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchHdr.FINDSET then
            repeat
                GPurchLine.RESET;
                GPurchLine.SETCURRENTKEY("Document Type", "Document No.", "No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                GPurchLine.SETRANGE("Document No.", GPurchHdr."No.");
                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
                // GPurchLine.SETRANGE("No.", PRLinePar."No.");//19.0.0.4>>
                GPurchLine.SETRANGE(GPurchLine."G/L Account No.", PRLinePar."G/L Account No.");//19.0.0.4>>
                // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLinePar."Shortcut Dimension 1 Code");//19.0.0.5>>
                // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLinePar."Shortcut Dimension 2 Code");//19.0.0.5>>
                GPurchLine.SETRANGE("Dimension Set ID", PRLinePar."Dimension Set ID");//19.0.0.5>>
                if GPurchLine.FINDSET then
                    repeat
                        GPurchLine.CALCFIELDS("PR In G/L", "G/L Total Amt for PR");
                        if GPurchLine."PR In G/L" then
                            GTotalPurchaseLines += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)" - GPurchLine."G/L Total Amt for PR"
                        else
                            GTotalPurchaseLines += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Amt. Rcd. Not Invoiced (LCY)";
                    until GPurchLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    procedure BCalcPurchaseReturnOrderTotalPR(PRLinePar: Record "PR Line");
    begin
        GPurchHdr.RESET;
        GPurchHdr.SETCURRENTKEY("Document Type", "Posting Date");
        GPurchHdr.SETRANGE("Document Type", GPurchLine."Document Type"::"Return Order");
        GPurchHdr.SETRANGE("Posting Date", StartDate, EndDate);
        if GPurchHdr.FINDSET then
            repeat
                GPurchLine.RESET;
                GPurchLine.SETCURRENTKEY("Document Type", "Document No.", "No.", "Shortcut Dimension 1 Code", "Shortcut Dimension 2 Code");
                GPurchLine.SETRANGE("Document No.", GPurchHdr."No.");
                GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::"Return Order");
                // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLinePar."Shortcut Dimension 1 Code");//19.0.0.5
                // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLinePar."Shortcut Dimension 2 Code");//19.0.0.5
                GPurchLine.SETFILTER("Dimension Set ID", '%1', PRLinePar."Dimension Set ID");//19.0.0.5
                // GPurchLine.SETRANGE("No.", PRLinePar."No.");//19.0.0.5
                GPurchLine.SETRANGE("G/L Account No.", PRLinePar."G/L Account No.");//19.0.0.5
                if GPurchLine.FINDSET then
                    repeat
                        GTotalReturn += GPurchLine."Outstanding Amount (LCY)" + GPurchLine."Return Shpd. Not Invd. (LCY)";
                    until GPurchLine.NEXT = 0;
            until GPurchHdr.NEXT = 0;
    end;

    /* procedure BCalcPurchaseReqTotalForOnHoldPR(PRLinePar: Record "PR Line");
    begin
        GRFQHeader.RESET;
        GRFQHeader.SETFILTER("PR Document Type", '<>%1', GRFQHeader."PR Document Type"::PC);
        GRFQHeader.SETRANGE("PR Date", StartDate, EndDate);
        GRFQHeader.SETFILTER(Status, '%1|%2|%3', GRFQHeader.Status::Released, GRFQHeader.Status::Closed, GRFQHeader.Status::"Pending Approval");
        GRFQHeader.SETFILTER("LOA Status", '%1|%2|%3', GRFQHeader.Status::Released, GRFQHeader.Status::Closed, GRFQHeader.Status::Open);
        if GRFQHeader.FINDSET then
            repeat
                GPRLine.RESET;
                GPRLine.SETRANGE("Document No.", GRFQHeader."No.");
                // GPRLine.SETRANGE("No.", PRLinePar."No.");//19.0.0.4>>
                GPRLine.SETRANGE("G/L Account No.", PRLinePar."G/L Account No.");//19.0.0.4>>
                // GPRLine.SETRANGE("Shortcut Dimension 1 Code", PRLinePar."Shortcut Dimension 1 Code");//19.0.0.5>>
                // GPRLine.SETRANGE("Shortcut Dimension 2 Code", PRLinePar."Shortcut Dimension 2 Code");//19.0.0.5>>
                GPRLine.SETRANGE("Dimension Set ID", PRLinePar."Dimension Set ID");//19.0.0.5>>
                if GPRLine.FINDSET then
                    repeat
                        if (GPRLine.ConvertedtoOrder) then
                            BCalcPurchaseOrderForOnHoldPR(GRFQHeader."No.", GPRLine)
                        else
                            if (GPRLine.ConvertedtoQuote) then
                                BCalcPurchaseQuoteForOnHoldPR(GRFQHeader."No.", GPRLine)
                            else
                                GTotalBudgetOnHold += (GPRLine."Unit Cost (LCY)" * GPRLine.Quantity);
                    until GPRLine.NEXT = 0;
            until GRFQHeader.NEXT = 0;
    end;
 */
    procedure BCalcPurchaseOrderForOnHoldPR(PRNo: Code[20]; PRLinePar: Record "PR Line");
    begin
        GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Order);
        GPurchLine.SETRANGE("Document No.", PRNo);
        GPurchLine.SETRANGE("Line No.", PRLinePar."Line No.");
        // GPurchLine.SETRANGE("No.", PRLinePar."No.");//19.0.0.4>>
        GPurchLine.SETRANGE("G/L Account No.", PRLinePar."G/L Account No.");//19.0.0.4>>
        // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLinePar."Shortcut Dimension 1 Code");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLinePar."Shortcut Dimension 2 Code");//19.0.0.5>>
        GPurchLine.SETRANGE("Dimension Set ID", PRLinePar."Dimension Set ID");//19.0.0.5>>
        if GPurchLine.FINDFIRST then
            if GPurchLine."Quantity Received" = 0 then
                GTotalBudgetOnHold += GPurchLine."Outstanding Amount (LCY)";
    end;

    procedure BCalcPurchaseQuoteForOnHoldPR(PRNo: Code[20]; PRLinepar: Record "PR Line");
    var
        LQuoteConvertedToOrder: Boolean;
        RFQComp: Record "RFQ Comparison";
    begin
        CLEAR(LQuoteConvertedToOrder);
        RFQComp.RESET;
        RFQComp.SETRANGE("PR No", PRNo);
        RFQComp.SETRANGE(Status, RFQComp.Status::"Pending Approval");
        if RFQComp.FINDFIRST then
            GPurchLine.RESET;
        GPurchLine.SETRANGE("Document Type", GPurchLine."Document Type"::Quote);
        GPurchLine.SETRANGE("PR No.", PRNo);
        GPurchLine.SETRANGE("PR Line No.", PRLinepar."Line No.");
        // GPurchLine.SETRANGE("No.", PRLinepar."No.");//19.0.0.4>>
        GPurchLine.SETRANGE("G/L Account No.", PRLinepar."G/L Account No.");//19.0.0.4>>
        // GPurchLine.SETRANGE("Shortcut Dimension 1 Code", PRLinepar."Shortcut Dimension 1 Code");//19.0.0.5>>
        // GPurchLine.SETRANGE("Shortcut Dimension 2 Code", PRLinepar."Shortcut Dimension 2 Code");//19.0.0.5>>
        GPurchLine.SETRANGE("Dimension Set ID", PRLinepar."Dimension Set ID");//19.0.0.5>>
        if GPurchLine.FINDSET then
            GTotalBudgetOnHold += GPurchLine."Outstanding Amount (LCY)";
    end;

    /* local procedure CheckDim(RFQHeaderPar: Record "PR Header");
    var
        PRLine2: Record "PR Line";
    begin
        PRLine2.RESET;
        PRLine2.SETRANGE("Document No.", RFQHeaderPar."No.");
        // PRLine2.SETFILTER(Type, '<>%1', PRLine2.Type::Description);//19.0.0.5
        PRLine2.SETFILTER(Type, '<>%1', PRLine2.Type::" ");//19.0.0.5
        if PRLine2.FINDSET then begin
            repeat
                if (RFQHeaderPar.Status = RFQHeaderPar.Status::Open) then begin
                    CheckDimComb(PRLine2);
                    CheckDimValuePosting(RFQHeaderPar, PRLine2);
                end
            until PRLine2.NEXT = 0;
        end;
    end;

    local procedure CheckDimComb(PRLine: Record "PR Line");
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        if PRLine."Line No." = 0 then
            if not DimMgt.CheckDimIDComb(RFQHeader."Dimension Set ID") then
                ERROR(
                  Text032, RFQHeader."No.", DimMgt.GetDimCombErr);

        if PRLine."Line No." <> 0 then
            if not DimMgt.CheckDimIDComb(PRLine."Dimension Set ID") then
                ERROR(
                  Text033,
                  RFQHeader."No.", PRLine."Line No.", DimMgt.GetDimCombErr);
    end;

    local procedure CheckDimValuePosting(RFQHeaderPar: Record "PR Header"; var PRLine2: Record "PR Line");
    var
        DimMgt: Codeunit DimensionManagement;
        TableIDArr: array[10] of Integer;
        NumberArr: array[10] of Code[20];
    begin
        if PRLine2."Line No." = 0 then begin
            TableIDArr[1] := DATABASE::Vendor;
            NumberArr[1] := RFQHeaderPar."Suggested Vendor";
            TableIDArr[2] := DATABASE::"Salesperson/Purchaser";
            NumberArr[2] := RFQHeaderPar."Purchaser Code";

            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, RFQHeaderPar."Dimension Set ID") then
                ERROR(
                  Text034,
                  RFQHeaderPar."No.", DimMgt.GetDimValuePostingErr);
        end else begin
            TableIDArr[1] := DimMgt.TypeToTableID4(PRLine2.Type);
            NumberArr[1] := PRLine2."No.";

            if not DimMgt.CheckDimValuePosting(TableIDArr, NumberArr, PRLine2."Dimension Set ID") then
                ERROR(
                  Text035,
                  RFQHeaderPar."No.", PRLine2."Line No.", DimMgt.GetDimValuePostingErr);
        end;

    end; */

    procedure ArchivePR1(var PRHdr: Record "PR Header");
    var
        PRLine: Record "PR Line";
        PurchaseHdr: Record "Purchase Header" temporary;
        PurchaseLine: Record "Purchase Line" temporary;
        ArchiveManagement: Codeunit ArchiveManagement;
    begin
        if PRHdr.FindSet() then begin
            PurchaseHdr.INIT;
            PurchaseHdr."Document Type" := PurchaseHdr."Document Type"::PR;
            PurchaseHdr."No." := PRHdr."No.";
            PurchaseHdr."No. Series" := PRHdr."No. series";
            PurchaseHdr."Document Date" := PRHdr."PR Date";
            PurchaseHdr."Your Reference" := PRHdr.Requester;
            PurchaseHdr.INSERT(false);
            PurchaseHdr."Buy-from Vendor No." := GVend."No.";
            PurchaseHdr.COPYLINKS(PRHdr);
            PurchaseHdr."Shortcut Dimension 1 Code" := PRHdr."Shortcut Dimension 1 Code";
            PurchaseHdr."Shortcut Dimension 2 Code" := PRHdr."Shortcut Dimension 2 Code";
            PurchaseHdr."Dimension Set ID" := PRHdr."Dimension Set ID";//19.0.0.5
            PurchaseHdr."PR No." := PRHdr."No.";
            PurchaseHdr."USERID PR to PO" := USERID;
            PurchaseHdr."Purchaser Code" := PRHdr."Purchaser Code";
            PurchaseHdr."Your Reference" := PRHdr.Requester;
            if PRHdr."Currency Code" <> '' then begin
                PurchaseHdr."Currency Code" := PRHdr."Currency Code";
            end;
            PurchaseHdr."Expected Receipt Date" := PRHdr."Due Date";
            PurchaseHdr."Your Reference" := PRHdr.Requester;
            PurchaseHdr.MODIFY(false);

            PRLine.Reset();
            PRLine.SetRange("Document No.", PRHdr."No.");
            if PRLine.FindSet() then
                repeat
                    PurchaseLine.INIT;
                    PurchaseLine."Document Type" := PurchaseLine."Document Type"::PR;
                    PurchaseLine."Document No." := PurchaseHdr."No.";
                    PurchaseLine."Line No." := PRLine."Line No.";
                    PurchaseLine.INSERT(false);
                    if PRLine.Type = PRLine.Type::Item then
                        PurchaseLine.Type := PurchaseLine.Type::Item
                    else
                        if (PRLine.Type = PRLine.Type::"G/L Account") then
                            PurchaseLine.Type := PurchaseLine.Type::"G/L Account"
                        else
                            if (PRLine.Type = PRLine.Type::"Fixed Asset") then
                                PurchaseLine.Type := PurchaseLine.Type::"Fixed Asset"
                            else
                                // if (PRLine.Type = PRLine.Type::Description) then//19.0.0.5
                                if (PRLine.Type = PRLine.Type::" ") then//19.0.0.5
                                    PurchaseLine.Type := PurchaseLine.Type::" ";

                    PurchaseLine."No." := PRLine."No.";
                    PurchaseLine."Location Code" := PRLine."Delivery Location";
                    PurchaseLine."Unit of Measure Code" := PRLine."Unit of  Measure";
                    PurchaseLine."Direct Unit Cost" := PRLine."Unit Cost";
                    PurchaseLine.Quantity := PRLine.Quantity;
                    PurchaseLine.Description := PRLine.Description;
                    PurchaseLine."Description 2" := PRLine."Description 2";
                    PurchaseLine."PR No." := PRLine."Document No.";
                    PurchaseLine."PR Line No." := PRLine."Line No.";
                    if PurchaseLine."G/L Account No." = '' then
                        PurchaseLine."G/L Account No." := PRLine."G/L Account No.";
                    PurchaseLine."WBS ID" := PRLine."WBS ID";
                    PurchaseLine."Activity ID" := PRLine."Activity ID";
                    PurchaseLine.Remarks := PRLine.Remarks;
                    PurchaseLine."Reason for Shortlist" := PRLine."Reason for Shortlist";
                    PurchaseLine.MODIFY(false);
                until PRLine.NEXT = 0;
        end;
        ArchiveManagement.ArchivePurchDocument(PurchaseHdr);

        MESSAGE('PR Archived.');
    end;
}