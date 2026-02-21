BeforeAll {
    Get-Module GitlabCli -All | Remove-Module -Force -ErrorAction SilentlyContinue

    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/PaginationHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1

    function global:Invoke-GithubApi { param($HttpMethod, $Path, [hashtable]$Query, [hashtable]$Body, $MaxPages, $Accept) }
    function global:Resolve-GithubRepository { param($Repository) }
    function global:Resolve-GithubMaxPages { param($MaxPages, [switch]$All) }
    function global:New-GithubObject {
        param([Parameter(ValueFromPipeline)]$InputObject, [Parameter(Position=0)][string]$DisplayType)
        Begin{}
        Process {
            foreach ($item in $InputObject) {
                if ($item -is [hashtable]) { $item = [PSCustomObject]$item }
                $Wrapper = New-Object PSObject
                $item.PSObject.Properties | ForEach-Object {
                    $Wrapper | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
                }
                if ($DisplayType) { $Wrapper.PSTypeNames.Insert(0, $DisplayType) }
                Write-Output $Wrapper
            }
        }
        End{}
    }
    function global:Get-FilteredObject {
        param([Parameter(ValueFromPipeline)]$InputObject, [Parameter(Position=0)][string]$Select)
        process { $InputObject }
    }

    Import-Module $PSScriptRoot/../src/GithubCli/Workflows.psm1 -Force
}

AfterAll {
    Remove-Module Workflows -ErrorAction SilentlyContinue
    Remove-Item function:Invoke-GithubApi -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubRepository -ErrorAction SilentlyContinue
    Remove-Item function:Resolve-GithubMaxPages -ErrorAction SilentlyContinue
    Remove-Item function:New-GithubObject -ErrorAction SilentlyContinue
    Remove-Item function:Get-FilteredObject -ErrorAction SilentlyContinue
}

Describe 'Get-GithubWorkflow' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Workflows
    }

    It 'Should call list endpoint and expand .workflows' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 2
                workflows = @(
                    [PSCustomObject]@{ id = 1; name = 'CI'; path = '.github/workflows/ci.yml'; state = 'active' }
                    [PSCustomObject]@{ id = 2; name = 'Release'; path = '.github/workflows/release.yml'; state = 'active' }
                )
            }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflow -RepositoryId 'owner/repo'
        $Result | Should -HaveCount 2
        $Result[0].Name | Should -Be 'CI'
        $Result[1].Name | Should -Be 'Release'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/workflows'
        }
    }

    It 'Should call single endpoint when WorkflowId is provided' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 123; name = 'CI'; path = '.github/workflows/ci.yml'; state = 'active' }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflow -RepositoryId 'owner/repo' -WorkflowId 123
        $Result.Name | Should -Be 'CI'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/workflows/123'
        }
    }

    It 'Should accept workflow filename as WorkflowId' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 456; name = 'Deploy'; path = '.github/workflows/deploy.yml'; state = 'active' }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflow -RepositoryId 'owner/repo' -WorkflowId 'deploy.yml'
        $Result.Name | Should -Be 'Deploy'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/workflows/deploy.yml'
        }
    }
}

Describe 'Get-GithubWorkflowRun' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Workflows
    }

    It 'Should call list endpoint and expand .workflow_runs' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 1
                workflow_runs = @(
                    [PSCustomObject]@{ id = 100; name = 'CI'; status = 'completed'; conclusion = 'success'; html_url = 'https://github.com/owner/repo/actions/runs/100' }
                )
            }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflowRun -RepositoryId 'owner/repo'
        $Result | Should -HaveCount 1
        $Result[0].Name | Should -Be 'CI'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/runs'
        }
    }

    It 'Should call single endpoint when WorkflowRunId is provided' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 200; name = 'CI'; status = 'completed'; conclusion = 'failure' }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflowRun -RepositoryId 'owner/repo' -WorkflowRunId 200
        $Result.Conclusion | Should -Be 'failure'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/runs/200'
        }
    }

    It 'Should pass query parameters for filtering' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 0
                workflow_runs = @()
            }
        } -ModuleName Workflows

        Get-GithubWorkflowRun -RepositoryId 'owner/repo' -Branch 'main' -Status 'success' -Event 'push'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/actions/runs' -and
            $Query.branch -eq 'main' -and
            $Query.status -eq 'success' -and
            $Query.event -eq 'push'
        }
    }

    It 'Should pass workflow_id query parameter' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 0
                workflow_runs = @()
            }
        } -ModuleName Workflows

        Get-GithubWorkflowRun -RepositoryId 'owner/repo' -WorkflowId 42
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $Query.workflow_id -eq 42
        }
    }
}

