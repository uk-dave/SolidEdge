@echo off

rem SolidEdgeSetLanguage_SE2024.cmd
rem Copyright (C) 2023, David C. Merritt, david.c.merritt@siemens.com
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
rem DOS script to change the default Solid Edge UI language based on the 
rem user selected choice and then launch Solid Edge.
rem
rem ---------------------------------------------------------------------
rem
rem 22/02/2023  merritt  initial release
rem

set SE_HOME=C:\Program Files\Siemens\Solid Edge 2024

title Solid Edge Language Selector


rem
rem Display our template menu
rem
:MenuTemplate
cls
echo        ����������������������������
echo        �   Solid Edge Language    �
echo        ����������������������������
echo        �                          �
echo        � (A) Chinese, Simplified  �
echo        � (B) Chinese, Traditional �
echo        � (C) Czech                �
echo        � (D) English              �
echo        � (E) French               �
echo        � (F) German               �
echo        � (G) Hungarian            �
echo        � (H) Italian              �
echo        � (I) Japanese             �
echo        � (J) Korean               �
echo        � (K) Polish               �
echo        � (L) Portuguese           �
echo        � (M) Russian              �
echo        � (N) Spanish              �
echo        �                          �
echo        � (X) Exit                 �
echo        �                          �
echo        ����������������������������  
echo.
echo.

set CHOICE_MENU=
set /p CHOICE_MENU=Enter option #: 
echo.

if not '%CHOICE_MENU%'=='' set CHOICE_MENU=%CHOICE_MENU:~0,1%

if '%CHOICE_MENU%'=='A' goto :StdA
if '%CHOICE_MENU%'=='B' goto :StdB
if '%CHOICE_MENU%'=='C' goto :StdC
if '%CHOICE_MENU%'=='D' goto :StdD
if '%CHOICE_MENU%'=='E' goto :StdE
if '%CHOICE_MENU%'=='F' goto :StdF
if '%CHOICE_MENU%'=='G' goto :StdG
if '%CHOICE_MENU%'=='H' goto :StdH
if '%CHOICE_MENU%'=='I' goto :StdI
if '%CHOICE_MENU%'=='J' goto :StdJ
if '%CHOICE_MENU%'=='K' goto :StdK
if '%CHOICE_MENU%'=='L' goto :StdL
if '%CHOICE_MENU%'=='M' goto :StdM
if '%CHOICE_MENU%'=='N' goto :StdN
if '%CHOICE_MENU%'=='X' goto :CleanExit

if '%CHOICE_MENU%'=='a' goto :StdA
if '%CHOICE_MENU%'=='b' goto :StdB
if '%CHOICE_MENU%'=='c' goto :StdC
if '%CHOICE_MENU%'=='d' goto :StdD
if '%CHOICE_MENU%'=='e' goto :StdE
if '%CHOICE_MENU%'=='f' goto :StdF
if '%CHOICE_MENU%'=='g' goto :StdG
if '%CHOICE_MENU%'=='h' goto :StdH
if '%CHOICE_MENU%'=='i' goto :StdI
if '%CHOICE_MENU%'=='j' goto :StdJ
if '%CHOICE_MENU%'=='k' goto :StdK
if '%CHOICE_MENU%'=='l' goto :StdL
if '%CHOICE_MENU%'=='m' goto :StdM
if '%CHOICE_MENU%'=='n' goto :StdN
if '%CHOICE_MENU%'=='x' goto :CleanExit

echo        "%CHOICE_MENU%" is not a valid option - try again!
echo.

echo        Press any key to continue . . .
pause > nul
goto :MenuTemplate

rem
rem Set our Solid Edge language 
rem
:StdA
set CHOICE_LANG=2052
goto :ChangeLang

:StdB
set CHOICE_LANG=1028
goto :ChangeLang

:StdC
set CHOICE_LANG=1029
goto :ChangeLang

:StdD
set CHOICE_LANG=1033
goto :ChangeLang

:StdE
set CHOICE_LANG=1036
goto :ChangeLang

:StdF
set CHOICE_LANG=1031
goto :ChangeLang

:StdG
set CHOICE_LANG=1038
goto :ChangeLang

:StdH
set CHOICE_LANG=1040
goto :ChangeLang

:StdI
set CHOICE_LANG=1041
goto :ChangeLang

:StdJ
set CHOICE_LANG=1042
goto :ChangeLang

:StdK
set CHOICE_LANG=1045
goto :ChangeLang

:StdL
set CHOICE_LANG=1046
goto :ChangeLang

:StdM
set CHOICE_LANG=1049
goto :ChangeLang

:StdN
set CHOICE_LANG=1034
goto :ChangeLang

rem
rem finally set our Solid Edge language  
rem
:ChangeLang
reg delete "HKCU\Software\Siemens\Solid Edge\Version 224" /v DefaultToSystemLocale /f >nul 2>&1

reg delete "HKCU\Software\Siemens\Solid Edge\Version 224" /v RuntimeLanguage /f >nul 2>&1

reg add "HKLM\Software\Siemens\Solid Edge\Version 224\CurrentVersion" /v InstalledLanguage /t REG_DWORD /d %CHOICE_LANG% /f >nul 2>&1

rem
rem now launch Solid Edge 
rem
pause
start "" "%SE_HOME%\Program\Edge.exe"
goto :CleanExit

rem
rem cleanly exit
rem
:CleanExit
set SE_HOME=
set CHOICE_MENU=
set CHOICE_LANG=
exit /b