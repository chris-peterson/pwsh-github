---
document type: cmdlet
external help file: Users-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Users
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Get-GithubUser
---

# Get-GithubUser

## SYNOPSIS

Gets a GitHub user profile.

## SYNTAX

### ByName (Default)

```
Get-GithubUser [[-Username] <string>] [-Select <string>] [<CommonParameters>]
```

### Me

```
Get-GithubUser [-Me] [-Select <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Gets a GitHub user profile. Can retrieve a user by username or the authenticated user's own profile.

## EXAMPLES

### Example 1

Get-GithubUser 'octocat'
Get-GithubUser -Me

## PARAMETERS

### -Me

Return the authenticated user's profile.

```yaml
Type: System.Management.Automation.SwitchParameter
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: Me
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
- Name: ByName
  Position: 0
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

### Github.User

A GitHub user object.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest/users/users](https://docs.github.com/en/rest/users/users)

