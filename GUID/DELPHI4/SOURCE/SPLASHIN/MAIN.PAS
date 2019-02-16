unit Main;

interface

uses
  windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TMainForm = class(TForm)
    ExitButton: TButton;
    procedure ExitButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.ExitButtonClick(Sender: TObject);
begin
  Close;
end;

{ The following procedure pauses for a few seconds so
  the Splash dialog remains visible for a predetermined
  length of time. }

procedure TMainForm.FormCreate(Sender: TObject);
var
  CurrentTime: LongInt;
begin
  CurrentTime := GetTickCount div 1000;
  while ( (GetTickCount div 1000) < (CurrentTime + 4) ) do
    Sleep(1);
end;

end.

