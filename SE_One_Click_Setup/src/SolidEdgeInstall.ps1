# SolidEdgeInstall
# Copyright (C) 2014, David C. Merritt, david.c.merritt@siemens.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY# without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# ---------------------------------------------------------------------
#
# PowerShell script to silently install the Solid Edge and optionally 
# the data management clients.
#
# NOTE: if you encounter an error "SolidEdgeInstall.ps1 cannot 
# be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell
# execution policy.  To change the policy, in a PowerShell command
# prompt run the following command:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 14/07/2014  merritt  initial release
# 29/10/2014  merritt  corrected typos in text
#

<#
.SYNOPSIS
Installs Solid Edge and optionally any Solid Edge data management clients.

.DESCRIPTION
The script automates silent installation of Solid Edge and optionally any Solid Edge data management clients.

.NOTES
File Name : SolidEdgeInstall.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/

.PARAMETER InstallFolder
Optional parameter pointing to the location of the Solid Edge install media. If not provided in the command line user will be prompted for this inline.

.PARAMETER Template
Optional parameter specifying which Solid Edge template standard to install. If not provided in the command line user will be prompted for this inline.

.PARAMETER DataMgmtClient
Optional parameter specifying which Solid Edge data management clients to install. If not provided in the command line user will be prompted for this inline.
#>

# set our input params
param(
    [string]$InstallFolder, 
    [string]$Template, 
    [string]$DataMgmtClient
)  

# set our title
cls
$host.ui.rawui.WindowTitle="Install Solid Edge"

# set debug switch for testing code, set to 1 to do uninstall set to 0 to test
$DebugOff = 1

# set up our install location for our log and backup files
$Timestamp = Get-Date -f yyyy-MM-dd_HH_mm_ss
$LogRoot = "SolidEdge_Install"
$PathLog = $env:temp + "\" + $LogRoot + "\" + $Timestamp
New-Item $PathLog -ItemType directory -force >$null

