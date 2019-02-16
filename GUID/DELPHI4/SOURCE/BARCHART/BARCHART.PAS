unit BarChart;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs;

type
  TBarChart = class(TGraphicControl)
  private
    FPen: TPen;
    FBrush: TBrush;
    FData: TStrings;
    FLabels: Boolean;
    XBase, YBase: Integer;
    XIncrement, YIncrement: Integer;
    procedure SetPen(Value: TPen);
    procedure SetBrush(Value: TBrush);
    procedure SetData(Value: TStrings);
    procedure SetLabels(Value: Boolean);
    function YData(N: Integer): Integer;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    procedure StyleChanged(Sender: TObject);
    property Pen: TPen read FPen write SetPen;
    property Brush: TBrush read FBrush write SetBrush;
    property Data: TStrings read FData write SetData;
    property Labels: Boolean read FLabels write SetLabels;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentShowHint;
    property ShowHint;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

procedure Register;

implementation

const
{ Fixed constants }
  numClrs = 16;            { Number of colors in colorArray }
  spaceAtBottom = 10;      { Reserved pixels below chart }
  spaceAtLeft = 20;        { Reserved pixels at left of chart }
  spaceAtTop = 40;         { Reserved pixels above chart }
  spaceAtRight = 20;       { Reserved pixels at right of chart }
  yScaleMax = 100.0;       { Maximum Y scale value }
  yScaleIncrement = 10.0;  { Increment for Y scale markers }
{ Typed constants }
  spaceVertical: Integer = spaceAtTop + spaceAtBottom;
  spaceHorizontal: Integer = spaceAtLeft + spaceAtRight;
  yScale: Integer = Trunc(yScaleMax / yScaleIncrement);
{ Array of colors used to draw topmost bars }
  colorArray: array[0 .. numClrs - 1] of TColor = (
    $0000000, $0FFFFFF, $0FF0000, $000FF00,
    $00000FF, $0FFFF00, $000FFFF, $0FF00FF,
    $0880000, $0008800, $0000088, $0888800,
    $0008888, $0880088, $0448844, $0884488
  );

{ Delphi calls this to install component onto the VCL palette }
procedure Register;
begin
  RegisterComponents('Samples', [TBarChart]);
end;

{ Create component instance at runtime AND design time }
constructor TBarChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);  { Call inherited constructor ! }
  Width := 65;
  Height := 65;
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
  FData := TStringList.Create;
  FLabels := True;
end;

{ Destroy component instance at runtime AND design time }
destructor TBarChart.Destroy;
begin
  FPen.Free;      { Free allocated resources }
  FBrush.Free;
  FData.Free;
  inherited Destroy;  { Call inherited destructor ! }
end;

{ Return Y coordinate for data point N }
function TBarChart.YData(N: Integer): Integer;
var
  F: Double;
begin
  F := (StrToFloat(FData[N]) / yScaleIncrement) * yIncrement;
  Result := YBase - Round(F);
end;

{ Paint component shape at runtime AND design time }
procedure TBarChart.Paint;
var
  XMax, YMax: Integer;
  Width1, WidthD2: Integer;
  I, X1, Y1, X2, Y2, E: Integer;
begin
  with Canvas do
  begin
  { Erase background }
    Pen.Color := FPen.Color;
    Brush.Color := FBrush.Color;
    X1 := Pen.Width div 2;
    Y1 := X1;
    XMax := Width - Pen.Width + 1;
    YMax := Height - Pen.Width + 1;
    Rectangle(X1, Y1, X1 + XMax, Y1 + YMax);
    if FData.Count = 0 then Exit;
  { Initialize variables }
    try
      XIncrement := (XMax - spaceHorizontal) div FData.Count;
      YIncrement := (YMax - spaceVertical) div yScale;
      Width1 := XIncrement div 2;
      WidthD2 := Width1 div 2;
      XBase := spaceAtLeft + WidthD2;
      YBase := YMax - spaceAtBottom;
      Canvas.Font := Self.Font;
    { Draw barchart }
      for I := 0 to FData.Count - 1 do
      begin
        E := I;  // Because I may be undefined after for-loop
        X1 := spaceAtLeft + (XIncrement * I);
        Y1 := YData(I);
        X2 := X1 + Width1;
        Y2 := YBase;
        if FLabels then
        begin
          Brush.Color := FBrush.Color;
          TextOut(X1, Y1 - 30, FData.Strings[I]);
        end;
        Brush.Color := clBlack;
        Rectangle(X1 + 4, Y1 - 4, X2 + 4, Y2 - 4);
        Brush.Color := colorArray[(I + 2) mod numClrs];
        Rectangle(X1, Y1, X2, Y2);
      end;
    except
      ShowMessage('Error in data point ' + IntToStr(E));
      FData.Clear;
      Invalidate;
    end;
  end;
end;

{ Local event handler redraws shape when necessary }
procedure TBarChart.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

{ Assign new brush data to FBrush field }
procedure TBarChart.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

{ Assign new pen data to FPen field }
procedure TBarChart.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

{ Assign new string list to FData field }
procedure TBarChart.SetData(Value: TStrings);
begin
  FData.Assign(Value);
  Invalidate;
end;

{ Assign new Boolean value to FLabels field }
procedure TBarChart.SetLabels(Value: Boolean);
begin
  if FLabels <> Value then  { Exit if no change needed }
  begin
    FLabels := Value;  { Assign to FLabels, NOT Labels ! }
    Invalidate;  { Redraw component to add/remove labels }
  end;
end;

end.
