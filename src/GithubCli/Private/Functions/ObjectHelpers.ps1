function Add-CoalescedProperty {
    param (
        [PSCustomObject]
        [Parameter(Mandatory, ValueFromPipeline)]
        $On,

        [string]
        [Parameter(Mandatory)]
        $To,

        [string[]]
        [Parameter(Mandatory)]
        $From
    )

    Process {
        if ($On.PSObject.Properties.Name -contains $To) {
            return
        }
        foreach ($PropertyName in $From) {
            if ($null -ne $On.$PropertyName) {
                $On | Add-Member -MemberType NoteProperty -Name $To -Value $On.$PropertyName
                return
            }
        }
    }
}

function Get-GithubDefaultSortProperty {
    <#
    .SYNOPSIS
    Returns the Sort-Object parameters that order a listing of this object's type.

    .DESCRIPTION
    A type that declares a DefaultKeyPropertySet in Types.ps1xml gets an empty set:
    Sort-Object with no -Property sorts on those properties, comparing each by its
    own type, so a number sorts as a number. Anything else falls back to the first
    recency property it carries, most recent first. Nothing is returned when neither
    applies, and the listing keeps the order the API returned.
    #>
    param (
        [Parameter(Mandatory, Position=0)]
        $Object
    )

    if ($Object.PSStandardMembers.DefaultKeyPropertySet) {
        return @{}
    }

    $PropertyNames = $Object.PSObject.Properties.Name
    foreach ($Candidate in 'UpdatedAt', 'LastActivityAt') {
        if ($PropertyNames -contains $Candidate) {
            return @{ Property = $Candidate; Descending = $true }
        }
    }
}

function Test-GithubSortPreference {
    # A caller that was given -Sort or -Direction is passing the user's ordering
    # through to the API, so leave that result in the order it came back. Only a
    # bound value counts: a parameter's default never reaches BoundParameters.
    $CallStack = Get-PSCallStack
    for ($i = 1; $i -lt $CallStack.Count; $i++) {
        $BoundParameters = $CallStack[$i].InvocationInfo.BoundParameters
        if (-not $BoundParameters) {
            continue
        }
        foreach ($Name in 'Sort', 'Direction') {
            $Value = $null
            if ($BoundParameters.TryGetValue($Name, [ref] $Value) -and -not [string]::IsNullOrWhiteSpace($Value)) {
                Write-Verbose "Sort: $Name was passed to [$($CallStack[$i].InvocationInfo.MyCommand.Name)], skipping default sort"
                return $true
            }
        }
    }
    $false
}

function New-GithubObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Creates PSCustomObject wrappers, not a state-changing operation')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [Parameter(Position=0)]
        [string]
        $DisplayType
    )
    Begin {
        $Objects = New-Object 'Collections.Generic.List[object]'
    }
    Process {
        foreach ($item in $InputObject) {
            if ($item -is [hashtable]) {
                $item = [PSCustomObject]$item
            }

            $Wrapper = New-Object PSObject
            $item.PSObject.Properties |
                Sort-Object Name |
                ForEach-Object {
                    $Name = $_.Name | ConvertTo-PascalCase
                    $Value = $_.Value

                    if ($Value -is [string] -and $Value -match '^\d{4}-\d{2}-\d{2}T') {
                        try {
                            $Value = [datetime]::Parse($Value)
                        } catch { Write-Debug "Failed to parse datetime: $Value" }
                    }

                    $Wrapper | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
                }

            # Github API returns both 'url' (API) and 'html_url' (web).
            # Prefer the web URL for display; overwrite if needed.
            $WebUrl = $Wrapper.HtmlUrl ?? $Wrapper.WebUrl
            if ($WebUrl) {
                if ($Wrapper.PSObject.Properties['Url']) {
                    $Wrapper.Url = $WebUrl
                } else {
                    $Wrapper | Add-Member -MemberType NoteProperty -Name 'Url' -Value $WebUrl
                }
            }

            # Promote nested pull_request.merged_at to top-level MergedAt
            # (GitHub search API nests merged_at inside a pull_request sub-object)
            if ($Wrapper.PullRequest.merged_at -and -not $Wrapper.PSObject.Properties['MergedAt']) {
                $MergedAtValue = $Wrapper.PullRequest.merged_at
                if ($MergedAtValue -is [string]) {
                    try { $MergedAtValue = [datetime]::Parse($MergedAtValue) } catch { Write-Debug "Failed to parse MergedAt: $MergedAtValue" }
                }
                $Wrapper | Add-Member -MemberType NoteProperty -Name 'MergedAt' -Value $MergedAtValue
            }

            if ($DisplayType) {
                $Wrapper.PSTypeNames.Insert(0, $DisplayType)

                $IdentityPropertyName = $global:GithubIdentityPropertyNameExemptions[$DisplayType]
                if ($IdentityPropertyName -eq $null) {
                    $IdentityPropertyName = 'Id'
                }
                if ($IdentityPropertyName -ne '') {
                    if ($Wrapper.$IdentityPropertyName) {
                        $TypeShortName = $DisplayType.Split('.') | Select-Object -Last 1
                        $AliasName = "$($TypeShortName)Id"
                        if (-not ($Wrapper.PSObject.Properties.Name -contains $AliasName)) {
                            $Wrapper | Add-Member -MemberType NoteProperty -Name $AliasName -Value $Wrapper.$IdentityPropertyName
                        }
                    }
                }
            }
            $Objects.Add($Wrapper)
        }
    }
    End {
        # Sorting needs the whole set, so nothing is emitted until the input
        # closes. Invoke-GithubApi has already collected every page by then.
        if ($Objects.Count -lt 2 -or (Test-GithubSortPreference)) {
            Write-Output $Objects
            return
        }

        $Sort = Get-GithubDefaultSortProperty $Objects[0]
        if ($null -ne $Sort) {
            $Objects | Sort-Object @Sort
        } else {
            Write-Output $Objects
        }
    }
}
