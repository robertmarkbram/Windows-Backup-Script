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
3. If you choose to save the configuration file under some name other than `backup-settings-for-%computername%.bat` or in a different directory than the root directory of this project, you will need to edit `Backup.bat` and change this line:

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

## How to manage multiple configurations on the one computer

Often I want to change what set of directories I am backing up depending on what project I am working on at the time. I don't want to include *all of the project directories* in the one configuration file because my hard disk space will vanish far too quickly. Instead, I set up a configuration file for each project I work on and create a launcher for that configuration.

1. `Backup.bat` looks for a configuration file: `backup-settings-for-%computername%.bat`, that controls what directories to back up, how long the backups are kept for, how often to run the scheduled task etc.
    1. This file will actually be the target of a `symbolic link` created by the [Windows command mklink](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/mklink).
    2. Whenever I swap between projects, I run the `launcher script` which changes the `configuration script` targeted by the `symbolic link` and then runs the backup script once.
2. Under this approach, I will create a pair of batch scripts per project I want to work on.
    1. A `project specific configuration` file as defined earlier: [How to set up the script](README.md#how-to-set-up-the-script), but with a different name.
        1. The name of the configuration file reflects the project and computer name: `backup-settings-for-%computername%_Magical-Project-X.bat`
        2. I always ensure that each configuration file has the same value for `SCHED_TASK_LABEL`, so that any time I (re)schedule the task, it will always use the same name. Otherwise you will end up with a scheduled task for each configuration file: each with a different name but running the same script.
    2. A `launcher script` that sets the `configuration script` this as the new configuration for `Backup.bat` and runs `Backup.bat` once. Sample version of this file:

        ```bat
        @ECHO OFF

        cd /D %HOMEPATH%\myApps\Windows-Backup-Script
        del backup-settings-for-%computername%.bat
        mklink backup-settings-for-%computername%.bat backup-settings-for-%computername%_Magical-Project-X.bat
        call Backup.bat
        ```

        1. The name of this script reflects the project and computer name, e.g.: `backup Magical-Project-X on %computername%.bat`
        2. Note that this script runs the [Windows command mklink](https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/mklink) and as such must be run as an administrator.
3. Whenever I want to change projects, I run the `launcher script` as an administrator.

## Use a launcher app

It is fiddly to have to navigate to the `Windows-Backup-Script` folder in `Windows Explorer`, right click on the correct `launcher script` and select `Run as Administrator`.

Instead, run a Windows launcher app such as [Launchy](https://www.launchy.net/) (which sadly seems dead as of 2020) or my personal favourite [Keypirinha](https://keypirinha.com/) or google "`Windows launchers`". Launcher apps are set up to monitor and index a set of a directories you control for a set of specific file extensions that you control. Open the launcher, type a file name or part of it.. drill down through the options shown and select the file you want to launch.

This way I just start typing "back up" and I will see all the `launcher script`s I created for the different projects I work on.

Tips for **Keypirinha**.

1. Ensure that [Keypirinha](https://keypirinha.com/) looks at the directory where these batch scripts are stored.
2. Use Keypirinha to run the launcher scripts, e.g.: `backup Magical-Project-X`.
    1. MUST open this entry (`control + enter`) and select `Open as Administrator`. This is needed because the script tries to create a link (via `mklink`), which can only be done as admin.
