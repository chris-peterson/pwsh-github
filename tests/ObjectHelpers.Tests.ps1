BeforeAll {
    . $PSScriptRoot/../src/GithubCli/Private/Functions/StringHelpers.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Globals.ps1
    . $PSScriptRoot/../src/GithubCli/Private/Functions/ObjectHelpers.ps1
}

Describe "New-GithubObject" {

    Context "Property conversion" {
        It "Should convert snake_case properties to PascalCase" {
            $Input = [PSCustomObject]@{ first_name = 'John'; last_name = 'Doe' }
            $Result = $Input | New-GithubObject
            $Result.FirstName | Should -Be 'John'
            $Result.LastName | Should -Be 'Doe'
        }

        It "Should preserve property values" {
            $Input = [PSCustomObject]@{ count = 123; active = $true; items = @(1,2,3) }
            $Result = $Input | New-GithubObject
            $Result.Count | Should -Be 123
            $Result.Active | Should -Be $true
            $Result.Items | Should -HaveCount 3
        }

        It "Should parse ISO datetime strings" {
            $Input = [PSCustomObject]@{ created_at = '2024-03-15T14:30:00Z' }
            $Result = $Input | New-GithubObject
            $Result.CreatedAt | Should -BeOfType [datetime]
        }

        It "Should not parse non-datetime strings" {
            $Input = [PSCustomObject]@{ name = 'test-2024-value'; version = '1.2.3' }
            $Result = $Input | New-GithubObject
            $Result.Name | Should -BeOfType [string]
            $Result.Version | Should -BeOfType [string]
        }
    }

    Context "URL aliasing" {
        It "Should prefer html_url over url for the Url property" {
            $Input = [PSCustomObject]@{
                url      = 'https://api.github.com/repos/owner/repo/issues/1'
                html_url = 'https://github.com/owner/repo/issues/1'
            }
            $Result = $Input | New-GithubObject
            $Result.Url | Should -Be 'https://github.com/owner/repo/issues/1'
        }

        It "Should keep original Url when no html_url exists" {
            $Input = [PSCustomObject]@{ url = 'https://api.github.com/something' }
            $Result = $Input | New-GithubObject
            $Result.Url | Should -Be 'https://api.github.com/something'
        }
    }

    Context "DisplayType" {
        It "Should set PSTypeName when DisplayType is provided" {
            $Input = [PSCustomObject]@{ number = 1; title = 'test' }
            $Result = $Input | New-GithubObject 'Github.Issue'
            $Result.PSTypeNames | Should -Contain 'Github.Issue'
        }

        It "Should not set PSTypeName when DisplayType is not provided" {
            $Input = [PSCustomObject]@{ id = 1; name = 'test' }
            $Result = $Input | New-GithubObject
            $Result.PSTypeNames | Should -Not -Contain 'Github.Issue'
        }
    }

    Context "Identity field aliasing" {
        It "Should create IssueId from Number for Github.Issue" {
            $Input = [PSCustomObject]@{ number = 42; title = 'Test Issue' }
            $Result = $Input | New-GithubObject 'Github.Issue'
            $Result.IssueId | Should -Be 42
            $Result.Number | Should -Be 42
        }

        It "Should create PullRequestId from Number for Github.PullRequest" {
            $Input = [PSCustomObject]@{ number = 99; title = 'Test PR' }
            $Result = $Input | New-GithubObject 'Github.PullRequest'
            $Result.PullRequestId | Should -Be 99
        }

        It "Should create RepositoryId from Id for Github.Repository" {
            $Input = [PSCustomObject]@{ id = 12345; name = 'my-repo' }
            $Result = $Input | New-GithubObject 'Github.Repository'
            $Result.RepositoryId | Should -Be 12345
        }
    }

    Context "Pipeline support" {
        It "Should process multiple objects from pipeline" {
            $Items = @(
                [PSCustomObject]@{ id = 1; name = 'first' }
                [PSCustomObject]@{ id = 2; name = 'second' }
                [PSCustomObject]@{ id = 3; name = 'third' }
            )
            $Results = $Items | New-GithubObject
            $Results | Should -HaveCount 3
            $Results[0].Id | Should -Be 1
            $Results[2].Id | Should -Be 3
        }
    }
}

Describe "Add-CoalescedProperty" {

    Context "Basic aliasing" {
        It "Should add alias property when source exists" {
            $Obj = [PSCustomObject]@{ HtmlUrl = 'https://github.com/test' }
            $Obj | Add-CoalescedProperty -From 'HtmlUrl' -To 'Url'
            $Obj.Url | Should -Be 'https://github.com/test'
        }

        It "Should not add alias when source property is null" {
            $Obj = [PSCustomObject]@{ HtmlUrl = $null }
            $Obj | Add-CoalescedProperty -From 'HtmlUrl' -To 'Url'
            $Obj.PSObject.Properties.Name | Should -Not -Contain 'Url'
        }

        It "Should not overwrite existing property" {
            $Obj = [PSCustomObject]@{ HtmlUrl = 'https://github.com/test'; Url = 'existing' }
            $Obj | Add-CoalescedProperty -From 'HtmlUrl' -To 'Url'
            $Obj.Url | Should -Be 'existing'
        }
    }

    Context "Multiple source properties" {
        It "Should use first non-null property from array" {
            $Obj = [PSCustomObject]@{ HtmlUrl = 'https://html.com'; WebUrl = 'https://web.com' }
            $Obj | Add-CoalescedProperty -From @('HtmlUrl', 'WebUrl') -To 'Url'
            $Obj.Url | Should -Be 'https://html.com'
        }

        It "Should fall back to second property when first is null" {
            $Obj = [PSCustomObject]@{ HtmlUrl = $null; WebUrl = 'https://web.com' }
            $Obj | Add-CoalescedProperty -From @('HtmlUrl', 'WebUrl') -To 'Url'
            $Obj.Url | Should -Be 'https://web.com'
        }
    }
}

