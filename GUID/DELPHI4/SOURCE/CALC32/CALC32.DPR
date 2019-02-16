program Calc32;

uses
  Forms,
  Calc in 'CALC.PAS' {CalcForm},
  About in 'ABOUT.PAS' {AboutForm};

{$R *.RES}

begin
  Application.CreateForm(TCalcForm, CalcForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.Run;
end.

