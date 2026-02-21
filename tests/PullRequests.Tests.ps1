BeforeAll {
    Get-Module GitlabCli -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    function global:Invoke-GithubApi { param($HttpMethod, $Path, [hashtable]$Query, [hashtable]$Body, $MaxPages, $Accept) }
    function global:Resolve-GithubRepository { param($Repository) }
    function global:Resolve-GithubMaxPages { param($MaxPages, [switch]$All) }
    function global:New-GithubObject {
        param([Parameter(ValueFromPipeline)]$InputObject, [Parameter(Position=0)][string]$DisplayType)
        Begin{}
        Process {
            foreach ($item in $InputObject) {
                if ($item -is [hashtable]) { $item = [PSCustomObject]$item }
                $Wrapper = New-Object PSObject
                $item.PSObject.Properties | ForEach-Object {
                    $Wrapper | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
                }
                if ($DisplayType) { $Wrapper.PSTypeNames.Insert(0, $DisplayType) }
                Write-Output $Wrapper
            }
        }
        End{}
    }

    Import-Module $PSScriptRoot/../src/GithubCli/PullRequests.psm1 -Force
}

AfterAll {
    Remove-Module PullRequests -ErrorAction SilentlyContinue
    Remove-Item function:Invoke-GithubApi -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubRepository -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubMaxPages -ErrorAction SilentlyContinue
    Remove-Item function:New-GithubObject -ErrorAction SilentlyContinue
}

Describe 'New-GithubPullRequest' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ number = 1; title = 'Test PR'; state = 'open'; head = @{ ref = 'feature' }; base = @{ ref = 'main' } }
        } -ModuleName PullRequests
    }

    It 'Should call POST with correct path and body' {
        New-GithubPullRequest -Title 'Test PR' -SourceBranch 'feature' -TargetBranch 'main'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/pulls' -and
            $Body.title -eq 'Test PR' -and
            $Body.head -eq 'feature' -and
            $Body.base -eq 'main'
        }
    }

    It 'Should default TargetBranch to main' {
        New-GithubPullRequest -Title 'Test PR' -SourceBranch 'feature'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.base -eq 'main'
        }
    }

    It 'Should pass optional parameters when specified' {
        New-GithubPullRequest -Title 'Test PR' -SourceBranch 'feature' -Description 'PR body' -Draft -MaintainerCanModify

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.body -eq 'PR body' -and
            $Body.draft -eq $true -and
            $Body.maintainer_can_modify -eq $true
        }
    }

    It 'Should return a Github.PullRequest object' {
        $Result = New-GithubPullRequest -Title 'Test PR' -SourceBranch 'feature'
        $Result.PSTypeNames | Should -Contain 'Github.PullRequest'
    }

    It 'Should accept Head and Base aliases' {
        New-GithubPullRequest -Title 'Test PR' -Head 'feature' -Base 'develop'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.head -eq 'feature' -and
            $Body.base -eq 'develop'
        }
    }
}

Describe 'Update-GithubPullRequest' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ number = 42; title = 'Updated'; state = 'open' }
        } -ModuleName PullRequests
    }

    It 'Should call PATCH with correct path' {
        Update-GithubPullRequest 42 -Title 'Updated'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/pulls/42'
        }
    }

    It 'Should pass title in body' {
        Update-GithubPullRequest 42 -Title 'New Title'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.title -eq 'New Title'
        }
    }

    It 'Should pass description as body field' {
        Update-GithubPullRequest 42 -Description 'New description'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.body -eq 'New description'
        }
    }

    It 'Should pass state when specified' {
        Update-GithubPullRequest 42 -State 'closed'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.state -eq 'closed'
        }
    }

    It 'Should pass target branch as base' {
        Update-GithubPullRequest 42 -TargetBranch 'develop'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $Body.base -eq 'develop'
        }
    }

    It 'Should return a Github.PullRequest object' {
        $Result = Update-GithubPullRequest 42 -Title 'Updated'
        $Result.PSTypeNames | Should -Contain 'Github.PullRequest'
    }
}

Describe 'Merge-GithubPullRequest' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ number = 42; title = 'Test PR'; state = 'closed'; merged = $true; head = @{ ref = 'feature' } }
        } -ModuleName PullRequests
    }

    It 'Should call PUT to the merge endpoint' {
        Merge-GithubPullRequest 42

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PUT' -and
            $Path -eq 'repos/owner/repo/pulls/42/merge'
        }
    }

    It 'Should pass merge_method when specified' {
        Merge-GithubPullRequest 42 -MergeMethod squash

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PUT' -and
            $Body.merge_method -eq 'squash'
        }
    }

    It 'Should pass commit title and message' {
        Merge-GithubPullRequest 42 -CommitTitle 'feat: merge' -CommitMessage 'Details here'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PUT' -and
            $Body.commit_title -eq 'feat: merge' -and
            $Body.commit_message -eq 'Details here'
        }
    }

    It 'Should delete source branch when requested' {
        Merge-GithubPullRequest 42 -DeleteSourceBranch

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'repos/owner/repo/git/refs/heads/feature'
        }
    }

    It 'Should re-fetch the PR after merge' {
        Merge-GithubPullRequest 42

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/pulls/42'
        }
    }

    It 'Should return a Github.PullRequest object' {
        $Result = Merge-GithubPullRequest 42
        $Result.PSTypeNames | Should -Contain 'Github.PullRequest'
    }
}

Describe 'Close-GithubPullRequest' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ number = 42; title = 'Test PR'; state = 'closed' }
        } -ModuleName PullRequests
    }

    It 'Should call Update-GithubPullRequest which sends state closed' {
        Close-GithubPullRequest 42

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/pulls/42' -and
            $Body.state -eq 'closed'
        }
    }
}

Describe 'Get-GithubPullRequestComment' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 1; body = 'First comment' }
                [PSCustomObject]@{ id = 2; body = 'Second comment' }
            )
        } -ModuleName PullRequests
    }

    It 'Should call GET on the issues comments endpoint' {
        Get-GithubPullRequestComment 42

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/issues/42/comments'
        }
    }

    It 'Should return Github.Comment objects' {
        $Result = Get-GithubPullRequestComment 42
        $Result | Should -HaveCount 2
        $Result[0].PSTypeNames | Should -Contain 'Github.Comment'
    }
}

Describe 'New-GithubPullRequestComment' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName PullRequests
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 10; body = 'New comment' }
        } -ModuleName PullRequests
    }

    It 'Should call POST on the issues comments endpoint' {
        New-GithubPullRequestComment 42 -Body 'New comment'

        Should -Invoke Invoke-GithubApi -ModuleName PullRequests -Times 1 -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/issues/42/comments' -and
            $Body.body -eq 'New comment'
        }
    }

    It 'Should return a Github.Comment object' {
        $Result = New-GithubPullRequestComment 42 -Body 'New comment'
        $Result.PSTypeNames | Should -Contain 'Github.Comment'
    }
}
