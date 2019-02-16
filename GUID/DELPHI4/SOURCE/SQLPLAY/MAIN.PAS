unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,
  DBGrids, DBCtrls, DB, DBTables, Open;

type
  TMainForm = class(TForm)
    DataSource1: TDataSource;
    DBNavigator1: TDBNavigator;
    DBGrid1: TDBGrid;
    Memo1: TMemo;
    Bevel1: TBevel;
    PerformBitBtn: TBitBtn;
    CloseBitBtn: TBitBtn;
    OpenBitBtn: TBitBtn;
    Query1: TQuery;
    procedure OpenBitBtnClick(Sender: TObject);
    procedure PerformBitBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.OpenBitBtnClick(Sender: TObject);
begin
  if OpenForm.ShowModal = mrOk then
  begin
    Query1.Close;
    try
      Query1.DatabaseName := OpenForm.ComboBox1.Text;
      Query1.SQL.Clear;
      Query1.SQL.Add('Select * From ' +
        OpenForm.ComboBox2.Text);
      Memo1.Lines := Query1.SQL;
      Query1.Open;
      Memo1.SetFocus;
      PerformBitBtn.Enabled := True;
    except;
      ShowMessage('Unable to open database');
    end;
  end;
end;

procedure TMainForm.PerformBitBtnClick(Sender: TObject);
begin
  Query1.Close;
  try
    Query1.SQL := Memo1.Lines;
    Query1.Open;
  except
    ShowMessage('Invalid query');
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Query1.Close;
end;

end.
