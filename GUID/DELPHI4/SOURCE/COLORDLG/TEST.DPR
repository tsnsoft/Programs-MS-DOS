program Test;

uses
  Forms,
  Colordlg in 'COLORDLG.PAS' {ColorDlgForm},
  Main in 'MAIN.PAS' {MainForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TColorDlgForm, ColorDlgForm);
  Application.Run;
end.
