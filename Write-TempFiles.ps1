<#
Author: Dagh Zeppenfeld
Version: 20.02.2023
#>

# Write the PID and shutdownTime to a file
function Write-TempFiles ($processID, $shutdownTime) {
    $processID | Out-File -FilePath "$ScriptDirectory\temp\pid.txt" -Encoding ASCII -Force
    $shutdownTime | Out-File -FilePath "$ScriptDirectory\temp\shutdownTime.txt" -Encoding ASCII -Force
}

# Write the date of setting the shutdown time to a file
function Write-DateFile ($date) {
    $date | Out-File -FilePath "$ScriptDirectory\temp\shutdownDate.txt" -Encoding ASCII -Force
}
