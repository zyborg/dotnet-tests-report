
function splitListInput { $args[0] -split ',' | % { $_.Trim() } }
function writeListInput { $args[0] | % { Write-ActionInfo "    - $_" } }


function Resolve-EscapeTokens {
    param(
        [object]$Message,
        [object]$Context,
        [switch]$UrlEncode
    )

    $m = ''
    $Message = $Message.ToString()
    $p2 = -1
    $p1 = $Message.IndexOf('%')
    while ($p1 -gt -1) {
        $m += $Message.Substring($p2 + 1, $p1 - $p2 - 1)
        $p2 = $Message.IndexOf('%', $p1 + 1)
        if ($p2 -lt 0) {
            $m += $Message.Substring($p1)
            break
        }
        $etName = $Message.Substring($p1 + 1, $p2 - $p1 - 1)
        if ($etName -eq '') {
            $etValue = '%'
        }
        else {
            $etValue = $Context.$etName
        }
        $m += $etValue
        $p1 = $Message.IndexOf('%', $p2 + 1)
    }
    $m += $Message.Substring($p2 + 1)

    if ($UrlEncode) {
        $m = [System.Web.HTTPUtility]::UrlEncode($m).Replace('+', '%20')
    }

    $m
}