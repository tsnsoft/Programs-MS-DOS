unit Client;

interface

uses
  Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, DdeMan, StdCtrls, Buttons;

type
  TClientForm = class(TForm)
    DdeClientItem1: TDdeClientItem;
    DdeClientConv1: TDdeClientConv;
    Edit1: TEdit;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure DdeClientItem1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ClientForm: TClientForm;

implementation

{$R *.DFM}

procedure TClientForm.FormCreate(Sender: TObject);
begin
  DdeClientItem1.DdeItem := 'DdeServerItem1';
end;

procedure TClientForm.DdeClientItem1Change(Sender: TObject);
begin
  Edit1.Text := DdeClientItem1.Text;
end;

end.