# enter our install media location
$host.ui.rawui.WindowTitle="Select Solid Edge install media"
$DataMgmt = 0
$Selection = 0
while ($Selection -eq 0)
{
    Write-Host 
    if ($InstallFolder -eq "")
    {
        Write-Host "    Enter Solid Edge install media folder location,"
        $Selected = Read-Host -Prompt "    where either autostart.exe or setup.exe located"
        
        $MediaFolder = $Selected
        $MediaFolder = $Selected.Replace("`"","")   
        # this is a junk note for formatting issue in notepad++ "`""
    }
    else
    {
        $MediaFolder = $InstallFolder
        $InstallFolder = ""
    }
    # check a valid selection input
    if ($MediaFolder.length -gt 1)
    {
        if (Test-Path "$MediaFolder")
        {
            # check which level - autostart or msi
            if (Test-Path "$MediaFolder\autostart.exe")
            {
                if (Test-Path "$MediaFolder\Solid Edge\setup.exe")
                {
                    $InstallTop = $MediaFolder
                    $InstallSolidEdge = "$MediaFolder\Solid Edge"
                    $Selection = 1
                }
                else
                {
                    Write-Host
                    Write-Host "    ERROR! Cannot locate installer!"           
                }
            }
            elseif (Test-Path "$MediaFolder\setup.exe")
            {
                $InstallSolidEdge = "$MediaFolder"
                if (Test-Path "$MediaFolder\..\autostart.exe")
                {                    
                    $InstallTop = Split-Path $MediaFolder -Parent
                }
                else
                {
                    Write-Host 
                    Write-Host "    WARNING! No additional Solid Edge install media found!"
                    Write-Host "    No data management products available. Will only install Solid Edge!"
                    $DataMgmt = 1
                }
                $Selection = 1
            }
            else
            {
                Write-Host
                Write-Host "    ERROR! Cannot locate installer!"           
            }
        }
        else
        {
            Write-Host
            Write-Host "    ERROR! Invalid folder location!"        
        }
    }
}
   
# test if Solid Edge <ver>.msi exists
$FolderContent = Get-ChildItem -path "$InstallSolidEdge" -name -filter "Solid Edge*.msi"
If ($FolderContent -eq "" -or $FolderContent -eq $null)
{
    Write-Host
    Write-Host "    ERROR! Solid Edge .msi install file not found!"
    Write-Host
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Write-Host
    Exit
}
else
{
    $SeInstaller = $FolderContent
    # determine which SE version based on the msi file
    $SeVersion = $SeInstaller.Replace(".msi", "")
    $SeVersion = $SeVersion.Replace("Solid Edge ", "")
    $VersionNo = $SeVersion.Replace("ST", "")
    Write-Host
    Write-Host "    It appears we are installing $SeVersion"
    
    $SeInstallerFull = $InstallSolidEdge + "\" + $SeInstaller
    Write-Host
    Write-Host "    Installer `"$SeInstaller`" found!"
}

# select the default template
$host.ui.rawui.WindowTitle="Select Solid Edge template"
$Selection = 0
$TemplateNo = 8
while ($Selection -eq 0)
{
    if ($Template -eq "")
    {   
        Write-Host
        Write-Host "    Template Standard"
        Write-Host "    =================" 
        Write-Host
        Write-Host "    (1) Metric"
        Write-Host "    (2) JIS Metric"
        Write-Host "    (3) ISO Metric"
        Write-Host "    (4) ANSI Inch"
        Write-Host "    (5) DIN Metric"
        Write-Host "    (6) UNI Metric"
        Write-Host "    (7) ESKD Metric"
        Write-Host "    (8) GB Metric"
        
        if ($VersionNo -ge 7)
        {
            Write-Host "    (9) ANSI Metric"
            $TemplateNo = 9
        }
        Write-Host
        $Selected = Read-Host -Prompt "    Select number of template standard to install"
    }
    else
    {
        $Selected = $Template
        $Template = ""
    }
    
    # check a valid selection input
    if (($Selected.Length -eq 1) -and (($Selected -gt 0) -and ($Selected -le $TemplateNo)))
    {
        $Selection = 1
    }
}
$TemplateStd = $Selected
$SeecInstallerFull = ""
$SespInstallerFull = ""
$InsInstallerFull = ""

# select the data management products 
if ($DataMgmt -ne 1)
{
    $host.ui.rawui.WindowTitle="Select Solid Edge data management"
    $Selection = 0
    while ($Selection -eq 0)
    {
        if ($DataMgmtClient -eq "")
        {        
            Write-Host
            Write-Host "    Data Management"
            Write-Host "    ===============" 
            Write-Host
            Write-Host "    (1) None"
            Write-Host "    (2) Solid Edge Embedded Client"
            Write-Host "    (3) Solid Edge SharePoint"
            Write-Host "    (4) Insight"
            Write-Host "    (5) All"
            Write-Host
            $Selected = Read-Host -Prompt "    Select number of data management product to install"
        }
        else
        {
            $Selected = $DataMgmtClient
            $DataMgmtClient = ""
        }
        
        # check a valid selection input
        if (($Selected.Length -eq 1) -and (($Selected -gt 0) -and ($Selected -lt 6)))
        {
            $Selection = 1
        }
    }
    $DataMgmt = $Selected
}

# check if the SEEC installer exists
if ($DataMgmt -eq 2 -or $DataMgmt -eq 5)
{  
    $ContinueCheck = 0
    $InstallSeec = $InstallTop + "\Solid Edge Teamcenter Client"
    # test if .msi exists
    if (Test-Path "$InstallSeec")
    {
        $FolderContent = Get-ChildItem -path "$InstallSeec" -name -filter "Solid Edge Teamcenter Client*.msi" 
        if ($FolderContent -eq "" -or $FolderContent -eq $null)
        {
            $ContinueCheck = 1
        }
        else
        {
            $SeecInstaller = $FolderContent
            $SeecInstallerFull = $InstallSeec + "\" + $SeecInstaller
            Write-Host
            Write-Host "    Installer `"$SeecInstaller`" found!"
        }
    }
    else
    {
        $ContinueCheck = 1
    }
    
    if ($ContinueCheck)
    {
        Write-Host
        Write-Host "    WARNING! Solid Edge Teamcenter Client .msi install file not found!"
        $Selection = 0
        while ($Selection -eq 0)
        {
            Write-Host
            $Selected = Read-Host -Prompt "    Continue Solid Edge installation? (Y/N)"
            
            # check a valid selection input
            if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
            {
                $Selection = 1
            }
        }
        if ($Selected -eq "y")
        { 
            $SeecInstallerFull = ""
        }
        else
        {        
            Write-Host
            Write-Host "    Press any key to exit..."
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Exit             
        }        
    }
}

