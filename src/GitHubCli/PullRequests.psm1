function Get-GitHubPullRequest {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('GitHub.PullRequest')]
    param(
        [Parameter(ParameterSetName='ByRepo')]
        [string]
        $Repository = '.',

        [Parameter(Position=0, ParameterSetName='ByRepo')]
        [Alias('Id')]
        [int]
        $PullRequestNumber,

        [Parameter(Mandatory, ParameterSetName='Mine')]
        [switch]
        $Mine,

        [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string]
        $State = 'open',

        [Parameter()]
        [Alias('Branch')]
        [string]
        $Head,

        [Parameter()]
        [string]
        $Base,

        [Parameter()]
        [ValidateSet('created', 'updated', 'popularity', 'long-running')]
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

    $MaxPages = Resolve-GitHubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($State)     { $Query.state     = $State }
    if ($Head)      { $Query.head      = $Head }
    if ($Base)      { $Query.base      = $Base }
    if ($Sort)      { $Query.sort      = $Sort }
    if ($Direction) { $Query.direction = $Direction }

    switch ($PSCmdlet.ParameterSetName) {
        'ByRepo' {
            $Repo = Resolve-GitHubRepository $Repository
            if ($PullRequestNumber) {
                # https://docs.github.com/en/rest/pulls/pulls#get-a-pull-request
                return Invoke-GitHubApi GET "repos/$Repo/pulls/$PullRequestNumber" |
                    New-GitHubObject 'GitHub.PullRequest'
            }
            # https://docs.github.com/en/rest/pulls/pulls#list-pull-requests
            $Result = Invoke-GitHubApi GET "repos/$Repo/pulls" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # Use search API to find PRs authored by current user
            $User = Invoke-GitHubApi GET "user"
            $SearchQuery = "is:pr author:$($User.login)"
            if ($State -ne 'all') {
                $SearchQuery += " is:$State"
            }
            $Result = Invoke-GitHubApi GET "search/issues" @{ q = $SearchQuery } -MaxPages $MaxPages |
                Select-Object -ExpandProperty items
        }
    }

    $Result |
        New-GitHubObject 'GitHub.PullRequest'
}
