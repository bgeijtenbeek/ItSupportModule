#Standardized script template - Set Regkeys
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

#Start custom transcript
$currentScriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
$dateStamp = Get-Date -Format "yyyyMMdd_HHmm"
Start-ScriptTranscript -scriptName $currentScriptName -runningContext $runningContext -dateStamp $dateStamp

try {
####################################################################################
# ↓ ADD YOUR CUSTOM SCRIPT HERE ↓
####################################################################################

    #Define registry path
    $registryPathMachine = "HKLM:\SOFTWARE\Your\Custom\Key"

    #Define registry entries as an array of hashtables
    $registryEntriesMachine = @(
        @{ Name = "Example01"; Value = "Line of text"; Type = "String" },
        @{ Name = "Example02"; Value = "Some.other.data"; Type = "String" },
        @{ Name = "Example03"; Value = 1; Type = "DWord" },
        @{ Name = "Example04"; Value = 0; Type = "DWord" },
        @{ Name = "Example05"; Value = ""; Type = "String" },
        @{ Name = "Example06"; Value = "1"; Type = "String" }
    )

    #Check if the registry path exists, if not, create it
    if (-not (Test-Path $registryPathMachine)) {
        New-Item -Path $registryPathMachine -Force | Out-Null
        Write-ToLog -info "Created $registryPathMachine because it did not exist yet."
    }

    #Iterate through entries and set the properties
    foreach ($entry in $registryEntriesMachine) {
        $name = $entry.Name
        $value = $entry.Value
        $type = $entry.Type

        Set-ItemProperty -Path $registryPathMachine -Name $name -Value $value -Type $type
        Write-ToLog -success "Successfully set key ($registryPathMachine) property: $name with value: $value ($type)"
    }


    <# OR WHEN RUNNING IN USER CONTEXT TO SET HKCU VALUES

    #Define registry path
    $registryPathUser = "HKCU:\SOFTWARE\Your\Custom\Key"

    #Define registry entries as an array of hashtables
    $registryEntriesUser = @(
        @{ Name = "Example01"; Value = "Line of text"; Type = "String" },
        @{ Name = "Example02"; Value = "Some.other.data"; Type = "String" },
        @{ Name = "Example03"; Value = 1; Type = "DWord" },
        @{ Name = "Example04"; Value = 0; Type = "DWord" },
        @{ Name = "Example05"; Value = ""; Type = "String" },
        @{ Name = "Example06"; Value = "1"; Type = "String" }
    )

    #Check if the registry path exists, if not, create it
    if (-not (Test-Path $registryPathUser)) {
        New-Item -Path $registryPathUser -Force | Out-Null
        Write-ToLog -info "Created $registryPathUser because it did not exist yet."
    }

    #Iterate through entries and set the properties
    foreach ($entry in $registryEntriesUser) {
        $name = $entry.Name
        $value = $entry.Value
        $type = $entry.Type

        Set-ItemProperty -Path $registryPathUser -Name $name -Value $value -Type $type
        Write-ToLog -success "Successfully set key ($registryPathUser) property: $name with value: $value ($type)"
    }

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