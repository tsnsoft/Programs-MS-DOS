unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, TeEngine, Series, ExtCtrls,
  TeeProcs, Chart, Buttons;

type
  TMainForm = class(TForm)
    Chart1: TChart;
    Button1: TButton;
    Series1: TBarSeries;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

var
  HeapStatus: THeapStatus;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  HeapStatus := System.GetHeapStatus;
  with Series1, HeapStatus do
  begin
//    Add(TotalAddrSpace, 'Total address space', clTeeColor);
//    Add(TotalUncommitted, 'Total Uncommitted', clTeeColor);
    Add(TotalCommitted, 'Total Committed', clTeeColor);
    Add(TotalAllocated, 'Total Allocated', clTeeColor);
    Add(TotalFree, 'Total Free', clTeeColor);
    Add(FreeSmall, 'Free Small', clTeeColor);
    Add(FreeBig, 'Free Big', clTeeColor);
    Add(Unused, 'Unused', clTeeColor);
    Add(Overhead, 'Overhead', clTeeColor);
  end;
end;

end.
