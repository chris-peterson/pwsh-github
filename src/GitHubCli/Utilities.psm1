function Invoke-GitHubApi {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Position=0, Mandatory)]
        [Alias('Method')]
        [string]
        $HttpMethod,

        [Parameter(Position=1, Mandatory)]
        [string]
        $Path,

        [Parameter(Position=2)]
        [hashtable]
        $Query = @{},

        [Parameter()]
        [hashtable]
        $Body = @{},

        [Parameter()]
        [uint]
        $MaxPages = 1,

        [Parameter()]
        [string]
        $Accept = 'application/vnd.github+json'
    )

    if ($MaxPages -gt [int]::MaxValue) {
         $MaxPages = [int]::MaxValue
    }

    $Config = Get-GitHubConfiguration
    $BaseUrl = $Config.BaseUrl.TrimEnd('/')

    $Headers = @{
        Accept                 = $Accept
        Authorization          = "Bearer $($Config.AccessToken)"
        'X-GitHub-Api-Version' = '2022-11-28'
    }

    $SerializedQuery = ''
    $Delimiter = '?'
    if($Query.Count -gt 0) {
        foreach($Name in $Query.Keys) {
            $Value = $Query[$Name]
            if ($Value) {
                $SerializedQuery += $Delimiter
                $SerializedQuery += "$Name="
                $SerializedQuery += $Value | ConvertTo-UrlEncoded
                $Delimiter = '&'
            }
        }
    }

    $Uri = "$BaseUrl/$Path$SerializedQuery"

    $RestMethodParams = @{
        Method = $HttpMethod
        Uri    = $Uri
        Header = $Headers
    }
    if($MaxPages -gt 1) {
        $RestMethodParams.FollowRelLink        = $true
        $RestMethodParams.MaximumFollowRelLink = $MaxPages
    }
    if ($Body.Count -gt 0) {
        $RestMethodParams.ContentType = 'application/json'
        $RestMethodParams.Body        = $Body | ConvertTo-Json
    }

    Write-Verbose "Request: $($RestMethodParams.Method) $($RestMethodParams.Uri)"
    $Result = Invoke-RestMethod @RestMethodParams
    Write-Verbose "Response: $($Result | ConvertTo-Json -Depth 5)"
    if($MaxPages -gt 1) {
        $Result | ForEach-Object {
            Write-Output $_
        }
    } else {
        Write-Output $Result
    }
}

function Open-InBrowser {
    [CmdletBinding()]
    [OutputType([void])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    Process {
        if (-not $InputObject) {
            # do nothing
        } elseif ($InputObject -is [string]) {
            Start-Process $InputObject
        } elseif ($InputObject.HtmlUrl -and $InputObject.HtmlUrl -is [string]) {
            Start-Process $InputObject.HtmlUrl
        } elseif ($InputObject.Url -and $InputObject.Url -is [string]) {
            Start-Process $InputObject.Url
        }
    }
}

function Get-FilteredObject {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(ValueFromPipeline, Mandatory)]
        $InputObject,

        [Parameter(Position=0)]
        [string]
        $Select = '*'
    )
    Begin {}
    Process {
        foreach ($Object in $InputObject) {
            if (($Select -eq '*') -or (-not $Select)) {
                $Object
            } elseif ($Select.Contains(',')) {
                $Object | Select-Object $($Select -split ',')
            } else {
                $Object | Select-Object -ExpandProperty $Select
            }
        }
    }
    End {}
}
