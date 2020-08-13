#!/usr/bin/env pwsh

## You interface with the Actions/Workflow system by interacting
## with the environment.  The `GitHubActions` module makes this
## easier and more natural by wrapping up access to the Workflow
## environment in PowerShell-friendly constructions and idioms
if (-not (Get-Module -ListAvailable GitHubActions)) {
    ## Make sure the GH Actions module is installed from the Gallery
    Install-Module GitHubActions -Force
}

## Load up some common functionality for interacting
## with the GitHub Actions/Workflow environment
Import-Module GitHubActions

$inputs = @{
    test_results_path  = Get-ActionInput test_results_path
    project_path       = Get-ActionInput project_path
    report_name        = Get-ActionInput report_name
    report_title       = Get-ActionInput report_title
    github_token       = Get-ActionInput github_token -Required
    skip_check_run     = Get-ActionInput skip_check_run
    gist_name          = Get-ActionInput gist_name
    gist_badge_label   = Get-ActionInput gist_badge_label
    gist_badge_message = Get-ActionInput gist_badge_message
    gist_token         = Get-ActionInput gist_token -Required
}

$tmpDir = Join-Path $PWD _TMP
$test_results_path = $inputs.test_results_path

if ($test_results_path) {
    Write-ActionInfo "TRX Test Results Path provided as input; skipping test invocation"
}
else {
    $dotnet = Get-Command dotnet -ErrorAction SilentlyContinue
    if (-not $dotnet) {
        Write-ActionError "Unable to resolve the `dotnet` executable; ABORTING!"
        exit 1
    }
    else {
        Write-ActionInfo "Resolved `dotnet` executable:"
        Write-ActionInfo "  * path.......: [$($dotnet.Path)]"
        $dotnetVersion = & $dotnet.Path --version
        Write-ActionInfo "  * version....: [$($dotnetVersion)]"
    }

    $trxName = 'test-results.trx'
    $test_results_path = Join-Path $tmpDir $trxName

    $dotnetArgs = @(
        'test'
        #'--no-restore'
        '--verbosity','normal'
        '--results-directory',$tmpDir
        '--logger',"`"trx;LogFileName=$trxName`""
    )

    if ($inputs.project_path) {
        $dotnetArgs += $inputs.project_path
    }

    Write-AcitonInfo "Assembled test invocation arguments:"
    Write-ActionInfo "    $dotnetArgs"

    Write-ActionInfo "Invoking..."
    & $dotnet.Path @dotnetArgs
}

## Expose the greeting as an output value of this step instance
Set-ActionOutput -Name test_results_path -Value $test_results_path
