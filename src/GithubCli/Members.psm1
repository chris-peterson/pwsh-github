function Get-GithubOrganizationMember {
    [CmdletBinding()]
    [OutputType('Github.Member')]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter()]
        [string]
        $Username,

        [Parameter()]
        [ValidateSet('all', 'admin', 'member')]
        [string]
        $Role = 'all',

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [string]
        $Select
    )

    if ($Username) {
        # https://docs.github.com/en/rest/orgs/members#check-organization-membership-for-a-user
        try {
            Invoke-GithubApi GET "orgs/$Organization/members/$Username" |
                New-GithubObject 'Github.Member' |
                Get-FilteredObject $Select
        }
        catch {
            Write-Error "User '$Username' is not a member of organization '$Organization'"
        }
        return
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Role -and $Role -ne 'all') { $Query.role = $Role }

    # https://docs.github.com/en/rest/orgs/members#list-organization-members
    Invoke-GithubApi GET "orgs/$Organization/members" $Query -MaxPages $MaxPages |
        New-GithubObject 'Github.Member' |
        Get-FilteredObject $Select
}

function Add-GithubOrganizationMember {
    [CmdletBinding()]
    [OutputType('Github.Member')]
    param(
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter(Mandatory, Position=0)]
        [string]
        $Username,

        [Parameter()]
        [ValidateSet('admin', 'member')]
        [string]
        $Role = 'member'
    )

    $Body = @{
        role = $Role
    }

    # https://docs.github.com/en/rest/orgs/members#set-organization-membership-for-a-user
    Invoke-GithubApi PUT "orgs/$Organization/memberships/$Username" -Body $Body |
        New-GithubObject 'Github.Member'
}

function Remove-GithubOrganizationMember {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter(Mandatory, Position=0)]
        [string]
        $Username
    )

    if ($PSCmdlet.ShouldProcess("$Organization/$Username", 'Remove organization member')) {
        # https://docs.github.com/en/rest/orgs/members#remove-an-organization-member
        Invoke-GithubApi DELETE "orgs/$Organization/members/$Username"
    }
}

function Get-GithubRepositoryCollaborator {
    [CmdletBinding()]
    [OutputType('Github.Member')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter()]
        [string]
        $Username,

        [Parameter()]
        [ValidateSet('outside', 'direct', 'all')]
        [string]
        $Affiliation = 'all',

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [string]
        $Select
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($Username) {
        # https://docs.github.com/en/rest/collaborators/collaborators#check-if-a-user-is-a-repository-collaborator
        try {
            Invoke-GithubApi GET "repos/$Repo/collaborators/$Username" |
                New-GithubObject 'Github.Member' |
                Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
                Get-FilteredObject $Select
        }
        catch {
            Write-Error "User '$Username' is not a collaborator on '$Repo'"
        }
        return
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Affiliation -and $Affiliation -ne 'all') { $Query.affiliation = $Affiliation }

    # https://docs.github.com/en/rest/collaborators/collaborators#list-repository-collaborators
    Invoke-GithubApi GET "repos/$Repo/collaborators" $Query -MaxPages $MaxPages |
        New-GithubObject 'Github.Member' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}

function Add-GithubRepositoryCollaborator {
    [CmdletBinding()]
    [OutputType('Github.Member')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Username,

        [Parameter()]
        [ValidateSet('pull', 'push', 'admin', 'maintain', 'triage')]
        [string]
        $Permission = 'push'
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{
        permission = $Permission
    }

    # https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator
    Invoke-GithubApi PUT "repos/$Repo/collaborators/$Username" -Body $Body |
        New-GithubObject 'Github.Member' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
}

function Remove-GithubRepositoryCollaborator {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Username
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo/$Username", 'Remove repository collaborator')) {
        # https://docs.github.com/en/rest/collaborators/collaborators#remove-a-repository-collaborator
        Invoke-GithubApi DELETE "repos/$Repo/collaborators/$Username"
    }
}
