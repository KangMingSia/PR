codeunit 27003011 "Document Approval PR-IBIZRFQ"
{

    Permissions = TableData "Approval Entry" = rimd;

    trigger OnRun();
    begin
    end;

    var
        AddApproversTemp: Record "Additional Approvers" temporary;
        IsOpenStatusSet: Boolean;
        Currency: Record Currency;
        DocApp: Codeunit "Approvals Management-IBIZRFQ";
        DocAppmail: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
        GTotalAmt: Decimal;
        GLSetup: Record "General Ledger Setup";
        PRFunc: Codeunit "PR Functions-IBIZRFQ";
        Text001: Label 'RFQ %2 requires further approval to make %1.\\Approval request entries have been created.';
        Text002: Label '%1 %2 approval request cancelled.';
        Text003: Label '%1 %2 has been automatically approved and released.';
        Text004: Label 'Approval Setup not found.';
        Text005: Label 'User ID %1 does not exist in the Document Approval Setup RFQ.';
        Text006: Label 'Approver ID %1 does not exist in the User Setup table.';
        Text007: Label '%1 for %2  does not exist in the User Setup table.';
        Text008: Label 'User ID %1 does not exist in the User Setup table for %2 %3.';
        Text013: Label 'Document %1 must be approved and released before you can perform this action.';
        Text010: Label 'Approver not found.';
        Text014: Label 'The %1 approval entries have now been cancelled.';
        Text015: Label 'The %1 %2 does not have any Lines.';
        Text022: Label 'There has to be a %1 on %2 %3.';
        Text023: Label '"A template with a blank Approval Type or with Limit Type ""Credit Limit"", must have additional approvers. "';
        Text024: Label '%1 are only for purchase request orders.';
        Text025: Label '%1 is not a valid limit type for %2 %3.';
        Text026: Label '%1 is only a valid limit type for %2.';
        Text027: Label 'When Approval Type is blank, additional approvers must be added to the template.';
        Text028: Label 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order';
        Text100: Label 'S-QUOTE';
        Text101: Label 'Sales Quote Approval';
        Text102: Label 'S-ORDER';
        Text103: Label 'Sales Order Approval';
        Text104: Label 'S-INVOICE';
        Text105: Label 'Sales Invoice Approval';
        Text106: Label 'S-CREDIT MEMO';
        Text107: Label 'Sales Credit Memo Approval';
        Text108: Label 'S-RETURN ORDER';
        Text109: Label 'Sales Return Order Approval';
        Text110: Label 'S-BLANKET ORDER';
        Text111: Label 'Sales Blanket Order Approval';
        Text112: Label 'P-QUOTE';
        Text113: Label 'Purchase Quote Approval';
        Text114: Label 'P-ORDER';
        Text115: Label 'Purchase Order Approval';
        Text116: Label 'P-INVOICE';
        Text117: Label 'Purchase Invoice Approval';
        Text118: Label 'P-CREDIT MEMO';
        Text119: Label 'Purchase Credit Memo Approval';
        Text120: Label 'P-RETURN ORDER';
        Text121: Label 'Purchase Return Order Approval';
        Text122: Label 'P-BLANKET ORDER';
        Text123: Label 'Purchase Blanket Order Approval';
        Text124: Label 'S-O-CREDITLIMIT';
        Text125: Label 'Sales Order Credit Limit Apporval';
        Text126: Label 'S-I-CREDITLIMIT';
        Text127: Label 'Sales Invoice Credit Limit Apporval';
        Text128: Label '%1 %2 has been automatically approved. Status changed to Pending Prepayment.';
        Text129: Label 'No Approval Templates are enabled for document type %1.';
        Text130: Label 'The approval request cannot be canceled because the order has already been released. To  modify this order, you must reopen it.';
        GText005: Label 'RFQ Comparision %1 has been reopened';
        GText006: Label 'RFQ Comparision %1 has been reopened';
        NewEntry: Integer;
        RFQHeader: Record "RFQ Comparison";

    procedure SendPurchaseReqApproval(var RFQHeader: Record "RFQ Comparison"; TotalBudget: Decimal): Boolean;
    var
        TemplateRec: Record "Approval Templates";
        ApprovalSetup: Record "Approval Setup";
        MessageType: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval;
    begin
        with RFQHeader do begin
            if Status <> Status::Open then
                exit(false);

            if not ApprovalSetup.GET then
                ERROR(Text004);
            if not PurchaseReqLinesexist(RFQHeader) then
                ERROR(Text015, "No.");

            TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
            TemplateRec.SETRANGE("Table ID", DATABASE::"PR Header");
            TemplateRec.SETRANGE("Document Type", TemplateRec."Document Type"::PR);
            TemplateRec.SETRANGE("No. series", RFQHeader."No. series");
            TemplateRec.SETRANGE("LOA Approval", false);
            TemplateRec.SETRANGE(Enabled, true);
            if TemplateRec.FIND('-') then begin
                repeat
                    if TemplateRec."Direct Approver" then begin
                        if not FindApproverPurchaseReqDirect(RFQHeader, ApprovalSetup, TemplateRec) then
                            ERROR(Text010);
                    end else begin
                        if not FindApproverPurchaseReq(RFQHeader, ApprovalSetup, TemplateRec) then
                            ERROR(Text010);

                    end;
                until TemplateRec.NEXT = 0;
                FinishApprovalEntryPurchaseReq(RFQHeader, ApprovalSetup, MessageType, TotalBudget);
                case MessageType of
                    MessageType::AutomaticPrePayment:
                        MESSAGE(Text128, RFQHeader."No.");
                    MessageType::AutomaticRelease:
                        MESSAGE(Text003, RFQHeader."No.");
                    MessageType::RequiresApproval:
                        MESSAGE(Text001, RFQHeader."No.");
                end;
            end else
                ERROR(STRSUBSTNO(Text129, 'PR'));
        end;
    end;

    /*  procedure SendPurchaseReqApprovalLOA(var RFQHeader: Record "RFQ Comparison"; Totalbudget: Decimal): Boolean;
     var
         TemplateRec: Record "Approval Templates";
         ApprovalSetup: Record "Approval Setup";
         MessageType: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval;
     begin
         with RFQHeader do begin
             if "LOA Status" <> "LOA Status"::Open then
                 exit(false);

             if not ApprovalSetup.GET then
                 ERROR(Text004);
             if not PurchaseReqLinesexist(RFQHeader) then
                 ERROR(Text015,"No.");

             TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
             TemplateRec.SETRANGE("Table ID", DATABASE::"PR Header");
             TemplateRec.SETRANGE("Document Type", TemplateRec."Document Type"::PR);
             TemplateRec.SETRANGE("No. series", RFQHeader."No. series");
             TemplateRec.SETRANGE("LOA Approval", true);
             TemplateRec.SETRANGE(Enabled, true);
             if TemplateRec.FIND('-') then begin
                 repeat
                     if TemplateRec."Direct Approver" then begin
                         if not FindApproverPurchaseReqDirLOA(RFQHeader, ApprovalSetup, TemplateRec) then
                             ERROR(Text010);
                     end else begin
                         if not FindApproverPurchaseReqLOA(RFQHeader, ApprovalSetup, TemplateRec) then
                             ERROR(Text010);

                     end;
                 until TemplateRec.NEXT = 0;
                 FinishApprovalEntryPurchReqLOA(RFQHeader, ApprovalSetup, MessageType, Totalbudget);
                 case MessageType of
                     MessageType::AutomaticPrePayment:
                         MESSAGE(Text128, RFQHeader."No.");
                     MessageType::AutomaticRelease:
                         MESSAGE(Text003, RFQHeader."No.");
                     MessageType::RequiresApproval:
                         MESSAGE(Text001, RFQHeader."No.");
                 end;
             end else
                 ERROR(STRSUBSTNO(Text129, 'PR'));
         end;
     end;
  */
    procedure PurchaseReqLinesexist(var RFQHeader: Record "RFQ Comparison"): Boolean;
    var
        PRLine: Record "PR Line";
    begin
        CLEAR(GTotalAmt);
        RFQHeader.RESET;
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", RFQHeader."No.");
        if PRLine.FINDSET then
            repeat
                GTotalAmt += PRLine.Amount;
            until PRLine.NEXT = 0;


        RFQHeader.RESET;
        PRLine.RESET;
        PRLine.SETRANGE("Document No.", RFQHeader."No.");
        if PRLine.FINDSET then
            exit(true);
    end;

    procedure FindApproverPurchaseReq(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[50];
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
    begin

        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcPurchaseReqDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);

        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if RFQHeader."Co-ordinator" <> '' then begin
                        case AppTemplate."Limit Type" of
                            AppTemplate."Limit Type"::"Approval Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                          DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                        ApproverId := UserSetup."Approver ID";
                                        if not UserSetup."Unlimited Purchase Approval" and
                                           ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                           (UserSetup."Purchase Amount Approval Limit" = 0))
                                        then begin
                                            UserSetup.RESET;
                                            UserSetup.SETCURRENTKEY("User ID");
                                            UserSetup.SETRANGE("User ID", ApproverId);
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            repeat
                                                if not UserSetup.FIND('-') then
                                                    ERROR(Text006, ApproverId);
                                                ApproverId := UserSetup."User ID";
                                                MakeApprovalEntryPurchaseReq(
                                                  DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                  AppTemplate, 0);
                                                UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            until UserSetup."Unlimited Purchase Approval" or
                                                  ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                                  (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                                  (UserSetup."User ID" = UserSetup."Approver ID")
                                        end;
                                    end;
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                              DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                              AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                            AppTemplate."Limit Type"::"Request Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator");
                                    ApproverId := UserSetup."User ID";
                                    MakeApprovalEntryPurchaseReq(
                                      DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                      ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                      AppTemplate, 0);
                                    if not UserSetup."Unlimited Request Approval" and
                                             ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                              (UserSetup."Request Amount Approval Limit" = 0))
                                    then
                                        repeat
                                            UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            if not UserSetup.FIND('-') then
                                                ERROR(Text005, USERID);
                                            ApproverId := UserSetup."User ID";
                                            MakeApprovalEntryPurchaseReq(
                                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                             ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                             AppTemplate, 0);
                                        until UserSetup."Unlimited Request Approval" or
                                                    ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                                     (UserSetup."Request Amount Approval Limit" <> 0)) or
                                                    (UserSetup."User ID" = UserSetup."Approver ID");
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                            AppTemplate."Limit Type"::"No Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    end;
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                        end;
                    end else
                        ERROR(LText002)
                end;
            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;

                            end;
                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);


                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryPurchaseReq(
                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                               AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);

                end;
        end;
        exit(true);
    end;

    procedure FindApproverPurchaseReqLOA(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[50];
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcPurchaseReqDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);

        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if RFQHeader."Co-ordinator" <> '' then begin
                        case AppTemplate."Limit Type" of
                            AppTemplate."Limit Type"::"Approval Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                          DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                        ApproverId := UserSetup."Approver ID";
                                        if not UserSetup."Unlimited Request Approval" and
                                           ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                           (UserSetup."Purchase Amount Approval Limit" = 0))
                                        then begin
                                            UserSetup.RESET;
                                            UserSetup.SETCURRENTKEY("User ID");
                                            UserSetup.SETRANGE("User ID", ApproverId);
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            repeat
                                                if not UserSetup.FIND('-') then
                                                    ERROR(Text006, ApproverId);
                                                ApproverId := UserSetup."User ID";
                                                MakeApprovalEntryPurchReqLOA(
                                                  DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                  AppTemplate, 0);
                                                UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            until UserSetup."Unlimited Request Approval" or
                                                  ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                                  (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                                  (UserSetup."User ID" = UserSetup."Approver ID")
                                        end;
                                    end;
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchReqLOA(
                                              DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                              AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                            AppTemplate."Limit Type"::"Request Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator");
                                    ApproverId := UserSetup."User ID";
                                    MakeApprovalEntryPurchReqLOA(
                                      DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                      ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                      AppTemplate, 0);
                                    if not UserSetup."Unlimited Request Approval" and
                                             ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                              (UserSetup."Request Amount Approval Limit" = 0))
                                    then
                                        repeat
                                            UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            if not UserSetup.FIND('-') then
                                                ERROR(Text005, USERID);
                                            ApproverId := UserSetup."User ID";
                                            MakeApprovalEntryPurchReqLOA(
                                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                             ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                             AppTemplate, 0);
                                        until UserSetup."Unlimited Request Approval" or
                                                    ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                                     (UserSetup."Request Amount Approval Limit" <> 0)) or
                                                    (UserSetup."User ID" = UserSetup."Approver ID");
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchReqLOA(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                            AppTemplate."Limit Type"::"No Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    end;
                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchReqLOA(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                        end;
                    end else
                        ERROR(LText002)
                end;
            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Purchaser Code",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;

                            end;
                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);


                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryPurchReqLOA(
                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                               AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);

                end;
        end;
        exit(true);
    end;

    procedure FindApproverPurchaseReqDirect(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[20];
        FirstEntry: Boolean;
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcPurchaseReqDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);

        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if RFQHeader."Co-ordinator" <> '' then begin
                        case AppTemplate."Limit Type" of
                            AppTemplate."Limit Type"::"Approval Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")

                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);

                                        ApproverId := UserSetup."Approver ID";
                                        if not UserSetup."Unlimited Purchase Approval" and
                                           ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                           (UserSetup."Purchase Amount Approval Limit" = 0))
                                        then begin
                                            UserSetup.RESET;
                                            UserSetup.SETCURRENTKEY("User ID");
                                            UserSetup.SETRANGE("User ID", ApproverId);
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            if UserSetup.FINDFIRST then begin
                                                FirstEntry := true;
                                                repeat
                                                    if not FirstEntry then begin
                                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                        if not UserSetup.FIND('-') then
                                                            ERROR(Text006, ApproverId);
                                                    end;
                                                    FirstEntry := false;
                                                until (UserSetup."Unlimited Purchase Approval") or
                                                  ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                                  (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                                  (UserSetup."User ID" = UserSetup."Approver ID");
                                                ApproverId := UserSetup."User ID";
                                                MakeApprovalEntryPurchaseReq(
                                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                   AppTemplate, 0);

                                            end else
                                                ERROR(Text006, ApproverId);
                                        end;
                                    end;

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"Request Limits":
                                begin

                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator");

                                    UserSetup.RESET;
                                    UserSetup.SETRANGE("User ID", USERID);
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(Text005, USERID);
                                    ApproverId := UserSetup."User ID";
                                    MakeApprovalEntryPurchaseReq(
                                       DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                       AppTemplate, 0);

                                    if not UserSetup."Unlimited Request Approval" and
                                       ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                        (UserSetup."Request Amount Approval Limit" = 0))
                                    then
                                        repeat
                                            UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            if not UserSetup.FIND('-') then
                                                ERROR(Text005, USERID);
                                            ApproverId := UserSetup."User ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until UserSetup."Unlimited Request Approval" or
                                              ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                               (UserSetup."Request Amount Approval Limit" <> 0)) or
                                              (UserSetup."User ID" = UserSetup."Approver ID");

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                              AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"No Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                        DocApp.CheckAddApprovers(AppTemplate);
                                        AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                        if AddApproversTemp.FIND('-') then
                                            repeat
                                                ApproverId := AddApproversTemp."Approver ID";
                                                MakeApprovalEntryPurchaseReq(
                                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                  AppTemplate, 0);
                                            until AddApproversTemp.NEXT = 0;
                                    end;
                                end;
                        end;
                    end;
                end;

            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                    ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                    AppTemplate, 0);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then begin
                                    UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                    if UserSetup.FINDFIRST then begin
                                        FirstEntry := true;
                                        repeat
                                            if not FirstEntry then begin
                                                UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                if not UserSetup.FIND('-') then
                                                    ERROR(Text005, USERID);
                                            end;
                                            FirstEntry := false;
                                        until UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    end else
                                        ERROR(Text006, ApproverId);
                                end;

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryPurchaseReq(
                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                              AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);
                end;
        end;

        exit(true);
    end;

    procedure FindApproverPurchaseReqDirLOA(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[20];
        FirstEntry: Boolean;
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcPurchaseReqDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);

        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if RFQHeader."Co-ordinator" <> '' then begin
                        case AppTemplate."Limit Type" of
                            AppTemplate."Limit Type"::"Approval Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")

                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                           DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);

                                        ApproverId := UserSetup."Approver ID";
                                        if not UserSetup."Unlimited Purchase Approval" and
                                           ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                           (UserSetup."Purchase Amount Approval Limit" = 0))
                                        then begin
                                            UserSetup.RESET;
                                            UserSetup.SETCURRENTKEY("User ID");
                                            UserSetup.SETRANGE("User ID", ApproverId);
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            if UserSetup.FINDFIRST then begin
                                                FirstEntry := true;
                                                repeat
                                                    if not FirstEntry then begin
                                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                        if not UserSetup.FIND('-') then
                                                            ERROR(Text006, ApproverId);
                                                    end;
                                                    FirstEntry := false;
                                                until (UserSetup."Unlimited Purchase Approval") or
                                                  ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                                  (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                                  (UserSetup."User ID" = UserSetup."Approver ID");
                                                ApproverId := UserSetup."User ID";
                                                MakeApprovalEntryPurchReqLOA(
                                                   DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                   AppTemplate, 0);

                                            end else
                                                ERROR(Text006, ApproverId);
                                        end;
                                    end;

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchReqLOA(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"Request Limits":
                                begin

                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator");

                                    UserSetup.RESET;
                                    UserSetup.SETRANGE("User ID", USERID);
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(Text005, USERID);
                                    ApproverId := UserSetup."User ID";
                                    MakeApprovalEntryPurchReqLOA(
                                       DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                       AppTemplate, 0);

                                    if not UserSetup."Unlimited Request Approval" and
                                       ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                        (UserSetup."Request Amount Approval Limit" = 0))
                                    then
                                        repeat
                                            UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            if not UserSetup.FIND('-') then
                                                ERROR(Text005, USERID);
                                            ApproverId := UserSetup."User ID";
                                            MakeApprovalEntryPurchReqLOA(
                                               DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until UserSetup."Unlimited Request Approval" or
                                              ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                               (UserSetup."Request Amount Approval Limit" <> 0)) or
                                              (UserSetup."User ID" = UserSetup."Approver ID");

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchReqLOA(
                                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                              AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"No Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQHeader."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQHeader."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                        DocApp.CheckAddApprovers(AppTemplate);
                                        AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                        if AddApproversTemp.FIND('-') then
                                            repeat
                                                ApproverId := AddApproversTemp."Approver ID";
                                                MakeApprovalEntryPurchReqLOA(
                                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                  AppTemplate, 0);
                                            until AddApproversTemp.NEXT = 0;
                                    end;
                                end;
                        end;
                    end;
                end;

            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                    ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                    AppTemplate, 0);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then begin
                                    UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                    if UserSetup.FINDFIRST then begin
                                        FirstEntry := true;
                                        repeat
                                            if not FirstEntry then begin
                                                UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                if not UserSetup.FIND('-') then
                                                    ERROR(Text005, USERID);
                                            end;
                                            FirstEntry := false;
                                        until UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    end else
                                        ERROR(Text006, ApproverId);
                                end;

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchReqLOA(
                                 DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchReqLOA(
                                         DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryPurchReqLOA(
                             DATABASE::"PR Header", RFQHeader."No.", RFQHeader."Co-ordinator",
                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                              AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);
                end;
        end;

        exit(true);
    end;

    procedure MakeApprovalEntryPurchaseReq(TableID: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[50]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[50]; ApprovalCode: Code[20]; UserSetup: Record "Document Approval Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; AppTemplate: Record "Approval Templates"; ExeedAmountLCY: Decimal);
    var
        ApprovalEntry: Record "Approval Entry";
        NewSequenceNo: Integer;
    begin
        with ApprovalEntry do begin
            if FINDLAST then
                NewEntry := "Entry No." + 1
            else
                NewEntry := 1;
            "Entry No." := NewEntry;
            SETRANGE("Table ID", TableID);
            SETRANGE("Document Type", "PR Document Type"::PR);
            SETRANGE("Document No.", DocNo);
            if FIND('+') then
                NewSequenceNo := "Sequence No." + 1
            else
                NewSequenceNo := 1;
            "Table ID" := TableID;
            // "Document Type" := "PR Document Type"::PR;//Version 19.0.0.0>>
            "Document Type" := "Document Type"::PR;//Version 19.0.0.0>>
            "Document No." := DocNo;
            if RFQHeader.GET(DocNo) then
                ApprovalEntry."Record ID to Approve" := RFQHeader.RECORDID;

            "Sequence No." := NewSequenceNo;
            "Approval Code" := ApprovalCode;
            "Sender ID" := USERID;
            Amount := ApprovalAmount;
            "Amount (LCY)" := ApprovalAmountLCY;
            "Approver ID" := ApproverId;
            if ApproverId = USERID then
                Status := Status::Approved
            else
                Status := Status::Created;
            "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
            "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            "Last Modified By User ID" := USERID;
            "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
            "Approval Type" := AppTemplate."Approval Type";
            "Limit Type" := AppTemplate."Limit Type";
            "Available Credit Limit (LCY)" := ExeedAmountLCY;
            "Entry No." := NewEntry;
            INSERT;
        end;
    end;

    procedure MakeApprovalEntryPurchReqLOA(TableID: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[50]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[50]; ApprovalCode: Code[20]; UserSetup: Record "Document Approval Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; AppTemplate: Record "Approval Templates"; ExeedAmountLCY: Decimal);
    var
        ApprovalEntry: Record "Approval Entry";
        NewSequenceNo: Integer;
    begin
        with ApprovalEntry do begin
            if FINDLAST then
                NewEntry := "Entry No." + 1
            else
                NewEntry := 1;

            SETRANGE("Table ID", TableID);
            SETRANGE("Document Type", "PR Document Type"::PR);
            SETRANGE("Document No.", DocNo);
            if FIND('+') then
                NewSequenceNo := "Sequence No." + 1
            else
                NewSequenceNo := 1;

            "Entry No." := NewEntry;
            if RFQHeader.GET(DocNo) then
                ApprovalEntry."Record ID to Approve" := RFQHeader.RECORDID;
            "Table ID" := TableID;
            "Document Type" := "PR Document Type"::PR;
            "Document No." := DocNo;
            "Salespers./Purch. Code" := COPYSTR(SalespersonPurchaser, 1, 19);
            "Sequence No." := NewSequenceNo;
            "Approval Code" := ApprovalCode;
            "Sender ID" := USERID;
            Amount := ApprovalAmount;
            "Amount (LCY)" := ApprovalAmountLCY;
            "Approver ID" := ApproverId;
            if ApproverId = USERID then
                Status := Status::Approved
            else
                Status := Status::Created;
            "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
            "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            "Last Modified By User ID" := USERID;
            "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
            "Approval Type" := AppTemplate."Approval Type";
            "Limit Type" := AppTemplate."Limit Type";
            "Available Credit Limit (LCY)" := ExeedAmountLCY;
            INSERT;
        end;
    end;

    procedure CalcPurchaseReqDocAmount(RFQHeader: Record "RFQ Comparison"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    var
        LPRLine: Record "PR Line";
    begin
        LPRLine.RESET;
        LPRLine.SETRANGE("Document No.", RFQHeader."No.");
        if LPRLine.FINDSET then
            repeat
                ApprovalAmount += LPRLine.Amount;
                ApprovalAmountLCY += LPRLine.Amount;
            until LPRLine.NEXT = 0;
    end;

    procedure FinishApprovalEntryPurchaseReq(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; var MessageID: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval; TotalBudget: Decimal);
    var
        DocReleased: Boolean;
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
        PRLine: Record "PR Line";
    begin
        DocReleased := false;
        with ApprovalEntry do begin
            INIT;
            SETRANGE("Table ID", DATABASE::"PR Header");
            SETRANGE("Document Type", ApprovalEntry."PR Document Type"::PR);
            SETRANGE("Document No.", RFQHeader."No.");
            SETRANGE(Status, Status::Created);
            if FINDSET(true, false) then
                repeat
                    if "Sender ID" = "Approver ID" then begin
                        Status := Status::Approved;
                        MODIFY;
                    end else
                        if not IsOpenStatusSet then begin
                            Status := Status::Open;
                            MODIFY;
                            IsOpenStatusSet := true;
                            if ApprovalSetup.Approvals then
                                ApprovalsMgtNotification.SendRFQCApprovalsMail(RFQHeader, ApprovalEntry, TotalBudget);
                        end;
                until NEXT = 0;

            if not IsOpenStatusSet then begin
                SETRANGE(Status);
                FINDLAST;
                DocReleased := ApprovalRelease(ApprovalEntry, RFQHeader);
            end;

            if DocReleased then begin
                MessageID := MessageID::AutomaticRelease;
            end else begin
                RFQHeader.Status := RFQHeader.Status::"Pending Approval";
                RFQHeader.MODIFY(true);
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", RFQHeader."No.");
                if PRLine.FINDSET then
                    repeat
                        PRLine.Status := PRLine.Status::"Pending Approval";
                        PRLine.MODIFY;
                    until PRLine.NEXT = 0;
                MessageID := MessageID::RequiresApproval;
            end;
        end;
    end;

    procedure ApprovalRelease(ApprovalEntry: Record "Approval Entry"; RFQHeader: Record "RFQ Comparison"): Boolean;
    var
        NextApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalEntry.Status := ApprovalEntry.Status::Approved;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            NextApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
            NextApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            NextApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            NextApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            NextApprovalEntry.SETFILTER(Status, '%1|%2', NextApprovalEntry.Status::Created, NextApprovalEntry.Status::Open);
            if NextApprovalEntry.FIND('-') then begin
                if NextApprovalEntry.Status = NextApprovalEntry.Status::Open then
                    exit(false)
                else begin
                    NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
                    NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
                    NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    NextApprovalEntry."Last Modified By User ID" := USERID;
                    NextApprovalEntry.MODIFY;
                    ApprovalSetup.GET;
                    if ApprovalSetup.Approvals then
                        ApprovalsMgtNotification.SendRFQCApprovalsMail(RFQHeader, NextApprovalEntry, 0);
                    exit(false);
                end;
            end else begin
                if ApprovalSetup.GET and ApprovalSetup.Approvals then //begin
                                                                      // if RFQHeader. = RFQHeader."PR Document Type"::PC then
                    ApprovalsMgtNotification.SendRFQPCApprovedMail(RFQHeader, ApprovalEntry);
                //    ApprovalsMgtNotification.SendPRPCApprovedMail(RFQHeader, ApprovalEntry);
                // end;
                PRFunc.ReleaseRFQDocAfterApprove(RFQHeader);
                exit(true);
            end;
        end;
    end;


    procedure RejectRelease(ApprovalEntry: Record "Approval Entry");
    var
        RFQHeader: Record "RFQ Comparison";
        PRLine: Record "PR Line";
        ApprovalSetup: Record "Approval Setup";
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalSetup.GET;
            RFQHeader.RESET;
            RFQHeader.SETRANGE("No.", ApprovalEntry."Document No.");
            if RFQHeader.FINDFIRST then;

            ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            if ApprovalSetup.Rejections then
                DocAppmail.SendRFQRejectionsMail(RFQHeader, ApprovalEntry);

            ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
            ApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            ApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
            if ApprovalEntry.FIND('-') then
                repeat
                    ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
                    ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    ApprovalEntry."Last Modified By User ID" := USERID;
                    ApprovalEntry.MODIFY;
                until ApprovalEntry.NEXT = 0;

            RFQHeader.Status := RFQHeader.Status::Open;
            RFQHeader.MODIFY;
            PRLine.RESET;
            PRLine.SETRANGE("Document No.", RFQHeader."No.");
            if PRLine.FINDSET then
                repeat
                    PRLine.Status := PRLine.Status::Open;
                    PRLine.MODIFY;
                until PRLine.NEXT = 0;

            MESSAGE(GText005, RFQHeader."No.");
        end;
    end;

    procedure RejectReleaseLOA(ApprovalEntry: Record "Approval Entry");
    var
        RFQHeader: Record "RFQ Comparison";
        PRLine: Record "PR Line";
        ApprovalSetup: Record "Approval Setup";
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalSetup.GET;
            RFQHeader.RESET;
            RFQHeader.SETRANGE("No.", ApprovalEntry."Document No.");
            if RFQHeader.FINDFIRST then;

            ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            if ApprovalSetup.Rejections then
                DocAppmail.SendRFQRejectionsMail(RFQHeader, ApprovalEntry);

            ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
            ApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            ApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
            if ApprovalEntry.FIND('-') then
                repeat
                    ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
                    ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    ApprovalEntry."Last Modified By User ID" := USERID;
                    ApprovalEntry.MODIFY;
                until ApprovalEntry.NEXT = 0;

            RFQHeader."LOA Status" := RFQHeader."LOA Status"::Open;
            RFQHeader.MODIFY;
            MESSAGE(GText005, RFQHeader."No.");
        end;
    end;

    procedure RejectReleaseRFQ(ApprovalEntry: Record "Approval Entry"; totalbudget: Decimal);
    var
        RFQComp: Record "RFQ Comparison";
        POLine: Record "Purchase Line";
        ApprovalSetup: Record "Approval Setup";
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalSetup.GET;
            RFQComp.RESET;
            RFQComp.SETRANGE("No.", ApprovalEntry."Document No.");
            if RFQComp.FINDFIRST then;

            ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            if ApprovalSetup.Rejections then
                DocAppmail.SendRFQCRejectionsMail(RFQComp, ApprovalEntry, totalbudget);

            ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
            ApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            ApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
            if ApprovalEntry.FIND('-') then
                repeat
                    ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
                    ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    ApprovalEntry."Last Modified By User ID" := USERID;
                    ApprovalEntry.MODIFY;
                until ApprovalEntry.NEXT = 0;

            RFQComp.Status := RFQComp.Status::Open;
            RFQComp.MODIFY;
            MESSAGE(GText006, RFQComp."No.");
        end;
    end;

    procedure DelegateRelease(ApprovalEntry: Record "Approval Entry");
    var
        UserSetup: Record "User Setup";
        DocumentApprovalSetup: Record "Document Approval Setup";
    begin
        DocumentApprovalSetup.SETRANGE("User ID", ApprovalEntry."Approver ID");
        if not DocumentApprovalSetup.FIND('-') then
            ERROR(Text005, ApprovalEntry."Approver ID");

        if DocumentApprovalSetup.Substitute <> '' then begin
            DocumentApprovalSetup.SETRANGE("User ID", DocumentApprovalSetup.Substitute);
            if DocumentApprovalSetup.FIND('-') then begin
                ApprovalEntry."Last Modified By User ID" := USERID;
                ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                ApprovalEntry."Approver ID" := DocumentApprovalSetup."User ID";
                ApprovalEntry.MODIFY;

            end;
        end else
            ERROR(Text007, DocumentApprovalSetup.FIELDCAPTION(Substitute), DocumentApprovalSetup."User ID");
    end;

    procedure CancelPurchaseApprovalRequest(RFQHeader: Record "RFQ Comparison"): Boolean;
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
        SendMail: Boolean;
        MailCreated: Boolean;
        PRLine: Record "PR Line";
    begin
        if (RFQHeader.Status = RFQHeader.Status::"Pending Approval") then begin

            if not ApprovalSetup.GET then
                ERROR(Text004);

            with RFQHeader do begin
                ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
                ApprovalEntry.SETRANGE("Table ID", DATABASE::"PR Header");
                ApprovalEntry.SETFILTER("Document Type", 'PR');
                ApprovalEntry.SETRANGE("Document No.", "No.");
                ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
                if ApprovalEntry.FIND('-') then begin
                    repeat
                        if (ApprovalEntry.Status = ApprovalEntry.Status::Open) or
                           (ApprovalEntry.Status = ApprovalEntry.Status::Approved) or (ApprovalEntry.Status = ApprovalEntry.Status::Created) then
                            ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                        ApprovalEntry."Last Modified By User ID" := USERID;
                        ApprovalEntry.MODIFY;
                    until ApprovalEntry.NEXT = 0;
                end;

                if not (Status = Status::Released) then
                    Status := Status::Open;
                MODIFY(true);
                PRLine.RESET;
                PRLine.SETRANGE("Document No.", RFQHeader."No.");
                if PRLine.FINDSET then begin
                    PRLine.MODIFYALL(Status, PRLine.Status::Open);
                end;
                MESSAGE(Text002, RFQHeader."No.");
            end;
        end
        else
            MESSAGE(Text130)
    end;

    procedure SendRFQApproval(var RFQComparision: Record "RFQ Comparison"; TotalBudget: Decimal): Boolean;
    var
        TemplateRec: Record "Approval Templates";
        ApprovalSetup: Record "Approval Setup";
        MessageType: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval;
    begin
        with RFQComparision do begin
            if Status <> Status::Open then
                exit(false);

            if not ApprovalSetup.GET then
                ERROR(Text004);

            TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
            TemplateRec.SETRANGE("Table ID", DATABASE::"RFQ Comparison");
            TemplateRec.SETRANGE("Document Type", TemplateRec."Document Type"::RFQC);
            TemplateRec.SETRANGE("No. series", RFQComparision."No. series");
            TemplateRec.SETRANGE(Enabled, true);
            if TemplateRec.FIND('-') then begin
                repeat
                    if TemplateRec."Direct Approver" then begin
                        if not FindApproverRFQDirect(RFQComparision, ApprovalSetup, TemplateRec) then
                            ERROR(Text010);
                    end else begin
                        if not FindApproverRFQ(RFQComparision, ApprovalSetup, TemplateRec) then
                            ERROR(Text010);
                    end;
                until TemplateRec.NEXT = 0;
                FinishApprovalEntryRFQ(RFQComparision, ApprovalSetup, MessageType, TotalBudget);
                case MessageType of
                    MessageType::AutomaticPrePayment:
                        MESSAGE(Text128, 'RFQ', RFQComparision."No.");
                    MessageType::AutomaticRelease:
                        MESSAGE(Text003, 'RFQ', RFQComparision."No.");
                    MessageType::RequiresApproval:
                        MESSAGE(Text001, 'RFQ', RFQComparision."No.");
                end;
            end else
                ERROR(STRSUBSTNO(Text129, 'RFQC'));
        end;
    end;

    procedure FindApproverRFQ(RFQHeader: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[20];
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
    begin

        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcRFQDocAmount(RFQHeader, ApprovalAmount, ApprovalAmountLCY);
        if ApprovalAmountLCY = 0 then
            ERROR('checking balance');
        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryRFQ(
                                   DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryRFQ(
                                           DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryRFQ(
                                         DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryRFQ(
                                   DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);
                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryRFQ(
                                           DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryRFQ(
                                           DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;

                            end;
                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryRFQ(
                                   DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                   AppTemplate, 0);


                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryRFQ(
                                           DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryRFQ(
                               DATABASE::"RFQ Comparison", RFQHeader."No.", '',
                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                               AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);

                end;
        end;
        exit(true);
    end;

    procedure FindApproverRFQDirect(RFQComp: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; AppTemplate: Record "Approval Templates"): Boolean;
    var
        LText001: Label '"User setup does not exist for requester %1 "';
        LText002: Label 'Requester should not be empty in the Purchase Requisition header';
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        UserSetup: Record "Document Approval Setup";
        ApproverId: Code[20];
        FirstEntry: Boolean;
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcRFQDocAmount(RFQComp, ApprovalAmount, ApprovalAmountLCY);

        case AppTemplate."Approval Type" of
            AppTemplate."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if RFQComp."Co-ordinator" <> '' then begin
                        case AppTemplate."Limit Type" of
                            AppTemplate."Limit Type"::"Approval Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQComp."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQComp."Co-ordinator")

                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                           DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                           ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                           AppTemplate, 0);

                                        ApproverId := UserSetup."Approver ID";
                                        if not UserSetup."Unlimited Purchase Approval" and
                                           ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                           (UserSetup."Purchase Amount Approval Limit" = 0))
                                        then begin
                                            UserSetup.RESET;
                                            UserSetup.SETCURRENTKEY("User ID");
                                            UserSetup.SETRANGE("User ID", ApproverId);
                                            UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                            if UserSetup.FINDFIRST then begin
                                                FirstEntry := true;
                                                repeat
                                                    if not FirstEntry then begin
                                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                        if not UserSetup.FIND('-') then
                                                            ERROR(Text006, ApproverId);
                                                    end;
                                                    FirstEntry := false;
                                                until (UserSetup."Unlimited Purchase Approval") or
                                                  ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                                  (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                                  (UserSetup."User ID" = UserSetup."Approver ID");
                                                ApproverId := UserSetup."User ID";
                                                MakeApprovalEntryPurchaseReq(
                                                   DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                                   ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                   AppTemplate, 0);

                                            end else
                                                ERROR(Text006, ApproverId);
                                        end;
                                    end;

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"Request Limits":
                                begin

                                    UserSetup.SETRANGE("User ID", RFQComp."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQComp."Co-ordinator");

                                    UserSetup.RESET;
                                    UserSetup.SETRANGE("User ID", USERID);
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(Text005, USERID);
                                    ApproverId := UserSetup."User ID";
                                    MakeApprovalEntryPurchaseReq(
                                       DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                       ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                       AppTemplate, 0);

                                    if not UserSetup."Unlimited Request Approval" and
                                       ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                        (UserSetup."Request Amount Approval Limit" = 0))
                                    then
                                        repeat
                                            UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                            if not UserSetup.FIND('-') then
                                                ERROR(Text005, USERID);
                                            ApproverId := UserSetup."User ID";
                                            MakeApprovalEntryPurchaseReq(
                                               DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                               ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                               AppTemplate, 0);

                                        until UserSetup."Unlimited Request Approval" or
                                              ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                               (UserSetup."Request Amount Approval Limit" <> 0)) or
                                              (UserSetup."User ID" = UserSetup."Approver ID");

                                    DocApp.CheckAddApprovers(AppTemplate);
                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FIND('-') then
                                        repeat
                                            ApproverId := AddApproversTemp."Approver ID";
                                            MakeApprovalEntryPurchaseReq(
                                             DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                              AppTemplate, 0);

                                        until AddApproversTemp.NEXT = 0;
                                end;

                            AppTemplate."Limit Type"::"No Limits":
                                begin
                                    UserSetup.SETRANGE("User ID", RFQComp."Co-ordinator");
                                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                    if not UserSetup.FIND('-') then
                                        ERROR(LText001, RFQComp."Co-ordinator")
                                    else begin
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                        DocApp.CheckAddApprovers(AppTemplate);
                                        AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                        if AddApproversTemp.FIND('-') then
                                            repeat
                                                ApproverId := AddApproversTemp."Approver ID";
                                                MakeApprovalEntryPurchaseReq(
                                                 DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                                  AppTemplate, 0);
                                            until AddApproversTemp.NEXT = 0;
                                    end;
                                end;
                        end;
                    end;
                end;

            AppTemplate."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                    if not UserSetup.FIND('-') then
                        ERROR(Text005, USERID);

                    case AppTemplate."Limit Type" of
                        AppTemplate."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                    ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                    AppTemplate, 0);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                   (UserSetup."Purchase Amount Approval Limit" = 0))
                                then begin
                                    UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                    if UserSetup.FINDFIRST then begin
                                        FirstEntry := true;
                                        repeat
                                            if not FirstEntry then begin
                                                UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                                if not UserSetup.FIND('-') then
                                                    ERROR(Text005, USERID);
                                            end;
                                            FirstEntry := false;
                                        until UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                          (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    end else
                                        ERROR(Text006, ApproverId);
                                end;

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"Request Limits":
                            begin
                                UserSetup.SETRANGE("User ID", USERID);
                                UserSetup.SETRANGE("Approval Routing", AppTemplate."Approval Routing");
                                if not UserSetup.FIND('-') then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FIND('-') then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);
                                    until UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;

                        AppTemplate."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakeApprovalEntryPurchaseReq(
                                 DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                  ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                  AppTemplate, 0);

                                DocApp.CheckAddApprovers(AppTemplate);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FIND('-') then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeApprovalEntryPurchaseReq(
                                         DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                                          ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                                          AppTemplate, 0);

                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;

            AppTemplate."Approval Type"::" ":
                begin
                    DocApp.CheckAddApprovers(AppTemplate);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FIND('-') then
                        repeat
                            ApproverId := AddApproversTemp."Approver ID";
                            MakeApprovalEntryPurchaseReq(
                             DATABASE::"PR Header", RFQComp."No.", RFQComp."Co-ordinator",
                              ApprovalSetup, ApproverId, AppTemplate."Approval Code", UserSetup, ApprovalAmount, ApprovalAmountLCY,
                              AppTemplate, 0);

                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);
                end;
        end;

        exit(true);
    end;

    procedure FinishApprovalEntryRFQ(RFQComparision: Record "RFQ Comparison"; ApprovalSetup: Record "Approval Setup"; var MessageID: Option " ",AutomaticPrePayment,AutomaticRelease,RequiresApproval; TotalBudget: Decimal);
    var
        DocReleased: Boolean;
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
    begin
        DocReleased := false;
        with ApprovalEntry do begin
            INIT;
            SETRANGE("Table ID", DATABASE::"RFQ Comparison");
            SETRANGE("Document Type", ApprovalEntry."PR Document Type"::RFQC);
            SETRANGE("Document No.", RFQComparision."No.");
            SETRANGE(Status, Status::Created);
            if FINDSET(true, false) then
                repeat
                    if "Sender ID" = "Approver ID" then begin
                        Status := Status::Approved;
                        MODIFY;
                    end else
                        if not IsOpenStatusSet then begin
                            Status := Status::Open;
                            MODIFY;
                            IsOpenStatusSet := true;
                            if ApprovalSetup.Approvals then
                                ApprovalsMgtNotification.SendRFQCApprovalsMail(RFQComparision, ApprovalEntry, TotalBudget);
                        end;
                until NEXT = 0;

            if not IsOpenStatusSet then begin
                SETRANGE(Status);
                FINDLAST;
                DocReleased := ApprovalReleaseRFQ(ApprovalEntry, RFQComparision, TotalBudget);
            end;

            if DocReleased then begin
                MessageID := MessageID::AutomaticRelease;
            end else begin
                RFQComparision.Status := RFQComparision.Status::"Pending Approval";
                RFQComparision.MODIFY(true);
                MessageID := MessageID::RequiresApproval;
            end;
        end;
    end;

    procedure MakeApprovalEntryRFQ(TableID: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[20]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[20]; ApprovalCode: Code[20]; UserSetup: Record "Document Approval Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; AppTemplate: Record "Approval Templates"; ExeedAmountLCY: Decimal);
    var
        ApprovalEntry: Record "Approval Entry";
        NewSequenceNo: Integer;
    begin
        with ApprovalEntry do begin
            if FINDLAST then
                NewEntry := "Entry No." + 1
            else
                NewEntry := 1;

            "Entry No." := NewEntry;
            SETRANGE("Table ID", TableID);
            SETRANGE("Document Type", "PR Document Type"::RFQC);
            SETRANGE("Document No.", DocNo);
            if FIND('+') then
                NewSequenceNo := "Sequence No." + 1
            else
                NewSequenceNo := 1;
            "Table ID" := TableID;
            "Document Type" := "PR Document Type"::RFQC;
            "Document No." := DocNo;
            if RFQHeader.GET(DocNo) then
                ApprovalEntry."Record ID to Approve" := RFQHeader.RECORDID;

            "Salespers./Purch. Code" := COPYSTR(SalespersonPurchaser, 1, 19);
            "Sequence No." := NewSequenceNo;
            "Approval Code" := ApprovalCode;
            "Sender ID" := USERID;
            Amount := ApprovalAmount;
            "Amount (LCY)" := ApprovalAmountLCY;
            "Approver ID" := ApproverId;
            if ApproverId = USERID then
                Status := Status::Approved
            else
                Status := Status::Created;
            "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
            "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            "Last Modified By User ID" := USERID;
            "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
            "Approval Type" := AppTemplate."Approval Type";
            "Limit Type" := AppTemplate."Limit Type";
            "Available Credit Limit (LCY)" := ExeedAmountLCY;
            INSERT;
        end;
    end;

    procedure CalcRFQDocAmount(RFQHeader: Record "RFQ Comparison"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    var
        LPLine: Record "Purchase Line";
    begin
        LPLine.RESET;
        LPLine.SETRANGE("Create PO", true);
        LPLine.SETRANGE(LPLine."RFQ No.", RFQHeader."No.");
        if LPLine.FINDSET then
            repeat
                ApprovalAmount += LPLine."Outstanding Amount";
                ApprovalAmountLCY += LPLine."Outstanding Amount (LCY)";
            until LPLine.NEXT = 0;
    end;

    procedure ApprovalReleaseRFQ(ApprovalEntry: Record "Approval Entry"; RFQComparision: Record "RFQ Comparison"; totalbudget: Decimal): Boolean;
    var
        NextApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZRFQ";
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalEntry.Status := ApprovalEntry.Status::Approved;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            NextApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
            NextApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            NextApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            NextApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            NextApprovalEntry.SETFILTER(Status, '%1|%2', NextApprovalEntry.Status::Created, NextApprovalEntry.Status::Open);
            if NextApprovalEntry.FIND('-') then begin
                if NextApprovalEntry.Status = NextApprovalEntry.Status::Open then
                    exit(false)
                else begin
                    NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
                    NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
                    NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    NextApprovalEntry."Last Modified By User ID" := USERID;
                    NextApprovalEntry.MODIFY;
                    ApprovalSetup.GET;
                    if ApprovalSetup.Approvals then
                        ApprovalsMgtNotification.SendRFQCApprovalsMail(RFQComparision, NextApprovalEntry, totalbudget);
                    exit(false);
                end;
            end else begin
                PRFunc.ReleaseRFQCDocAfterApprove(RFQComparision);
                exit(true);
            end;
        end;
    end;

    procedure CancelRFQApproval(RFQComp: Record "RFQ Comparison"): Boolean;
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
        SendMail: Boolean;
        MailCreated: Boolean;
    begin
        if (RFQComp.Status = RFQComp.Status::"Pending Approval") then begin

            if not ApprovalSetup.GET then
                ERROR(Text004);

            with RFQComp do begin
                ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
                ApprovalEntry.SETRANGE("Table ID", DATABASE::"RFQ Comparison");
                ApprovalEntry.SETFILTER("Document Type", 'RFQC');
                ApprovalEntry.SETRANGE("Document No.", "No.");
                ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
                if ApprovalEntry.FIND('-') then begin
                    repeat
                        if (ApprovalEntry.Status = ApprovalEntry.Status::Open) or
                           (ApprovalEntry.Status = ApprovalEntry.Status::Approved) or (ApprovalEntry.Status = ApprovalEntry.Status::Created) then
                            ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                        ApprovalEntry."Last Modified By User ID" := USERID;
                        ApprovalEntry.MODIFY;
                    until ApprovalEntry.NEXT = 0;
                end;

                if not (Status = Status::Released) then
                    Status := Status::Open;
                MODIFY(true);
                MESSAGE(Text002, 'RFQ Comparision', RFQComp."No.");
            end;
        end
        else
            MESSAGE(Text130)
    end;
}

