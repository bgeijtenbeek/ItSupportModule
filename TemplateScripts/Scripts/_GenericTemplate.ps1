#Standardized script template
#Created by Bastiaan Geijtenbeek
#Created on 05-MARCH-2025

####################################################################################
# ↓ DO NOT CHANGE THINGS IN THIS AREA. IT IS PART OF THE STANDARDIZED SCRIPT ↓
####################################################################################

#Add the module path to powershell
$env:PSModulePath += ";C:\Program Files\Powershell\Modules\"
#Verify Module installation
$moduleInstalled = Get-Module -ListAvailable | Where-Object { $_.Name -eq "ItSupportModule" }
if(!($moduleInstalled)){
    #Install-Module 
}
Import-Module MyUtilities

$currentScriptName = [System.IO.Path]::GetFileNameWithoutExtension($PSCommandPath)
Start-CustomTranscript -scriptName $currentScriptName

try {
####################################################################################
# ↓ ADD YOUR CUSTOM SCRIPT HERE ↓
####################################################################################

<# Example of Write-ToLog (Write-Host information with custom markup)

Write-ToLog "Write-ToLog - Regular Test."
Write-ToLog -info "Write-ToLog - Info Test."
Write-ToLog -warning "Write-ToLog - Warning Test."
Write-ToLog -failure "Write-ToLog - Failure Test."
Write-ToLog -success "Write-ToLog - Success Test."
#>

####################################################################################
# ↑ END OF YOUR CUSTOM SCRIPT ↑
# ↓ DO NOT CHANGE THINGS AFTER THIS LINE. IT IS PART OF THE STANDARDIZED SCRIPT ↓
####################################################################################
}
catch {
    Write-Host "ERROR: $_"
    Stop-CustomTranscriptError
}
Stop-CustomTranscriptSuccess