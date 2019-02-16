program Client2;

uses
  Forms,
  Client in 'CLIENT.PAS' {ClientForm};

{$R *.RES}

begin
  Application.CreateForm(TClientForm, ClientForm);
  Application.Run;
end.
