if($PSVersionTable.Platform -like 'Win*') {
    $env:HOME = Join-Path $env:HOMEDRIVE $env:HOMEPATH
}

$global:GithubConfigurationPath = Join-Path $env:HOME "/.config/powershell/githubcli/config.yml"
$global:GithubBaseUrl              = 'https://api.github.com'
$global:GithubDefaultMaxPages      = 10

$global:GithubIdentityPropertyNameExemptions = @{
    'Github.Branch'             = 'Name'
    'Github.Comment'            = 'Id'
    'Github.Commit'             = 'Sha'
    'Github.Configuration'      = ''
    'Github.Event'              = 'Id'
    'Github.Issue'              = 'Number'
    'Github.Label'              = 'Id'
    'Github.Member'             = 'Id'
    'Github.Milestone'          = 'Number'
    'Github.Organization'       = 'Id'
    'Github.PullRequest'        = 'Number'
    'Github.Release'            = 'Id'
    'Github.Repository'         = 'Id'
    'Github.SearchResult'       = ''
    'Github.User'               = 'Id'
    'Github.Workflow'           = 'Id'
    'Github.WorkflowJob'       = 'Id'
    'Github.WorkflowRun'       = 'Id'
}
