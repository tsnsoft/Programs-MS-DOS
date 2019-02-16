program Cclient;

uses
  Forms,
  Climain in 'CLIMAIN.PAS' {MainForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
