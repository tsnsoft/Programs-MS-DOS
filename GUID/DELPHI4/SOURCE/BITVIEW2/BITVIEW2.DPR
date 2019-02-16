program Bitview2;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

