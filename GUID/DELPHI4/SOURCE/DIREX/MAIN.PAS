unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, DirDlg;

type
  TMainForm = class(TForm)
    TestBitBtn: TBitBtn;
    CloseBitBtn: TBitBtn;
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
  with DirDlgForm do
  if ShowModal = mrOk then
    ShowMessage('Selected file = ' + FileNameEdit.Text);
end;

end.
