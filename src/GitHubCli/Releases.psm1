function Get-GithubRelease {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Release')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='ById', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='ByTag', ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName='ByLatest', ValueFromPipelineByPropertyName)]
        [Alias('RepositoryId')]
        [string]
        $Repository = '.',

        [Parameter(Position=0, ParameterSetName='ById')]
        [Alias('Id')]
        [string]
        $ReleaseId,

        [Parameter(ParameterSetName='ByTag')]
        [string]
        $Tag,

        [Parameter(ParameterSetName='ByLatest')]
        [switch]
        $Latest,

        [Parameter(ParameterSetName='ByRepo')]
        [switch]
        $IncludePrerelease,

        [Parameter(ParameterSetName='ByRepo')]
        [uint]
        $MaxPages,

        [switch]
        [Parameter(ParameterSetName='ByRepo')]
        $All,

        [Parameter()]
        [string]
        $Select
    )

    $Repo = Resolve-GithubRepository $Repository

    if ($ReleaseId) {
        # https://docs.github.com/en/rest/releases/releases#get-a-release
        $Result = Invoke-GithubApi GET "repos/$Repo/releases/$ReleaseId" |
            New-GithubObject 'Github.Release'
    } elseif ($Tag) {
        # https://docs.github.com/en/rest/releases/releases#get-a-release-by-tag-name
        $Result = Invoke-GithubApi GET "repos/$Repo/releases/tags/$Tag" |
            New-GithubObject 'Github.Release'
    } elseif ($Latest) {
        # https://docs.github.com/en/rest/releases/releases#get-the-latest-release
        $Result = Invoke-GithubApi GET "repos/$Repo/releases/latest" |
            New-GithubObject 'Github.Release'
    } else {
        # https://docs.github.com/en/rest/releases/releases#list-releases
        $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
        $Result = Invoke-GithubApi GET "repos/$Repo/releases" -MaxPages $MaxPages |
            New-GithubObject 'Github.Release'

        # Github API includes prereleases by default
        if (-not $IncludePrerelease) {
            $Result = $Result | Where-Object { -not $_.Prerelease }
        }
    }

    $Result | Get-FilteredObject $Select
}
