############################################################################################################
# Function to start a transcript with custom naming and path parameters (for scripts)
############################################################################################################
function Start-ScriptTranscript {

    param (
        [string]$scriptName
    )

    # Check whether the script is running in admin, user, or SYSTEM context
    $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($windowsIdentity)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    # Check if the current user is SYSTEM
    $isSystem = $windowsIdentity.Name -eq "NT AUTHORITY\SYSTEM"

    # Define custom scriptlog folder based on admin, user, or SYSTEM context and set scriptLogFolder accordingly
    if ($isSystem) {
        # Running as SYSTEM account
        $scriptLogFolder = "$env:ProgramData\MWP\ScriptLogs\$scriptName"
    } elseif ($windowsPrincipal.IsInRole($adminRole)) {
        # Running as an administrator
        $scriptLogFolder = "$env:ProgramData\MWP\ScriptLogs\$scriptName"
    } else {
        # Running as a regular user
        $scriptLogFolder = "$env:LOCALAPPDATA\MWP\ScriptLogs\$scriptName"
    }
    
    #Create logfolder if it doesn't exist yet
    $scriptLogPathCreated = $false
    if (!(Test-Path $scriptLogFolder)) {
        New-Item -ItemType Directory -Path $scriptLogFolder -Force | Out-Null
        $scriptLogPathCreated = $true
    }

    #Define variables used in the custom transcript
    $dateStamp = Get-Date -Format "yyyyMMdd_HHmm"
    $logName = $scriptName + "_$dateStamp"
    $fullLogPath = Join-Path -Path $scriptLogFolder -ChildPath "$logname.log"

    #Start the custom named transcript
    Start-Transcript -Path "$fullLogPath" -Force -ErrorAction SilentlyContinue

    # Write log for creating log folder when it was just created.
    if ($scriptLogPathCreated) {
        Write-ToLog -info "Created logfolder $scriptLogFolder before starting the transcript because it did not exist yet."
    }
}

############################################################################################################
# Function to stop the custom transcript with a success message and exit code (for scripts)
############################################################################################################
function Stop-CustomTranscriptSuccess {
    Write-ToLog -success "Everything seems in order, script ran without any noticable issues."
    Write-Host "Exiting script.."
    Stop-Transcript
    Start-Sleep -Seconds 1
    Exit 0
}

############################################################################################################
# Function to stop the custom transcript with an error message and exit code (for scripts)
############################################################################################################
function Stop-CustomTranscriptError {
    Write-ToLog -failure "Something went wrong. Check the logs for further details or manually check the results on the device!"
    Write-Host "Exiting script.."
    Stop-Transcript
    Start-Sleep -Seconds 1
    Exit 1
}

############################################################################################################
# Function to write messages to host with custom formatting
############################################################################################################
function Write-ToLog {

    param (
        [switch]$info,
        [switch]$warning,
        [switch]$failure,
        [switch]$success,
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$CustomLogEntry
    )

    if ((-not $info.IsPresent) -and (-not $warning.IsPresent) -and (-not $failure.IsPresent) -and (-not $success.IsPresent)){
        Write-Host "$CustomLogEntry"    
    }
    if($info.IsPresent){
        Write-Host "ℹ️ - $CustomLogEntry" -ForegroundColor Cyan   
    }
    if($warning.IsPresent){
        Write-Host "⚠️ - $CustomLogEntry"-ForegroundColor Yellow       
    }
    if($failure.IsPresent){
        Write-Host "❌ - $CustomLogEntry" -ForegroundColor Red        
    }
    if($success.IsPresent){
        Write-Host "✅ - $CustomLogEntry" -ForegroundColor Green        
    } 
}

############################################################################################################
# Function to start a transcript with custom naming and path parameters (for .MSI installations)
############################################################################################################
function Start-MsiTranscript {

    param (
        [string]$scriptName
    )

    # Check whether the script is running in admin, user, or SYSTEM context
    $windowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $windowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($windowsIdentity)
    $adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator

    # Check if the current user is SYSTEM
    $isSystem = $windowsIdentity.Name -eq "NT AUTHORITY\SYSTEM"

    # Define custom scriptlog folder based on admin, user, or SYSTEM context and set scriptLogFolder accordingly
    if ($isSystem) {
        # Running as SYSTEM account
        $installLogFolder = "$env:ProgramData\MWP\InstallLogs\$scriptName"
    } elseif ($windowsPrincipal.IsInRole($adminRole)) {
        # Running as an administrator
        $installLogFolder = "$env:ProgramData\MWP\InstallLogs\$scriptName"
    } else {
        # Running as a regular user
        $installLogFolder = "$env:LOCALAPPDATA\MWP\InstallLogs\$scriptName"
    }
    
    #Create logfolder if it doesn't exist yet
    $installLogPathCreated = $false
    if (!(Test-Path $installLogFolder)) {
        New-Item -ItemType Directory -Path $installLogFolder -Force | Out-Null
        $installLogPathCreated = $true
    }

    #Define variables used in the custom transcript
    $dateStamp = Get-Date -Format "yyyyMMdd_HHmm"
    $logName = $scriptName + "_$dateStamp"
    $fullLogPath = Join-Path -Path $scriptLogFolder -ChildPath "$logname.log"

    #Start the custom named transcript
    Start-Transcript -Path "$fullLogPath" -Force -ErrorAction SilentlyContinue

    # Write log for creating log folder when it was just created.
    if ($installLogPathCreated) {
        Write-ToLog -info "Created logfolder $installLogFolder before starting the transcript because it did not exist yet."
    }
}

##################################################################################################
# Function to install MSI and MST files
##################################################################################################
function Start-MsiInstall {

}






#Export the functions so they are available when the module is imported
Export-ModuleMember -Function Start-ScriptTranscript, Stop-CustomTranscriptSuccess, Stop-CustomTranscriptError, Write-ToLog, Start-MsiTranscript, Start-MsiInstall