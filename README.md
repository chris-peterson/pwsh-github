# pwsh-github

PowerShell module for GitHub automation.

## Status

**Early development** -- readonly operations for issues, repositories, and pull requests.

## Getting Started

### Prerequisites

- PowerShell 7.1+

### Installing

```powershell
# Clone and import locally
git clone https://github.com/chris-peterson/pwsh-github.git
Import-Module ./pwsh-github/src/GitHubCli/GitHubCli.psd1
```

### Authentication

The module checks for credentials in this order:

1. **Environment variables** -- `GITHUB_TOKEN` or `GH_TOKEN`
2. **GitHub CLI** -- `gh auth token` (if `gh` is installed and authenticated)
3. **Config file** -- `~/.config/powershell/githubcli/config.yml`

```powershell
# Option 1: Environment variable
$env:GITHUB_TOKEN = 'ghp_...'

# Option 2: GitHub CLI (recommended for interactive use)
gh auth login

# Then import the module
Import-Module ./src/GitHubCli/GitHubCli.psd1
```

## Usage

### Context Awareness

Commands are context-aware.  When run inside a GitHub repository, `.` resolves to the current repo:

```powershell
cd ~/src/my-github-repo
Get-GitHubIssue           # lists issues for the current repo
Get-GitHubPullRequest     # lists PRs for the current repo
Get-GitHubRepository      # gets info about the current repo
```

### Repositories

```powershell
# Current repository
Get-GitHubRepository

# By owner/name
Get-GitHubRepository 'chris-peterson/pwsh-github'

# List org repos
Get-GitHubRepository -Organization 'my-org'

# List your repos
Get-GitHubRepository -Mine
```

### Issues

```powershell
# List open issues for current repo
Get-GitHubIssue

# Get a specific issue
Get-GitHubIssue 42

# List closed issues
Get-GitHubIssue -State closed

# Filter by assignee
Get-GitHubIssue -Assignee 'octocat'

# Filter by labels
Get-GitHubIssue -Labels 'bug,help wanted'

# Your issues across all repos
Get-GitHubIssue -Mine
```

### Pull Requests

```powershell
# List open PRs for current repo
Get-GitHubPullRequest

# Get a specific PR
Get-GitHubPullRequest 123

# List all PRs (including closed)
Get-GitHubPullRequest -State all

# Filter by branch
Get-GitHubPullRequest -Head 'feature-branch'

# Your PRs
Get-GitHubPullRequest -Mine

# Reviews for a PR
Get-GitHubPullRequestReview 123
```

### Direct API Access

```powershell
# Call any GitHub API endpoint directly
Invoke-GitHubApi GET 'repos/chris-peterson/pwsh-github/contributors'
```

## Forge Ecosystem

`GitHubCli` is part of the **pwsh-forge** ecosystem — a unified PowerShell interface across software forges.
`GitHubCli` works standalone, but also integrates with [ForgeCli](https://github.com/chris-peterson/pwsh-forge)
so that commands like `Get-Issue` are automatically handled by the correct provider.

```powershell
Import-Module GitHubCli
Import-Module ForgeCli

cd ~/src/my-github-project
Get-Issue              # routes to Get-GitHubIssue
Get-ChangeRequest       # routes to Get-GitHubPullRequest
```

| Module | Purpose |
|--------|---------|
| [pwsh-forge](https://github.com/chris-peterson/pwsh-forge) | Unified dispatch layer |
| **pwsh-github** | GitHub provider (this module) |
| [pwsh-gitlab](https://github.com/chris-peterson/pwsh-gitlab) | GitLab provider |
