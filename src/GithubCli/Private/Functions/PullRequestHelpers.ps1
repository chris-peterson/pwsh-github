# Memoizes a resolve against the pull request object that asked for it, so both
# branch properties share one call. Keyed by the object rather than by repo and
# number, and held only in memory: Get-GithubPullRequest builds a new object every
# call, so a later fetch resolves again and a retargeted base is never served
# stale. Weak keys let an entry go when its pull request does.
$global:GithubPullRequestDetailByInstance = [System.Runtime.CompilerServices.ConditionalWeakTable[psobject, psobject]]::new()

function Resolve-GithubPullRequestDetail {
    <#
    .SYNOPSIS
    Fetches the pulls-API representation of a pull request that came from search.

    .DESCRIPTION
    A Github.PullRequest arrives in one of two shapes. The pulls API supplies
    Head/Base; search/issues supplies neither, and backs -Mine, -Search, and the
    -Author/-IsDraft/-CreatedAfter/-CreatedBefore/-MergedAfter/-MergedBefore/
    -ReviewedBy filters. The refs cost one API call per pull request, so the
    result is cached against the pull request it describes and fetched at most
    once, whether or not it succeeds.
    #>
    [CmdletBinding()]
    [OutputType('Github.PullRequest')]
    param(
        [Parameter(Mandatory)]
        [psobject]
        $PullRequest
    )

    $Detail = $null
    if ($global:GithubPullRequestDetailByInstance.TryGetValue($PullRequest, [ref] $Detail)) {
        return $Detail
    }

    $Repository = $PullRequest.RepositoryId ? $PullRequest.RepositoryId : $PullRequest.ProjectPath
    if ($Repository -and $PullRequest.Number) {
        try {
            $Detail = Invoke-GithubApi GET "repos/$Repository/pulls/$($PullRequest.Number)" |
                New-GithubObject 'Github.PullRequest'
        } catch {
            # A ScriptProperty getter swallows a terminating error, so an
            # unresolved ref would otherwise look like a pull request with no branch.
            Write-Warning "Could not resolve branch refs for $Repository#$($PullRequest.Number): $($_.Exception.Message)"
        }
    }

    $global:GithubPullRequestDetailByInstance.Add($PullRequest, $Detail)
    $Detail
}
