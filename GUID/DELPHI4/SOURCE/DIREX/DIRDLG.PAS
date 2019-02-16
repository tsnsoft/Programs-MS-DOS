unit Dirdlg;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, FileCtrl;

type
  TDirDlgForm = class(TForm)
    FileListBox: TFileListBox;
    DirectoryListBox: TDirectoryListBox;
    DriveComboBox: TDriveComboBox;
    FilterComboBox: TFilterComboBox;
    FileNameEdit: TEdit;
    FileNameLabel: TLabel;
    DirectoriesLabel: TLabel;
    DirLabel: TLabel;
    ListFilesLabel: TLabel;
    DrivesLabel: TLabel;
    OkBitBtn: TBitBtn;
    CancelBitBtn: TBitBtn;
    procedure FileListBoxDblClick(Sender: TObject);
    procedure DriveComboBoxChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DirDlgForm: TDirDlgForm;

implementation

{$R *.DFM}

procedure TDirDlgForm.FileListBoxDblClick(Sender: TObject);
begin
  OkBitBtn.Click;  { Simulate OK button click }
end;

procedure TDirDlgForm.DriveComboBoxChange(Sender: TObject);
begin
  DirectoryListBox.Drive := DriveComboBox.Drive;
  FileListBox.Drive := DriveComboBox.Drive;
  FileListBox.Directory := DirectoryListBox.Directory;
end;

end.
