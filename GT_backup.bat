@echo off
set LINE=-------------------------------------------------------------------------------
set END=*******************************************************************************
set VERSION=1.0
mode con: cols=80 lines=12

REM NEWLINE (the empty lines are necessary!)
set NLM=^


set NL=^^^%NLM%%NLM%^%NLM%%NLM%
REM end of NEWLINE

REM immer ins Batch Verzeichnis wechseln
cd /D %~d0%~p0

REM Auf Server oder DiskStation speichern
set "destDS=\\ds209j\bkp\%USERNAME%" 

REM Parameter einlesen ->  wo soll gespeichert werden?
if "%1"=="gt" (
	REM set "dest=%destGT%"
	echo R.I.P. gt-server2
	pause >nul
	goto EOF
) else (
	set "dest=%destDS%"
)

REM set Title with destination!
title Graph-Tech (c) Batchup v%VERSION% .:. %dest%

:MAIN
	REM blau auf grau
	color 79	
	cls
	echo %LINE%
	echo ROBOCOPY Script um ein inkrementelles Backup von mehreren Ordnern zu erstellen.
	echo Es k”nnen beliebige Ordner in der Datei 'bkpfolders.txt' angegeben werden. 
	echo.
	echo (c) by Graph-Tech AG {can} 2011
	echo %LINE%
	echo.

REM überprüfen ob der Computer im GT Netz ist!
ipconfig|findstr /C:"192.168.112">nul || ( 
    goto NONET
)

REM log Datei löschen falls bereits vorhanden
if exist bkp.log del bkp.log
if exist temp.log del temp.log
REM Funktion :NEXT mit dem Parameter (Inhalt der Zeile) aufrufen
for /F "delims=; usebackq" %%i in (%cd%\bkpfolders.txt) do call :NEXT "%%i"
goto LOG

:NEXT
REM %1 ist der erste Parameter aus dem "bkpfolders.txt"
set "src=%1"
REM Alle Einträge in der Textdatei checken
goto CHECK

:CHECK	
	REM echo checking: %src%
	if exist %src% (
		goto START
	)

:NOSRC
	REM Fehler schwarz auf rot
	color C0
	cls
	echo Der Pfad %src% existiert nicht!
	echo.
	set /P "src=Ordner angeben der gesichert werden soll: "
	goto CHECK

:NONET
	REM Fehler schwarz auf rot
	color C0
	cls
	echo %LINE%
	echo Sie sind nicht im Netz 'GT'
	echo %LINE%
	echo.
	echo Wollen sie es erneut probieren?
	set /P X=(J)a oder (N)ein: 
	if /I "%X%"=="J" goto MAIN
	if /I "%X%"=="N" goto EOF

:LOG
	echo Backup aller Ordner aus der Datei 'bkpfolders.txt' wurde abgeschlossen.
	type temp.log | find /v "%%">bkp.log
	del temp.log
	set /P L=Druecken sie 'L' um die Log Datei anzuschauen.%NL%
	if /I "%L%"=="L" (
		start bkp.log
	)
	goto EOF
	
:START
	REM UP = ein Verzeichnis höher
	for %%i in (%src%) do set UP=%%~ni%%~xi 
	REM Destination Folder kreieren falls nicht bereits vorhanden
	set "findest=%dest%\%UP%"
	if not exist %findest% md %findest%
	echo start backing up to folder: '%findest%'
	echo Bitte warten bis der Backupvorgang abgeschlossen wurde...
	
	REM Subdirectories, Restart on Access denied, Multitreaded, Retry=3, Wait=3, log to stdout & file
	REM robocopy %src% %findest% /S /MT:8 /ZB /R:3 /W:3 /TEE /FFT /LOG+:"temp.log"
	robocopy %src% %findest% /MIR /TEE /LOG+:"temp.log"

	echo %END%
		
:EOF	

