function Resolve-GitHubMaxPages {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Resolves the MaxPages parameter value')]
    param (
        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All
    )
    if ($MaxPages -eq 0) {
        $MaxPages = $global:GitHubDefaultMaxPages
    }
    if ($All) {
        if ($MaxPages -ne $global:GitHubDefaultMaxPages) {
            Write-Warning -Message "Ignoring -MaxPages in favor of -All"
        }
        $MaxPages = [uint]::MaxValue
    }
    Write-Debug "MaxPages: $MaxPages"
    $MaxPages
}
