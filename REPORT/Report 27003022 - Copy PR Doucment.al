report 27003022 "Copy PR Doucment"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(FROMPRHeader; "PR Header")
        {
            RequestFilterFields = "No.";
            dataitem(FROMPRLine; "PR Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = SORTING("Document No.", "Line No.") ORDER(Ascending);

                trigger OnAfterGetRecord();
                begin

                    Window.UPDATE(1, FROMPRLine."No.");
                    ToPRLine.INIT;
                    ToPRLine."Document No." := ToPRNo;
                    ToPRLine2.RESET;
                    ToPRLine2.SETRANGE("Document No.", ToPRNo);
                    if ToPRLine2.FINDLAST then
                        ToPRLine."Line No." := ToPRLine2."Line No." + 10000
                    else
                        ToPRLine."Line No." := 10000;

                    ToPRLine.Description := FROMPRLine.Description;
                    ToPRLine.Type := FROMPRLine.Type;
                    ToPRLine.VALIDATE("No.", FROMPRLine."No.");
                    ToPRLine.VALIDATE(Description, FROMPRLine.Description);
                    ToPRLine.Quantity := FROMPRLine.Quantity;
                    ToPRLine."Unit of  Measure" := FROMPRLine."Unit of  Measure";
                    ToPRLine."Delivery Location" := FROMPRLine."Delivery Location";
                    ToPRLine."PR Document Type" := FROMPRLine."PR Document Type";
                    ToPRLine."PR No" := FROMPRLine."PR No";
                    ToPRLine."Unit Cost" := FROMPRLine."Unit Cost";
                    ToPRLine.Amount := FROMPRLine.Amount;
                    ToPRLine."Description 2" := FROMPRLine."Description 2";
                    ToPRLine.Remarks := FROMPRLine.Remarks;
                    ToPRLine."Suggested Supplier" := FROMPRLine."Suggested Supplier";
                    ToPRLine.VALIDATE("Shortcut Dimension 1 Code", FROMPRLine."Shortcut Dimension 1 Code");
                    ToPRLine.VALIDATE("Shortcut Dimension 2 Code", FROMPRLine."Shortcut Dimension 2 Code");
                    ToPRLine.VALIDATE("Dimension Set ID", FROMPRLine."Dimension Set ID");
                    ToPRLine."Reason for Shortlist" := FROMPRLine."Reason for Shortlist";
                    ToPRLine."Unit Cost (LCY)" := FROMPRLine."Unit Cost (LCY)";
                    ToPRLine."Amount (LCY)" := FROMPRLine."Amount (LCY)";
                    ToPRLine."WBS ID" := FROMPRLine."WBS ID";
                    ToPRLine."Activity ID" := FROMPRLine."Activity ID";
                    ToPRLine."STD Purchase Code" := FROMPRLine."STD Purchase Code";
                    ToPRLine.INSERT;
                end;

                trigger OnPreDataItem();
                begin

                    if ToPRHeader.GET(ToPRNo) then begin
                        ToPRHeader.Description := FROMPRHeader.Description;
                        ToPRHeader."Delivery Location" := FROMPRHeader."Delivery Location";
                        ToPRHeader."Suggested Vendor" := FROMPRHeader."Suggested Vendor";
                        ToPRHeader."Shortcut Dimension 1 Code" := FROMPRHeader."Shortcut Dimension 1 Code";
                        ToPRHeader."Shortcut Dimension 2 Code" := FROMPRHeader."Shortcut Dimension 2 Code";
                        ToPRHeader.VALIDATE("Dimension Set ID", FROMPRHeader."Dimension Set ID");
                        ToPRHeader."PR Type" := FROMPRHeader."PR Type";
                        ToPRHeader."Budgetary PR" := FROMPRHeader."Budgetary PR";
                        ToPRHeader."Currency Code" := FROMPRHeader."Currency Code";
                        ToPRHeader."Currency Factor" := FROMPRHeader."Currency Factor";
                        ToPRHeader."Purchaser Code" := FROMPRHeader."Purchaser Code";
                        ToPRHeader."Co-ordinator" := USERID;
                        ToPRHeader."PR Date" := TODAY;
                        ToPRHeader.MODIFY;
                        FromSuggestedVendor.RESET;
                        FromSuggestedVendor.SETRANGE("Document Type", FromSuggestedVendor."Document Type"::"PR Header");
                        FromSuggestedVendor.SETRANGE("PR No.", FROMPRHeader."No.");
                        if FromSuggestedVendor.FINDFIRST then
                            repeat
                                ToSuggestedVendor.INIT;
                                ToSuggestedVendor := FromSuggestedVendor;
                                ToSuggestedVendor."PR No." := ToPRHeader."No.";
                                ToSuggestedVendor.Converted := false;
                                ToSuggestedVendor.INSERT;
                            until FromSuggestedVendor.NEXT = 0;
                    end;
                end;
            }

            trigger OnPostDataItem();
            begin
                Window.CLOSE;
            end;

            trigger OnPreDataItem();
            begin
                Window.OPEN('Copying #1##############');
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ToPRHeader: Record "PR Header";
        ToPRLine: Record "PR Line";
        ToPRLine2: Record "PR Line";
        ToPRNo: Code[20];
        Window: Dialog;
        FromSuggestedVendor: Record "Suggested Vendor";
        ToSuggestedVendor: Record "Suggested Vendor";

    procedure ToUpdatePR(UPdatetoPRNo: Code[20]);
    begin
        ToPRNo := UPdatetoPRNo;
    end;
}

