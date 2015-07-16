# SeBeautifyLog
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
# PowerShell script to beautify the Solid Edge XML log file introduced
# with ST8 by converting into a human readable HTML file.
#
# NOTE: if you encounter an error "SeBeautifyLog.ps1 cannot be loaded 
# because the execution of scripts is disabled on this system", this is 
# normal.  You will need to modify the PowerShell execution policy.  To 
# change the policy, in a PowerShell command prompt run the following 
# Name:
#
#     Set-ExecutionPolicy Unrestricted 
#
# ---------------------------------------------------------------------
#
# 22/06/2015  merritt  initial release
#

<#
.SYNOPSIS
Beautifies the Solid Edge XML log file.

.DESCRIPTION
This script is for beautifing the Solid Edge XML log file first introduced with ST8 by converting the log into a human readable HTML file.

.NOTES  
File Name : SeBeautifyLog.ps1  
Author    : David C. Merritt (david.c.merritt@siemens.com)

.LINK 
http://github.com/uk-dave/SolidEdge/SeBeautifyLog

.PARAMETER Backup
Optional parameter to backup the current user's existing Solid Edge preferences before resetting. Valid input is y or n. If not provided in the command line user will be prompted for this inline.
#># set our input params
param(
        [string]$XmlLogFile
)  

# set our title
cls
$host.ui.rawui.WindowTitle="Beautify SE XML log file"

# check our required xml log file is passed
if ($XmlLogFile -eq "")
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $Return = [System.Windows.Forms.MessageBox]::Show("No XML log file provided!","SE Beautify Log",[System.Windows.Forms.MessageBoxButtons]::OK,[System.Windows.Forms.MessageBoxIcon]::Asterisk)
    Exit
}

# get paths and set html file name
$XmlLogFile = Resolve-Path $XmlLogFile
$FileInfo = Get-ItemProperty -Path $XmlLogFile 
$Folder = $FileInfo.DirectoryName     
$File = $FileInfo.BaseName          
$HtmlFile = $Folder + "\" + $File + ".html"

# read in our xml log file 
$Data = [xml] (Get-Content "$XmlLogFile")

# prepare and write our html head
$Html = "<html>" + "`r`n"
$Html += '  <head>' + "`r`n"
$Html += '    <title>Solid Edge User Experience Log</title>' + "`r`n"
$Html += '  </head>' + "`r`n"
$Html += '  <body>' + "`r`n"
$Html += '    <font face="Consolas">' + "`r`n"
Set-Content $HtmlFile $Html
start-sleep -m 500

# get our solid edge install
$Html = '    <h2>Solid Edge</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Version" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Installation.Version + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "License" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Installation.License + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Level" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Installation.Level + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Type" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Installation.Type + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Locale" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Installation.Locale + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our operating system
$Html = '    <br />' + "`r`n"
$Html += '    <h2>Operating System</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Name" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.OperatingSystem.Name + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Service Pack" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.OperatingSystem.ServicePack + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Architecture" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.OperatingSystem.Architecture + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Version Number" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.OperatingSystem.Version + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Language" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.OperatingSystem.Language + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our hardware
$Html = '    <br />' + "`r`n"
$Html += '    <h2>Hardware</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Manufacturer" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Manufacturer + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Model" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Model + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "System Type" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Systemtype + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Processor" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Processor + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Clock Speed" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Clock + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Physical Processors" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.PhysicalProcessors + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Logical Processors" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.LogicalProcessors + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Cores" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Cores + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Hyperthreading" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Machine.Hyperthreading + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our video
$Html = '    <br />' + "`r`n"
$Html += '    <h2>Video</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <th colspan="2">' + "Adapter" + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Name" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Adapter.Name + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Vendor" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Adapter.Vendor + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Version" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Adapter.Version + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <th colspan="2">' + "Chipset" + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Processor" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Chipset.Processor + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Video RAM" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Chipset.VideoRAM + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "DAC Type" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Chipset.DACType + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <th colspan="2">' + "Display" + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Height" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Display.Height + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Width" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Display.Width + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Frequency" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Display.Frequency + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Bits Per Pixel" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Video.Display.BitsPerPixel + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our session info
$Html = '    <h2>Session</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "User ID" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.User.ID + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Session Start Time" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.Start_Time + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Cumulative Session" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.SessionTime.Cumulative_Session + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Elapsed Session" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.SessionTime.Elapsed_Session + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Cumulative Idle" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.SessionTime.Cumulative_Idle + "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <td>&nbsp;' + "Elapsed Idle" + "&nbsp;</td>`r`n"
$Html += '        <td>&nbsp;' + $Data.SETelemetryLog.Session.SessionTime.Elapsed_Idle+ "&nbsp;</td>`r`n"
$Html += '      </tr>' + "`r`n"
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our preferences
$Html = '    <br />' + "`r`n"
$Html += '    <h2>Preferences</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <th>&nbsp;' + "Preference Set" + "&nbsp;</th>`r`n"
$Html += '        <th>&nbsp;' + "Preference Name"  + "&nbsp;</th>`r`n"
$Html += '        <th>&nbsp;' + "Preference Value" + "&nbsp;</th>`r`n"
$Html += '      </tr>' + "`r`n"  
        
