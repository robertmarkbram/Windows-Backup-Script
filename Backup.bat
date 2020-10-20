@ECHO OFF

:: BACKUP DIRECTORIES AND DELETE OLD BACKUPS
::
:: Run this script without arguments and it will backup selected directories to
:: a backup directory and delete old backup directories.

:: SCHEDULE BACKUP TASKS
:: Run this script with argument "sched" and it will schedule this script to run
:: every few hours. You will need to enter your Windows password.
:: For example:
::    cd /D %HOMEPATH%\myApps\Windows-Backup-Script
::    Backup.bat sched
::    Scheduling task.

:: Old blog entry about this.
:: Directory backup utility.
::    http://robertmarkbramprogrammer.blogspot.com.au/2010/06/script-to-backup-directories-on-regular_28.html

:: - Tested on Win 10, 7 and XP 64 bit.
:: - Dependency: invisible.vbs - small script that lets this batch file be run
::    without popping up a DOS box. Is used when you schedule this batch.
::    Put invisible.vbs in the same folder as this batch file.
::
::    The invisible.vbs file is included in this repo.
::
::    Or create it yourself. Contents of invisible.vbs:
::       CreateObject("Wscript.Shell").Run """" & WScript.Arguments(0) & """", 0, False
::
:: - Dependency: forfiles.exe - Windows 7/XP-bit and later should have the
::    FORFILES command by default. For earlier Windows builds, get it from:
::      http://ss64.com/nt/forfiles.html
::    and make sure to put forfiles.exe in the PATH (e.g. C:\WINDOWS\system32\
::    for Windows XP).
:: - Dependency: 7zip, a FREE and open source alternative to WinZip - get it
::    from here: http://www.7-zip.org and edit the ZIP variable below if the
::    path is NOT C:\Program Files\7-Zip\7z.exe.

:: HISTORY
:: =============================
:: Wednesday, 23rd of June 2010, 5:10:55 PM
:: - v1.
:: Monday, 28th of June 2010, 6:03:28 PM
:: - Modified to backup directories to zip files instead of backing 
::    by copying directories.
:: Monday, 12th of September 2011, 07:34:52 PM
:: - Modified the way FORFILES is called to use / switches.
::    Plus, added ZIP variable instead of relying on it being in the PATH.
:: Saturday, 19th of May 2012, 11:43:42 AM
:: - Integrated invisible.vbs to hide DOS box.
:: Monday, 25th of April 2016, 04:39:57 PM
:: - Re-wrote some comments.. trying to work out this error:
::    ---------------------------
::    Windows Script Host
::    ---------------------------
::    Script:   D:\apps\Batch\invisible.vbs
::    Line:   1
::    Char:   1
::    Error:   The system cannot find the file specified.
::    Code:   80070002
::    Source:    (null)
::    ---------------------------
::    OK
::    ---------------------------
:: Thursday, 17th of May 2018, 11:04:27 AM
:: - Uses specific path to find forfiles.exe
:: Monday, 19th of October 2020, 05:52:17 PM
:: - Fixed up usage of 7-zip: 
::    - cd to folder we want to backup.
::    - backup everyting except for exclude patterns.
:: Monday, 19th of October 2020, 07:15:01 PM
:: - Refactor to define backup configuration settings in a machine specific file:
::    %HOMEPATH%\myApps\batch\backup-settings-for-%computername%.bat
:: - Added extra comments and pretty to output.
:: - Specified contents of invisible.vbs.
:: Tuesday, 20th of October 2020, 11:56:59 PM
:: - Quote script when setting up scheduled command.

:: =======================================
:: EDIT THIS SECTION.
:: =======================================
:: Where is 7zip installed to?
SET ZIP="C:\Program Files\7-Zip\7z.exe"
:: Where is forfiles installed to?
SET FORFILES="C:\Windows\System32\forfiles.exe"
:: Define where to find settings for backup up files on this machine.
:: By default looks for the settings file in the same folder as this script.
SET BACKUP_SETTINGS_FILE=%~dp0\backup-settings-for-%computername%.bat

:: =======================================
:: DON'T CHANGE BELOW THIS POINT unless you know what you are doing!
:: =======================================

if not exist "%BACKUP_SETTINGS_FILE%" goto :SETTINGS_NOT_FOUND
goto :LOAD_SETTINGS

:: Load settings for this machine.
:LOAD_SETTINGS 
echo Loading setup configuration for this machine from:
echo    %BACKUP_SETTINGS_FILE%
call "%BACKUP_SETTINGS_FILE%"
goto :POST_SETTINGS_LOADED

