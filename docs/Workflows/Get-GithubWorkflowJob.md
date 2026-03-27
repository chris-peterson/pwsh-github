---
document type: cmdlet
external help file: Workflows-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Workflows
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubWorkflowJob
---

# Get-GithubWorkflowJob

## SYNOPSIS

Gets jobs from a GitHub Actions workflow run.

## SYNTAX

### ByRun (Default)

```
Get-GithubWorkflowJob -WorkflowRunId <Object> [-RepositoryId <string>] [-Filter <string>]
 [-Select <string>] [-MaxPages <uint>] [-All] [<CommonParameters>]
```

### ById

```
Get-GithubWorkflowJob [-WorkflowJobId] <Object> [-RepositoryId <string>] [-Select <string>]
 [-MaxPages <uint>] [-All] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets jobs from a GitHub Actions workflow run. Can retrieve a specific job by ID or list all jobs for a run.

## EXAMPLES

### Example 1

Get-GithubWorkflowRun | Get-GithubWorkflowJob

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

### -Filter

Filter jobs: 'latest' for the most recent execution or 'all' for every attempt.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByRun
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

### -WorkflowJobId

The workflow job ID.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: ById
  Position: 0
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -WorkflowRunId

The workflow run ID.

```yaml
Type: System.Object
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: ByRun
  Position: Named
  IsRequired: true
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

### System.Object

Gets jobs from a GitHub Actions workflow run. Can retrieve a specific job by ID or list all jobs for a run.

## OUTPUTS

### Github.WorkflowJob

A GitHub Actions workflow job object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/actions/workflow-jobs](https://docs.github.com/en/rest/actions/workflow-jobs)

