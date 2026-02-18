@{
    # PSScriptAnalyzer settings for pwsh-github
    # https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme

    ExcludeRules = @(
        # This module intentionally uses global variables for shared module state
        # (config path, API defaults, identity mappings, etc.). $script: scope doesn't
        # work across module files, so $global: is the standard pattern.
        # All globals are namespaced with 'Github' prefix to avoid collisions.
        'PSAvoidGlobalVars'

        # Suggests putting $null on the left side of comparisons to avoid array coercion issues.
        # While technically valid, the right-side style ($var -eq $null) is more readable.
        'PSPossibleIncorrectComparisonWithNull'

        # The 'Mine' parameter appears unused in many functions, but it drives
        # ParameterSetName-based dispatch ($PSCmdlet.ParameterSetName eq 'Mine').
        # PSScriptAnalyzer cannot detect this usage pattern.
        'PSReviewUnusedParameter'

        # Fires on functions with ValueFromPipelineByPropertyName but no process {} block.
        # Most functions in this module are designed for single-object pipeline input.
        'PSUseProcessBlockForPipelineCommand'
    )
}
