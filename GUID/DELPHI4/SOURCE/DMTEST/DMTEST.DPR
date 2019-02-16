program DMTest;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Module1 in 'Module1.pas' {DataModule1: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.Run;
end.
