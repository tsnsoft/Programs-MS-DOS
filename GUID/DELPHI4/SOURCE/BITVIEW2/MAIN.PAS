unit Main;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls, Jpeg;

type
  TMainForm = class(TForm)
    BitImage: TImage;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog1: TOpenDialog;
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.Open1Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    BitImage.Picture.LoadFromFile(OpenDialog1.Filename);
    Caption := OpenDialog1.Filename;
    FormResize(Sender);
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  HorzScrollBar.Range := BitImage.Picture.Width;
  VertScrollBar.Range := BitImage.Picture.Height;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  OpenDialog1.Filter := GraphicFilter(TGraphic);
end;

end.

