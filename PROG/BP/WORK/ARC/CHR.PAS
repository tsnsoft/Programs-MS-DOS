{ Example for RegisterBGIFont }

uses Graph;
var
  Driver, Mode, kk: Integer;
  FontF: file;
  FontP: pointer;
begin
  { Open font file, read, register }
  Assign(FontF, 'c:\aff\bp\bgi\tscr.CHR');
  Reset(FontF, 1);
  GetMem(FontP, FileSize(FontF));
  BlockRead(FontF, FontP^,
            FileSize(FontF));
  kk:=RegisterBGIfont(FontP);
  if kk < 0 then
  begin
    WriteLn('Error registering font: ',
            GraphErrorMsg(GraphResult));
    Halt(1);
  end;
  { Init graphics }
  Driver := Detect;
  InitGraph(Driver, Mode, 'c:\aff\bp\bgi');
  if GraphResult < 0 then
    Halt(1);
  { Select registered font }
  SetTextStyle(kk, HorizDir, 2);
  OutText('Triplex loaded by user program + Талипов Сережа !!!');
  MoveTo(0, TextHeight('a'));
  ReadLn;
  CloseGraph;
end.
