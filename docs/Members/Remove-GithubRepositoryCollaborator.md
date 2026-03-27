---
document type: cmdlet
external help file: Members-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Members
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Remove-GithubRepositoryCollaborator
---

# Remove-GithubRepositoryCollaborator

## SYNOPSIS

Removes a collaborator from a GitHub repository.

## SYNTAX

### __AllParameterSets

```
Remove-GithubRepositoryCollaborator [-Username] <string> [-RepositoryId <string>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Removes a user from the collaborators of a GitHub repository.

## EXAMPLES

### Example 1

Remove-GithubRepositoryCollaborator 'octocat'

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

### -Username

The GitHub username.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### System.Void

Removes a user from the collaborators of a GitHub repository.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/collaborators/collaborators#remove-a-repository-collaborator](https://docs.github.com/en/rest/collaborators/collaborators#remove-a-repository-collaborator)

