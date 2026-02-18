function Get-GithubUser {
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType('Github.User')]
    param(
        [Parameter(Position=0, ParameterSetName='ByName')]
        [string]
        $Username,

        [Parameter(ParameterSetName='Me')]
        [switch]
        $Me,

        [Parameter()]
        [string]
        $Select
    )

    if ($Me) {
        # https://docs.github.com/en/rest/users/users#get-the-authenticated-user
        Invoke-GithubApi GET "user" |
            New-GithubObject 'Github.User' |
            Get-FilteredObject $Select
    } elseif ($Username) {
        # https://docs.github.com/en/rest/users/users#get-a-user
        Invoke-GithubApi GET "users/$Username" |
            New-GithubObject 'Github.User' |
            Get-FilteredObject $Select
    } else {
        throw "Specify -Username or -Me"
    }
}
