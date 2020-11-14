@echo off
set filename=radyum

rem parameter zi allows for debug symbols
rem C:\TASM\tasm.exe /zi /m3 %filename%.asm
rem C:\TASM\tlink.exe /3 /x /v %filename%.obj

C:\TASM\tasm.exe /m3 %filename%.asm
C:\TASM\tlink.exe /3 /x %filename%.obj


REM %1.exe

pause