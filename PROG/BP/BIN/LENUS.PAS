program Hrusa;
uses graph;
var gd,gm:integer;
begin
gd:=detect; initgraph (gd,gm,'E:\tp\bgi');
setcolor(13);
circle(320,190,85); circle(310,190,5); circle(330,190,5);
ellipse(320,190,0,360,25,20); line(260,30,235,190);
moveto(260,30); lineto(320,105);
lineto(380,30); lineto(405,190);
setfillstyle(4,10); fillellipse(260,160,10,15);
fillellipse(380,160,10,15); setfillstyle(1,0);
pieslice(260,160,0,360,5); pieslice(380,160,0,360,5);
setcolor(4); arc(320,190,200,340,70);
setfillstyle(8,11);
floodfill(270,100,13); floodfill(330,100,13);
line(240,330,400,250); line(240,250,400,330);
line(240,250,240,330); line(400,250,400,330);
setfillstyle(2,10);
floodfill(290,300,4); floodfill(350,300,4);
moveto(242,350);
settextstyle(0,0,2); outtext('�� ���誠');
readln; closegraph;
end.