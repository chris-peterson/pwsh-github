function Get-GithubWorkflow {
    [CmdletBinding(DefaultParameterSetName='List')]
    [OutputType('Github.Workflow')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0, ParameterSetName='ById')]
        [Alias('Id')]
        $WorkflowId,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($WorkflowId) {
        $Result = Invoke-GithubApi GET "repos/$Repo/actions/workflows/$WorkflowId"
        return $Result |
            New-GithubObject 'Github.Workflow' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
    $Result = Invoke-GithubApi GET "repos/$Repo/actions/workflows" -MaxPages $MaxPages
    $Result.workflows |
        New-GithubObject 'Github.Workflow' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}

function Get-GithubWorkflowRun {
    [CmdletBinding(DefaultParameterSetName='List')]
    [OutputType('Github.WorkflowRun')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0, ParameterSetName='ById')]
        [Alias('Id')]
        $WorkflowRunId,

        [Parameter(ValueFromPipelineByPropertyName, ParameterSetName='List')]
        $WorkflowId,

        [Parameter(ParameterSetName='List')]
        [string]
        $Branch,

        [Parameter(ParameterSetName='List')]
        [ValidateSet('completed', 'action_required', 'cancelled', 'failure', 'neutral',
                     'skipped', 'stale', 'success', 'timed_out', 'in_progress',
                     'queued', 'requested', 'waiting', 'pending')]
        [string]
        $Status,

        [Parameter(ParameterSetName='List')]
        [string]
        $EventName,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($WorkflowRunId) {
        $Result = Invoke-GithubApi GET "repos/$Repo/actions/runs/$WorkflowRunId"
        return $Result |
            New-GithubObject 'Github.WorkflowRun' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
    $Query = @{}
    if ($WorkflowId) { $Query.workflow_id = $WorkflowId }
    if ($Branch)     { $Query.branch = $Branch }
    if ($Status)     { $Query.status = $Status }
    if ($EventName)  { $Query.event = $EventName }

    $Result = Invoke-GithubApi GET "repos/$Repo/actions/runs" $Query -MaxPages $MaxPages
    $Result.workflow_runs |
        New-GithubObject 'Github.WorkflowRun' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}

function Get-GithubWorkflowJob {
    [CmdletBinding(DefaultParameterSetName='ByRun')]
    [OutputType('Github.WorkflowJob')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName='ByRun')]
        $WorkflowRunId,

        [Parameter(Position=0, Mandatory, ParameterSetName='ById')]
        [Alias('Id')]
        $WorkflowJobId,

        [Parameter(ParameterSetName='ByRun')]
        [ValidateSet('latest', 'all')]
        [string]
        $Filter,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ParameterSetName -eq 'ById') {
        $Result = Invoke-GithubApi GET "repos/$Repo/actions/jobs/$WorkflowJobId"
        return $Result |
            New-GithubObject 'Github.WorkflowJob' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
    $Query = @{}
    if ($Filter) { $Query.filter = $Filter }

    $Result = Invoke-GithubApi GET "repos/$Repo/actions/runs/$WorkflowRunId/jobs" $Query -MaxPages $MaxPages
    $Result.jobs |
        New-GithubObject 'Github.WorkflowJob' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo; WorkflowRunId = $WorkflowRunId } -PassThru |
        Get-FilteredObject $Select
}

function Get-GithubWorkflowRunLog {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [Alias('Id')]
        $WorkflowJobId
    )

    $Repo = Resolve-GithubRepository $RepositoryId
    Invoke-GithubApi GET "repos/$Repo/actions/jobs/$WorkflowJobId/logs" -Accept 'application/vnd.github+json'
}

function Start-GithubWorkflowRun {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        $WorkflowId,

        [Parameter()]
        [string]
        $Ref,

        [Parameter()]
        [hashtable]
        $Inputs
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if (-not $Ref) {
        $RepoInfo = Invoke-GithubApi GET "repos/$Repo"
        $Ref = $RepoInfo.default_branch
    }

    $Body = @{ ref = $Ref }
    if ($Inputs) { $Body.inputs = $Inputs }

    if ($PSCmdlet.ShouldProcess("$Repo workflow $WorkflowId", 'Dispatch workflow run')) {
        Invoke-GithubApi POST "repos/$Repo/actions/workflows/$WorkflowId/dispatches" -Body $Body
    }
}
