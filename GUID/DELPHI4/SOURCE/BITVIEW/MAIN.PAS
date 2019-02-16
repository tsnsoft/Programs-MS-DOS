unit Main;

interface

uses
  Windows, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Menus, ExtCtrls;

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
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

end.

