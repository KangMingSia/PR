codeunit 27003003 "Approvals Management-IBIZPR"
{
    Permissions = TableData "Approval Entry" = imd,
                  TableData "Approval Comment Line" = imd,
                  TableData "Posted Approval Entry" = imd,
                  TableData "Posted Approval Comment Line" = imd,
                  TableData "Overdue Approval Entry" = imd;

    trigger OnRun();
    begin
    end;

    var
        Text001: Label '%1 %2 requires further approval.\\Approval request entries have been created.';
        Text002: Label '%1 %2 approval request cancelled.';
        Text003: Label '%1 %2 has been automatically approved and released.';
        Text004: Label 'Approval Setup not found.';
        Text005: Label 'User ID %1 does not exist in the User Setup table.';
        Text006: Label 'Approver ID %1 does not exist in the User Setup table.';
        Text007: Label '%1 for %2  does not exist in the User Setup table.';
        Text008: Label 'User ID %1 does not exist in the User Setup table for %2 %3.';
        Text013: TextConst Comment = '%1=document type, %2=document no., e.g. Order 321 must be approved...', ENU = '%1 %2 must be approved and released before you can perform this action.';
        Text010: Label 'Approver not found.';
        Text014: Label 'The %1 approval entries have now been cancelled.';
        Text015: Label 'The %1 %2 does not have any Lines.';
        Text022: Label 'There has to be a %1 on %2 %3.';
        AddApproversTemp: Record "Additional Approvers" temporary;
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
        Text125: Label 'Sales Order Credit Limit Approval';
        Text126: Label 'S-I-CREDITLIMIT';
        Text127: Label 'Sales Invoice Credit Limit Approval';
        Text128: Label '%1 %2 has been automatically approved. Status changed to Pending Prepayment.';
        Text129: Label 'No Approval Templates are enabled for document type %1.';
        IsOpenStatusSet: Boolean;
        Text130: Label 'The approval request cannot be canceled because the order has already been released. To modify this order, you must reopen it.';
        UnpostedPrepaymentExistsMsg: Label '%1 There are unposted prepayment amounts on the document of type %2 with the number %3.';
        UnpostedPaymentExistsMsg: Label '%1 There are unpaid prepayment invoices that are related to the document of type %2 with the number %3.';

    procedure SendSalesApprovalRequest(var SalesHeader: Record "Sales Header"): Boolean;
    var
        TemplateRec: Record "Approval Templates";
        ApprovalSetup: Record "Approval Setup";
        MessageType: Option " ",AutomaticPrePayment,AutomaticPayment,AutomaticRelease,RequiresApproval;
    begin
        TestSetup;
        with SalesHeader do begin
            if Status <> Status::Open then
                exit(false);

            if not ApprovalSetup.GET then
                ERROR(Text004);

            if not SalesLinesExist then
                ERROR(Text015, FORMAT("Document Type"), "No.");

            CalcInvDiscForHeader;

            TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
            TemplateRec.SETRANGE("Table ID", DATABASE::"Sales Header");
            TemplateRec.SETRANGE("Document Type", "Document Type");
            TemplateRec.SETRANGE(Enabled, true);
            if TemplateRec.FIND('-') then begin
                repeat
                    if not FindApproverSales(SalesHeader, ApprovalSetup, TemplateRec) then
                        ERROR(Text010);
                until TemplateRec.NEXT = 0;
                FinishApprovalEntrySales(SalesHeader, ApprovalSetup, MessageType);
                case MessageType of
                    MessageType::AutomaticPrePayment:
                        if TestSalesPrepayment(SalesHeader) then
                            MESSAGE(
                              UnpostedPrepaymentExistsMsg,
                              STRSUBSTNO(Text128, "Document Type", "No."),
                              "Document Type",
                              "No.")
                        else
                            MESSAGE(Text128, "Document Type", "No.");
                    MessageType::AutomaticPayment:
                        if TestSalesPayment(SalesHeader) then
                            MESSAGE(
                              UnpostedPaymentExistsMsg,
                              STRSUBSTNO(Text128, "Document Type", "No."),
                              "Document Type",
                              "No.")
                        else
                            MESSAGE(Text128, "Document Type", "No.");
                    MessageType::AutomaticRelease:
                        MESSAGE(Text003, "Document Type", "No.");
                    MessageType::RequiresApproval:
                        MESSAGE(Text001, "Document Type", "No.");
                end;
            end else
                ERROR(STRSUBSTNO(Text129, "Document Type"));
            exit(true);
        end;
    end;

    procedure CancelSalesApprovalRequest(var SalesHeader: Record "Sales Header"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
        SendMail: Boolean;
        MailCreated: Boolean;
    begin
        TestSetup;
        if SalesHeader.Status <> SalesHeader.Status::Released then begin
            if not ApprovalSetup.GET then
                ERROR(Text004);

            with SalesHeader do begin
                ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
                ApprovalEntry.SETRANGE("Table ID", DATABASE::"Sales Header");
                ApprovalEntry.SETRANGE("Document Type", "Document Type");
                ApprovalEntry.SETRANGE("Document No.", "No.");
                ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
                SendMail := false;
                if ApprovalEntry.FIND('-') then begin
                    repeat
                        if (ApprovalEntry.Status = ApprovalEntry.Status::Open) or
                           (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
                        then
                            SendMail := true;
                        ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                        ApprovalEntry."Last Modified By User ID" := USERID;
                        ApprovalEntry.MODIFY;
                        if ApprovalSetup.Cancellations and ShowMessage and SendMail then begin
                            AppManagement.SendSalesCancellationsMail(SalesHeader, ApprovalEntry);
                            MailCreated := true;
                            SendMail := false;
                        end;
                    until ApprovalEntry.NEXT = 0;
                    if MailCreated then begin
                        AppManagement.SendMail;
                        MailCreated := false;
                    end;
                end;

                if ManualCancel or (not ManualCancel and not (Status = Status::Released)) then
                    Status := Status::Open;
                MODIFY(true);
            end;
            if ShowMessage then
                MESSAGE(Text002, SalesHeader."Document Type", SalesHeader."No.");
        end
        else
            MESSAGE(Text130);
    end;

    procedure SendPurchaseApprovalRequest(var PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        TemplateRec: Record "Approval Templates";
        ApprovalSetup: Record "Approval Setup";
        MessageType: Option " ",AutomaticPrePayment,AutomaticPayment,AutomaticRelease,RequiresApproval;
    begin
        TestSetup;
        with PurchaseHeader do begin
            if Status <> Status::Open then
                exit(false);

            if not ApprovalSetup.GET then
                ERROR(Text004);

            if not PurchLinesExist then
                ERROR(Text015, FORMAT("Document Type"), "No.");

            CalcInvDiscForHeader;

            TemplateRec.SETCURRENTKEY("Table ID", "Document Type", Enabled);
            TemplateRec.SETRANGE("Table ID", DATABASE::"Purchase Header");
            TemplateRec.SETRANGE("Document Type", "Document Type");
            TemplateRec.SETRANGE(Enabled, true);
            if TemplateRec.FIND('-') then begin
                repeat
                    if TemplateRec."Limit Type" = TemplateRec."Limit Type"::"Credit Limits" then begin
                        ERROR(STRSUBSTNO(Text025, FORMAT(TemplateRec."Limit Type"), FORMAT("Document Type"),
                            "No."));
                    end else begin
                        if not FindApproverPurchase(PurchaseHeader, ApprovalSetup, TemplateRec) then
                            ERROR(Text010);
                    end;
                until TemplateRec.NEXT = 0;
                FinishApprovalEntryPurchase(PurchaseHeader, ApprovalSetup, MessageType);
                case MessageType of
                    MessageType::AutomaticPrePayment:
                        /*   if TestPurchasePrepayment(PurchaseHeader) then
                              MESSAGE(
                                UnpostedPrepaymentExistsMsg,
                                STRSUBSTNO(Text128, "Document Type", "No."),
                                "Document Type",
                                "No.")
                          else */ //TOCHECK
                        MESSAGE(Text128, "Document Type", "No.");
                    MessageType::AutomaticPayment:
                        if TestPurchasePayment(PurchaseHeader) then
                            MESSAGE(
                              UnpostedPaymentExistsMsg,
                              STRSUBSTNO(Text128, "Document Type", "No."),
                              "Document Type",
                              "No.")
                        else
                            MESSAGE(Text128, "Document Type", "No.");
                    MessageType::AutomaticRelease:
                        MESSAGE(Text003, "Document Type", "No.");
                    MessageType::RequiresApproval:
                        MESSAGE(Text001, "Document Type", "No.");
                end;
            end else
                ERROR(STRSUBSTNO(Text129, "Document Type"));
            exit(true);
        end;
    end;

    procedure CancelPurchaseApprovalRequest(var PurchaseHeader: Record "Purchase Header"; ShowMessage: Boolean; ManualCancel: Boolean): Boolean;
    var
        ApprovalEntry: Record "Approval Entry";
        ApprovalSetup: Record "Approval Setup";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
        SendMail: Boolean;
        MailCreated: Boolean;
    begin
        TestSetup;
        if PurchaseHeader.Status <> PurchaseHeader.Status::Released then begin
            if not ApprovalSetup.GET then
                ERROR(Text004);

            with PurchaseHeader do begin
                ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
                ApprovalEntry.SETRANGE("Table ID", DATABASE::"Purchase Header");
                ApprovalEntry.SETRANGE("Document Type", "Document Type");
                ApprovalEntry.SETRANGE("Document No.", "No.");
                ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Rejected, ApprovalEntry.Status::Canceled);
                SendMail := false;
                if ApprovalEntry.FIND('-') then begin
                    repeat
                        if (ApprovalEntry.Status = ApprovalEntry.Status::Open) or
                           (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
                        then
                            SendMail := true;
                        ApprovalEntry.Status := ApprovalEntry.Status::Canceled;
                        ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                        ApprovalEntry."Last Modified By User ID" := USERID;
                        ApprovalEntry.MODIFY;
                        if ApprovalSetup.Cancellations and ShowMessage and SendMail then begin
                            AppManagement.SendPurchaseCancellationsMail(PurchaseHeader, ApprovalEntry);
                            MailCreated := true;
                            SendMail := false;
                        end;
                    until ApprovalEntry.NEXT = 0;
                    if MailCreated then begin
                        AppManagement.SendMail;
                        MailCreated := false;
                    end;
                end;

                if ManualCancel or (not ManualCancel and not (Status = Status::Released)) then
                    Status := Status::Open;
                MODIFY(true);
            end;
            if ShowMessage then
                MESSAGE(Text002, PurchaseHeader."Document Type", PurchaseHeader."No.");
        end
        else
            MESSAGE(Text130)
    end;

    procedure CheckApprSalesDocument(var SalesHeader: Record "Sales Header"): Boolean;
    var
        ApprovalTemplate: Record "Approval Templates";
    begin
        ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
        ApprovalTemplate.SETRANGE("Table ID", DATABASE::"Sales Header");
        ApprovalTemplate.SETRANGE("Document Type", SalesHeader."Document Type");
        ApprovalTemplate.SETRANGE(Enabled, true);
        exit(not ApprovalTemplate.ISEMPTY);
    end;

    procedure CheckApprPurchaseDocument(var PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        ApprovalTemplate: Record "Approval Templates";
    begin
        ApprovalTemplate.SETCURRENTKEY("Table ID", "Document Type", Enabled);
        ApprovalTemplate.SETRANGE("Table ID", DATABASE::"Purchase Header");
        ApprovalTemplate.SETRANGE("Document Type", PurchaseHeader."Document Type");
        ApprovalTemplate.SETRANGE(Enabled, true);
        exit(not ApprovalTemplate.ISEMPTY);
    end;

    procedure SalesLines(SalesHeader: Record "Sales Header"): Boolean;
    var
        SalesLines: Record "Sales Line";
    begin
        SalesLines.SETCURRENTKEY("Document Type", "Document No.");
        SalesLines.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLines.SETRANGE("Document No.", SalesHeader."No.");
        if SalesLines.FINDSET then
            repeat
                if (SalesLines.Quantity <> 0) and (SalesLines."Line Amount" <> 0) then
                    exit(true);
            until SalesLines.NEXT = 0;

        exit(false);
    end;

    procedure FindApproverSales(SalesHeader: Record "Sales Header"; ApprovalSetup: Record "Approval Setup"; ApprovalTemplates: Record "Approval Templates"): Boolean;
    var
        Cust: Record Customer;
        UserSetup: Record "User Setup";
        ApproverId: Code[50];
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        AboveCreditLimitAmountLCY: Decimal;
        InsertEntries: Boolean;
        SufficientApprover: Boolean;
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcSalesDocAmount(SalesHeader, ApprovalAmount, ApprovalAmountLCY);

        case ApprovalTemplates."Approval Type" of
            ApprovalTemplates."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if SalesHeader."Salesperson Code" = '' then
                        ERROR(STRSUBSTNO(Text022, SalesHeader.FIELDCAPTION("Salesperson Code"),
                            FORMAT(SalesHeader."Document Type"), SalesHeader."No."));

                    case ApprovalTemplates."Limit Type" of
                        ApprovalTemplates."Limit Type"::"Approval Limits":
                            begin
                                AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                                UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                      UserSetup."Salespers./Purch. Code");

                                MakeSalesHeaderApprovalEntry(
                                  SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                  UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                ApproverId := UserSetup."Approver ID";

                                if not UserSetup."Unlimited Sales Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") or
                                    (UserSetup."Sales Amount Approval Limit" = 0))
                                then begin
                                    UserSetup.RESET;
                                    UserSetup.SETCURRENTKEY("User ID");
                                    UserSetup.SETRANGE("User ID", ApproverId);
                                    repeat
                                        if not UserSetup.FINDFIRST then
                                            ERROR(Text006, ApproverId);
                                        ApproverId := UserSetup."User ID";
                                        MakeSalesHeaderApprovalEntry(
                                          SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");

                                        SufficientApprover := UserSetup."Unlimited Sales Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") and
                                           (UserSetup."Sales Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID")
                                    until SufficientApprover;
                                end;

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakeSalesHeaderApprovalEntry(
                                          SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        ApprovalTemplates."Limit Type"::"Credit Limits":
                            begin
                                AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                                Cust.GET(SalesHeader."Bill-to Customer No.");
                                ApprovalTemplates.CALCFIELDS("Additional Approvers");
                                if not ApprovalTemplates."Additional Approvers" then
                                    ERROR(Text023);

                                InsertAddApprovers(ApprovalTemplates);
                                if (AboveCreditLimitAmountLCY > 0) or (Cust."Credit Limit (LCY)" = 0) then begin
                                    ApproverId := USERID;
                                    MakeSalesHeaderApprovalEntry(
                                      SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                      ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                end else begin
                                    UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                    UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
                                    if not UserSetup.FINDFIRST then
                                        ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                          UserSetup."Salespers./Purch. Code");

                                    MakeSalesHeaderApprovalEntry(
                                      SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                      UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

                                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                    if AddApproversTemp.FINDSET then
                                        repeat
                                            MakeSalesHeaderApprovalEntry(
                                              SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                              AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                        until AddApproversTemp.NEXT = 0;
                                end;
                            end;
                        ApprovalTemplates."Limit Type"::"Request Limits":
                            ERROR(STRSUBSTNO(Text024, FORMAT(ApprovalTemplates."Limit Type")));
                        ApprovalTemplates."Limit Type"::"No Limits":
                            begin
                                AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                                UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                UserSetup.SETRANGE("Salespers./Purch. Code", SalesHeader."Salesperson Code");
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                      UserSetup."Salespers./Purch. Code");

                                ApproverId := UserSetup."User ID";
                                MakeSalesHeaderApprovalEntry(
                                  SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        ApproverId := AddApproversTemp."Approver ID";
                                        MakeSalesHeaderApprovalEntry(
                                          SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;
            ApprovalTemplates."Approval Type"::Approver:
                case ApprovalTemplates."Limit Type" of
                    ApprovalTemplates."Limit Type"::"Approval Limits":
                        begin
                            AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                            UserSetup.SETRANGE("User ID", USERID);
                            if not UserSetup.FINDFIRST then
                                ERROR(Text005, USERID);
                            ApproverId := UserSetup."User ID";
                            MakeSalesHeaderApprovalEntry(
                              SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                              ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                            if not UserSetup."Unlimited Sales Approval" and
                               ((ApprovalAmountLCY > UserSetup."Sales Amount Approval Limit") or
                                (UserSetup."Sales Amount Approval Limit" = 0))
                            then
                                repeat
                                    UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                    if not UserSetup.FINDFIRST then
                                        ERROR(Text005, UserSetup."Approver ID");
                                    ApproverId := UserSetup."User ID";
                                    MakeSalesHeaderApprovalEntry(
                                      SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                      ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                    SufficientApprover := UserSetup."Unlimited Sales Approval" or
                                      ((ApprovalAmountLCY <= UserSetup."Sales Amount Approval Limit") and
                                       (UserSetup."Sales Amount Approval Limit" <> 0)) or
                                      (UserSetup."User ID" = UserSetup."Approver ID");
                                until SufficientApprover;

                            CheckAddApprovers(ApprovalTemplates);
                            AddApproversTemp.SETCURRENTKEY("Sequence No.");
                            if AddApproversTemp.FINDSET then
                                repeat
                                    MakeSalesHeaderApprovalEntry(
                                      SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                      AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                until AddApproversTemp.NEXT = 0;
                        end;
                    ApprovalTemplates."Limit Type"::"Credit Limits":
                        begin
                            AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                            Cust.GET(SalesHeader."Bill-to Customer No.");

                            ApprovalTemplates.CALCFIELDS("Additional Approvers");
                            if not ApprovalTemplates."Additional Approvers" then
                                ERROR(Text023);

                            InsertAddApprovers(ApprovalTemplates);
                            if (AboveCreditLimitAmountLCY > 0) or (Cust."Credit Limit (LCY)" = 0) then begin
                                ApproverId := USERID;
                                MakeSalesHeaderApprovalEntry(
                                  SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                            end else begin
                                UserSetup.SETRANGE("User ID", USERID);
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakeSalesHeaderApprovalEntry(
                                  SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);

                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakeSalesHeaderApprovalEntry(
                                          SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, SalesHeader."Salesperson Code",
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        end;
                    ApprovalTemplates."Limit Type"::"Request Limits":
                        ERROR(STRSUBSTNO(Text024, FORMAT(ApprovalTemplates."Limit Type")));
                    ApprovalTemplates."Limit Type"::"No Limits":
                        begin
                            AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                            UserSetup.SETRANGE("User ID", USERID);
                            if not UserSetup.FINDFIRST then
                                ERROR(Text005, USERID);
                            ApproverId := UserSetup."Approver ID";
                            if ApproverId = '' then
                                ApproverId := UserSetup."User ID";
                            MakeSalesHeaderApprovalEntry(
                              SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                              ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                        end;
                end;
            ApprovalTemplates."Approval Type"::" ":
                begin
                    AboveCreditLimitAmountLCY := CheckCreditLimit(SalesHeader);
                    InsertEntries := false;
                    Cust.GET(SalesHeader."Bill-to Customer No.");
                    if IsCreditLimits(ApprovalTemplates) then
                        if (AboveCreditLimitAmountLCY > 0) or (Cust."Credit Limit (LCY)" = 0) then begin
                            ApproverId := USERID;
                            MakeSalesHeaderApprovalEntry(
                              SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                              ApproverId, ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                        end else
                            InsertEntries := true;

                    if not IsCreditLimits(ApprovalTemplates) or InsertEntries then begin
                        CheckAddApprovers(ApprovalTemplates);
                        AddApproversTemp.SETCURRENTKEY("Sequence No.");
                        if AddApproversTemp.FINDSET then
                            repeat
                                MakeSalesHeaderApprovalEntry(
                                  SalesHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                  AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY, AboveCreditLimitAmountLCY);
                            until AddApproversTemp.NEXT = 0
                        else
                            ERROR(Text027);
                    end;
                end;
        end;

        exit(true);
    end;

    procedure PurchaseLines(PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        PurchaseLines: Record "Purchase Line";
    begin
        with PurchaseLines do begin
            SETCURRENTKEY("Document Type", "Document No.");
            SETRANGE("Document Type", PurchaseHeader."Document Type");
            SETRANGE("Document No.", PurchaseHeader."No.");
            if FINDSET then
                repeat
                    if (Quantity <> 0) and ("Line Amount" <> 0) then
                        exit(true);
                until NEXT = 0;
        end;
        exit(false);
    end;

    procedure FindApproverPurchase(PurchaseHeader: Record "Purchase Header"; ApprovalSetup: Record "Approval Setup"; ApprovalTemplates: Record "Approval Templates"): Boolean;
    var
        UserSetup: Record "User Setup";
        ApproverId: Code[50];
        ApprovalAmount: Decimal;
        ApprovalAmountLCY: Decimal;
        SufficientApprover: Boolean;
    begin
        AddApproversTemp.RESET;
        AddApproversTemp.DELETEALL;

        CalcPurchaseDocAmount(PurchaseHeader, ApprovalAmount, ApprovalAmountLCY);

        case ApprovalTemplates."Approval Type" of
            ApprovalTemplates."Approval Type"::"Sales Pers./Purchaser":
                begin
                    if PurchaseHeader."Purchaser Code" = '' then
                        ERROR(STRSUBSTNO(Text022, PurchaseHeader.FIELDCAPTION("Purchaser Code"),
                            FORMAT(PurchaseHeader."Document Type"), PurchaseHeader."No."));

                    case ApprovalTemplates."Limit Type" of
                        ApprovalTemplates."Limit Type"::"Approval Limits":
                            begin
                                UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                      UserSetup."Salespers./Purch. Code");

                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
                                  UserSetup."User ID", ApprovalAmount, ApprovalAmountLCY);
                                ApproverId := UserSetup."Approver ID";
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                    (UserSetup."Purchase Amount Approval Limit" = 0))
                                then begin
                                    UserSetup.RESET;
                                    UserSetup.SETCURRENTKEY("User ID");
                                    UserSetup.SETRANGE("User ID", ApproverId);
                                    repeat
                                        if not UserSetup.FINDFIRST then
                                            ERROR(Text006, ApproverId);
                                        ApproverId := UserSetup."User ID";
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        SufficientApprover := UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                           (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID")
                                    until SufficientApprover;
                                end;

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        ApprovalTemplates."Limit Type"::"Request Limits":
                            begin
                                if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote then
                                    ERROR(GetQuoteErrorText(ApprovalTemplates, PurchaseHeader));

                                UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                      UserSetup."Salespers./Purch. Code");
                                UserSetup.RESET;
                                UserSetup.SETRANGE("User ID", USERID);
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY);

                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        UserSetup.SETRANGE("User ID", UserSetup."Approver ID");
                                        if not UserSetup.FINDFIRST then
                                            ERROR(Text005, USERID);
                                        ApproverId := UserSetup."User ID";
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                        SufficientApprover := UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                    until SufficientApprover;

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        ApprovalTemplates."Limit Type"::"No Limits":
                            begin
                                UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                                UserSetup.SETRANGE("Salespers./Purch. Code", PurchaseHeader."Purchaser Code");
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text008, UserSetup."User ID", UserSetup.FIELDCAPTION("Salespers./Purch. Code"),
                                      UserSetup."Salespers./Purch. Code");
                                ApproverId := UserSetup."User ID";
                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY);

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;
            ApprovalTemplates."Approval Type"::Approver:
                begin
                    UserSetup.SETRANGE("User ID", USERID);
                    if not UserSetup.FINDFIRST then
                        ERROR(Text005, USERID);

                    case ApprovalTemplates."Limit Type" of
                        ApprovalTemplates."Limit Type"::"Approval Limits":
                            begin
                                ApproverId := UserSetup."User ID";
                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                if not UserSetup."Unlimited Purchase Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Purchase Amount Approval Limit") or
                                    (UserSetup."Purchase Amount Approval Limit" = 0))
                                then
                                    repeat
                                        ApproverId := UserSetup."Approver ID";
                                        UserSetup.SETRANGE("User ID", ApproverId);
                                        if not UserSetup.FINDFIRST then
                                            ERROR(Text005, ApproverId);
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                        SufficientApprover := UserSetup."Unlimited Purchase Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Purchase Amount Approval Limit") and
                                           (UserSetup."Purchase Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                    until SufficientApprover;

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        ApprovalTemplates."Limit Type"::"Request Limits":
                            begin
                                if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Quote then
                                    ERROR(GetQuoteErrorText(ApprovalTemplates, PurchaseHeader));

                                UserSetup.SETRANGE("User ID", USERID);
                                if not UserSetup.FINDFIRST then
                                    ERROR(Text005, USERID);
                                ApproverId := UserSetup."User ID";
                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                if not UserSetup."Unlimited Request Approval" and
                                   ((ApprovalAmountLCY > UserSetup."Request Amount Approval Limit") or
                                    (UserSetup."Request Amount Approval Limit" = 0))
                                then
                                    repeat
                                        ApproverId := UserSetup."Approver ID";
                                        UserSetup.SETRANGE("User ID", ApproverId);
                                        if not UserSetup.FINDFIRST then
                                            ERROR(Text005, ApproverId);
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          ApproverId, ApprovalAmount, ApprovalAmountLCY);
                                        SufficientApprover := UserSetup."Unlimited Request Approval" or
                                          ((ApprovalAmountLCY <= UserSetup."Request Amount Approval Limit") and
                                           (UserSetup."Request Amount Approval Limit" <> 0)) or
                                          (UserSetup."User ID" = UserSetup."Approver ID");
                                    until SufficientApprover;

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                        ApprovalTemplates."Limit Type"::"No Limits":
                            begin
                                ApproverId := UserSetup."Approver ID";
                                if ApproverId = '' then
                                    ApproverId := UserSetup."User ID";
                                MakePurchHeaderApprovalEntry(
                                  PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, PurchaseHeader."Purchaser Code",
                                  ApproverId, ApprovalAmount, ApprovalAmountLCY);

                                CheckAddApprovers(ApprovalTemplates);
                                AddApproversTemp.SETCURRENTKEY("Sequence No.");
                                if AddApproversTemp.FINDSET then
                                    repeat
                                        MakePurchHeaderApprovalEntry(
                                          PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                                          AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                                    until AddApproversTemp.NEXT = 0;
                            end;
                    end;
                end;
            ApprovalTemplates."Approval Type"::" ":
                begin
                    CheckAddApprovers(ApprovalTemplates);
                    AddApproversTemp.SETCURRENTKEY("Sequence No.");
                    if AddApproversTemp.FINDSET then
                        repeat
                            MakePurchHeaderApprovalEntry(
                              PurchaseHeader, ApprovalSetup, UserSetup, ApprovalTemplates, '',
                              AddApproversTemp."Approver ID", ApprovalAmount, ApprovalAmountLCY);
                        until AddApproversTemp.NEXT = 0
                    else
                        ERROR(Text027);
                end;
        end;

        exit(true);
    end;

    local procedure MakeSalesHeaderApprovalEntry(SalesHeader: Record "Sales Header"; ApprovalSetup: Record "Approval Setup"; UserSetup: Record "User Setup"; ApprovalTemplates: Record "Approval Templates"; SalespersonPurchaser: Code[10]; ApproverId: Code[50]; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; ExceedAmountLCY: Decimal);
    begin
        MakeApprovalEntry(
          DATABASE::"Sales Header", SalesHeader."Document Type", SalesHeader."No.",
          SalespersonPurchaser, ApprovalSetup, ApproverId, UserSetup, ApprovalAmount, ApprovalAmountLCY,
          SalesHeader."Currency Code", ApprovalTemplates, ExceedAmountLCY);
    end;

    local procedure MakePurchHeaderApprovalEntry(PurchHeader: Record "Purchase Header"; ApprovalSetup: Record "Approval Setup"; UserSetup: Record "User Setup"; ApprovalTemplates: Record "Approval Templates"; SalespersonPurchaser: Code[10]; ApproverId: Code[50]; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal);
    begin
        MakeApprovalEntry(
          DATABASE::"Purchase Header", PurchHeader."Document Type", PurchHeader."No.",
          SalespersonPurchaser, ApprovalSetup, ApproverId, UserSetup, ApprovalAmount, ApprovalAmountLCY,
          PurchHeader."Currency Code", ApprovalTemplates, 0);
    end;

    // procedure MakeApprovalEntry(TableID: Integer; DocType: Integer; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[50]; UserSetup: Record "User Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; ApprovalTemplates: Record "Approval Templates"; ExeedAmountLCY: Decimal);//Version 19.0.0.0>>
    procedure MakeApprovalEntry(TableID: Integer; DocType: Enum "Approval Document Type"; DocNo: Code[20]; SalespersonPurchaser: Code[10]; ApprovalSetup: Record "Approval Setup"; ApproverId: Code[50]; UserSetup: Record "User Setup"; ApprovalAmount: Decimal; ApprovalAmountLCY: Decimal; CurrencyCode: Code[10]; ApprovalTemplates: Record "Approval Templates"; ExeedAmountLCY: Decimal);//Version 19.0.0.0>>
    var
        ApprovalEntry: Record "Approval Entry";
        NewSequenceNo: Integer;
    begin
        with ApprovalEntry do begin
            SETRANGE("Table ID", TableID);
            SETRANGE("Document Type", DocType);
            SETRANGE("Document No.", DocNo);
            if FINDLAST then
                NewSequenceNo := "Sequence No." + 1
            else
                NewSequenceNo := 1;
            "Table ID" := TableID;
            "Document Type" := DocType;
            "Document No." := DocNo;
            "Salespers./Purch. Code" := SalespersonPurchaser;
            "Sequence No." := NewSequenceNo;
            "Approval Code" := ApprovalTemplates."Approval Code";
            "Sender ID" := USERID;
            Amount := ApprovalAmount;
            "Amount (LCY)" := ApprovalAmountLCY;
            "Currency Code" := CurrencyCode;
            "Approver ID" := ApproverId;
            if ApproverId = USERID then
                Status := Status::Approved
            else
                Status := Status::Created;
            "Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
            "Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            "Last Modified By User ID" := USERID;
            "Due Date" := CALCDATE(ApprovalSetup."Due Date Formula", TODAY);
            "Approval Type" := ApprovalTemplates."Approval Type";
            "Limit Type" := ApprovalTemplates."Limit Type";
            "Available Credit Limit (LCY)" := ExeedAmountLCY;
            INSERT;
        end;
    end;

    procedure ApproveApprovalRequest(ApprovalEntry: Record "Approval Entry"): Boolean;
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ApprovalSetup: Record "Approval Setup";
        NextApprovalEntry: Record "Approval Entry";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleasePurchaseDoc: Codeunit "Release Purchase Document";
        ApprovalMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZPR";
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
            if NextApprovalEntry.FINDFIRST then begin
                if NextApprovalEntry.Status = NextApprovalEntry.Status::Open then
                    exit(false);

                NextApprovalEntry.Status := NextApprovalEntry.Status::Open;
                NextApprovalEntry."Date-Time Sent for Approval" := CREATEDATETIME(TODAY, TIME);
                NextApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                NextApprovalEntry."Last Modified By User ID" := USERID;
                NextApprovalEntry.MODIFY;
                if ApprovalSetup.GET then
                    if ApprovalSetup.Approvals then begin
                        if ApprovalEntry."Table ID" = DATABASE::"Sales Header" then begin
                            if SalesHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") then
                                ApprovalMgtNotification.SendSalesApprovalsMail(SalesHeader, NextApprovalEntry);
                        end else
                            if PurchaseHeader.GET(NextApprovalEntry."Document Type", NextApprovalEntry."Document No.") then
                                ApprovalMgtNotification.SendPurchaseApprovalsMail(PurchaseHeader, NextApprovalEntry);
                    end;
                exit(false);
            end;
            if ApprovalEntry."Table ID" = DATABASE::"Sales Header" then begin
                if SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                    ReleaseSalesDoc.RUN(SalesHeader);
            end else
                if PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                    ReleasePurchaseDoc.RUN(PurchaseHeader);
            exit(true);
        end;
    end;

    procedure RejectApprovalRequest(ApprovalEntry: Record "Approval Entry");
    var
        ApprovalSetup: Record "Approval Setup";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleasePurchaseDoc: Codeunit "Release Purchase Document";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
        SendMail: Boolean;
    begin
        if ApprovalEntry."Table ID" <> 0 then begin
            ApprovalSetup.GET;
            ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
            ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
            ApprovalEntry."Last Modified By User ID" := USERID;
            ApprovalEntry.MODIFY;
            if ApprovalSetup.Rejections then
                SendRejectionMail(ApprovalEntry, AppManagement);
            ApprovalEntry.SETCURRENTKEY("Table ID", "Document Type", "Document No.", "Sequence No.");
            ApprovalEntry.SETRANGE("Table ID", ApprovalEntry."Table ID");
            ApprovalEntry.SETRANGE("Document Type", ApprovalEntry."Document Type");
            ApprovalEntry.SETRANGE("Document No.", ApprovalEntry."Document No.");
            ApprovalEntry.SETFILTER(Status, '<>%1&<>%2', ApprovalEntry.Status::Canceled, ApprovalEntry.Status::Rejected);
            if ApprovalEntry.FIND('-') then
                repeat
                    SendMail := false;
                    if (ApprovalEntry.Status = ApprovalEntry.Status::Open) or
                       (ApprovalEntry.Status = ApprovalEntry.Status::Approved)
                    then
                        SendMail := true;

                    ApprovalEntry.Status := ApprovalEntry.Status::Rejected;
                    ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                    ApprovalEntry."Last Modified By User ID" := USERID;
                    ApprovalEntry.MODIFY;
                    if ApprovalSetup.Rejections and SendMail then
                        SendRejectionMail(ApprovalEntry, AppManagement);
                until ApprovalEntry.NEXT = 0;
            if ApprovalSetup.Rejections then
                AppManagement.SendMail;
            if ApprovalEntry."Table ID" = DATABASE::"Sales Header" then begin
                SalesHeader.SETCURRENTKEY("Document Type", "No.");
                SalesHeader.SETRANGE("Document Type", ApprovalEntry."Document Type");
                SalesHeader.SETRANGE("No.", ApprovalEntry."Document No.");
                if SalesHeader.FINDFIRST then
                    ReleaseSalesDoc.Reopen(SalesHeader);
            end else begin
                PurchaseHeader.SETCURRENTKEY("Document Type", "No.");
                PurchaseHeader.SETRANGE("Document Type", ApprovalEntry."Document Type");
                PurchaseHeader.SETRANGE("No.", ApprovalEntry."Document No.");
                if PurchaseHeader.FINDFIRST then
                    ReleasePurchaseDoc.Reopen(PurchaseHeader);
            end;
        end;
    end;

    procedure DelegateApprovalRequest(ApprovalEntry: Record "Approval Entry");
    var
        UserSetup: Record "User Setup";
        ApprovalSetup: Record "Approval Setup";
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
    begin
        UserSetup.SETRANGE("User ID", ApprovalEntry."Approver ID");
        if not UserSetup.FINDFIRST then
            ERROR(Text005, ApprovalEntry."Approver ID");
        if not ApprovalSetup.GET then
            ERROR(Text004);

        if UserSetup.Substitute <> '' then begin
            UserSetup.SETRANGE("User ID", UserSetup.Substitute);
            if UserSetup.FINDFIRST then begin
                ApprovalEntry."Last Modified By User ID" := USERID;
                ApprovalEntry."Last Date-Time Modified" := CREATEDATETIME(TODAY, TIME);
                ApprovalEntry."Approver ID" := UserSetup."User ID";
                ApprovalEntry.MODIFY;

                case ApprovalEntry."Table ID" of
                    DATABASE::"Sales Header":
                        begin
                            if ApprovalSetup.Delegations then
                                if SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                                    AppManagement.SendSalesDelegationsMail(SalesHeader, ApprovalEntry);
                        end;
                    DATABASE::"Purchase Header":
                        begin
                            if ApprovalSetup.Delegations then
                                if PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                                    AppManagement.SendPurchaseDelegationsMail(PurchaseHeader, ApprovalEntry);
                        end;
                end;
            end;
        end else
            ERROR(Text007, UserSetup.FIELDCAPTION(Substitute), UserSetup."User ID");
    end;

    procedure PrePostApprovalCheck(var SalesHeader: Record "Sales Header"; var PurchaseHeader: Record "Purchase Header"): Boolean;
    begin
        if SalesHeader."No." <> '' then
            exit(PrePostApprovalCheckSales(SalesHeader));
        exit(PrePostApprovalCheckPurch(PurchaseHeader));
    end;

    procedure PrePostApprovalCheckSales(var SalesHeader: Record "Sales Header"): Boolean;
    begin
        if not CheckApprSalesDocument(SalesHeader) then
            exit(true);
        if not (SalesHeader.Status in [SalesHeader.Status::Released, SalesHeader.Status::"Pending Prepayment"]) then
            ERROR(Text013, SalesHeader."Document Type", SalesHeader."No.");
        exit(true);
    end;

    procedure PrePostApprovalCheckPurch(var PurchaseHeader: Record "Purchase Header"): Boolean;
    begin
        if not CheckApprPurchaseDocument(PurchaseHeader) then
            exit(true);
        if not (PurchaseHeader.Status in [PurchaseHeader.Status::Released, PurchaseHeader.Status::"Pending Prepayment"]) then
            ERROR(Text013, PurchaseHeader."Document Type", PurchaseHeader."No.");
        exit(true);
    end;

    procedure MoveApprvalEntryToPosted(var ApprovalEntry: Record "Approval Entry"; ToTableId: Integer; ToNo: Code[20]);
    var
        PostedApprvlEntry: Record "Posted Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        PostedApprovalCommentLine: Record "Posted Approval Comment Line";
    begin
        with ApprovalEntry do begin
            if FIND('-') then
                repeat
                    PostedApprvlEntry.INIT;
                    PostedApprvlEntry.TRANSFERFIELDS(ApprovalEntry);
                    PostedApprvlEntry."Table ID" := ToTableId;
                    PostedApprvlEntry."Document No." := ToNo;
                    PostedApprvlEntry.INSERT;
                until NEXT = 0;
            ApprovalCommentLine.SETRANGE("Table ID", "Table ID");
            ApprovalCommentLine.SETRANGE("Document Type", "Document Type");
            ApprovalCommentLine.SETRANGE("Document No.", "Document No.");
            if ApprovalCommentLine.FIND('-') then
                repeat
                    PostedApprovalCommentLine.INIT;
                    PostedApprovalCommentLine.TRANSFERFIELDS(ApprovalCommentLine);
                    PostedApprovalCommentLine."Entry No." := 0;
                    PostedApprovalCommentLine."Table ID" := ToTableId;
                    PostedApprovalCommentLine."Document No." := ToNo;
                    PostedApprovalCommentLine.INSERT(true);
                until ApprovalCommentLine.NEXT = 0;
        end;
    end;

    procedure DeleteApprovalEntry(TableId: Integer; DocumentType: Option; DocumentNo: Code[20]);
    var
        ApprovalEntry: Record "Approval Entry";
    begin
        ApprovalEntry.SETRANGE("Table ID", TableId);
        ApprovalEntry.SETRANGE("Document Type", DocumentType);
        ApprovalEntry.SETRANGE("Document No.", DocumentNo);
        DeleteApprovalCommentLine(TableId, DocumentType, DocumentNo);
        if ApprovalEntry.FINDFIRST then
            ApprovalEntry.DELETEALL;
    end;

    procedure DeleteApprovalCommentLine(TableId: Integer; DocumentType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order"; DocumentNo: Code[20]);
    var
        ApprovalCommentLine: Record "Approval Comment Line";
    begin
        ApprovalCommentLine.SETRANGE("Table ID", TableId);
        ApprovalCommentLine.SETRANGE("Document Type", DocumentType);
        ApprovalCommentLine.SETRANGE("Document No.", DocumentNo);
        if ApprovalCommentLine.FINDFIRST then
            ApprovalCommentLine.DELETEALL;
    end;

    procedure DeletePostedApprovalEntry(TableId: Integer; DocumentNo: Code[20]);
    var
        PostedApprovalEntry: Record "Posted Approval Entry";
    begin
        PostedApprovalEntry.SETRANGE("Table ID", TableId);
        PostedApprovalEntry.SETRANGE("Document No.", DocumentNo);
        DeletePostedApprvlCommentLine(TableId, DocumentNo);
        if PostedApprovalEntry.FINDFIRST then
            PostedApprovalEntry.DELETEALL;
    end;

    procedure DeletePostedApprvlCommentLine(TableId: Integer; DocumentNo: Code[20]);
    var
        PostedApprovalCommentLine: Record "Posted Approval Comment Line";
    begin
        PostedApprovalCommentLine.SETRANGE("Entry No.", TableId);
        PostedApprovalCommentLine.SETRANGE("Document No.", DocumentNo);
        if PostedApprovalCommentLine.FINDFIRST then
            PostedApprovalCommentLine.DELETEALL;
    end;

    procedure DisableSalesApproval(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order");
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.RESET;
        with SalesHeader do begin
            if FIND('-') then
                repeat
                    CancelSalesApprovalRequest(SalesHeader, false, false);
                until NEXT = 0;
        end;
        MESSAGE(Text014, SELECTSTR(1 + DocType, Text028));
    end;

    procedure DisablePurchaseApproval(DocType: Option Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order");
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.RESET;
        with PurchaseHeader do begin
            SETRANGE("Document Type", DocType);
            repeat
                CancelPurchaseApprovalRequest(PurchaseHeader, false, false);
            until NEXT = 0;
        end;
        MESSAGE(Text014, SELECTSTR(1 + DocType, Text028));
    end;

    procedure CalcSalesDocAmount(SalesHeader: Record "Sales Header"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    var
        TempSalesLine: Record "Sales Line" temporary;
        TotalSalesLine: Record "Sales Line";
        TotalSalesLineLCY: Record "Sales Line";
        SalesPost: Codeunit "Sales-Post";
        TempAmount: array[5] of Decimal;
        VAtText: Text[30];
    begin
        SalesPost.GetSalesLines(SalesHeader, TempSalesLine, 0);
        CLEAR(SalesPost);
        SalesPost.SumSalesLinesTemp(
          SalesHeader, TempSalesLine, 0, TotalSalesLine, TotalSalesLineLCY,
          TempAmount[1], VAtText, TempAmount[2], TempAmount[3], TempAmount[4]);
        ApprovalAmount := TotalSalesLine.Amount;
        ApprovalAmountLCY := TotalSalesLineLCY.Amount;
    end;

    procedure CalcPurchaseDocAmount(PurchaseHeader: Record "Purchase Header"; var ApprovalAmount: Decimal; var ApprovalAmountLCY: Decimal);
    var
        TempPurchaseLine: Record "Purchase Line" temporary;
        TotalPurchaseLine: Record "Purchase Line";
        TotalPurchaseLineLCY: Record "Purchase Line";
        PurchasePost: Codeunit "Purch.-Post";
        TempAmount: Decimal;
        VAtText: Text[30];
    begin
        PurchasePost.GetPurchLines(PurchaseHeader, TempPurchaseLine, 0);
        CLEAR(PurchasePost);
        PurchasePost.SumPurchLinesTemp(
          PurchaseHeader, TempPurchaseLine, 0, TotalPurchaseLine, TotalPurchaseLineLCY,
          TempAmount, VAtText);
        ApprovalAmount := TotalPurchaseLine.Amount;
        ApprovalAmountLCY := TotalPurchaseLineLCY.Amount;
    end;

    procedure InsertAddApprovers(AppTemplate: Record "Approval Templates");
    var
        AddApprovers: Record "Additional Approvers";
    begin
        CLEAR(AddApproversTemp);
        AddApprovers.SETCURRENTKEY("Sequence No.");
        AddApprovers.SETRANGE("Approval Code", AppTemplate."Approval Code");
        AddApprovers.SETRANGE("Approval Type", AppTemplate."Approval Type");
        AddApprovers.SETRANGE("Document Type", AppTemplate."Document Type");
        AddApprovers.SETRANGE("Limit Type", AppTemplate."Limit Type");
        if AddApprovers.FIND('-') then
            repeat
                AddApproversTemp := AddApprovers;
                AddApproversTemp.INSERT;
            until AddApprovers.NEXT = 0;
    end;

    procedure CheckCreditLimit(SalesHeader: Record "Sales Header"): Decimal;
    var
        Customer: Record Customer;
    begin
        if not Customer.GET(SalesHeader."Bill-to Customer No.") then
            exit(0);
        exit(Customer.CalcAvailableCredit);
    end;

    procedure CheckAddApprovers(AppTemplate: Record "Approval Templates");
    begin
        AppTemplate.CALCFIELDS("Additional Approvers");
        if AppTemplate."Additional Approvers" then
            InsertAddApprovers(AppTemplate);
    end;

    procedure SetupDefualtApprovals();
    var
        ApprovalCode: Record "Approval Code";
        ApprovalTemplate: Record "Approval Templates";
        AllObj: Record AllObj;
    begin
        if not ApprovalCode.FIND('-') then begin
            AllObj.SETRANGE("Object Type", AllObj."Object Type"::Table);
            AllObj.SETRANGE("Object ID", DATABASE::"Sales Header");
            if AllObj.FINDFIRST then;
            InsertDefaultApprovalCode(ApprovalCode, Text100, Text101, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text102, Text103, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text104, Text105, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text106, Text107, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text108, Text109, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text110, Text111, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text124, Text125, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text126, Text127, AllObj."Object ID", AllObj."Object Name");

            AllObj.SETRANGE("Object Type", AllObj."Object Type"::Table);
            AllObj.SETRANGE("Object ID", DATABASE::"Purchase Header");
            if AllObj.FINDFIRST then;
            InsertDefaultApprovalCode(ApprovalCode, Text112, Text113, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text114, Text115, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text116, Text117, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text118, Text119, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text120, Text121, AllObj."Object ID", AllObj."Object Name");
            InsertDefaultApprovalCode(ApprovalCode, Text122, Text123, AllObj."Object ID", AllObj."Object Name");
        end;

        if not ApprovalTemplate.FINDFIRST and ApprovalCode.FIND('-') then
            repeat
                InsertDefaultApprovalTemplate(ApprovalTemplate, ApprovalCode);
            until ApprovalCode.NEXT = 0;
    end;

    procedure InsertDefaultApprovalCode(var ApprovalCodeRec: Record "Approval Code"; ApprovalCode: Code[20]; ApprovalName: Text[100]; TableId: Integer; Tablename: Text[50]);
    begin
        ApprovalCodeRec.INIT;
        ApprovalCodeRec.Code := ApprovalCode;
        ApprovalCodeRec.Description := ApprovalName;
        ApprovalCodeRec."Linked To Table Name" := Tablename;
        ApprovalCodeRec."Linked To Table No." := TableId;
        ApprovalCodeRec.INSERT;
    end;

    procedure InsertDefaultApprovalTemplate(var ApprovalTemplate: Record "Approval Templates"; ApprovalCode: Record "Approval Code");
    begin
        case true of
            ApprovalCode.Code = Text100:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Quote;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text102:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Approval Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text104:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Invoice;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text106:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Credit Memo";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text108:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Return Order";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text110:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Blanket Order";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text112:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::Approver;
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Quote;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Request Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text114:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Approval Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text116:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Invoice;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text118:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Credit Memo";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text120:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::"Sales Pers./Purchaser";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Return Order";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text122:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::"Blanket Order";
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"No Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text124:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Order;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Credit Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
            ApprovalCode.Code = Text126:
                begin
                    ApprovalTemplate.INIT;
                    ApprovalTemplate."Approval Code" := ApprovalCode.Code;
                    ApprovalTemplate."Approval Type" := ApprovalTemplate."Approval Type"::" ";
                    ApprovalTemplate."Document Type" := ApprovalTemplate."Document Type"::Invoice;
                    ApprovalTemplate."Limit Type" := ApprovalTemplate."Limit Type"::"Credit Limits";
                    ApprovalTemplate."Table ID" := ApprovalCode."Linked To Table No.";
                    ApprovalTemplate.INSERT;
                end;
        end;
    end;

    procedure TestSalesPrepayment(SalesHeader: Record "Sales Header"): Boolean;
    var
        SalesLines: Record "Sales Line";
    begin
        SalesLines.SETRANGE("Document Type", SalesHeader."Document Type");
        SalesLines.SETRANGE("Document No.", SalesHeader."No.");
        SalesLines.SETFILTER("Prepmt. Line Amount", '<>%1', 0);
        if SalesLines.FIND('-') then
            repeat
                if SalesLines."Prepmt. Amt. Inv." <> SalesLines."Prepmt. Line Amount" then
                    exit(true);
            until SalesLines.NEXT = 0;
    end;

    procedure TestPurchasePrepayment(PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        PurchaseLines: Record "Purchase Line";
    begin
        PurchaseLines.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLines.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLines.SETFILTER("Prepmt. Line Amount", '<>%1', 0);
        if PurchaseLines.FIND('-') then
            repeat
                if PurchaseLines."Prepmt. Amt. Inv." <> PurchaseLines."Prepmt. Line Amount" then
                    exit(true);
            until PurchaseLines.NEXT = 0;
    end;

    procedure TestSetup();
    var
        ApprovalSetup: Record "Approval Setup";
    begin
        if not ApprovalSetup.GET then
            ERROR(Text004);
    end;

    procedure TestSalesPayment(SalesHeader: Record "Sales Header"): Boolean;
    var
        SalesSetup: Record "Sales & Receivables Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvHeader: Record "Sales Invoice Header";
        EntryFound: Boolean;
    begin
        EntryFound := false;
        SalesSetup.GET;
        if SalesSetup."Check Prepmt. when Posting" then begin
            SalesInvHeader.SETCURRENTKEY("Prepayment Order No.", "Prepayment Invoice");
            SalesInvHeader.SETRANGE("Prepayment Order No.", SalesHeader."No.");
            SalesInvHeader.SETRANGE("Prepayment Invoice", true);
            if SalesInvHeader.FIND('-') then
                repeat
                    CustLedgerEntry.SETCURRENTKEY("Document No.");
                    CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Invoice);
                    CustLedgerEntry.SETRANGE("Document No.", SalesInvHeader."No.");
                    CustLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>%1', 0);
                    if CustLedgerEntry.FINDFIRST then
                        EntryFound := true;
                until (SalesInvHeader.NEXT = 0) or EntryFound;
        end;
        if EntryFound then
            exit(true);

        exit(false);
    end;

    procedure TestPurchasePayment(PurchaseHeader: Record "Purchase Header"): Boolean;
    var
        PurchaseSetup: Record "Purchases & Payables Setup";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        PurchaseInvHeader: Record "Purch. Inv. Header";
        EntryFound: Boolean;
    begin
        EntryFound := false;
        PurchaseSetup.GET;
        if PurchaseSetup."Check Prepmt. when Posting" then begin
            PurchaseInvHeader.SETCURRENTKEY("Prepayment Order No.", "Prepayment Invoice");
            PurchaseInvHeader.SETRANGE("Prepayment Order No.", PurchaseHeader."No.");
            PurchaseInvHeader.SETRANGE("Prepayment Invoice", true);
            if PurchaseInvHeader.FIND('-') then
                repeat
                    VendLedgerEntry.SETCURRENTKEY("Document No.");
                    VendLedgerEntry.SETRANGE("Document Type", VendLedgerEntry."Document Type"::Invoice);
                    VendLedgerEntry.SETRANGE("Document No.", PurchaseInvHeader."No.");
                    VendLedgerEntry.SETFILTER("Remaining Amt. (LCY)", '<>%1', 0);
                    if VendLedgerEntry.FINDFIRST then
                        EntryFound := true;
                until (PurchaseInvHeader.NEXT = 0) or EntryFound;
        end;
        if EntryFound then
            exit(true);

        exit(false);
    end;

    procedure SendRejectionMail(ApprovalEntry: Record "Approval Entry"; AppManagement: Codeunit "Approvals Mgt Noti.-IBIZPR");
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        case ApprovalEntry."Table ID" of
            DATABASE::"Sales Header":
                begin
                    if SalesHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                        AppManagement.SendSalesRejectionsMail(SalesHeader, ApprovalEntry);
                end;
            DATABASE::"Purchase Header":
                begin
                    if PurchaseHeader.GET(ApprovalEntry."Document Type", ApprovalEntry."Document No.") then
                        AppManagement.SendPurchaseRejectionsMail(PurchaseHeader, ApprovalEntry);
                end;
        end;
    end;

    procedure FinishApprovalEntrySales(var SalesHeader: Record "Sales Header"; ApprovalSetup: Record "Approval Setup"; var MessageID: Option " ",AutomaticPrePayment,AutomaticPayment,AutomaticRelease,RequiresApproval);
    var
        DocReleased: Boolean;
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZPR";
    begin
        DocReleased := false;
        with ApprovalEntry do begin
            INIT;
            SETRANGE("Table ID", DATABASE::"Sales Header");
            SETRANGE("Document Type", SalesHeader."Document Type");
            SETRANGE("Document No.", SalesHeader."No.");
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
                                ApprovalsMgtNotification.SendSalesApprovalsMail(SalesHeader, ApprovalEntry);
                        end;
                until NEXT = 0;

            if not IsOpenStatusSet then begin
                SETRANGE(Status);
                FINDLAST;
                DocReleased := ApproveApprovalRequest(ApprovalEntry);
                if DocReleased then
                    SalesHeader.FIND;
            end;

            if DocReleased then begin
                MessageID := MessageID::AutomaticRelease;
                if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                    if TestSalesPrepayment(SalesHeader) then
                        MessageID := MessageID::AutomaticPrePayment
                    else
                        if TestSalesPayment(SalesHeader) then
                            MessageID := MessageID::AutomaticPayment;
            end else begin
                SalesHeader.Status := SalesHeader.Status::"Pending Approval";
                SalesHeader.MODIFY(true);
                MessageID := MessageID::RequiresApproval;
            end;
        end;
    end;

    procedure FinishApprovalEntryPurchase(var PurchHeader: Record "Purchase Header"; ApprovalSetup: Record "Approval Setup"; var MessageID: Option " ",AutomaticPrePayment,AutomaticPayment,AutomaticRelease,RequiresApproval);
    var
        DocReleased: Boolean;
        ApprovalEntry: Record "Approval Entry";
        ApprovalsMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZPR";
    begin
        DocReleased := false;
        with ApprovalEntry do begin
            INIT;
            SETRANGE("Table ID", DATABASE::"Purchase Header");
            SETRANGE("Document Type", PurchHeader."Document Type");
            SETRANGE("Document No.", PurchHeader."No.");
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
                                ApprovalsMgtNotification.SendPurchaseApprovalsMail(PurchHeader, ApprovalEntry);
                        end;
                until NEXT = 0;

            if not IsOpenStatusSet then begin
                SETRANGE(Status);
                FINDLAST;
                DocReleased := ApproveApprovalRequest(ApprovalEntry);
                if DocReleased then
                    PurchHeader.FIND;
            end;

            if DocReleased then begin
                MessageID := MessageID::AutomaticRelease;
                if PurchHeader."Document Type" = PurchHeader."Document Type"::Order then
                    if TestPurchasePrepayment(PurchHeader) then
                        MessageID := MessageID::AutomaticPrePayment
                    else
                        if TestPurchasePayment(PurchHeader) then
                            MessageID := MessageID::AutomaticPayment;
            end else begin
                PurchHeader.Status := PurchHeader.Status::"Pending Approval";
                PurchHeader.MODIFY(true);
                MessageID := MessageID::RequiresApproval;
            end;
        end;
    end;

    local procedure GetQuoteErrorText(ApprovalTemplates: Record "Approval Templates"; PurchaseHeader: Record "Purchase Header") ErrorText: Text;
    begin
        ErrorText :=
          STRSUBSTNO(
            Text026,
            FORMAT(ApprovalTemplates."Limit Type"),
            FORMAT(PurchaseHeader."Document Type"::Quote));
    end;

    local procedure IsCreditLimits(ApprovalTemplates: Record "Approval Templates"): Boolean;
    begin
        exit(ApprovalTemplates."Limit Type" = ApprovalTemplates."Limit Type"::"Credit Limits")
    end;
}

