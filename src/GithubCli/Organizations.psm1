function Get-GithubOrganization {
    [CmdletBinding(DefaultParameterSetName='Mine')]
    [OutputType('Github.Organization')]
    param(
        [Parameter(Position=0, ParameterSetName='ByName')]
        [string]
        $Name,

        [Parameter(Mandatory, ParameterSetName='ByUser')]
        [string]
        $Username,

        [Parameter(ParameterSetName='Mine')]
        [switch]
        $Mine,

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

    if ($Name) {
        # https://docs.github.com/en/rest/orgs/orgs#get-an-organization
        Invoke-GithubApi GET "orgs/$Name" |
            New-GithubObject 'Github.Organization' |
            Get-FilteredObject $Select
    }
    elseif ($Username) {
        $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
        # https://docs.github.com/en/rest/orgs/orgs#list-organizations-for-a-user
        Invoke-GithubApi GET "users/$Username/orgs" -MaxPages $MaxPages |
            New-GithubObject 'Github.Organization' |
            Get-FilteredObject $Select
    }
    else {
        # Mine (default) - authenticated user's orgs
        $MaxPages = Resolve-GithubMaxPages -MaxPages:$MaxPages -All:$All
        # https://docs.github.com/en/rest/orgs/orgs#list-organizations-for-the-authenticated-user
        Invoke-GithubApi GET "user/orgs" -MaxPages $MaxPages |
            New-GithubObject 'Github.Organization' |
            Get-FilteredObject $Select
    }
}
