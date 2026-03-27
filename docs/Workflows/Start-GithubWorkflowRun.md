---
document type: cmdlet
external help file: Workflows-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Workflows
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Start-GithubWorkflowRun
---

# Start-GithubWorkflowRun

## SYNOPSIS

Triggers a GitHub Actions workflow run.

## SYNTAX

### __AllParameterSets

```
Start-GithubWorkflowRun [-WorkflowId] <Object> [-RepositoryId <string>] [-Ref <string>]
 [-Inputs <hashtable>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Dispatches a GitHub Actions workflow run. By default triggers on the repository's default branch. Use -Ref to target a specific branch or tag, and -Inputs to pass workflow input parameters.

## EXAMPLES

### Example 1

Start-GithubWorkflowRun 'ci.yml'

## PARAMETERS

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- cf
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

### -Inputs

Hashtable of input key-value pairs to pass to the workflow.

```yaml
Type: System.Collections.Hashtable
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

### -Ref

The git reference (branch name, tag, or SHA) to use.

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

### -WhatIf

Runs the command in a mode that only reports what would happen without performing the actions.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases:
- wi
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

### -WorkflowId

The workflow ID or filename (e.g. 'ci.yml').

```yaml
Type: System.Object
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

### System.Object

Dispatches a GitHub Actions workflow run. By default triggers on the repository's default branch. Use -Ref to target a specific branch or tag, and -Inputs to pass workflow input parameters.

## OUTPUTS

### System.Void

Dispatches a GitHub Actions workflow run. By default triggers on the repository's default branch. Use -Ref to target a specific branch or tag, and -Inputs to pass workflow input parameters.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/actions/workflows#create-a-workflow-dispatch-event](https://docs.github.com/en/rest/actions/workflows#create-a-workflow-dispatch-event)

