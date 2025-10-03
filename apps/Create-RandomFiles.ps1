# Create-RandomFiles.ps1
# Creates 3-5 files with random names in the current directory

param (
    [string]$path = ".",
    [int]$count = 5
)

# Set the default working directory to the script's location
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $path -or $path -eq ".") {
    $path = $ScriptDir
}

# Resolve the provided or default path
try {
    $CURRENT_DIR = Resolve-Path $path -ErrorAction Stop
    Set-Location -Path $CURRENT_DIR
    Write-Host "Working directory set to: $($CURRENT_DIR.Path)" -ForegroundColor Yellow
} catch {
    Write-Host "Error: Invalid path '$path'" -ForegroundColor Red
    exit 1
}

# Validate the count parameter
if ($count -le 0) {
    Write-Host "Error: -count must be a positive integer." -ForegroundColor Red
    exit 1
}

# Function to generate random file names
function Get-RandomFileName {
    $prefixes = @("Report", "Document", "Data", "Backup", "Log", "Archive", "Config", "Settings")
    $suffixes = @(".txt", ".log", ".dat", ".cfg", ".tmp", ".bak")
    
    $prefix = $prefixes | Get-Random
    $suffix = $suffixes | Get-Random
    
    # 50% chance to include brackets with numbers
    if ((Get-Random -Maximum 2) -eq 0) {
        $randomNumber = Get-Random -Minimum 1 -Maximum 100
        return "$prefix ($randomNumber)$suffix"
    } else {
        return "$prefix$suffix"
    }
}

# Main script
try {
    Write-Host "Creating random files in current directory..." -ForegroundColor Green
    Write-Host "Current directory: $PWD" -ForegroundColor Yellow
    
    # Determine how many files to create (3-5)
    $fileCount = Get-Random -Minimum 3 -Maximum 6
    Write-Host "Creating $count files..." -ForegroundColor Cyan
    
    $createdFiles = @()
    
    for ($i = 1; $i -le $count; $i++) {
        $fileName = Get-RandomFileName
        
        # Ensure unique filename
        $counter = 1
        $originalName = $fileName
        while (Test-Path $fileName) {
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($originalName)
            $extension = [System.IO.Path]::GetExtension($originalName)
            $fileName = "${baseName}_$counter$extension"
            $counter++
        }
        
        # Create empty file
        New-Item -Path $fileName -ItemType File -Force | Out-Null
        $createdFiles += $fileName
        Write-Host "Created: $fileName" -ForegroundColor White
    }
    
    Write-Host "`nSuccessfully created $count files:" -ForegroundColor Green
    $createdFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
}

Write-Host "`nScript completed!" -ForegroundColor Green