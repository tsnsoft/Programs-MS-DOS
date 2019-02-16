@echo off
tasm /t/m %1
tlink /x %1
exe2bin %1.exe
del %1.obj
del %1.mdf
del %1.exe
ren %1.bin %1.mdf