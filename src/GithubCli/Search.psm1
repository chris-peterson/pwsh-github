function Search-Github {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias('Q')]
        [string]
        $Query,

        [Parameter()]
        [ValidateSet('code', 'commits', 'issues', 'repositories', 'users')]
        [string]
        $Scope = 'code',

        [Parameter()]
        [string]
        $Sort,

        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]
        $Direction,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $ApiQuery = @{
        q = $Query
    }
    if ($Sort)      { $ApiQuery.sort  = $Sort }
    if ($Direction) { $ApiQuery.order = $Direction }

    $TypeMap = @{
        code         = 'Github.SearchResult'
        commits      = 'Github.Commit'
        issues       = 'Github.Issue'
        repositories = 'Github.Repository'
        users        = 'Github.User'
    }
    $ObjectType = $TypeMap[$Scope]

    $Result = Invoke-GithubApi GET "search/$Scope" $ApiQuery -MaxPages $MaxPages
    $Result.items | New-GithubObject $ObjectType
}

function Search-GithubRepository {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Query,

        [Parameter()]
        [ValidateSet('code', 'commits', 'issues')]
        [string]
        $Scope = 'code',

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $QualifiedQuery = "$Query repo:$Repo"
    Search-Github -Query $QualifiedQuery -Scope $Scope -MaxPages:$MaxPages -All:$All
}
