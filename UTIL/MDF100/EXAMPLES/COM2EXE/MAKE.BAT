@echo off
echo Make an .exe version of ShowRegs
..\..\mdf showregs.com showregs.exe com2exe.mdf
showregs.exe
echo Now ShowRegs.EXE will be converted back to ShowRegs.COM
pause
..\..\mdf showregs.exe showregs.com com2exe.mdf
showregs.com
