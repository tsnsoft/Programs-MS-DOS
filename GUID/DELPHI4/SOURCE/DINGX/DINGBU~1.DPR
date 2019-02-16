library DingButtonXControl;

uses
  ComServ,
  DingButtonXControl_TLB in 'DingButtonXControl_TLB.pas',
  DingButtonImpl1 in 'DingButtonImpl1.pas' {DingButtonX: CoClass},
  About1 in 'About1.pas' {DingButtonXAbout},
  DingButton in '..\DING\DingButton.pas';

{$E ocx}

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
