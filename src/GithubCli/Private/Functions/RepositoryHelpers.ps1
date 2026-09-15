function ConvertTo-GithubRepositoryId {
    <#
    .SYNOPSIS
    Reads owner/name out of an API url an item carries about itself. Parses the
    string; makes no request.

    .DESCRIPTION
    A cross-repo listing (search, -Mine, -Organization) returns items from many
    repositories, and each one names its own in repository_url. That is the
    repository every follow-up call about the item has to use: the caller's working
    directory names at most one of the set, and often none of them.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Position=0)]
        [string]
        $ApiUrl
    )

    $Match = [regex]::Match($ApiUrl, '/repos/(?<Repository>[^/]+/[^/]+)')
    if ($Match.Success) {
        $Match.Groups['Repository'].Value
    }
}
