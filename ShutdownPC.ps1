<#------------------------------------------------------------------------------------
This script is designed to shut down the caller's PC at a specified time. 
It is the main script of the ShutdownPC project.

The PC is shut down using the 'Stop-Computer -Force' command, this requires administrative privileges.

Author: Dagh Zeppenfeld
Version: 12.04.2023
------------------------------------------------------------------------------------#>

# Include required files
$ScriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    . ("$ScriptDirectory\Set-WindowState.ps1")
    . ("$ScriptDirectory\Write-TempFiles.ps1")
    . ("$ScriptDirectory\Test-ProcessRunning.ps1")
    . ("$ScriptDirectory\Write-TimeRemainingInfo.ps1")
}
catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Error while loading supporting PowerShell Scripts." -ForegroundColor Red
    Write-Host "Press 'ENTER' to exit." -ForegroundColor White
    Read-Host
    Exit
}

# Read config.json file
$configFile = "$ScriptDirectory\config.json"
$config = Get-Content $configFile | ConvertFrom-Json


# Check if a process is already running. If yes, give info about shutdown time and time remaining.
$savedPID = Get-Content "$ScriptDirectory\temp\pid.txt"
if($savedPID) {
    if (Test-ProcessRunning -ProcessId $savedPID) {
        Write-TimeRemainingInfo
        $processRunning = $true
    }else{
        Write-TempFiles -processID "" -shutdownTime ""
    }
}

# Check if running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires a Powershell with administrative privileges to run." -ForegroundColor Red
    Write-Host "Press 'ENTER' to exit." -ForegroundColor White
    Read-Host
    Exit
}

# Only if no other shutdown process is running
if ($processRunning) {
    # Give the User three options: Change, Abort or Continue
    Write-Host "Please choose between the following options:" -ForegroundColor Yellow -NoNewline
    Write-Host " | (arrow-keys = up & down, ENTER = select)" -ForegroundColor White

    $options = @("[1: CHANGE TIME]", "[2: CANCEL SHUTDOWN]", "[3: PROCEED]")
    $selectedIndex = 0

    do {
        for ($i = 0; $i -lt $options.Length; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host ("-> {0}" -f $options[$i]) -ForegroundColor Green
            }
            else {
                Write-Host ("   {0}" -f $options[$i])
            }
        }

        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

        # Standard navigation with arrow keys (they have no character)
        switch ($key.VirtualKeyCode) {
            38 { $selectedIndex = [Math]::Max(0, $selectedIndex - 1) }
            40 { $selectedIndex = [Math]::Min($options.Length - 1, $selectedIndex + 1) }
        }

        # Additional navigation with further keys (they have a character)
        switch ($key.character) {
            'w' { $selectedIndex = [Math]::Max(0, $selectedIndex - 1) }
            's' { $selectedIndex = [Math]::Min($options.Length - 1, $selectedIndex + 1) }
            '1' { $selectedIndex = 0 }
            '2' { $selectedIndex = 1 }
            '3' { $selectedIndex = 2 }
        }

        # Selecting the current option
        if ($key.VirtualKeyCode -eq 13) { break }

        Clear-Host
        Write-TimeRemainingInfo
        Write-Host "Please choose between the following options:" -ForegroundColor Yellow -NoNewline
        Write-Host " | (arrow-keys = up & down, ENTER = select)" -ForegroundColor White

    } while ($true)

    # If the user doesn't want to change the shutdown time, exit the script and follow the user's alternative choice
    if($selectedIndex -ne 0) {
        Clear-Host
        if($selectedIndex -eq 1) {
            # Cancel the shutdown
            if (Test-ProcessRunning -ProcessId $savedPID) {
                Get-Process -ID $savedPID | Stop-Process -Force
                Write-Host "Shutdown cancelled." -ForegroundColor Green
            }else{
                Write-Host "The process $savedPID is not running anymore..." -ForegroundColor Yellow
            }
            Write-TempFiles -processID "" -shutdownTime ""
        }else{
            $savedShutdownTime = Get-Content "$ScriptDirectory\temp\shutdownTime.txt"
            Write-Host "Nothing changed. The PC will be shut down as before: " -NoNewline -ForegroundColor White
            Write-Host "->" $savedShutdownTime "<-" -ForegroundColor Black -BackgroundColor White
            Write-Host ""
        }
        Write-Host "Press 'ENTER' to exit." -ForegroundColor White
        Read-Host
        Exit
    }
}

