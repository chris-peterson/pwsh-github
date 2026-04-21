---
document type: cmdlet
external help file: PullRequests-Help.xml
HelpUri: ''
Locale: en-US
Module Name: PullRequests
ms.date: 04/21/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubPullRequestComment
---

# Get-GithubPullRequestComment

## SYNOPSIS

Gets comments on a GitHub pull request.

## SYNTAX

### __AllParameterSets

```
Get-GithubPullRequestComment [-PullRequestId] <int> [-RepositoryId <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets comments on a GitHub pull request. Returns issue-level comments (not review comments).

## EXAMPLES

### Example 1

Get-GithubPullRequestComment 42

## PARAMETERS

### -PullRequestId

The pull request number.

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

### System.Int32

Gets comments on a GitHub pull request. Returns issue-level comments (not review comments).

## OUTPUTS

### Github.Comment

A GitHub comment object.

## NOTES

## RELATED LINKS

- [https://docs.github.com/en/rest/issues/comments#list-issue-comments](https://docs.github.com/en/rest/issues/comments#list-issue-comments)
