unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, Forms, DBCtrls, DB, Grids, DBGrids, DBTables,
  Mask, ExtCtrls, Buttons;

type
  TMainForm = class(TForm)
    ScrollBox: TScrollBox;
    Label1: TLabel;
    EditCUR_PRICE: TDBEdit;
    Label2: TLabel;
    EditEXCHANGE: TDBEdit;
    Label3: TLabel;
    EditCO_NAME: TDBEdit;
    Label4: TLabel;
    EditSYMBOL: TDBEdit;
    Label5: TLabel;
    EditP_E_RATIO: TDBEdit;
    Label6: TLabel;
    EditYRL_LOW: TDBEdit;
    Label7: TLabel;
    EditYRL_HIGH: TDBEdit;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    MasterSource: TDataSource;
    Panel2: TPanel;
    MasterTable: TTable;
    DetailTable: TTable;
    DetailSource: TDataSource;
    DBGrid1: TDBGrid;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  MasterTable.Open;
  DetailTable.Open;
end;

end.
