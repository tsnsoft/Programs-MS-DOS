unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, Printers;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    SetupBitBtn: TBitBtn;
    PrintBitBtn: TBitBtn;
    CloseBitBtn: TBitBtn;
    OpenBitBtn: TBitBtn;
    OpenDialog1: TOpenDialog;
    PrintDialog1: TPrintDialog;
    PrinterSetupDialog1: TPrinterSetupDialog;
    procedure OpenBitBtnClick(Sender: TObject);
    procedure SetupBitBtnClick(Sender: TObject);
    procedure PrintBitBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.OpenBitBtnClick(Sender: TObject);
begin
  with OpenDialog1 do
  if Execute then
  begin
    Memo1.Lines.LoadFromFile(FileName);
    Caption := Lowercase(FileName);
  end;
end;

procedure TMainForm.SetupBitBtnClick(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

procedure TMainForm.PrintBitBtnClick(Sender: TObject);
var
  FPrn: System.Text;  { Printer output text file }
  I: Integer;         { Memo1.Lines index }
  LCol: Integer;      { Line number column width }
begin
  if PrintDialog1.Execute then
  begin
    AssignPrn(FPrn);  { Direct Write/Writeln to FPrn }
    Rewrite(FPrn);    { Open printer output file }
    try
      Printer.Canvas.Font := Memo1.Font;  { Use Memo's font }
      with Memo1, Lines do
      begin  { Set line number column width for file size:         }
        if Count < 10 then LCol := 1         { 0 .. 9 lines        }
        else if Count < 100 then LCol := 2   { 10 .. 99 lines      }
        else if Count < 1000 then LCol := 3  { 100 .. 999 lines    }
        else LCol := 4;                      { You must be kidding }
        for I := 0 to Count - 1 do
        begin
          Write(FPrn, I + 1:LCol, ': ');  { Print line number }
          Writeln(FPrn, Lines[I]);        { Print line }
        end;
      end;
    finally
      CloseFile(FPrn);  { Close printer output file }
    end;
  end;
end;

end.
