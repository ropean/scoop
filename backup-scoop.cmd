@echo off
REM -----------------------------------------------------------------------------
REM Backup Scoop configuration, installed apps, and buckets to scoop-meta.json
REM The exported file will include config, apps, and buckets sections.
REM -----------------------------------------------------------------------------

REM Define the backup directory as the directory where this script is located
set "backupDir=%~dp0"

REM Remove trailing backslash if present
if "%backupDir:~-1%"=="\" set "backupDir=%backupDir:~0,-1%"

REM Set the export file path to 'scoop-meta.json' inside the backup directory
set "exportFile=%backupDir%\scoop-meta.json"

REM Export Scoop configuration, installed apps, and buckets to the JSON file
REM The '-c' flag ensures credentials are included in the export
scoop export -c > "%exportFile%"

REM Check if the command was successful
if %errorlevel% equ 0 (
    echo ✓ Scoop export completed successfully.
    echo Backup file saved to: %exportFile%
) else (
    echo ✗ Scoop export failed with error code %errorlevel%
    exit /b %errorlevel%
)

REM Tips:
REM - You can restore your Scoop setup using: scoop import "%exportFile%"
REM - Keep the backup file in a safe location to avoid loss of your app list and settings