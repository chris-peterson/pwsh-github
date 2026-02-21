BeforeAll {
    Get-Module GitlabCli, Issues, Comments -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    $global:_IssueTestHelpers = @(
        'ConvertTo-PascalCase', 'ConvertTo-SnakeCase', 'ConvertTo-UrlEncoded',
        'New-GithubObject', 'Add-CoalescedProperty',
        'Resolve-GithubMaxPages',
        'Resolve-GithubRepository', 'Get-GithubRemoteContext'
    )
    foreach ($fn in $global:_IssueTestHelpers) {
        $item = Get-Item "function:$fn" -ErrorAction SilentlyContinue
        if ($item) {
            Set-Item "function:global:$fn" $item.ScriptBlock
        }
    }
    function global:Invoke-GithubApi {
        param(
            [string] $HttpMethod,
            [string] $Path,
            [hashtable] $Query = @{},
            [hashtable] $Body = @{},
            [uint] $MaxPages = 1,
            [string] $Accept = 'application/vnd.github+json'
        )
    }

    Import-Module $PSScriptRoot/../src/GithubCli/Issues.psm1 -Force
    Import-Module $PSScriptRoot/../src/GithubCli/Comments.psm1 -Force
}

Describe "New-GithubIssue" {
    BeforeAll {
        Mock -ModuleName Issues Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Issues Invoke-GithubApi {
            [PSCustomObject]@{ number = 1; title = 'Test'; state = 'open'; html_url = 'https://github.com/owner/repo/issues/1' }
        }
    }

    It "Should POST to correct endpoint with title" {
        New-GithubIssue -Title 'Bug report'

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/issues' -and
            $Body.title -eq 'Bug report'
        }
    }

    It "Should include body when Description is provided" {
        New-GithubIssue -Title 'Bug' -Description 'Details here'

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $Body.title -eq 'Bug' -and
            $Body.body -eq 'Details here'
        }
    }

    It "Should include assignees and labels" {
        New-GithubIssue -Title 'Feature' -Assignees @('user1', 'user2') -Labels @('enhancement')

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $Body.assignees.Count -eq 2 -and
            $Body.assignees[0] -eq 'user1' -and
            $Body.labels[0] -eq 'enhancement'
        }
    }

    It "Should include milestone when MilestoneNumber is provided" {
        New-GithubIssue -Title 'Task' -MilestoneNumber 5

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $Body.milestone -eq 5
        }
    }

    It "Should return a Github.Issue object" {
        $Result = New-GithubIssue -Title 'Test'
        $Result.PSTypeNames | Should -Contain 'Github.Issue'
    }
}

Describe "Update-GithubIssue" {
    BeforeAll {
        Mock -ModuleName Issues Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Issues Invoke-GithubApi {
            [PSCustomObject]@{ number = 42; title = 'Updated'; state = 'open'; html_url = 'https://github.com/owner/repo/issues/42' }
        }
    }

    It "Should PATCH to correct endpoint" {
        Update-GithubIssue 42 -Title 'New title'

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/issues/42' -and
            $Body.title -eq 'New title'
        }
    }

    It "Should include state when provided" {
        Update-GithubIssue 42 -State closed

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $Body.state -eq 'closed'
        }
    }

    It "Should include description, assignees, labels, milestone" {
        Update-GithubIssue 42 -Description 'Updated body' -Assignees @('dev1') -Labels @('bug', 'urgent') -MilestoneNumber 3

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $Body.body -eq 'Updated body' -and
            $Body.assignees[0] -eq 'dev1' -and
            $Body.labels.Count -eq 2 -and
            $Body.milestone -eq 3
        }
    }

    It "Should return a Github.Issue object" {
        $Result = Update-GithubIssue 42 -Title 'Test'
        $Result.PSTypeNames | Should -Contain 'Github.Issue'
    }
}

Describe "Close-GithubIssue" {
    BeforeAll {
        Mock -ModuleName Issues Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Issues Invoke-GithubApi {
            [PSCustomObject]@{ number = 10; title = 'Closed'; state = 'closed'; html_url = 'https://github.com/owner/repo/issues/10' }
        }
    }

    It "Should PATCH with state closed" {
        Close-GithubIssue 10

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/issues/10' -and
            $Body.state -eq 'closed'
        }
    }

    It "Should support -WhatIf" {
        Close-GithubIssue 10 -WhatIf

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 0
    }
}

Describe "Open-GithubIssue" {
    BeforeAll {
        Mock -ModuleName Issues Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Issues Invoke-GithubApi {
            [PSCustomObject]@{ number = 10; title = 'Reopened'; state = 'open'; html_url = 'https://github.com/owner/repo/issues/10' }
        }
    }

    It "Should PATCH with state open" {
        Open-GithubIssue 10

        Should -Invoke -ModuleName Issues Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/issues/10' -and
            $Body.state -eq 'open'
        }
    }
}

Describe "Get-GithubIssueComment" {
    BeforeAll {
        Mock -ModuleName Comments Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Comments Resolve-GithubMaxPages { 10 }
        Mock -ModuleName Comments Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 101; body = 'First comment'; html_url = 'https://github.com/owner/repo/issues/1#issuecomment-101' }
                [PSCustomObject]@{ id = 102; body = 'Second comment'; html_url = 'https://github.com/owner/repo/issues/1#issuecomment-102' }
            )
        }
    }

    It "Should GET comments for the correct issue" {
        Get-GithubIssueComment 1

        Should -Invoke -ModuleName Comments Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/issues/1/comments'
        }
    }

    It "Should return Github.Comment objects" {
        $Results = Get-GithubIssueComment 1
        $Results | Should -HaveCount 2
        $Results[0].PSTypeNames | Should -Contain 'Github.Comment'
    }

    It "Should pass Since query parameter" {
        Get-GithubIssueComment 1 -Since '2024-01-01T00:00:00Z'

        Should -Invoke -ModuleName Comments Invoke-GithubApi -Times 1 -ParameterFilter {
            $Query.since -eq '2024-01-01T00:00:00Z'
        }
    }
}

Describe "New-GithubIssueComment" {
    BeforeAll {
        Mock -ModuleName Comments Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Comments Invoke-GithubApi {
            [PSCustomObject]@{ id = 201; body = 'New comment'; html_url = 'https://github.com/owner/repo/issues/5#issuecomment-201' }
        }
    }

    It "Should POST to correct endpoint with body" {
        New-GithubIssueComment 5 -Body 'This is a comment'

        Should -Invoke -ModuleName Comments Invoke-GithubApi -Times 1 -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/issues/5/comments' -and
            $Body.body -eq 'This is a comment'
        }
    }

    It "Should return a Github.Comment object" {
        $Result = New-GithubIssueComment 5 -Body 'Test'
        $Result.PSTypeNames | Should -Contain 'Github.Comment'
    }
}
