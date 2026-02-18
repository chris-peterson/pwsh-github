if($PSVersionTable.Platform -like 'Win*') {
    $env:HOME = Join-Path $env:HOMEDRIVE $env:HOMEPATH
}

$global:GithubConfigurationPath = Join-Path $env:HOME "/.config/powershell/githubcli/config.yml"
$global:GithubBaseUrl              = 'https://api.github.com'
$global:GithubDefaultMaxPages      = 10

$global:GithubIdentityPropertyNameExemptions = @{
    'Github.Branch'             = ''
    'Github.Comment'            = 'Id'
    'Github.Configuration'      = ''
    'Github.Issue'              = 'Number'
    'Github.Label'              = 'Id'
    'Github.Milestone'          = 'Number'
    'Github.Organization'       = 'Id'
    'Github.PullRequest'        = 'Number'
    'Github.Release'            = 'Id'
    'Github.Repository'         = 'Id'
    'Github.User'               = 'Id'
}
