BeforeAll {
    Get-Module GitlabCli, Search -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    $global:_SearchTestHelpers = @(
        'ConvertTo-PascalCase', 'ConvertTo-SnakeCase', 'ConvertTo-UrlEncoded',
        'New-GithubObject', 'Add-CoalescedProperty',
        'Resolve-GithubMaxPages',
        'Resolve-GithubRepository', 'Get-GithubRemoteContext'
    )
    foreach ($fn in $global:_SearchTestHelpers) {
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

    Import-Module $PSScriptRoot/../src/GithubCli/Search.psm1 -Force
}

Describe "Search-Github" {
    BeforeEach {
        Mock -ModuleName Search Resolve-GithubMaxPages { 10 }
        Mock -ModuleName Search Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 1
                items = @([PSCustomObject]@{ id = 1; name = 'test' })
            }
        }
    }

    It "Should GET from search/code by default" {
        Search-Github 'hello world'

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'search/code' -and
            $Query.q -eq 'hello world'
        }
    }

    It "Should use the specified scope" {
        Search-Github 'my-repo' -Scope repositories

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $Path -eq 'search/repositories' -and
            $Query.q -eq 'my-repo'
        }
    }

    It "Should pass sort and direction" {
        Search-Github 'test' -Sort stars -Direction desc

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $Query.sort -eq 'stars' -and
            $Query.order -eq 'desc'
        }
    }

    It "Should expand .items from the response" {
        $Results = Search-Github 'test'
        $Results | Should -HaveCount 1
        $Results[0].Name | Should -Be 'test'
    }

    It "Should type results as Github.SearchResult for code scope" {
        $Results = Search-Github 'test' -Scope code
        $Results[0].PSTypeNames | Should -Contain 'Github.SearchResult'
    }

    It "Should type results as Github.Issue for issues scope" {
        Mock -ModuleName Search Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 1
                items = @([PSCustomObject]@{ id = 1; number = 42; title = 'Bug' })
            }
        }
        $Results = Search-Github 'bug' -Scope issues
        $Results[0].PSTypeNames | Should -Contain 'Github.Issue'
    }
}

Describe "Search-GithubRepository" {
    BeforeEach {
        Mock -ModuleName Search Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Search Resolve-GithubMaxPages { 10 }
        Mock -ModuleName Search Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 1
                items = @([PSCustomObject]@{ id = 1; name = 'match.py' })
            }
        }
    }

    It "Should append repo: qualifier to the query" {
        Search-GithubRepository 'TODO'

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $Query.q -eq 'TODO repo:owner/repo'
        }
    }

    It "Should default to code scope" {
        Search-GithubRepository 'TODO'

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $Path -eq 'search/code'
        }
    }

    It "Should support issues scope" {
        Search-GithubRepository 'bug' -Scope issues

        Should -Invoke -ModuleName Search Invoke-GithubApi -ParameterFilter {
            $Path -eq 'search/issues' -and
            $Query.q -eq 'bug repo:owner/repo'
        }
    }
}
