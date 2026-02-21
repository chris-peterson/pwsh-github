# pwsh-github

PowerShell module for Github automation.

## Getting Started

### Prerequisites

- PowerShell 7.1+

### Installing

```powershell
# Clone and import locally
git clone https://github.com/chris-peterson/pwsh-github.git
Import-Module ./pwsh-github/src/GithubCli/GithubCli.psd1
```

### Authentication

The module checks for credentials in this order:

1. **Environment variables** -- `GITHUB_TOKEN` or `GH_TOKEN`
2. **Github CLI** -- `gh auth token` (if `gh` is installed and authenticated)
3. **Config file** -- `~/.config/powershell/githubcli/config.yml`

```powershell
# Option 1: Environment variable
$env:GITHUB_TOKEN = 'ghp_...'

# Option 2: Github CLI (recommended for interactive use)
gh auth login

# Then import the module
Import-Module ./src/GithubCli/GithubCli.psd1
```

## Usage

### Context Awareness

Commands are context-aware.  When run inside a Github repository, `.` resolves to the current repo:

```powershell
cd ~/src/my-github-repo
Get-GithubIssue           # lists issues for the current repo
Get-GithubPullRequest     # lists PRs for the current repo
Get-GithubRepository      # gets info about the current repo
```

### Repositories

```powershell
# Current repository
Get-GithubRepository

# By owner/name
Get-GithubRepository 'chris-peterson/pwsh-github'

# List org repos
Get-GithubRepository -Organization 'my-org'

# List your repos
Get-GithubRepository -Mine
```

### Issues

```powershell
# List open issues
Get-GithubIssue

# Get a specific issue
Get-GithubIssue 42

# Filter by state, assignee, labels
Get-GithubIssue -State closed
Get-GithubIssue -Assignee 'octocat'
Get-GithubIssue -Labels 'bug,help wanted'

# Your issues across all repos
Get-GithubIssue -Mine

# Create, update, close
New-GithubIssue -Title 'Bug report' -Labels 'bug'
Update-GithubIssue 42 -Title 'Updated title'
Close-GithubIssue 42
```

### Pull Requests

```powershell
# List open PRs
Get-GithubPullRequest

# Get a specific PR
Get-GithubPullRequest 123

# Create, merge, close
New-GithubPullRequest -Title 'My feature' -SourceBranch 'feature-branch'
Merge-GithubPullRequest 123 -MergeMethod squash -DeleteSourceBranch
Close-GithubPullRequest 123
```

### Branches

```powershell
Get-GithubBranch
New-GithubBranch 'feature-branch'
Remove-GithubBranch 'feature-branch'
```

### Pipeline Chaining

Objects carry their parent identifiers, so you can pipe between commands without repeating parameters:

```powershell
# Close an issue (RepositoryId flows through the pipeline)
Get-GithubIssue 42 | Close-GithubIssue

# Get comments for an issue
Get-GithubIssue 42 | Get-GithubIssueComment

# Comment on a PR
Get-GithubPullRequest 123 | New-GithubPullRequestComment -Body 'LGTM'

# Merge a PR
Get-GithubPullRequest 123 | Merge-GithubPullRequest -MergeMethod squash

# Create a branch from a repository
Get-GithubRepository | New-GithubBranch -Name 'feature-branch'

# Get jobs for a workflow run
Get-GithubWorkflowRun 456 | Get-GithubWorkflowJob
```

### Labels, Milestones, Releases

```powershell
Get-GithubLabel
New-GithubLabel -Name 'priority' -Color 'ff0000'

Get-GithubMilestone
New-GithubMilestone -Title 'v2.0'

Get-GithubRelease
Get-GithubRelease -Latest
```

### Workflows

```powershell
Get-GithubWorkflow
Get-GithubWorkflowRun -Status completed
Get-GithubWorkflowRun 789 | Get-GithubWorkflowJob

Start-GithubWorkflowRun -WorkflowId 'ci.yml'
```

### Search

```powershell
Search-Github 'error handling' -Scope code
Search-GithubRepository 'TODO' -Scope code
```

### Direct API Access

```powershell
Invoke-GithubApi GET 'repos/chris-peterson/pwsh-github/contributors'
```

## Forge Ecosystem

`GithubCli` is part of the **pwsh-forge** ecosystem — a unified PowerShell interface across software forges.
`GithubCli` works standalone, but also integrates with [ForgeCli](https://github.com/chris-peterson/pwsh-forge)
so that commands like `Get-Issue` are automatically handled by the correct provider.

```powershell
Import-Module GithubCli
Import-Module ForgeCli

cd ~/src/my-github-project
Get-Issue              # routes to Get-GithubIssue
Get-ChangeRequest       # routes to Get-GithubPullRequest
```

| Module | Purpose |
|--------|---------|
| [pwsh-forge](https://github.com/chris-peterson/pwsh-forge) | Unified dispatch layer |
| **pwsh-github** | Github provider (this module) |
| [pwsh-gitlab](https://github.com/chris-peterson/pwsh-gitlab) | GitLab provider |
