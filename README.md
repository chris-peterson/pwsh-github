# pwsh-github

PowerShell module for Github automation.

## Status

**Early development** -- readonly operations for issues, repositories, and pull requests.

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
# List open issues for current repo
Get-GithubIssue

# Get a specific issue
Get-GithubIssue 42

# List closed issues
Get-GithubIssue -State closed

# Filter by assignee
Get-GithubIssue -Assignee 'octocat'

# Filter by labels
Get-GithubIssue -Labels 'bug,help wanted'

# Your issues across all repos
Get-GithubIssue -Mine
```

### Pull Requests

```powershell
# List open PRs for current repo
Get-GithubPullRequest

# Get a specific PR
Get-GithubPullRequest 123

# List all PRs (including closed)
Get-GithubPullRequest -State all

# Filter by branch
Get-GithubPullRequest -Head 'feature-branch'

# Your PRs
Get-GithubPullRequest -Mine

# Reviews for a PR
Get-GithubPullRequestReview 123
```

### Direct API Access

```powershell
# Call any Github API endpoint directly
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
