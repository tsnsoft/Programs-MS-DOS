unit Clrform;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ColorGrd, ExtCtrls;

type
  TColorForm = class(TForm)
    ColorGrid: TColorGrid;
    Label1: TLabel;
    Label2: TLabel;
    CancelBitBtn: TBitBtn;
    OkBitBtn: TBitBtn;
    Bevel1: TBevel;
    procedure CancelBitBtnClick(Sender: TObject);
    procedure OkBitBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ColorForm: TColorForm;

function FBGetColors(var FColor, BColor: TColor): WordBool;
  export;

implementation

{$R *.DFM}

{- Exit dialog via Cancel button }
procedure TColorForm.CancelBitBtnClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

{- Exit dialog via Ok button }
procedure TColorForm.OkBitBtnClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{- Get foreground and background colors }
function FBGetColors(var FColor, BColor: TColor): WordBool;
begin
  Result := False;
  ColorForm := TColorForm.Create(Application);
  try
    if ColorForm.ShowModal = mrOk then
    with ColorForm do
    begin
      FColor := ColorGrid.ForegroundColor;
      BColor := ColorGrid.BackgroundColor;
      Result := True;
    end;
  finally
    ColorForm.Free;
  end;
end;

end.
