<#
.SYNOPSIS
    Fills PlatyPS placeholder text in generated markdown help files.
.DESCRIPTION
    Reads each .md help file under docs/ and replaces {{ Fill ... }} placeholders
    with descriptions derived from the source .psm1 files.
#>

$DocsRoot = Join-Path $PSScriptRoot '..' '..' | Resolve-Path

# --- Parameter descriptions (shared across cmdlets) ---
$ParamDescriptions = @{
    'RepositoryId'        = 'The owner/name of the GitHub repository (e.g. ''owner/repo''). Defaults to the current directory''s repository.'
    'MaxPages'            = 'Maximum number of pages of results to return. Each page contains up to 30 items.'
    'All'                 = 'Retrieve all pages of results. Overrides MaxPages.'
    'Select'              = 'Property name(s) to return. Use a comma-separated list for multiple properties, or ''*'' for all.'
    'Mine'                = 'Return items assigned to or authored by the authenticated user.'
    'Me'                  = 'Return the authenticated user''s profile.'
    'Organization'        = 'The name of the GitHub organization.'
    'Username'            = 'The GitHub username.'
    'IssueId'             = 'The issue number.'
    'PullRequestId'       = 'The pull request number.'
    'State'               = 'Filter by state (e.g. open, closed, all).'
    'Assignee'            = 'Filter issues by assignee username.'
    'Creator'             = 'Filter issues by the username of the creator.'
    'Labels'              = 'Comma-separated list of label names to filter by.'
    'Sort'                = 'Property to sort results by.'
    'Direction'           = 'Sort direction: asc or desc.'
    'Since'               = 'Only return results updated after the given ISO 8601 timestamp (YYYY-MM-DDTHH:MM:SSZ).'
    'Until'               = 'Only return commits before the given ISO 8601 timestamp.'
    'Title'               = 'The title text.'
    'Description'         = 'The description or body text.'
    'Body'                = 'The comment body text.'
    'Assignees'           = 'Array of GitHub usernames to assign.'
    'MilestoneNumber'     = 'The milestone number to associate.'
    'MilestoneId'         = 'The milestone number.'
    'BranchId'            = 'The branch name.'
    'Name'                = 'The name.'
    'NewName'             = 'The new name to rename to.'
    'Ref'                 = 'The git reference (branch name, tag, or SHA) to use.'
    'Color'               = 'The hex color code for the label (without the leading #).'
    'Role'                = 'The role to assign to the member.'
    'Affiliation'         = 'Filter collaborators by affiliation (outside, direct, or all).'
    'Permission'          = 'The permission level to grant (pull, push, admin, maintain, or triage).'
    'DueOn'               = 'The due date for the milestone in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ).'
    'Head'                = 'Filter pull requests by head branch name.'
    'Base'                = 'Filter pull requests by base branch name.'
    'SourceBranch'        = 'The head branch containing the changes.'
    'TargetBranch'        = 'The base branch that the pull request merges into. Defaults to ''main''.'
    'Draft'               = 'Create the pull request as a draft, or convert an existing pull request to draft.'
    'MaintainerCanModify' = 'Allow maintainers of the base repository to push commits to the head branch.'
    'MarkReady'           = 'Mark a draft pull request as ready for review.'
    'MergeMethod'         = 'The merge strategy to use: merge, squash, or rebase.'
    'CommitTitle'         = 'Custom title for the merge commit.'
    'CommitMessage'       = 'Custom message for the merge commit.'
    'DeleteSourceBranch'  = 'Delete the source branch after merging.'
    'IsDraft'             = 'Filter to only return draft pull requests.'
    'Author'              = 'Filter by the author''s GitHub username.'
    'Sha'                 = 'The commit SHA or ref to retrieve.'
    'Branch'              = 'Filter commits by branch name.'
    'Path'                = 'Filter commits by file path.'
    'Protected'           = 'Only return protected branches.'
    'Type'                = 'Filter repositories by type (all, public, private, forks, sources, member).'
    'Visibility'          = 'Repository visibility: public or private.'
    'Homepage'            = 'URL of the project homepage.'
    'DefaultBranch'       = 'The name of the default branch.'
    'HasIssues'           = 'Enable the issues feature on the repository.'
    'HasWiki'             = 'Enable the wiki feature on the repository.'
    'AutoInit'            = 'Initialize the repository with a README.'
    'Archived'            = 'Archive the repository (makes it read-only).'
    'Query'               = 'The search query string using GitHub search syntax.'
    'Scope'               = 'The type of GitHub objects to search (code, commits, issues, repositories, or users).'
    'ReleaseId'           = 'The release ID.'
    'Tag'                 = 'The git tag associated with the release.'
    'Latest'              = 'Return only the latest published release.'
    'IncludePrerelease'   = 'Include prerelease versions in results. By default, prereleases are excluded.'
    'WorkflowId'          = 'The workflow ID or filename (e.g. ''ci.yml'').'
    'WorkflowRunId'       = 'The workflow run ID.'
    'WorkflowJobId'       = 'The workflow job ID.'
    'Status'              = 'Filter workflow runs by status (e.g. completed, in_progress, success, failure).'
    'EventName'           = 'Filter workflow runs by the event that triggered them (e.g. push, pull_request).'
    'Filter'              = 'Filter jobs: ''latest'' for the most recent execution or ''all'' for every attempt.'
    'Inputs'              = 'Hashtable of input key-value pairs to pass to the workflow.'
    'HttpMethod'          = 'The HTTP method (GET, POST, PATCH, PUT, DELETE).'
    'Accept'              = 'The Accept header value for the API request. Defaults to ''application/vnd.github+json''.'
}