$PreferenceSets = $Data.GetElementsByTagName("PreferenceSet")
foreach ($PreferenceSet in $PreferenceSets)
{
    $Preferences = $PreferenceSet.GetElementsByTagName("Preference")
    foreach ($Preference in $Preferences)
    {
        $Html += '      <tr>' + "`r`n"
        $Html += '        <td>&nbsp;' + $PreferenceSet.Name + "&nbsp;</td>`r`n"
        $Html += '        <td>&nbsp;' + $Preference.Name  + "&nbsp;</td>`r`n"
        $Html += '        <td>&nbsp;' + $Preference.Value + "&nbsp;</td>`r`n"
        $Html += '      </tr>' + "`r`n"    
    }   
}

$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# get our events
$Html = '    <br />' + "`r`n"
$Html += '    <h2>User Events</h2>' + "`r`n"
$Html += '    <table border="1" cellpadding="3" cellspacing="3">' + "`r`n"
$Html += '      <tr>' + "`r`n"
$Html += '        <th>&nbsp;' + "Event"  + "&nbsp;</th>`r`n"
$Html += '        <th>&nbsp;' + "Detail" + "&nbsp;</th>`r`n"
$Html += '        <th>&nbsp;' + "Time (UTC)" + "&nbsp;</th>`r`n"
$Html += '      </tr>' + "`r`n" 

