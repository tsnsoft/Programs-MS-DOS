@echo off
echo GetVer show you version of DOS you use (if you forget it ;)
getver
echo �
pause
echo Now GetVer.com converted into FakeDOS.exe
..\..\mdf getver.com fakedos.exe setver.mdf 1.23
echo Check out the result of execution of FakeDOS.exe ;)
fakedos
echo �
pause
echo Now FakeDOS.exe turned back to GetVer.com
..\..\mdf fakedos.exe getver.com setver.mdf
echo And return old good DOS to you :)
getver
echo �
pause