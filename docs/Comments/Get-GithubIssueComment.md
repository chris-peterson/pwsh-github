---
document type: cmdlet
external help file: Comments-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Comments
ms.date: 04/21/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubIssueComment
---

# Get-GithubIssueComment

## SYNOPSIS

Gets comments on a GitHub issue.

## SYNTAX

### __AllParameterSets

```
Get-GithubIssueComment [-IssueId] <int> [-RepositoryId <string>] [-Since <string>]
 [-MaxPages <uint>] [-All] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets comments on a GitHub issue. Returns all comments for the specified issue number.

## EXAMPLES

### Example 1

Get-GithubIssueComment -IssueId 42

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

### -IssueId

The issue number.

```yaml
Type: System.Int32
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: true
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

### -RepositoryId

The owner/name of the GitHub repository (e.g. 'owner/repo'). Defaults to the current directory's repository.

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
  ValueFromPipelineByPropertyName: true
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Since

Only return results updated after the given ISO 8601 timestamp (YYYY-MM-DDTHH:MM:SSZ).

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Int32

Gets comments on a GitHub issue. Returns all comments for the specified issue number.

### System.String

A string value.

## OUTPUTS

### Github.Comment

A GitHub comment object.

## NOTES

## RELATED LINKS

- [https://docs.github.com/en/rest/issues/comments#list-issue-comments](https://docs.github.com/en/rest/issues/comments#list-issue-comments)
