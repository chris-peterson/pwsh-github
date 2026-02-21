function Get-GithubIssueComment {
    [CmdletBinding()]
    [OutputType('Github.Comment')]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [int]
        $IssueId,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [uint]
        $MaxPages,

        [Parameter()]
        [switch]
        $All
    )

    $Repo = Resolve-GithubRepository $RepositoryId
    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    $Query = @{}
    if ($Since) { $Query.since = $Since }

    # https://docs.github.com/en/rest/issues/comments#list-issue-comments
    Invoke-GithubApi GET "repos/$Repo/issues/$IssueId/comments" $Query -MaxPages $MaxPages |
        New-GithubObject 'Github.Comment' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo; IssueId = $IssueId } -PassThru
}

function New-GithubIssueComment {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Comment')]
    param(
        [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
        [int]
        $IssueId,

        [Parameter(Mandatory)]
        [string]
        $Body,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.'
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    if ($PSCmdlet.ShouldProcess("$Repo issue #$IssueId", 'Create comment')) {
        # https://docs.github.com/en/rest/issues/comments#create-an-issue-comment
        Invoke-GithubApi POST "repos/$Repo/issues/$IssueId/comments" -Body @{ body = $Body } |
            New-GithubObject 'Github.Comment' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo; IssueId = $IssueId } -PassThru
    }
}
