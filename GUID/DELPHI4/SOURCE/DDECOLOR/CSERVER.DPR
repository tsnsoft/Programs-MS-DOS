program Cserver;

uses
  Forms,
  Sermain in 'SERMAIN.PAS' {MainForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
