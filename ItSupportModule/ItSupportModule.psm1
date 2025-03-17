############################################################################################################
# Function to start a transcript with custom naming and path parameters (for scripts)
############################################################################################################
function Start-ScriptTranscript {

    param (
        [string]$scriptName,
        [string]$runningContext,
        [string]$dateStamp
    )

    # Define custom scriptlog folder based on admin, user, or SYSTEM context and set scriptLogFolder accordingly
    if ($runningContext -eq "System") {
        # Running as SYSTEM account
        $scriptLogFolder = "$env:ProgramData\MWP\ScriptLogs\$scriptName"
    } elseif ($runningContext -eq "Admin") {
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
        [string]$appName,
        [string]$runningContext,
        [switch]$uninstall
    )

    # Define custom scriptlog folder based on admin, user, or SYSTEM context and set installLogFolder accordingly
    if ($runningContext -eq "System") {
        # Running as SYSTEM account
        $installLogFolder = "$env:ProgramData\MWP\InstallLogs\$appName"
    } elseif ($runningContext -eq "Admin") {
        # Running as an administrator
        $installLogFolder = "$env:ProgramData\MWP\InstallLogs\$appName"
    } else {
        # Running as a regular user
        $installLogFolder = "$env:LOCALAPPDATA\MWP\InstallLogs\$appName"
    }
    
    #Create logfolder if it doesn't exist yet
    $installLogPathCreated = $false
    if (!(Test-Path $installLogFolder)) {
        New-Item -ItemType Directory -Path $installLogFolder -Force | Out-Null
        $installLogPathCreated = $true
    }

    #Define variables used in the custom transcripts
    $dateStamp = Get-Date -Format "yyyyMMdd_HHmm"
    if($uninstall.IsPresent) {
    $logName = $appName + "_uninst_$dateStamp"        
    }
    else{
      $logName = $appName + "_inst_$dateStamp"  
    }
    $logName = $appName + "_inst_$dateStamp"
    $fullLogPath = Join-Path -Path $installLogFolder -ChildPath "$logname.log"

    #Start the custom named transcript
    Start-Transcript -Path "$fullLogPath" -Force -ErrorAction SilentlyContinue

    # Write log for creating log folder when it was just created.
    if ($installLogPathCreated) {
        Write-ToLog -info "Created logfolder $installLogFolder before starting the transcript because it did not exist yet."
    }

    #Return the $installLogFolder value that we have set here to the main script.
    return [PSCustomObject]@{
        installLogFolder = $installLogFolder
        dateStamp = $dateStamp
    }
}

##################################################################################################
# Function to install MSI and MST files
##################################################################################################
function Start-InstallMsi {
    param (
        [string]$appName,
        [string]$appVersion,
        [string]$dateStamp,
        [string]$msiFileName,
        [string]$installLogFolder,
        [string]$customArguments,
        [string]$scriptPath
    )

    $logMSI = "_inst_MSI_$dateStamp"
    $logNameMSI = $appName + $logMSI
    $fullMsiLogPath = Join-Path -Path $installLogFolder -ChildPath "$logNameMSI.log"

    Write-ToLog "##############################################################"
    Write-ToLog "Installing $appName application version $appVersion." 
    Write-ToLog "##############################################################"

    try{
        #Determine the script's current location (where the MSI resides)
        $msiPath = Join-Path -Path $scriptPath -ChildPath "$msiFileName"
        $defaultArguments = "/i `"$msiPath`" /qn /norestart /L*V `"$fullMsiLogPath`""
        if ($customArguments) {
            $arguments = $defaultArguments + " " + $customArguments
        }
        else {
            $arguments = $defaultArguments
        }

        # Start installation from .MSI
        Write-ToLog "Starting MSI installation. For details on that, check seperate log at $fullMsiLogPath."
        Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
        Write-ToLog -success "Installation has completed."
    }
    catch {
        #Error when something happens
        Write-ToLog -failure "An error occurred: $_"
        Stop-CustomTranscriptError
    }
}

##################################################################################################
# Function to uninstall MSI by help of the GUID
##################################################################################################
function Start-UninstallMsiGUID {
    param (
        [string]$appName,
        [string]$appVersion,
        [string]$dateStamp,
        [string]$msiFileName,
        [string]$installLogFolder,
        [string]$customArguments,
        [string]$scriptPath
    )

    $logMSI = "_uninst_MSI_$dateStamp"
    $logNameMSI = $appName + $logMSI
    $fullMsiLogPath = Join-Path -Path $installLogFolder -ChildPath "$logNameMSI.log"

    Write-ToLog "##############################################################"
    Write-ToLog "Installing $appName application version $appVersion." 
    Write-ToLog "##############################################################"

    try{
        #Determine the script's current location (where the MSI resides)
        $msiPath = Join-Path -Path $scriptPath -ChildPath "$msiFileName"
        $defaultArguments = "/i `"$msiPath`" /qn /norestart /L*V `"$fullMsiLogPath`""
        if ($customArguments) {
            $arguments = $defaultArguments + " " + $customArguments
        }
        else {
            $arguments = $defaultArguments
        }

        # Start installation from .MSI
        Write-ToLog "Starting MSI installation. For details on that, check seperate log at $fullMsiLogPath."
        Start-Process "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
        Write-ToLog -success "Installation has completed."
    }
    catch {
        #Error when something happens
        Write-ToLog -failure "An error occurred: $_"
        Stop-CustomTranscriptError
    }
}



#Export the functions so they are available when the module is imported
Export-ModuleMember -Function Start-ScriptTranscript, Stop-CustomTranscriptSuccess, Stop-CustomTranscriptError, Write-ToLog, Start-MsiTranscript, Start-InstallMsi, Start-UninstallMsiGUID