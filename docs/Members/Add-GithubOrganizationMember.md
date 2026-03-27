---
document type: cmdlet
external help file: Members-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Members
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Add-GithubOrganizationMember
---

# Add-GithubOrganizationMember

## SYNOPSIS

Adds or updates a user's membership in a GitHub organization.

## SYNTAX

### __AllParameterSets

```
Add-GithubOrganizationMember [-Username] <string> -Organization <string> [-Role <string>]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Sets organization membership for a user. Can be used to invite a new member or update an existing member's role.

## EXAMPLES

### Example 1

Add-GithubOrganizationMember -Organization 'my-org' -Username 'octocat'

## PARAMETERS

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
  Position: Named
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

## OUTPUTS

### Github.Member

A GitHub member/collaborator object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/orgs/members#set-organization-membership-for-a-user](https://docs.github.com/en/rest/orgs/members#set-organization-membership-for-a-user)

