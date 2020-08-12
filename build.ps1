param(
    [switch]$UpgradePackages
)

if ($UpgradePackages) {
    & npm upgrade "@actions/core"
    & npm upgrade "@actions/exec"
}

ncc build .\invoke-pwsh.js -o _init