Describe 'Get-GithubWorkflowJob' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Workflows
    }

    It 'Should call jobs-by-run endpoint and expand .jobs' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 2
                jobs = @(
                    [PSCustomObject]@{ id = 10; name = 'build'; status = 'completed'; conclusion = 'success' }
                    [PSCustomObject]@{ id = 11; name = 'test'; status = 'completed'; conclusion = 'success' }
                )
            }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflowJob -RepositoryId 'owner/repo' -WorkflowRunId 100
        $Result | Should -HaveCount 2
        $Result[0].Name | Should -Be 'build'
        $Result[1].Name | Should -Be 'test'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/runs/100/jobs'
        }
    }

    It 'Should call single job endpoint when WorkflowJobId is provided' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{ id = 10; name = 'build'; status = 'completed'; conclusion = 'success' }
        } -ModuleName Workflows

        $Result = Get-GithubWorkflowJob -RepositoryId 'owner/repo' -WorkflowJobId 10
        $Result.Name | Should -Be 'build'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo/actions/jobs/10'
        }
    }

    It 'Should pass filter query parameter' {
        Mock Invoke-GithubApi {
            [PSCustomObject]@{
                total_count = 0
                jobs = @()
            }
        } -ModuleName Workflows

        Get-GithubWorkflowJob -RepositoryId 'owner/repo' -WorkflowRunId 100 -Filter 'latest'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $Query.filter -eq 'latest'
        }
    }
}

Describe 'Get-GithubWorkflowRunLog' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Workflows
    }

    It 'Should call job logs endpoint with correct accept header' {
        Mock Invoke-GithubApi { 'log line 1\nlog line 2' } -ModuleName Workflows

        $Result = Get-GithubWorkflowRunLog -RepositoryId 'owner/repo' -WorkflowJobId 10
        $Result | Should -Be 'log line 1\nlog line 2'
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'GET' -and
            $Path -eq 'repos/owner/repo/actions/jobs/10/logs' -and
            $Accept -eq 'application/vnd.github+json'
        }
    }
}

Describe 'Start-GithubWorkflowRun' {
    BeforeEach {
        Mock Resolve-GithubRepository { 'owner/repo' } -ModuleName Workflows
    }

    It 'Should fetch default branch and dispatch workflow' {
        Mock Invoke-GithubApi {
            if ($Path -eq 'repos/owner/repo') {
                return [PSCustomObject]@{ default_branch = 'main' }
            }
        } -ModuleName Workflows

        Start-GithubWorkflowRun -RepositoryId 'owner/repo' -WorkflowId 'ci.yml' -Confirm:$false
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Path -eq 'repos/owner/repo/actions/workflows/ci.yml/dispatches' -and
            $Body.ref -eq 'main'
        }
    }

    It 'Should use provided Ref instead of fetching default branch' {
        Mock Invoke-GithubApi {} -ModuleName Workflows

        Start-GithubWorkflowRun -RepositoryId 'owner/repo' -WorkflowId 'ci.yml' -Ref 'develop' -Confirm:$false
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -Times 1 -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Body.ref -eq 'develop'
        }
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -Times 0 -ParameterFilter {
            $HttpMethod -eq 'GET' -and $Path -eq 'repos/owner/repo'
        }
    }

    It 'Should include inputs in body when provided' {
        Mock Invoke-GithubApi {} -ModuleName Workflows

        Start-GithubWorkflowRun -RepositoryId 'owner/repo' -WorkflowId 'ci.yml' -Ref 'main' -Inputs @{ environment = 'staging' } -Confirm:$false
        Should -Invoke Invoke-GithubApi -ModuleName Workflows -ParameterFilter {
            $HttpMethod -eq 'POST' -and
            $Body.ref -eq 'main' -and
            $Body.inputs.environment -eq 'staging'
        }
    }
}
