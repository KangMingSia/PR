codeunit 27003012 "Approvals Mgt Noti.-IBIZRFQ"
{
    Permissions = TableData "Overdue Approval Entry" = i;

    trigger OnRun();
    begin
    end;

    var
        AppSetup: Record "Approval Setup";
        // SMTP: Codeunit "SMTP Mail";//20.0.0.0
        EmailMessage: Codeunit "Email Message";//20.0.0.0
        Email: Codeunit Email;//20.0.0.0
        MailManagement: Codeunit "Mail Management";
        SenderName: Text[100];
        SenderAddress: Text[100];
        Recipient: Text[100];
        Subject: Text[100];
        Body: Text;
        InStreamTemplate: InStream;
        InSReadChar: Text[1];
        CharNo: Text[4];
        I: Integer;
        Text001: Label 'Sales %1';
        Text002: Label 'Purchase %1';
        Text003: Label 'requires your approval.';
        Text004: Label 'To view your documents for approval, please use this link';
        Text005: Label 'Customer';
        WebViewTok: Label 'Web view', Comment = 'Opens the document in the Microsoft Dynamics NAV web client';
        Text007: Label 'Microsoft Dynamics NAV: %1 Mail';
        Text008: Label 'Approval';
        Text009: Label 'Cancellation';
        Text010: Label 'Rejection';
        Text011: Label 'Delegation';
        Text012: Label 'Overdue Approvals';
        Text013: Label 'Microsoft Dynamics NAV Document Approval System';
        Text014: Label 'has been cancelled.';
        Text016: Label 'has been rejected.';
        Text018: Label 'Vendor';
        Text020: Label 'has been delegated.';
        Text022: Label 'Overdue approval';
        Text030: Label 'Not yet overdue';
        Text033: Label 'Rejection comments:';
        Text040: Label 'You must import an Approval Template in Approval Setup.';
        Text041: Label 'You must import an Overdue Approval Template in Approval Setup.';
        FromUser: Text[100];
        Text042: Label 'Available Credit Limit (LCY)';
        Text043: Label 'Request Amount (LCY)';
        MailCreated: Boolean;
        OpenBracketTok: Label '(', Comment = '{Locked=true}';
        CloseBracketTok: Label ')', Comment = '{Locked=true}';
        Text100: Label 'NAV: %1 Mail';

    procedure SendSalesApprovalsMail(SalesHeader: Record "Sales Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        SetTemplate(ApprovalEntry);
        Subject := STRSUBSTNO(Text007, Text008);
        Body := Text013;
        RecipientList.Add(Recipient);
        // SMTP.CreateMessage(SenderName, SenderAddress, RecipientList, Subject, Body);//20.0.0.0
        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                // SMTP.AppendBody(Body);//20.0.0.0
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillSalesTemplate(Body, CharNo, SalesHeader, ApprovalEntry, 0);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        // SMTP.Send;//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendPurchaseApprovalsMail(PurchaseHeader: Record "Purchase Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        SetTemplate(ApprovalEntry);
        Subject := STRSUBSTNO(Text007, Text008);
        Body := Text013;

        RecipientList.Add(Recipient);
        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillPurchaseTemplate(Body, CharNo, PurchaseHeader, ApprovalEntry, 0);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendSalesCancellationsMail(SalesHeader: Record "Sales Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplate(ApprovalEntry);
            Subject := STRSUBSTNO(Text007, Text009);
            Body := Text013;
            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
            Body := '';

            while InStreamTemplate.EOS = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillSalesTemplate(Body, CharNo, SalesHeader, ApprovalEntry, 1);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;
            EmailMessage.AppendToBody(Body);//20.0.0.0
            MailCreated := true;
        end;
    end;

    procedure SendPurchaseCancellationsMail(PurchaseHeader: Record "Purchase Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplate(ApprovalEntry);
            Subject := STRSUBSTNO(Text007, Text009);
            Body := Text013;

            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
            Body := '';

            while InStreamTemplate.EOS = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillPurchaseTemplate(Body, CharNo, PurchaseHeader, ApprovalEntry, 1);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;
            EmailMessage.AppendToBody(Body);//20.0.0.0
            MailCreated := true;
        end;
    end;

    procedure SendSalesRejectionsMail(SalesHeader: Record "Sales Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
        AppCommentLine: Record "Approval Comment Line";
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplate(ApprovalEntry);
            Subject := STRSUBSTNO(Text007, Text010);
            Body := Text013;

            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // SMTP.AddCC(RecipientList);//20.0.0.1>>

            Body := '';

            while InStreamTemplate.EOS = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillSalesTemplate(Body, CharNo, SalesHeader, ApprovalEntry, 2);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;
            EmailMessage.AppendToBody(Body);//20.0.0.0

            ApprovalEntry.CALCFIELDS(Comment);
            if ApprovalEntry.Comment then begin
                AppCommentLine.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
                AppCommentLine.SETRANGE("Table ID", ApprovalEntry."Table ID");
                AppCommentLine.SETRANGE("Document Type", ApprovalEntry."Document Type");
                AppCommentLine.SETRANGE("Document No.", ApprovalEntry."Document No.");
                if AppCommentLine.FIND('-') then begin
                    Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>', Text033);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    repeat
                        BuildCommentLine(AppCommentLine);
                    until AppCommentLine.NEXT = 0;
                end;
            end;
            MailCreated := true;
        end;
    end;

    procedure SendPurchaseRejectionsMail(PurchaseHeader: Record "Purchase Header"; ApprovalEntry: Record "Approval Entry");
    var
        AppCommentLine: Record "Approval Comment Line";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplate(ApprovalEntry);
            Subject := STRSUBSTNO(Text007, Text010);
            Body := Text013;

            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // SMTP.AddCC(RecipientList);//20.0.0.1>>

            Body := '';

            while InStreamTemplate.EOS = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillPurchaseTemplate(Body, CharNo, PurchaseHeader, ApprovalEntry, 2);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;
            EmailMessage.AppendToBody(Body);//20.0.0.0

            ApprovalEntry.CALCFIELDS(Comment);
            if ApprovalEntry.Comment then begin
                AppCommentLine.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
                AppCommentLine.SETRANGE("Table ID", ApprovalEntry."Table ID");
                AppCommentLine.SETRANGE("Document Type", ApprovalEntry."Document Type");
                AppCommentLine.SETRANGE("Document No.", ApprovalEntry."Document No.");
                if AppCommentLine.FIND('-') then begin
                    Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>',
                        Text033);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    repeat
                        BuildCommentLine(AppCommentLine);
                    until AppCommentLine.NEXT = 0;
                end;
            end;

            MailCreated := true;
        end;
    end;

    procedure SendSalesDelegationsMail(SalesHeader: Record "Sales Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetTemplate(ApprovalEntry);
        Subject := STRSUBSTNO(Text007, Text011);
        Body := Text013;

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        // SMTP.AddCC(RecipientList);//20.0.0.1>>

        Body := '';

        while InStreamTemplate.EOS = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillSalesTemplate(Body, CharNo, SalesHeader, ApprovalEntry, 3);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendPurchaseDelegationsMail(PurchaseHeader: Record "Purchase Header"; ApprovalEntry: Record "Approval Entry");
    var
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetTemplate(ApprovalEntry);
        Subject := STRSUBSTNO(Text007, Text011);
        Body := Text013;

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        // SMTP.AddCC(RecipientList);//20.0.0.1>>
        Body := '';

        while InStreamTemplate.EOS = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillPurchaseTemplate(Body, CharNo, PurchaseHeader, ApprovalEntry, 3);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendOverdueApprovalsMail(Reciever: Text[100]; var AppEntriesNotDue: Record "Approval Entry"; var AppEntriesDue: Record "Approval Entry");
    var
        AppSetUp: Record "Approval Setup";
        UserSetup: Record "User Setup";
        QtyAppEntries: Integer;
        QytAppEntDue: Integer;
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetOverdueTemplate;
        AppSetUp.GET;
        AppSetUp.TESTFIELD("Approval Administrator");
        UserSetup.GET(AppSetUp."Approval Administrator");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";
        Recipient := Reciever;
        Subject := STRSUBSTNO(Text007, Text012);
        Body := Text013;

        QtyAppEntries := AppEntriesNotDue.COUNT;
        QytAppEntDue := AppEntriesDue.COUNT;

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                case CharNo of
                    '1':
                        Body := '';
                    '2':
                        Body := STRSUBSTNO(Body, Text004);
                    '5':
                        Body := STRSUBSTNO(Body, GetApprovalEntriesWinUri);
                    '19':
                        Body := STRSUBSTNO(Body, GetApprovalEntriesWebUri);
                    '20':
                        Body := STRSUBSTNO(Body, WebViewTok);
                    '21':
                        Body := STRSUBSTNO(Body, OpenBracketTok);
                    '22':
                        Body := STRSUBSTNO(Body, CloseBracketTok);
                end;
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0

        // Find Approval entries overdue and append to template
        if QytAppEntDue > 0 then begin
            Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>', Text022);
            EmailMessage.AppendToBody(Body);//20.0.0.0
            if AppEntriesDue.FIND('-') then
                repeat
                    BuildOverdueLine(AppEntriesDue);
                    InsertOverdueLogEntries(AppEntriesDue);
                until AppEntriesDue.NEXT = 0;
        end;

        // Find Approval entries not overdue and append to template
        if QtyAppEntries > 0 then begin
            Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>', Text030);
            EmailMessage.AppendToBody(Body);//20.0.0.0
            if AppEntriesNotDue.FIND('-') then
                repeat
                    BuildDueLine(AppEntriesNotDue);
                until AppEntriesNotDue.NEXT = 0;
        end;
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure GetEmailAddress(AppEntry: Record "Approval Entry");
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.GET(AppEntry."Sender ID");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";
        UserSetup.GET(AppEntry."Approver ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";
        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";
    end;

    procedure CheckEntriesDue(DueDate: Date);
    var
        UserSetup: Record "User Setup";
        AppEnt: Record "Approval Entry" temporary;
        AppEntDue: Record "Approval Entry" temporary;
        AppEntries: Record "Approval Entry";
        ApprovalMgt: Codeunit "Approvals Mgt Noti.-IBIZPR";
        OverdueFound: Boolean;
    begin
        if UserSetup.FIND('-') then begin
            UserSetup.TESTFIELD("E-Mail");
            repeat
                OverdueFound := false;
                AppEnt.DELETEALL;
                AppEntDue.DELETEALL;
                AppEntries.SETCURRENTKEY("Approver ID", Status);
                AppEntries.SETRANGE("Approver ID", UserSetup."User ID");
                AppEntries.SETRANGE(Status, AppEntries.Status::Open);
                if AppEntries.FIND('-') then begin
                    repeat
                        if AppEntries."Due Date" <= DueDate then begin
                            AppEntDue := AppEntries;
                            AppEntDue.INSERT;
                            OverdueFound := true;
                        end else begin
                            AppEnt := AppEntries;
                            AppEnt.INSERT;
                        end;
                    until AppEntries.NEXT = 0;
                    if OverdueFound then
                        ApprovalMgt.SendOverdueApprovalsMail(UserSetup."E-Mail", AppEnt, AppEntDue);
                end;
            until UserSetup.NEXT = 0;
        end;
    end;

    procedure FillSalesTemplate(var Body: Text; FieldNo: Text[30]; Header: Record "Sales Header"; AppEntry: Record "Approval Entry"; CalledFrom: Option Approve,Cancel,Reject,Delegate);
    begin
        case FieldNo of
            '1':
                Body := STRSUBSTNO(Text001, Header."Document Type");
            '2':
                Body := STRSUBSTNO(Body, Header."No.");
            '3':
                case CalledFrom of
                    CalledFrom::Approve:
                        Body := STRSUBSTNO(Body, Text003);
                    CalledFrom::Cancel:
                        Body := STRSUBSTNO(Body, Text014);
                    CalledFrom::Reject:
                        Body := STRSUBSTNO(Body, Text016);
                    CalledFrom::Delegate:
                        Body := STRSUBSTNO(Body, Text020);
                end;
            '4':
                if CalledFrom in [CalledFrom::Approve, CalledFrom::Cancel, CalledFrom::Reject, CalledFrom::Delegate] then
                    Body := '';
            '5':
                Body := STRSUBSTNO(Body, GetApprovalEntriesWinUri);
            '6':
                Body := STRSUBSTNO(Body, Text004);
            '7':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION(Amount));
            '8':
                Body := STRSUBSTNO(Body, AppEntry."Currency Code");
            '9':
                Body := STRSUBSTNO(Body, AppEntry.Amount);
            '10':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION("Amount (LCY)"));
            '11':
                Body := STRSUBSTNO(Body, AppEntry."Amount (LCY)");
            '12':
                Body := STRSUBSTNO(Body, Text005);
            '13':
                Body := STRSUBSTNO(Body, Header."Bill-to Customer No.");
            '14':
                Body := STRSUBSTNO(Body, Header."Bill-to Name");
            '15':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION("Due Date"));
            '16':
                Body := STRSUBSTNO(Body, AppEntry."Due Date");
            '17':
                Body := Text042;
            '18':
                Body := STRSUBSTNO(Body, AppEntry."Available Credit Limit (LCY)");
            '19':
                Body := STRSUBSTNO(Body, GetApprovalEntriesWebUri);
            '20':
                Body := STRSUBSTNO(Body, WebViewTok);
            '21':
                Body := STRSUBSTNO(Body, OpenBracketTok);
            '22':
                Body := STRSUBSTNO(Body, CloseBracketTok);
        end;
    end;

    procedure FillPurchaseTemplate(var Body: Text; FieldNo: Text[30]; Header: Record "Purchase Header"; AppEntry: Record "Approval Entry"; CalledFrom: Option Approve,Cancel,Reject,Delegate);
    begin
        case FieldNo of
            '1':
                Body := STRSUBSTNO(Text002, Header."Document Type");
            '2':
                Body := STRSUBSTNO(Body, Header."No.");
            '3':
                case CalledFrom of
                    CalledFrom::Approve:
                        Body := STRSUBSTNO(Body, Text003);
                    CalledFrom::Cancel:
                        Body := STRSUBSTNO(Body, Text014);
                    CalledFrom::Reject:
                        Body := STRSUBSTNO(Body, Text016);
                    CalledFrom::Delegate:
                        Body := STRSUBSTNO(Body, Text020);
                end;
            '4':
                if CalledFrom in [CalledFrom::Approve, CalledFrom::Cancel, CalledFrom::Reject, CalledFrom::Delegate] then
                    Body := '';
            '5':
                Body := STRSUBSTNO(Body, GetApprovalEntriesWinUri);
            '6':
                Body := STRSUBSTNO(Body, Text004);
            '7':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION(Amount));
            '8':
                Body := STRSUBSTNO(Body, AppEntry."Currency Code");
            '9':
                Body := STRSUBSTNO(Body, AppEntry.Amount);
            '10':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION("Amount (LCY)"));
            '11':
                Body := STRSUBSTNO(Body, AppEntry."Amount (LCY)");
            '12':
                Body := STRSUBSTNO(Body, Text018);
            '13':
                Body := STRSUBSTNO(Body, Header."Pay-to Vendor No.");
            '14':
                Body := STRSUBSTNO(Body, Header."Pay-to Name");
            '15':
                Body := STRSUBSTNO(Body, AppEntry.FIELDCAPTION("Due Date"));
            '16':
                Body := STRSUBSTNO(Body, AppEntry."Due Date");
            '17':
                begin
                    if AppEntry."Limit Type" = AppEntry."Limit Type"::"Request Limits" then
                        Body := Text043
                    else
                        Body := ' ';
                end;
            '18':
                begin
                    if AppEntry."Limit Type" = AppEntry."Limit Type"::"Request Limits" then
                        Body := STRSUBSTNO(Body, AppEntry."Amount (LCY)")
                    else
                        Body := ' ';
                end;
            '19':
                Body := STRSUBSTNO(Body, GetApprovalEntriesWebUri);
            '20':
                Body := STRSUBSTNO(Body, WebViewTok);
            '21':
                Body := STRSUBSTNO(Body, OpenBracketTok);
            '22':
                Body := STRSUBSTNO(Body, CloseBracketTok);
        end;
    end;

    procedure SetTemplate(AppEntry: Record "Approval Entry");
    begin
        AppSetup.GET;
        AppSetup.CALCFIELDS("Approval Template");
        if not AppSetup."Approval Template".HASVALUE then
            ERROR(Text040);
        AppSetup."Approval Template".CREATEINSTREAM(InStreamTemplate);
        SenderName := COMPANYNAME;
        CLEAR(SenderAddress);
        CLEAR(Recipient);
        GetEmailAddress(AppEntry);
    end;

    procedure SetOverdueTemplate();
    begin
        AppSetup.GET;
        AppSetup.CALCFIELDS("Overdue Template");
        if not AppSetup."Overdue Template".HASVALUE then
            ERROR(Text041);
        AppSetup."Overdue Template".CREATEINSTREAM(InStreamTemplate);
        SenderName := COMPANYNAME;
    end;

    procedure BuildOverdueLine(AppEntry: Record "Approval Entry");
    var
        DueLine: Text[500];
        TextType: Text[30];
    begin
        case AppEntry."Table ID" of
            36:
                TextType := 'Sales';
            38:
                TextType := 'Purchase';
        end;
        DueLine := '<p class="MsoNormal"><span style="font-family:Arial size 2">' +
          FORMAT(TextType, 10) + FORMAT(AppEntry."Document Type", 15) +
          FORMAT(AppEntry."Document No.", 20) + FORMAT(AppEntry."Due Date", 10) + '</span></p>';
        // SMTP.AppendBody(DueLine);//20.0.0.0
        EmailMessage.AppendToBody(DueLine);//20.0.0.0
    end;

    procedure BuildDueLine(AppEntry: Record "Approval Entry");
    var
        TextType: Text[500];
        DueLine: Text[254];
    begin
        case AppEntry."Table ID" of
            36:
                TextType := 'Sales';
            38:
                TextType := 'Purchase';
        end;
        DueLine := '<p class="MsoNormal"><span style="font-family:Arial size 2">' +
          FORMAT(TextType, 10) + FORMAT(AppEntry."Document Type", 15) +
          FORMAT(AppEntry."Document No.", 20) + FORMAT(AppEntry."Due Date", 10) + '</span></p>';
        // SMTP.AppendBody(DueLine);//20.0.0.0
        EmailMessage.AppendToBody(DueLine);//20.0.0.0
    end;

    procedure BuildCommentLine(Comments: Record "Approval Comment Line");
    var
        CommentLine: Text[500];
    begin
        CommentLine := '<p class="MsoNormal"><span style="font-family:Arial size 2">' +
          Comments.Comment + '</span></p>';
        // SMTP.AppendBody(CommentLine);//20.0.0.0
        EmailMessage.AppendToBody(CommentLine);//20.0.0.0
    end;

    procedure InsertOverdueLogEntries(AppEntry: Record "Approval Entry");
    var
        User: Record User;
        LogEntries: Record "Overdue Approval Entry";
    begin
        LogEntries."Approver ID" := AppEntry."Approver ID";
        User.SETRANGE("User Name", AppEntry."Approver ID");
        if User.FINDFIRST then
            LogEntries."Sent to Name" := COPYSTR(User."Full Name", 1, MAXSTRLEN(LogEntries."Sent to Name"));

        LogEntries."Table ID" := AppEntry."Table ID";
        LogEntries."Document Type" := AppEntry."Document Type";
        LogEntries."Document No." := AppEntry."Document No.";
        LogEntries."Sent to ID" := AppEntry."Approver ID";
        LogEntries."Sent Date" := TODAY;
        LogEntries."Sent Time" := TIME;
        LogEntries."E-Mail" := Recipient;
        LogEntries."Sequence No." := AppEntry."Sequence No.";
        LogEntries."Due Date" := AppEntry."Due Date";
        LogEntries."Approval Code" := AppEntry."Approval Code";
        LogEntries.INSERT;
    end;

    procedure LaunchCheck(RunDate: Date);
    var
        ApprovalMannagement: Codeunit "Approvals Mgt Noti.-IBIZPR";
    begin
        ApprovalMannagement.CheckEntriesDue(RunDate);
    end;

    procedure SendMail();
    begin
        Email.Send(EmailMessage);//20.0.0.0
        MailCreated := false;
    end;

    local procedure GetApprovalEntriesWinUri(): Text;
    begin
        // Generates a url to the Approval Entries list page, such as
        // dynamicsnav://server:port/instance/company/runpage?page=658<?Tenant=tenantId>.
        exit(GETURL(CLIENTTYPE::Windows, COMPANYNAME, OBJECTTYPE::Page, PAGE::"Approval Entries"));
    end;

    local procedure GetApprovalEntriesWebUri(): Text;
    begin
        // Generates a url to the Approval Entries list page, such as
        // http://server:port/instance/WebClient/company/runpage?page=658<?Tenant=tenantId>.
        exit(GETURL(CLIENTTYPE::Web, COMPANYNAME, OBJECTTYPE::Page, PAGE::"Approval Entries"));
    end;

    procedure SetTemplateRFQ(AppEntry: Record "Approval Entry");
    var
        AppSetup: Record "Approval Setup";
        TempPath: Text[1000];
    begin
        AppSetup.GET;
        AppSetup.CALCFIELDS("PR Approval Template");
        if not AppSetup."PR Approval Template".HASVALUE then
            ERROR(Text040);
        AppSetup."PR Approval Template".CREATEINSTREAM(InStreamTemplate);
        SenderName := COMPANYNAME;
        CLEAR(SenderAddress);
        CLEAR(Recipient);
        GetEmailAddress(AppEntry);
    end;

    procedure SendRFQApprovalsMail(PurchaseReq: Record "RFQ Comparison"; ApprovalEntry: Record "Approval Entry"; TotalBudget: Decimal);
    var
        UserSetup: Record "User Setup";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetTemplateRFQ(ApprovalEntry);
        Subject := STRSUBSTNO(Text100, Text008);
        Body := Text013;

        UserSetup.GET(ApprovalEntry."Approver ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";

        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";

        UserSetup.GET(ApprovalEntry."Sender ID");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        PurchaseReq.CALCFIELDS("RFQ Total Amount", "RFQ Total Amount (LCY)");
        while InStreamTemplate.EOS() = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillRFQTemplateNew(Body, CharNo, PurchaseReq, ApprovalEntry, 0);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;

        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendRFQPCApprovedMail(PurchaseReq: Record "RFQ Comparison"; ApprovalEntry: Record "Approval Entry");
    var
        UserSetup: Record "User Setup";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetTemplateRFQ(ApprovalEntry);
        Subject := STRSUBSTNO(Text100, 'RFQ Approved');
        Body := Text013;

        UserSetup.GET(ApprovalEntry."Approver ID");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";

        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";

        UserSetup.GET(ApprovalEntry."Sender ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS() = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillRFQTemplateNew(Body, CharNo, PurchaseReq, ApprovalEntry, 0);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendRFQRejectionsMail(RFQHeader: Record "RFQ Comparison"; ApprovalEntry: Record "Approval Entry");
    var
        AppCommentLine: Record "Approval Comment Line";
        Usersetup: Record "User Setup";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplateRFQ(ApprovalEntry);
            Subject := STRSUBSTNO(Text100, 'Approval Rejected');
            Body := Text013;

            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // SMTP.AddCC(RecipientList);//20.0.0.1>>
            Body := '';

            while InStreamTemplate.EOS() = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillRFQTemplateNew(Body, CharNo, RFQHeader, ApprovalEntry, 2);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;

            EmailMessage.AppendToBody(Body);//20.0.0.0

            // Append Comment Lines
            ApprovalEntry.CALCFIELDS(Comment);
            if ApprovalEntry.Comment then begin
                AppCommentLine.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
                AppCommentLine.SETRANGE("Table ID", ApprovalEntry."Table ID");
                AppCommentLine.SETRANGE("Document Type", ApprovalEntry."Document Type");
                AppCommentLine.SETRANGE("Document No.", ApprovalEntry."Document No.");
                if AppCommentLine.FIND('-') then begin
                    Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>',
                        Text033);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    repeat
                        BuildCommentLine(AppCommentLine);
                    until AppCommentLine.NEXT = 0;
                end;
            end;
            MailCreated := true;

        end;
        Email.Send(EmailMessage);//20.0.0.0
        MailCreated := false;
    end;

    procedure FillRFQTemplateNew(var Body: Text[254]; TextNo: Text[30]; RFQHeader: Record "RFQ Comparison"; AppEntry: Record "Approval Entry"; CalledFrom: Option Approve,Cancel,Reject,Delegate);
    begin
        case TextNo of
            '1':
                Body := STRSUBSTNO('Document Type :', '');
            // '2':
            //   Body := STRSUBSTNO(Body, RFQHeader."PR Document Type");
            '3':
                Body := STRSUBSTNO(Body, 'Document No. :');
            '4':
                Body := STRSUBSTNO(Body, RFQHeader."No.");
            '5':
                Body := STRSUBSTNO(Body, 'Description :');
            '6':
                Body := STRSUBSTNO(Body, RFQHeader.Description);
            '7':
                Body := STRSUBSTNO(Body, 'Expected Receipt date :');
            //   '8':
            //     Body := STRSUBSTNO(Body, RFQHeader."Due Date");

            '9':
                Body := STRSUBSTNO(Body, 'Document Amount       :');
            '10':
                Body := STRSUBSTNO(Body, RFQHeader."RFQ Total Amount");
            '11':
                Body := STRSUBSTNO(Body, 'Document Amount(LCY)  :');
            '12':
                Body := STRSUBSTNO(Body, RFQHeader."RFQ Total Amount (LCY)");
        end;

    end;

    procedure SendRFQCApprovalsMail(RFQComparision: Record "RFQ Comparison"; ApprovalEntry: Record "Approval Entry"; TotalBudget: Decimal);
    var
        UserSetup: Record "User Setup";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        SetTemplateRFQ(ApprovalEntry);
        Subject := STRSUBSTNO(Text100, Text008);
        Body := Text013;

        UserSetup.GET(ApprovalEntry."Sender ID");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";

        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";

        UserSetup.GET(ApprovalEntry."Approver ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS() = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillRFQCTemplateNew(Body, CharNo, RFQComparision, ApprovalEntry.Amount, ApprovalEntry."Amount (LCY)", TotalBudget);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure SendRFQCRejectionsMail(RFQComparision: Record "RFQ Comparison"; ApprovalEntry: Record "Approval Entry"; Totalbudget: Decimal);
    var
        AppCommentLine: Record "Approval Comment Line";
        Usersetup: Record "User Setup";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        if MailCreated then begin
            GetEmailAddress(ApprovalEntry);
            // if Recipient <> SenderAddress then begin//20.0.0.1>>
            //     SMTP.AddCC(RecipientList);
            // end;
        end else begin
            SetTemplateRFQ(ApprovalEntry);
            Subject := STRSUBSTNO(Text100, 'Approval Rejected');
            Body := Text013;

            EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
            // SMTP.AddCC(RecipientList);//20.0.0.1>>
            Body := '';

            while InStreamTemplate.EOS() = false do begin
                InStreamTemplate.READTEXT(InSReadChar, 1);
                if InSReadChar = '%' then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                    if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                    if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                        Body := Body + '1';
                        CharNo := InSReadChar;
                        while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                            if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                            if (InSReadChar >= '0') and (InSReadChar <= '9') then
                                CharNo := CharNo + InSReadChar;
                        end;
                    end else
                        Body := Body + InSReadChar;
                    FillRFQCTemplateNew(Body, CharNo, RFQComparision, ApprovalEntry.Amount, ApprovalEntry."Amount (LCY)", Totalbudget);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := InSReadChar;
                end else begin
                    Body := Body + InSReadChar;
                    I := I + 1;
                    if I = 500 then begin
                        EmailMessage.AppendToBody(Body);//20.0.0.0
                        Body := '';
                        I := 0;
                    end;
                end;
            end;

            EmailMessage.AppendToBody(Body);//20.0.0.0

            // Append Comment Lines
            ApprovalEntry.CALCFIELDS(Comment);
            if ApprovalEntry.Comment then begin
                AppCommentLine.SETCURRENTKEY("Table ID", "Document Type", "Document No.");
                AppCommentLine.SETRANGE("Table ID", ApprovalEntry."Table ID");
                AppCommentLine.SETRANGE("Document Type", ApprovalEntry."Document Type");
                AppCommentLine.SETRANGE("Document No.", ApprovalEntry."Document No.");
                if AppCommentLine.FIND('-') then begin
                    Body := STRSUBSTNO('<p class="MsoNormal"><font face="Arial size 2"><b>%1</b></font></p>',
                        Text033);
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    repeat
                        BuildCommentLine(AppCommentLine);
                    until AppCommentLine.NEXT = 0;
                end;
            end;
            MailCreated := true;

        end;
        Email.Send(EmailMessage);//20.0.0.0
        MailCreated := false;
    end;

    procedure FillRFQCTemplateNew(var Body: Text[254]; TextNo: Text[30]; RFQComparision: Record "RFQ Comparison"; Amount: Decimal; AmountLCy: Decimal; TotalBudGet: Decimal);
    begin
        case TextNo of
            '1':
                Body := STRSUBSTNO('Document Type :', '');
            '2':
                Body := STRSUBSTNO(Body, 'RFQ Comparison');
            '3':
                Body := STRSUBSTNO(Body, 'Document No.');
            '4':
                Body := STRSUBSTNO(Body, RFQComparision."No.");
            '5':
                Body := STRSUBSTNO(Body, 'Amount       :');
            '6':
                Body := STRSUBSTNO(Body, Amount);
            '7':
                Body := STRSUBSTNO(Body, 'Amount(LCY)  :');
            '8':
                Body := STRSUBSTNO(Body, AmountLCy);
        end;
    end;

    procedure SendPRBudgetNotificationMail(PurchaseReq: Record "RFQ Comparison"; TotalAmout: Decimal; "TotalAmount(LCY)": Decimal; TotalBudget: Decimal);
    var
        UserSetup: Record "User Setup";
        DocumentAppr: Record "Document Approval Setup";
        ApprovalTemp: Record "Approval Templates";
        ApprovalEntry: Record "Approval Entry";
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        AppSetup.GET;
        AppSetup.CALCFIELDS("PR Approval Template");
        if not AppSetup."PR Approval Template".HASVALUE then
            ERROR(Text040);
        AppSetup."PR Approval Template".CREATEINSTREAM(InStreamTemplate);
        SenderName := COMPANYNAME;
        CLEAR(SenderAddress);
        CLEAR(Recipient);

        Subject := STRSUBSTNO(Text100, 'Budget Notification');
        Body := Text013;

        ApprovalTemp.RESET;
        ApprovalTemp.SETRANGE("No. series", PurchaseReq."No. series");
        ApprovalTemp.SETRANGE("Document Type", ApprovalTemp."Document Type"::PR);
        if ApprovalTemp.FINDFIRST then
            DocumentAppr.RESET;
        DocumentAppr.SETRANGE("Approval Routing", ApprovalTemp."Approval Routing");
        DocumentAppr.SETRANGE("Finance User", true);
        if DocumentAppr.FINDFIRST then
            UserSetup.GET(DocumentAppr."User ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";

        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";

        UserSetup.GET(PurchaseReq."Co-ordinator");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS() = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillRFQBudgetTemplate(Body, CharNo, PurchaseReq, TotalAmout, "TotalAmount(LCY)", TotalBudget);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure FillRFQBudgetTemplate(var Body: Text[254]; TextNo: Text[30]; RFQHeader: Record "RFQ Comparison"; TotalAmount: Decimal; TotalAmountLCY: Decimal; TotalBudget: Decimal);
    begin
        case TextNo of
            '1':
                Body := STRSUBSTNO('Document Type :', '');
            //  '2':
            //    Body := STRSUBSTNO(Body, RFQHeader."PR Document Type");
            '3':
                Body := STRSUBSTNO(Body, 'Document No.');
            '4':
                Body := STRSUBSTNO(Body, RFQHeader."No.");
            '5':
                Body := STRSUBSTNO(Body, 'Amount       :');
            '6':
                Body := STRSUBSTNO(Body, TotalAmount);
            '7':
                Body := STRSUBSTNO(Body, 'Amount(LCY)  :');
            '8':
                Body := STRSUBSTNO(Body, TotalAmountLCY);
        end;
    end;

    procedure SendRFQBudgetNotificationMail(RFQComparision: Record "RFQ Comparison"; POLine: Record "Purchase Line"; totalbudget: Decimal);
    var
        UserSetup: Record "User Setup";
        DocumentAppr: Record "Document Approval Setup";
        ApprovalTemp: Record "Approval Templates";
        ApprovalEntry: Record "Approval Entry";
        TempPath: Text[1000];
        RecipientList: List of [Text];
    begin
        RecipientList.Add(Recipient);
        AppSetup.GET;
        AppSetup.CALCFIELDS("PR Approval Template");
        if not AppSetup."PR Approval Template".HASVALUE then
            ERROR(Text040);

        AppSetup."PR Approval Template".CREATEINSTREAM(InStreamTemplate);
        Subject := STRSUBSTNO(Text100, 'Insufficient budget Notification');
        Body := Text013;

        ApprovalTemp.RESET;
        ApprovalTemp.SETRANGE("No. series", RFQComparision."No. series");
        ApprovalTemp.SETRANGE("Document Type", ApprovalTemp."Document Type"::RFQC);
        if ApprovalTemp.FINDFIRST then
            DocumentAppr.RESET;
        DocumentAppr.SETRANGE("Approval Routing", ApprovalTemp."Approval Routing");
        DocumentAppr.SETRANGE("Finance User", true);
        if DocumentAppr.FINDFIRST then
            UserSetup.GET(DocumentAppr."User ID");
        UserSetup.TESTFIELD("E-Mail");
        Recipient := UserSetup."E-Mail";

        UserSetup.GET(USERID);
        UserSetup.TESTFIELD("E-Mail");
        FromUser := UserSetup."E-Mail";

        UserSetup.GET(RFQComparision."Co-ordinator");
        UserSetup.TESTFIELD("E-Mail");
        SenderAddress := UserSetup."E-Mail";

        EmailMessage.Create(RecipientList, Subject, Body, true);//20.0.0.0
        Body := '';

        while InStreamTemplate.EOS() = false do begin
            InStreamTemplate.READTEXT(InSReadChar, 1);
            if InSReadChar = '%' then begin
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
                if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                if (InSReadChar >= '0') and (InSReadChar <= '9') then begin
                    Body := Body + '1';
                    CharNo := InSReadChar;
                    while (InSReadChar >= '0') and (InSReadChar <= '9') do begin
                        if InStreamTemplate.READTEXT(InSReadChar, 1) <> 0 then;
                        if (InSReadChar >= '0') and (InSReadChar <= '9') then
                            CharNo := CharNo + InSReadChar;
                    end;
                end else
                    Body := Body + InSReadChar;
                FillRFQCTemplateNew(Body, CharNo, RFQComparision, POLine."Outstanding Amount", POLine."Outstanding Amount (LCY)", totalbudget);
                EmailMessage.AppendToBody(Body);//20.0.0.0
                Body := InSReadChar;
            end else begin
                Body := Body + InSReadChar;
                I := I + 1;
                if I = 500 then begin
                    EmailMessage.AppendToBody(Body);//20.0.0.0
                    Body := '';
                    I := 0;
                end;
            end;
        end;
        EmailMessage.AppendToBody(Body);//20.0.0.0
        Email.Send(EmailMessage);//20.0.0.0
    end;

    procedure FillRFQBudgetTemplate(var Body: Text[254]; TextNo: Text[30]; RFQComparision: Record "RFQ Comparison"; POLine: Record "Purchase Line"; CalledFrom: Option Approve,Cancel,Reject,Delegate);
    begin
        case TextNo of
            '1':
                Body := STRSUBSTNO(Text002, 'RFQ');
            '2':
                Body := STRSUBSTNO(Body, RFQComparision."No.");
            '3':
                case CalledFrom of
                    CalledFrom::Approve:
                        Body := STRSUBSTNO(Body, Text003);
                    CalledFrom::Cancel:
                        Body := STRSUBSTNO(Body, Text014);
                    CalledFrom::Reject:
                        Body := STRSUBSTNO(Body, Text016);
                    CalledFrom::Delegate:
                        Body := STRSUBSTNO(Body, Text020);
                end;
            '4':
                case CalledFrom of
                    CalledFrom::Approve:
                        Body := '';
                    CalledFrom::Cancel:
                        Body := '';
                    CalledFrom::Reject:
                        Body := '';
                    CalledFrom::Delegate:
                        Body := '';
                end;
            '5':
                Body := '';
            '6':
                Body := '';
            '7':
                Body := STRSUBSTNO(Body, POLine.FIELDCAPTION(Amount));
            '8':
                Body := STRSUBSTNO(Body, '');
            '9':
                Body := STRSUBSTNO(Body, POLine.Amount);
            '10':
                Body := STRSUBSTNO(Body, POLine.FIELDCAPTION(POLine."Amount Including VAT"));
            '11':
                Body := STRSUBSTNO(Body, POLine."Amount Including VAT");
            '12':
                Body := STRSUBSTNO(Body, '');
            '13':
                Body := STRSUBSTNO(Body, '');
            '14':
                Body := STRSUBSTNO(Body, '');
            '15':
                Body := STRSUBSTNO(Body, '');
            '16':
                Body := STRSUBSTNO(Body, '');
        end;
    end;
}

