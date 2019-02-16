unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Spin, StdCtrls, ExtCtrls, Buttons;

type
  TMainForm = class(TForm)
    SpinButton1: TSpinButton;
    Label1: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit: TLabel;
    SpinLabel: TLabel;
    BitBtn1: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure SpinButton1DownClick(Sender: TObject);
    procedure SpinButton1UpClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SetSpinButtonCaption;
  private
    { Private declarations }
    Count: Integer;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

const
  minCount = -99;
  maxCount = 99;

procedure TMainForm.SetSpinButtonCaption;
begin
  SpinLabel.Caption := IntToStr(Count);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Count := 0;
end;

procedure TMainForm.SpinButton1DownClick(Sender: TObject);
begin
  if Count > minCount then Dec(Count);
  SetSpinButtonCaption;
end;

procedure TMainForm.SpinButton1UpClick(Sender: TObject);
begin
  if Count < maxCount then Inc(Count);
  SetSpinButtonCaption;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  Count := 0;
  SetSpinButtonCaption;
end;

end.

