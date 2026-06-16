report 27003000 "PR Excel Import"
{
    ProcessingOnly = true;
    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ImportOption; ImportOption)
                    {
                        Caption = 'Option';
                    }
                }
            }
        }


        trigger OnQueryClosePage(CloseAction: Action): Boolean;
        begin
            if CloseAction = ACTION::OK then begin
                //    ServerFileName := FileMgt.UploadFile(Text006, ExcelExtensionTok);
                if ServerFileName = '' then
                    exit(false);

                //  SheetName := ExcelBuf.SelectSheetsName(ServerFileName);
                if SheetName = '' then
                    exit(false);
            end;
        end;
    }



    trigger OnPreReport();
    var
        X: Integer;
    begin
        if ImportOption = ImportOption::"Replace entries" then
            ExcelImport.DELETEALL;

        ExcelBuf.LOCKTABLE;
        //  ExcelBuf.OpenBook(ServerFileName, SheetName);
        ExcelBuf.ReadSheet;
        GetLastRowandColumn;

        for X := 2 to TotalRows do
            InsertData(X);

        ExcelBuf.DELETEALL;

        MESSAGE('Import Completed.');
    end;

    var
        ImportOption: Option "Add entries","Replace entries";
        Text005: Label '"Imported from Excel "';
        ServerFileName: Text;
        SheetName: Text[250];
        FileMgt: Codeunit "File Management";
        Text006: Label 'Import Excel File';
        ExcelExtensionTok: Label '.xlsx', Comment = '{Locked=true}';
        ExcelBuf: Record "Excel Buffer";
        Text010: Label 'Add entries,Replace entries';
        Window: Dialog;
        Text001: Label 'Do you want to create %1 %2.';
        Text003: Label 'Are you sure you want to %1 for %2 %3.';
        TotalColumns: Integer;
        TotalRows: Integer;
        ExcelImport: Record "PR Line";
        PRHeader: Record "PR Header";
        PRline: Record "PR Line";

    procedure GetLastRowandColumn();
    begin
        ExcelBuf.SETRANGE("Row No.", 1);
        TotalColumns := ExcelBuf.COUNT;

        ExcelBuf.RESET;
        if ExcelBuf.FINDLAST then
            TotalRows := ExcelBuf."Row No.";
    end;

    procedure InsertData(RowNo: Integer);
    var
        ItemNo: Code[20];
        RecItem: Record Item;
        LMonth: Integer;
    begin

        ExcelImport.INIT;
        ExcelImport."Document No." := PRHeader."No.";
        PRline.RESET;
        PRline.SETRANGE("Document No.", PRHeader."No.");
        if PRline.FINDLAST then
            ExcelImport."Line No." := PRline."Line No." + 10000
        else
            ExcelImport."Line No." := 10000;

        if (GetValueAtCell(RowNo, 1) <> '') then
            EVALUATE(ExcelImport.Type, GetValueAtCell(RowNo, 1));
        if GetValueAtCell(RowNo, 2) <> '' then
            EVALUATE(ExcelImport."No.", GetValueAtCell(RowNo, 2));
        if GetValueAtCell(RowNo, 3) <> '' then
            EVALUATE(ExcelImport.Description, GetValueAtCell(RowNo, 3));
        if GetValueAtCell(RowNo, 4) <> '' then
            EVALUATE(ExcelImport.Quantity, GetValueAtCell(RowNo, 4));
        if GetValueAtCell(RowNo, 5) <> '' then
            EVALUATE(ExcelImport."Unit of  Measure", GetValueAtCell(RowNo, 5));

        ExcelImport.INSERT(true);
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text;
    var
        ExcelBuf1: Record "Excel Buffer";
    begin
        if ExcelBuf1.GET(RowNo, ColNo) then
            exit(ExcelBuf1."Cell Value as Text");
    end;

    procedure SetPRHeader(PRHeaderPar: Record "PR Header");
    begin
        PRHeader := PRHeaderPar;
    end;
}

