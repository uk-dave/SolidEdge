@echo off

rem install
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
rem DOS script to install the Solid Edge Admin Utils
rem
rem ---------------------------------------------------------------------
rem
rem 31/12/2014  merritt  initial release
rem

set SOFTWARE_NAME=Solid Edge Admin Utils
title %SOFTWARE_NAME%: Installing...

rem set up some variables 
for /f %%i in ("%0") do set SOFTWARE_DIR=%%~dpi
set INSTALL_DIR=%ProgramFiles%\%SOFTWARE_NAME%
set MENU_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs

rem check if our install folders already exist
if exist "%INSTALL_DIR%" goto :ExistsError
if exist "%MENU_DIR%\%SOFTWARE_NAME%" goto :ExistsError

rem
rem Display our template menu
rem
:MenuTemplate
cls
echo.
echo.
echo        ษอออออออออออออออออออออออป
echo        บ   Default Standard    บ
echo        ฬอออออออออออออออออออออออน
echo        บ                       บ
echo        บ (1) Metric            บ
echo        บ (2) JIS Metric        บ
echo        บ (3) ISO Metric        บ
echo        บ (4) ANSI Inch         บ
echo        บ (5) DIN Metric        บ
echo        บ (6) UNI Metric        บ
echo        บ (7) ESKD Metric       บ
echo        บ (8) GB Metric         บ
echo        บ (9) ANSI Metric       บ
echo        บ                       บ
echo        บ (0) Exit              บ
echo        บ                       บ
echo        ศอออออออออออออออออออออออผ   
echo.
echo.

set CHOICE_MENU=
set /p CHOICE_MENU=Enter option #: 
echo.

if not '%CHOICE_MENU%'=='' set CHOICE_MENU=%CHOICE_MENU:~0,1%

if '%CHOICE_MENU%'=='1' goto :Std1
if '%CHOICE_MENU%'=='2' goto :Std2
if '%CHOICE_MENU%'=='3' goto :Std3
if '%CHOICE_MENU%'=='4' goto :Std4
if '%CHOICE_MENU%'=='5' goto :Std5
if '%CHOICE_MENU%'=='6' goto :Std6
if '%CHOICE_MENU%'=='7' goto :Std7
if '%CHOICE_MENU%'=='8' goto :Std8
if '%CHOICE_MENU%'=='9' goto :Std9
if '%CHOICE_MENU%'=='0' goto :CleanExit

echo        "%CHOICE_MENU%" is not a valid option - try again!
echo.

echo        Press any key to continue . . .
pause > nul
goto :MenuTemplate


rem
rem Set our template standard type
rem
:Std1
set CHOICE_STD=metric
goto :InstallSoftware

:Std2
set CHOICE_STD=JIS_metric
goto :InstallSoftware

:Std3
set CHOICE_STD=ISO_metric
goto :InstallSoftware

:Std4
set CHOICE_STD=ANSI_inch
goto :InstallSoftware

:Std5
set CHOICE_STD=DIN_metric
goto :InstallSoftware

:Std6
set CHOICE_STD=UNI_metric
goto :InstallSoftware

:Std7
set CHOICE_STD=ESKD_metric
goto :InstallSoftware

:Std8
set CHOICE_STD=GB_metric
goto :InstallSoftware

:Std9
set CHOICE_STD=ANSI_metric
goto :InstallSoftware

rem
rem finally install our software 
rem
:InstallSoftware
cls
echo.
echo     %SOFTWARE_NAME%: Installing...

rem copy everything to our install folder
xcopy "%SOFTWARE_DIR%*" "%INSTALL_DIR%" /h /e /i /r /y /d 
cls

rem set our powershell execution policy
regedit /s "%SOFTWARE_DIR%registry\powershell_execution_policy.reg"

rem copy our start menu shortcuts
mkdir "%MENU_DIR%\%SOFTWARE_NAME%" 
ping 127.0.0.1 -n 2 > nul
xcopy "%SOFTWARE_DIR%start_menu\*" "%MENU_DIR%" /h /e /i /r /y /d 
cls

rem install our registry shortcuts
regedit /s "%SOFTWARE_DIR%registry\desktop_menu_install_%CHOICE_STD%.reg"
regedit /s "%SOFTWARE_DIR%registry\desktop_menu_uninstall.reg"
regedit /s "%SOFTWARE_DIR%registry\desktop_menu_user_reset.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_background_menu_install_%CHOICE_STD%.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_background_menu_uninstall.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_background_menu_user_reset.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_folder_menu_install_%CHOICE_STD%.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_folder_menu_uninstall.reg"
regedit /s "%SOFTWARE_DIR%registry\win_exp_folder_menu_user_reset.reg"
cls

rem install should be complete so open our start menu and then exit
title %SOFTWARE_NAME%: Installed!
echo.
echo     Solid Edge Admin Utils has been installed!
explorer "%MENU_DIR%\%SOFTWARE_NAME%"
goto :CleanExit


rem
rem display error for existing files 
rem
:ExistsError
title %SOFTWARE_NAME%: ERROR!
echo.
echo.
echo     Error: %SOFTWARE_NAME% appears to already be installed!
echo.
echo.    Please remove existing files before attempting to install.
echo.
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
set CHOICE_MENU=
set CHOICE_STD=
exit /b