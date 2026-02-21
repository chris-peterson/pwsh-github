BeforeAll {
    Get-Module GitlabCli, Repositories -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    $global:_RepoTestHelpers = @(
        'ConvertTo-PascalCase', 'ConvertTo-SnakeCase', 'ConvertTo-UrlEncoded',
        'New-GithubObject', 'Add-CoalescedProperty',
        'Resolve-GithubMaxPages',
        'Resolve-GithubRepository', 'Get-GithubRemoteContext',
        'Get-FilteredObject'
    )
    foreach ($fn in $global:_RepoTestHelpers) {
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

    Import-Module $PSScriptRoot/../src/GithubCli/Repositories.psm1 -Force
}

Describe "New-GithubRepository" {
    BeforeAll {
        Mock -ModuleName Repositories Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; name = 'new-repo'; full_name = 'owner/new-repo'; private = $false }
        }
    }

    It "Should POST to user/repos with name" {
        New-GithubRepository -Name 'new-repo'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'user/repos' -and
            $Body.name -eq 'new-repo'
        }
    }

    It "Should POST to orgs endpoint when -Organization is specified" {
        New-GithubRepository -Name 'org-repo' -Organization 'my-org'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'orgs/my-org/repos' -and
            $Body.name -eq 'org-repo'
        }
    }

    It "Should pass description in body" {
        New-GithubRepository -Name 'new-repo' -Description 'A test repo'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.description -eq 'A test repo'
        }
    }

    It "Should set private=true for private visibility" {
        New-GithubRepository -Name 'new-repo' -Visibility 'private'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.private -eq $true
        }
    }

    It "Should set private=false for public visibility" {
        New-GithubRepository -Name 'new-repo' -Visibility 'public'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.private -eq $false
        }
    }

    It "Should pass auto_init when -AutoInit is specified" {
        New-GithubRepository -Name 'new-repo' -AutoInit

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.auto_init -eq $true
        }
    }

    It "Should return a Github.Repository object" {
        $Result = New-GithubRepository -Name 'new-repo'
        $Result.PSTypeNames | Should -Contain 'Github.Repository'
        $Result.Name | Should -Be 'new-repo'
    }
}

Describe "Update-GithubRepository" {
    BeforeAll {
        Mock -ModuleName Repositories Resolve-GithubRepository { 'owner/my-repo' }
        Mock -ModuleName Repositories Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; name = 'my-repo'; full_name = 'owner/my-repo'; private = $false }
        }
    }

    It "Should PATCH repos/{owner}/{repo}" {
        Update-GithubRepository -RepositoryId 'owner/my-repo' -Description 'Updated'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/my-repo' -and
            $Body.description -eq 'Updated'
        }
    }

    It "Should pass name in body when renaming" {
        Update-GithubRepository -RepositoryId 'owner/my-repo' -Name 'renamed-repo'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.name -eq 'renamed-repo'
        }
    }

    It "Should pass default_branch in body" {
        Update-GithubRepository -RepositoryId 'owner/my-repo' -DefaultBranch 'develop'

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.default_branch -eq 'develop'
        }
    }

    It "Should set archived=true when -Archived is specified" {
        Update-GithubRepository -RepositoryId 'owner/my-repo' -Archived

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $Body.archived -eq $true
        }
    }

    It "Should return a Github.Repository object" {
        $Result = Update-GithubRepository -RepositoryId 'owner/my-repo' -Description 'Updated'
        $Result.PSTypeNames | Should -Contain 'Github.Repository'
    }
}

Describe "Remove-GithubRepository" {
    BeforeAll {
        Mock -ModuleName Repositories Resolve-GithubRepository { 'owner/my-repo' }
        Mock -ModuleName Repositories Invoke-GithubApi {}
    }

    It "Should DELETE repos/{owner}/{repo}" {
        Remove-GithubRepository -RepositoryId 'owner/my-repo' -Confirm:$false

        Should -Invoke Invoke-GithubApi -ModuleName Repositories -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'repos/owner/my-repo'
        }
    }

    It "Should require -RepositoryId (no default to '.')" {
        $Cmd = Get-Command Remove-GithubRepository
        $RepoParam = $Cmd.Parameters['RepositoryId']
        $MandatoryAttr = $RepoParam.Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
        $MandatoryAttr.Mandatory | Should -Be $true
    }

    It "Should support ShouldProcess" {
        $Cmd = Get-Command Remove-GithubRepository
        $Cmd.Parameters.Keys | Should -Contain 'WhatIf'
        $Cmd.Parameters.Keys | Should -Contain 'Confirm'
    }
}
