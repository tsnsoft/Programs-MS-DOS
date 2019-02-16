unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ActnList, StdCtrls;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Edit1: TEdit;
    Button1: TButton;
    Label1: TLabel;
    ActionList1: TActionList;
    Demo1: TMenuItem;
    Exit1: TMenuItem;
    ExitAction: TAction;
    procedure ExitActionExecute(Sender: TObject);
    procedure ExitActionUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ExitActionExecute(Sender: TObject);
begin
  Close;  // Exit program
end;

procedure TForm1.ExitActionUpdate(Sender: TObject);
var
  Flag: Boolean;
begin
// Set Flag True if user types Quit into Edit1
  if Lowercase(Edit1.Text) = 'quit'
    then Flag := True
    else Flag := False;
  Button1.Enabled := Flag;  // Enable or disable Button1
  Exit1.Enabled := Flag;    // Enable or disable Menu item
end;

end.
