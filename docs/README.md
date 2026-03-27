# <img src="favicon.svg" width="64" height="64" style="vertical-align: middle"/>GithubCli

> PowerShell module for GitHub automation

[![GitHub](https://img.shields.io/github/license/chris-peterson/pwsh-github)](https://github.com/chris-peterson/pwsh-github/blob/main/LICENSE)

## Overview

`GithubCli` is a PowerShell module that provides cmdlets for interacting with the GitHub REST API. It enables automation of GitHub operations directly from PowerShell.

## Installation

```powershell
git clone https://github.com/chris-peterson/pwsh-github.git
Import-Module ./pwsh-github/src/GithubCli/GithubCli.psd1
```

## Quick Start

### 1. Configure Authentication

**Option A: GitHub CLI** (recommended for interactive use)

```powershell
gh auth login
```

**Option B: Environment Variables** (simple, CI/CD)

```powershell
$env:GITHUB_TOKEN = 'ghp_...'
```

**Option C: Config File** (multiple tokens)

```powershell
# ~/.config/powershell/githubcli/config.yml
```

### 2. Start Using

```powershell
# Context-aware — run inside a GitHub repo
Get-GithubRepository
Get-GithubIssue
Get-GithubPullRequest

# Pipeline chaining
Get-GithubIssue 42 | Close-GithubIssue
Get-GithubPullRequest 123 | Merge-GithubPullRequest -MergeMethod squash
```

## Getting Help

Use PowerShell's built-in help:

```powershell
# List all cmdlets
Get-Command -Module GithubCli

# Get help for a specific cmdlet
Get-Help Get-GithubRepository -Full
```

## Cmdlet Categories

Browse the sidebar to find cmdlets organized by category:

- [Branches](Branches/) - Manage repository branches
- [Comments](Comments/) - Issue and PR comments
- [Commits](Commits/) - View commit information
- [Config](Config/) - Module configuration
- [Events](Events/) - Repository events
- [Issues](Issues/) - Work with issues
- [Labels](Labels/) - Manage labels
- [Members](Members/) - Organization and repository members
- [Milestones](Milestones/) - Track milestones
- [Organizations](Organizations/) - Organization information
- [PullRequests](PullRequests/) - Handle pull requests
- [Releases](Releases/) - Manage releases
- [Repositories](Repositories/) - Manage repositories
- [Search](Search/) - Search GitHub
- [Users](Users/) - User information
- [Utilities](Utilities/) - Helper utilities
- [Workflows](Workflows/) - GitHub Actions workflows

## Links

- [GitHub Repository](https://github.com/chris-peterson/pwsh-github)
- [GitHub API Documentation](https://docs.github.com/en/rest)
