---
document type: cmdlet
external help file: Config-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Config
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubConfiguration
---

# Get-GithubConfiguration

## SYNOPSIS

Gets the current GitHub API authentication configuration.

## SYNTAX

### __AllParameterSets

```
Get-GithubConfiguration [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Returns the GitHub API authentication configuration. Checks, in order: GITHUB_TOKEN / GH_TOKEN environment variables, the GithubCli config file, and the gh CLI auth token.

## EXAMPLES

### Example 1

Get-GithubConfiguration

## PARAMETERS

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Github.Configuration

A GitHub API configuration object containing authentication details.

## NOTES



## RELATED LINKS

[https://github.com/chris-peterson/pwsh-github#authentication](https://github.com/chris-peterson/pwsh-github#authentication)