Describe "New-GithubObject default ordering" {
    BeforeAll {
        # Stand-ins for Types.ps1xml, so each rung is exercised on its own.
        Update-TypeData -TypeName 'Github.SortTest.Keyed' -DefaultKeyPropertySet Name -Force
        Update-TypeData -TypeName 'Github.SortTest.Activity' -MemberType ScriptProperty -MemberName LastActivityAt -Value { $this.PushedAt } -Force

        function Get-Names { param([Parameter(ValueFromPipeline)] $InputObject) process { $InputObject.Name } }
    }

    AfterAll {
        Remove-TypeData -TypeName 'Github.SortTest.Keyed' -ErrorAction SilentlyContinue
        Remove-TypeData -TypeName 'Github.SortTest.Activity' -ErrorAction SilentlyContinue
    }

    It "Should order by the key properties the type declares, ahead of any recency property" {
        $Result = @(
            [PSCustomObject]@{ id = 1; name = 'b'; updated_at = '2026-01-03T00:00:00Z' }
            [PSCustomObject]@{ id = 2; name = 'c'; updated_at = '2026-01-01T00:00:00Z' }
            [PSCustomObject]@{ id = 3; name = 'a'; updated_at = '2026-01-02T00:00:00Z' }
        ) | New-GithubObject 'Github.SortTest.Keyed'
        $Result | Get-Names | Should -Be @('a', 'b', 'c')
    }

    It "Should order by UpdatedAt, most recent first, when the type declares no key properties" {
        $Result = @(
            [PSCustomObject]@{ id = 1; name = 'middle'; updated_at = '2026-01-02T00:00:00Z' }
            [PSCustomObject]@{ id = 2; name = 'oldest'; updated_at = '2026-01-01T00:00:00Z' }
            [PSCustomObject]@{ id = 3; name = 'newest'; updated_at = '2026-01-03T00:00:00Z' }
        ) | New-GithubObject 'Github.SortTest.Plain'
        $Result | Get-Names | Should -Be @('newest', 'middle', 'oldest')
    }

    It "Should fall back to LastActivityAt, most recent first, when there is no UpdatedAt" {
        $Result = @(
            [PSCustomObject]@{ id = 1; name = 'oldest'; pushed_at = '2026-01-01T00:00:00Z' }
            [PSCustomObject]@{ id = 2; name = 'newest'; pushed_at = '2026-01-03T00:00:00Z' }
            [PSCustomObject]@{ id = 3; name = 'middle'; pushed_at = '2026-01-02T00:00:00Z' }
        ) | New-GithubObject 'Github.SortTest.Activity'
        $Result | Get-Names | Should -Be @('newest', 'middle', 'oldest')
    }

    It "Should keep the API's order when there are neither key properties nor a recency property" {
        $Result = @(
            [PSCustomObject]@{ id = 1; name = 'b' }
            [PSCustomObject]@{ id = 2; name = 'c' }
            [PSCustomObject]@{ id = 3; name = 'a' }
        ) | New-GithubObject 'Github.SortTest.Plain'
        $Result | Get-Names | Should -Be @('b', 'c', 'a')
    }

    It "Should sort across items that arrive in separate pipeline calls" {
        $Result = 'b', 'c', 'a' | ForEach-Object { [PSCustomObject]@{ id = 1; name = $_ } } |
            New-GithubObject 'Github.SortTest.Keyed'
        $Result | Get-Names | Should -Be @('a', 'b', 'c')
    }

    Context "The caller's own ordering" {
        BeforeAll {
            function Get-SortTestListing {
                [CmdletBinding()]
                param(
                    [string] $Sort = 'created',
                    [string] $Direction = 'desc'
                )
                @(
                    [PSCustomObject]@{ id = 1; name = 'b' }
                    [PSCustomObject]@{ id = 2; name = 'c' }
                    [PSCustomObject]@{ id = 3; name = 'a' }
                ) | New-GithubObject 'Github.SortTest.Keyed'
            }
        }

        It "Should keep the API's order when the caller bound -Sort" {
            Get-SortTestListing -Sort 'updated' | Get-Names | Should -Be @('b', 'c', 'a')
        }

        It "Should keep the API's order when the caller bound -Direction" {
            Get-SortTestListing -Direction 'asc' | Get-Names | Should -Be @('b', 'c', 'a')
        }

        It "Should still sort when -Sort and -Direction only carry their defaults" {
            Get-SortTestListing | Get-Names | Should -Be @('a', 'b', 'c')
        }

        It "Should still sort when -Sort was bound to an empty value" {
            Get-SortTestListing -Sort '' | Get-Names | Should -Be @('a', 'b', 'c')
        }
    }
}
