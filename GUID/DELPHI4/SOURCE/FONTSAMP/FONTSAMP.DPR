program Fontsamp;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  About in 'ABOUT.PAS' {AboutForm},
  Preview in 'PREVIEW.PAS' {PreviewForm},
  Drawpage in 'DRAWPAGE.PAS';

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TPreviewForm, PreviewForm);
  Application.Run;
end.

