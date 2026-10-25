$ErrorActionPreference = 'Stop'
$work = 'C:\ServerMaintenance'; $script = "$work\update-check.ps1"; $log = "$work\health.log"
$scriptUrl = 'https://raw.githubusercontent.com/zizomail1015-collab/server-maintenance/main/update-check.ps1'

function Log($m){ if(!(Test-Path $work)){mkdir $work|Out-Null}; "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss') | $env:COMPUTERNAME | $m" | Out-File $log -Append -Encoding utf8 }

try {
    Invoke-WebRequest $scriptUrl -OutFile $script -UseBasicParsing
    Log "run started"; & $script; Log "run OK"
} catch { Log "FAILED: $($_.Exception.Message)"; exit 1 }