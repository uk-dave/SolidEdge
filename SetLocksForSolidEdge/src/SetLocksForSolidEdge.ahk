; SetLocksForSolidEdge
; Copyright (C) 2015 David C. Merritt, david.c.merritt@siemens.com
;
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;
; ---------------------------------------------------------------------
;
; AutoHotkey script to enforce the toggling of the Caps and Num locks to 
; always turn on whenever Solid Edge is the active window. 
;
; ---------------------------------------------------------------------
;
; 28/10/2015  merritt  initial release
; 29/10/2015  merritt  moved icon files to img sub-folder
;                      relocated ini file to user LOCALAPPDATA
;                      added check for and copy missing ini to user
;                      created installer file 
;

; allow allow one instance, keyboard hook, and make persistent
#SingleInstance, Force
#Persistent
#InstallKeybdHook

; ini file 
EnvGet, UserIniDir, LOCALAPPDATA
UserIniDir = %UserIniDir%\DM Operations, Utilities, Scripts, Extensions\Set Locks for Solid Edge
UserIniFile = %UserIniDir%\SetLocksForSolidEdge.ini

; check if user ini folder exists
IfNotExist, %UserIniDir%
{
    FileCreateDir, %UserIniDir%
}

; check if user ini file exists
IfNotExist, %UserIniFile%
{
    FileCopy, %A_ScriptDir%\SetLocksForSolidEdge.ini, %UserIniDir%
}

; read in our ini file
IniRead, EnforceCapslock, %UserIniFile%, EnforceLock, CapsLock, 1
IniRead, EnforceNumLock, %UserIniFile%, EnforceLock, NumLock, 1
IniRead, DisplayTrayTip, %UserIniFile%, DisplayTips, TrayTip, 1
IniRead, DisplayToolTip, %UserIniFile%, DisplayTips, ToolTip, 1
IniRead, KeyPause, %UserIniFile%, KeyControl, Pause, #p
IniRead, KeyQuit, %UserIniFile%, KeyControl, Exit, #q

; set up our pause and quit hot keys
HotKey, %KeyPause%, PauseApp
HotKey, %KeyQuit%, QuitApp

; set our app name and tray icon data
AppName=SetLocksForSolidEdge
Menu, Tray, Icon, img\icon_caps_on_num_on.ico, 1, 1
Menu, Tray, Tip, %AppName%

; set our paused tracking off
Paused := False

; start a timer to enfore the locking
SetTimer, EnforceLocks, 500
Return

; enforce the locking
EnforceLocks:
    ; check the state of our locks
    SetCapsLockState := GetKeyState("CapsLock", "T")    
    SetNumlockState := GetKeyState("NumLock", "T")
    
    ; reset our icon state
    IconCalc = 3
    
    ; calculate the icon to display
    if (SetCapsLockState == 0)  
    {
        IconCalc -= 1
    }
    if (SetNumlockState == 0)  
    {
        IconCalc -= 2
    }
    SetDisplayIcon(IconCalc, AppName)
        
    ; get the process name of our current active window
    WinGet, CurrentProcess, ProcessName, A    

    ; if the active window is from Solid Edge then turn on locking
    if (CurrentProcess == "Edge.exe")
    {   
        if (EnforceNumLock)
        {
            ;SetNumlockState := GetKeyState("NumLock", "T")
            if (SetNumlockState == 0)
            {
                SetNumlockState, On          
                
                ; display our tray tip
                if (DisplayTrayTip)
                {
                    TrayTip, %AppName%, Num Lock: On, 1, 1
                }
                
                ; display our tool tip
                if (DisplayToolTip)
                {
                    Tooltip, Num Lock: On
                    SetTimer, RemoveToolTip, 750
                } 
            }
        }
        if (EnforceCapslock)
        {
            ;SetCapsLockState := GetKeyState("CapsLock", "T")
            if (SetCapsLockState == 0)
            {
                SetCapsLockState, On    
                
                ; display our tray tip
                if (DisplayTrayTip)
                {
                    TrayTip, %AppName%, Caps Lock: On, 1, 1
                }
                
                ; display our tool tip
                if (DisplayToolTip)
                {
                    Tooltip, Caps Lock: On
                    SetTimer, RemoveToolTip, 750
                }   
            }
        }
    }
Return

; set the tray icon to display
SetDisplayIcon(IconState, AppName)
{
    if (IconState == -1)
    {
        Menu, Tray, Icon, img\icon_pause.ico, 1, 1
        Menu, Tray, Tip, %AppName%`nPaused
    }
    if (IconState == 0)
    {
        Menu, Tray, Icon, img\icon_caps_off_num_off.ico, 1, 1
        Menu, Tray, Tip, %AppName%`nCaps: Off`nNum: Off
    }
    if (IconState == 1)
    {
        Menu, Tray, Icon, img\icon_caps_on_num_off.ico, 1, 1
        Menu, Tray, Tip, %AppName%`nCaps: On`nNum: Off
    }
    if (IconState == 2)
    {
        Menu, Tray, Icon, img\icon_caps_off_num_on.ico, 1, 1
        Menu, Tray, Tip, %AppName%`nCaps: Off`nNum: On
    }
    if (IconState == 3)
    {
        Menu, Tray, Icon, img\icon_caps_on_num_on.ico, 1, 1
        Menu, Tray, Tip, %AppName%`nCaps: On`nNum: On
    }         
    Return
}

; timer to ensure the tooltip is removed
RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
Return

; exit our application
QuitApp:
    ExitApp
Return

; pause our application 
PauseApp:
    if (Paused)
    {
        if (DisplayTrayTip)
        {
            TrayTip, %AppName%, Lock enforcement resumed, 1, 1
        }
        SetDisplayIcon(3, AppName)  
        Paused := False        
    }    
    else
    {
        if (DisplayTrayTip)
        {
            TrayTip, %AppName%, Lock enforcement paused, 1, 1
        }
        SetDisplayIcon(-1, AppName)       
        Paused := True     
    }
    Pause,,1
Return
