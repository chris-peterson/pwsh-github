# https://just.systems/man/en/

default: test lint

test:
    #!/usr/bin/env pwsh
    Import-Module Pester
    $Config = New-PesterConfiguration
    $Config.Run.Exit = $true
    Invoke-Pester -Configuration $Config

docs:
    docsify serve docs --open

help-export:
    #!/usr/bin/env pwsh
    ./docs/.support/scripts/Export-Help.ps1

# Show the manifest and changelog edits a release would make, without writing them
release-preview VERSION:
    #!/usr/bin/env pwsh
    ./build/Update-ReleaseArtifacts.ps1 -Version {{VERSION}} -WhatIf

lint:
    #!/usr/bin/env pwsh
    $Results = Invoke-ScriptAnalyzer -Path ./src -Recurse -Settings ./PSScriptAnalyzerSettings.ps1
    if ($Results) { $Results | Format-Table -AutoSize; exit 1 } else { Write-Host "No linting issues found." }
