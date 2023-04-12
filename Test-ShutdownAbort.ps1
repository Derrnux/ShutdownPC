<#
Author: Dagh Zeppenfeld
Version: 12.04.2023
#>

<#

Code that impelments this in the ShutdownPC.ps1 script:

if($config.shutdownCountdown) {
        $countdownTime = $config.shutdownCountdownTimeSeconds

        $millisecondsToWait = (($config.shutdownWarningTimeSeconds) - $countdownTime) * 1000
        for ($i = 0; $i -lt $millisecondsToWait; $i += 100) {
            Start-Sleep -Milliseconds 100

            
            if ($Host.UI.RawUI.KeyAvailable) {
                # Clear the key buffer
                while ($Host.UI.RawUI.KeyAvailable) {
                    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                }
                
                Write-Host "Shutdown aborted." -ForegroundColor Green
                Write-Host "Press 'ENTER' to exit." -ForegroundColor White
                Read-Host
                Exit
            }
        }

        # Count down the last '$config.shutdownCountdownTimeSeconds' seconds
        for ($i = $countdownTime; $i -gt 0; $i--) {
            if($config.warningSound){
                [Console]::Beep($config.warningSoundFrequency, $config.warningSoundDurationMilliseconds)
            }
            Write-Host "Shutting down the PC in $i seconds. Press any key or close the window to Abort!" -ForegroundColor Red

            # Wait for 1 second with regular intervals to check if the user aborted the shutdown
            for ($j = 0; $j -lt 1000; $j += 100) {
                Start-Sleep -Milliseconds 100
                Test-ShutdownAbort
            }
        }
    }else{
        $millisecondsToWait = ($config.shutdownWarningTimeSeconds) * 1000
        for ($i = 0; $i -lt $millisecondsToWait; $i += 100) {
            Start-Sleep -Milliseconds 100
            Test-ShutdownAbort
        }
    }

#>

# Abort the shutdown process if a key is pressed (is called often during countdown)
function Test-ShutdownAbort {
    if ($Host.UI.RawUI.KeyAvailable) {
        # Clear the key buffer
        while ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }

        Write-Host "Shutdown aborted." -ForegroundColor Green
        Write-Host "Press 'ENTER' to exit." -ForegroundColor White
        Read-Host
        Exit
    }
}