#Standardized script template - Generic
#Created by Bastiaan Geijtenbeek
#Created on 11-MARCH-2025

##############################################################################################
# ↓ DECLARE VARIABLES REQUIRED FOR THIS SCRIPT. NEEDS TO BE MODIFIED FOR EVERY INSTALLATION ↓
##############################################################################################

#Friendly app name, used for logging purposes. Single word. For example: FortiClientVPN, StorageExplorer, VlcMediaPlayer
$appName = "yourAppName"
#Version of the app you are installing, used for logging purposes only.
$appVersion = "xx.xx.xx"

####################################################################################
# ↓ DO NOT CHANGE - CHECK FOR AND INSTALLATION/UPDATE OF REQUIRED MODULE ↓
####################################################################################
$ModuleName = "ItSupportModule"
$GitHubRepo = "https://raw.githubusercontent.com/bgeijtenbeek/$ModuleName/main"
$ReleaseZip = "https://github.com/bgeijtenbeek/$ModuleName/releases/latest/download/$ModuleName.zip"
$TempZip = "$env:TEMP\$ModuleName.zip"

#Function to check if running as SYSTEM
function Test-IsSystem {
    return ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -eq "NT AUTHORITY\SYSTEM")
}

#Function to check if running as Admin
function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

#Determine where to install the module
if (Test-IsSystem) {
    #Running as SYSTEM (Intune or SCCM deployment)
    Write-Host "Running as SYSTEM. Using system-wide module."
    $ModulePath = "$env:ProgramFiles\PowerShell\Modules\$ModuleName"
    $runningContext = "System"
} elseif (Test-IsAdmin) {
    #Running as Administrator
    Write-Host "Running as Administrator. Using system-wide module."
    if ($PSVersionTable.PSEdition -eq "Core") {
        $ModulePath = "$env:ProgramFiles\PowerShell\Modules\$ModuleName"
        $runningContext = "Admin"
    } else {
        $ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"
        $runningContext = "Admin"
    }
} else {
    #Running as a regular user, set module installpath to user
    Write-Host "Running as regular user. Using user-installed module."
    $ModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\$ModuleName"
    $runningContext = "User"
}

#Function to get the installed module version
function Get-InstalledModuleVersion {
    if (Test-Path "$ModulePath\$ModuleName.psd1") {
        $ModuleManifest = Import-PowerShellDataFile "$ModulePath\$ModuleName.psd1"
        return $ModuleManifest.ModuleVersion
    }
    return $null
}

#Function to get the latest available version from GitHub
function Get-LatestGitHubVersion {
    try {
        $LatestVersion = Invoke-RestMethod -Uri "$GitHubRepo/ModuleVersion.txt"
        return $LatestVersion
    } catch {
        Write-Host "Failed to fetch latest version. Using installed version if available."
        return $null
    }
}

#Function to download and install the module
function Install-ModuleFromGitHub {
    Write-Host "Downloading module from GitHub..."
    Invoke-WebRequest -Uri $ReleaseZip -OutFile $TempZip

    if (Test-Path $ModulePath) {
        Remove-Item -Recurse -Force $ModulePath -ErrorAction SilentlyContinue
    }

    Expand-Archive -Path $TempZip -DestinationPath $ModulePath -Force
    Remove-Item $TempZip
}

#Main Logic
Write-Host "Looking for $ModuleName module.." 
$CurrentVersion = Get-InstalledModuleVersion
$LatestVersion = Get-LatestGitHubVersion

Write-Host "Installed version: $CurrentVersion"
Write-Host "Latest available version: $LatestVersion"

if (-not $CurrentVersion -or $CurrentVersion -ne $LatestVersion) {
    Write-Host "Installing/Updating module to latest version..."
    Install-ModuleFromGitHub
} else {
    Write-Host "Module $ModuleName is already up to date."
}

#Import the module for immediate use
Import-Module $ModuleName -Force

if (Get-Module -Name $ModuleName) {
    Write-Host "Module $ModuleName has been imported."
}
else {
    Write-Host "Module $ModuleName has not been imported. Cannot continue."
    Exit 1
}

####################################################################################
# ↓ DO NOT CHANGE - START CUSTOM TRANSCRIPT FOR THIS SCRIPT ↓
####################################################################################
$dateStamp = Get-Date -Format "yyyyMMdd_HHmm"
Start-MsiTranscript -appName $appName -dateStamp $dateStamp -runningContext $runningContext



try {
####################################################################################
# ↓ ADD YOUR CUSTOM SCRIPT HERE ↓
####################################################################################

    ########### PRE-INSTALLATION PHASE ###########



    ########### INSTALLATION PHASE (DO NOT CHANGE) ###########
    
    Write-Host "Testrun log entry"



    ########### POST-INSTALLATION PHASE ###########

    

####################################################################################
# ↓ DO NOT CHANGE - CATCH OUTCOME AND END CUSTOM TRANSCRIPT FOR THIS SCRIPT ↓
####################################################################################
}
catch {
    Write-Host "ERROR: $_"
    Stop-CustomTranscriptError
}
Stop-CustomTranscriptSuccess