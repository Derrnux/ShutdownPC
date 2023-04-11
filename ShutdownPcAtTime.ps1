<#------------------------------------------------------------------------------------
This script is designed to shut down the caller's PC at a specified time.

The PC is shut down using the 'Stop-Computer -Force' command.

Author: Dagh Zeppenfeld
Version: 11.04.2023
------------------------------------------------------------------------------------#>

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges to run." -ForegroundColor Red
    Write-Host "Please run PowerShell as an administrator and try again."
    Start-Sleep -Milliseconds 2500
    Exit
}

$shutdownTimeParsed = $null

# User Input Handeling
while (!$shutdownTimeInSeconds) {
    $shutdownTime = Read-Host "After which time do you want to shutdown the PC? (format: HH:mm)"
    try {
        $shutdownTimeParsed = [datetime]::ParseExact($shutdownTime, "HH:mm", $null)
        $shutdownTimeInSeconds = $shutdownTimeParsed.TimeOfDay.TotalSeconds
    } catch {
        Write-Host "Incorrect time format ($shutdownTime). Please use the format HH:mm." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "The PC will be shut down at " -NoNewline
Write-Host "->" (Get-Date).AddSeconds($shutdownTimeInSeconds).ToString("HH:mm") "<-" -ForegroundColor Black -BackgroundColor White
Start-Sleep -Seconds $shutdownTimeInSeconds
Stop-Computer -Force
