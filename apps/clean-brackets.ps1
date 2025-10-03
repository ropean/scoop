<#
.SYNOPSIS
    Clean Brackets - Remove (number) patterns from filenames

.DESCRIPTION
    This script removes parentheses containing numbers only from the end of filename (before extension).
    Examples: 
    - "file (1).txt" becomes "file.txt"
    - "document (123).pdf" becomes "document.pdf"
    - "photo (42).jpg" becomes "photo.jpg"
    - "1-2(2) copy.txt" becomes "1-2(2) copy.txt" (NO CHANGE - parentheses not at the end)
    - "1-2(2).txt" becomes "1-2.txt"

.PARAMETER path
    The directory path to process (defaults to current directory)

.PARAMETER log
    The log file name (if specified, logs will be written to file)

.PARAMETER dryRun
    Shows what would be renamed without actually renaming files

.PARAMETER help
    Shows help information

.EXAMPLE
    .\clean-brackets.ps1
    # Processes current directory, output to console only

.EXAMPLE
    .\clean-brackets.ps1 -path "C:\MyFiles" -log "my-cleanup-log.txt"
    # Processes specified directory with log file

.EXAMPLE
    .\clean-brackets.ps1 -dryRun
    # Shows what would be renamed without actually renaming files

.EXAMPLE
    .\clean-brackets.ps1 -help
    # Shows help information

.NOTES
    Author: Ropean
    Date: 10/3/2025 12:46AM
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$path = ".",
    
    [Parameter(Mandatory=$false)]
    [string]$log,
    
    [Parameter(Mandatory=$false)]
    [switch]$dryRun,
    
    [Parameter(Mandatory=$false)]
    [switch]$help
)

function Show-Help {
    Write-Host @"
Clean Brackets - Remove (number) patterns from filenames

USAGE:
    .\clean-brackets.ps1 [OPTIONS]

OPTIONS:
    -path <directory>    Directory to process (default: current directory)
    -log <filename>      Log file name (if not specified, output to console only)
    -dryRun              Show what would be renamed without actually renaming
    -help                Show this help message

EXAMPLES:
    .\clean-brackets.ps1
    .\clean-brackets.ps1 -path "C:\MyFiles" -log "cleanup.log"
    .\clean-brackets.ps1 -dryRun
    .\clean-brackets.ps1 -help

"@ -ForegroundColor Cyan
}

# Show help if requested
if ($help) {
    Show-Help
    exit 0
}

# Set the default working directory to the script's location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $path -or $path -eq ".") {
    $path = $ScriptDir
}

# Resolve the provided or default path
try {
    $CURRENT_DIR = Resolve-Path $path -ErrorAction Stop
} catch {
    Write-Host "Error: Invalid path '$path'" -ForegroundColor Red
    Write-Host "Use -help for usage information" -ForegroundColor Yellow
    exit 1
}

$PROCESSED = 0
$RENAMED = 0
$ERRORS = 0

# Initialize log file if specified
if ($log) {
    $LOG_FILE = Join-Path $CURRENT_DIR.Path $log
    $logHeader = @"
=============================================
File Name Cleanup Log
Date: $(Get-Date)
Directory: $($CURRENT_DIR.Path)
=============================================

"@
    $logHeader | Out-File -FilePath $LOG_FILE -Encoding UTF8
}

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    
    Write-Host $Message -ForegroundColor $Color
    if ($log) {
        $Message | Out-File -FilePath $LOG_FILE -Append -Encoding UTF8
    }
}

Write-Log "Starting filename cleanup in directory: $($CURRENT_DIR.Path)" "Green"
if ($log) {
    Write-Log "Log file: $LOG_FILE" "Yellow"
}
if ($dryRun) {
    Write-Log "DRY RUN MODE - No files will be actually renamed" "Magenta"
}
Write-Log ""

# Get all files in the directory (excluding directories and the script/log files)
$excludeFiles = @("clean-brackets.ps1")
if ($log) { $excludeFiles += $log }

$files = Get-ChildItem -Path $CURRENT_DIR.Path -File | 
         Where-Object { $_.Name -notin $excludeFiles }

foreach ($file in $files) {
    $PROCESSED++
    $ORIGINAL_NAME = $file.Name
    $NEW_NAME = $ORIGINAL_NAME
    
    # Split filename and extension
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($ORIGINAL_NAME)
    $extension = [System.IO.Path]::GetExtension($ORIGINAL_NAME)
    
    # Remove parentheses with numbers only from the end of the base filename
    # This regex matches (digits) that are at the end of the base name (before extension)
    # and may have spaces before them
    $newBaseName = $baseName -replace '\s*\(\d+\)$', ''
    
    # Only update if base name was changed
    if ($baseName -ne $newBaseName) {
        $NEW_NAME = $newBaseName + $extension
        $NEW_NAME = $NEW_NAME.Trim()
        
        # Check if target file already exists
        $targetPath = Join-Path $file.DirectoryName $NEW_NAME
        
        if (Test-Path $targetPath) {
            Write-Log "[SKIP] Target already exists: $ORIGINAL_NAME -> $NEW_NAME" "Red"
            $ERRORS++
        } else {
            try {
                if ($dryRun) {
                    Write-Log "[DRY RUN] Would rename: $ORIGINAL_NAME -> $NEW_NAME" "Cyan"
                    $RENAMED++
                } else {
                    Rename-Item -Path $file.FullName -NewName $NEW_NAME -ErrorAction Stop
                    Write-Log "[RENAMED] $ORIGINAL_NAME -> $NEW_NAME" "Green"
                    $RENAMED++
                }
            } catch {
                Write-Log "[ERROR] Failed to rename: $ORIGINAL_NAME - $($_.Exception.Message)" "Red"
                $ERRORS++
            }
        }
    } else {
        Write-Log "[NO CHANGE] $ORIGINAL_NAME" "Gray"
    }
}

# Write summary
$summary = @"

=============================================
SUMMARY
Total files processed: $PROCESSED
Files renamed: $RENAMED
Errors/Skipped: $ERRORS
=============================================
"@

Write-Log $summary "Cyan"

if ($log) {
    $summary | Out-File -FilePath $LOG_FILE -Append -Encoding UTF8
}

# Display final summary
Write-Log "" "White"
Write-Log "=============================================" "Cyan"
Write-Log "CLEANUP COMPLETE" "Cyan"
Write-Log "=============================================" "Cyan"
Write-Log "Total files processed: $PROCESSED" "White"
Write-Log "Files successfully renamed: $RENAMED" "Green"
Write-Log "Errors/Skipped files: $ERRORS" "Red"
if ($log) {
    Write-Log "Log saved to: $LOG_FILE" "Yellow"
}
Write-Log "=============================================" "Cyan"

if ($dryRun) {
    Write-Log "`nNote: This was a dry run. No files were actually renamed." "Magenta"
}