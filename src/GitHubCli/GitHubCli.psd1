@{
    ModuleVersion = '0.1.0'

    PrivateData = @{
        PSData = @{
            LicenseUri = 'https://github.com/chris-peterson/pwsh-github/blob/main/LICENSE'
            ProjectUri = 'https://github.com/chris-peterson/pwsh-github'
            Tags = @(
                'GitHub',
                'API',
                'REST',
                'DevOps',
                'Automation',
                'PowerShell',
                'Module',
                'PSEdition_Core',
                'Windows',
                'Linux',
                'MacOS'
            )
            ReleaseNotes =
@'
* Initial framing of readonly operations for issues, repositories, and pull requests
'@
        }
    }

    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    Author = 'Chris Peterson'
    CompanyName = 'Chris Peterson'
    Copyright = '(c) 2026'

    Description = 'Interact with GitHub via PowerShell'
    PowerShellVersion = '7.1'
    CompatiblePSEditions = @('Core')

    TypesToProcess = @('Types.ps1xml')
    FormatsToProcess = @('Formats.ps1xml')

    ScriptsToProcess = @(
        'Private/Functions/StringHelpers.ps1'
        'Private/Functions/ObjectHelpers.ps1'
        'Private/Functions/PaginationHelpers.ps1'
        'Private/Functions/GitHelpers.ps1'
        'Private/Globals.ps1'
    )

    NestedModules = @(
        'Config.psm1'
        'Issues.psm1'
        'PullRequests.psm1'
        'Repositories.psm1'
        'Utilities.psm1'
    )
    FunctionsToExport = @(
        # Configuration
        'Get-GitHubConfiguration'

        # Repositories
        'Get-GitHubRepository'

        # Issues
        'Get-GitHubIssue'

        # Pull Requests
        'Get-GitHubPullRequest'

        # Utilities
        'Invoke-GitHubApi'
    )
    AliasesToExport = @()
}
