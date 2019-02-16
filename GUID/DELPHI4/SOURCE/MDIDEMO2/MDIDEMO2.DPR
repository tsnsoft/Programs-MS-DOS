program Mdidemo2;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  Child in 'CHILD.PAS' {ChildForm},
  About in 'ABOUT.PAS' {AboutForm},
  Childbmp in 'Childbmp.pas' {ChildBmpForm};

{$R *.RES}

begin
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.
