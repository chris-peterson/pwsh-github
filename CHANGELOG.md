# Changelog

All notable changes to GithubCli are recorded here, newest first.

## [Unreleased]

## [0.11.0] - 2026-09-13

### Features
- `Set-GithubRepositoryCollaborator` aliases the collaborator upsert, so granting and changing access read the same: https://github.com/chris-peterson/pwsh-github/pull/9

### Bug Fixes
- Paged requests keep their authorization past the first page. Anything using `-All` over more than one page of results could come back truncated or fail with a 401: https://github.com/chris-peterson/pwsh-github/pull/11

## [0.10.0] - 2026-08-24

### Features
- https://github.com/chris-peterson/pwsh-github/pull/3
