# ShutdownPC
The code in this repository includes a windows powershell script that shuts down a PC at a desired time. 
The script can be used conveniently when creating a desktop shortcut.

By starting the script again, running timers can be checked, changed, and aborted.
Some features can be disabled or changed using the config.json file.

*You will need to allow PowerShell to run scripts and you will need to open the script with administrator rights for it to work.*

<sub>(Tested under Windows 11 Home - V.10.0.22621 Build 22621)</sub>

## Features
I will list some key features here:

+ __Ability to set a timer that shuts down the computer after a certain time__
+ Ability to check the progress of a running timer
+ Ability to edit or cancel running timers
+ Warning before shutdown (optionally with sound)
+ Offer some customizable settings

## Installation
I will try to explain the installation process as clear as possible. If you encounter any problems, feel free to contact me.

### Step 1
__Save the project on your PC. Remember the storage address.__

+ One way is with `git clone https://github.com/Derrnux/ShutdownPC.git` - if you have git installed (recommended)
+ Alternatively, you can download the .zip file and then unzip the files manually

### Step 2
__Allow PowerShell to run locally created scripts.__

1. Open the Windows Powershell as an administrator
2. Run the following command: `Set-ExecutionPolicy RemoteSigned`

Doing this may cause security issues on your PC. No guarantees!

If you experience problems using the scripts, you may need to use the `Set-ExecutionPolicy Unrestricted` command instead.
This is more dangerous, but can be used for testing purposes.

### Step 3 (Better Access)
__Creating a Desktop Shortcut.__

1. Go to the Windows desktop (or wherever you want the shortcut to be)
2. *Right-Click*, then *Click* __"New"__, then *Click* __"Shortcut"__
3. You are now prompted to specify a file path, use this format: 
   `'location of PowerShell.exe' 'location of *ShutdownPC.ps1* script'`

   Your link then should then look something like this:
   `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe C:\...\...\ShutdownPC\ShutdownPC.ps1`
4. Save your selection and name the shortcut. e.g. "ShutdownPC".
5. Save the shortcut.

6. Now *Right-Click*, then *Click* __"Properties"__
7. *Click* on __"Advanced"__, then check the box next to __"Run as administrator"__
   *Click* __"OK"__
8. Optionally, choose to always open the window maximized so it always fills the screen. 
   To do this select __"Maximized"__ from the drop-down menu next to __"Run"__
9. Now *Click* __"OK"__ again

*You will now have access to it from the Windows search bar as well. Try it out!*

## Use-Cases
+ Turn off your PC after watching a movie
    + *This is useful if you fall asleep easily and want to conserve battery power* ;)
+ Turn off the PC after finishing an update
    + *Not an optimal solution, but it will work if you know the time needed*

I am sure you will find more!

## Roadmap
I may develop more features in this small application:

1. Implement a script that automatically creates a desktop shortcut
2. GUI? I do like the simplicity of the current version so we will see

Got more ideas? Feel free to contact me!
