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

. $PSScriptRoot/action_helpers.ps1

$inputs = @{
    test_results_path           = Get-ActionInput test_results_path
    project_path                = Get-ActionInput project_path
    no_restore                  = Get-ActionInput no_restore
    msbuild_configuration       = Get-ActionInput msbuild_configuration
    msbuild_verbosity           = Get-ActionInput msbuild_verbosity
    report_name                 = Get-ActionInput report_name
    report_title                = Get-ActionInput report_title
    github_token                = Get-ActionInput github_token -Required
    skip_check_run              = Get-ActionInput skip_check_run
    gist_name                   = Get-ActionInput gist_name
    gist_badge_label            = Get-ActionInput gist_badge_label
    gist_badge_message          = Get-ActionInput gist_badge_message
    gist_token                  = Get-ActionInput gist_token -Required
    fail_check_on_failed_tests  = Get-ActionInput fail_check_on_failed_tests
}

$tmpDir = Join-Path $PWD _TMP
$test_results_path = $inputs.test_results_path
$test_report_path = Join-Path $tmpDir test-results.md

function Build-MarkdownReport {
    $script:report_name = $inputs.report_name
    $script:report_title = $inputs.report_title

    if (-not $script:report_name) {
        $script:report_name = "TEST_RESULTS_$([datetime]::Now.ToString('yyyyMMdd_hhmmss'))"
    }
    if (-not $report_title) {
        $script:report_title = $report_name
    }

    $script:test_report_path = Join-Path $tmpDir test-results.md
    & "$PSScriptRoot/trx-report/trx2md.ps1" -Verbose `
        -trxFile $script:test_results_path `
        -mdFile $script:test_report_path -xslParams @{
            reportTitle = $script:report_title
        }
}

function Publish-ToCheckRun {
    param(
        [string]$reportData
    )

    Write-ActionInfo "Publishing Report to GH Workflow"

    $ghToken = $inputs.github_token
    $ctx = Get-ActionContext
    $repo = Get-ActionRepo
    $repoFullName = "$($repo.Owner)/$($repo.Repo)"

    Write-ActionInfo "Resolving REF"
    $ref = $ctx.Sha
    if ($ctx.EventName -eq 'pull_request') {
        Write-ActionInfo "Resolving PR REF"
        $ref = $ctx.Payload.pull_request.head.sha
        if (-not $ref) {
            Write-ActionInfo "Resolving PR REF as AFTER"
            $ref = $ctx.Payload.after
        }
    }
    if (-not $ref) {
        Write-ActionError "Failed to resolve REF"
        exit 1
    }
    Write-ActionInfo "Resolved REF as $ref"
    Write-ActionInfo "Resolve Repo Full Name as $repoFullName"

    Write-ActionInfo "Adding Check Run"
    $conclusion = 'neutral'
    if ($testResult.ResultSummary_outcome -eq "Failed" -and $inputs.fail_check_on_failed_tests) {
        Write-ActionWarning "Found failing tests"
        $conclusion = 'failure'

    }

    $url = "https://api.github.com/repos/$repoFullName/check-runs"
    $hdr = @{
        Accept = 'application/vnd.github.antiope-preview+json'
        Authorization = "token $ghToken"
    }
    $bdy = @{
        name       = $report_name
        head_sha   = $ref
        status     = $conclusion
        conclusion = 'neutral'
        output     = @{
            title   = $report_title
            summary = "This run completed at ``$([datetime]::Now)``"
            text    = $reportData
        }
    }
    Invoke-WebRequest -Headers $hdr $url -Method Post -Body ($bdy | ConvertTo-Json)
}

