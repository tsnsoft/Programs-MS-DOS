unit Main;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Demo1: TMenuItem;
    Erase1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    procedure FormMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormDblClick(Sender: TObject);
    procedure Erase1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Dragging: Boolean;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Dragging := False;
end;

procedure TMainForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Dragging := True;
  Canvas.MoveTo(X, Y);
end;

procedure TMainForm.FormMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if Dragging then
    Canvas.LineTo(X, Y);
end;

procedure TMainForm.FormMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Dragging := False;
end;

procedure TMainForm.FormDblClick(Sender: TObject);
begin
  Erase1Click(Sender);
end;

procedure TMainForm.Erase1Click(Sender: TObject);
begin
  Canvas.Brush := Brush; { Assign form's brush to Canvas }
  Canvas.FillRect(MainForm.ClientRect);  { Repaint form bkgrnd}
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

end.

