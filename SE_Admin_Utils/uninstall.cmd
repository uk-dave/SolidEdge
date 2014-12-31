@echo off

rem uninstall
rem Copyright (C) 2014, David C. Merritt, david.c.merritt@siemens.com
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
rem DOS uninstall script to call the Solid Edge Admin Utils remove script
rem
rem ---------------------------------------------------------------------
rem
rem 31/12/2014  merritt  initial release
rem

set SOFTWARE_NAME=Solid Edge Admin Utils
title %SOFTWARE_NAME%: Uninstalling...

rem set up some variables 
for /f %%i in ("%0") do set SOFTWARE_DIR=%%~dpi
set INSTALL_DIR=%ProgramFiles%\%SOFTWARE_NAME%

rem copy our uninstall file so we can delete everything
copy /y "%SOFTWARE_DIR%src\SE_Admin_Utils_remove.cmd" "%TEMP%\SE_Admin_Utils_remove.cmd"
if exist "%TEMP%\SE_Admin_Utils_remove.cmd" (start "" /D %TEMP% "%TEMP%\SE_Admin_Utils_remove.cmd")

rem
rem cleanly exit
rem
:CleanExit
set SOFTWARE_NAME=
set SOFTWARE_DIR=
set INSTALL_DIR=
exit