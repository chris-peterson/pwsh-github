function Get-GithubEvent {
    [CmdletBinding(DefaultParameterSetName='ByRepo')]
    [OutputType('Github.Event')]
    param(
        [Parameter(ParameterSetName='ByRepo', ValueFromPipelineByPropertyName)]
        [string]
        $RepositoryId = '.',

        [Parameter(Mandatory, ParameterSetName='ByUser')]
        [string]
        $Username,

        [Parameter(Mandatory, ParameterSetName='ByOrg')]
        [Alias('Org')]
        [string]
        $Organization,

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

    $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All

    switch ($PSCmdlet.ParameterSetName) {
        'ByRepo' {
            $Repo = Resolve-GithubRepository $RepositoryId
            # https://docs.github.com/en/rest/activity/events#list-repository-events
            Invoke-GithubApi GET "repos/$Repo/events" -MaxPages $MaxPages |
                New-GithubObject 'Github.Event' |
                Add-Member -NotePropertyMembers @{ RepositoryId = $Repo } -PassThru |
                Get-FilteredObject $Select
        }
        'ByUser' {
            # https://docs.github.com/en/rest/activity/events#list-events-for-the-authenticated-user
            Invoke-GithubApi GET "users/$Username/events" -MaxPages $MaxPages |
                New-GithubObject 'Github.Event' |
                Get-FilteredObject $Select
        }
        'ByOrg' {
            # https://docs.github.com/en/rest/activity/events#list-organization-events
            Invoke-GithubApi GET "orgs/$Organization/events" -MaxPages $MaxPages |
                New-GithubObject 'Github.Event' |
                Get-FilteredObject $Select
        }
    }
}
