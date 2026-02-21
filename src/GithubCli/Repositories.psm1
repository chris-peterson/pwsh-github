function Get-GithubRepository {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType('Github.Repository')]
    param(
        [Parameter(Position=0, ParameterSetName='ByName')]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, ParameterSetName='ByOrg')]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter(Mandatory, ParameterSetName='ByUser')]
        [string]
        $Username,

        [Parameter(ParameterSetName='Mine')]
        [switch]
        $Mine,

        [Parameter(ParameterSetName='ByOrg')]
        [Parameter(ParameterSetName='ByUser')]
        [Parameter(ParameterSetName='Mine')]
        [ValidateSet('all', 'public', 'private', 'forks', 'sources', 'member')]
        [string]
        $Type,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Type) {
        $Query.type = $Type
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ByName' {
            $Repo = Resolve-GithubRepository $RepositoryId
            # https://docs.github.com/en/rest/repos/repos#get-a-repository
            $Result = Invoke-GithubApi GET "repos/$Repo"
            return $Result |
                New-GithubObject 'Github.Repository' |
                Get-FilteredObject $Select
        }
        'ByOrg' {
            # https://docs.github.com/en/rest/repos/repos#list-organization-repositories
            $Result = Invoke-GithubApi GET "orgs/$Organization/repos" $Query -MaxPages $MaxPages
        }
        'ByUser' {
            # https://docs.github.com/en/rest/repos/repos#list-repositories-for-a-user
            $Result = Invoke-GithubApi GET "users/$Username/repos" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # https://docs.github.com/en/rest/repos/repos#list-repositories-for-the-authenticated-user
            $Result = Invoke-GithubApi GET "user/repos" $Query -MaxPages $MaxPages
        }
    }

    $Result |
        New-GithubObject 'Github.Repository' |
        Sort-Object FullName |
        Get-FilteredObject $Select
}

function New-GithubRepository {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Repository')]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Name,

        [Parameter()]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('public', 'private')]
        [string]
        $Visibility,

        [Parameter()]
        [string]
        $Homepage,

        [Parameter()]
        [switch]
        $HasIssues,

        [Parameter()]
        [switch]
        $HasWiki,

        [Parameter()]
        [switch]
        $AutoInit
    )

    $Body = @{ name = $Name }
    if ($Description) { $Body.description = $Description }
    if ($Visibility)  { $Body.private = ($Visibility -eq 'private') }
    if ($Homepage)    { $Body.homepage = $Homepage }
    if ($HasIssues)   { $Body.has_issues = $true }
    if ($HasWiki)     { $Body.has_wiki = $true }
    if ($AutoInit)    { $Body.auto_init = $true }

    $Target = if ($Organization) { $Organization } else { 'user' }
    if ($PSCmdlet.ShouldProcess("$Target/$Name", 'Create repository')) {
        if ($Organization) {
            # https://docs.github.com/en/rest/repos/repos#create-an-organization-repository
            $Result = Invoke-GithubApi POST "orgs/$Organization/repos" -Body $Body
        } else {
            # https://docs.github.com/en/rest/repos/repos#create-a-repository-for-the-authenticated-user
            $Result = Invoke-GithubApi POST "user/repos" -Body $Body
        }
        $Result | New-GithubObject 'Github.Repository'
    }
}

function Update-GithubRepository {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Repository')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter()]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('public', 'private')]
        [string]
        $Visibility,

        [Parameter()]
        [string]
        $Homepage,

        [Parameter()]
        [string]
        $DefaultBranch,

        [Parameter()]
        [switch]
        $Archived
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{}
    if ($Name)          { $Body.name = $Name }
    if ($Description)   { $Body.description = $Description }
    if ($Visibility)    { $Body.private = ($Visibility -eq 'private') }
    if ($Homepage)      { $Body.homepage = $Homepage }
    if ($DefaultBranch) { $Body.default_branch = $DefaultBranch }
    if ($Archived)      { $Body.archived = $true }

    if ($PSCmdlet.ShouldProcess($Repo, 'Update repository')) {
        # https://docs.github.com/en/rest/repos/repos#update-a-repository
        Invoke-GithubApi PATCH "repos/$Repo" -Body $Body |
            New-GithubObject 'Github.Repository'
    }
}

function Remove-GithubRepository {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess($Repo, 'Delete repository')) {
        # https://docs.github.com/en/rest/repos/repos#delete-a-repository
        Invoke-GithubApi DELETE "repos/$Repo"
    }
}
