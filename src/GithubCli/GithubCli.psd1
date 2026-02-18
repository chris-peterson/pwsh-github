@{
    ModuleVersion = '0.1.0'

    PrivateData = @{
        PSData = @{
            Prerelease = 'alpha'
            LicenseUri = 'https://github.com/chris-peterson/pwsh-github/blob/main/LICENSE'
            ProjectUri = 'https://github.com/chris-peterson/pwsh-github'
            Tags = @(
                'Github',
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
Readonly support for
* Branches
* Releases
* Repositories
* Users
* Organizations
* Pull Requests
* Issues
* Comments
* Labels
* Milestones
'@
        }
    }

    GUID = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'

    Author = 'Chris Peterson'
    CompanyName = 'Chris Peterson'
    Copyright = '(c) 2026'

    Description = 'Interact with Github via PowerShell'
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
        'Branches.psm1'
        'Issues.psm1'
        'Organizations.psm1'
        'PullRequests.psm1'
        'Releases.psm1'
        'Repositories.psm1'
        'Users.psm1'
        'Utilities.psm1'
    )
    FunctionsToExport = @(
        # Configuration
        'Get-GithubConfiguration'

        # Branches
        'Get-GithubBranch'

        # Issues
        'Get-GithubIssue'

        # Organizations
        'Get-GithubOrganization'

        # Pull Requests
        'Get-GithubPullRequest'

        # Releases
        'Get-GithubRelease'

        # Repositories
        'Get-GithubRepository'

        # Users
        'Get-GithubUser'

        # Utilities
        'Invoke-GithubApi'
    )
    AliasesToExport = @()
}
