BeforeAll {
    Get-Module GithubCli -All | Remove-Module -Force -ErrorAction SilentlyContinue
    Import-Module $PSScriptRoot/../src/GithubCli/GitHubCli.psd1 -Force

    function New-PullRequest {
        param([hashtable] $Overrides = @{}, [string[]] $Without = @())
        $Payload = [ordered]@{
            id         = 4541821349
            number     = 17
            state      = 'closed'
            title      = 'Add utility commands'
            body       = 'Why this change exists.'
            draft      = $false
            html_url   = 'https://github.com/owner/repo/pull/17'
            url        = 'https://api.github.com/repos/owner/repo/pulls/17'
            user       = [PSCustomObject]@{ login = 'octocat' }
            merged_at  = '2026-09-19T06:03:46Z'
            created_at = '2026-09-15T21:40:50Z'
        }
        foreach ($Key in $Overrides.Keys) { $Payload[$Key] = $Overrides[$Key] }
        foreach ($Key in $Without) { $Payload.Remove($Key) }
        [PSCustomObject]$Payload | New-GithubObject 'Github.PullRequest'
    }
}

AfterAll {
    Remove-Module GithubCli -Force -ErrorAction SilentlyContinue
}

Describe 'Github.PullRequest contract properties' {

    It 'Should name its forge' {
        (New-PullRequest).Forge | Should -Be 'github'
    }

    It 'Should report the web host, not the API host' {
        (New-PullRequest).Host | Should -Be 'github.com'
    }

    It 'Should report the host of a GitHub Enterprise instance' {
        (New-PullRequest @{ html_url = 'https://ghe.example.com/owner/repo/pull/17' }).Host | Should -Be 'ghe.example.com'
    }

    It 'Should expose the body as Description' {
        (New-PullRequest).Description | Should -Be 'Why this change exists.'
    }

    It 'Should expose the author login as AuthorUsername' {
        (New-PullRequest).AuthorUsername | Should -Be 'octocat'
    }

    It 'Should report a merged pull request as merged' {
        (New-PullRequest).State | Should -Be 'merged'
    }

    It 'Should report a pull request closed without merging as closed' {
        (New-PullRequest @{ merged_at = $null }).State | Should -Be 'closed'
    }

    It 'Should report an open pull request as open' {
        (New-PullRequest @{ state = 'open'; merged_at = $null }).State | Should -Be 'open'
    }

    It 'Should report a merged pull request from the search API as merged' {
        # Search results nest merged_at under pull_request and carry no top-level merged_at.
        $Result = New-PullRequest @{ pull_request = [PSCustomObject]@{ merged_at = '2026-09-19T06:03:46Z' } } -Without merged_at
        $Result.State | Should -Be 'merged'
    }

    It 'Should use the number shown in the UI as Id' {
        (New-PullRequest).Id | Should -Be 17
    }

    It 'Should keep the API global id as DatabaseId' {
        (New-PullRequest).DatabaseId | Should -Be 4541821349
    }

    It 'Should keep PullRequestId as the number, for pipeline binding' {
        (New-PullRequest).PullRequestId | Should -Be 17
    }
}
