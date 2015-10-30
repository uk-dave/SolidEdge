#
# This installs multiple files, creates start menu shortcuts, builds 
# an uninstaller, and adds uninstall information to the registry for 
# Add/Remove Programs.
#

# If you change file names you should do a search and replace as 
# the file names show up in a few places.  All program specific info
# be tweaked by editing the !defines below
!define APPNAME "Set Locks for Solid Edge"
!define COMPANYNAME "DM Operations, Utilities, Scripts, Extensions"
!define DESCRIPTION "Caps and Num locks enforcer for Solid Edge"

# These three must be integers
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 1

# These will be displayed by the "Click here for support information" link in "Add/Remove Programs"
# It is possible to use "mailto:" links in here to open the email client
!define HELPURL "mailto:david.c.merrritt@siemens.com?subject=${APPNAME} ${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}" # "Support Information" link
!define UPDATEURL "http://github.com/uk-dave/SolidEdge/tree/master/SetLocksForSolidEdge" # "Product Updates" link
!define ABOUTURL "http://about.me/davidmerritt" # "Publisher" link

# This is the size (in kB) of all the files copied into "Program Files"
!define INSTALLSIZE 1273
 
# Require admin rights on NT6+ (When UAC is turned on)
RequestExecutionLevel admin 
 
# This is our install folder location
InstallDir "$PROGRAMFILES64\${COMPANYNAME}\${APPNAME}"
 
# rtf or txt file - remember if it is txt, it must be in the DOS text format (\r\n)
LicenseData "LICENSE"

# This will be in the installer/uninstaller's title bar
Name "${APPNAME}"
Icon "img\logo.ico"
outFile "setup.exe"
 
!include LogicLib.nsh
 
# Just three pages - license agreement, install location, and installation
page license
page directory
Page instfiles
 
!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend
 
function .onInit
	setShellVarContext all
	!insertmacro VerifyUserIsAdmin
functionEnd
 
section "install"
	# Files for the install directory - to build the installer, these should be in the same directory as the install script (this file)
	setOutPath $INSTDIR
	
    # Files added here should be removed by the uninstaller (see section "uninstall")
    file LICENSE
	file "SetLocksForSolidEdge.exe"
    file "SetLocksForSolidEdge.ini"
    
    setOutPath "$LOCALAPPDATA\${COMPANYNAME}\${APPNAME}"
	file "SetLocksForSolidEdge.ini"
	
    setOutPath $INSTDIR\img
    file "img\icon_caps_off_num_off.ico"
    file "img\icon_caps_off_num_on.ico"
    file "img\icon_caps_on_num_off.ico"
    file "img\icon_caps_on_num_on.ico"
    file "img\icon_pause.ico"
    file "img\logo.ico"
	# Add any other files for the install directory (license files, app data, etc) above here
 
	# Uninstaller - See function un.onInit and section "uninstall" for configuration
	writeUninstaller "$INSTDIR\uninstall.exe"
 
	# Start Menu
	createDirectory "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}"
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\SetLocksForSolidEdge.exe" "" "$INSTDIR\img\icon_caps_on_num_off.ico"
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\Edit Preferences.lnk" "%LOCALAPPDATA%\${COMPANYNAME}\${APPNAME}\SetLocksForSolidEdge.ini" ""
	createShortCut "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" ""
    
    # Startup
	createShortCut "$SMSTARTUP\${APPNAME}.lnk" "$INSTDIR\SetLocksForSolidEdge.exe" "" "$INSTDIR\img\icon_caps_on_num_off.ico"
 
	# Registry information for add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${APPNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\img\logo.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "${COMPANYNAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "HelpLink" "${HELPURL}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Comments" "${DESCRIPTION}"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
	# Set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
sectionEnd
 
# Uninstaller
function un.onInit
	SetShellVarContext all
 
	#Verify the uninstaller - last chance to back out
	MessageBox MB_OKCANCEL "Permanantly remove ${APPNAME}?" IDOK next
		Abort
	next:
	!insertmacro VerifyUserIsAdmin
functionEnd
 
section "uninstall"
  	# Remove Startup
    delete "$SMSTARTUP\${APPNAME}.lnk"
    
	# Remove Start Menu launcher
	delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\${APPNAME}.lnk"
	delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\Edit Preferences.lnk"
    delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}\Uninstall.lnk"
    
	# Try to remove the Start Menu folder - this will only happen if it is empty
	rmDir "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}"
	rmDir "$SMPROGRAMS\${COMPANYNAME}"
 
	# Remove files
    delete $INSTDIR\LICENSE
	delete $INSTDIR\SetLocksForSolidEdge.exe
	delete $INSTDIR\SetLocksForSolidEdge.ini
    delete $INSTDIR\img\icon_caps_off_num_off.ico
    delete $INSTDIR\img\icon_caps_off_num_on.ico
    delete $INSTDIR\img\icon_caps_on_num_off.ico
    delete $INSTDIR\img\icon_caps_on_num_on.ico
    delete $INSTDIR\img\icon_pause.ico
    delete $INSTDIR\img\logo.ico
    
	# Always delete uninstaller as the last action
	delete $INSTDIR\uninstall.exe
 
	# Try to remove the install directory - this will only happen if it is empty
    rmDir $INSTDIR\img
	rmDir $INSTDIR
 
	# Remove uninstaller information from the registry
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
sectionEnd