BeforeAll {
    Get-Module GitlabCli, Members -All | Remove-Module -Force -ErrorAction SilentlyContinue

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

    Import-Module $PSScriptRoot/../src/GithubCli/Members.psm1 -Force
}

AfterAll {
    Remove-Module Members -ErrorAction SilentlyContinue
    Remove-Item function:Invoke-GithubApi -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubRepository -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubMaxPages -ErrorAction SilentlyContinue
    Remove-Item function:New-GithubObject -ErrorAction SilentlyContinue
    Remove-Item function:Get-FilteredObject -ErrorAction SilentlyContinue
}

Describe 'Get-GithubOrganizationMember' {
    BeforeEach {
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 1; login = 'user1'; type = 'User'; html_url = 'https://github.com/user1' }
                [PSCustomObject]@{ id = 2; login = 'user2'; type = 'User'; html_url = 'https://github.com/user2' }
            )
        } -ModuleName Members
    }

    It 'Should GET org members list' {
        Get-GithubOrganizationMember -Organization 'my-org'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'orgs/my-org/members'
        }
    }

    It 'Should return Github.Member objects' {
        $Result = Get-GithubOrganizationMember -Organization 'my-org'
        $Result | Should -HaveCount 2
        $Result[0].PSTypeNames | Should -Contain 'Github.Member'
    }

    It 'Should pass role query parameter' {
        Get-GithubOrganizationMember -Organization 'my-org' -Role admin

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'orgs/my-org/members' -and
            $Query.role -eq 'admin'
        }
    }

    It 'Should check specific member when Username is provided' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; login = 'user1'; type = 'User'; html_url = 'https://github.com/user1' }
        } -ModuleName Members

        $Result = Get-GithubOrganizationMember -Organization 'my-org' -Username 'user1'
        $Result.login | Should -Be 'user1'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'orgs/my-org/members/user1'
        }
    }
}

Describe 'Add-GithubOrganizationMember' {
    BeforeEach {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ url = 'https://api.github.com/orgs/my-org/memberships/new-user'; role = 'member'; state = 'pending' }
        } -ModuleName Members
    }

    It 'Should PUT to memberships endpoint with default role' {
        Add-GithubOrganizationMember -Organization 'my-org' -Username 'new-user'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'PUT' -and
            $Path -eq 'orgs/my-org/memberships/new-user' -and
            $Body.role -eq 'member'
        }
    }

    It 'Should pass admin role when specified' {
        Add-GithubOrganizationMember -Organization 'my-org' -Username 'new-user' -Role admin

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $Body.role -eq 'admin'
        }
    }

    It 'Should return a Github.Member object' {
        $Result = Add-GithubOrganizationMember -Organization 'my-org' -Username 'new-user'
        $Result.PSTypeNames | Should -Contain 'Github.Member'
    }
}

Describe 'Remove-GithubOrganizationMember' {
    BeforeEach {
        Mock Invoke-GithubApi {} -ModuleName Members
    }

    It 'Should DELETE org member' {
        Remove-GithubOrganizationMember -Organization 'my-org' -Username 'old-user' -Confirm:$false

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'orgs/my-org/members/old-user'
        }
    }

    It 'Should support ShouldProcess' {
        $Cmd = Get-Command Remove-GithubOrganizationMember
        $Cmd.Parameters.Keys | Should -Contain 'WhatIf'
        $Cmd.Parameters.Keys | Should -Contain 'Confirm'
    }

    It 'Should not call API with -WhatIf' {
        Remove-GithubOrganizationMember -Organization 'my-org' -Username 'old-user' -WhatIf

        Should -Invoke Invoke-GithubApi -ModuleName Members -Times 0
    }
}

Describe 'Get-GithubRepositoryCollaborator' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Members
        Mock Invoke-GithubApi {
            @(
                [PSCustomObject]@{ id = 1; login = 'collab1'; permissions = @{ push = $true }; html_url = 'https://github.com/collab1' }
                [PSCustomObject]@{ id = 2; login = 'collab2'; permissions = @{ admin = $true }; html_url = 'https://github.com/collab2' }
            )
        } -ModuleName Members
    }

    It 'Should GET collaborators list' {
        Get-GithubRepositoryCollaborator -RepositoryId 'owner/repo'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/collaborators'
        }
    }

    It 'Should return Github.Member objects' {
        $Result = Get-GithubRepositoryCollaborator -RepositoryId 'owner/repo'
        $Result | Should -HaveCount 2
        $Result[0].PSTypeNames | Should -Contain 'Github.Member'
    }

    It 'Should pass affiliation query parameter' {
        Get-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Affiliation direct

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/collaborators' -and
            $Query.affiliation -eq 'direct'
        }
    }

    It 'Should check specific collaborator when Username is provided' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; login = 'collab1'; html_url = 'https://github.com/collab1' }
        } -ModuleName Members

        Get-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'collab1'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/collaborators/collab1'
        }
    }
}

Describe 'Add-GithubRepositoryCollaborator' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Members
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 1; repository = 'owner/repo'; invitee = @{ login = 'new-collab' }; permissions = 'push' }
        } -ModuleName Members
    }

    It 'Should PUT to collaborators endpoint with default permission' {
        Add-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'new-collab'

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'PUT' -and
            $Path -eq 'repos/owner/repo/collaborators/new-collab' -and
            $Body.permission -eq 'push'
        }
    }

    It 'Should pass admin permission when specified' {
        Add-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'new-collab' -Permission admin

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $Body.permission -eq 'admin'
        }
    }

    It 'Should return a Github.Member object' {
        $Result = Add-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'new-collab'
        $Result.PSTypeNames | Should -Contain 'Github.Member'
    }
}

Describe 'Remove-GithubRepositoryCollaborator' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Members
        Mock Invoke-GithubApi {} -ModuleName Members
    }

    It 'Should DELETE collaborator' {
        Remove-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'old-collab' -Confirm:$false

        Should -Invoke Invoke-GithubApi -ModuleName Members -ParameterFilter {
            $HttpMethod -eq 'DELETE' -and
            $Path -eq 'repos/owner/repo/collaborators/old-collab'
        }
    }

    It 'Should support ShouldProcess' {
        $Cmd = Get-Command Remove-GithubRepositoryCollaborator
        $Cmd.Parameters.Keys | Should -Contain 'WhatIf'
        $Cmd.Parameters.Keys | Should -Contain 'Confirm'
    }

    It 'Should not call API with -WhatIf' {
        Remove-GithubRepositoryCollaborator -RepositoryId 'owner/repo' -Username 'old-collab' -WhatIf

        Should -Invoke Invoke-GithubApi -ModuleName Members -Times 0
    }
}
