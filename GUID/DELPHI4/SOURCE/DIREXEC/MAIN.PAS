unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ShellAPI, DirDlg;

type
  TMainForm = class(TForm)
    RunBitBtn: TBitBtn;
    BitBtn2: TBitBtn;
    procedure RunBitBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

function ExecuteFile(const FileName, Params, Dir: String;
  ShowCmd: Integer): THandle;
begin
  Result := ShellExecute(Application.MainForm.Handle, nil,
    PChar(FileName), PChar(Params), PChar(Dir), ShowCmd);
end;

procedure TMainForm.RunBitBtnClick(Sender: TObject);
begin
  with DirDlgForm do
  if ShowModal = mrOk then
  if ExecuteFile(FileNameEdit.Text, '',
    DirectoryListBox.Directory,SW_SHOW) <= 32 then
    MessageDlg('Unable to open file or program',
      mtError, [mbOk], 0)
  else
    Application.Minimize;
end;

end.
