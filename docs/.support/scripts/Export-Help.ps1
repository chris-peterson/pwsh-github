$Language     = 'en-US'
$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$DocsFolder   = Resolve-Path (Join-Path $ScriptDir '../..')
$ModuleFolder = Resolve-Path (Join-Path $ScriptDir '../../../src/GithubCli')
$OutputFolder = Join-Path $ModuleFolder $Language

Import-Module Microsoft.PowerShell.PlatyPS

if (-not (Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder | Out-Null
}

Measure-PlatyPSMarkdown -Path (Join-Path $DocsFolder '*/*.md') |
    Where-Object Filetype -match 'CommandHelp' |
    Import-MarkdownCommandHelp -Path { $_.FilePath } |
    Export-MamlCommandHelp -OutputFolder $OutputFolder -Force | Out-Null

# Each nested module declares its own `external help file`, so PlatyPS emits one
# folder per nested module; flatten them into en-US/ where PowerShell looks.
foreach ($Folder in Get-ChildItem -Path $OutputFolder -Directory) {
    Get-ChildItem -Path $Folder.FullName -Filter '*-Help.xml' |
        Move-Item -Destination $OutputFolder -Force

    $Leftover = Get-ChildItem -Path $Folder.FullName -Force
    if ($Leftover) {
        throw "$($Folder.Name) still holds $($Leftover.Count) file(s) after flattening: $($Leftover.Name -join ', ')"
    }
    Remove-Item -Path $Folder.FullName
}

$Exported = Get-ChildItem -Path $OutputFolder -Filter '*-Help.xml' | Sort-Object Name
Write-Host "Help exported to $OutputFolder ($($Exported.Count) files):" -ForegroundColor Green
$Exported | ForEach-Object { Write-Host "  $($_.Name)" }
