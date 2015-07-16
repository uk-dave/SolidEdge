@echo off

rem SE_Admin_Utils_remove
rem Copyright (C) 2014-2015, David C. Merritt, david.c.merritt@siemens.com
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
rem DOS script to remove the Solid Edge Admin Utils
rem
rem ---------------------------------------------------------------------
rem
rem 31/12/2014  merritt  initial release
rem 02/01/2015  merritt  added warning about losing custom config files
rem 02/01/2014  merritt  moved start menu shortcuts to all users
rrem

set SOFTWARE_NAME=Solid Edge Admin Utils
title %SOFTWARE_NAME%: Uninstalling...
cls

rem set up some variables 
for /f %%i in ("%0") do set SOFTWARE_DIR=%%~dpi
set INSTALL_DIR=%ProgramFiles%\%SOFTWARE_NAME%
set MENU_DIR=%ProgramData%\Microsoft\Windows\Start Menu\Programs

rem confirm removal
echo.
echo.
echo     WARNING! This will also remove any custom config files added.
echo. 
echo.
set /P CONFIRM=Are you sure you want to remove %SOFTWARE_NAME% (Y/N)? 
if /i {%CONFIRM%}=={y} (goto :RemoveSoftware)
if /i {%CONFIRM%}=={yes} (goto :RemoveSoftware)
goto :CleanExit

rem start removing
:RemoveSoftware
cls
echo.
echo     Uninstalling %SOFTWARE_NAME%...

rem remove our registry shortcuts
echo.
echo         Removing context menu shortcuts...
ping 127.0.0.1 -n 3 > nul
regedit /s "%INSTALL_DIR%\registry\remove\remove_desktop_folder_menu_install.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_desktop_folder_menu_uninstall.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_desktop_menu_user_reset.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_background_menu_install.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_background_menu_uninstall.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_background_menu_user_reset.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_folder_menu_install.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_folder_menu_uninstall.reg"
regedit /s "%INSTALL_DIR%\registry\remove\remove_win_exp_folder_menu_user_reset.reg"

rem remove our menu shortcuts
echo.
echo         Removing Start menu shortcuts...
if exist "%MENU_DIR%\%SOFTWARE_NAME%" (rmdir /s /q "%MENU_DIR%\%SOFTWARE_NAME%" >nul)
ping 127.0.0.1 -n 3 > nul

rem remove our install folder
echo.
echo         Removing program files...
if exist "%INSTALL_DIR%" (rmdir /s /q "%INSTALL_DIR%" >nul)
ping 127.0.0.1 -n 3 > nul

rem add an extended delay to ensure all files are released
echo.
echo         Cleaning up...
ping 127.0.0.1 -n 3 > nul

rem uninstall should be complete so open our start menu and then exit
title %SOFTWARE_NAME%: Uninstalled!
echo.
echo.
echo     Solid Edge Admin Utils has been uninstalled!
echo.
if exist "%MENU_DIR%\%SOFTWARE_NAME%" (echo     Unable to remove all Start Menu files. Please delete manually.)
if exist "%MENU_DIR%\%SOFTWARE_NAME%" (explorer "%MENU_DIR%\%SOFTWARE_NAME%")
if exist "%INSTALL_DIR%" (echo     Unable to remove all Install files. Please delete manually.)
if exist "%INSTALL_DIR%" (explorer "%INSTALL_DIR%")
echo.
echo     Press any key to exit . . .
pause > nul
goto :CleanExit


rem
rem cleanly exit
rem
:CleanExit
set SOFTWARE_NAME=
set SOFTWARE_DIR=
set INSTALL_DIR=
set MENU_DIR=
set CONFIRM=
exit