# Let the user choose the shutdown time
$shutdownTimeParsed = $null
Clear-Host
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

# Check if another instance of this script is already running and save the new PID to a file
$ScriptPID = $PID
if($savedPID) {
    if (Test-ProcessRunning -ProcessId $savedPID) {
        Get-Process -ID $savedPID | Stop-Process -Force
    }
}
Write-TempFiles -processID $ScriptPID -shutdownTime (Get-Date).AddSeconds($shutdownTimeInSeconds).ToString("HH:mm:ss")

# Give the user info about the shutdown time
Clear-Host
Write-Host "The PC will be shut down at " -NoNewline
Write-Host "->" (Get-Date).AddSeconds($shutdownTimeInSeconds).ToString("HH:mm:ss") "<-" -ForegroundColor Black -BackgroundColor White
Write-Host ""
Write-Host "This window will be hidden in 10 seconds, unless you skip with 'ENTER'" -ForegroundColor Yellow
if($config.shutdownWarning) {
    Write-Host "It will be shown again "$config.shutdownWarningTimeSeconds" seconds before the shutdown." -ForegroundColor White
}

# Show the text for a maximum of 10 seconds. Skip if the user presses enter.
$millisecondsInWait = 0
for ($i = 100; $i -gt 0; $i--) {
    $millisecondsInWait += 100
    Start-Sleep -Milliseconds 100
    if ($Host.UI.RawUI.KeyAvailable) {
        $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        if ($key.VirtualKeyCode -eq 13) { break }
    }
}

# Hide the PowerShell window
Get-Process -ID $ScriptPID | Set-WindowState -State HIDE

if($config.shutdownWarning){
    # Wait until showing the window again. This is done to give the user a chance to abort the shutdown.
    Start-Sleep -Milliseconds ($shutdownTimeInSeconds * 1000 - ($millisecondsInWait) - (($config.shutdownWarningTimeSeconds) * 1000))
    Get-Process -ID $ScriptPID | Set-WindowState -State SHOW
    Clear-Host
    Write-Host "Shutting down the PC in "$config.shutdownWarningTimeSeconds" seconds. Close this window to abort!" -ForegroundColor Red

    # Wait until finally shutting down the PC after 30 seconds
    if($config.warningSound){
        [Console]::Beep($config.warningSoundFrequency, $config.warningSoundDurationMilliseconds)
    }

    if($config.shutdownCountdown) {
        $countdownTime = $config.shutdownCountdownTimeSeconds
        Start-Sleep -Seconds (($config.shutdownWarningTimeSeconds) - $countdownTime)

        # Count down the last '$config.shutdownCountdownTimeSeconds' seconds
        for ($i = $countdownTime; $i -gt 0; $i--) {
            if($config.warningSound){
                [Console]::Beep($config.warningSoundFrequency, $config.warningSoundDurationMilliseconds)
            }
            Write-Host "Shutting down the PC in $i seconds. Close this window to abort!" -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
        
    }else{
        Start-Sleep -Seconds ($config.shutdownWarningTimeSeconds)
    }
}else{
    Start-Sleep -Milliseconds (($shutdownTimeInSeconds) * 1000 - ($millisecondsInWait))
}


# Clear the temp files and shut down the PC
Write-TempFiles -processID "" -shutdownTime ""
Stop-Computer -Force
