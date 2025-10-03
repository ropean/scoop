@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

rem =================================================================
rem Clean Brackets - Remove (number) patterns from filenames
rem Usage: Run this batch file in the target directory
rem =================================================================

rem Set current directory and log file
set "CURRENT_DIR=%CD%"
set "LOG_FILE=%CURRENT_DIR%\bracket-cleanup-log.txt"

rem Initialize log file with header
echo ============================================= > "!LOG_FILE!"
echo File Name Cleanup Log >> "!LOG_FILE!"
echo Date: %DATE% %TIME% >> "!LOG_FILE!"
echo Directory: !CURRENT_DIR! >> "!LOG_FILE!"
echo ============================================= >> "!LOG_FILE!"
echo. >> "!LOG_FILE!"

rem Initialize counters
set /a PROCESSED=0
set /a RENAMED=0
set /a ERRORS=0

echo Starting filename cleanup in current directory...
echo Log file: !LOG_FILE!
echo.

rem Loop through all files in current directory (excluding directories)
for %%F in (*) do (
    if not "%%F"=="clean-brackets.bat" (
        if not "%%F"=="bracket-cleanup-log.txt" (
            set "ORIGINAL_NAME=%%F"
            set "NEW_NAME=%%F"
            
            rem Remove (1), (2), (3), etc. patterns from filename
            set "NEW_NAME=!NEW_NAME:(1)=!"
            set "NEW_NAME=!NEW_NAME:(2)=!"
            set "NEW_NAME=!NEW_NAME:(3)=!"
            set "NEW_NAME=!NEW_NAME:(4)=!"
            set "NEW_NAME=!NEW_NAME:(5)=!"
            set "NEW_NAME=!NEW_NAME:(6)=!"
            set "NEW_NAME=!NEW_NAME:(7)=!"
            set "NEW_NAME=!NEW_NAME:(8)=!"
            set "NEW_NAME=!NEW_NAME:(9)=!"
            set "NEW_NAME=!NEW_NAME:(0)=!"
            
            rem Check if filename was changed
            if not "!ORIGINAL_NAME!"=="!NEW_NAME!" (
                rem Attempt to rename the file
                if exist "!NEW_NAME!" (
                    echo [SKIP] Target already exists: !ORIGINAL_NAME! -^> !NEW_NAME!
                    echo [SKIP] Target already exists: !ORIGINAL_NAME! -^> !NEW_NAME! >> "!LOG_FILE!"
                    set /a ERRORS+=1
                ) else (
                    ren "!ORIGINAL_NAME!" "!NEW_NAME!" 2>nul
                    if !ERRORLEVEL! EQU 0 (
                        echo [RENAMED] !ORIGINAL_NAME! -^> !NEW_NAME!
                        echo [RENAMED] !ORIGINAL_NAME! -^> !NEW_NAME! >> "!LOG_FILE!"
                        set /a RENAMED+=1
                    ) else (
                        echo [ERROR] Failed to rename: !ORIGINAL_NAME!
                        echo [ERROR] Failed to rename: !ORIGINAL_NAME! >> "!LOG_FILE!"
                        set /a ERRORS+=1
                    )
                )
            ) else (
                echo [NO CHANGE] !ORIGINAL_NAME!
                echo [NO CHANGE] !ORIGINAL_NAME! >> "!LOG_FILE!"
            )
            
            set /a PROCESSED+=1
        )
    )
)

rem Write summary to log
echo. >> "!LOG_FILE!"
echo ============================================= >> "!LOG_FILE!"
echo SUMMARY >> "!LOG_FILE!"
echo Total files processed: !PROCESSED! >> "!LOG_FILE!"
echo Files renamed: !RENAMED! >> "!LOG_FILE!"
echo Errors/Skipped: !ERRORS! >> "!LOG_FILE!"
echo ============================================= >> "!LOG_FILE!"

rem Display summary
echo.
echo ==============================================
echo CLEANUP COMPLETE
echo ==============================================
echo Total files processed: !PROCESSED!
echo Files successfully renamed: !RENAMED!
echo Errors/Skipped files: !ERRORS!
echo.
echo Log saved to: !LOG_FILE!
echo ==============================================

@REM pause