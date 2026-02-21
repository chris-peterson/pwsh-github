BeforeAll {
    Get-Module GitlabCli, Labels -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    $global:_LabelTestHelpers = @(
        'ConvertTo-PascalCase', 'ConvertTo-SnakeCase', 'ConvertTo-UrlEncoded',
        'New-GithubObject', 'Add-CoalescedProperty',
        'Resolve-GithubMaxPages',
        'Resolve-GithubRepository', 'Get-GithubRemoteContext',
        'Get-FilteredObject'
    )
    foreach ($fn in $global:_LabelTestHelpers) {
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

    Import-Module $PSScriptRoot/../src/GithubCli/Labels.psm1 -Force
}

Describe "Get-GithubLabel" {
    BeforeEach {
        Mock -ModuleName Labels Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Labels Resolve-GithubMaxPages { 10 }
        Mock -ModuleName Labels Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 1; name = 'bug'; color = 'd73a4a'; description = 'Something is broken' }
                [PSCustomObject]@{ id = 2; name = 'enhancement'; color = 'a2eeef'; description = 'New feature' }
            )
        }
    }

    It "Should GET labels for the repository" {
        Get-GithubLabel

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/labels'
        }
    }

    It "Should GET a single label by name" {
        Mock -ModuleName Labels Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; name = 'bug'; color = 'd73a4a'; description = 'Something is broken' }
        }

        Get-GithubLabel 'bug'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/labels/bug'
        }
    }

    It "Should return Github.Label objects" {
        $Results = Get-GithubLabel
        $Results | Should -HaveCount 2
        $Results[0].PSTypeNames | Should -Contain 'Github.Label'
    }
}

Describe "New-GithubLabel" {
    BeforeEach {
        Mock -ModuleName Labels Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Labels Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; name = 'bug'; color = 'd73a4a'; description = 'Something is broken' }
        }
    }

    It "Should POST to correct endpoint with name and color" {
        New-GithubLabel -Name 'bug' -Color 'd73a4a'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/labels' -and
            $Body.name -eq 'bug' -and
            $Body.color -eq 'd73a4a'
        }
    }

    It "Should include description when provided" {
        New-GithubLabel -Name 'bug' -Color 'd73a4a' -Description 'Something is broken'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $Body.description -eq 'Something is broken'
        }
    }

    It "Should return a Github.Label object" {
        $Result = New-GithubLabel -Name 'bug' -Color 'd73a4a'
        $Result.PSTypeNames | Should -Contain 'Github.Label'
    }
}

Describe "Update-GithubLabel" {
    BeforeEach {
        Mock -ModuleName Labels Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Labels Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; name = 'feature'; color = '0075ca'; description = 'Feature request' }
        }
    }

    It "Should PATCH to correct endpoint" {
        Update-GithubLabel 'bug' -NewName 'feature'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'PATCH' -and
            $Path -eq 'repos/owner/repo/labels/bug' -and
            $Body.new_name -eq 'feature'
        }
    }

    It "Should include color and description when provided" {
        Update-GithubLabel 'bug' -Color '0075ca' -Description 'Feature request'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $Body.color -eq '0075ca' -and
            $Body.description -eq 'Feature request'
        }
    }

    It "Should return a Github.Label object" {
        $Result = Update-GithubLabel 'bug' -Color '0075ca'
        $Result.PSTypeNames | Should -Contain 'Github.Label'
    }
}

Describe "Remove-GithubLabel" {
    BeforeEach {
        Mock -ModuleName Labels Resolve-GithubRepository { 'owner/repo' }
        Mock -ModuleName Labels Invoke-GithubApi {}
    }

    It "Should DELETE the correct label" {
        Remove-GithubLabel 'bug'

        Should -Invoke -ModuleName Labels Invoke-GithubApi -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'repos/owner/repo/labels/bug'
        }
    }

    It "Should support ShouldProcess" {
        $Cmd = Get-Command Remove-GithubLabel
        $Cmd.Parameters.Keys | Should -Contain 'WhatIf'
        $Cmd.Parameters.Keys | Should -Contain 'Confirm'
    }

    It "Should not call API with -WhatIf" {
        Remove-GithubLabel 'bug' -WhatIf

        Should -Invoke -ModuleName Labels Invoke-GithubApi -Times 0
    }
}
