unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, BarChart;

type
  TMainForm = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    BarChart1: TBarChart;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  BarChart1 := TBarChart.Create(Self);
  BarChart1.Parent := Self;
  with BarChart1 do
  begin
    Left := 20;
    Top := 20;
    Width := 375;
    Height := 200;
    Data.Add('65.0');
    Data.Add('45.0');
    Data.Add('95.0');
    Data.Add('76.0');
    Data.Add('51.0');
    Data.Add('90.0');
  end;
end;

end.
