# ShutdownPC
The code of this repository includes a windows powershell script that shutdowns a PC at a desired time. The script can be comfortably used when creating a desktop shortcut.

## Installation
    1. Save the script to your PC. Take note of the storage address.
    2. Create a desktop shortcut with the format: 'Storage address of PowerShell.exe' 'Storage address of this script'
       The PowerShell is typically located at: 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
    3. Enable PowerShell to execute scripts. To do this,
       open PowerShell as an administrator and run the following command: 'Set-ExecutionPolicy RemoteSigned'

## Use-Cases
    1. Turn off the PC after watching a Movie
    2. Turn off the PC after finishing an update (not optimal solution, but will work if you know the needed time)
    
    I am sure you will find more!
