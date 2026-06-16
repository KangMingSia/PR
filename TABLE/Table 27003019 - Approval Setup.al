table 27003019 "Approval Setup"
{
    Caption = 'Approval Setup';

    fields
    {
        field(1; "Primary Key"; Code[20])
        {
            Caption = 'Primary Key';
        }
        field(2; "Due Date Formula"; DateFormula)
        {
            Caption = 'Due Date Formula';

            trigger OnValidate();
            begin
                if COPYSTR(FORMAT("Due Date Formula"), 1, 1) = '-' then
                    ERROR(STRSUBSTNO(Text001, FIELDCAPTION("Due Date Formula")));
            end;
        }
        field(3; "Approval Administrator"; Code[50])
        {
            Caption = 'Approval Administrator';
            TableRelation = "User Setup";
        }
        field(5; "Request Rejection Comment"; Boolean)
        {
            Caption = 'Request Rejection Comment';
        }
        field(6; Approvals; Boolean)
        {
            Caption = 'Approvals';
        }
        field(7; Cancellations; Boolean)
        {
            Caption = 'Cancellations';
        }
        field(8; Rejections; Boolean)
        {
            Caption = 'Rejections';
        }
        field(9; Delegations; Boolean)
        {
            Caption = 'Delegations';
        }
        field(10; "Last Run Time"; Time)
        {
            Caption = 'Last Run Time';
        }
        field(11; "Last Run Date"; Date)
        {
            Caption = 'Last Run Date';
        }
        field(12; "Overdue Template"; BLOB)
        {
            Caption = 'Overdue Template';
            SubType = UserDefined;
        }
        field(13; "Approval Template"; BLOB)
        {
            Caption = 'Approval Template';
            SubType = UserDefined;
        }
        field(90000; "PR Approval Template"; BLOB)
        {
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'You cannot have negative values in %1.';
}

