unit Test;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TTestForm = class(TForm)
    ClickMeButton: TButton;
    Label1: TLabel;
    Bevel1: TBevel;
    BitBtn1: TBitBtn;
    procedure ClickMeButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  TestForm: TTestForm;

implementation

uses FMXUtils;

$R *.DFM}

(* 16-bit version; still works but WinExec is obsolete
procedure TTestForm.ClickMeButtonClick(Sender: TObject);
var
  K: Integer;  { Result of calling WinExec }
begin
  K := WinExec('Readme.Exe Readme.Txt', SW_SHOWNORMAL);
  if K < 32 then
    ShowMessage('Error running README.EXE');
end;
*)

{ 32-bit version; calls ExecuteFile in FMXUtils unit, which
  is located in Delphi's Demos\Doc\Filmanex folder }
procedure TTestForm.ClickMeButtonClick(Sender: TObject);
var
  H: THandle;
begin
  H := ExecuteFile('Readme.exe', 'Readme.txt', '.',
         SW_SHOWNORMAL);
  if Integer(H) < 32 then
    ShowMessage('Error running Readme.exe');
end;


end.