$EventTimes = $Data.GetElementsByTagName("Event")
foreach ($EventTime in $EventTimes)
{
    # convert timestamp to utc time
    $Time = [Convert]::ToString($EventTime.Time, 10)
    $Seconds = $Time.Substring(0,($Time.length-3))
    $Milliseconds = $Time.Substring(($Time.length-3))

    $Timestamp = [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($Seconds))
    $Timestamp = [timezone]::CurrentTimeZone.ToUniversalTime(([datetime]'1/1/1970').AddSeconds($Seconds))
    $Timestamp = [STRING]$Timestamp + "." + $Milliseconds

    # finally write our event type
    $Html += '      <tr>' + "`r`n"
    if ($EventTime.MenuTabChange)
    {
        
        $Html += '        <td bgcolor="DarkGray">&nbsp;' + "MenuTabChange"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="DarkGray">&nbsp;Caption: ' + $EventTime.MenuTabChange.Caption + "&nbsp;<br />`r`n"
        $Html += '            &nbsp;ID: ' + $EventTime.MenuTabChange.ID + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="DarkGray">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"   
   }
    elseif ($EventTime.DocumentLoad)
    {
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + "DocumentLoad"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $EventTime.DocumentLoad.Type + "&nbsp;"
        $Html += $EventTime.DocumentLoad.Class + "&nbsp;"
        $Html += '#' + $EventTime.DocumentLoad.ID + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
    }
    elseif ($EventTime.DocumentChange)
    {
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + "DocumentChange"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $EventTime.DocumentChange.Deactivate_Class + "&nbsp;"
        $Html += "#" + $EventTime.DocumentChange.Deactivate_ID 
        $Html += "&nbsp;--&gt;&nbsp;"       
        $Html += $EventTime.DocumentChange.Activate_Class 
        $Html += "&nbsp;#" + $EventTime.DocumentChange.Activate_ID + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
   }
    elseif ($EventTime.EnvironmentChange)
    {
        $Html += '        <td bgcolor="#D499ED">&nbsp;' + "EnvironmentChange"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="#D499ED">&nbsp;' 
        if ($EventTime.EnvironmentChange.Deactivate -eq "")
        {
            $Html += "Application"        
        }
        else
        {
            $Html += $EventTime.EnvironmentChange.Deactivate        
        }
        $Html += "&nbsp;--&gt;&nbsp;"       
        if ($EventTime.EnvironmentChange.Activate -eq "")
        {
            $Html += "Application"        
        }
        else
        {
            $Html += $EventTime.EnvironmentChange.Activate        
        }
        $Html += "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="#D499ED">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
    }
    elseif ($EventTime.Command)
    {
        # set our background colour
        if ($EventTime.Command.Phase -eq "Start")
        {
            $Bgcolor = "GrenYellow"
            $Bgcolor = "#66FF66"
        }
        elseif ($EventTime.Command.Phase -eq "Terminate")
        {
            $Bgcolor = "BurlyWood"        
        }
        elseif ($EventTime.Command.Phase -eq "Pause")
        {
            $Bgcolor = "#FFFF66"        
        }
        elseif ($EventTime.Command.Phase -eq "Resume")
        {
            $Bgcolor = "#99FFFF"        
        }
        else
        {
             $Bgcolor = "#FFFFFF"               
        }
    
        $Html += '        <td bgcolor="' + $Bgcolor + '">&nbsp;' + "Command"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="' + $Bgcolor + '">' 
       
        # display our command detail based on command type
        if ($EventTime.Command.Phase -eq "Start")
        {
            $Html += "&nbsp;Name:&nbsp;" + $EventTime.Command.ToolTip + "<br />"
            $Html += "&nbsp;Phase:&nbsp;" + $EventTime.Command.Phase + "<br />"
            $Html += "&nbsp;ID:&nbsp;" + $EventTime.Command.CommandID + "<br />"
            $Html += "&nbsp;Environment:&nbsp;" + $EventTime.Command.Environment + "<br />"
            $Html += "&nbsp;Launched From:&nbsp;" + $EventTime.Command.LaunchedFrom
        }
        elseif ($EventTime.Command.Phase -eq "Terminate")
        {
            $Html += "&nbsp;Name:&nbsp;" + $EventTime.Command.ToolTip + "<br />"
            $Html += "&nbsp;Phase:&nbsp;" + $EventTime.Command.Phase + "<br />"
            $Html += "&nbsp;ID:&nbsp;" + $EventTime.Command.CommandID + "<br />"
            $Html += "&nbsp;Environment:&nbsp;" + $EventTime.Command.Environment
        }
        else
        {
            $Html += "&nbsp;Name:&nbsp;" + $EventTime.Command.ToolTip + "<br />"
            $Html += "&nbsp;Phase:&nbsp;" + $EventTime.Command.Phase + "<br />"
            $Html += "&nbsp;ID:&nbsp;" + $EventTime.Command.CommandID + "<br />"
            $Html += "&nbsp;Environment:&nbsp;" + $EventTime.Command.Environment
       }        
        
        # finish our command detail
        $Html += "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="' + $Bgcolor + '">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
    }
    elseif ($EventTime.DocumentClose)
    {
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + "DocumentClose"  + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $EventTime.DocumentClose.Type + "&nbsp;"
        $Html += $EventTime.DocumentClose.Class + "&nbsp;"
        $Html += '#' + $EventTime.DocumentClose.ID + "&nbsp;</td>`r`n"
        $Html += '        <td bgcolor="LightGoldenRodYellow">&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
    }
    else 
    {
        # clean up our unknown xml
        Write-Host $EventTime.InnerXML 
        $String = $EventTime.InnerXML -replace "<", ""
        $String = $String -replace " />", ""
        $String = $String -replace '"', ""
        $String = $String -replace "=", ":&nbsp;"     
        $Command = $String.split(" ")
        $String = $String -replace $Command[0], ""
        $String = $String.trim()
        $String = $String -replace " ", "<br />&nbsp;"
        Write-Host $String
        $Html += '        <td>&nbsp;' + $Command[0] + "&nbsp;</td>`r`n"
        $Html += '        <td>&nbsp;' + $String + "&nbsp;</td>`r`n"
        $Html += '        <td>&nbsp;' + $Timestamp + "&nbsp;</td>`r`n"
    }
    $Html += '      </tr>' + "`r`n"    
}
$Html += '    </table>' + "`r`n"
Add-Content $HtmlFile $Html

# add the log file we generated from
$Html = '    <p><br />' + "`n"
$Html += '   Generated from <a href="' + $XmlLogFile +'" target="_blank">' + $XmlLogFile + "</a>`n"
$Html += '   </p>' + "`n"
Add-Content $HtmlFile $Html

# cleanly close out our html
$Html = '    </font>' + "`n"
$Html += '  </body>' + "`n"
$Html += '</html>' + "`n"
Add-Content $HtmlFile $Html

# finally open our beautified log file
start-sleep -m 500
Invoke-Item $HtmlFile

Exit
