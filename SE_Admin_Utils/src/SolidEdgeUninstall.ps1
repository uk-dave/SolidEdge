# SolidEdgeUninstall
# Copyright (C) 2014-2015, David C. Merritt, david.c.merritt@siemens.com
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
# PowerShell script to silently uninstall the Solid Edge and data 
# managament clients, and optionally allow for backup and reset of both
# the Solid Edge and the current user's Solid Edge preferences.
#
# NOTE: if you encounter an error "SolidEdgeUninstall.ps1 cannot 
# be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell
# execution policy.  To change the policy, in a PowerShell command
# prompt run the following command:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 12/06/2014  merritt  initial release
# 11/07/2014  merritt  changed method to detect SE software installed
# 13/07/2014  merritt  added dialog box exit
#                      added open win explorer window in debug mode
# 14/07/2014  merritt  added optional command line parameter passthru
#                      added sanity check before uninstalling
# 29/10/2014  merritt  corrected typos in text
# 30/12/2014  merritt  corrected typos in GNU license agreement
#                      corrected typos in user prompts
# 01/01/2015  merritt  added pause before deleting program folder
# 21/08/2015  merritt  added check if all parameters passed and if so 
#                      use a gui yes/no 
#

<#
.SYNOPSIS
Uninstalls Solid Edge and any Solid Edge data management clients.

.DESCRIPTION
The script uninstalls Solid Edge and any Solid Edge data management clients, and optionally allows for backup and reset of the existing preferences.

.NOTES  
File Name : SolidEdgeUninstall.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/

.PARAMETER Backup
Optional parameter to backup the existing Solid Edge site preferences before resetting. Valid input is y or n. If not provided in the command line user will be prompted for this inline.

.PARAMETER ResetUser
Optional parameter to backup and reset the existing user's Solid Edge preferences before resetting. Valid input is y or n. If not provided in the command line user will be prompted for this inline.
#>

# set our input params
param([string]$Backup, [string]$ResetUser)

# set our title
cls
$host.ui.rawui.WindowTitle="Uninstall Solid Edge"

# set debug switch for testing code, set to 1 to do uninstall set to 0 to test
$DebugOff = 1

# set our command line parameter switch
$AllParametersPassed = 1

# set up our uninstall location for our log and backup files
$Timestamp = Get-Date -f yyyy-MM-dd_HH_mm_ss
$LogRoot = "SolidEdge_Uninstall"
$PathLog = $env:temp + "\" + $LogRoot + "\" + $Timestamp
New-Item $PathLog -ItemType directory -force >$null
$PathSite = $PathLog + "\" + "Preferences"
$PathUser = $PathLog + "\" + "User"

# find all Solid Edge software installed
$Software = @()

# check for 64-bit software first
$Software += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Solid Edge*" -and $_.Publisher -eq "Siemens" } 

# if no 64-bit then check for 32-bit
if ( $Software.count -eq 0)
{
    $Software += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -like "*Solid Edge*" -and $_.Publisher -eq "Siemens" } 
}

# if no Solid Edge found exit
if ($Software.count -eq 0 -or $Software[0].DisplayName -eq $null)
{
    $LogFile = $PathLog + "\SolidEdge_uninstall.log"
    New-Item $LogFile -type file -force -value "Solid Edge not found!" >$null
    Write-Host
    Write-Host "    Solid Edge does not appear to be installed!"
    Write-Host
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
    Exit
}

# parse for the base Solid Edge software
foreach ($item in $Software) 
{ 
    # get major versions and remove characters 107 -> 7, 117 -> 17
    $Version = [string]$item.VersionMajor
    $Version = $Version.SubString(1)
    $Version = [int]$Version    
    
    # determine base Solid Edge install
    $VersionName = "Solid Edge ST" + $Version    
    if ($item.DisplayName -eq  $VersionName)
    {
        $PathInstall = $item.InstallLocation
        $ProductCodeSe = $item.PSChildName
        Write-Host
        Write-Host "    $VersionName appears to be installed!"
    }    
}

