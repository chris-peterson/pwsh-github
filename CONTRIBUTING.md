# Contributing to pwsh-github

Thanks for your interest in contributing! This document outlines how to set up your development environment and the tools we use.

## Prerequisites

| Tool | Version | Installation |
|------|---------|--------------|
| [PowerShell](https://github.com/PowerShell/PowerShell) | 7.1+ | `brew install powershell` (macOS) |
| [just](https://just.systems) | latest | `brew install just` (macOS) |

## Development Workflow

We use [just](https://just.systems) as a task runner. The default task runs tests and lint:

```sh
just
```

| Recipe | What it does |
|--------|--------------|
| `just test` | Run the Pester suite in `tests/` |
| `just lint` | Run PSScriptAnalyzer over `src/` |
| `just docs` | Serve the docsify site locally |
| `just help-export` | Export MAML help into `src/GithubCli/en-US/` |
| `just release-preview VERSION` | Show the manifest and changelog edits a release would make |

## Tooling

### Testing — [Pester](https://pester.dev/)

Tests live in `tests/`. We use Pester v5+.

### Documentation — [PlatyPS](https://github.com/PowerShell/platyps)

Cmdlet documentation is generated from code comments using PlatyPS and published to GitHub Pages. Documentation lives in `docs/`.

Run `docs/.support/scripts/Update-Help.ps1` after adding or renaming parameters. It syncs structural metadata (types, parameter sets, aliases) while preserving hand-written descriptions.

### Security Analysis

[PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) runs locally via `just lint` and in CI. Configuration is in `PSScriptAnalyzerSettings.ps1`.

## Releasing

**A feature pull request needs no manifest change.** Don't bump `ModuleVersion` and don't touch `ReleaseNotes`; the release job sets both. Add a line under `## [Unreleased]` in `CHANGELOG.md` instead if the change is worth a release note.

`CHANGELOG.md` keeps an `## [Unreleased]` section at the top, and that section is where release notes come from. Appending to it as you work is welcome but not required; whoever cuts the release reviews it and backfills whatever is missing.

Releases are driven by [GitHub Releases](https://github.com/chris-peterson/pwsh-github/releases). Publishing a release is the trigger; the tag carries the version:

- The **tag** is the version, `v`-prefixed (e.g. `v0.11.0`). CI strips the `v`, so `ModuleVersion` reads `0.11.0`.
- The **notes** are whatever `Unreleased` holds at that moment. The release body you type is replaced with them, so leaving it blank is fine.

On publish, the `release` job:

1. Promotes `Unreleased` into a dated `## [<version>]` section, leaves a fresh empty `Unreleased` behind, and writes that same text into `GitHubCli.psd1` `ModuleVersion` and `ReleaseNotes`.
2. Exports MAML help so the published module carries current help.
3. Publishes the module to the PowerShell Gallery.
4. Sets the GitHub Release body to the promoted notes, so the releases page reads the same as the changelog.
5. Commits the manifest and changelog back to `main`.

Dispatching a release with an empty `Unreleased` fails the job, so record what changed before publishing.

The commit-back runs last so that a failed publish leaves `main` without a commit claiming a release that never shipped.

To preview the manifest and changelog edits a release will make:

```sh
just release-preview v0.11.0
```

Cut releases from a tag at `main`'s HEAD. The test and security gates run against the tag, but the `release` job checks out `main` (it has to, to commit the version bump back), so a tag behind `main` publishes `main`'s code rather than the code the gates checked.

The commit-back uses the built-in `GITHUB_TOKEN`. If `main` becomes a protected branch, that token needs permission to push to it.

## Making Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run `just` to verify tests pass and no lint errors
5. Run `docs/.support/scripts/Update-Help.ps1` if you added or modified cmdlets
6. Add a line under `## [Unreleased]` in `CHANGELOG.md` if the change is worth a release note
7. Commit your changes
8. Open a Pull Request

## Code Style

- Follow [PowerShell Best Practices](https://poshcode.gitbook.io/powershell-practice-and-style/)
- Use approved verbs for cmdlet names (`Get-Verb` to see the list)
- Add tests for new functionality
- Avoid inline commenting (except when necessary); instead, prefer
  intention-revealing code.  Often a well-named function removes
  the need for a comment.
