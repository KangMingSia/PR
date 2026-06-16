page 27003014 "Approval Setup"
{
    Caption = 'Approval Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Approval Setup";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Due Date Formula"; "Due Date Formula")
                {
                    ApplicationArea = all;
                }
                field("Approval Administrator"; "Approval Administrator")
                {
                    ApplicationArea = all;
                }
                field("Request Rejection Comment"; "Request Rejection Comment")
                {
                    ApplicationArea = all;
                }
            }
            group(Notification)
            {
                Caption = 'Notification';
                group("Notify User about:")
                {
                    Caption = 'Notify User about:';
                    field(Approvals; Approvals)
                    {
                        ApplicationArea = all;
                    }
                    field(Cancellations; Cancellations)
                    {
                        ApplicationArea = all;
                    }
                    field(Rejections; Rejections)
                    {
                        ApplicationArea = all;
                    }
                    field(Delegations; Delegations)
                    {
                        ApplicationArea = all;
                    }
                }
                group("Overdue Approvals")
                {
                    Caption = 'Overdue Approvals';
                    field("Last Run Date"; "Last Run Date")
                    {
                        ApplicationArea = all;
                        Editable = false;
                    }
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                Visible = false;
                ApplicationArea = all;
            }
            systempart(Control1905767507; Notes)
            {
                Visible = false;
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Mail Templates")
            {
                Caption = '&Mail Templates';
                Image = Template;
                group("Approval Mail Template")
                {
                    Caption = 'Approval Mail Template';
                    Image = Template;
                    action(Import)
                    {
                        Caption = 'Import';
                        Ellipsis = true;
                        Image = Import;
                        ApplicationArea = all;
                        trigger OnAction();
                        var
                            OutStr: OutStream;
                        begin
                            CALCFIELDS("Approval Template");
                            if "Approval Template".HASVALUE then
                                AppTemplateExists := true;

                            //Version 19.0.0.0>>
                            // "Approval Template" := TempBlob.Blob;
                            OutStr.Write("Approval Template");
                            TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);
                            //Version 19.0.0.0<<
                            if AppTemplateExists then
                                if not CONFIRM(Text002, false, FIELDCAPTION("Approval Template")) then
                                    exit;

                            CurrPage.SAVERECORD;
                        end;
                    }
                    action("E&xport")
                    {
                        Caption = 'E&xport';
                        Ellipsis = true;
                        Image = Export;
                        ApplicationArea = all;
                        trigger OnAction();
                        var
                            OutStr: OutStream;
                        begin
                            CALCFIELDS("Approval Template");
                            if "Approval Template".HASVALUE then begin

                                //Version 19.0.0.0>>
                                // TempBlob.Blob := "Approval Template";
                                OutStr.Write("Approval Template");
                                TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);
                                //Version 19.0.0.0<<
                            end;
                        end;
                    }
                    action(Delete)
                    {
                        Caption = 'Delete';
                        Ellipsis = true;
                        Image = Delete;
                        ApplicationArea = all;
                        trigger OnAction();
                        begin
                            CALCFIELDS("Approval Template");
                            if "Approval Template".HASVALUE then
                                if CONFIRM(Text003, false, FIELDCAPTION("Approval Template")) then begin
                                    CLEAR("Approval Template");
                                    CurrPage.SAVERECORD;
                                end;
                        end;
                    }
                }
                group("Overdue Mail Template")
                {
                    Caption = 'Overdue Mail Template';
                    Image = Overdue;
                    action(Action27)
                    {
                        Caption = 'Import';
                        Ellipsis = true;
                        Image = Import;
                        ApplicationArea = all;
                        trigger OnAction();
                        var
                            InStr: InStream;
                        begin
                            CALCFIELDS("Overdue Template");
                            OverdueTemplateExists := "Overdue Template".HASVALUE;

                            //Version 19.0.0.0>>
                            // "Overdue Template" := TempBlob.Blob;
                            InStr.Read("Overdue Template");
                            TempBlob.CreateInStream(InStr, TextEncoding::Windows);
                            //Version 19.0.0.0<<

                            if OverdueTemplateExists then
                                if not CONFIRM(Text002, false, FIELDCAPTION("Overdue Template")) then
                                    exit;

                            CurrPage.SAVERECORD;
                        end;
                    }
                    action(Action28)
                    {
                        Caption = 'E&xport';
                        Ellipsis = true;
                        Image = Export;
                        ApplicationArea = all;
                        trigger OnAction();
                        var
                            OutStr: OutStream;
                        begin
                            CALCFIELDS("Overdue Template");
                            if "Overdue Template".HASVALUE then begin

                                //Version 19.0.0.0>>
                                // TempBlob.Blob := "Overdue Template";
                                OutStr.Write("Overdue Template");
                                TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);
                                //Version 19.0.0.0<<
                            end;
                        end;
                    }
                    action(Action29)
                    {
                        Caption = 'Delete';
                        Ellipsis = true;
                        Image = Delete;
                        ApplicationArea = all;
                        trigger OnAction();
                        begin
                            CALCFIELDS("Overdue Template");
                            if "Overdue Template".HASVALUE then
                                if CONFIRM(Text003, false, FIELDCAPTION("Overdue Template")) then begin
                                    CLEAR("Overdue Template");
                                    CurrPage.SAVERECORD;
                                end;
                        end;
                    }
                }
                group("PR Mail Template")
                {
                    Caption = 'PR Mail Template';
                    Image = Overdue;
                    action(Action1000000002)
                    {
                        Caption = 'Import';
                        Ellipsis = true;
                        Image = Import;
                        ApplicationArea = all;
                        trigger OnAction();
                        var
                            InStr: InStream;
                        begin
                            CALCFIELDS("PR Approval Template");
                            AppTemplateExists := "PR Approval Template".HASVALUE;

                            //Version 19.0.0.0>>
                            // "PR Approval Template" := TempBlob.Blob;
                            InStr.Read("PR Approval Template");
                            TempBlob.CreateInStream(InStr, TextEncoding::Windows);
                            //Version 19.0.0.0<<

                            if AppTemplateExists then
                                if not CONFIRM(Text002, false, FIELDCAPTION("PR Approval Template")) then
                                    exit;

                            CurrPage.SAVERECORD;
                        end;
                    }
                    action(Action1000000001)
                    {
                        Caption = 'E&xport';
                        Ellipsis = true;
                        Image = Export;
                        ApplicationArea = all;
                        trigger OnAction();

                        var
                            OutStr: OutStream;
                        begin
                            CALCFIELDS("PR Approval Template");
                            if "PR Approval Template".HASVALUE then begin

                                //Version 19.0.0.0>>
                                // TempBlob.Blob := "PR Approval Template";
                                OutStr.Write("PR Approval Template");
                                TempBlob.CreateOutStream(OutStr, TextEncoding::Windows);
                                //Version 19.0.0.0<<
                            end;
                        end;
                    }
                    action(Action1000000000)
                    {
                        Caption = 'Delete';
                        Ellipsis = true;
                        Image = Delete;
                        ApplicationArea = all;
                        trigger OnAction();
                        begin
                            CALCFIELDS("Overdue Template");
                            if "PR Approval Template".HASVALUE then
                                if CONFIRM(Text003, false, FIELDCAPTION("PR Approval Template")) then begin
                                    CLEAR("PR Approval Template");
                                    CurrPage.SAVERECORD;
                                end;
                        end;
                    }
                }
            }
            group("&Overdue")
            {
                Caption = '&Overdue';
                Image = Overdue;
                action("Send Overdue Mails")
                {
                    Caption = 'Send Overdue Mails';
                    Image = OverdueMail;
                    ApplicationArea = all;
                    trigger OnAction();
                    begin
                        if CONFIRM(STRSUBSTNO(Text004, TODAY), true) then begin
                            ApprMgtNotification.LaunchCheck(TODAY);
                            "Last Run Date" := TODAY;
                            "Last Run Time" := TIME;
                            MODIFY;
                            CurrPage.UPDATE;
                        end;
                    end;
                }
                action("Overdue Log Entries")
                {
                    Caption = 'Overdue Log Entries';
                    Image = OverdueEntries;
                    RunObject = Page "Overdue Approval Entries";
                    ApplicationArea = all;
                }
            }
        }
        area(processing)
        {
            action("&User Setup")
            {
                Caption = '&User Setup';
                Image = UserSetup;
                Promoted = true;
                ApplicationArea = all;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Approval User Setup";
            }
            action(NotificationMailSetup)
            {
                Caption = '&Notification Email Setup';
                Image = MailSetup;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = all;
                PromotedIsBig = true;
                RunObject = Page "Email Accounts";
            }
        }
    }

    trigger OnOpenPage();
    begin
        RESET;
        if not GET then begin
            INIT;
            INSERT;
        end;
    end;

    var
        // TempBlob: Record TempBlob; //Version 19.0.0.0
        TempBlob: Codeunit "Temp Blob";//Version 19.0.0.0
        TempBlobCodeUnit: Codeunit "Temp Blob";
        ApprMgtNotification: Codeunit "Approvals Mgt Noti.-IBIZPR";
        FileMgt: Codeunit "File Management";
        OverdueTemplateExists: Boolean;
        Text002: Label 'Do you want to replace the existing %1?';
        Text003: Label 'Do you want to delete the template %1?';
        AppTemplateExists: Boolean;
        Text004: Label 'Do you want to run the overdue check by the %1?';
}

