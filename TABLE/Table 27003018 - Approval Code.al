table 27003018 "Approval Code"
{
    Caption = 'Approval Code';
    DrillDownPageID = "Approval Code";
    LookupPageID = "Approval Code";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Linked To Table Name"; Text[50])
        {
            Caption = 'Linked To Table Name';
        }
        field(4; "Linked To Table No."; Integer)
        {
            Caption = 'Linked To Table No.';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));
            trigger OnValidate();
            var
                AllObjWithCaption: Record AllObjWithCaption;
            begin
                AllObjWithCaption.SETRANGE("Object Type", AllObjWithCaption."Object Type"::Table);
                AllObjWithCaption.SETRANGE("Object ID", "Linked To Table No.");
                if AllObjWithCaption.FINDFIRST then
                    "Linked To Table Name" := AllObjWithCaption."Object Name"
                else
                    "Linked To Table Name" := '';
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

}

