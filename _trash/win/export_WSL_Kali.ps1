#C:\Users\Pavel>winget install --id Git.Git -e --source winget
#C:\Users\Pavel>winget install --id Microsoft.PowerShell --source winget
#Found PowerShell [Microsoft.PowerShell] Version 7.4.1.0

param(
    [string]$wslDistribution = "kali-linux",
    [string]$outFile,
    [string]$oldFile
)

# Check if outFile parameter is provided
if (-not $outFile) {
    Write-Host "Please provide the export path using -outFile parameter."
    Exit 1
}
# Check if oldFile parameter is provided and file exists
if ($oldFile -and -not (Test-Path $oldFile)) {
    Write-Host "Please provide the old tar filename using -oldFile parameter."
    Exit 1
}

# Build the WSL export command
$exportCommand = "wsl.exe --export $wslDistribution $outFile"

# Execute the export command
Invoke-Expression -Command $exportCommand

# Check the exit code
if ($LASTEXITCODE -ne 0) {
    Write-Host "Export failed with exit code $LASTEXITCODE."
    Exit 2
} else {
    Write-Host "Export completed. The tar file is located at: $outFile"
}

#TODO
#xdelta.exe -e -s $oldFile $outFile $oldFile-$outFile.xdelta 
