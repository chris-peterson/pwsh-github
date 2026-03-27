---
document type: cmdlet
external help file: Workflows-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Workflows
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubWorkflowRunLog
---

# Get-GithubWorkflowRunLog

## SYNOPSIS

Gets the log output for a GitHub Actions workflow job.

## SYNTAX

### __AllParameterSets

```
Get-GithubWorkflowRunLog [-WorkflowJobId] <Object> [-RepositoryId <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Downloads and returns the log output for a specific GitHub Actions workflow job.

## EXAMPLES

### Example 1

Get-GithubWorkflowRunLog 12345

## PARAMETERS

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

### -WorkflowJobId

The workflow job ID.

```yaml
Type: System.Object
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### System.String

A string value.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/actions/workflow-jobs#download-job-logs-for-a-workflow-run](https://docs.github.com/en/rest/actions/workflow-jobs#download-job-logs-for-a-workflow-run)

