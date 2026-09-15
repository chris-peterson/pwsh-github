BeforeAll {
    Get-Module GitlabCli -All | Remove-Module -Force -ErrorAction SilentlyContinue

    # The manifest is what wires the type data to the resolver: TypesToProcess
    # supplies the getters, ScriptsToProcess puts the resolver in the caller's
    # session state so any scope reading the property can reach it.
    Import-Module $PSScriptRoot/../src/GithubCli/GitHubCli.psd1 -Force

    function New-SearchShapePullRequest {
        param($Number = 7, $RepositoryId = 'owner/repo')
        [PSCustomObject]@{
            PSTypeName   = 'Github.PullRequest'
            Number       = $Number
            RepositoryId = $RepositoryId
        }
    }
}

AfterAll {
    Remove-Module GithubCli -Force -ErrorAction SilentlyContinue
}

Describe 'Pull request branch refs' {

    BeforeEach {
        $global:GithubPullRequestDetailByInstance = [System.Runtime.CompilerServices.ConditionalWeakTable[psobject, psobject]]::new()
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ number = 7; head = @{ ref = 'resolved-feature' }; base = @{ ref = 'master' } }
        }
    }

    It 'Should read the refs off the pulls-API shape without an extra call' {
        $Pr = [PSCustomObject]@{
            PSTypeName = 'Github.PullRequest'
            Head       = [PSCustomObject]@{ Ref = 'my-feature' }
            Base       = [PSCustomObject]@{ Ref = 'main' }
        }

        $Pr.SourceBranch | Should -Be 'my-feature'
        $Pr.TargetBranch | Should -Be 'main'
        Should -Invoke Invoke-GithubApi -Times 0 -Exactly
    }

    It 'Should resolve the refs for the search shape, which carries neither' {
        $Pr = New-SearchShapePullRequest

        $Pr.SourceBranch | Should -Be 'resolved-feature'
        $Pr.TargetBranch | Should -Be 'master'
    }

    It 'Should resolve once and reuse it across both properties' {
        $Pr = New-SearchShapePullRequest
        $null = $Pr.SourceBranch, $Pr.TargetBranch, $Pr.SourceBranch

        Should -Invoke Invoke-GithubApi -Times 1 -Exactly
    }

    It 'Should resolve again for a pull request fetched a second time' {
        $null = (New-SearchShapePullRequest).SourceBranch
        $null = (New-SearchShapePullRequest).SourceBranch

        # Keyed by the object, not by repo and number, so a later fetch reflects a
        # base branch that has been retargeted since the first one.
        Should -Invoke Invoke-GithubApi -Times 2 -Exactly
    }

    It 'Should fall back to ProjectPath when the search shape carries no RepositoryId' {
        $Pr = [PSCustomObject]@{
            PSTypeName = 'Github.PullRequest'
            Number     = 7
            HtmlUrl    = 'https://github.com/owner/repo/pull/7'
        }

        $Pr.SourceBranch | Should -Be 'resolved-feature'
        Should -Invoke Invoke-GithubApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'repos/owner/repo/pulls/7'
        }
    }

    It 'Should resolve a cross-repo result set against each repository in it' {
        $Prs = @(
            New-SearchShapePullRequest -Number 3533 -RepositoryId 'AzureAD/identitymodel'
            New-SearchShapePullRequest -Number 157  -RepositoryId 'chris-peterson/pwsh-gitlab'
        )

        $null = $Prs | ForEach-Object { $_.SourceBranch }

        Should -Invoke Invoke-GithubApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'repos/AzureAD/identitymodel/pulls/3533'
        }
        Should -Invoke Invoke-GithubApi -Times 1 -Exactly -ParameterFilter {
            $Path -eq 'repos/chris-peterson/pwsh-gitlab/pulls/157'
        }
    }

    It 'Should stay null rather than throw when there is nothing to resolve from' {
        $Pr = [PSCustomObject]@{ PSTypeName = 'Github.PullRequest'; Number = 7 }

        $Pr.SourceBranch | Should -BeNullOrEmpty
        $Pr.TargetBranch | Should -BeNullOrEmpty
        Should -Invoke Invoke-GithubApi -Times 0 -Exactly
    }

    It 'Should stay null rather than adopt a repository the caller matched earlier' {
        # $Matches resolves up the scope chain, so a getter that reads it after a
        # failed match reports whatever the caller matched last. A mixed-provider
        # caller reaches a Github.PullRequest holding a GitLab path -- a repository
        # the pull request could never belong to.
        'https://gitlab.example.com/group/team/project/-/merge_requests/9' -match '://[^/]+/(?<ProjectPath>.+?)/-/' | Out-Null
        $Matches.ProjectPath | Should -Be 'group/team/project'

        $Pr = [PSCustomObject]@{ PSTypeName = 'Github.PullRequest'; Number = 7 }

        $Pr.ProjectPath | Should -BeNullOrEmpty
        $Pr.SourceBranch | Should -BeNullOrEmpty
        Should -Invoke Invoke-GithubApi -Times 0 -Exactly
    }

    It 'Should warn rather than render an empty branch when the resolve is refused' {
        Mock Invoke-GithubApi { throw '401 Unauthorized' }
        $Pr = New-SearchShapePullRequest

        $Warning = $($null = $Pr.SourceBranch) 3>&1

        "$Warning" | Should -Match 'owner/repo#7'
        "$Warning" | Should -Match '401 Unauthorized'
    }

    It 'Should cache a refusal instead of retrying it on every read' {
        Mock Invoke-GithubApi { throw '401 Unauthorized' }
        $Pr = New-SearchShapePullRequest

        $null = ($Pr.SourceBranch, $Pr.TargetBranch, $Pr.SourceBranch) 3>$null

        Should -Invoke Invoke-GithubApi -Times 1 -Exactly
    }
}
