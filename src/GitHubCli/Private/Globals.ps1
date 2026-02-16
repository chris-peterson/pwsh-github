if($PSVersionTable.Platform -like 'Win*') {
    $env:HOME = Join-Path $env:HOMEDRIVE $env:HOMEPATH
}

$global:GitHubConfigurationPath = Join-Path $env:HOME "/.config/powershell/githubcli/config.yml"
$global:GitHubBaseUrl              = 'https://api.github.com'
$global:GitHubDefaultMaxPages      = 10

$global:GitHubIdentityPropertyNameExemptions = @{
    'GitHub.Issue'              = 'Number'
    'GitHub.PullRequest'        = 'Number'
    'GitHub.Repository'         = 'Id'
    'GitHub.User'               = 'Id'
    'GitHub.Label'              = 'Id'
    'GitHub.Milestone'          = 'Number'
    'GitHub.Comment'            = 'Id'
    'GitHub.Configuration'      = ''
}
