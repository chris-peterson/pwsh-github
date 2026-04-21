---
document type: cmdlet
external help file: Events-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Events
ms.date: 04/21/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubEvent
---

# Get-GithubEvent

## SYNOPSIS

Gets events from GitHub.

## SYNTAX

### ByRepo (Default)

```
Get-GithubEvent [-RepositoryId <string>] [-MaxPages <uint>] [-All] [-Select <string>]
 [<CommonParameters>]
```

### ByUser

```
Get-GithubEvent -Username <string> [-MaxPages <uint>] [-All] [-Select <string>] [<CommonParameters>]
```

### ByOrg

```
Get-GithubEvent -Organization <string> [-MaxPages <uint>] [-All] [-Select <string>]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets events from a GitHub repository, user, or organization. Events include pushes, pull requests, issues, and other activity.

## EXAMPLES

### Example 1

Get-GithubEvent
Get-GithubEvent -Username octocat

## PARAMETERS

### -All

Retrieve all pages of results. Overrides MaxPages.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -MaxPages

Maximum number of pages of results to return. Each page contains up to 30 items.

```yaml
Type: System.UInt32
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Organization

The name of the GitHub organization.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Org
ParameterSets:
- Name: ByOrg
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -RepositoryId

The owner/name of the GitHub repository (e.g. 'owner/repo'). Defaults to the current directory's repository.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByRepo
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Select

Property name(s) to return. Use a comma-separated list for multiple properties, or '*' for all.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Username

The GitHub username.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByUser
  Position: Named
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### Github.Event

A GitHub event object.

## NOTES

## RELATED LINKS

- [https://docs.github.com/en/rest/activity/events](https://docs.github.com/en/rest/activity/events)
