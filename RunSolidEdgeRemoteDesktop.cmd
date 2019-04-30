@echo off 

rem RunSolidEdgeRemoteDesktop.cmd
rem Copyright (C) 2019, David C. Merritt, david.c.merritt@siemens.com
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
rem Batch script to run Solid Edge  in a remote dekstop session.
rem
rem ------------------
rem *** TO INSTALL ***
rem ------------------
rem 
rem 1. Copy this script on to the remote workstation which has Solid Edge  
rem    installed to it.
rem 
rem 2. Edit this script where indicated to define the full path to the 
rem    Solid Edge exe file
rem 
rem --------------
rem *** TO USE ***
rem --------------
rem 
rem 1. Remote desktop in to the workstation with Solid Edge installed to it
rem 
rem 2. Run this script that we have previously coped ot the remote 
rem    workstation
rem 
rem 3. The script will disconnect the active remote desktop session but 
rem    leave the user logged in on the remote workstation
rem 
rem 4. The script will then launch the Solid Edge exe on the remote but now
rem    disconnected session 
rem 
rem 5. After a few seconds of being disconnected, allowing some time for 
rem    Solid Edge to fully launch, then remote desktop back into the 
rem    workstation 
rem 
rem Voilà!  Solid Edge is now running remotely.
rem 
rem
rem ---------------------------------------------------------------------
rem
rem 30/04/2019  merritt  initial release
rem


rem *******************************************************************
rem Define the full command line to run the Solid Edge exe file below here
rem *******************************************************************

set ProgramCmdLine="C:\Program Files\Solid Edge ST10\Program\Edge.exe"

rem *******************************************************************
rem Define the full command line to run the Solid Edge exe file above here
rem *******************************************************************


rem set command line for tasklist.exe used to help identify our current desktop session id
set IdentifySessionIdCmd=tasklist /FI "IMAGENAME eq tasklist.exe" /FO "TABLE" /NH

rem run tasklist.exe and capture the remote session id from the output
for /f "tokens=4 delims= " %%i in ('%IdentifySessionIdCmd%') do set SessionId=%%i

rem forewarn the user of disconnect and pause so user can aknowledge this
echo.
echo We are about to connect back to the remote system display.
echo This will automatically disconnect your Remote Desktop session.
echo This is expected and is no cause for alarm.
echo Please allow time for Solid Edge to fully launch on the remote system.
echo Then reconnect your Remote Desktop session and use Solid Edge.
echo.
pause


rem connect our remote session back to the running desktop console
tscon %SessionId% /dest:console

rem now we are disconnected launch Solid Edge 
start "" %ProgramCmdLine%

rem be a good citizen and clean up after ourselves and exit quietly
set ProgramCmdLine=
set IdentifySessionIdCmd=
set SessionId=
exit /b
