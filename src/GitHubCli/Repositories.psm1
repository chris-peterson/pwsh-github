function Get-GithubRepository {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType('Github.Repository')]
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

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Type) {
        $Query.type = $Type
    }

    switch ($PSCmdlet.ParameterSetName) {
        'ByName' {
            $Repo = Resolve-GithubRepository $Repository
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
