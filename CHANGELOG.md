# Changelog

All notable changes to GithubCli are recorded here, newest first.

## [Unreleased]

### Features
- Listings come back in a consistent order. Issues and pull requests are grouped by repository and ordered by number (`owner/repo#7` before `owner/repo#10`), repositories by full name, and anything carrying `UpdatedAt` or `LastActivityAt` (comments, milestones, workflow runs) newest first. Passing `-Sort` or `-Direction` keeps the order GitHub returned, and `Search-Github` keeps its best-match ranking: https://github.com/chris-peterson/pwsh-github/issues/12

### Bug Fixes
- Every result of a cross-repo listing names the repository it came from. `Get-GithubPullRequest -Mine`/`-Search`, `Get-GithubIssue -Mine`/`-Organization`, and `Search-Github -Scope issues` left `RepositoryId` unset, so branch refs and any piped follow-up call aimed at whatever repository the current directory pointed at: https://github.com/chris-peterson/pwsh-github/issues/4
- `ProjectPath` is empty for an object whose url doesn't carry one, instead of reporting the last path the caller happened to match.

## [0.11.0] - 2026-09-13

### Features
- `Set-GithubRepositoryCollaborator` aliases the collaborator upsert, so granting and changing access read the same: https://github.com/chris-peterson/pwsh-github/pull/9

### Bug Fixes
- Paged requests keep their authorization past the first page. Anything using `-All` over more than one page of results could come back truncated or fail with a 401: https://github.com/chris-peterson/pwsh-github/pull/11

## [0.10.0] - 2026-08-24

### Features
- https://github.com/chris-peterson/pwsh-github/pull/3
