function Get-GithubIssue {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Issue')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [Alias('RepositoryId')]
        [string]
        $Repository = '.',

        [Parameter(Position=0)]
        [Alias('Id')]
        [int]
        $IssueNumber,

        [Parameter(Mandatory, ParameterSetName='ByOrg')]
        [Alias('Org')]
        [string]
        $Organization,

        [Parameter(Mandatory, ParameterSetName='Mine')]
        [switch]
        $Mine,

        [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string]
        $State = 'open',

        [Parameter()]
        [string]
        $Assignee,

        [Parameter()]
        [string]
        $Creator,

        [Parameter()]
        [string]
        $Labels,

        [Parameter()]
        [ValidateSet('created', 'updated', 'comments')]
        [string]
        $Sort,

        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]
        $Direction,

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($State)     { $Query.state     = $State }
    if ($Assignee)  { $Query.assignee  = $Assignee }
    if ($Creator)   { $Query.creator   = $Creator }
    if ($Labels)    { $Query.labels    = $Labels }
    if ($Sort)      { $Query.sort      = $Sort }
    if ($Direction) { $Query.direction = $Direction }
    if ($Since)     { $Query.since     = $Since }

    switch ($PSCmdlet.ParameterSetName) {
        'ByRepo' {
            $Repo = Resolve-GithubRepository $Repository
            if ($IssueNumber) {
                # https://docs.github.com/en/rest/issues/issues#get-an-issue
                return Invoke-GithubApi GET "repos/$Repo/issues/$IssueNumber" |
                    New-GithubObject 'Github.Issue'
            }
            # https://docs.github.com/en/rest/issues/issues#list-repository-issues
            $Result = Invoke-GithubApi GET "repos/$Repo/issues" $Query -MaxPages $MaxPages
        }
        'ByOrg' {
            # https://docs.github.com/en/rest/issues/issues#list-organization-issues-assigned-to-the-authenticated-user
            $Result = Invoke-GithubApi GET "orgs/$Organization/issues" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # https://docs.github.com/en/rest/issues/issues#list-issues-assigned-to-the-authenticated-user
            $Result = Invoke-GithubApi GET "issues" $Query -MaxPages $MaxPages
        }
    }

    # Github's issues endpoint returns pull requests too; filter them out
    $Result |
        Where-Object { -not $_.pull_request } |
        New-GithubObject 'Github.Issue'
}
