unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TMainForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses ComObj;   // Declares the CreateOleObject function

{$R *.DFM}

{ This procedure works with Microsoft Word 95 and
  earlier versions. It does *not* work with the
  newer Word 97, which now uses Visual Basic in
  place of Word Basic. }
procedure TMainForm.Button1Click(Sender: TObject);
var
  V: Variant;
begin
  V := CreateOleObject('Word.Basic');
  V.Insert('Hello from Delphi');
  V.FilePrint;
  V.FileSaveAs('C:\Hold.doc');
end;

end.
