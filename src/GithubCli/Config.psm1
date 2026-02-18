function Get-GithubConfiguration {
    [CmdletBinding()]
    [OutputType('Github.Configuration')]
    param ()

    # Environment variable takes precedence (CI/CD, automation)
    if ($env:GITHUB_TOKEN -or $env:GH_TOKEN) {
        return [PSCustomObject]@{
            AccessToken = $env:GITHUB_TOKEN ?? $env:GH_TOKEN
            BaseUrl     = $env:GITHUB_API_URL ?? $global:GithubBaseUrl
        } | New-GithubObject 'Github.Configuration'
    }

    # File-based configuration
    if (Test-Path $global:GithubConfigurationPath) {
        $Config = Get-Content $global:GithubConfigurationPath -Raw | ConvertFrom-Yaml
        return [PSCustomObject]@{
            AccessToken = $Config.AccessToken
            BaseUrl     = $Config.BaseUrl ?? $global:GithubBaseUrl
        } | New-GithubObject 'Github.Configuration'
    }

    # Try gh CLI auth token as fallback
    try {
        $GhToken = gh auth token 2>$null
        if ($GhToken) {
            return [PSCustomObject]@{
                AccessToken = $GhToken.Trim()
                BaseUrl     = $global:GithubBaseUrl
            } | New-GithubObject 'Github.Configuration'
        }
    }
    catch {
        Write-Verbose "gh CLI not available or not authenticated: $_"
    }

    throw @"
GithubCli: No authentication configured.
Set one of the following:
  - `$env:GITHUB_TOKEN or `$env:GH_TOKEN environment variable
  - Authenticate with 'gh auth login' (Github CLI)
  - Create config file at $global:GithubConfigurationPath
See https://github.com/chris-peterson/pwsh-github#authentication
"@
}

function Get-GithubAccessToken {
    [CmdletBinding()]
    [OutputType([string])]
    param ()

    $Config = Get-GithubConfiguration
    $Config.AccessToken
}
