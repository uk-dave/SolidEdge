# SolidEdgeTranslateFromExplorer
# Copyright (C) 2015, David C. Merritt, david.c.merritt@siemens.com
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
# PowerShell script to calls the Solid Edge command line translator to 
# convert Solid Edge file types from within WIndows Explorer.
#
# NOTE: if you encounter an error "SolidEdgeTranslateFromExplorer.ps1 
# cannot be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell 
# execution policy.  To change the policy, in a PowerShell command 
# prompt run the following:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 04/08/2015  merritt  initial release
#

<#
.SYNOPSIS
Translates Solid Edge files from Windows Explorer.

.DESCRIPTION
This script calls the Solid Edge command line translator to convert Solid Edge file types from within Windows Explorer.

.NOTES  
File Name : SolidEdgeTranslateFromExplorer.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/SolidEdgeTranslateFromExplorer

.PARAMETER Translate
Required parameter to specify either a folder or single file to translate. Valid input is y or n. If not provided in the command line user will be prompted for this inline.

.PARAMETER Type
Required parameter to specify the file type to export to. If not provided in the command line user will be prompted for this inline.
#>

# set our input params
param(
    [string]$Translate, 
    [string]$Type
)  

# set our title
cls
$host.ui.rawui.WindowTitle="Translate Solid Edge files"

# set some variables
$LogRoot = "Solid_Edge_Win_Exp_Translate"
$PathLog = $env:temp + "\" + $LogRoot + "\" + $Timestamp
$LogFile = $PathLog + "\SolidEdge_uninstall.log"

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

# check if the command line translator exists
$Translator = $PathInstall + "\Program\SolidEdgeTranslationServices.exe"
if (! (Test-Path "$Translator"))
{
    $LogFile = $PathLog + "\SolidEdge_uninstall.log"
    New-Item $LogFile -type file -force -value "Solid Edge command line translator not found!" >$null
    Write-Host
    Write-Host "    Solid Edge command line translator does not appear to be installed!"
    Write-Host
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
    Exit
}

# check if a folder or file is passed to translate
$Selection = 0
while ($Selection -eq 0)
{

if (Test-Path $Translate -PathType Leaf)
{
    Write-Host "    Appears to be a file!"

}
elseif (Test-Path $Translate -PathType Container)
{
    Write-Host "    Appears to be a folder!"

}
else
{
    Write-Host
    Write-Host "    No valid files to translate provided!"
    Write-Host
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
    Exit
}

}

Exit
