{ �ணࠬ�� ��⠭���� ᨬ����� ���짮��⥫�� }
{ * TSN * Associate, 22.09.1997, �Sn }

uses crt; { ������稬 ����� ࠡ��� � ���᮫�� }
const n=4; { ����뢠�� ������⢮ ��⠭���������� ᨬ����� }

{ ���襬 ᨬ���� ��襣� ���� }
const MyFont: array [1..n, 1..8] of byte=(
                                    ($ff,$81,$81,$81,$81,$81,$81,$ff),
                                    ($00,$7e,$7e,$7e,$7e,$7e,$7e,$00),
                                    ($00,$00,$3c,$3c,$3c,$3c,$00,$00),
                                    ($00,$00,$00,$18,$18,$00,$00,$00)
                                    );

{ ��楤�� ��⠭���� ���� ᨬ����� }
procedure Font (var sss); assembler;
asm
  { ��⠭���� ᢮� ���� � ����� 0 }
  les bp, sss; { ����㦠�� ES:BP ���ᮬ ��襣� ���� }
  mov ah,11h;  { ����뢠�� ����� �㭪樨 ࠡ��� � ���⠬� }
  mov al,10h;  { ����뢠�� ����� ����㭪樨 ����㧪� ��襣� ���� }
  mov bh,8h;   { ����뢠�� ����� (� �窠�) ᨬ����� ��襣� ���� }
  mov bl,0h;   { ����뢠�� ����� ����㦠����� ����� ������������ }
  mov cx,n;    { ����뢠�� ������⢮ ᨬ����� � ��襬 ���� }
  mov dx,80h;  { ����뢠�� ��� ��ࢮ�� ᨬ���� ��襣� ���� }
  int 10h;     { ��뢠�� Video - �ࢨ� }
end;

begin
  { ��⠭���� ���� 8*8 � ����� 0 }
asm
  mov ah,11h; { ����뢠�� ����� �㭪樨 ࠡ��� � ���⠬� }
  mov al,12h; { ����뢠�� ����� ����㭪樨 ����㧪� ���� 8*8 }
  mov bl,0;   { ����뢠�� ����� ����㦠����� ����� ������������ }
  int 10h;    { ��뢠�� Video - �ࢨ� }
end;

clrscr; writeln('* TSN * Associate'); writeln;
writeln ('���������� ����� ᨬ����� ���짮��⥫�� - ����'); readln;
Font(MyFont);

{ ������� ���� ��� ��ᬮ�� ᮤ�ন���� ��࠭� }
readln;

  { ��⠭���� ���� 8*14 � ����� 0 }
asm
  mov ah,11h; mov al,11h; mov bl,0; int 10h;
end;

writeln('... �������������� ����� ������������'); readln;
end.
