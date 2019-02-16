unit Open;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Db, DbTables;

type
  TOpenForm = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Bevel2: TBevel;
    Label2: TLabel;
    ComboBox2: TComboBox;
    procedure FormActivate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OpenForm: TOpenForm;

implementation

{$R *.DFM}

procedure TOpenForm.FormActivate(Sender: TObject);
begin
  Session.GetAliasNames(ComboBox1.Items);
end;

procedure TOpenForm.ComboBox1Change(Sender: TObject);
begin
  Session.GetTableNames(ComboBox1.Text, '*.*',
    False, False, ComboBox2.Items);
  ComboBox2.ItemIndex := 0;
end;

end.
