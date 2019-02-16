program Mdidemo;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Child in 'CHILD.PAS' {ChildForm},
  About in 'ABOUT.PAS' {AboutForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
