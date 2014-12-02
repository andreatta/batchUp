@echo off
set LINE=-------------------------------------------------------------------------------
title Graph-Tech(c) Batch Installer
:: cd /D %~d0%~p0 in aktuelles Verzeichnis wechseln funktioniert hier oben noch nicht, wegen UNC Pfaden!
color A2

cls
:MAIN
	echo %LINE%
	echo INSTALL Graph-Tech(c) Backup Tool v0.6
	echo.
	echo (c) by Graph-Tech AG {can} 2008
	echo %LINE%
	echo.

:WRITEREG
echo Windows Registry Editor Version 5.00 >> %TEMP%\DisUNC.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Command Processor] >> %TEMP%\DisUNC.reg
echo "DisableUNCCheck"=dword:00000001 >> %TEMP%\DisUNC.reg
:: Regedit starten und Eintrag ohne Nachfrage schreiben!
START /WAIT REGEDIT /S %TEMP%.\DisUNC.REG
del %TEMP%\DisUNC.reg
::echo UNCCheck deaktiviert

::Pfad auf Server wird gespeichert!!! Sonst gibt es UNC Error in CMD
set InstPath=%~d0%~p0
copy "%InstPath%robocopy.exe" "%systemroot%\system32" >NUL
::copy "%InstPath%robocopy.exe" "%systemroot%\system32" >NUL
::echo Robocopy.exe wurde erfolgreich kopiert...
::echo.

:INST
set instDIR=%ProgramFiles%\GTools\GTBKP

echo Wollen sie das Programm in folgendem Verzeichnis installieren?
echo %LINE%
echo %instDIR%
echo %LINE%
:: Auswahl J oder N 
set /P X=(J)a oder (N)ein: 
if /I "%X%"=="J" goto JA
if /I "%X%"=="N" goto NEIN

:DEFAULT
echo Geben sie 'J' ein wenn sie das Programm unter %instDIR% installieren wollen
echo.
echo Geben sie 'N' ein um ein eigenes Verzeichnis anzugeben.
cls
goto INST

:NEIN
echo Geben sie das gewnschte Verzeichnis an:
set /P instDIR=""

:JA
REM echo %dest%
REM echo Geben sie den Pfad fr die Batch-Datei an: 
REM echo Beispiel: 'E:\Programme\GTBKP'
REM set /P instDIR=""
echo.
if exist %instDIR% goto :OK
	md %instDIR% 
	::echo ERRORLEVEL: %errorlevel%
	::findstr "Syntax"
	::echo GEFUNDEN: %errorlevel%
	
	if %errorlevel% == 0 goto :OK
		echo Verzeichnis konnte nicht erstellt werden!
		goto :INST

:OK
::echo %instDIR% wurde erfolgreich erstellt!
::copy "%InstPath%robocopy.exe" "%instDIR%" >NUL
copy "%InstPath%robocopy.doc" "%instDIR%" >NUL
copy "%InstPath%GT_backup.bat" "%instDIR%" >NUL
copy "%InstPath%gt.ico" "%instDIR%" >NUL
if exist %instDIR%\bkpfolders.txt goto :LNK
	copy "%InstPath%bkpfolders.txt" "%instDIR%" >NUL

:LNK
::VBS Datei schreiben um Verknüpfung auf Desktop zu erstellen
echo Const strProgram ="%instDIR%\GT_backup.bat" >>"%instDIR%\mklnk.vbs"
echo Dim objShortcut >>"%instDIR%\mklnk.vbs"
echo Dim objShell >>"%instDIR%\mklnk.vbs"
echo Set objShell= WScript.CreateObject("Wscript.Shell") >>"%instDIR%\mklnk.vbs"
echo Set objShortcut=objShell.CreateShortcut("%userprofile%\Desktop\backup.lnk") >>"%instDIR%\mklnk.vbs"
echo objShortcut.TargetPath= strProgram >>"%instDIR%\mklnk.vbs"
echo objShortcut.Description= "macht Backups von den in der Datei 'bkpfolders.txt' angegebenen Ordnern." >>"%instDIR%\mklnk.vbs"
echo objShortcut.IconLocation = "%instDIR%\gt.ico" >>"%instDIR%\mklnk.vbs"
echo objShortcut.Save  >>"%instDIR%\mklnk.vbs"

"%instDIR%\mklnk.vbs"	
del "%instDIR%\mklnk.vbs"
:: ä ö ü „”
echo Installation erfolgreich abgeschlossen!
echo Drcken sie eine beliebige Taste um dieses Fenster zu schliessen.
echo Es ”ffnet sich danach eine Datei in der sie die Pfade angeben k”nnen
echo welche sie automatisch sichern wollen.
pause >NUL
start notepad "%instDIR%\bkpfolders.txt"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:EOF



