function Get-GitHubConfiguration {
    [CmdletBinding()]
    [OutputType('GitHub.Configuration')]
    param ()

    # Environment variable takes precedence (CI/CD, automation)
    if ($env:GITHUB_TOKEN -or $env:GH_TOKEN) {
        return [PSCustomObject]@{
            AccessToken = $env:GITHUB_TOKEN ?? $env:GH_TOKEN
            BaseUrl     = $env:GITHUB_API_URL ?? $global:GitHubBaseUrl
        } | New-GitHubObject 'GitHub.Configuration'
    }

    # File-based configuration
    if (Test-Path $global:GitHubConfigurationPath) {
        $Config = Get-Content $global:GitHubConfigurationPath -Raw | ConvertFrom-Yaml
        return [PSCustomObject]@{
            AccessToken = $Config.AccessToken
            BaseUrl     = $Config.BaseUrl ?? $global:GitHubBaseUrl
        } | New-GitHubObject 'GitHub.Configuration'
    }

    # Try gh CLI auth token as fallback
    try {
        $GhToken = gh auth token 2>$null
        if ($GhToken) {
            return [PSCustomObject]@{
                AccessToken = $GhToken.Trim()
                BaseUrl     = $global:GitHubBaseUrl
            } | New-GitHubObject 'GitHub.Configuration'
        }
    }
    catch {
        # gh CLI not available or not authenticated
    }

    throw @"
GitHubCli: No authentication configured.
Set one of the following:
  - `$env:GITHUB_TOKEN or `$env:GH_TOKEN environment variable
  - Authenticate with 'gh auth login' (GitHub CLI)
  - Create config file at $global:GitHubConfigurationPath
See https://github.com/chris-peterson/pwsh-github#authentication
"@
}

function Get-GitHubAccessToken {
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $Config = Get-GitHubConfiguration
    $Config.AccessToken
}
