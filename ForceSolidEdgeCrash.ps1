# ForceSolidEdgeCrash
# Copyright (C) 2017, David C. Merritt, david.c.merritt@siemens.com
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
# PowerShell script to force a Solid Edge crash with assocaited 
# crashlogs.
#
# NOTE: if you encounter an error "ForceSolidEdgeCrash.ps1 cannot 
# be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell
# execution policy.  To change the policy, in a PowerShell command
# prompt run the following command:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 07/08/2017 merritt initial release
# 08/08/2017 merritt added manual exit
# 08/08/2017 merritt added code to always keep script window on top
# 31/07/2018 merritt updated to accommodate changes with SE2019 
# 03/08/2018 merritt added checks to exclude auxiliary software when
#                    checking for installed software 
# 03/04/2023 merritt added additional portfolio prodcuts to skip 
#

<#
.SYNOPSIS
Configures and launches Solid Edge to then force a crash condition.

.DESCRIPTION
The script will configure the Solid Edge DEBUG regsitry, launch Solid Edge, then fires a specific Solid Edge command to force a Solid Edge crash, resets the Debug switch, and then automatically opens Windows Explorer to the crash log file location.

.NOTES  
File Name : ForceSolidEdgeCrash.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/

#>

# set up any starting parameters
$host.ui.rawui.WindowTitle="Force a crash of Solid Edge"

# force the script to always be on top
$signature = @'
[DllImport("user32.dll")] 
public static extern bool SetWindowPos( 
    IntPtr hWnd, 
    IntPtr hWndInsertAfter, 
    int X, 
    int Y, 
    int cx, 
    int cy, 
    uint uFlags); 
'@
 
$type = Add-Type -MemberDefinition $signature -Name SetWindowPosition -Namespace SetWindowPos -Using System.Text -PassThru

$handle = (Get-Process -id $Global:PID).MainWindowHandle 
$alwaysOnTop = New-Object -TypeName System.IntPtr -ArgumentList (-1) 

$dummy = $type::SetWindowPos($handle, $alwaysOnTop, 0, 0, 0, 0, 0x0003)

# set our crash logs location bases on the %TEMP% location
$PathLog = $env:temp

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
    # skip License Manager 
    if ($item.Comments -like '*License*')
    {
        continue
    }
    
    # skip Standard Parts 
    if ($item.Comments -like '*Standard*')
    {
        continue
    }

    # skip Tech Pubs
    if ($item.Comments -like '*Technical*')
    {
        continue
    }
	
	# skip CAM Pro
    if ($item.Comments -like '*NX*')
    {
        continue
    }

	# skip Visual Studio Addin
    if ($item.Comments -like '')
    {
        continue
    }
		
    # get major versions and remove characters 107 -> 7, 117 -> 17
    $VersionMajor = [string]$item.VersionMajor

    if ([int]$VersionMajor -gt 200)
    {
        $Version = $VersionMajor.SubString(1)
        $Version = [int]$Version    
        
        $VersionName = "Siemens Solid Edge 20" + $Version 
        $RegPath = "HKCU:\Software\Siemens\Solid Edge\Version " + $VersionMajor 
    }
    else
    {
        $Version = $VersionMajor.SubString(1)
        $Version = [int]$Version    
        
        $VersionName = "Solid Edge ST" + $Version          
        $RegPath = "HKCU:\Software\Unigraphics Solutions\Solid Edge\Version " + $VersionMajor 
    }
    
    # determine base Solid Edge install folder
    if ($item.DisplayName -eq  $VersionName)
    {
        $PathInstall = $item.InstallLocation
        $ProductCodeSe = $item.PSChildName
        Write-Host
        Write-Host "    $VersionName appears to be installed!"
    }    
}

# set our debug registry switch
Write-Host
Write-Host "    Setting crash debug switch in registry..."
$DebugPath = $RegPath + "\DEBUG"

# check if our debug hive exists and if not create it
if (-Not (Test-Path $DebugPath))
{
    New-Item -Path $RegPath -Name DEBUG -Force | Out-Null
}

# create and set the value for the crash key
New-ItemProperty -Path $DebugPath -Name TEST_ABORT_SE -Value 1 -PropertyType DWORD -Force | Out-Null
Start-Sleep 2

# check if Solid Edge is already running and if not start it
$host.ui.rawui.WindowTitle="Starting $VersionName"
$application = $null
try
{
    $application = [System.Runtime.InteropServices.Marshal]::GetActiveObject('SolidEdge.Application')
    Write-Host 
    Write-Host "    $VersionName is already running..."
}
catch [System.Exception]
{
    if ($_.Exception.ErrorCode -eq -2147221021) #MK_E_UNAVAILABLE
    {
        Write-Host
        Write-Host "    Starting $VersionName..."

        $application = New-Object -Com SolidEdge.Application
        $application.Visible = $true
    }
    else
    {
        Write-Host
        Write-Host $_.Exception.Message
    }
}

# force the crash
if ($application -ne $null)
{
    $host.ui.rawui.WindowTitle="Forcing $VersionName crash"
    Write-Host
    Write-Host "    Attempting to force $VersionName to crash..."
    $crash = $application.StartCommand(40232)
}

# pause for crash to display
Start-Sleep 3

# display our log files
$host.ui.rawui.WindowTitle="Forced crash of $VersionName completed!"
Write-Host
Write-Host "    Crash logs can be found in the user's following %TEMP% folder:"
Write-Host
Write-Host "        $PathLog"

# open Windows Explorer to the user's tmep location
Write-Host
Write-Host "    Opening user's %TEMP% folder..."
Invoke-Expression "explorer '/root,$PathLog'"

#set our debug key back
Write-Host
Write-Host "    Resetting crash debug switch in registry..."
New-ItemProperty -Path $DebugPath -Name TEST_ABORT_SE -Value 0 -PropertyType DWORD -Force | Out-Null

# finally close out of the app
Write-Host
Write-Host "    Force $VersionName crash complete!"
Write-Host
Write-Host "    Press any key to exit..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host

Exit