program Direx;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Dirdlg in 'DIRDLG.PAS' {DirDlgForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDirDlgForm, DirDlgForm);
  Application.Run;
end.
