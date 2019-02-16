unit Main;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls,
  Forms, Dialogs, Inidata, StdCtrls, Buttons, TabNotBk,
  IniFiles, ComCtrls;

type
  TMainForm = class(TForm)
    TabbedNotebook1: TTabbedNotebook;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Edit1: TEdit;
    Edit2: TEdit;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    procedure LoadOptions;
    procedure SaveOptions;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

procedure TMainForm.LoadOptions;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create('test.ini');
  try
    LoadDataFromINI(MainForm, IniFile);
  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.SaveOptions;
var
  IniFile: TIniFile;
begin
  IniFile := TIniFile.Create('test.ini');
  try
    SaveDataToINI(MainForm, IniFile);
  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  RegisterINIDataProp('TCheckBox', 'State');
  RegisterINIDataProp('TRadioButton', 'Checked');
  RegisterINIDataProp('TEdit', 'Text');
  LoadOptions;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
begin
  SaveOptions;
end;

end.
