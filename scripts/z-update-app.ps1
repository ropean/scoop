<#
.SYNOPSIS
    Update application version and hash in JSON manifest files

.DESCRIPTION
    This script updates the version and hash in a Scoop bucket application manifest.
    It automatically backs up the original file and updates version-related fields.

.PARAMETER app
    The name of the application (without .json extension)

.PARAMETER version
    The new version number to set

.PARAMETER hash
    The new hash value to set

.EXAMPLE
    ./z-update-app -app "flyenv" -version "1.2.3" -hash "a1b2c3d4e5f6..."

.EXAMPLE
    ./z-update-app "flyenv" "1.2.3" "abc123def456..."
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$app,
    
    [Parameter(Mandatory=$true)]
    [string]$version,
    
    [Parameter(Mandatory=$true)]
    [string]$hash
)

# Set error handling
$ErrorActionPreference = "Stop"

try {
    $bucketDir = "bucket"
    $jsonFile = Join-Path $bucketDir "$app.json"
    
    # Check if file exists
    if (-not (Test-Path $jsonFile)) {
        Write-Error "File $jsonFile does not exist"
        exit 1
    }
    
    # Read JSON file
    Write-Host "Reading $jsonFile..." -ForegroundColor Green
    $jsonContent = Get-Content $jsonFile -Raw -Encoding UTF8
    $jsonObj = $jsonContent | ConvertFrom-Json
    
    # Get original version
    $originVersion = $jsonObj.version
    Write-Host "Original version: $originVersion" -ForegroundColor Cyan
    
    # Backup original file - use Copy-Item instead of Rename-Item to avoid issues with special characters
    $backupFile = Join-Path $bucketDir "$app@$originVersion.json"
    Write-Host "Backing up original file to $backupFile..." -ForegroundColor Green
    Copy-Item -Path $jsonFile -Destination $backupFile -Force
    
    # Update version and hash
    $jsonObj.version = $version
    $jsonObj.hash = $hash
    
    # Update version in URL field if it exists
    if ($jsonObj.url) {
        $jsonObj.url = $jsonObj.url -replace "v[\d\.]+", "v$version" -replace "[\d\.]+\.exe", "$version.exe"
    }
    
    # Update version in pre_install section if it exists
    if ($jsonObj.pre_install) {
        $jsonObj.pre_install = $jsonObj.pre_install | ForEach-Object {
            $_ -replace "FlyEnv-Setup-[\d\.]+\.exe", "FlyEnv-Setup-$version.exe"
        }
    }
    
    # Write new JSON file
    Write-Host "Creating new $jsonFile..." -ForegroundColor Green
    $jsonObj | ConvertTo-Json -Depth 10 | Set-Content $jsonFile -Encoding UTF8
    
    Write-Host "`n✓ Completed!" -ForegroundColor Green
    Write-Host "  Original file backed up: $backupFile" -ForegroundColor Yellow
    Write-Host "  New version: $version" -ForegroundColor Yellow
    Write-Host "  New hash: $hash" -ForegroundColor Yellow
    
} catch {
    Write-Error "Error: $_"
    exit 1
}