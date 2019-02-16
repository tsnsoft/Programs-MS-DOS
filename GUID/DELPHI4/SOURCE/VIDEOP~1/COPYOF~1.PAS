unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, MPlayer, ComCtrls;

type
  TForm1 = class(TForm)
    MediaPlayer1: TMediaPlayer;
    OpenBitBtn: TBitBtn;
    BitBtn2: TBitBtn;
    OpenDialog1: TOpenDialog;
    AutoPlayCheckBox: TCheckBox;
    AutoStartCheckBox: TCheckBox;
    procedure OpenBitBtnClick(Sender: TObject);
    procedure MediaPlayer1Notify(Sender: TObject);
    procedure MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
      var DoDefault: Boolean);
    procedure AutoPlayCheckBoxClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure SetMediaPlayerButtons;
    procedure SetPlayButtonSet;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

(*

AutoReplay:   Off
Button  Open     Close    Play     Pause    Stop
Play    ON       OFF      OFF      ON       ON
Pause   OFF      OFF      ON       OFF      OFF
Stop    OFF      OFF      ON       ON       OFF
Next    ON       OFF      ON       ON       ON
Prev    ON       OFF      ON       ON       ON
Step    ON       OFF      ON       ON       ON
Back    ON       OFF      ON       ON       ON


AutoReplay:   On
Button  Open     Close    Play     Pause    Stop
Play    ON       OFF      OFF      ON       ON
Pause   OFF      OFF      ON       OFF      OFF
Stop    OFF      OFF      ON       ON       OFF
Next    ON       OFF      OFF      ON       ON
Prev    ON       OFF      OFF      ON       ON
Step    ON       OFF      OFF      ON       ON
Back    ON       OFF      OFF      ON       ON

*)

const
  OpenButtonSet  : TButtonSet =
    [
      btPlay,
      TMPBtnType(btNext),
      TMPBtnType(btPrev),
      btStep,
      btBack
    ];
  CloseButtonSet : TButtonSet =
    [
    ];
  PlayButtonSetNoReplay  : TButtonSet =
    [
      btPause,
      btStop,
      TMPBtnType(btNext),
      TMPBtnType(btPrev),
      btStep,
      btBack
    ];
  PlayButtonSetReplay  : TButtonSet =
    [
      btPause,
      btStop
    ];
  PauseButtonSet : TButtonSet =
    [
      btPlay,
      btStop,
      TMPBtnType(btNext),
      TMPBtnType(btPrev),
      btStep,
      btBack
    ];
  StopButtonSet  : TButtonSet =
    [
      btPlay,
      TMPBtnType(btNext),
      TMPBtnType(btPrev),
      btStep,
      btBack
    ];

var
  PlayButtonSet: TButtonSet;     { Varies according to Autoplay checkbox }
  CurrentButtonSet: TButtonSet;  { Holds set of enabled MediaPlayer buttons }

{ Respond to user selection of the Open file button }
procedure TForm1.OpenBitBtnClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
    Form1.Caption := OpenDialog1.FileName;
    MediaPlayer1.FileName := OpenDialog1.FileName;
    MediaPlayer1.Open;
    MediaPlayer1.Notify := True;
    if AutoStartCheckBox.Checked then
    begin
      CurrentButtonSet := PlayButtonSet;
      MediaPlayer1.Play;
    end else
    begin
      CurrentButtonSet := OpenButtonSet;
    end;
    SetMediaPlayerButtons;
  end;
end;

procedure TForm1.MediaPlayer1Notify(Sender: TObject);
begin
  case MediaPlayer1.Mode of
    mpNotReady :
    begin
      CurrentButtonSet := CloseButtonSet;
    end;
    mpStopped  :
    begin
      if AutoPlayCheckBox.Checked then
      begin
        MediaPlayer1.Rewind;
        CurrentButtonSet := PlayButtonSet;
        MediaPlayer1.Play;
      end;
    end;
    mpPlaying  :
    begin
      CurrentButtonSet := PlayButtonSet;
    end;
    mpPaused   :
    begin
      CurrentButtonSet := PauseButtonSet;
    end;
    mpOpen     :
    begin
      CurrentButtonSet := OpenButtonSet;
    end;
  end;
  SetMediaPlayerButtons;
  MediaPlayer1.Notify := True;  { So we receive the next notify event }
end;

procedure TForm1.MediaPlayer1Click(Sender: TObject; Button: TMPBtnType;
  var DoDefault: Boolean);
begin
  MediaPlayer1.Notify := False;  { Do not change position of statement! }
  if Button = btStop then
  begin
    MediaPlayer1.Stop;
    CurrentButtonSet := OpenButtonSet;
  end else
  if Button = btPause then
  begin
    MediaPlayer1.Pause;
    CurrentButtonSet := PauseButtonSet;
  end;
  SetMediaPlayerButtons;
end;

procedure TForm1.AutoPlayCheckBoxClick(Sender: TObject);
begin
  if AutoPlayCheckBox.Checked then
    MediaPlayer1.Notify := True;  { So media events trigger notification }
  SetPlayButtonSet;  { Enable buttons according to checkbox state }
  SetMediaPlayerButtons;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
{ Do not change the order of the following statements }
  SetPlayButtonSet;       { Enable buttons according to checkbox state }
  SetMediaPlayerButtons;  { Enable control buttons }
end;

{- Private procedures }

{ Enable MediaPlayerButtons according to program state }
procedure TForm1.SetMediaPlayerButtons;
begin
{ Do not change the order of the following statements }
  if MediaPlayer1.Mode = mpPlaying then
    CurrentButtonSet := PlayButtonSet;
  MediaPlayer1.EnabledButtons := [];
  MediaPlayer1.EnabledButtons := CurrentButtonSet;
end;

{ Change set of buttons based on auto-replay checkbox }
procedure TForm1.SetPlayButtonSet;
begin
{ Do not change the order of the following statements }
  if AutoPlayCheckBox.Checked then
    PlayButtonSet := PlayButtonSetReplay
  else
    PlayButtonSet := PlayButtonSetNoReplay;
  SetMediaPlayerButtons;
end;

end.
