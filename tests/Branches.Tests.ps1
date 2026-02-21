BeforeAll {
    Get-Module GitlabCli -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    $global:_BranchTestHelpers = @(
        'ConvertTo-PascalCase', 'ConvertTo-SnakeCase', 'ConvertTo-UrlEncoded',
        'New-GithubObject', 'Add-CoalescedProperty',
        'Resolve-GithubMaxPages',
        'Resolve-GithubRepository', 'Get-GithubRemoteContext',
        'Get-FilteredObject'
    )
    foreach ($fn in $global:_BranchTestHelpers) {
        $item = Get-Item "function:$fn" -ErrorAction SilentlyContinue
        if ($item) {
            Set-Item "function:global:$fn" $item.ScriptBlock
        }
    }
    function global:Get-FilteredObject {
        param([Parameter(ValueFromPipeline)]$InputObject, [Parameter(Position=0)][string]$Select)
        process { $InputObject }
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

    Import-Module $PSScriptRoot/../src/GithubCli/Branches.psm1 -Force
}

Describe "New-GithubBranch" {
    BeforeAll {
        Mock -ModuleName Branches Resolve-GithubRepository { 'owner/my-repo' }
        Mock -ModuleName Branches Invoke-GithubApi {
            param($HttpMethod, $Path)
            switch -Wildcard ($Path) {
                'repos/*/git/ref/heads/*' {
                    [PSCustomObject]@{ object = @{ sha = 'abc123def456' } }
                }
                'repos/owner/my-repo' {
                    [PSCustomObject]@{ default_branch = 'main' }
                }
                'repos/*/git/refs' {
                    [PSCustomObject]@{ ref = 'refs/heads/feature-branch'; object = @{ sha = 'abc123def456' } }
                }
                'repos/*/branches/*' {
                    [PSCustomObject]@{ name = 'feature-branch'; commit = @{ sha = 'abc123def456' } }
                }
            }
        }
    }

    It "Should resolve SHA from default branch when no -Ref given" {
        New-GithubBranch -Name 'feature-branch'

        Should -Invoke Invoke-GithubApi -ModuleName Branches -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/my-repo'
        }
        Should -Invoke Invoke-GithubApi -ModuleName Branches -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/my-repo/git/ref/heads/main'
        }
    }

    It "Should resolve SHA from specified -Ref" {
        New-GithubBranch -Name 'feature-branch' -Ref 'develop'

        Should -Invoke Invoke-GithubApi -ModuleName Branches -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/my-repo/git/ref/heads/develop'
        }
    }

    It "Should POST to git/refs with correct body" {
        New-GithubBranch -Name 'feature-branch' -Ref 'main'

        Should -Invoke Invoke-GithubApi -ModuleName Branches -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/my-repo/git/refs' -and
            $Body.ref -eq 'refs/heads/feature-branch' -and
            $Body.sha -eq 'abc123def456'
        }
    }

    It "Should return a Github.Branch object" {
        $Result = New-GithubBranch -Name 'feature-branch' -Ref 'main'
        $Result.PSTypeNames | Should -Contain 'Github.Branch'
    }
}

Describe "Remove-GithubBranch" {
    BeforeAll {
        Mock -ModuleName Branches Resolve-GithubRepository { 'owner/my-repo' }
        Mock -ModuleName Branches Invoke-GithubApi {}
    }

    It "Should DELETE git/refs/heads/{branch}" {
        Remove-GithubBranch -BranchId 'feature-branch'

        Should -Invoke Invoke-GithubApi -ModuleName Branches -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'repos/owner/my-repo/git/refs/heads/feature-branch'
        }
    }

    It "Should support ShouldProcess" {
        $Cmd = Get-Command Remove-GithubBranch
        $Cmd.Parameters.Keys | Should -Contain 'WhatIf'
        $Cmd.Parameters.Keys | Should -Contain 'Confirm'
    }

    It "Should not call API with -WhatIf" {
        Remove-GithubBranch -BranchId 'feature-branch' -WhatIf

        Should -Invoke Invoke-GithubApi -ModuleName Branches -Times 0
    }
}
