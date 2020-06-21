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

CHOICE /C:YNQ Do you want to load last saved Game (yes/no/quit)
ECHO.
IF ERRORLEVEL 3 GOTO TheEnd
IF ERRORLEVEL 2 GOTO ResetGame
IF ERRORLEVEL 1 GOTO GoAhead
:ResetGame
ECHO Resetting Game
:GoAhead
ECHO Running Escape the 80s now
ECHO.
RADYUM.EXE
:TheEnd
