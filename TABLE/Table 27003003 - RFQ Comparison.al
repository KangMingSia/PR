table 27003003 "RFQ Comparison"
{
    DrillDownPageID = "RFQ Comparisons";
    LookupPageID = "RFQ Comparisons";

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "PR No"; Code[20])
        {
            TableRelation = "PR Header"."No." WHERE("PR Status" = FILTER(RFQ));

            trigger OnValidate();
            begin

                if xRec."PR No" <> '' then
                    ERROR(Text001);
                if PRHdr.GET("PR No") then
                    Description := PRHdr.Description;
            end;
        }
        field(3; Description; Text[150])
        {
        }
        field(4; "No. series"; Code[20])
        {
        }
        field(5; "RFQ Status"; Option)
        {
            OptionCaption = 'Open,Closed';
            OptionMembers = Open,Closed;
        }
        field(12; Status; Option)
        {
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";

            trigger OnValidate();
            begin
                TESTFIELD("RFQ Status", "RFQ Status"::Open);
            end;
        }
        field(13; Requester; Text[150])
        {

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(14; "Co-ordinator"; Code[50])
        {
            Editable = false;
            TableRelation = "User Setup";

            trigger OnValidate();
            begin
                TESTFIELD(Status, Status::Open);
            end;
        }
        field(15; "Total Budget"; Decimal)
        {
        }
        field(16; "Purchaser Code"; Code[20])
        {
            TableRelation = "Salesperson/Purchaser".Code WHERE(Purchaser = CONST(true));
        }
        field(17; "LOA Status"; Option)
        {
            Description = 'PR2.1';
            Editable = false;
            OptionCaption = 'Open,Released,Cancel,Closed,Pending Approval';
            OptionMembers = Open,Released,Cancel,Closed,"Pending Approval";
        }
        field(18; "RFQ Total Amount"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Line Amount" WHERE("Document Type" = CONST(Quote), "RFQ No." = FIELD("No."), "Create PO" = const(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(19; "RFQ Total Amount (LCY)"; Decimal)
        {
            CalcFormula = Sum("Purchase Line"."Line Amount" WHERE("Document Type" = CONST(Quote), "RFQ No." = FIELD("No."), "Create PO" = const(true)));
            Editable = false;
            FieldClass = FlowField;
        }
        field(20; "RFQ Date"; Date)
        {
            Editable = false;

        }
        field(21; "Due Date"; Date)
        {


        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
    }

    fieldgroups
    {
    }

    var
        PurchSetup: Record "Purchases & Payables Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PRHdr: Record "PR Header";
        Text001: Label 'Modification not allowed';
}

