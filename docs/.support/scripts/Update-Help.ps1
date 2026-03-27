# Usage:
#   ./Update-Help.ps1                 # Update markdown files
#   ./Update-Help.ps1 -ThrowOnChanges # Update and fail if changes were made (for CI)

param(
    [switch]
    $ThrowOnChanges
)

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$DocsFolder = Join-Path $ScriptDir '../..'
$ModulePath = Join-Path $ScriptDir '../../../src/GithubCli'
$RepoRoot   = Resolve-Path (Join-Path $ScriptDir '../../..')

# Remove existing help XML to avoid duplicate documentation
$HelpXmlPath = Join-Path $ModulePath 'en-US/GithubCli-Help.xml'
if (Test-Path $HelpXmlPath) {
    Remove-Item $HelpXmlPath -Force
    Write-Host "Removed existing help XML file" -ForegroundColor Cyan
}

Import-Module Microsoft.PowerShell.PlatyPS
Import-Module $ModulePath -Force

$Module = Get-Module GithubCli

Write-Host "Updating existing markdown help files..." -ForegroundColor Cyan
$MdFiles = Measure-PlatyPSMarkdown -Path (Join-Path $DocsFolder '*/*.md') -ErrorAction SilentlyContinue
if ($MdFiles) {
    $MdFiles | Where-Object Filetype -match 'CommandHelp' |
        Update-MarkdownCommandHelp -Path { $_.FilePath } -NoBackup
}

Write-Host "Checking for new commands without documentation..." -ForegroundColor Cyan
$NewFiles = New-MarkdownCommandHelp -Module $Module -OutputFolder $DocsFolder -WarningAction SilentlyContinue

foreach ($File in $NewFiles) {
    $RelativePath = $File.FullName -replace [regex]::Escape((Resolve-Path $DocsFolder).Path + '/'), ''
    $UrlPath = $RelativePath -replace '\.md$', ''
    $Help = Import-MarkdownCommandHelp -Path $File.FullName
    $Help.OnlineVersionUrl = "https://chris-peterson.github.io/pwsh-github/#/$UrlPath"
    $Help.ModuleName = 'GithubCli'
    $Help | Export-MarkdownCommandHelp -OutputFolder $DocsFolder -Force
}

# PlatyPS creates a flat GithubCli/ folder in addition to category folders; remove the duplicate
$FlatFolder = Join-Path $DocsFolder 'GithubCli'
if (Test-Path $FlatFolder) {
    Remove-Item $FlatFolder -Recurse -Force
    Write-Host "  Removed duplicate GithubCli/ folder" -ForegroundColor Cyan
}

Write-Host "Filtering out unimportant changes..." -ForegroundColor Cyan
Push-Location $RepoRoot
$ModifiedFiles = git diff --name-only -- docs/
foreach ($File in $ModifiedFiles) {
    if ($File) {
        $DiffContent = git diff --unified=0 -- $File
        $SignificantChanges = $DiffContent | Where-Object {
            $_ -match '^[+-]' -and
            $_ -notmatch '^[+-]{3}' -and      # Ignore diff headers
            $_ -notmatch '^[+-]ms\.date:'     # Ignore ms.date changes
        }
        if (-not $SignificantChanges) {
            git checkout -- $File 2>$null
            Write-Debug "  Reverted unimportant changes in: $File"
        }
    }
}
Pop-Location

Write-Host "Checking for placeholder text..." -ForegroundColor Cyan
$PlaceholderPattern = '\{\{\s*Fill\s'
$PlaceholderMatches = Get-ChildItem -Path $DocsFolder -Filter '*.md' -Recurse |
    Select-String -Pattern $PlaceholderPattern

if ($PlaceholderMatches) {
    $GroupedPlaceholders = $PlaceholderMatches | Group-Object { Split-Path $_.Path -Parent | Split-Path -Leaf }
    Write-Host "`nPlaceholder text found in $($GroupedPlaceholders.Count) categories ($($PlaceholderMatches.Count) total):" -ForegroundColor Yellow
    foreach ($Group in $GroupedPlaceholders) {
        Write-Host "  $($Group.Name): $($Group.Count) placeholders" -ForegroundColor Yellow
    }
    if ($ThrowOnChanges) {
        throw "Documentation contains placeholder text. Please fill in the descriptions."
    }
}

# Define category descriptions
$CategoryDescriptions = @{
    'Branches'      = 'Manage repository branches'
    'Comments'      = 'Issue and PR comments'
    'Commits'       = 'View commit information'
    'Config'        = 'Module configuration'
    'Events'        = 'Repository events'
    'Issues'        = 'Work with issues'
    'Labels'        = 'Manage labels'
    'Members'       = 'Organization and repository members'
    'Milestones'    = 'Track milestones'
    'Organizations' = 'Organization information'
    'PullRequests'  = 'Handle pull requests'
    'Releases'      = 'Manage releases'
    'Repositories'  = 'Manage repositories'
    'Search'        = 'Search GitHub'
    'Users'         = 'User information'
    'Utilities'     = 'Helper utilities'
    'Workflows'     = 'GitHub Actions workflows'
}

# Get all category folders (exclude files and special folders)
$Categories = Get-ChildItem -Path $DocsFolder -Directory |
    Where-Object { $_.Name -ne '.support' } |
    Sort-Object Name

