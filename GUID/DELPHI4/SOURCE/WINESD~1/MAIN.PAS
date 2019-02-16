unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, StdCtrls, Buttons, Grids, DBGrids, ExtCtrls, DBCtrls;

type
  TMainForm = class(TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    BitBtn1: TBitBtn;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

end.
