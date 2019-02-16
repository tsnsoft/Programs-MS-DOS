unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ShellAPI;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    FileNameLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure WMDropFiles(var Msg: TMessage);
      message wm_DropFiles;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

{ Handle wm_DropFiles message }
procedure TMainForm.WMDropFiles(var Msg: TMessage);
var
  Filename: array[0 .. 256] of Char;
begin
  DragQueryFile(
    THandle(Msg.WParam),
    0,
    Filename,
    SizeOf(Filename));
  with FileNameLabel do
  begin
    Caption := LowerCase(FileName);
    Memo1.Lines.LoadfromFile(Caption);
  end;
  DragFinish(THandle(Msg.WParam));
end;

{ Tell Windows this window can accept drag-and-drop files }
{ Disable drag-and-drop files (recommended) }
procedure TMainForm.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DragAcceptFiles(Handle, False);
end;

end.
