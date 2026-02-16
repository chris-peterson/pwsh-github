function Get-GitHubIssue {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('GitHub.Issue')]
    param(
        [Parameter(ParameterSetName='ByRepo')]
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

    $MaxPages = Resolve-GitHubMaxPages -MaxPages:$MaxPages -All:$All

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
            $Repo = Resolve-GitHubRepository $Repository
            if ($IssueNumber) {
                # https://docs.github.com/en/rest/issues/issues#get-an-issue
                return Invoke-GitHubApi GET "repos/$Repo/issues/$IssueNumber" |
                    New-GitHubObject 'GitHub.Issue'
            }
            # https://docs.github.com/en/rest/issues/issues#list-repository-issues
            $Result = Invoke-GitHubApi GET "repos/$Repo/issues" $Query -MaxPages $MaxPages
        }
        'ByOrg' {
            # https://docs.github.com/en/rest/issues/issues#list-organization-issues-assigned-to-the-authenticated-user
            $Result = Invoke-GitHubApi GET "orgs/$Organization/issues" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # https://docs.github.com/en/rest/issues/issues#list-issues-assigned-to-the-authenticated-user
            $Result = Invoke-GitHubApi GET "issues" $Query -MaxPages $MaxPages
        }
    }

    # GitHub's issues endpoint returns pull requests too; filter them out
    $Result |
        Where-Object { -not $_.pull_request } |
        New-GitHubObject 'GitHub.Issue'
}
