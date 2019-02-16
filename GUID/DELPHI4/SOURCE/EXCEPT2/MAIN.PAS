unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TMainForm = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.Button1Click(Sender: TObject);
var
  N: Integer;
begin
  N := StrToInt(Edit1.Text);
  if (N < 0) or (N > 99) then
    raise ERangeError.Create('Value out of range! Try again')
  else begin
    ShowMessage('Success! Click Ok to end program');
    Close;
  end;
end;

end.
