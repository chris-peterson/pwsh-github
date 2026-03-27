---
document type: cmdlet
external help file: Members-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Members
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubOrganizationMember
---

# Get-GithubOrganizationMember

## SYNOPSIS

Gets members of a GitHub organization.

## SYNTAX

### __AllParameterSets

```
Get-GithubOrganizationMember [-Organization] <string> [-Username <string>] [-Role <string>]
 [-MaxPages <uint>] [-All] [-Select <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets members of a GitHub organization. Can check membership for a specific user or list all members with optional role filtering.

## EXAMPLES

### Example 1

Get-GithubOrganizationMember 'my-org'

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

### -Role

The role to assign to the member.

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

## OUTPUTS

### Github.Member

A GitHub member/collaborator object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/orgs/members](https://docs.github.com/en/rest/orgs/members)

