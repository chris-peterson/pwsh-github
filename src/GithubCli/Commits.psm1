function Get-GithubCommit {
    [CmdletBinding()]
    [OutputType('Github.Commit')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0)]
        [Alias('Ref')]
        [string]
        $Sha,

        [Parameter()]
        [string]
        $Branch,

        [Parameter()]
        [string]
        $Author,

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [string]
        $Until,

        [Parameter()]
        [string]
        $Path,

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

    if ($Sha) {
        # https://docs.github.com/en/rest/commits/commits#get-a-commit
        return Invoke-GithubApi GET "repos/$Repo/commits/$Sha" |
            New-GithubObject 'Github.Commit' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Branch) { $Query.sha    = $Branch }
    if ($Author) { $Query.author = $Author }
    if ($Since)  { $Query.since  = $Since }
    if ($Until)  { $Query.until  = $Until }
    if ($Path)   { $Query.path   = $Path }

    # https://docs.github.com/en/rest/commits/commits#list-commits
    Invoke-GithubApi GET "repos/$Repo/commits" -Query $Query -MaxPages $MaxPages |
        New-GithubObject 'Github.Commit' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}