# --- Per-cmdlet synopsis, description, example, and related links ---
$CmdletInfo = @{
    'Get-GithubBranch' = @{
        Synopsis    = 'Gets branches from a GitHub repository.'
        Description = 'Gets branches from a GitHub repository. When a BranchId is specified, retrieves detailed information for that branch. Otherwise, lists all branches.'
        Example     = "Get-GithubBranch`nGet-GithubBranch main"
        Links       = 'https://docs.github.com/en/rest/branches/branches'
    }
    'New-GithubBranch' = @{
        Synopsis    = 'Creates a new branch in a GitHub repository.'
        Description = 'Creates a new branch in a GitHub repository. By default the branch is created from the repository''s default branch. Use -Ref to branch from a specific branch.'
        Example     = "New-GithubBranch 'feature/my-feature'"
        Links       = 'https://docs.github.com/en/rest/git/refs#create-a-reference'
    }
    'Remove-GithubBranch' = @{
        Synopsis    = 'Deletes a branch from a GitHub repository.'
        Description = 'Deletes a branch from a GitHub repository by removing the git reference.'
        Example     = "Remove-GithubBranch 'feature/my-feature'"
        Links       = 'https://docs.github.com/en/rest/git/refs#delete-a-reference'
    }
    'Get-GithubIssueComment' = @{
        Synopsis    = 'Gets comments on a GitHub issue.'
        Description = 'Gets comments on a GitHub issue. Returns all comments for the specified issue number.'
        Example     = 'Get-GithubIssueComment -IssueId 42'
        Links       = 'https://docs.github.com/en/rest/issues/comments#list-issue-comments'
    }
    'New-GithubIssueComment' = @{
        Synopsis    = 'Adds a comment to a GitHub issue.'
        Description = 'Creates a new comment on the specified GitHub issue.'
        Example     = "New-GithubIssueComment -IssueId 42 -Body 'This is a comment'"
        Links       = 'https://docs.github.com/en/rest/issues/comments#create-an-issue-comment'
    }
    'Get-GithubCommit' = @{
        Synopsis    = 'Gets commits from a GitHub repository.'
        Description = 'Gets commits from a GitHub repository. When a SHA is specified, retrieves detailed information for that commit. Otherwise, lists commits with optional filtering by branch, author, date range, and file path.'
        Example     = "Get-GithubCommit`nGet-GithubCommit -Branch main -Author octocat"
        Links       = 'https://docs.github.com/en/rest/commits/commits'
    }
    'Get-GithubConfiguration' = @{
        Synopsis    = 'Gets the current GitHub API authentication configuration.'
        Description = 'Returns the GitHub API authentication configuration. Checks, in order: GITHUB_TOKEN / GH_TOKEN environment variables, the GithubCli config file, and the gh CLI auth token.'
        Example     = 'Get-GithubConfiguration'
        Links       = 'https://github.com/chris-peterson/pwsh-github#authentication'
    }
    'Get-GithubEvent' = @{
        Synopsis    = 'Gets events from GitHub.'
        Description = 'Gets events from a GitHub repository, user, or organization. Events include pushes, pull requests, issues, and other activity.'
        Example     = "Get-GithubEvent`nGet-GithubEvent -Username octocat"
        Links       = 'https://docs.github.com/en/rest/activity/events'
    }
    'Get-GithubIssue' = @{
        Synopsis    = 'Gets issues from a GitHub repository.'
        Description = 'Gets issues from a GitHub repository. Can retrieve a single issue by ID, list repository issues, list organization issues, or list issues assigned to the authenticated user.'
        Example     = "Get-GithubIssue`nGet-GithubIssue 42`nGet-GithubIssue -Mine"
        Links       = 'https://docs.github.com/en/rest/issues/issues'
    }
    'New-GithubIssue' = @{
        Synopsis    = 'Creates a new issue in a GitHub repository.'
        Description = 'Creates a new issue in a GitHub repository with the specified title and optional description, assignees, labels, and milestone.'
        Example     = "New-GithubIssue -Title 'Bug: login fails'"
        Links       = 'https://docs.github.com/en/rest/issues/issues#create-an-issue'
    }
    'Update-GithubIssue' = @{
        Synopsis    = 'Updates an existing GitHub issue.'
        Description = 'Updates properties of an existing GitHub issue such as title, description, state, assignees, labels, and milestone.'
        Example     = "Update-GithubIssue 42 -State closed"
        Links       = 'https://docs.github.com/en/rest/issues/issues#update-an-issue'
    }
    'Close-GithubIssue' = @{
        Synopsis    = 'Closes a GitHub issue.'
        Description = 'Closes a GitHub issue by setting its state to closed.'
        Example     = 'Close-GithubIssue 42'
        Links       = 'https://docs.github.com/en/rest/issues/issues#update-an-issue'
    }
    'Open-GithubIssue' = @{
        Synopsis    = 'Reopens a closed GitHub issue.'
        Description = 'Reopens a closed GitHub issue by setting its state to open.'
        Example     = 'Open-GithubIssue 42'
        Links       = 'https://docs.github.com/en/rest/issues/issues#update-an-issue'
    }
    'Get-GithubLabel' = @{
        Synopsis    = 'Gets labels from a GitHub repository.'
        Description = 'Gets labels from a GitHub repository. When a Name is specified, retrieves that label. Otherwise, lists all labels.'
        Example     = "Get-GithubLabel`nGet-GithubLabel 'bug'"
        Links       = 'https://docs.github.com/en/rest/issues/labels'
    }
    'New-GithubLabel' = @{
        Synopsis    = 'Creates a new label in a GitHub repository.'
        Description = 'Creates a new label in a GitHub repository with the specified name, color, and optional description.'
        Example     = "New-GithubLabel -Name 'bug' -Color 'd73a4a'"
        Links       = 'https://docs.github.com/en/rest/issues/labels#create-a-label'
    }
    'Update-GithubLabel' = @{
        Synopsis    = 'Updates an existing label in a GitHub repository.'
        Description = 'Updates properties of an existing label such as name, color, and description.'
        Example     = "Update-GithubLabel 'bug' -Color 'ff0000'"
        Links       = 'https://docs.github.com/en/rest/issues/labels#update-a-label'
    }
    'Remove-GithubLabel' = @{
        Synopsis    = 'Deletes a label from a GitHub repository.'
        Description = 'Deletes a label from a GitHub repository.'
        Example     = "Remove-GithubLabel 'wontfix'"
        Links       = 'https://docs.github.com/en/rest/issues/labels#delete-a-label'
    }
    'Get-GithubOrganizationMember' = @{
        Synopsis    = 'Gets members of a GitHub organization.'
        Description = 'Gets members of a GitHub organization. Can check membership for a specific user or list all members with optional role filtering.'
        Example     = "Get-GithubOrganizationMember 'my-org'"
        Links       = 'https://docs.github.com/en/rest/orgs/members'
    }
    'Add-GithubOrganizationMember' = @{
        Synopsis    = 'Adds or updates a user''s membership in a GitHub organization.'
        Description = 'Sets organization membership for a user. Can be used to invite a new member or update an existing member''s role.'
        Example     = "Add-GithubOrganizationMember -Organization 'my-org' -Username 'octocat'"
        Links       = 'https://docs.github.com/en/rest/orgs/members#set-organization-membership-for-a-user'
    }
    'Remove-GithubOrganizationMember' = @{
        Synopsis    = 'Removes a member from a GitHub organization.'
        Description = 'Removes a user from a GitHub organization.'
        Example     = "Remove-GithubOrganizationMember -Organization 'my-org' -Username 'octocat'"
        Links       = 'https://docs.github.com/en/rest/orgs/members#remove-an-organization-member'
    }
    'Get-GithubRepositoryCollaborator' = @{
        Synopsis    = 'Gets collaborators of a GitHub repository.'
        Description = 'Gets collaborators of a GitHub repository. Can check if a specific user is a collaborator or list all collaborators with optional affiliation filtering.'
        Example     = 'Get-GithubRepositoryCollaborator'
        Links       = 'https://docs.github.com/en/rest/collaborators/collaborators'
    }
    'Add-GithubRepositoryCollaborator' = @{
        Synopsis    = 'Adds a collaborator to a GitHub repository.'
        Description = 'Adds a user as a collaborator to a GitHub repository with the specified permission level.'
        Example     = "Add-GithubRepositoryCollaborator 'octocat' -Permission push"
        Links       = 'https://docs.github.com/en/rest/collaborators/collaborators#add-a-repository-collaborator'
    }
    'Remove-GithubRepositoryCollaborator' = @{
        Synopsis    = 'Removes a collaborator from a GitHub repository.'
        Description = 'Removes a user from the collaborators of a GitHub repository.'
        Example     = "Remove-GithubRepositoryCollaborator 'octocat'"
        Links       = 'https://docs.github.com/en/rest/collaborators/collaborators#remove-a-repository-collaborator'
    }
    'Get-GithubMilestone' = @{
        Synopsis    = 'Gets milestones from a GitHub repository.'
        Description = 'Gets milestones from a GitHub repository. When a MilestoneId is specified, retrieves that milestone. Otherwise, lists milestones with optional filtering and sorting.'
        Example     = "Get-GithubMilestone`nGet-GithubMilestone 1"
        Links       = 'https://docs.github.com/en/rest/issues/milestones'
    }
    'New-GithubMilestone' = @{
        Synopsis    = 'Creates a new milestone in a GitHub repository.'
        Description = 'Creates a new milestone in a GitHub repository with the specified title and optional description, due date, and state.'
        Example     = "New-GithubMilestone -Title 'v1.0'"
        Links       = 'https://docs.github.com/en/rest/issues/milestones#create-a-milestone'
    }
    'Update-GithubMilestone' = @{
        Synopsis    = 'Updates an existing milestone in a GitHub repository.'
        Description = 'Updates properties of an existing milestone such as title, description, due date, and state.'
        Example     = "Update-GithubMilestone 1 -State closed"
        Links       = 'https://docs.github.com/en/rest/issues/milestones#update-a-milestone'
    }
    'Remove-GithubMilestone' = @{
        Synopsis    = 'Deletes a milestone from a GitHub repository.'
        Description = 'Deletes a milestone from a GitHub repository.'
        Example     = 'Remove-GithubMilestone 1'
        Links       = 'https://docs.github.com/en/rest/issues/milestones#delete-a-milestone'
    }
    'Get-GithubOrganization' = @{
        Synopsis    = 'Gets GitHub organizations.'
        Description = 'Gets GitHub organizations. Can retrieve a single organization by name, list organizations for a user, or list organizations for the authenticated user.'
        Example     = "Get-GithubOrganization`nGet-GithubOrganization 'my-org'"
        Links       = 'https://docs.github.com/en/rest/orgs/orgs'
    }
    'Get-GithubPullRequest' = @{
        Synopsis    = 'Gets pull requests from a GitHub repository.'
        Description = 'Gets pull requests from a GitHub repository. Can retrieve a single pull request by ID, list repository pull requests with optional filtering, or list pull requests authored by the authenticated user.'
        Example     = "Get-GithubPullRequest`nGet-GithubPullRequest 42`nGet-GithubPullRequest -Mine"
        Links       = 'https://docs.github.com/en/rest/pulls/pulls'
    }
    'New-GithubPullRequest' = @{
        Synopsis    = 'Creates a new pull request in a GitHub repository.'
        Description = 'Creates a new pull request in a GitHub repository with the specified title, source branch, and target branch.'
        Example     = "New-GithubPullRequest -Title 'Add feature' -SourceBranch 'feature/branch'"
        Links       = 'https://docs.github.com/en/rest/pulls/pulls#create-a-pull-request'
    }
    'Update-GithubPullRequest' = @{
        Synopsis    = 'Updates an existing pull request.'
        Description = 'Updates properties of an existing pull request such as title, description, state, target branch, and draft status.'
        Example     = "Update-GithubPullRequest 42 -Title 'Updated title'"
        Links       = 'https://docs.github.com/en/rest/pulls/pulls#update-a-pull-request'
    }
    'Merge-GithubPullRequest' = @{
        Synopsis    = 'Merges a GitHub pull request.'
        Description = 'Merges a GitHub pull request using the specified merge strategy. Optionally deletes the source branch after merging.'
        Example     = "Merge-GithubPullRequest 42 -MergeMethod squash"
        Links       = 'https://docs.github.com/en/rest/pulls/pulls#merge-a-pull-request'
    }
    'Close-GithubPullRequest' = @{
        Synopsis    = 'Closes a GitHub pull request.'
        Description = 'Closes a GitHub pull request by setting its state to closed without merging.'
        Example     = 'Close-GithubPullRequest 42'
        Links       = 'https://docs.github.com/en/rest/pulls/pulls#update-a-pull-request'
    }
    'Get-GithubPullRequestComment' = @{
        Synopsis    = 'Gets comments on a GitHub pull request.'
        Description = 'Gets comments on a GitHub pull request. Returns issue-level comments (not review comments).'
        Example     = 'Get-GithubPullRequestComment 42'
        Links       = 'https://docs.github.com/en/rest/issues/comments#list-issue-comments'
    }
    'New-GithubPullRequestComment' = @{
        Synopsis    = 'Adds a comment to a GitHub pull request.'
        Description = 'Creates a new comment on the specified GitHub pull request.'
        Example     = "New-GithubPullRequestComment 42 -Body 'LGTM'"
        Links       = 'https://docs.github.com/en/rest/issues/comments#create-an-issue-comment'
    }
    'Get-GithubRelease' = @{
        Synopsis    = 'Gets releases from a GitHub repository.'
        Description = 'Gets releases from a GitHub repository. Can retrieve a specific release by ID or tag, the latest release, or list all releases. By default, prereleases are excluded from list results.'
        Example     = "Get-GithubRelease`nGet-GithubRelease -Latest"
        Links       = 'https://docs.github.com/en/rest/releases/releases'
    }
    'Get-GithubRepository' = @{
        Synopsis    = 'Gets GitHub repositories.'
        Description = 'Gets GitHub repositories. Can retrieve a single repository by name, list repositories for an organization or user, or list repositories for the authenticated user.'
        Example     = "Get-GithubRepository`nGet-GithubRepository 'owner/repo'"
        Links       = 'https://docs.github.com/en/rest/repos/repos'
    }
    'New-GithubRepository' = @{
        Synopsis    = 'Creates a new GitHub repository.'
        Description = 'Creates a new GitHub repository for the authenticated user or within an organization.'
        Example     = "New-GithubRepository 'my-repo' -Visibility public"
        Links       = 'https://docs.github.com/en/rest/repos/repos#create-a-repository-for-the-authenticated-user'
    }
    'Update-GithubRepository' = @{
        Synopsis    = 'Updates a GitHub repository.'
        Description = 'Updates properties of an existing GitHub repository such as name, description, visibility, homepage, default branch, and archived status.'
        Example     = "Update-GithubRepository -Description 'Updated description'"
        Links       = 'https://docs.github.com/en/rest/repos/repos#update-a-repository'
    }
    'Remove-GithubRepository' = @{
        Synopsis    = 'Deletes a GitHub repository.'
        Description = 'Permanently deletes a GitHub repository. This action cannot be undone.'
        Example     = "Remove-GithubRepository 'owner/repo'"
        Links       = 'https://docs.github.com/en/rest/repos/repos#delete-a-repository'
    }
    'Search-Github' = @{
        Synopsis    = 'Searches GitHub using the search API.'
        Description = 'Searches across GitHub for code, commits, issues, repositories, or users using the GitHub search syntax.'
        Example     = "Search-Github 'filename:Dockerfile FROM node' -Scope code"
        Links       = 'https://docs.github.com/en/rest/search/search'
    }
    'Search-GithubRepository' = @{
        Synopsis    = 'Searches within a specific GitHub repository.'
        Description = 'Searches within a specific GitHub repository for code, commits, or issues. Automatically scopes the search query to the specified repository.'
        Example     = "Search-GithubRepository 'TODO' -Scope code"
        Links       = 'https://docs.github.com/en/rest/search/search'
    }
    'Get-GithubUser' = @{
        Synopsis    = 'Gets a GitHub user profile.'
        Description = 'Gets a GitHub user profile. Can retrieve a user by username or the authenticated user''s own profile.'
        Example     = "Get-GithubUser 'octocat'`nGet-GithubUser -Me"
        Links       = 'https://docs.github.com/en/rest/users/users'
    }
    'Invoke-GithubApi' = @{
        Synopsis    = 'Invokes the GitHub REST API directly.'
        Description = 'Sends an authenticated request to the GitHub REST API. Handles authentication, pagination, and serialization. This is the low-level function used by all other cmdlets in the module.'
        Example     = "Invoke-GithubApi GET 'repos/owner/repo'"
        Links       = 'https://docs.github.com/en/rest'
    }
    'Get-GithubWorkflow' = @{
        Synopsis    = 'Gets GitHub Actions workflows from a repository.'
        Description = 'Gets GitHub Actions workflows from a repository. Can retrieve a specific workflow by ID or list all workflows.'
        Example     = "Get-GithubWorkflow`nGet-GithubWorkflow 'ci.yml'"
        Links       = 'https://docs.github.com/en/rest/actions/workflows'
    }
    'Get-GithubWorkflowRun' = @{
        Synopsis    = 'Gets GitHub Actions workflow runs from a repository.'
        Description = 'Gets GitHub Actions workflow runs from a repository. Can retrieve a specific run by ID or list runs with optional filtering by workflow, branch, status, and trigger event.'
        Example     = "Get-GithubWorkflowRun`nGet-GithubWorkflowRun -Status failure"
        Links       = 'https://docs.github.com/en/rest/actions/workflow-runs'
    }
    'Get-GithubWorkflowJob' = @{
        Synopsis    = 'Gets jobs from a GitHub Actions workflow run.'
        Description = 'Gets jobs from a GitHub Actions workflow run. Can retrieve a specific job by ID or list all jobs for a run.'
        Example     = 'Get-GithubWorkflowRun | Get-GithubWorkflowJob'
        Links       = 'https://docs.github.com/en/rest/actions/workflow-jobs'
    }
    'Get-GithubWorkflowRunLog' = @{
        Synopsis    = 'Gets the log output for a GitHub Actions workflow job.'
        Description = 'Downloads and returns the log output for a specific GitHub Actions workflow job.'
        Example     = 'Get-GithubWorkflowRunLog 12345'
        Links       = 'https://docs.github.com/en/rest/actions/workflow-jobs#download-job-logs-for-a-workflow-run'
    }
    'Start-GithubWorkflowRun' = @{
        Synopsis    = 'Triggers a GitHub Actions workflow run.'
        Description = 'Dispatches a GitHub Actions workflow run. By default triggers on the repository''s default branch. Use -Ref to target a specific branch or tag, and -Inputs to pass workflow input parameters.'
        Example     = "Start-GithubWorkflowRun 'ci.yml'"
        Links       = 'https://docs.github.com/en/rest/actions/workflows#create-a-workflow-dispatch-event'
    }
}

