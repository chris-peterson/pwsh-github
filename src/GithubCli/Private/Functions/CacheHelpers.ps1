function Get-GithubCachePath {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    $CacheDir = Split-Path -Parent $global:GithubConfigurationPath
    Join-Path $CacheDir 'cache.yml'
}

function Get-GithubCache {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param()

    if ($global:GithubCache.Count -gt 0) {
        Write-Debug "GithubCache: Using in-memory cache"
        return $global:GithubCache
    }

    $CachePath = Get-GithubCachePath
    if (Test-Path $CachePath) {
        try {
            $DiskCache = Get-Content $CachePath -Raw | ConvertFrom-Yaml
            if ($DiskCache) {
                $global:GithubCache = $DiskCache
                $UserCount = $DiskCache.users ? $DiskCache.users.Count : 0
                Write-Debug "GithubCache: Loaded $UserCount user(s) from disk"
                return $global:GithubCache
            }
        } catch {
            Write-Debug "GithubCache: Error loading cache from disk: $_"
        }
    }

    Write-Debug "GithubCache: Initializing empty cache"
    $global:GithubCache = @{ users = @{} }
    return $global:GithubCache
}

function Save-GithubCache {
    [CmdletBinding()]
    param()

    $CachePath = Get-GithubCachePath
    $CacheDir = Split-Path -Parent $CachePath

    if (-not (Test-Path $CacheDir)) {
        Write-Debug "GithubCache: Creating cache directory '$CacheDir'"
        New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    }

    try {
        $Cache = $global:GithubCache
        $SortedCache = [ordered]@{}
        if ($Cache.users) {
            $SortedCache.users = [ordered]@{}
            $Cache.users.GetEnumerator() | Sort-Object Key | ForEach-Object { $SortedCache.users[$_.Key] = $_.Value }
        }
        $SortedCache | ConvertTo-Yaml | Set-Content -Path $CachePath -Force
        Write-Debug "GithubCache: Persisted cache to '$CachePath'"
    } catch {
        Write-Debug "GithubCache: Error saving cache to disk: $_"
    }
}

function Resolve-GithubUserName {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]
        $Login
    )

    $Cache = Get-GithubCache

    if (-not $Cache.users) {
        $Cache.users = @{}
    }

    if ($Cache.users.ContainsKey($Login)) {
        Write-Debug "GithubCache: User cache hit '$Login' -> '$($Cache.users[$Login])'"
        return $Cache.users[$Login]
    }

    Write-Debug "GithubCache: User cache miss for '$Login', calling API"
    $user = Invoke-GithubApi GET "users/$Login"
    $resolvedName = if ($user.name) { $user.name } else { $Login }
    $Cache.users[$Login] = $resolvedName
    Save-GithubCache

    Write-Debug "GithubCache: Resolved '$Login' -> '$resolvedName'"
    return $resolvedName
}