function Publish-ToGist {
    param(
        [string]$reportData
    )

    Write-ActionInfo "Publishing Report to GH Workflow"

    $reportGistName = $inputs.gist_name
    $gist_token = $inputs.gist_token
    Write-ActionInfo "Resolved Report Gist Name.....: [$reportGistName]"

    $gistsApiUrl = "https://api.github.com/gists"
    $apiHeaders = @{
        Accept        = "application/vnd.github.v2+json"
        Authorization = "token $gist_token"
    }

    ## Request all Gists for the current user
    $listGistsResp = Invoke-WebRequest -Headers $apiHeaders -Uri $gistsApiUrl

    ## Parse response content as JSON
    $listGists = $listGistsResp.Content | ConvertFrom-Json -AsHashtable
    Write-ActionInfo "Got [$($listGists.Count)] Gists for current account"

    ## Isolate the first Gist with a file matching the expected metadata name
    $reportGist = $listGists | Where-Object { $_.files.$reportGistName } | Select-Object -First 1

    if ($reportGist) {
        Write-ActionInfo "Found the Tests Report Gist!"
        ## Debugging:
        #$reportDataRawUrl = $reportGist.files.$reportGistName.raw_url
        #Write-ActionInfo "Fetching Tests Report content from Raw Url"
        #$reportDataRawResp = Invoke-WebRequest -Headers $apiHeaders -Uri $reportDataRawUrl
        #$reportDataContent = $reportDataRawResp.Content
        #if (-not $reportData) {
        #    Write-ActionWarning "Tests Report content seems to be missing"
        #    Write-ActionWarning "[$($reportGist.files.$reportGistName)]"
        #    Write-ActionWarning "[$reportDataContent]"
        #}
        #else {
        #    Write-Information "Got existing Tests Report"
        #}
    }

    $gistFiles = @{
        $reportGistName = @{
            content = $reportData
        }
    }
    if ($inputs.gist_badge_label) {
        $gist_badge_label = $inputs.gist_badge_label
        $gist_badge_message = $inputs.gist_badge_message

        if (-not $gist_badge_message) {
            $gist_badge_message = '%ResultSummary_outcome%'
        }

        $gist_badge_label = Resolve-EscapeTokens $gist_badge_label $testResult -UrlEncode
        $gist_badge_message = Resolve-EscapeTokens $gist_badge_message $testResult -UrlEncode
        $gist_badge_color = switch ($testResult.ResultSummary_outcome) {
            'Completed' { 'green' }
            'Failed' { 'red' }
            default { 'yellow' }
        }
        $gist_badge_url = "https://img.shields.io/badge/$gist_badge_label-$gist_badge_message-$gist_badge_color"
        Write-ActionInfo "Computed Badge URL: $gist_badge_url"
        $gistBadgeResult = Invoke-WebRequest $gist_badge_url -ErrorVariable $gistBadgeError
        if ($gistBadgeError) {
            $gistFiles."$($reportGistName)_badge.txt" = @{ content = $gistBadgeError.Message }
        }
        else {
            $gistFiles."$($reportGistName)_badge.svg" = @{ content = $gistBadgeResult.Content }
        }
    }

    if (-not $reportGist) {
        Write-ActionInfo "Creating initial Tests Report Gist"
        $createGistResp = Invoke-WebRequest -Headers $apiHeaders -Uri $gistsApiUrl -Method Post -Body (@{
            public = $true ## Set thit to false to make it a Secret Gist
            files = $gistFiles
        } | ConvertTo-Json)
        $createGist = $createGistResp.Content | ConvertFrom-Json -AsHashtable
        $reportGist = $createGist
        Write-ActionInfo "Create Response: $createGistResp"
    }
    else {
        Write-ActionInfo "Updating Tests Report Gist"
        $updateGistUrl = "$gistsApiUrl/$($reportGist.id)"
        $updateGistResp = Invoke-WebRequest -Headers $apiHeaders -Uri $updateGistUrl -Method Patch -Body (@{
            files = $gistFiles
        } | ConvertTo-Json)

        Write-ActionInfo "Update Response: $updateGistResp"
    }
}

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

    $no_restore = $inputs.no_restore
    $msbuild_configuration = $inputs.msbuild_configuration
    $msbuild_verbosity = $inputs.msbuild_verbosity

    if (-not $msbuild_verbosity) {
        $msbuild_verbosity = 'normal'
    }

    $dotnetArgs = @(
        'test'
        '--verbosity',$msbuild_verbosity
        '--results-directory',$tmpDir
        '--logger',"`"trx;LogFileName=$trxName`""
    )

    if ($msbuild_configuration) {
        $dotnetArgs += '--configuration'
        $dotnetArgs += $msbuild_configuration
    }
    if ($no_restore -eq 'true') {
        $dotnetArgs += '--no-restore'
    }

    if ($inputs.project_path) {
        $dotnetArgs += $inputs.project_path
    }

    Write-ActionInfo "Assembled test invocation arguments:"
    Write-ActionInfo "    $dotnetArgs"

    Write-ActionInfo "Invoking..."
    & $dotnet.Path @dotnetArgs

    if (-not $?) {
        Write-ActionWarning "Execution of tests returned failure: $LASTEXITCODE"
    }
    if (-not (Test-Path -PathType Leaf $test_results_path)) {
        Write-ActionWarning "Execution of tests DID NOT PRODUCE a tests results file"
    }
}

if ($test_results_path) {
    Set-ActionOutput -Name test_results_path -Value $test_results_path

    Write-ActionInfo "Compiling Test Result object"
    $testResultXml = Select-Xml -Path $test_results_path -XPath /
    $testResult = [psobject]::new()
    $testResultXml.Node.TestRun.Attributes | % { $testResult |
        Add-Member -MemberType NoteProperty -Name "TestRun_$($_.Name)" -Value $_.Value }
    $testResultXml.Node.TestRun.Times.Attributes | % { $testResult |
        Add-Member -MemberType NoteProperty -Name "Times_$($_.Name)" -Value $_.Value }
    $testResultXml.Node.TestRun.ResultSummary.Attributes | % { $testResult |
        Add-Member -MemberType NoteProperty -Name "ResultSummary_$($_.Name)" -Value $_.Value }
    $testResultXml.Node.TestRun.ResultSummary.Counters.Attributes | % { $testResult |
        Add-Member -MemberType NoteProperty -Name "Counters_$($_.Name)" -Value $_.Value }
    Write-ActionInfo "$($testResult|Out-Default)"

    $result_clixml_path = Join-Path $tmpDir dotnet-test-result.clixml
    Export-Clixml -InputObject $testResult -Path $result_clixml_path

    Set-ActionOutput -Name result_clixml_path -Value $result_clixml_path
    Set-ActionOutput -Name result_value -Value ($testResult.ResultSummary_outcome)
    Set-ActionOutput -Name total_count -Value ($testResult.Counters_total)
    Set-ActionOutput -Name passed_count -Value ($testResult.Counters_passed)
    Set-ActionOutput -Name failed_count -Value ($testResult.Counters_failed)

    Write-ActionInfo "Generating Markdown Report from TRX file"
    Build-MarkdownReport
    $reportData = [System.IO.File]::ReadAllText($test_report_path)

    if ($inputs.skip_check_run -ne $true) {
        Publish-ToCheckRun -ReportData $reportData
    }
    if ($inputs.gist_name -and $inputs.gist_token) {
        Publish-ToGist -ReportData $reportData
    }
}
