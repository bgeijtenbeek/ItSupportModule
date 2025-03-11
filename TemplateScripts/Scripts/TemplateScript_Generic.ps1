#Standardized script template - Generic
#Created by Bastiaan Geijtenbeek
#Created on 11-MARCH-2025

####################################################################################
# ↓ DO NOT CHANGE THINGS IN THIS AREA. IT IS PART OF THE STANDARDIZED SCRIPT ↓
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
    Write-Host "Running as SYSTEM. Installing module system-wide..."
    $ModulePath = "$env:ProgramFiles\PowerShell\Modules\$ModuleName"
} elseif (Test-IsAdmin) {
    #Running as Administrator
    Write-Host "Running as Administrator. Installing module system-wide..."
    if ($PSVersionTable.PSEdition -eq "Core") {
        $ModulePath = "$env:ProgramFiles\PowerShell\Modules\$ModuleName"
    } else {
        $ModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\$ModuleName"
    }
} else {
    #Running as a regular user, set module installpath to user
    Write-Host "Running as regular user. Installing module to user profile..."
    $ModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\$ModuleName"
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
$CurrentVersion = Get-InstalledModuleVersion
$LatestVersion = Get-LatestGitHubVersion

Write-Host "Installed version: $CurrentVersion"
Write-Host "Latest available version: $LatestVersion"

if (-not $CurrentVersion -or $CurrentVersion -ne $LatestVersion) {
    Write-Host "Installing/Updating module to latest version..."
    Install-ModuleFromGitHub
} else {
    Write-Host "Module is already up to date."
}

#Import the module for immediate use
Import-Module $ModuleName -Force

if (Get-Module -Name $ModuleName) {
    Write-Host "Module has been imported."
}
else {
    Write-Host "Module has not been imported. Cannot continue."
    Exit 1
}

#Start custom transcript
$currentScriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
Start-CustomTranscript -scriptName $currentScriptName

try {
####################################################################################
# ↓ ADD YOUR CUSTOM SCRIPT HERE ↓
####################################################################################

<#Example of Write-ToLog (Write-Host information with custom markup)

Write-ToLog "Write-ToLog - Regular Test."
Write-ToLog -info "Write-ToLog - Info Test."
Write-ToLog -warning "Write-ToLog - Warning Test."
Write-ToLog -failure "Write-ToLog - Failure Test."
Write-ToLog -success "Write-ToLog - Success Test."
#>

####################################################################################
# ↑ END OF YOUR CUSTOM SCRIPT ↑
####################################################################################
# ↓ DO NOT CHANGE THINGS AFTER THIS LINE. IT IS PART OF THE STANDARDIZED SCRIPT ↓
####################################################################################
}
catch {
    Write-Host "ERROR: $_"
    Stop-CustomTranscriptError
}
Stop-CustomTranscriptSuccess