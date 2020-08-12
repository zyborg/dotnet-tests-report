#!/usr/bin/env pwsh

##
## This is a sample GitHub Action script written in PowerShell Core.
## You can write your logic in PWSH to perform GitHub Actions.
##


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

##
## ***** Put your logic here *****
##

## Pull in some inputs
$salutation = Get-ActionInput salutation -Required
$audience   = Get-ActionInput audience

if (-not $salutation) {
    ## We actually specified this input as *required* above so
    ## this should never execute, but here is an example value
    $salutation = "Hello"
}
if (-not $audience) {
    $audience = "World"
}

$greeting = "$($salutation) $($audience)!"

## Persist the greeting in the environment for all subsequent steps
Set-ActionVariable -Name build_greeting -Value greeting

## Expose the greeting as an output value of this step instance
Set-ActionOutput -Name greeting -Value $greeting

## Write it out to the log for good measure
Write-ActionInfo $greeting