Write-Host "Validating category landing pages..." -ForegroundColor Cyan
foreach ($Category in $Categories) {
    $CmdletFiles = Get-ChildItem -Path $Category.FullName -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object BaseName

    if ($CmdletFiles) {
        $LandingPath = Join-Path $Category.FullName 'README.md'

        if (-not (Test-Path $LandingPath)) {
            $Description = $CategoryDescriptions[$Category.Name]
            if (-not $Description) { $Description = "Manage $($Category.Name)" }

            $LandingContent = @()
            $LandingContent += "# $($Category.Name)"
            $LandingContent += ''
            $LandingContent += $Description
            $LandingContent += ''
            $LandingContent += '## Cmdlets'
            $LandingContent += ''
            $LandingContent += '| Cmdlet | Description |'
            $LandingContent += '|--------|-------------|'
            foreach ($CmdletFile in $CmdletFiles) {
                $LandingContent += "| [$($CmdletFile.BaseName)]($($Category.Name)/$($CmdletFile.Name)) | |"
            }
            $LandingContent += ''

            Set-Content $LandingPath -Value ($LandingContent -join "`n") -NoNewline
            Write-Host "  Created $($Category.Name)/README.md (please add descriptions)" -ForegroundColor Yellow
        }
        else {
            $ReadmeContent = Get-Content $LandingPath -Raw
            $MissingCmdlets = @()
            foreach ($CmdletFile in $CmdletFiles) {
                if ($ReadmeContent -notmatch [regex]::Escape($CmdletFile.BaseName)) {
                    $MissingCmdlets += $CmdletFile.BaseName
                }
            }
            if ($MissingCmdlets) {
                Write-Host "  WARNING: $($Category.Name)/README.md is missing cmdlets: $($MissingCmdlets -join ', ')" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "Updating _sidebar.md from folder structure..." -ForegroundColor Cyan
$SidebarPath = Join-Path $DocsFolder '_sidebar.md'
$SidebarContent = @()
$SidebarContent += '<!-- docs/_sidebar.md -->'
$SidebarContent += '<!-- This file is auto-generated by .support/scripts/Update-Help.ps1 -->'
$SidebarContent += ''
$SidebarContent += '* [Home](/)'
$SidebarContent += ''

foreach ($Category in $Categories) {
    $CmdletFiles = Get-ChildItem -Path $Category.FullName -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object BaseName

    if ($CmdletFiles) {
        $SidebarContent += "* [$($Category.Name)]($($Category.Name)/)"

        foreach ($CmdletFile in $CmdletFiles) {
            $CmdletName = $CmdletFile.BaseName
            $RelativePath = "$($Category.Name)/$($CmdletFile.Name)"
            $SidebarContent += "  * [$CmdletName]($RelativePath)"
        }

        $SidebarContent += ''
    }
}

$SidebarContent += '---'
$SidebarContent += ''
$SidebarContent += '* [GitHub](https://github.com/chris-peterson/pwsh-github)'
$SidebarContent += '* [Acknowledgements](Acknowledgements.md)'
$SidebarContent += ''

$NewSidebarContent = $SidebarContent -join "`n"
$ExistingSidebarContent = if (Test-Path $SidebarPath) { Get-Content $SidebarPath -Raw } else { '' }

if ($NewSidebarContent.TrimEnd() -ne $ExistingSidebarContent.TrimEnd()) {
    Set-Content $SidebarPath -Value $NewSidebarContent -NoNewline
    Write-Host "  Updated _sidebar.md" -ForegroundColor Yellow
}

Write-Host "Updating README.md categories section..." -ForegroundColor Cyan
$ReadmePath = Join-Path $DocsFolder 'README.md'
$ReadmeContent = Get-Content $ReadmePath -Raw

$CategoriesList = @()
foreach ($Category in $Categories) {
    $Description = $CategoryDescriptions[$Category.Name]
    if (-not $Description) { $Description = "Manage $($Category.Name)" }

    $CategoriesList += "- [$($Category.Name)]($($Category.Name)/) - $Description"
}
$CategoriesText = $CategoriesList -join "`n"

$Pattern = '(?s)(## Cmdlet Categories\s+Browse the sidebar to find cmdlets organized by category:\s+)(- \[.*?)(## Links)'
$Replacement = "`$1$CategoriesText`n`n`$3"
$UpdatedReadme = $ReadmeContent -replace $Pattern, $Replacement

if ($UpdatedReadme -ne $ReadmeContent) {
    Set-Content $ReadmePath -Value $UpdatedReadme -NoNewline
    Write-Host "  Updated README.md categories" -ForegroundColor Yellow
}

if ($ThrowOnChanges) {
    Push-Location $RepoRoot
    $ModifiedFiles = git diff --name-only -- docs/
    $UntrackedFiles = git ls-files --others --exclude-standard -- docs/
    Pop-Location

    $PendingChanges = @($ModifiedFiles) + @($UntrackedFiles) | Where-Object { $_ }

    if ($PendingChanges) {
        Write-Host "`nThe following markdown help files are out of sync:" -ForegroundColor Red
        $PendingChanges | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Yellow
        }
        throw "Markdown help is out of sync. Run 'docs/.support/scripts/Update-Help.ps1' locally and commit the changes."
    }
    else {
        Write-Host "Markdown help is up to date." -ForegroundColor Green
    }
}
else {
    Push-Location $RepoRoot
    $ModifiedFiles = git diff --name-only -- docs/
    $UntrackedFiles = git ls-files --others --exclude-standard -- docs/
    Pop-Location

    $PendingChanges = @($ModifiedFiles) + @($UntrackedFiles) | Where-Object { $_ }

    if ($PendingChanges) {
        Write-Host "Help files updated. Review changes and commit." -ForegroundColor Yellow
    }
    else {
        Write-Host "Help files are up to date." -ForegroundColor Green
    }
}