# if install path is empty check another registry
if (!$PathInstall)
{
    $RegKey = "HKLM:\Software\Unigraphics Solutions\Solid Edge\Version " + $item.VersionMajor + "\CurrentVersion"
    if (Test-Path $RegKey) 
    {
        $PathInstall = Get-ItemProperty -Path "$RegKey" -Name "InstallDir"
        $PathInstall = $PathInstall.InstallDir 
    }  
}

# prompt for selection to backup existing Solid Edge preferences 
$host.ui.rawui.WindowTitle="Backing up preferences..."
$Selection = 0
while ($Selection -eq 0)
{
    if ($Backup -eq "")
    {
        $AllParametersPassed = 0
        Write-Host
        $Selected = Read-Host -Prompt "    Backup Solid Edge preferences? (Y/N)"
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
$Backup = $Selected

# prompt for selection to reset existing user preferences 
$host.ui.rawui.WindowTitle="Reset user preferences..."
$Selection = 0
while ($Selection -eq 0)
{
    if ($ResetUser -eq "")
    {
        $AllParametersPassed = 0
        Write-Host
        $Selected = Read-Host -Prompt "    Reset and backup current user's Solid Edge preferences? (Y/N)"
    }
    else
    {
        $Selected = $ResetUser
        $ResetUser = ""
    }
    
    # check a valid selection input
    if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
    {
        $Selection = 1
    }
}
$ResetUser = $Selected

# prompt for sanity check before uninstall
$host.ui.rawui.WindowTitle="Starting Solid Edge uninstall..."
$Selection = 0
while ($Selection -eq 0)
{
    if ($AllParametersPassed -eq 1)
    {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        
        $SelectStr = "    Are you sure you want to uninstall " + $VersionName + "?"
        $Selected = [System.Windows.Forms.MessageBox]::Show($SelectStr , "Solid Edge Uninstall",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)

        if ($Selected -eq "YES")
        {
            $Selected = "y"
        }  
        else
        {
            $Selected = "n"        
        }
        $Selection = 1        
    }
    else
    {
        Write-Host
        $SelectStr = "    Are you sure you want to uninstall " + $VersionName + "? (Y/N)"
        $Selected = Read-Host -Prompt $SelectStr

        # check a valid selection input
        if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
        {
            $Selection = 1
        }
    }
}

if ($Selected -eq "n")
{ 
    if ($AllParametersPassed -eq 1)
    {     
        exit
    }
    else
    {
        $host.ui.rawui.WindowTitle="Solid Edge uninstall cancelled!"
        Write-Host
        Write-Host "    Solid Edge uninstall cancelled."
        Write-Host
        Write-Host "    Press any key to exit..."
        $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        Write-Host
        exit
    }
}

# backup the site preferences
if ($Backup -eq "y")
{ 
    $PathPrefs = $PathInstall + "Preferences"
    
    if (Test-Path $PathPrefs)
    {
        Copy-Item $PathPrefs $PathSite -recurse
    }
}
else
{
    $LogFile = $PathSite + "\Preferences_backup.log"
    New-Item $LogFile -type file -force -value "Solid Edge preferences not selected for backup!" >$null
}

# backup and reset the user preferences 
if ($ResetUser -eq "y")
{ 
    # copy the user appdata folder
    $PathAppdata = $env:appdata + "\Unigraphics Solutions"
    $PathUserAppdata = $PathUser + "\Unigraphics Solutions"    
    if (Test-Path "$PathAppdata")
    {
        Copy-Item "$PathAppdata" "$PathUserAppdata" -recurse
    }
    else
    {
        New-Item $PathUser -ItemType directory -force >$null
    }

    # copy the user registry keys
    $RegFile = $PathUser + "\user_se_registry.reg"    
    if (Test-Path "HKCU:\Software\Unigraphics Solutions")
    {
        reg export "HKCU\Software\Unigraphics Solutions" "$RegFile" /y >$null
    }

    # reset the user preferences
    if ($DebugOff)
    {
        if (Test-Path "$PathAppdata")
        {
            Remove-Item "$PathAppdata" -force -recurse
        }        
        if (Test-Path "HKCU:\Software\Unigraphics Solutions")
        {
            Remove-Item "HKCU:\Software\Unigraphics Solutions" -force -recurse
        }
    }
    else
    {
        Write-Host
        Write-Host "Remove-Item `"$PathAppdata`" -force -recurse"
        Write-Host
        Write-Host "Remove-Item `"HKCU:\Software\Unigraphics Solutions`" -force -recurse"
        Write-Host
    }   
}
else
{
    $LogFile = $PathUser + "\User_reset.log"
    New-Item $LogFile -type file -force -value "Solid Edge user preferences not selected for reset!" >$null
}

# uninstall everything found but base Solid Edge 
Write-Host
foreach ($item in $Software) 
{ 
    if ($ProductCodeSe -ne $item.PSChildName)
    {
        $DisplayName = $item.DisplayName
        $ProductCode = $item.PSChildName
        $host.ui.rawui.WindowTitle="Uninstalling $DisplayName..."
        
        # set our log file name
        $LogFile = $DisplayName.Replace("Solid Edge ", "")
        $LogFile = $LogFile.Replace(" ", "_")
        $LogFile = $PathLog + "\" + $LogFile + "_uninstall.log"

        Write-Host "    Uninstalling $DisplayName..."
        Write-Host
        $UninstallArgs = "/x " + $ProductCode + " /quiet /l*v `"" + $LogFile + "`""    
        if ($DebugOff)
        {
            # uninstall software
            Start-Process msiexec.exe $UninstallArgs -Wait
        }
        else
        {
            Write-Host
            Write-Host "Start-Process msiexec.exe $UninstallArgs -Wait"
            Write-Host
        }
    }

}

# finally uninstall base Solid Edge
$host.ui.rawui.WindowTitle="Uninstalling $VersionName..."
$LogFile = $PathLog + "\Solid_Edge_uninstall.log"

Write-Host "    Uninstalling $VersionName..."
$UninstallArgs = "/x " + $ProductCodeSe + " /quiet /l*v `"" + $LogFile + "`""    
if ($DebugOff)
{
    # uninstall software
    Start-Process msiexec.exe $UninstallArgs -Wait
              
    # remove registry keys 
    if (Test-Path "HKLM:\Software\Unigraphics Solutions")
    {
        Remove-Item "HKLM:\Software\Unigraphics Solutions" -force -recurse
    }
    if (Test-Path "HKLM:\Software\Wow6432Node\Unigraphics Solutions\Solid Edge") 
    {
        Remove-Item "HKLM:\Software\Wow6432Node\Unigraphics Solutions\Solid Edge" -force -recurse
    }
    if (Test-Path "HKLM:\Software\Wow6432Node\Unigraphics Solutions\Standard Parts") 
    {
        Remove-Item "HKLM:\Software\Wow6432Node\Unigraphics Solutions\Standard Parts" -force -recurse
    }  

    # remove program folder
    if (Test-Path "$PathInstall")
    {
        Start-Sleep -s 3
        Remove-Item "$PathInstall" -force -recurse
    }    
}
else
{
    Write-Host
    Write-Host "Start-Process msiexec.exe $UninstallArgs -Wait"
    Write-Host
    Write-Host "Remove-Item `"HKLM:\Software\Unigraphics Solutions`" -force -recurse"
    Write-Host
    Write-Host "Remove-Item `"HKLM:\Software\Wow6432Node\Unigraphics Solutions\Solid Edge`" -force -recurse"
    Write-Host
    Write-Host "Remove-Item `"HKLM:\Software\Wow6432Node\Unigraphics Solutions\Standard Parts`" -force -recurse"
    Write-Host
    Write-Host "Remove-Item `"$PathInstall`" -force -recurse"
    Write-Host
}

# display our backup files
$host.ui.rawui.WindowTitle="Uninstall of $VersionName finished!"
Write-Host
Write-Host "    Uninstall logs and backed up preference files can be found in:"
Write-Host
Write-Host "    $PathLog"

# finally close out of the uninstall
Write-Host
Write-Host "    Solid Edge uninstall complete!"
Write-Host
if ($DebugOff -eq 0)
{
    Invoke-Expression "explorer '/root,$PathLog'"
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
}
else
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $Return = [System.Windows.Forms.MessageBox]::Show("$VersionName uninstall complete." , "Solid Edge Uninstall",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Asterisk)
}

Exit