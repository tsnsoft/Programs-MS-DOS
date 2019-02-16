unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, Grids;

type
  TMainForm = class(TForm)
    PathLabel: TLabel;
    BitBtn1: TBitBtn;
    GlyphList: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure GlyphListDrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

const glyphPath =
  'C:\Program Files\Borland\Delphi 3\Images\Buttons';

// Reads all glyph bitmaps and stores their filenames and
// images in the GlyphList TStringGrid object.
procedure TMainForm.FormCreate(Sender: TObject);
var
  SearchRec: TSearchRec;  { Directory scan result record }
  K: Integer;             { while-loop control variable }
  Bitmap: TBitmap;        { Holds bitmaps. Do not Free! }
  Index: Integer;         { TStringGrid cell index }
begin
  Show;  { Make form visible while loading bitmaps }
  Screen.Cursor := crHourGlass;  { Show hourglass cursor }
  Index := 0;
  try
    PathLabel.Caption := glyphPath; { Show path above ListBox }
    { Start scan }
    K := FindFirst(glyphPath + '\*.*', faAnyFile, SearchRec);
    try
      while K = 0 do  { Scan directory for file names }
      begin
        if SearchRec.Name[1] <> '.' then {No '.' or '..' paths}
        begin
          Bitmap := TBitmap.Create;  { Create bitmap object }
          try  { Get bitmap and load from list }
            Bitmap.LoadFromFile(glyphPath + '\'
              + SearchRec.Name);
            if Index = GlyphList.RowCount then  // Expand list
              GlyphList.RowCount := Index + 1;
            GlyphList.Cells[0, Index] := SearchRec.Name;// Name
            GlyphList.Objects[1, Index] := Bitmap;    // Bitmap
            inc(Index);
          except
            Bitmap.Free; { Executed if ANYTHING goes wrong }
            raise;       { Pass any exceptions up call chain }
          end;
        end;
        K := FindNext(SearchRec);  { Continue directory scan }
      end;
    finally
      FindClose(SearchRec);
    end;
  finally
    Screen.Cursor := crDefault;  { Restore normal cursor }
  end;
end;

// Frees memory occupied by all glyph bitmaps. The TStringGrid
// object does NOT do this automatically.
procedure TMainForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
var
  I: Integer;
begin
  for I := 0 to GlyphList.RowCount - 1 do
    TBitmap(GlyphList.Objects[0, I]).Free;
end;

// Draw each glyph bitmap. The TStringGrid object is smart
// enough to draw its filename text objects with no further
// help. This code draws only the bitmaps in the second column.
procedure TMainForm.GlyphListDrawCell(Sender: TObject;
  Col, Row: Integer; Rect: TRect; State: TGridDrawState);
var
  Bitmap: TBitmap;
begin
  if col = 1 then  // Be sure to refer to the bitmap column
  begin
    { Get bitmap object }
    Bitmap := TBitmap(GlyphList.Objects[1, Row]);
    if Bitmap <> nil then
    begin  { Draw bitmap in column cell }
      GlyphList.Canvas.BrushCopy(
        Bounds(Rect.Left + 2, Rect.Top + 2, Bitmap.Width,
          Bitmap.Height), Bitmap,
          Bounds(0, 0, Bitmap.Width, Bitmap.Height), clRed);
      { The preceding clRed argument gives the transparent
        glyph substance. Change this to any solid color, or
        change it to 0 to see why this is necessary. }
    end;
  end;
end;

end.

