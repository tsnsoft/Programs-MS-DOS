unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, TeEngine, Series, ExtCtrls, TeeProcs, Chart,
  StdCtrls, Buttons, TeCanvas;

type
  TMainForm = class(TForm)
    Chart1: TChart;
    Series1: TLineSeries;
    Series2: TLineSeries;
    Series4: TLineSeries;
    Series5: TLineSeries;
    Series6: TLineSeries;
    Series3: TLineSeries;
    BitBtn1: TBitBtn;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

{ Change the following pathname if your data file is
  in another location. The pathname is relative to the
  current directory, which is assumed to be at the
  same level as \Data\. }

const
  FileName = '..\Data\KeyWestMayClimate.txt';

{ The following procedure is called when the form is first
  activated. At that time, the program opens the data file,
  reads its values, and adds them to the chart's series
  objects. }

procedure TMainForm.FormActivate(Sender: TObject);
var
  F: TextFile;                   // File variable
  Date: Integer;                 // First column in file data
  NormalHigh : Integer;          // Next column
  NormalLow : Integer;           // and so on ...
  RecordHigh : Integer;
  RecordHighYear : Integer;
  RecordLow : Integer;
  RecordLowYear : Integer;
  ColdestMaximum : Integer;
  ColdestMaximumYear : Integer;
  WarmestMaximum : Integer;      // ... down to the
  WarmestMaximumYear : Integer;  // Last column in file data
begin
  AssignFile(F, FileName);   // Initialize file variable
  Reset(F);                  // Open the file
  while not Eof(F) do        // Loop until the end of the file
  begin
    Read(F,                  // Read one row of data
      Date,                  // into the individual variables.
      NormalHigh,
      NormalLow,
      RecordHigh,
      RecordHighYear,
      RecordLow,
      RecordLowYear,
      ColdestMaximum,
      ColdestMaximumYear,
      WarmestMaximum,
      WarmestMaximumYear);   // End of Read statement

    { One row of file data has been loaded at this point. The
      following statements add the data points to each of the
      line chart's six series objects. The empty string
      arguments can be used to label data points. These
      strings aren't used here because the X axis of this
      sample chart already shows day values (1, 2, ..., 31). }

    Series1.AddXY(Date, NormalHigh, '', clTeeColor);
    Series2.AddXY(Date, NormalLow, '', clTeeColor);
    Series3.AddXY(Date, RecordHigh, '', clTeeColor);
    Series4.AddXY(Date, RecordLow, '', clTeeColor);
    Series5.AddXY(Date, ColdestMaximum, '', clTeeColor);
    Series6.AddXY(Date, WarmestMaximum, '', clTeeColor);

  end;
end;

end.
