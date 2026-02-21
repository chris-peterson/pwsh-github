function Get-GithubPullRequest {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0, ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int]
        $PullRequestId,

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

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($State)     { $Query.state     = $State }
    if ($Head)      { $Query.head      = $Head }
    if ($Base)      { $Query.base      = $Base }
    if ($Sort)      { $Query.sort      = $Sort }
    if ($Direction) { $Query.direction = $Direction }

    switch ($PSCmdlet.ParameterSetName) {
        'ByRepo' {
            $Repo = Resolve-GithubRepository $RepositoryId
            if ($PullRequestId) {
                # https://docs.github.com/en/rest/pulls/pulls#get-a-pull-request
                return Invoke-GithubApi GET "repos/$Repo/pulls/$PullRequestId" |
                    New-GithubObject 'Github.PullRequest' |
                    Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
            }
            # https://docs.github.com/en/rest/pulls/pulls#list-pull-requests
            $Result = Invoke-GithubApi GET "repos/$Repo/pulls" $Query -MaxPages $MaxPages
        }
        'Mine' {
            # Use search API to find PRs authored by current user
            $User = Invoke-GithubApi GET "user"
            $SearchQuery = "is:pr author:$($User.login)"
            if ($State -ne 'all') {
                $SearchQuery += " is:$State"
            }
            $Result = Invoke-GithubApi GET "search/issues" @{ q = $SearchQuery } -MaxPages $MaxPages |
                Select-Object -ExpandProperty items
        }
    }

    $PullRequests = $Result | New-GithubObject 'Github.PullRequest'
    if ($Repo) {
        $PullRequests | Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    } else {
        $PullRequests
    }
}

function New-GithubPullRequest {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter(Mandatory)]
        [Alias('Head')]
        [string]
        $SourceBranch,

        [Parameter()]
        [Alias('Base')]
        [string]
        $TargetBranch = 'main',

        [Parameter()]
        [Alias('Body')]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $Draft,

        [Parameter()]
        [switch]
        $MaintainerCanModify
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $RequestBody = @{
        title = $Title
        head  = $SourceBranch
        base  = $TargetBranch
    }
    if ($Description)       { $RequestBody.body = $Description }
    if ($Draft)             { $RequestBody.draft = $true }
    if ($MaintainerCanModify) { $RequestBody.maintainer_can_modify = $true }

    if ($PSCmdlet.ShouldProcess("$Repo PR '$Title' ($SourceBranch -> $TargetBranch)", 'Create')) {
        # https://docs.github.com/en/rest/pulls/pulls#create-a-pull-request
        Invoke-GithubApi POST "repos/$Repo/pulls" -Body $RequestBody |
            New-GithubObject 'Github.PullRequest' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Update-GithubPullRequest {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int]
        $PullRequestId,

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
        [Alias('Base')]
        [string]
        $TargetBranch,

        [Parameter()]
        [switch]
        $MaintainerCanModify
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $RequestBody = @{}
    if ($Title)               { $RequestBody.title = $Title }
    if ($Description)         { $RequestBody.body = $Description }
    if ($State)               { $RequestBody.state = $State }
    if ($TargetBranch)        { $RequestBody.base = $TargetBranch }
    if ($MaintainerCanModify) { $RequestBody.maintainer_can_modify = $true }

    if ($PSCmdlet.ShouldProcess("$Repo #$PullRequestId", 'Update pull request')) {
        # https://docs.github.com/en/rest/pulls/pulls#update-a-pull-request
        Invoke-GithubApi PATCH "repos/$Repo/pulls/$PullRequestId" -Body $RequestBody |
            New-GithubObject 'Github.PullRequest' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Merge-GithubPullRequest {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int]
        $PullRequestId,

        [Parameter()]
        [ValidateSet('merge', 'squash', 'rebase')]
        [string]
        $MergeMethod,

        [Parameter()]
        [string]
        $CommitTitle,

        [Parameter()]
        [string]
        $CommitMessage,

        [Parameter()]
        [switch]
        $DeleteSourceBranch
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $RequestBody = @{}
    if ($MergeMethod)   { $RequestBody.merge_method  = $MergeMethod }
    if ($CommitTitle)   { $RequestBody.commit_title   = $CommitTitle }
    if ($CommitMessage) { $RequestBody.commit_message = $CommitMessage }

    if ($PSCmdlet.ShouldProcess("$Repo #$PullRequestId", 'Merge pull request')) {
        # https://docs.github.com/en/rest/pulls/pulls#merge-a-pull-request
        Invoke-GithubApi PUT "repos/$Repo/pulls/$PullRequestId/merge" -Body $RequestBody | Out-Null

        if ($DeleteSourceBranch) {
            $PR = Invoke-GithubApi GET "repos/$Repo/pulls/$PullRequestId"
            $BranchName = $PR.head.ref
            # https://docs.github.com/en/rest/git/refs#delete-a-reference
            Invoke-GithubApi DELETE "repos/$Repo/git/refs/heads/$BranchName" | Out-Null
        }

        Invoke-GithubApi GET "repos/$Repo/pulls/$PullRequestId" |
            New-GithubObject 'Github.PullRequest' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Close-GithubPullRequest {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [int]
        $PullRequestId
    )

    if ($PSCmdlet.ShouldProcess("$RepositoryId #$PullRequestId", 'Close pull request')) {
        Update-GithubPullRequest -RepositoryId $RepositoryId -PullRequestId $PullRequestId -State closed
    }
}

function Get-GithubPullRequestComment {
    [CmdletBinding()]
    [OutputType('Github.Comment')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [int]
        $PullRequestId
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    # https://docs.github.com/en/rest/issues/comments#list-issue-comments
    Invoke-GithubApi GET "repos/$Repo/issues/$PullRequestId/comments" |
        New-GithubObject 'Github.Comment' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo; PullRequestId = $PullRequestId } -PassThru
}

function New-GithubPullRequestComment {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Comment')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [int]
        $PullRequestId,

        [Parameter(Mandatory)]
        [string]
        $Body
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo #$PullRequestId", 'Add comment')) {
        # https://docs.github.com/en/rest/issues/comments#create-an-issue-comment
        Invoke-GithubApi POST "repos/$Repo/issues/$PullRequestId/comments" -Body @{ body = $Body } |
            New-GithubObject 'Github.Comment' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo; PullRequestId = $PullRequestId } -PassThru
    }
}
