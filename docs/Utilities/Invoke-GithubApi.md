---
document type: cmdlet
external help file: Utilities-Help.xml
HelpUri: ''
Locale: en-US
Module Name: Utilities
ms.date: 03/26/2026
PlatyPS schema version: 2024-05-01
title: Invoke-GithubApi
---

# Invoke-GithubApi

## SYNOPSIS

Invokes the GitHub REST API directly.

## SYNTAX

### __AllParameterSets

```
Invoke-GithubApi [-HttpMethod] <string> [-Path] <string> [[-Query] <hashtable>] [-Body <hashtable>]
 [-MaxPages <uint>] [-Accept <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Sends an authenticated request to the GitHub REST API. Handles authentication, pagination, and serialization. This is the low-level function used by all other cmdlets in the module.

## EXAMPLES

### Example 1

Invoke-GithubApi GET 'repos/owner/repo'

## PARAMETERS

### -Accept

The Accept header value for the API request. Defaults to 'application/vnd.github+json'.

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

### -Body

The comment body text.

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

### -HttpMethod

The HTTP method (GET, POST, PATCH, PUT, DELETE).

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Method
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

### -Path

Filter commits by file path.

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Query

The search query string using GitHub search syntax.

```yaml
Type: System.Collections.Hashtable
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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

### System.Management.Automation.PSObject

Sends an authenticated request to the GitHub REST API. Handles authentication, pagination, and serialization. This is the low-level function used by all other cmdlets in the module.

## NOTES



## RELATED LINKS

[https://docs.github.com/en/rest](https://docs.github.com/en/rest)

