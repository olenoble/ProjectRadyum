@ECHO OFF
CLS
ECHO -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
ECHO     ______                              ________            ____  ____      
ECHO    / ____/_____________ _____  ___     /_  __/ /_  ___     ( __ )/ __ \_____
ECHO   / __/ / ___/ ___/ __ `/ __ \/ _ \     / / / __ \/ _ \   / __  / / / / ___/
ECHO  / /___(__  ) /__/ /_/ / /_/ /  __/    / / / / / /  __/  / /_/ / /_/ (__  ) 
ECHO /_____/____/\___/\__,_/ .___/\___/    /_/ /_/ /_/\___/   \____/\____/____/  
ECHO                      /_/                                              
ECHO -~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-
ECHO.
ECHO.
ECHO Escape the 80s  - Le jeu
CHOICE /C:ONQ Voulez-vous utiliser la derniere sauvegarde (oui/non/quitter)
ECHO.
IF ERRORLEVEL 3 GOTO QuitGame
IF ERRORLEVEL 2 GOTO ResetGame
IF ERRORLEVEL 1 GOTO GoAhead
:QuitGame
ECHO.
ECHO :'( ... ok ....
ECHO.
GOTO TheEnd
:ResetGame
ECHO Sauvegarde existante effacee...
COPY /Y ROOM.DAT ROOMP.DAT  > nul 2>&1
COPY /Y ROOM0.DAT ROOM.DAT  > nul 2>&1
:GoAhead
ECHO Lancement de "Escape the 80s"...
ECHO.
RADYUM.EXE
:TheEnd
