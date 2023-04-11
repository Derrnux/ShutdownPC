<#------------------------------------------------------------------------------------
This script is designed to shut down the caller's PC at a specified time. The process runs in the background.

Previously set shutdowns are deleted beforehand. The PC is shut down using the 'Stop-Computer -Force' command.

Author: Dagh Zeppenfeld
Version: 11.04.2023

Installation:
    1. Save the script to your PC. Take note of the storage address.
    2. Create a desktop shortcut with the format: 'Storage address of PowerShell.exe' 'Storage address of this script'
       The PowerShell is typically located at: 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
    3. Enable PowerShell to execute scripts. To do this,
       open PowerShell as an administrator and run the following command: 'Set-ExecutionPolicy RemoteSigned'
------------------------------------------------------------------------------------#>

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires administrative privileges to run." -ForegroundColor Red
    Write-Host "Please run PowerShell as an administrator and try again."
    Start-Sleep -Milliseconds 2500
    Exit
}

# Get all running Stop-Computer jobs and delete them
Get-Job -Command "Stop-Computer" | Remove-Job -Force

$shutdownTimeParsed = $null

while (!$shutdownTimeParsed) {
    $shutdownTime = Read-Host "When do you want to shutdown the PC? (format: HH:mm)"
    try {
        $shutdownTimeParsed = [datetime]::ParseExact($shutdownTime, "HH:mm", $null)
    } catch {
        Write-Host "Incorrect time format ($shutdownTime). Please use the format HH:mm." -ForegroundColor Yellow
    }
}

$job = Start-Job -ScriptBlock {
    Start-Sleep -Seconds ((New-TimeSpan -Start (Get-Date) -End $using:shutdownTimeParsed).TotalSeconds)
    Stop-Computer -Force
}

if ($job.State -eq 'Failed') {
    Write-Host ""
    Write-Host "Error creating job. The PC is NOT SHUT DOWN" -ForegroundColor Red
    Write-Host "The Program will now close, please try again."
    Start-Sleep -Milliseconds 2500
    Exit
} else {
    Write-Host ""
    Write-Host "Job created successfully." -ForegroundColor Green
    Write-Host "The PC will be shut down at " -NoNewline
    Write-Host "->" $shutdownTimeParsed.ToString("HH:mm") "<-" -ForegroundColor Black -BackgroundColor White
    Start-Sleep -Milliseconds 2500
    Exit
}