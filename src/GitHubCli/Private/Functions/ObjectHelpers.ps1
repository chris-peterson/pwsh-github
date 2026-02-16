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

function New-GitHubObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Creates PSCustomObject wrappers, not a state-changing operation')]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject,

        [Parameter(Position=0)]
        [string]
        $DisplayType
    )
    Begin{}
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

            # GitHub API returns both 'url' (API) and 'html_url' (web).
            # Prefer the web URL for display; overwrite if needed.
            $WebUrl = $Wrapper.HtmlUrl ?? $Wrapper.WebUrl
            if ($WebUrl) {
                if ($Wrapper.PSObject.Properties['Url']) {
                    $Wrapper.Url = $WebUrl
                } else {
                    $Wrapper | Add-Member -MemberType NoteProperty -Name 'Url' -Value $WebUrl
                }
            }

            if ($DisplayType) {
                $Wrapper.PSTypeNames.Insert(0, $DisplayType)

                $IdentityPropertyName = $global:GitHubIdentityPropertyNameExemptions[$DisplayType]
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
            Write-Output $Wrapper
        }
    }
    End{}
}