:: Crap: couldn't load settings for this machine.
:SETTINGS_NOT_FOUND
echo DID NOT FIND A FILE CONFIGURING BACKUP SETTINGS FOR THIS MACHINE.
echo.
echo EXPECTED FILE: %BACKUP_SETTINGS_FILE%
echo.
echo.
echo SAMPLE CONTENTS BELOW:
echo.
echo    :: Where do you want to put the backup files?
echo    SET BACKUP_HOME=%%HOMEPATH%%\bak\workspace
echo.   
echo    :: How long (days) do you want to keep them?
echo    SET DAYS_B4_DELETE=10
echo.   
echo    :: Define path and label (no spaces) for each directory you want to backup.
echo    SET DIR1="C:\path\to\dir-1\to\backup"
echo    SET LBL1=LABEL-1-NO-SPACE
echo    SET DIR2="C:\path\to\dir-2\to\backup"
echo    SET LBL2=LABEL-2-NO-SPACE
echo    SET DIR3="%%HOMEPATH%%\path\to\dir-3\to\backup"
echo    SET LBL3=LABEL-3-NO-SPACE
echo.   
echo    :: How many dir/lbl combinations did you define? Will ignore all beyond this number.
echo    SET MAX=2
echo.   
echo    :: How often (in hours) do you want to run this script?
echo    SET HOURS=4
echo.   
echo    :: What name to give the scheduled task.
echo    SET SCHED_TASK_LABEL=Backup my PC every 4 hours
echo.
echo Create a file with contents like those above and try again.

goto :END

:: Logic that should occur once machine based settings are loaded.
:POST_SETTINGS_LOADED

:: Directory Checks
IF "%BACKUP_HOME%" == "" (
   echo Warning: BACKUP_HOME has not been set.
   GOTO :END
)
IF NOT EXIST "%BACKUP_HOME%"  (
   echo Warning: BACKUP_HOME [%BACKUP_HOME%] does not exist.
   GOTO :END
)

:: Are we scheduling or backing up?
IF "%1" == "sched" GOTO :SCHEDULE
GOTO :BACKUP

:: Schedule this script to run regularly - user will have to enter password.
:SCHEDULE
echo Scheduling task: %0.
:: Schedule task.
echo Scheduling task: "wscript.exe %~dp0invisible.vbs %~dp0%~n0"
schtasks /create /SC HOURLY /MO %HOURS% /tn "%SCHED_TASK_LABEL%" /tr "wscript.exe \"%~dp0invisible.vbs\" \"%~dp0%~n0\""
GOTO :END

:: Run backup tasks.
:BACKUP
echo.
echo Backing up files.
echo.

:: Create timestamp.
SET hh=%time:~0,2%
if "%time:~0,1%"==" " SET hh=0%hh:~1,1%
:: Home PC
if "%computername%" == "ITS32675" (
   echo yo
   SET YYYYMMDD_HHMMSS=%date:~6,4%%date:~3,2%%date:~0,2%_%hh%%time:~3,2%%time:~6,2%
) else (
   SET YYYYMMDD_HHMMSS=%date:~10,4%%date:~7,2%%date:~4,2%_%hh%%time:~3,2%%time:~6,2%
)

:: Backup selected paths.
:: Note use of ^^! below - to escape the exclamation mark because 
::    we have turned on EnableDelayedExpansion
::    and we want 7zip to see the exclamation mark, not DOS.
SetLocal EnableDelayedExpansion
For /L %%i in (1,1,%MAX%) Do (
   IF EXIST !DIR%%i! (
      echo.
      echo .
      echo ..
      echo ...
      echo ====
      echo Backing up !DIR%%i!
      echo ====
      echo ...
      echo ..
      echo .
      echo.
      :: Go into the directory we want to backup.
      cd !DIR%%i!

      :: Backup everything except excluded files and directories.
      %ZIP% a "%BACKUP_HOME%\!LBL%%i!_%YYYYMMDD_HHMMSS%" ^
         -x^^!".git"           ^
         -x^^!"noupload"       ^
         -x^^!"out"            ^
         -x^^!"target"         ^
         -xr^^!".history"       ^
         -xr^^!".databaseDumps"       ^
         -x^^!"build"          ^
         -x^^!"bin"            ^
         -x^^!"node_modules"   ^
         -xr^^!"*.bak"         ^
         -xr^^!"*.log"         ^
         -xr^^!"*.gz"          ^
         -xr^^!"*.7z"          ^
         -xr^^!"*.zip"
   ) ELSE (
      echo.
      echo Specified backup directory does not exist. Skipping it.
      echo    !DIR%%i!
      echo.
   ) 
)
EndLocal


:: Delete old backups.
echo.
echo Deleting old files.
echo.
IF "%DAYS_B4_DELETE%" == "" (
   echo WARNING! DAYS_B4_DELETE not set. Not deleting old backups.
   GOTO :END
)

:: SetLocal EnableDelayedExpansion
SetLocal EnableDelayedExpansion
For /L %%i in (1,1,%MAX%) Do (
   echo.
   echo Looking for old files matching label: !LBL%%i!
   %FORFILES% /P "%BACKUP_HOME%" /M !LBL%%i!_*.7z /D -%DAYS_B4_DELETE% ^
      /C "CMD /C del /F /Q @FILE & echo Deleted @FILE "
   echo.
)
EndLocal

:: Use this for testing - echo what files will be deleted.
:: SetLocal EnableDelayedExpansion
:: For /L %%i in (1,1,%MAX%) Do (
::    %FORFILES% /P "%BACKUP_HOME%" /M !LBL%%i!_*.7z /D -%DAYS_B4_DELETE% ^
::       /C "CMD /C echo @FILE will be deleted"
:: )
:: EndLocal

:END

:: Uncomment the "pause" line if you want the command window to stick around
:: until you "Press any key to continue . . ."
:: (Let's you see the output of every run.)
pause

