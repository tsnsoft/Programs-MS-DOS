uses crt;
var a,b: byte;
const m: array [1..9] of char=('1','2','3','4','5','6','7','8','9');
var tt: byte;

function tsn(k: char): integer;
var sm,t: integer;
begin
     a:=3; b:=7; t:=a;
     while m[t]<>k do begin t:=((b+a) div 2);
       if a=b then if m[t]=k then break else begin t:=-1; break; end;
       if m[t]>k then b:=t else if a<>t then a:=t else a:=b;
     end;
     tsn:=t;
end;

begin
  clrscr;
  for tt:=1 to 9 do writeln('*',tsn(chr(tt+$30)),'*');
  readln;
end.
