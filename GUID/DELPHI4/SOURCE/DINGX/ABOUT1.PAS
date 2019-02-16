unit About1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TDingButtonXAbout = class(TForm)
    CtlImage: TSpeedButton;
    NameLbl: TLabel;
    OkBtn: TButton;
    CopyrightLbl: TLabel;
    DescLbl: TLabel;
  end;

procedure ShowDingButtonXAbout;

implementation

{$R *.DFM}

procedure ShowDingButtonXAbout;
begin
  with TDingButtonXAbout.Create(nil) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

end.
