table 27003008 "PR Arch. Header"
{
    DrillDownPageID = "PR Arch. List";
    LookupPageID = "PR Arch. List";

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Description; Text[150])
        {
        }
        field(3; "PR Date"; Date)
        {
        }
        field(4; "Due Date"; Date)
        {
        }
        field(5; "Delivery Location"; Code[20])
        {
            TableRelation = Location;
        }
        field(6; "No. series"; Code[20])
        {
            Editable = false;
        }
        field(7; Requester; Text[150])
        {
            TableRelation = "User Setup";
        }
        field(9; "Document Type"; Option)
        {
            OptionCaption = 'RFQ,PO';
            OptionMembers = RFQ,PO;
        }
        field(10; "PR Status"; Option)
        {
            OptionMembers = PR,RFQ,"Order",Cancel,Closed;
        }
        field(11; "USER ID"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";
        }
        field(12; Status; Option)
        {
            Editable = false;
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";
        }
        field(13; "Last Modified Date"; Date)
        {
            Editable = false;
        }
        field(14; "Suggested Supplier"; Code[20])
        {
        }
        field(15; "Shortcut Dimension 1 Code"; Code[20])
        {
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(1));
        }
        field(16; "Shortcut Dimension 2 Code"; Code[20])
        {
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code WHERE("Global Dimension No." = CONST(2));
        }
        field(17; PONoseries; Code[20])
        {
            TableRelation = "No. Series";
        }
        field(18; "PR Type"; Option)
        {
            OptionCaption = 'Raw Material,General,Hardware,Fixed Asset,Projects';
            OptionMembers = "Raw Material",General,Hardware,"Fixed Asset",Projects;
        }
        field(19; "WBS ID"; Code[50])
        {
            TableRelation = "Budget Import"."WBS ID" WHERE("Project ID" = FIELD("Shortcut Dimension 2 Code"));
        }
        field(20; "Budgetary PR"; Boolean)
        {
        }
        field(21; "Date Created"; Date)
        {
        }
        field(22; "Currency Code"; Code[10])
        {
            TableRelation = Currency;
        }
        field(23; "Currency Factor"; Decimal)
        {
            Caption = 'Currency Factor';
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(24; "Purchaser Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser";
        }
        field(25; "PR No."; Code[20])
        {
        }
        field(26; "Archive Date Time"; DateTime)
        {
        }
        field(27; "Archive UserID"; Code[50])
        {
        }
        field(28; "Version No."; Integer)
        {
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Description = 'PR4.0';
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "No.", "Version No.")
        {
        }
    }

}

