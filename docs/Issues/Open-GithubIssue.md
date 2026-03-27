---
document type: cmdlet
external help file: Issues-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Issues
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Open-GithubIssue
---

# Open-GithubIssue

## SYNOPSIS

Reopens a closed GitHub issue.

## SYNTAX

### __AllParameterSets

```
Open-GithubIssue [-IssueId] <int> [-RepositoryId <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Reopens a closed GitHub issue by setting its state to open.

## EXAMPLES

### Example 1

Open-GithubIssue 42

## PARAMETERS

### -IssueId

The issue number.

```yaml
Type: System.Int32
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: (All)
  Position: 0
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### Github.Issue

A GitHub issue object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/issues/issues#update-an-issue](https://docs.github.com/en/rest/issues/issues#update-an-issue)

