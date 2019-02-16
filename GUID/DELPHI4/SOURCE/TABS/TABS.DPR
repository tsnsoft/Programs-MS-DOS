program Tabs;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  About in 'ABOUT.PAS' {AboutForm},
  Options in 'OPTIONS.PAS' {OptionsDialog},
  Tabsunit in 'TABSUNIT.PAS',
  Inidata in '..\Inidata\Inidata.pas';

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TOptionsDialog, OptionsDialog);
  Application.Run;
end.

