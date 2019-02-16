unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TMainForm = class(TForm)
    Animate1: TAnimate;
    RadioGroup1: TRadioGroup;
    GoBitBtn: TBitBtn;
    StopBitBtn: TBitBtn;
    BitBtn1: TBitBtn;
    StatusText: TStaticText;
    Label1: TLabel;
    procedure GoBitBtnClick(Sender: TObject);
    procedure StopBitBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

{ Define array types for easier assignments of the
  Animate object's CommonAvi property, and also the
  StatusText object that shows which animation is running. }
type
  aviKindArray = array[0 .. 7] of TCommonAvi;
  aviStringArray = array[0 .. 7] of String;

{ Define constant arrays containing the TCommonAvi values
  in the same order they appear in the RadioGroup object,
  and also strings for displaying in the StatusText object
  that shows which animation is running. }
const

  aviKinds: aviKindArray =
    (aviCopyFile,
     aviCopyFiles,
     aviDeleteFile,
     aviEmptyRecycle,
     aviFindComputer,
     aviFindFile,
     aviFindFolder,
     aviRecycleFile);

  aviStrings: aviStringArray =
    ('aviCopyFile',
     'aviCopyFiles',
     'aviDeleteFile',
     'aviEmptyRecycle',
     'aviFindComputer',
     'aviFindFile',
     'aviFindFolder',
     'aviRecycleFile');

{ Start selected animation. This event handler is assigned
  to the OnClick event for both the Go button and the
  RadioGroup1. Clicking Go or clicking a radio button starts
  the animation immediately. }
procedure TMainForm.GoBitBtnClick(Sender: TObject);
var
  AnimIndex: Integer;  // Index of selected animation
begin
  AnimIndex := RadioGroup1.ItemIndex;
  with Animate1 do
  begin
    StatusText.Caption := aviStrings[AnimIndex];
    CommonAVI := aviKinds[AnimIndex];
    Play(1, FrameCount, 0);  // Start the animation
  end;
end;

{ Halt the animation when user clicks the Stop button. }
procedure TMainForm.StopBitBtnClick(Sender: TObject);
begin
  Animate1.Stop;
  StatusText.Caption := '(stopped)';
end;

end.
