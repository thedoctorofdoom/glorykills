# Refresh zscript/Weapons/BaseWeapon_Melee.upstream.zsc from PB Staging.
# Run after Project_Brutality-PB_Staging updates its melee base file.
param(
    [string]$PbStagingZip = (Join-Path $PSScriptRoot "..\..\Project_Brutality-PB_Staging.zip")
)

$ErrorActionPreference = "Stop"
$upstream = Join-Path $PSScriptRoot "..\zscript\Weapons\BaseWeapon_Melee.upstream.zsc"
$entry = "Project_Brutality-PB_Staging/zscript/Weapons/BaseWeapon_Melee.zsc"

if (-not (Test-Path $PbStagingZip)) {
    throw "PB Staging zip not found: $PbStagingZip"
}

$temp = Join-Path ([IO.Path]::GetTempPath()) ("gk_melee_sync_" + [guid]::NewGuid().ToString("n"))
New-Item -ItemType Directory -Path $temp | Out-Null
try {
    tar -xf $PbStagingZip -C $temp $entry
    $src = Join-Path $temp ($entry -replace "/", [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path $src)) { throw "Entry missing in archive: $entry" }

    $body = (Get-Content $src -Raw).TrimEnd()
    $body = $body -replace '(?s)\r?\nClass GayImp1.*$', ''

    $header = @"
// Unmodified PB Staging melee snapshot for GK VFS hook (see BaseWeapon_Melee.zsc).
// Refreshed from: $([IO.Path]::GetFileName($PbStagingZip))
// Run: tools/sync_pb_melee_upstream.ps1

"@

    Set-Content -Path $upstream -Value ($header + $body) -NoNewline
    Write-Host "Updated $upstream"
}
finally {
    Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
}
