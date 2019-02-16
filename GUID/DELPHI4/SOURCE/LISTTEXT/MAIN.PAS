unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;

type
  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog: TOpenDialog;
    MemoText: TMemo;
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
  if OpenDialog.Execute then
  begin
    MemoText.Lines.LoadFromFile(OpenDialog.Filename);
    MainForm.Caption := OpenDialog.Filename;
  end;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;

end.

