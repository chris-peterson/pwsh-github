function Get-GithubBranch {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Branch')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]
        $BranchId,

        [Parameter()]
        [switch]
        $Protected,

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
    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    if ($BranchId) {
        # https://docs.github.com/en/rest/branches/branches#get-a-branch
        return Invoke-GithubApi GET "repos/$Repo/branches/$BranchId" |
            New-GithubObject 'Github.Branch' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    } else {
        # https://docs.github.com/en/rest/branches/branches#list-branches
        $Query = @{}
        if ($Protected) { $Query.protected = 'true' }
        Invoke-GithubApi GET "repos/$Repo/branches" -Query $Query -MaxPages $MaxPages |
            New-GithubObject 'Github.Branch' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }
}

function New-GithubBranch {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Branch')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Ref
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo/$Name", 'Create branch')) {
        if ($Ref) {
            # Resolve the provided ref to a SHA
            $RefInfo = Invoke-GithubApi GET "repos/$Repo/git/ref/heads/$Ref"
            $Sha = $RefInfo.object.sha
        } else {
            # Use the repository's default branch
            $RepoInfo = Invoke-GithubApi GET "repos/$Repo"
            $DefaultBranch = $RepoInfo.default_branch
            $RefInfo = Invoke-GithubApi GET "repos/$Repo/git/ref/heads/$DefaultBranch"
            $Sha = $RefInfo.object.sha
        }

        $Body = @{
            ref = "refs/heads/$Name"
            sha = $Sha
        }

        # https://docs.github.com/en/rest/git/refs#create-a-reference
        Invoke-GithubApi POST "repos/$Repo/git/refs" -Body $Body | Out-Null

        # Return the newly created branch
        Invoke-GithubApi GET "repos/$Repo/branches/$Name" |
            New-GithubObject 'Github.Branch' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Remove-GithubBranch {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]
        $BranchId
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo/$BranchId", 'Delete branch')) {
        # https://docs.github.com/en/rest/git/refs#delete-a-reference
        Invoke-GithubApi DELETE "repos/$Repo/git/refs/heads/$BranchId"
    }
}
