unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Buttons, StdCtrls, TabNotBk, ComCtrls;

type
  TMainForm = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    AddPageButton: TButton;
    CloseBitBtn: TBitBtn;
    AddControlButton: TButton;
    procedure AddPageButtonClick(Sender: TObject);
    procedure AddControlButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

{- Insert new page into TabbedNotebook }
procedure TMainForm.AddPageButtonClick(Sender: TObject);
begin
  with TabbedNotebook1 do
    Pages.Add(Format('Page %d',[Pages.Count-1]));
end;

{- Insert new control into current page }
procedure TMainForm.AddControlButtonClick(Sender: TObject);
var
  L: TListBox;
  P: TWinControl;
begin
  L := TListBox.Create(Self);
  with TabbedNotebook1 do
  begin
    P := Pages.Objects[PageIndex] as TWinControl;
    L.Parent := P;
    L.SetBounds(10, 10, 100, 100);
{- Insert page tab label into edit control for demonstration.
   You don't have to perform this step. }
    L.Items.Add(TTabPage(P).Caption);
  end;
end;

end.