# --- Output type descriptions ---
$OutputTypes = @{
    'Github.Issue'          = 'A GitHub issue object.'
    'Github.PullRequest'    = 'A GitHub pull request object.'
    'Github.Branch'         = 'A GitHub branch object.'
    'Github.Commit'         = 'A GitHub commit object.'
    'Github.Comment'        = 'A GitHub comment object.'
    'Github.Label'          = 'A GitHub label object.'
    'Github.Member'         = 'A GitHub member/collaborator object.'
    'Github.Milestone'      = 'A GitHub milestone object.'
    'Github.Organization'   = 'A GitHub organization object.'
    'Github.Release'        = 'A GitHub release object.'
    'Github.Repository'     = 'A GitHub repository object.'
    'Github.User'           = 'A GitHub user object.'
    'Github.Event'          = 'A GitHub event object.'
    'Github.Configuration'  = 'A GitHub API configuration object containing authentication details.'
    'Github.Workflow'       = 'A GitHub Actions workflow object.'
    'Github.WorkflowRun'    = 'A GitHub Actions workflow run object.'
    'Github.WorkflowJob'    = 'A GitHub Actions workflow job object.'
    'Github.SearchResult'   = 'A GitHub search result object.'
    'System.String'         = 'A string value.'
    'PSCustomObject'        = 'A PowerShell custom object.'
}

