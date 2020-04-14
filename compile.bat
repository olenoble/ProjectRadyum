@echo off
set filename=radyum

C:\TASM\tasm.exe /m3 %filename%.asm
C:\TASM\tlink.exe /3 /x /v %filename%.obj

REM %1.exe

pause