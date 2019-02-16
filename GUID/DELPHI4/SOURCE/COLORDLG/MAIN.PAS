unit Main;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ColorDlg, Buttons, StdCtrls;

type
  TMainForm = class(TForm)
    CloseBitBtn: TBitBtn;
    TestBitBtn: TBitBtn;
    procedure TestBitBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.TestBitBtnClick(Sender: TObject);
begin
  with ColorDlgForm do
  if ShowModal = mrOk then
    ShowMessage(Format('Color value = $%-.6x', [ColorResult]));
end;

end.
