@echo off

rem SolidEdgeToPDF
rem Copyright (C) 2015, David C. Merritt, david.c.merritt@siemens.com
rem
rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <http://www.gnu.org/licenses/>.
rem
rem ---------------------------------------------------------------------
rem
rem DOS script to print Solid Edge draft files to PDF from the command
rem line by creating a wrapper to SolidEdgeTranslationServices.exe.  By 
rem creating this script this then allows you to drag and drop a Solid
rem Edge draft file onto the script and automatically convert the file.
rem 
rem This script will also allow for the drag and drop of folders and 
rem will then print all of the draft files in the folder.
rem
rem To use you must first define the location of your Solid Edge install
rem location in the area highlighted below.
rem
rem ---------------------------------------------------------------------
rem
rem 28/07/2015  merritt  initial release
rem

rem *********************************************************************
rem *                                                                   *                            
rem * set your Solid Edge install location below here                   *                            
rem *                                                                   *                            
rem *********************************************************************

set SE_INSTALL_PATH=C:\Program Files\Solid Edge ST8

rem *********************************************************************
rem *                                                                   *                            
rem * set your Solid Edge install location above here                   *                            
rem *                                                                   *                            
rem *********************************************************************

set SOFTWARE_NAME=SolidEdgeToPDF
title %SOFTWARE_NAME%
cls 

set TRANSLATOR_PATH=%SE_INSTALL_PATH%\Program
set TRANSLATOR_EXE=%TRANSLATOR_PATH%\SolidEdgeTranslationServices.exe

