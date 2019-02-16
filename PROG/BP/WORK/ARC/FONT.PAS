var i: byte;
  FontF: file; FontP: pointer;

begin
  Assign(FontF, 'c:\util\keyrus\fnt\jam.fnt');
  Reset(FontF, 1);
  GetMem(FontP, FileSize(FontF));
  BlockRead(FontF, FontP^, FileSize(FontF));
  close(FontF);

  asm mov ah,11h; mov al,21h; les dx, FontP; mov bp, dx;
     mov cx,14; mov bl,2; mov dl,0; mov bh,0; int 10h;
  end;

end.