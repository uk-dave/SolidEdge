# ResetUserPreferences
# Copyright (C) 2014, David C. Merritt, david.c.merritt@siemens.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------
#
# PowerShell script to reset the current user's Solid Edge preferences, 
# and optionally allows for backing up of the existing preferences
# before resetting.
#
# NOTE: if you encounter an error "ResetUserPreferences.ps1 cannot 
# be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell
# execution policy.  To change the policy, in a PowerShell command
# prompt run the following command:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 05/06/2014  merritt  initial release
# 13/07/2014  merritt  added dialog box exit
#                      added open win explorer window in debug mode
#                      added optional command line parameter passthru
# 29/10/2014  merritt  corrected typos in text
# 30/12/2014  merritt  corrected typos in GNU license agreement
#

<#
.SYNOPSIS
Resets the current user's Solid Edge preferences.

.DESCRIPTION
The script resets the current user's Solid Edge preferences, and optionally allows for backing up the existing preferences before resetting.

.NOTES  
File Name : ResetUserPreferences.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/

.PARAMETER Backup
Optional parameter to backup the current user's existing Solid Edge preferences before resetting. Valid input is y or n. If not provided in the command line user will be prompted for this inline.
#>

# set our input params
param([string]$Backup)

# set our title
cls
$host.ui.rawui.WindowTitle="Reset current user's Solid Edge preferences"

# set debug switch for testing code, set to 1 to do uninstall set to 0 to test
$DebugOff = 1

# prompt for selection to backup existing prefs
$Selection = 0
while ($Selection -eq 0)
{
    Write-Host
    if ($Backup -eq "")
    {
        $Selected = Read-Host -Prompt "    Backup current user's existing Solid Edge preferences? (Y/N)"
    }
    else
    {
        $Selected = $Backup
        $Backup = ""
    }
    # check a valid selection input
    if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
    {
        $Selection = 1
    }
}
Write-Host

# set common vars
$PathAppdata = $env:appdata + "\Unigraphics Solutions"


# if selected backup prefs
if ($Selected -eq "y")
{   
    # copy the user's %appdata% folder
    $Timestamp = Get-Date -f yyyy-MM-dd_HH_mm_ss
    $BackupRoot = "SolidEdge_user_pref_backup"
    $PathBackup = $env:temp + "\" + $BackupRoot + "\" + $Timestamp + "\Unigraphics Solutions"       
    if (Test-Path $PathAppdata -pathType container)
    {
        Copy-Item $PathAppdata $PathBackup -recurse
    }
    
    # copy the user's registry keys
    $RegFile = $env:temp + "\" + $BackupRoot + "\" + $Timestamp + "\user_se_registry.reg"    
    if (Test-Path "HKCU:\Software\Unigraphics Solutions")
    {
        reg export "HKCU\Software\Unigraphics Solutions" "$RegFile" /y >$null
    }
    
    # display where we backed up to
    Write-Host "    User preferences backed up to:"  
    Write-Host
    Write-Host "        %TEMP%\$BackupRoot\$Timestamp"
    Write-Host

}

# remove the user prefs
if (Test-Path $PathAppdata -pathType container)
{
    Remove-Item $PathAppdata -Force -Recurse
}

if (Test-Path "HKCU:\Software\Unigraphics Solutions")
{
    Remove-Item "HKCU:\Software\Unigraphics Solutions" -Force -Recurse
}

$host.ui.rawui.WindowTitle="Reset current user's Solid Edge preferences finished!"
Write-Host "    Current user's Solid Edge preferences reset!"
Write-Host


if ($DebugOff -eq 0)
{
    Invoke-Expression "explorer '/root,%TEMP%\$BackupRoot\$Timestamp'"
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $Return = [System.Windows.Forms.MessageBox]::Show("User preferences reset." , "Solid Edge Preferences Reset",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Asterisk)
}


Exit