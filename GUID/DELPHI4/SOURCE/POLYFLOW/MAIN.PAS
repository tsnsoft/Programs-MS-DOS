unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, Menus;

const
  maxIndex = 100;      { Maximum number of lines visible }
  dx1: Integer = 4;    { "Delta" values for controlling }
  dy1: Integer = 10;   {  the animation's personality.  }
  dx2: Integer = 3;
  dy2: Integer = 9;

type
  LineRec = record     { Line ends and color }
    X1, Y1, X2, Y2 : Integer;
    Color: TColor;
  end;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    Demo1: TMenuItem;
    Exit1: TMenuItem;
    Timer1: TTimer;
    procedure Exit1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    LineArray: array[0 .. maxIndex - 1] of LineRec;
    Index: Integer;     { Index for LineArray }
    Erasing: Boolean;   { True if erasing old lines }
    function Sign(N: Integer): Integer;
    procedure InitLineArray;
    procedure MakeNewLine(R: TRect; Index: Integer);
    procedure DrawLine(Index: Integer);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(params);
  with Params.WindowClass do
 {- Repaint the window automatically when resized }
    Style := Style or cs_HRedraw or cs_VRedraw;
end;

{- Return -1 if n < 0 or +1 if n >= 0 }
function TMainForm.Sign(N: Integer): Integer;
begin
  if N < 0 then Sign := -1 else Sign := 1;
end;

{- Erase LineArray and set X1 to -1 as "no line" flag }
procedure TMainForm.InitLineArray;
var
  I: Integer;
begin
  Index := 0;
  Erasing := False;
  FillChar(LineArray, SizeOf(LineArray), 0);
  for I := 0 to maxIndex - 1 do
    LineArray[I].X1 := -1;
end;

{- Create new line, direction, and color }
procedure TMainForm.MakeNewLine(R: TRect; Index: Integer);
  procedure NewCoord(var C, Change: Integer; Max: Integer;
    var Color: TColor);
  var
    Temp: Integer;
  begin
    Temp := C + Change;
    if (Temp < 0) or (Temp > Max) then
    begin
      Change := Sign(-Change) * (3 + Random(12));
      repeat
        Color := RGB(Random(256), Random(256), Random(256));
        Color := GetNearestColor(Canvas.Handle, Color)
      until Color <> GetBkColor(Canvas.Handle);
    end else
      C := Temp;
  end;
begin
  with LineArray[Index] do
  begin
    NewCoord(X1, dx1, R.Right, Color);
    NewCoord(Y1, dy1, R.Bottom, Color);
    NewCoord(X2, dx2, R.Right, Color);
    NewCoord(Y2, dy2, R.Bottom, Color)
  end
end;

{- Draw or erase a line identified by Index }
procedure TMainForm.DrawLine(Index: Integer);
begin
  with Canvas, LineArray[Index] do
  begin
    Pen.Color := Color;
    MoveTo(X1, Y1);
    LineTo(X2, Y2);
  end;
end;

{- Draw some lines at each timer interval }
procedure TMainForm.Timer1Timer(Sender: TObject);
var
  R: TRect;
  I, OldIndex: Integer;
begin
  R := GetClientRect;
  for I := 1 to 10 do  { 10 = number of lines }
  begin
    OldIndex := Index;
    Inc(Index);
    if Index = maxIndex - 1 then
    begin
      Index := 0;       { Wrap Index around to start }
      Erasing := True;  { True until window size changes }
    end;
    if Erasing then
      DrawLine(Index);  { Erase old line }
    LineArray[Index] := LineArray[OldIndex];
    MakeNewLine(R, Index);
    DrawLine(Index);    { Draw new line }
  end;
end;

{- Paint or repaint screen using data in LineArray }
procedure TMainForm.FormPaint(Sender: TObject);
var
  I: Integer;
begin
  with Canvas do
    for I := 0 to maxIndex - 1 do
      if LineArray[I].X1 >= 0 then  { Draw non-flagged lines }
        DrawLine(I);
end;

{- Start new lines when window size changes }
procedure TMainForm.FormResize(Sender: TObject);
begin
  InitLineArray;   { Erase LineArray and reset globals }
end;

{- Initialize globals and LineArray }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  with Canvas.Pen do
  begin
    Style := psSolid;
    Width := 1;
    Mode := pmXor;
  end;
  Randomize;
  InitLineArray;
end;

{- End program }
procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

end.

(*
// ==============================================================
// Copyright (c) 1991,1993,1995 by Tom Swan. All rights reserved
// Revision 1.00    Date: 3/1/1993   Time: 12:00 pm
// Revision 2.00    Date: 6/13/1995  Time:  6:00 pm
// - Fixed bug in timer proc that sometimes failed to erase a line
// - Erase LineArray to zero bytes at startup and on window resize
// Revision 2.01    Date: 2/16/1998  Time:  4:45 pm
// - Updated for Delphi 3
*)