# --- Process each markdown file ---
$MdFiles = Get-ChildItem -Path $DocsRoot -Filter '*.md' -Recurse |
    Where-Object { $_.FullName -notlike '*/.support/*' }

$TotalReplacements = 0

foreach ($MdFile in $MdFiles) {
    $Content = Get-Content $MdFile.FullName -Raw -Encoding UTF8
    if ($Content -notmatch '\{\{') { continue }

    $CmdletName = $MdFile.BaseName
    $Info = $CmdletInfo[$CmdletName]

    if (-not $Info) { continue }

    $OriginalContent = $Content

    # Synopsis
    $Content = $Content -replace '\{\{ Fill in the Synopsis \}\}', $Info.Synopsis

    # Description (in the DESCRIPTION section)
    # Handle the ## DESCRIPTION section's placeholder
    $Content = $Content -replace '(?<=## DESCRIPTION\s*\r?\n\s*\r?\n)\{\{ Fill in the Description \}\}', $Info.Description

    # Input type description
    foreach ($TypeName in $OutputTypes.Keys) {
        $EscapedType = [regex]::Escape($TypeName)
        $Content = $Content -replace "(?<=### $EscapedType\s*\r?\n\s*\r?\n)\{\{ Fill in the Description \}\}", $OutputTypes[$TypeName]
    }

    # Output type description
    foreach ($TypeName in $OutputTypes.Keys) {
        $EscapedType = [regex]::Escape($TypeName)
        $Content = $Content -replace "(?<=### $EscapedType\s*\r?\n\s*\r?\n)\{\{ Fill in the Description \}\}", $OutputTypes[$TypeName]
    }

    # Any remaining "Fill in the Description" - use the cmdlet description
    $Content = $Content -replace '\{\{ Fill in the Description \}\}', $Info.Description

    # Parameter descriptions
    foreach ($ParamName in $ParamDescriptions.Keys) {
        $Content = $Content -replace "\{\{ Fill $ParamName Description \}\}", $ParamDescriptions[$ParamName]
    }

    # Notes - clear placeholder
    $Content = $Content -replace '\{\{ Fill in the Notes \}\}', ''

    # Related links
    if ($Info.Links) {
        $Content = $Content -replace '\{\{ Fill in the related links here \}\}', "[$($Info.Links)]($($Info.Links))"
    } else {
        $Content = $Content -replace '\{\{ Fill in the related links here \}\}', ''
    }

    # Example description
    if ($Info.Example) {
        $Content = $Content -replace '\{\{ Add example description here \}\}', $Info.Example
    }

    if ($Content -ne $OriginalContent) {
        $ReplacementCount = ([regex]::Matches($OriginalContent, '\{\{') | Measure-Object).Count -
                            ([regex]::Matches($Content, '\{\{') | Measure-Object).Count
        $TotalReplacements += $ReplacementCount
        [System.IO.File]::WriteAllText($MdFile.FullName, $Content)
        Write-Host "Updated $($MdFile.Name) ($ReplacementCount replacements)"
    }
}

Write-Host "`nTotal replacements: $TotalReplacements"

# Verify remaining placeholders
$Remaining = Get-ChildItem -Path $DocsRoot -Filter '*.md' -Recurse |
    Where-Object { $_.FullName -notlike '*/.support/*' } |
    Select-String -Pattern '\{\{\s*Fill\s' |
    Measure-Object
Write-Host "Remaining placeholders: $($Remaining.Count)"
