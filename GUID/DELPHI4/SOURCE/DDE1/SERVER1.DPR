program Server1;

uses
  Forms,
  Server in 'SERVER.PAS' {ServerForm};

{$R *.RES}

begin
  Application.CreateForm(TServerForm, ServerForm);
  Application.Run;
end.
