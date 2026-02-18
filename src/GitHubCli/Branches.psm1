function Get-GithubBranch {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Branch')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [Alias('RepositoryId')]
        [string]
        $Repository = '.',

        [Parameter(Position=0)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $Protected,

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

    $Repo = Resolve-GithubRepository $Repository
    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    if ($Name) {
        # https://docs.github.com/en/rest/branches/branches#get-a-branch
        return Invoke-GithubApi GET "repos/$Repo/branches/$Name" |
            New-GithubObject 'Github.Branch' |
            Get-FilteredObject $Select
    } else {
        # https://docs.github.com/en/rest/branches/branches#list-branches
        $Query = @{}
        if ($Protected) { $Query.protected = 'true' }
        Invoke-GithubApi GET "repos/$Repo/branches" -Query $Query -MaxPages $MaxPages |
            New-GithubObject 'Github.Branch' |
            Get-FilteredObject $Select
    }
}
