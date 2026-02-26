@{
    ModuleVersion = '0.3.1'

    PrivateData = @{
        PSData = @{
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
Initial release
* Branches (Get, New, Remove)
* Commits (Get)
* Comments (Get, New)
* Events (Get)
* Issues (Get, New, Update, Close, Open)
* Labels (Get, New, Update, Remove)
* Members (Org Members, Repo Collaborators)
* Milestones (Get, New, Update, Remove)
* Organizations (Get)
* Pull Requests (Get, New, Update, Merge, Close, Comments)
* Releases (Get)
* Repositories (Get, New, Update, Remove)
* Search (Global, Per-Repository)
* Users (Get)
* Workflows (Get, Runs, Jobs, Logs, Start)
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
        'Branches.psm1'
        'Comments.psm1'
        'Commits.psm1'
        'Config.psm1'
        'Events.psm1'
        'Issues.psm1'
        'Labels.psm1'
        'Members.psm1'
        'Milestones.psm1'
        'Organizations.psm1'
        'PullRequests.psm1'
        'Releases.psm1'
        'Repositories.psm1'
        'Search.psm1'
        'Users.psm1'
        'Utilities.psm1'
        'Workflows.psm1'
    )
    FunctionsToExport = @(
        # Branches
        'Get-GithubBranch'
        'New-GithubBranch'
        'Remove-GithubBranch'

        # Comments
        'Get-GithubIssueComment'
        'New-GithubIssueComment'

        # Commits
        'Get-GithubCommit'

        # Configuration
        'Get-GithubConfiguration'

        # Events
        'Get-GithubEvent'

        # Issues
        'Get-GithubIssue'
        'New-GithubIssue'
        'Update-GithubIssue'
        'Close-GithubIssue'
        'Open-GithubIssue'

        # Labels
        'Get-GithubLabel'
        'New-GithubLabel'
        'Update-GithubLabel'
        'Remove-GithubLabel'

        # Members
        'Get-GithubOrganizationMember'
        'Add-GithubOrganizationMember'
        'Remove-GithubOrganizationMember'
        'Get-GithubRepositoryCollaborator'
        'Add-GithubRepositoryCollaborator'
        'Remove-GithubRepositoryCollaborator'

        # Milestones
        'Get-GithubMilestone'
        'New-GithubMilestone'
        'Update-GithubMilestone'
        'Remove-GithubMilestone'

        # Organizations
        'Get-GithubOrganization'

        # Pull Requests
        'Get-GithubPullRequest'
        'New-GithubPullRequest'
        'Update-GithubPullRequest'
        'Merge-GithubPullRequest'
        'Close-GithubPullRequest'
        'Get-GithubPullRequestComment'
        'New-GithubPullRequestComment'

        # Releases
        'Get-GithubRelease'

        # Repositories
        'Get-GithubRepository'
        'New-GithubRepository'
        'Update-GithubRepository'
        'Remove-GithubRepository'

        # Search
        'Search-Github'
        'Search-GithubRepository'

        # Users
        'Get-GithubUser'

        # Utilities
        'Invoke-GithubApi'

        # Workflows
        'Get-GithubWorkflow'
        'Get-GithubWorkflowRun'
        'Get-GithubWorkflowJob'
        'Get-GithubWorkflowRunLog'
        'Start-GithubWorkflowRun'
    )
    AliasesToExport = @()
}
