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
Required parameter to specify either a folder or single file to translate.

.PARAMETER Type
Required parameter to specify the file type to export to.
#>

# set our input params
param(
    [string]$Translate, 
    [string]$Type
)  

# set our title
cls
$host.ui.rawui.WindowTitle="Translating Solid Edge files..."

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

# check if a folder or file is passed to translate and get our files
if (Test-Path $Translate -PathType Leaf)
{
    $FileList = Get-Item $Translate
}
elseif (Test-Path $Translate -PathType Container)
{
    $FileList = Get-ChildItem $Translate -File
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

# check if a translation type is passed to translate
$Type = $Type.ToLower()
$ValidTypes = @("dwg", "dxf", "emf", "igs3d", "igs", "jt", "pdf", "pdf3d", "sat", "stp", "tif", "x_t" )
if ($ValidTypes -contains $Type)
{
    #set if 2d=0 or 3d=1
    switch ($Type)
    {
        "dwg"
        {
            $Format = 0
            break
        }
        "dxf"
        {
            $Format = 0
            break
        }
        "emf"
        {
            $Format = 0
            break
        }
        "igs3d"
        {
            $Format = 1
            $Type = "igs"
            break
        }
        "igs"
        {
            $Format = 0
            break
        }
        "jt"
        {
            $Format = 1
            break
        }
        "pdf"
        {
            $Format = 0
            break
        }
        "pdf3d"
        {
            $Format = 1
            $Type = "pdf"
            break
        }
        "sat"
        {
            $Format = 1
            break
        }         
        "stp"
        {
            $Format = 1
            break
        }         
        "tif"
        {
            $Format = 0
            break
        }       
        "x_t"
        {
            $Format = 1
            break
        }       
    }
}
else
{
    Write-Host
    Write-Host "    No valid translation type provided!"
    Write-Host
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
    Exit
}

# for each file check if a Solid Edge file and translate
$ValidFiles2D = @(".dft")
$ValidFiles= @(
                (".dft"),
                (".asm", ".par", ".psm")
              )
foreach ($File in $FileList) 
{
    if ($ValidFiles[$Format] -contains $File.Extension.ToLower())
    {       
        # build our output file name
        $Output = $File.DirectoryName
        $Output += "\" + $File.BaseName
        $Output += "." + $Type
        
        # build our command line to execute
        $CmdLine = ' -i="' + $File.FullName + '"'
        $CmdLine += ' -o="' + $Output + '"'
        $CmdLine += ' -t=' + $Type
        $CmdLine += ' -r=1200' 
        $CmdLine += ' -c=24' 
        $CmdLine += ' -v=false' 
        $CmdLine += ' -q=high' 
        $CmdLine += ' -m=true' 
        
        # and finally execute our translation
        $Text = "Translating to " + $Type.ToUpper() + ' "' + $File.FullName + '..."'
        Write-Host
        Write-Host $Text
        Write-Host
        Start-Process $Translator $CmdLine -Wait -WindowStyle Hidden
    }
 }


 
Exit
