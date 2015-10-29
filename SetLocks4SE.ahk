; SetLocks4SE
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
; 27/10/2015  merritt  initial release
;

#SingleInstance, Force
#InstallKeybdHook
#Persistent

AppName=SetLocks4SE
Menu, Tray, Icon, %A_WinDir%\System32\shell32.dll, 105
Menu, Tray, Tip, Set Caps and Num locks for Solid Edge

; set to false to not enforce locks
EnforceCapslock := true
EnforceNumLock  := true

SetTimer, EnforceLocks, 500
Return

EnforceLocks:
    WinGet, CurrentProcess, ProcessName, A       
    if (CurrentProcess == "Edge.exe")
    {   
        if (EnforceCapslock)
        {
            SetCapsLockState := GetKeyState("CapsLock", "T")
            IfEqual, SetCapsLockState, 0
            {
                SetCapsLockState, On       
                Tooltip, Caps Lock: On
                SetTimer, RemoveToolTip, 750
            }
        }
        
        if (EnforceNumLock)
        {
            SetNumlockState := GetKeyState("NumLock", "T")
            IfEqual, SetNumlockState, 0
            {
                SetNumlockState, On          
                Tooltip, Num Lock: On
                SetTimer, RemoveToolTip, 750
            }
        }
    }
Return

RemoveToolTip:
    SetTimer, RemoveToolTip, Off
    ToolTip
return

; Win + p pauses the script in case you need the locks
#p::
    TrayTip, %AppName%, Lock Enforcer paused, 30, 1
    Pause,,1
return

; Win + q exits
#q::ExitApp
