unit Module1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus;

type
  TDataModule1 = class(TDataModule)
    MainMenu1: TMainMenu;
    procedure DataModuleFormExit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataModule1: TDataModule1;

implementation

uses Main;

{$R *.DFM}

procedure TDataModule1.DataModuleFormExit1Click(Sender: TObject);
begin
  MainForm.Close;
end;

end.
