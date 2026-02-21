function Get-GithubIssue {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Issue')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0)]
        [Alias('Id')]
        [int]
        $IssueId,

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
            $Repo = Resolve-GithubRepository $RepositoryId
            if ($IssueId) {
                # https://docs.github.com/en/rest/issues/issues#get-an-issue
                return Invoke-GithubApi GET "repos/$Repo/issues/$IssueId" |
                    New-GithubObject 'Github.Issue' |
                    Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
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

    $Issues = $Result |
        Where-Object { -not $_.pull_request } |
        New-GithubObject 'Github.Issue'
    if ($Repo) {
        $Issues | Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    } else {
        $Issues
    }
}

function New-GithubIssue {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Issue')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter()]
        [Alias('Body')]
        [string]
        $Description,

        [Parameter()]
        [string[]]
        $Assignees,

        [Parameter()]
        [string[]]
        $Labels,

        [Parameter()]
        [int]
        $MilestoneNumber
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{
        title = $Title
    }
    if ($Description)    { $Body.body      = $Description }
    if ($Assignees)      { $Body.assignees = $Assignees }
    if ($Labels)         { $Body.labels    = $Labels }
    if ($MilestoneNumber) { $Body.milestone = $MilestoneNumber }

    if ($PSCmdlet.ShouldProcess("$Repo/$Title", 'Create issue')) {
        # https://docs.github.com/en/rest/issues/issues#create-an-issue
        Invoke-GithubApi POST "repos/$Repo/issues" -Body $Body |
            New-GithubObject 'Github.Issue' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Update-GithubIssue {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Issue')]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        [int]
        $IssueId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [Alias('Body')]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string]
        $State,

        [Parameter()]
        [string[]]
        $Assignees,

        [Parameter()]
        [string[]]
        $Labels,

        [Parameter()]
        [int]
        $MilestoneNumber
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{}
    if ($Title)           { $Body.title     = $Title }
    if ($Description)     { $Body.body      = $Description }
    if ($State)           { $Body.state     = $State }
    if ($Assignees)       { $Body.assignees = $Assignees }
    if ($Labels)          { $Body.labels    = $Labels }
    if ($MilestoneNumber) { $Body.milestone = $MilestoneNumber }

    if ($PSCmdlet.ShouldProcess("$Repo issue #$IssueId", 'Update issue')) {
        # https://docs.github.com/en/rest/issues/issues#update-an-issue
        Invoke-GithubApi PATCH "repos/$Repo/issues/$IssueId" -Body $Body |
            New-GithubObject 'Github.Issue' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Close-GithubIssue {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Issue')]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        [int]
        $IssueId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.'
    )

    if ($PSCmdlet.ShouldProcess("Issue #$IssueId", "Close")) {
        Update-GithubIssue -IssueId $IssueId -RepositoryId $RepositoryId -State closed
    }
}

function Open-GithubIssue {
    [CmdletBinding()]
    [OutputType('Github.Issue')]
    param(
        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        [int]
        $IssueId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.'
    )

    Update-GithubIssue -IssueId $IssueId -RepositoryId $RepositoryId -State open
}
