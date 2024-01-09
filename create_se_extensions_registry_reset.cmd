@echo off

rem create_se_extensions_registry_reset.cmd
rem Copyright (C) 2024, David C. Merritt, david.c.merritt@siemens.com
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
rem Script to dump Solid Edge file extensions from a clean Solid Edge 
rem software install and capture those clean registry settings into a 
rem registry reset scritp for later use if the Solid Edge file extensions
rem ever become corrupted.
rem
rem ---------------------------------------------------------------------
rem
rem 2024/01/09 dcm initial release


set TEMP_WORKING_FILE="%temp%\SE_registry_dump.reg"
set COMPILED_FILE=reset_solid_edge_extensions_SExxxx.reg
set DAY=%date:~0,2%
set MONTH=%date:~3,2%
set YEAR=%date:~6,4%
set C_DATE=%year%-%month%-%day%
set USER_INIT=dcm

echo Windows Registry Editor Version 5.00 > %COMPILED_FILE%
echo. >> %COMPILED_FILE%
echo ; reset_solid_edge_extensions_SExxxx >> %COMPILED_FILE%
echo ; Copyright (C) %YEAR%, David C. Merritt, david.c.merritt@siemens.com >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; This program is free software: you can redistribute it and/or modify >> %COMPILED_FILE%
echo ; it under the terms of the GNU General Public License as published by >> %COMPILED_FILE%
echo ; the Free Software Foundation, either version 3 of the License, or >> %COMPILED_FILE%
echo ; (at your option) any later version. >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; This program is distributed in the hope that it will be useful, >> %COMPILED_FILE%
echo ; but WITHOUT ANY WARRANTY; without even the implied warranty of >> %COMPILED_FILE%
echo ; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the >> %COMPILED_FILE%
echo ; GNU General Public License for more details. >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; You should have received a copy of the GNU General Public License >> %COMPILED_FILE%
echo ; along with this program.  If not, see http://www.gnu.org/licenses/. >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; --------------------------------------------------------------------- >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; Registry script to reset the default Solid Edge file extensions. >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; This script assumes the default Solid Edge install location e.g. >> %COMPILED_FILE%
echo ; C:\Program Files\Siemens\Solid Edge xxxx\Program\ >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; If you have installed to a different location perform a find and  >> %COMPILED_FILE%
echo ; replace on the following string (note the double back slashes) e.g. >> %COMPILED_FILE%
echo ; C:\\Program Files\\Siemens\\Solid Edge xxxx\\Program\\ >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; You should reboot your system after running this registry script. >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; NOTE: This registry change will first remove any existing user >> %COMPILED_FILE%
echo ; entries for the Solid Edge file type associations.>> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; --------------------------------------------------------------------- >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; %C_DATE% %USER_INIT% initial release >> %COMPILED_FILE%

echo. >> %COMPILED_FILE%
echo ; -------------------------------- >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; clear existing user associations >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; -------------------------------- >> %COMPILED_FILE%
echo. >> %COMPILED_FILE%

call :delete_user .asm
call :delete_user .cfg
call :delete_user .dft
call :delete_user .par
call :delete_user .psm
call :delete_user .pwd

echo ; -------------------------- >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; set root extension classes >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; -------------------------- >> %COMPILED_FILE%
echo. >> %COMPILED_FILE%

call :export_ext .asm
call :export_ext .cfg
call :export_ext .dft
call :export_ext .par
call :export_ext .psm
call :export_ext .pwd

echo ; ------------------------- >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; set root document classes >> %COMPILED_FILE%
echo ; >> %COMPILED_FILE%
echo ; ------------------------- >> %COMPILED_FILE%
echo. >> %COMPILED_FILE%

call :export_doc .asm , SolidEdge.AssemblyDocument
call :export_doc .cfg , SolidEdge.ConfigFileExtension
call :export_doc .dft , SolidEdge.DraftDocument
call :export_doc .par , SolidEdge.PartDocument
call :export_doc .psm , SolidEdge.SheetMetalDocument
call :export_doc .pwd , SolidEdge.WeldmentDocument

del %TEMP_WORKING_FILE% /q
set TEMP_WORKING_FILE=
set COMPILED_FILE=
set DAY=
set MONTH=
set YEAR=
set C_DATE=
set USER_INIT=

goto :EOF


:delete_user
echo ; ---- >> %COMPILED_FILE%
echo ; %~1 >> %COMPILED_FILE%
echo ; ---- >> %COMPILED_FILE%
echo [-HKEY_CURRENT_USER\Software\Classes\%~1] >> %COMPILED_FILE%
echo [-HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\%~1] >> %COMPILED_FILE%
echo. >> %COMPILED_FILE%
exit /b 0

:export_ext
reg export HKCR\%~1 %TEMP_WORKING_FILE% /y > nul
echo ; ---- >> %COMPILED_FILE%
echo ; %~1 >> %COMPILED_FILE%
echo ; ---- >> %COMPILED_FILE%
(for %%F in (%TEMP_WORKING_FILE%) do @more +1 "%%F") >> %COMPILED_FILE%
exit /b 0

:export_doc
reg export HKCR\%~2 %TEMP_WORKING_FILE% /y > nul
echo ; ---- >> %COMPILED_FILE%
echo ; %~1 >> %COMPILED_FILE%
echo ; ---- >> %COMPILED_FILE%
(for %%F in (%TEMP_WORKING_FILE%) do @more +1 "%%F") >> %COMPILED_FILE%
exit /b 0

:EOF