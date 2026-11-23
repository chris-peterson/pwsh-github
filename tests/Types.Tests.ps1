BeforeAll {
    # Other test files import Issues.psm1 and Repositories.psm1 on their own; a
    # mock aimed at -ModuleName would land on those stale copies instead of the
    # manifest's nested modules.
    Get-Module GitlabCli, GithubCli, Issues, PullRequests, Repositories -All | Remove-Module -Force -ErrorAction SilentlyContinue

    # The manifest loads Types.ps1xml, which declares each type's key properties.
    Import-Module $PSScriptRoot/../src/GithubCli/GitHubCli.psd1 -Force

    function New-ApiIssue {
        param([string] $Repo, [int] $Number)
        [PSCustomObject]@{
            number     = $Number
            html_url   = "https://github.com/$Repo/issues/$Number"
            updated_at = '2026-01-01T00:00:00Z'
        }
    }
}

AfterAll {
    Remove-Module GithubCli -Force -ErrorAction SilentlyContinue
}

Describe 'Key properties' {

    It 'Should group issues by repo, in reference order' {
        $Result = @(
            New-ApiIssue 'owner/zeta' 2
            New-ApiIssue 'owner/alpha' 10
            New-ApiIssue 'owner/zeta' 1
            New-ApiIssue 'owner/alpha' 7
        ) | New-GithubObject 'Github.Issue'

        $Result | ForEach-Object { "$($_.ProjectPath)#$($_.IssueId)" } |
            Should -Be @('owner/alpha#7', 'owner/alpha#10', 'owner/zeta#1', 'owner/zeta#2')
    }

    It 'Should group pull requests by repo, in reference order' {
        $Result = @(
            [PSCustomObject]@{ number = 9;  html_url = 'https://github.com/owner/beta/pull/9' }
            [PSCustomObject]@{ number = 12; html_url = 'https://github.com/owner/alpha/pull/12' }
            [PSCustomObject]@{ number = 3;  html_url = 'https://github.com/owner/alpha/pull/3' }
        ) | New-GithubObject 'Github.PullRequest'

        $Result | ForEach-Object { "$($_.ProjectPath)#$($_.PullRequestId)" } |
            Should -Be @('owner/alpha#3', 'owner/alpha#12', 'owner/beta#9')
    }

    It 'Should leave the reference and the url as GitHub has them' {
        $Issue = New-ApiIssue 'owner/repo' 7 | New-GithubObject 'Github.Issue'
        $Issue.IssueId | Should -Be 7
        $Issue.Url | Should -Be 'https://github.com/owner/repo/issues/7'
    }
}

Describe 'Get-GithubRepository ordering' {

    It 'Should list repositories by full name, ahead of their recent activity' {
        Mock -ModuleName Repositories Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 1; full_name = 'owner/charlie'; pushed_at = '2026-01-03T00:00:00Z' }
                [PSCustomObject]@{ id = 2; full_name = 'owner/alpha';   pushed_at = '2026-01-01T00:00:00Z' }
                [PSCustomObject]@{ id = 3; full_name = 'owner/bravo';   pushed_at = '2026-01-02T00:00:00Z' }
            )
        }

        Get-GithubRepository -Mine | ForEach-Object FullName |
            Should -Be @('owner/alpha', 'owner/bravo', 'owner/charlie')
    }
}

Describe 'Get-GithubIssue ordering' {

    BeforeAll {
        Mock -ModuleName Issues Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Issues Invoke-GithubApi {
            @(
                New-ApiIssue 'owner/repo' 5
                New-ApiIssue 'owner/repo' 2
                New-ApiIssue 'owner/repo' 9
            )
        }
    }

    It 'Should order by reference with no ordering asked for' {
        Get-GithubIssue | ForEach-Object IssueId | Should -Be @(2, 5, 9)
    }

    It 'Should keep the order the API returned when -Sort is given' {
        Get-GithubIssue -Sort updated | ForEach-Object IssueId | Should -Be @(5, 2, 9)
    }

    It 'Should keep the order the API returned when -Direction is given' {
        Get-GithubIssue -Direction asc | ForEach-Object IssueId | Should -Be @(5, 2, 9)
    }
}

Describe 'Get-GithubPullRequest ordering' {

    It 'Should group a cross-repo listing by repo, in reference order, each naming its own repo' {
        Mock -ModuleName PullRequests Invoke-GithubApi {
            if ($Path -eq 'user') { return [PSCustomObject]@{ login = 'me' } }
            [PSCustomObject]@{
                items = @(
                    [PSCustomObject]@{ number = 157;  repository_url = 'https://api.github.com/repos/chris-peterson/pwsh-gitlab'; html_url = 'https://github.com/chris-peterson/pwsh-gitlab/pull/157' }
                    [PSCustomObject]@{ number = 3533; repository_url = 'https://api.github.com/repos/AzureAD/identitymodel';      html_url = 'https://github.com/AzureAD/identitymodel/pull/3533' }
                    [PSCustomObject]@{ number = 51;   repository_url = 'https://api.github.com/repos/chris-peterson/pwsh-gitlab'; html_url = 'https://github.com/chris-peterson/pwsh-gitlab/pull/51' }
                )
            }
        }

        Get-GithubPullRequest -Mine | ForEach-Object { "$($_.RepositoryId)#$($_.PullRequestId)" } |
            Should -Be @('AzureAD/identitymodel#3533', 'chris-peterson/pwsh-gitlab#51', 'chris-peterson/pwsh-gitlab#157')
    }
}
