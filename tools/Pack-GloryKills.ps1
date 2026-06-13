# Rebuild glorykills-master.zip for PB_Staging load folder.
param(
    [string]$SourceRoot = (Split-Path $PSScriptRoot -Parent),
    [string]$OutputZip = (Join-Path (Split-Path (Split-Path $SourceRoot -Parent) -Parent) 'glorykills-master.zip')
)

$ErrorActionPreference = 'Stop'
$stagingDir = Join-Path $env:TEMP ('gk-pack-' + [guid]::NewGuid().ToString('n'))
$archiveZip = Join-Path $env:TEMP ('gk-archive-' + [guid]::NewGuid().ToString('n') + '.zip')

$excludeNames = @('.git', '.cursor', 'tools')

function Test-ExcludedPath([string]$fullPath, [string]$root) {
    $rel = $fullPath.Substring($root.Length).TrimStart('\', '/')
    foreach ($ex in $excludeNames) {
        if ($rel -ieq $ex -or $rel.StartsWith($ex + '\') -or $rel.StartsWith($ex + '/')) { return $true }
    }
    if ($rel -match '(?i)(^|[\\/])\.git([\\/]|$)') { return $true }
    return $false
}

function Copy-GKTree([string]$srcDir, [string]$dstDir, [string]$root) {
    Get-ChildItem -LiteralPath $srcDir -Force | ForEach-Object {
        if (Test-ExcludedPath $_.FullName, $root) { return }
        $dest = Join-Path $dstDir $_.Name
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Force -Path $dest | Out-Null
            Copy-GKTree $_.FullName $dest $root
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
    }
}

New-Item -ItemType Directory -Force -Path $stagingDir | Out-Null
Copy-GKTree $SourceRoot $stagingDir $SourceRoot

Add-Type -AssemblyName System.IO.Compression.FileSystem
if (Test-Path $archiveZip) { Remove-Item -LiteralPath $archiveZip -Force }
[System.IO.Compression.ZipFile]::CreateFromDirectory($stagingDir, $archiveZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)

Copy-Item -LiteralPath $archiveZip -Destination $OutputZip -Force
$count = ([System.IO.Compression.ZipFile]::OpenRead($OutputZip)).Entries.Count
Write-Host "Updated: $OutputZip ($((Get-Item $OutputZip).Length) bytes, $count entries)"

Remove-Item -LiteralPath $stagingDir -Recurse -Force
Remove-Item -LiteralPath $archiveZip -Force
