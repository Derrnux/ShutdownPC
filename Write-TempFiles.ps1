<#
Author: Dagh Zeppenfeld
Version: 11.04.2023
#>

# Write the PID and the shutdown time to a file
function Write-TempFiles ($processID, $shutdownTime) {
    $processID | Out-File -FilePath "$ScriptDirectory\temp\pid.txt" -Encoding ASCII -Force
    $shutdownTime | Out-File -FilePath "$ScriptDirectory\temp\shutdownTime.txt" -Encoding ASCII -Force
}