unit Main;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormActivate(Sender: TObject);
var
  FileName: string;
begin
  if ParamCount >= 1
    then FileName := ParamStr(1)
    else FileName := 'Readme.Txt';
  Memo1.Lines.LoadFromFile(FileName);
  Caption := FileName;
end;

end.
