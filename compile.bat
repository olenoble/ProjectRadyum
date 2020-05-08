@echo off
set filename=radyum

echo parameter zi allows for debug symbols
C:\TASM\tasm.exe /zi /m3 %filename%.asm
C:\TASM\tlink.exe /3 /x /v %filename%.obj

REM %1.exe

pause