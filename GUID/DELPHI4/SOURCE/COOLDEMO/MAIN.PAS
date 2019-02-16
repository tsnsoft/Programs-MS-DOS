unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, StdCtrls, Buttons, ImgList;

type
  TMainForm = class(TForm)
    CoolBar1: TCoolBar;
    ToolBar1: TToolBar;
    NavigatorImages: TImageList;
    NavigatorHotImages: TImageList;
    DateTimePicker1: TDateTimePicker;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Animate1: TAnimate;
    Button1: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ToolButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.BitBtn1Click(Sender: TObject);
var
  TF: Boolean;  // True or False flag
  S: String;
begin
  TF := ToolButton1.Enabled;
  ToolButton1.Enabled := not TF;
  ToolButton2.Enabled := not TF;
  if TF
    then S := 'Enable'
    else S := 'Disable';
  BitBtn1.Caption := S + ' Back and Forward Buttons';
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  Animate1.Active := not Animate1.Active;
  if Animate1.Active
    then Button1.Caption := 'Stop Animation'
    else Button1.Caption := 'Begin Animation';
end;

procedure TMainForm.ToolButton1Click(Sender: TObject);
begin
  with Sender as TToolButton do
    ShowMessage('Button selected: ' + Caption);
end;

end.
