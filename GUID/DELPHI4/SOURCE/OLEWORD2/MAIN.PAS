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

uses ComObj;  // Declares the CreateOleObject function

{$R *.DFM}

{ This procedure works with the newer Word 97,
  which uses Visual Basic in place of the standard
  Word Basic as its controlling language. }
procedure TMainForm.Button1Click(Sender: TObject);
var
  V, X: Variant;
  S: String;
begin
  V := CreateOleObject('Word.Document');
  X := V.Range(0, 0);
  X.InsertBefore('Hello from Delphi');
  X.Font.Name := 'Arial';
  X.Font.Size := 18;
  X.InsertParagraphAfter;
  V.Printout;
  V.SaveAs('C:\Hold.doc');
end;

end.
