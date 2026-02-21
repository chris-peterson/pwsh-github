function Get-GithubMilestone {
    [CmdletBinding()]
    [OutputType('Github.Milestone')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0)]
        [Alias('Id')]
        [int]
        $MilestoneId,

        [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string]
        $State = 'open',

        [Parameter()]
        [ValidateSet('due_on', 'completeness')]
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
        $All,

        [Parameter()]
        [string]
        $Select
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($MilestoneId) {
        return Invoke-GithubApi GET "repos/$Repo/milestones/$MilestoneId" |
            New-GithubObject 'Github.Milestone' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($State)     { $Query.state     = $State }
    if ($Sort)      { $Query.sort      = $Sort }
    if ($Direction) { $Query.direction = $Direction }

    Invoke-GithubApi GET "repos/$Repo/milestones" $Query -MaxPages $MaxPages |
        New-GithubObject 'Github.Milestone' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}

function New-GithubMilestone {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Milestone')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DueOn,

        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string]
        $State
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{
        title = $Title
    }
    if ($Description) { $Body.description = $Description }
    if ($DueOn)       { $Body.due_on      = $DueOn }
    if ($State)       { $Body.state       = $State }

    if ($PSCmdlet.ShouldProcess("$Repo/$Title", 'Create milestone')) {
        Invoke-GithubApi POST "repos/$Repo/milestones" -Body $Body |
            New-GithubObject 'Github.Milestone' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Update-GithubMilestone {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Milestone')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        [int]
        $MilestoneId,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string]
        $DueOn,

        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string]
        $State
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{}
    if ($Title)       { $Body.title       = $Title }
    if ($Description) { $Body.description = $Description }
    if ($DueOn)       { $Body.due_on      = $DueOn }
    if ($State)       { $Body.state       = $State }

    if ($PSCmdlet.ShouldProcess("$Repo milestone #$MilestoneId", 'Update milestone')) {
        Invoke-GithubApi PATCH "repos/$Repo/milestones/$MilestoneId" -Body $Body |
            New-GithubObject 'Github.Milestone' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Remove-GithubMilestone {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        [int]
        $MilestoneId
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo milestone #$MilestoneId", 'Delete milestone')) {
        Invoke-GithubApi DELETE "repos/$Repo/milestones/$MilestoneId"
    }
}
