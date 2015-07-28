@echo off

rem uninstall
rem Copyright (C) 2015, David C. Merritt, david.c.merritt@siemens.com
rem
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <http://www.gnu.org/licenses/>.
rem
rem ---------------------------------------------------------------------
rem
rem DOS uninstall script to begin the removal of the Solid Edge Translate 
rem from Explorer utility
rem
rem ---------------------------------------------------------------------
rem
rem 28/07/2015  merritt  initial release
rem

set SOFTWARE_NAME=Solid Edge Translate from Explorer
title %SOFTWARE_NAME%: Uninstalling...

rem set up some variables 
for /f %%i in ("%0") do set SOFTWARE_DIR=%%~dpi
set INSTALL_DIR=%ProgramFiles%\%SOFTWARE_NAME%
set MENU_DIR=%ProgramData%\Microsoft\Windows\Start Menu\Programs\%SOFTWARE_NAME%

rem check if folders are installed
if exist "%INSTALL_DIR%" goto :NowRemove
if exist "%MENU_DIR%" goto :NowRemove

rem
rem display error for existing files 
rem
:ExistsError
title %SOFTWARE_NAME%: ERROR!
echo.
echo.
echo     Error: %SOFTWARE_NAME% does not appear to be installed!
echo.
echo.
echo     Press any key to exit . . .
rem pause > nul
goto :CleanExit

rem
rem copy our uninstall file so we can then delete everything
rem
:NowRemove
copy /y "%SOFTWARE_DIR%SeBeautifyRemove.cmd" "%TEMP%\SeBeautifyRemove.cmd" > nul
copy /y "%INSTALL_DIR%\src\SeBeautifyRemove.cmd" "%TEMP%\SeBeautifyRemove.cmd" > nul
ping 127.0.0.1 -n 1 > nul
if exist "%TEMP%\SeBeautifyRemove.cmd" (start "" /D %TEMP% "%TEMP%\SeBeautifyRemove.cmd")
goto :CleanExit

rem
rem cleanly exit
rem
:CleanExit
set SOFTWARE_NAME=
set SOFTWARE_DIR=
set INSTALL_DIR=
exit