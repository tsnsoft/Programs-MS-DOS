unit DingButton;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TDingButton = class(TButton)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    procedure Click; override;
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Samples', [TDingButton]);
end;

procedure TDingButton.Click;
begin
  MessageBeep(0);
  inherited Click;
end;


end.
