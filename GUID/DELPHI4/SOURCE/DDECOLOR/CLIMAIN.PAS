unit Climain;

interface

uses
  Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DdeMan, StdCtrls, Buttons;

type
  TMainForm = class(TForm)
    DdeClientConv1: TDdeClientConv;
    DdeClientItem1: TDdeClientItem;
    Label1: TLabel;
    Edit1: TEdit;
    ColorValueLabel: TLabel;
    BitBtn1: TBitBtn;
    procedure DdeClientItem1Change(Sender: TObject);
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

const
  asciiBlank = ' ';  { One blank between two single quotes }

{- Client has received an item from server. Update sample
color and label. }
procedure TMainForm.DdeClientItem1Change(Sender: TObject);
var
  S: String;
  C: TColor;
begin
  with DdeClientItem1 do
  begin
    if Length(Text) = 0 then
      S := '$0'   { Default string }
    else
      S := Text;  { String from server }
    try
      while S[Length(S)] = asciiBlank do  { Delete trailing blanks }
        System.Delete(S, Length(S), 1);   { from string. }
      C := StringToColor(S);              { Convert to color }
      ColorValueLabel.Caption := S;       { Assign to label }
      Edit1.Color := C;                   { Show color }
    except
      ShowMessage('Bad color format from server');
    end;
  end;
end;

{- Establish conversation with server. }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  if DdeClientConv1.SetLink('CSERVER', 'ColorServer') then
  begin
    DdeClientItem1.DdeItem := 'ColorItem';
    if DdeClientConv1.ConnectMode = ddeManual then
      DdeClientConv1.OpenLink;
  end;
end;

end.
