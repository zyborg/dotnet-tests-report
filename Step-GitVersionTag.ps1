[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$MajorVerTag,
    [string]$Ref=$null,

    [switch]$Apply
)

if (-not $Ref) {
    Write-Verbose "No Ref specified, resolving latest tag matching SemVer version"

    if ($MajorVerTag -notmatch 'v[0-9]+') {
        Write-Warning "MajorVerTag does NOT specify a major semver pattern"
        Write-Warning "Ref cannot be resolved and MUST be specified"
        exit 1
    }

    $tags = git tag --list
    if (-not $tags) {
        Write-Warning "Could not find any existing tags"
    }
    else {
        Write-Verbose "Found [$($tags.Length)] tag(s)"
        $semverTags = $tags | Where-Object {
            $_ -match '^v[0-9]+(\.[0-9]+){1,3}$' -and $_.StartsWith($MajorVerTag)
        } | ForEach-Object {
            ## Drop the leading 'v' and convert to a Version
            ## instance so we can do properly ordered compare
            New-Object -TypeName psobject -Property @{ 
                tag = $_
                ver = [version]::new($_.Substring(1))
            }
        } | Sort-Object -Descending -Property ver
        $latestTag = $semverTags | Select-Object -First 1
        if (-not $latestTag) {
            Write-Warning "Found [$($tags.Length)] tag(s) but no version matching tags"
            Write-Warning "Ref cannot be resolved and must be specified"
            exit 1
        }

        $Ref = $latestTag.tag
        Write-Verbose "Resolved latest version-matching semver tag as [$($Ref)]"
    }
}

if (-not $Apply) {
    Write-Warning "Apply switch was not given, here's what I would do (VERBOSE):"

    Write-Verbose "Delete existing tag locally and remotely:"
    Write-Verbose "  git tag -d $MajorVerTag"
    Write-Verbose "  git push origin --delete $MajorVerTag"
    Write-Verbose "(Re-)Creating tag locally and remotely:"
    Write-Verbose "  git tag $MajorVerTag $Ref"
    Write-Verbose "  git push origin $MajorVerTag $Ref"
}
else {
    Write-Warning "Apply switch was given, applying changes"

    Write-Information "Delete existing tag locally and remotely:"
    & git tag -d $MajorVerTag
    & git push origin --delete $MajorVerTag
    ## Alternate (less intuitive) way to delete remove tag:
    #git push origin :refs/tags/$MajorVerTag

    Write-Information "(Re-)Creating tag locally and remotely:"
    & git tag $MajorVerTag $Ref
    & git push origin $MajorVerTag $Ref
}
