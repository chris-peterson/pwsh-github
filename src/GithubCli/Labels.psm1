function Get-GithubLabel {
    [CmdletBinding()]
    [OutputType('Github.Label')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Position=0)]
        [string]
        $Name,

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

    if ($Name) {
        $EncodedName = $Name | ConvertTo-UrlEncoded
        return Invoke-GithubApi GET "repos/$Repo/labels/$EncodedName" |
            New-GithubObject 'Github.Label' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
            Get-FilteredObject $Select
    }

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    Invoke-GithubApi GET "repos/$Repo/labels" -MaxPages $MaxPages |
        New-GithubObject 'Github.Label' |
        Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
        Get-FilteredObject $Select
}

function New-GithubLabel {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Label')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory)]
        [string]
        $Name,

        [Parameter(Mandatory)]
        [string]
        $Color,

        [Parameter()]
        [string]
        $Description
    )

    $Repo = Resolve-GithubRepository $RepositoryId

    $Body = @{
        name  = $Name
        color = $Color
    }
    if ($Description) { $Body.description = $Description }

    if ($PSCmdlet.ShouldProcess("$Repo/$Name", 'Create label')) {
        Invoke-GithubApi POST "repos/$Repo/labels" -Body $Body |
            New-GithubObject 'Github.Label' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Update-GithubLabel {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType('Github.Label')]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $NewName,

        [Parameter()]
        [string]
        $Color,

        [Parameter()]
        [string]
        $Description
    )

    $Repo = Resolve-GithubRepository $RepositoryId
    $EncodedName = $Name | ConvertTo-UrlEncoded

    $Body = @{}
    if ($NewName)     { $Body.new_name    = $NewName }
    if ($Color)       { $Body.color       = $Color }
    if ($Description) { $Body.description = $Description }

    if ($PSCmdlet.ShouldProcess("$Repo/$Name", 'Update label')) {
        Invoke-GithubApi PATCH "repos/$Repo/labels/$EncodedName" -Body $Body |
            New-GithubObject 'Github.Label' |
            Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru
    }
}

function Remove-GithubLabel {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([void])]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, Position=0)]
        [string]
        $Name
    )

    $Repo = Resolve-GithubRepository $RepositoryId
    $EncodedName = $Name | ConvertTo-UrlEncoded

    if ($PSCmdlet.ShouldProcess("$Repo/$Name", 'Delete label')) {
        Invoke-GithubApi DELETE "repos/$Repo/labels/$EncodedName"
    }
}
