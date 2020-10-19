# Windows-Backup-Script

A batch script to backup folders on Windows.

You get this script, then create your own `.bat` file that defines configuration parameters, such as which directories you want to back up.

When you run this script, it will back up those directories (with certain exclusions) and delete old back-ups.

You can also schedule this script to run every X hours.

## How to set up the script

How to set up this script.

1. Git clone this repository somewhere.

    ```bat
    mkdir %HOMEPATH%\myApps
    cd %HOMEPATH%\myApps
    git clone git@github.com:robertmarkbram/Windows-Backup-Script.git
    cd Windows-Backup-Script
    ```

2. Within the `Windows-Backup-Script` directory (or wherever you want), create a `.bat` file that controls how the backup script will operate.

    Save the file as `backup-settings-for-%computername%.bat`, where `%computername%` is your computer's name. Find it by opening a DOS box and typing:

    ```bat
    echo %computername%
    ```

    It's named like this so the script doesn't have to be modified for whatever machine you run this on - it will look for a file with the same name as your machine. This script can be shared across multiple machines and will work the same as long as each have the same file based on their computer name.

    **Configuration file.**

    ```bat
    :: Where do you want to put the backup files?
    SET BACKUP_HOME=%HOMEPATH%\bak\workspace

    :: How long (days) do you want to keep them?
    SET DAYS_B4_DELETE=10

    :: Define path and label (no spaces) for each directory you want to backup.
    SET DIR1="C:\path\to\dir-1\to\backup"
    SET LBL1=LABEL-1-NO-SPACE
    SET DIR2="C:\path\to\dir-2\to\backup"
    SET LBL2=LABEL-2-NO-SPACE
    SET DIR3="%HOMEPATH%\path\to\dir-3\to\backup"
    SET LBL3=LABEL-3-NO-SPACE

    :: How many dir/lbl combinations did you define? Will ignore all beyond this number.
    SET MAX=2

    :: How often (in hours) do you want to run this script?
    SET HOURS=4

    :: What name to give the scheduled task.
    SET SCHED_TASK_LABEL=Backup my PC every 4 hours
    ```

    This controls:

    1. Where to save the back up files.
    2. What directories to back-up.
    3. What label to use when saving each backup (archives are named as: `LABEL_yyyymmdd_hhMMss.7z`)
    4. How long to keep backups (in days).
    5. What label to use when scheduling this task.
3. If you choose to save the configuration file under some name other than `backup-settings-for-%computername%.bat` or in a different directory that the root directory of this project, you will need to edit `Backup.bat` and change this line:

    ```bat
    :: Define where to find settings for backup up files on this machine.
    :: By default looks for the settings file in the same folder as this script.
    SET BACKUP_SETTINGS_FILE=%~dp0\backup-settings-for-%computername%.bat
    ```

    Modify the path and file name to suit what you used.

## How to run the script

With your configuration file saved somewhere and `BACKUP_SETTINGS_FILE` modified if needed, run the script by double clicking on it.

## How to schedule the script

Open a command prompt. Change to the directory that holds this script and run the command `Backup.bat sched`.

```bat
cd /D %HOMEPATH%\myApps\Windows-Backup-Script
Backup.bat sched
```

Depending on permissions on your machine, you may need to enter your password.