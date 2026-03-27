---
document type: cmdlet
external help file: Branches-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Branches
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubBranch
---

# Get-GithubBranch

## SYNOPSIS

Gets branches from a GitHub repository.

## SYNTAX

### ByRepo (Default)

```
Get-GithubBranch [[-BranchId] <string>] [-RepositoryId <string>] [-Protected] [-MaxPages <uint>]
 [-All] [-Select <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets branches from a GitHub repository. When a BranchId is specified, retrieves detailed information for that branch. Otherwise, lists all branches.

## EXAMPLES

### Example 1

Get-GithubBranch
Get-GithubBranch main

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

### -BranchId

The branch name.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Id
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
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

### -Protected

Only return protected branches.

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### Github.Branch

A GitHub branch object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/branches/branches](https://docs.github.com/en/rest/branches/branches)

