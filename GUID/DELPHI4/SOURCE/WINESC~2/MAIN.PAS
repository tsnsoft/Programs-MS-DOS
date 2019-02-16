unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, TeEngine, Series, ExtCtrls, TeeProcs, Chart, DBChart,
  Db, DBTables;

type
  TMainForm = class(TForm)
    Table1: TTable;
    DataSource1: TDataSource;
    DBChart1: TDBChart;
    Series1: THorizBarSeries;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure BitBtn2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

uses
  TeePrevi;

procedure TMainForm.BitBtn2Click(Sender: TObject);
begin
  ChartPreview(MainForm, DBChart1);
end;

end.
