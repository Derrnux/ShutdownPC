<#
Author: Dagh Zeppenfeld
Version: 11.04.2023
#>

# Test if a specific process is running
function Test-ProcessRunning {
    param(
        [Parameter(Mandatory=$true)]
        [int]$ProcessId
    )

    try {
        Get-Process -Id $ProcessId -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}