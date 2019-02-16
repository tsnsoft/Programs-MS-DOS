@echo off
c:\aff\bp\bin\tasm  %1,,,%1 /la /c /zi
if errorlevel==0 c:\aff\bp\bin\tlink %1 /v
if errorlevel==0 c:\aff\bp\bin\tcref %1 /r
if errorlevel==0 del %1.xrf
:end
