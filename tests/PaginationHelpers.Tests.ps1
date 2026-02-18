BeforeAll {
    . $PSScriptRoot/../src/GitHubCli/Private/Globals.ps1
    . $PSScriptRoot/../src/GitHubCli/Private/Functions/PaginationHelpers.ps1
}

Describe "Resolve-GithubMaxPages" {

    Context "When neither MaxPages nor All is specified" {
        It "Should return the global default" {
            $Result = Resolve-GithubMaxPages
            $Result | Should -Be $global:GithubDefaultMaxPages
        }
    }

    Context "When MaxPages is 0" {
        It "Should return the global default" {
            $Result = Resolve-GithubMaxPages -MaxPages 0
            $Result | Should -Be $global:GithubDefaultMaxPages
        }
    }

    Context "When MaxPages is specified" {
        It "Should return the specified value" {
            $Result = Resolve-GithubMaxPages -MaxPages 5
            $Result | Should -Be 5
        }
    }

    Context "When -All is specified" {
        It "Should return uint max value" {
            $Result = Resolve-GithubMaxPages -All
            $Result | Should -Be ([uint]::MaxValue)
        }

        It "Should ignore MaxPages when -All is specified" {
            $Result = Resolve-GithubMaxPages -MaxPages 5 -All
            $Result | Should -Be ([uint]::MaxValue)
        }

        It "Should warn when MaxPages differs from default and -All is specified" {
            $Result = Resolve-GithubMaxPages -MaxPages 5 -All -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Match "Ignoring -MaxPages in favor of -All"
        }
    }
}
