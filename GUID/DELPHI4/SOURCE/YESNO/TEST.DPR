program Test;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Yesno in 'YESNO.PAS' {YesNoDlg};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TYesNoDlg, YesNoDlg);
  Application.Run;
end.

