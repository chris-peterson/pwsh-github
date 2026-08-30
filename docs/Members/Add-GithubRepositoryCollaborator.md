---
document type: cmdlet
external help file: Members-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Members
ms.date: 08/30/2026
PlatyPS schema version: 2024-05-01
title: Add-GithubRepositoryCollaborator
---

# Add-GithubRepositoryCollaborator

## SYNOPSIS

Grants a user access to a GitHub repository, or changes the access they already have.

## SYNTAX

### __AllParameterSets

```
Add-GithubRepositoryCollaborator [-Username] <string> [-RepositoryId <string>]
 [-Permission <string>] [<CommonParameters>]
```

## ALIASES

Set-GithubRepositoryCollaborator

## DESCRIPTION

Grants a user the specified permission on a GitHub repository. The underlying endpoint is an upsert,
so the same call adds a user who is not yet a collaborator and changes the permission of one who already is.
`Set-GithubRepositoryCollaborator` is an alias for exactly this behavior.

Lowering someone's access is a call with a narrower `-Permission`, not a removal:
`Remove-GithubRepositoryCollaborator` revokes access outright.

## EXAMPLES

### Example 1

Add-GithubRepositoryCollaborator 'octocat' -Permission push

### Example 2

Set-GithubRepositoryCollaborator 'octocat' -Permission admin

## PARAMETERS

### -Permission

The permission level to grant (pull, push, admin, maintain, or triage).

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

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

A string value.

## OUTPUTS

### Github.Member

A GitHub member/collaborator object.

## NOTES

## RELATED LINKS

- [https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator](https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator)
