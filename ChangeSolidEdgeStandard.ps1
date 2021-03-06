# ChangeSolidEdgeStandard
# Copyright (C) 2013, David C. Merritt, david.c.merritt@siemens.com
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
# Powershell script to change the default modeling standard within 
# Solid Edge, optionally clears the existing templates and copies the 
# new default template files associated to the selected modeling 
# standard.
#
# NOTE: if you encounter an error "ChangeSolidEdgeStandard.ps1 cannot 
# be loaded because the execution of scripts is disabled on this 
# system", this is normal.  You will need to modify the PowerShell
# execution policy.  To change the policy, in a PowerShell command
# prompt run the following command:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 12/08/2013  merritt  initial release
#

<#
.SYNOPSIS
Changes default modeling standard and templates in Solid Edge.

.DESCRIPTION
The script changes the default modeling standard within Solid Edge, 
optionally clears the existing templates and copies the new default 
template files associated to the selected modeling standard.

.NOTES  
File Name : ChangeSolidEdgeStandard.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/
#>

# set our title
$host.ui.rawui.WindowTitle="Change Solid Edge modeling standard"

# get the versions of Solid Edge installed in registry
$strVersions = @(Get-ChildItem -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Unigraphics Solutions\Solid Edge' -Name)

# check how many installed versions and if more than one ask for which version
if ($strVersions.Count -gt 1)
{
    $Selection = 0
    while ($Selection -eq 0)
    {
        Clear-Host
        Write-Host       
        Write-Host "    Multiple Solid Edge versions appear to be installed!"  
        Write-Host "    (if this is unexpected manually clean your registry)"
        Write-Host
        $counter = 1
        foreach ($version in $strVersions)
        {
            Write-Host "     "$counter") "$version
            $counter++
        }
 
        Write-Host

        $Selected = Read-Host -Prompt "    Enter number of Solid Edge version to change"
    
        # check a valid selection input
        if (($Selected.Length -eq 1) -and ($Selected -gt 0) -and ($Selected -le $strVersions.Count))
        {
            $Selection = 1
        }
    }
    
    # set our selected version
    $strVersion = $strVersions[($Selected - 1)]
}
else
{
    $strVersion = $strVersions[0]
}

# get the current standard for the selected version
$strRegStd = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Unigraphics Solutions\Solid Edge\" + $strVersion + "\TemplateStandard"
$strCurrentStd = (Get-ItemProperty -Path $strRegStd -Name '(default)').'(default)'

# generate our list of modeling standards and prompt for selection
$strAllStandards = @("ANSI", "DIN", "ESKD", "GB", "ISO", "JIS", "METRIC", "UNI")
$Selection = 0
while ($Selection -eq 0)
{
    Clear-Host
    Write-Host       
    Write-Host "    Solid Edge Modeling Standards"
    Write-Host "    ============================="
    Write-Host
    $counter = 1
    foreach ($standard in $strAllStandards)
    {
        if ($standard -eq $strCurrentStd)
        {
            Write-Host "     "$counter") "$standard "(current)"
        }
        else
        {
            Write-Host "     "$counter") "$standard
        }    
        $counter++
    }
    Write-Host
    $Selected = Read-Host -Prompt "    Enter number of Solid Edge standard"
    
    # check a valid selection input
    if (($Selected.Length -eq 1) -and ($Selected -gt 0) -and ($Selected -le $strAllStandards.Count))
    {
        $Selection = 1
    }    
}

# set our selected standard
$NewStandard = $strAllStandards[($Selected - 1)]
$strRegStd = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Unigraphics Solutions\Solid Edge\" + $strVersion + "\TemplateStandard"
Set-ItemProperty -Path $strRegStd -Name '(default)' -Value $NewStandard

# prompt for selection to clear existing templates and copy new defaults
$Selection = 0
while ($Selection -eq 0)
{
    Write-Host
    $Selected = Read-Host -Prompt "    Clear existing templates and copy default $NewStandard templates (Y/N)"
    
    # check a valid selection input
    if (($Selected.Length -eq 1) -and (($Selected -eq "y") -or ($Selected -eq "n")))
    {
        $Selection = 1
    }
}

# if selected copy our template files
if ($Selected -eq "y")
{
    # get the current template path for the selected version
    $strRegTplate = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Unigraphics Solutions\Solid Edge\" + $strVersion + "\TemplatePath"
    $strCurrentTplate = (Get-ItemProperty -Path $strRegTplate -Name '(default)').'(default)'
    
    # remove any existing template files
    Remove-Item $strCurrentTplate\*.* -include *.asm,*.dft,*.par,*.psm,*.pwd -force
    
    # copy our new template files
    Copy-Item $strCurrentTplate\More\$NewStandard*.* $strCurrentTplate -include *.asm,*.dft,*.par,*.psm,*.pwd -force
}

# finally cleanly exit
Write-Host     
if ($Selected -eq "y")
{
    Write-Host "    Solid Edge modeling standard and templates changed!"    
}
else
{
    Write-Host "    Solid Edge modeling standard changed!"    
}
Write-Host
Write-Host "    Press any key to exit ..."
    
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
Write-Host
Exit
