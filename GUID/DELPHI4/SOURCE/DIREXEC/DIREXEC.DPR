program Direxec;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Dirdlg in '..\Direx\Dirdlg.pas' {DirDlgForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDirDlgForm, DirDlgForm);
  Application.Run;
end.
