function Get-GitHubRepository {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType('GitHub.Repository')]
    param(
        [Parameter(Position=0, ParameterSetName='ByName')]
        [string]
        $Repository = '.',

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

    $MaxPages = Resolve-GitHubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Type) {
        $Query.type = $Type
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ByName' {
            $Repo = Resolve-GitHubRepository $Repository
            # https://docs.github.com/en/rest/repos/repos#get-a-repository
            $Result = Invoke-GitHubApi GET "repos/$Repo"
            return $Result |
                New-GitHubObject 'GitHub.Repository' |
                Get-FilteredObject $Select
        }
        'ByOrg' {
            # https://docs.github.com/en/rest/repos/repos#list-organization-repositories
            $Result = Invoke-GitHubApi GET "orgs/$Organization/repos" $Query -MaxPages $MaxPages
        }
        'ByUser' {
            # https://docs.github.com/en/rest/repos/repos#list-repositories-for-a-user
            $Result = Invoke-GitHubApi GET "users/$Username/repos" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # https://docs.github.com/en/rest/repos/repos#list-repositories-for-the-authenticated-user
            $Result = Invoke-GitHubApi GET "user/repos" $Query -MaxPages $MaxPages
        }
    }

    $Result |
        New-GitHubObject 'GitHub.Repository' |
        Sort-Object FullName |
        Get-FilteredObject $Select
}
