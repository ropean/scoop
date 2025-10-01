# -----------------------------------------------------------------------------
# Backup Scoop configuration, installed apps, and buckets to scoop-meta.json
# The exported file will include config, apps, and buckets sections.
# -----------------------------------------------------------------------------

# Define the backup directory as the directory where this script is located
$backupDir = $PSScriptRoot

# Set the export file path to 'scoop-meta.json' inside the backup directory
$exportFile = Join-Path $backupDir "scoop-meta.json"

# Export Scoop configuration, installed apps, and buckets to the JSON file
# The '-c' flag ensures credentials are included in the export
scoop export -c > $exportFile

# Output the path of the backup file and a success message
Write-Host "✓ Scoop export completed successfully." -ForegroundColor Green
Write-Host "Backup file saved to: $exportFile" -ForegroundColor Cyan

# Tips:
# - You can restore your Scoop setup using: scoop import $exportFile
# - Keep the backup file in a safe location to avoid loss of your app list and settings