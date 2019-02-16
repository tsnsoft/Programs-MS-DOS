unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TMainForm = class(TForm)
    StatusPanel: TPanel;
    CapsLockPanel: TPanel;
    NumLockPanel: TPanel;
    ScrollLockPanel: TPanel;
    InsPanel: TPanel;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Bevel1: TBevel;
    CapsLockLabel: TLabel;
    NumLockLabel: TLabel;
    ScrollLockLabel: TLabel;
    InsLabel: TLabel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure UpdateKeyPanel;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.UpdateKeyPanel;
begin
  CapsLockLabel.Enabled :=
    GetKeyState(VK_CAPITAL) and 1 = 1;
  NumLockLabel.Enabled :=
    GetKeyState(VK_NUMLOCK) and 1 = 1;
  ScrollLockLabel.Enabled :=
    GetKeyState(VK_SCROLL)  and 1 = 1;
  InsLabel.Enabled :=
    GetKeyState(VK_INSERT)  and 1 = 1;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateKeyPanel;
end;

procedure TMainForm.FormActivate(Sender: TObject);
begin
  UpdateKeyPanel;
end;

end.

