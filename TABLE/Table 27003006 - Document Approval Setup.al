table 27003006 "Document Approval Setup"
{
    Caption = 'Document Approval Setup';

    fields
    {
        field(1; "User ID"; Code[50])
        {
            TableRelation = User;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                LookupUserID("User ID");
            end;

            trigger OnValidate();
            begin
                ValidateUserID("User ID");
            end;
        }
        field(2; "Approval Routing"; Code[20])
        {
        }
        field(3; "Approver ID"; Code[50])
        {
            Caption = 'Approver ID';
            TableRelation = "User Setup"."User ID";
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                LookupUserID("Approver ID");
            end;

            trigger OnValidate();
            begin
                ValidateUserID("Approver ID");
            end;
        }
        field(4; "Salespers./Purch. Code"; Code[10])
        {
            Caption = 'Salespers./Purch. Code';
            TableRelation = "Salesperson/Purchaser".Code;
            ValidateTableRelation = false;

            trigger OnValidate();
            var
                UserSetup: Record "User Setup";
            begin
                if "Salespers./Purch. Code" <> '' then begin
                    UserSetup.SETCURRENTKEY("Salespers./Purch. Code");
                    UserSetup.SETRANGE("Salespers./Purch. Code", "Salespers./Purch. Code");
                    if UserSetup.FIND('-') then
                        ERROR(Text001, "Salespers./Purch. Code", UserSetup."User ID");
                end;
            end;
        }
        field(12; "Sales Amount Approval Limit"; Integer)
        {
            BlankZero = true;
            Caption = 'Sales Amount Approval Limit';

            trigger OnValidate();
            begin
                if "Unlimited Sales Approval" and ("Sales Amount Approval Limit" <> 0) then
                    ERROR(Text003, FIELDCAPTION("Sales Amount Approval Limit"), FIELDCAPTION("Unlimited Sales Approval"));
                if "Sales Amount Approval Limit" < 0 then
                    ERROR(Text005);
            end;
        }
        field(13; "Purchase Amount Approval Limit"; Integer)
        {
            BlankZero = true;
            Caption = 'Purchase Amount Approval Limit';

            trigger OnValidate();
            begin
                if "Unlimited Purchase Approval" and ("Purchase Amount Approval Limit" <> 0) then
                    ERROR(Text003, FIELDCAPTION("Purchase Amount Approval Limit"), FIELDCAPTION("Unlimited Purchase Approval"));
                if "Purchase Amount Approval Limit" < 0 then
                    ERROR(Text005);
            end;
        }
        field(14; "Unlimited Sales Approval"; Boolean)
        {
            Caption = 'Unlimited Sales Approval';

            trigger OnValidate();
            begin
                if "Unlimited Sales Approval" then
                    "Sales Amount Approval Limit" := 0;
            end;
        }
        field(15; "Unlimited Purchase Approval"; Boolean)
        {
            Caption = 'Unlimited Purchase Approval';

            trigger OnValidate();
            begin
                if "Unlimited Purchase Approval" then
                    "Purchase Amount Approval Limit" := 0;
            end;
        }
        field(16; Substitute; Code[50])
        {
            Caption = 'Substitute';
            TableRelation = User;
            ValidateTableRelation = false;

            trigger OnLookup();
            begin
                LookupUserID("User ID");
            end;

            trigger OnValidate();
            begin
                ValidateUserID("User ID");
            end;
        }
        field(17; "E-Mail"; Text[100])
        {
            Caption = 'E-Mail';
        }
        field(19; "Request Amount Approval Limit"; Integer)
        {
            BlankZero = true;
            Caption = 'Request Amount Approval Limit';

            trigger OnValidate();
            begin
                if "Unlimited Request Approval" and ("Request Amount Approval Limit" <> 0) then
                    ERROR(Text003, FIELDCAPTION("Request Amount Approval Limit"), FIELDCAPTION("Unlimited Request Approval"));
                if "Request Amount Approval Limit" < 0 then
                    ERROR(Text005);
            end;
        }
        field(20; "Unlimited Request Approval"; Boolean)
        {
            Caption = 'Unlimited Request Approval';

            trigger OnValidate();
            begin
                if "Unlimited Request Approval" then
                    "Request Amount Approval Limit" := 0;
            end;
        }
        field(21; "Finance User"; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "User ID", "Approval Routing")
        {
        }
        key(Key2; "Salespers./Purch. Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure LookupUserID(VAR UserName: Code[50]): Boolean
    var
        SID: GUID;
    begin
        EXIT(LookupUser(UserName, SID));
    end;

    procedure LookupUser(VAR UserName: Code[50]; VAR SID: GUID): Boolean
    var
        User: Record User;
    begin
        User.RESET;
        User.SETCURRENTKEY("User Name");
        User."User Name" := UserName;
        IF User.FIND('=><') THEN;
        IF PAGE.RUNMODAL(PAGE::Users, User) = ACTION::LookupOK THEN BEGIN
            UserName := User."User Name";
            SID := User."User Security ID";
            EXIT(TRUE);
        END;

        EXIT(FALSE);
    end;

    procedure ValidateUserID(UserName: Code[50])
    var
        User: Record User;
        Text000: Label 'The user name %1 does not exist.';
    begin
        IF UserName <> '' THEN BEGIN
            User.SETCURRENTKEY("User Name");
            User.SETRANGE("User Name", UserName);
            IF NOT User.FINDFIRST THEN BEGIN
                User.RESET;
                IF NOT User.ISEMPTY THEN
                    ERROR(Text000, UserName);
            END;
        END;
    end;

    var
        LoginMgt: Codeunit "User Management";
        Text001: Label 'The %1 Salesperson/Purchaser code is already assigned to another User ID %2.';
        Text003: Label '"You cannot have both a %1 and %2. "';
        Text005: Label 'You cannot have approval limits less than zero.';
}

