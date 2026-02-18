function Get-GithubRemoteContext {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [string]
        [Parameter()]
        $Path = '.'
    )

    $Context = [PSCustomObject]@{
        Provider = ''
        Owner    = ''
        Repo     = ''
        Branch   = ''
    }
    if($(Get-Location).Provider.Name -ne 'FileSystem') {
        return $Context
    }

    Push-Location

    try {
        Set-Location $Path
        $GitDir = git rev-parse --git-dir 2>$null
        if ($GitDir -and (Test-Path -Path $GitDir)) {
            $OriginUrl = git config --get remote.origin.url
            if (-not $OriginUrl) {
                return $Context
            }

            # Parse owner/repo from remote URL
            # Supports: https://github.com/owner/repo.git
            #           git@github.com:owner/repo.git
            if ($OriginUrl -match 'github\.com[:/](?<Owner>[^/]+)/(?<Repo>[^/]+?)(?:\.git)?$') {
                $Context.Provider = 'github'
                $Context.Owner = $Matches.Owner
                $Context.Repo = $Matches.Repo
            }
            else {
                # Non-Github remote -- still extract owner/repo for general use
                try {
                    $Uri = [Uri]::new($OriginUrl)
                    $Parts = $Uri.AbsolutePath.Trim('/').TrimEnd('.git') -split '/'
                    if ($Parts.Count -ge 2) {
                        $Context.Owner = $Parts[0..($Parts.Count - 2)] -join '/'
                        $Context.Repo = $Parts[-1]
                    }
                }
                catch {
                    if ($OriginUrl -match '@(?<Host>.*?)[:/](?<Path>.+?)(?:\.git)?$') {
                        $Parts = $Matches.Path -split '/'
                        if ($Parts.Count -ge 2) {
                            $Context.Owner = $Parts[0..($Parts.Count - 2)] -join '/'
                            $Context.Repo = $Parts[-1]
                        }
                    }
                }
            }

            $Ref = git status | Select-String "^HEAD detached at (?<sha>.{7,40})|^On branch (?<branch>.*)"
            if ($Ref -and $Ref.Matches) {
                if ($Ref.Matches[0].Groups["branch"].Success) {
                    $Context.Branch = $Ref.Matches[0].Groups["branch"].Value
                } else {
                    $Context.Branch = "Detached HEAD"
                }
            }
        }
    }
    finally {
        Pop-Location
    }

    $Context
}

function Resolve-GithubRepository {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Position=0)]
        [string]
        $Repository = '.'
    )

    if ($Repository -eq '.') {
        $Context = Get-GithubRemoteContext
        if (-not $Context.Owner -or -not $Context.Repo) {
            throw "Could not infer Github repository based on current directory ($(Get-Location))"
        }
        return "$($Context.Owner)/$($Context.Repo)"
    }

    if ($Repository -match '^[^/]+/[^/]+$') {
        return $Repository
    }

    if ($Repository -match '^\d+$') {
        $Repo = Invoke-GithubApi GET "repositories/$Repository"
        return $Repo.full_name
    }

    throw "Invalid repository format '$Repository'. Expected 'owner/repo', numeric ID, or '.' for current directory."
}
