<#------------------------------------------------------------------------------------
This script is designed to shut down the caller's PC at a specified time.

The PC is shut down using the 'Stop-Computer -Force' command.

Author: Dagh Zeppenfeld
Version: 11.04.2023
------------------------------------------------------------------------------------#>

# Include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\Set-WindowState.ps1")
    . ("$ScriptDirectory\Write-TempFiles.ps1")
    . ("$ScriptDirectory\Test-ProcessRunning.ps1")
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error while loading supporting PowerShell Scripts." -ForegroundColor Red
    Write-Host "The script will now exit!"
    Start-Sleep -Milliseconds 2500
    Exit
}

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges to run." -ForegroundColor Red
    Write-Host "Please run PowerShell as an administrator and try again."
    Start-Sleep -Milliseconds 2500
    Exit
}

# User Input Handeling
$shutdownTimeParsed = $null
while (!$shutdownTimeInSeconds) {
    $shutdownTime = Read-Host "After which time do you want to shutdown the PC? (format: HH:mm)"
    try {
        $shutdownTimeParsed = [datetime]::ParseExact($shutdownTime, "HH:mm", $null)
        $shutdownTimeInSeconds = $shutdownTimeParsed.TimeOfDay.TotalSeconds
    } catch {
        Write-Host "Incorrect time format ($shutdownTime). Please use the format HH:mm." -ForegroundColor Yellow
    }
    if($shutdownTimeInSeconds -eq 0) {
        Write-Host "The time must be in the future." -ForegroundColor Yellow
        $shutdownTimeInSeconds = $null
    }
}

# Give the user info about the shutdown time
Write-Host ""
Write-Host "The PC will be shut down at " -NoNewline
Write-Host "->" (Get-Date).AddSeconds($shutdownTimeInSeconds).ToString("HH:mm") "<-" -ForegroundColor Black -BackgroundColor White
Write-Host "This window will be hidden soon. It will be shown again 30 seconds before the shutdown."

# Check if another instance of this script is already running and save the new PID to a file
$ScriptPID = $PID
$savedPID = Get-Content "$ScriptDirectory\temp\pid.txt"
if($savedPID) {
    if (Test-ProcessRunning -ProcessId $savedPID) {
        Write-Host "Another instance of this script is already running. It will be closed now." -ForegroundColor Red
        Get-Process -ID $ScriptPID | Stop-Process -Force
    }
}
Write-TempFiles -processID $ScriptPID -shutdownTime (Get-Date).AddSeconds($shutdownTimeInSeconds).ToString("HH:mm")
Start-Sleep -Seconds 5

# Hide the PowerShell window
Get-Process -ID $ScriptPID | Set-WindowState -State HIDE

# Wait until showing the window again. This is done to give the user a chance to abort the shutdown.
Start-Sleep -Seconds ($shutdownTimeInSeconds-32)
Get-Process -ID $ScriptPID | Set-WindowState -State SHOW
Write-Host "Shutting down the PC in 30 seconds. Close this window to abort!" -ForegroundColor Red

# Wait until finally shutting down the PC after 30 seconds
[Console]::Beep(500, 80)
Start-Sleep -Seconds 20

# Count down the last 10 seconds
for ($i = 10; $i -gt 0; $i--) {
    [Console]::Beep(500, 80)
    Write-Host "Shutting down the PC in $i seconds. Close this window to abort!" -ForegroundColor Red
    Start-Sleep -Seconds 1
}

# Clear the temp files and shut down the PC
Write-TempFiles -processID "" -shutdownTime ""
Stop-Computer -Force
