# Module manifest for module 'ItSupportModule'

@{
    # Script module or binary module file associated with this manifest
    RootModule = 'ItSupportModule.psm1'

    # Version number of this module
    ModuleVersion = '0.0.1'

    # Supported PowerShell version
    PowerShellVersion = '5.1'

    # Name of the author
    Author = 'Bastiaan Geijtenbeek'

    # Company or vendor of the module
    CompanyName = 'GeijtenbeekIT'

    # Description of the module
    Description = 'A utility module with useful functions for desktop file management'

    # Functions to export from this module
    FunctionsToExport = @('Start-CustomTranscript', 'Stop-CustomTranscriptSuccess', 'Stop-CustomTranscriptError', 'Write-ToLog')

    # Cmdlets to export (if using binary modules, leave blank for now)
    CmdletsToExport = @()

    # Variables to export
    VariablesToExport = @()

    # Aliases to export
    AliasesToExport = @()

    # List of required modules
    RequiredModules = @()

    # Private data (useful for additional metadata)
    PrivateData = @{
        PSData = @{
            Tags = @('Utilities', 'Desktop', 'PowerShell', 'Scripting', 'Installation', 'Intune')
            LicenseUri = 'https://opensource.org/licenses/MIT'
            ProjectUri = 'https://github.com/bgeijtenbeek/ItSupportModule'
        }
    }
}
