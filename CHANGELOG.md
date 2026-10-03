# Changelog

All notable changes to GithubCli are recorded here, newest first.

## [Unreleased]

### Features
- Pull requests carry the properties ForgeCli's output contract reads: `Forge` (`github`), `Host` (the web host, such as `github.com` or a GitHub Enterprise host), `Description` (the body), and `AuthorUsername` (the author's login).

### Breaking Changes
- A merged pull request reports `State` as `merged`. GitHub returns `closed` for both merged and unmerged pull requests; a script that treated `closed` as including merged ones should check for `merged` as well.
- A pull request's `Id` is its number (`17` for `#17`), matching `PullRequestId` and GitLab's merge requests. The API's global id moves to `DatabaseId`.

### Bug Fixes
- Every result of a cross-repo listing names the repository it came from. `Get-GithubPullRequest -Mine`/`-Search`, `Get-GithubIssue -Mine`/`-Organization`, and `Search-Github -Scope issues` left `RepositoryId` unset, so branch refs and any piped follow-up call aimed at whatever repository the current directory pointed at: https://github.com/chris-peterson/pwsh-github/issues/4
- `ProjectPath` is empty for an object whose url doesn't carry one, instead of reporting the last path the caller happened to match.
- GithubCli works when another module imports it, as ForgeCli does. Its internal helpers loaded into the importing module's scope, so commands failed with errors like `The term 'Resolve-GithubMaxPages' is not recognized`; they now load into the global scope, as an interactive import already did.

## [0.11.0] - 2026-09-13

### Features
- `Set-GithubRepositoryCollaborator` aliases the collaborator upsert, so granting and changing access read the same: https://github.com/chris-peterson/pwsh-github/pull/9

### Bug Fixes
- Paged requests keep their authorization past the first page. Anything using `-All` over more than one page of results could come back truncated or fail with a 401: https://github.com/chris-peterson/pwsh-github/pull/11

## [0.10.0] - 2026-08-24

### Features
- https://github.com/chris-peterson/pwsh-github/pull/3