# check if the SESP installer exists
if ($DataMgmt -eq 3 -or $DataMgmt -eq 5)
{  
    $ContinueCheck = 0
    if ($VersionNo -eq 5)
    {
        $InstallSesp = $InstallTop + "\Solid Edge Insight XT Client"   
    }
    else
    {    
        $InstallSesp = $InstallTop + "\Solid Edge SP Client"   
    }
    # test if .msi exists
    if (Test-Path "$InstallSesp")
    {
        if ($VersionNo -eq 5)
        {
            $FolderContent = Get-ChildItem -path "$InstallSesp" -name -filter "Solid Edge Insight XT Client*.msi" 
        }
        else
        {    
            $FolderContent = Get-ChildItem -path "$InstallSesp" -name -filter "Solid Edge SP Client*.msi"         
        }
        if ($FolderContent -eq "" -or $FolderContent -eq $null)
        {
            $ContinueCheck = 1
        }
        else
        {
            $SespInstaller = $FolderContent
            $SespInstallerFull = $InstallSesp + "\" + $SespInstaller
            Write-Host
            Write-Host "    Installer `"$SespInstaller`" found!"
        }
    }
    else
    {
        $ContinueCheck = 1
    }
    
    if ($ContinueCheck)
    {
        Write-Host
        Write-Host "    WARNING! Solid Edge SharePoint Client .msi install file not found!"
        $Selection = 0
        while ($Selection -eq 0)
        {
            Write-Host
            $Selected = Read-Host -Prompt "    Continue Solid Edge installation? (Y/N)"
            
            # check a valid selection input
            if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
            {
                $Selection = 1
            }
        }
        if ($Selected -eq "y")
        { 
            $SespInstallerFull = ""
        }
        else
        {
            Write-Host    
            Write-Host "    Press any key to exit..."
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Exit             
        }        
    }
}

# check if the INS installer exists
if ($DataMgmt -eq 4 -or $DataMgmt -eq 5)
{   
    $ContinueCheck = 0
    $InstallIns = $InstallTop + "\Solid Edge Insight Client"
    # test if .msi exists
    if (Test-Path "$InstallIns")
    {
        $FolderContent = Get-ChildItem -path "$InstallIns" -name  -filter "Solid Edge Insight Client*.msi" 
        if ($FolderContent -eq "" -or $FolderContent -eq $null)
        {
            $ContinueCheck = 1
        }
        else
        {
            $InsInstaller = $FolderContent
            $InsInstallerFull = $InstallIns + "\" + $InsInstaller
            Write-Host
            Write-Host "    Installer `"$InsInstaller`" found!"
        }
    }
    else
    {
        $ContinueCheck = 1
    }
    
    if ($ContinueCheck)
    {
        Write-Host
        Write-Host "    WARNING! Solid Edge Insight Client .msi install file not found!"
        $Selection = 0
        while ($Selection -eq 0)
        {
            Write-Host
            $Selected = Read-Host -Prompt "    Continue Solid Edge installation? (Y/N)"
            
            # check a valid selection input
            if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
            {
                $Selection = 1
            }
        }
        if ($Selected -eq "y")
        { 
            $InsInstallerFull = ""
        }
        else
        {        
            Write-Host
            Write-Host "    Press any key to exit..."
            $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            Exit             
        }        
    }
}

# install Solid Edge
$host.ui.rawui.WindowTitle="Installing Solid Edge..."
Write-Host
Write-Host "    Installing Solid Edge..."
$LogFile = $PathLog + "\SolidEdge.log"
$InstallArgs = "/i `"" + $SeInstallerFull + "`" MYTEMPLATE=" + $TemplateStd + " /qn /L*v `"" + $LogFile + "`""    
if ($DebugOff)
{
    # install software
    Start-Process msiexec.exe $InstallArgs -Wait
}
else
{
    Write-Host
    Write-Host "Start-Process msiexec.exe $InstallArgs -Wait"
    Write-Host
}

# install SEEC
if ($SeecInstallerFull -ne "")
{
    $host.ui.rawui.WindowTitle="Installing Solid Edge Teamcenter Client..."
    Write-Host
    Write-Host "    Installing Solid Edge Teamcenter Client..."
    $LogFile = $PathLog + "\SEEC.log"
    $InstallArgs = "/i `"" + $SeecInstallerFull + "`" /qn /L*v `"" + $LogFile + "`""    
    
    if ($DebugOff)
    {
        # install software
        Start-Process msiexec.exe $InstallArgs -Wait
    }
    else
    {
        Write-Host
        Write-Host "Start-Process msiexec.exe $InstallArgs -Wait"
        Write-Host
    }
}

# install SESP
if ($SespInstallerFull -ne "")
{
    $host.ui.rawui.WindowTitle="Installing Solid Edge SharePoint Client..."
    Write-Host
    Write-Host "    Installing Solid Edge SharePoint Client..."
    $LogFile = $PathLog + "\SESP.log"
    $InstallArgs = "/i `"" + $SespInstallerFull + "`" /qn /L*v `"" + $LogFile + "`""    
    
    if ($DebugOff)
    {
        # install software
        Start-Process msiexec.exe $InstallArgs -Wait
    }
    else
    {
        Write-Host
        Write-Host "Start-Process msiexec.exe $InstallArgs -Wait"
        Write-Host
    }
}

# install INS
if ($InsInstallerFull -ne "")
{
    $host.ui.rawui.WindowTitle="Installing Solid Edge Insight Client..."
    Write-Host
    Write-Host "    Installing Solid Edge Insight Client..."
    $LogFile = $PathLog + "\INS.log"
    $InstallArgs = "/i `"" + $InsInstallerFull + "`" /qn /L*v `"" + $LogFile + "`""    
    
    if ($DebugOff)
    {
        # install software
        Start-Process msiexec.exe $InstallArgs -Wait
    }
    else
    {
        Write-Host
        Write-Host "Start-Process msiexec.exe $InstallArgs -Wait"
        Write-Host
    }
}

# display our log files
$host.ui.rawui.WindowTitle="Install of Solid Edge $SeVersion finished!"
Write-Host
Write-Host "    Install logs can be found in:"
Write-Host
Write-Host "    $PathLog"
Write-Host

# finally close out of the install
Write-Host "    Solid Edge $SeVersion install complete!"
Write-Host
if ($DebugOff -eq 0)
{
    Invoke-Expression "explorer '/root,$PathLog'"
    Write-Host "    Press any key to exit..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
else
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $Return = [System.Windows.Forms.MessageBox]::Show("Solid Edge $SeVersion install complete." , "Solid Edge Install",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Asterisk)
}

Exit