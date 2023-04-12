<#
Author: Dagh Zeppenfeld
Version: 12.04.2023
#>

# Print the time remaining and the shutdown time to the PowerShell window
function Write-TimeRemainingInfo {
    $savedShutdownTime = Get-Content "$ScriptDirectory\temp\shutdownTime.txt"
    $timeRemaining = (Get-Date $savedShutdownTime) - (Get-Date)
    $timeRemainingString = $timeRemaining.ToString("hh\:mm")

    Write-Host "A process is already running." -ForegroundColor Yellow
    Write-Host "The PC will be shut down at " -NoNewline
    Write-Host "->" $savedShutdownTime "<-" -ForegroundColor Black -BackgroundColor White -NoNewline
    Write-Host " | Time remaining: " -NoNewline
    if($timeRemaining.TotalSeconds -lt 0) {
        Write-Host "negative - shutdown not executed!" -ForegroundColor Red
    }else{
        Write-Host "->" $timeRemainingString "<-" -ForegroundColor Black -BackgroundColor White
    }
    Write-Host ""
}