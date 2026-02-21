BeforeAll {
    Get-Module GitlabCli -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    function global:Invoke-GithubApi { param($HttpMethod, $Path, [hashtable]$Query = @{}, [hashtable]$Body = @{}, $MaxPages, $Accept) }
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
    function global:Get-FilteredObject {
        param([Parameter(ValueFromPipeline)]$InputObject, [Parameter(Position=0)][string]$Select)
        process { $InputObject }
    }

    Import-Module $PSScriptRoot/../src/GithubCli/Events.psm1 -Force
}

AfterAll {
    Remove-Module Events -ErrorAction SilentlyContinue
    Remove-Item function:Invoke-GithubApi -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubRepository -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubMaxPages -ErrorAction SilentlyContinue
    Remove-Item function:New-GithubObject -ErrorAction SilentlyContinue
    Remove-Item function:Get-FilteredObject -ErrorAction SilentlyContinue
}

Describe 'Get-GithubEvent' {
    It 'Should GET repo events by default' {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Events
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = '100'; type = 'PushEvent'; actor = @{ login = 'user1' }; repo = @{ name = 'owner/repo' }; created_at = '2025-01-15T10:00:00Z' }
                [PSCustomObject]@{ id = '101'; type = 'IssuesEvent'; actor = @{ login = 'user2' }; repo = @{ name = 'owner/repo' }; created_at = '2025-01-15T11:00:00Z' }
            )
        } -ModuleName Events

        $Result = Get-GithubEvent -RepositoryId 'owner/repo'
        $Result | Should -HaveCount 2
        $Result[0].PSTypeNames | Should -Contain 'Github.Event'

        Should -Invoke Invoke-GithubApi -ModuleName Events -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/events'
        }
    }

    It 'Should GET user events when Username is provided' {
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = '200'; type = 'PushEvent'; actor = @{ login = 'octocat' }; created_at = '2025-01-15T12:00:00Z' }
            )
        } -ModuleName Events

        $Result = Get-GithubEvent -Username 'octocat'
        $Result | Should -HaveCount 1

        Should -Invoke Invoke-GithubApi -ModuleName Events -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'users/octocat/events'
        }
    }

    It 'Should GET org events when Organization is provided' {
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = '300'; type = 'MemberEvent'; actor = @{ login = 'admin1' }; org = @{ login = 'my-org' }; created_at = '2025-01-15T13:00:00Z' }
            )
        } -ModuleName Events

        $Result = Get-GithubEvent -Organization 'my-org'
        $Result | Should -HaveCount 1

        Should -Invoke Invoke-GithubApi -ModuleName Events -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'orgs/my-org/events'
        }
    }

    It 'Should accept Org alias for Organization' {
        Mock Invoke-GithubApi { @() } -ModuleName Events

        Get-GithubEvent -Org 'my-org'

        Should -Invoke Invoke-GithubApi -ModuleName Events -ParameterFilter {
            $Path -eq 'orgs/my-org/events'
        }
    }
}
