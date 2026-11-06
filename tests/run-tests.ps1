<#
.SYNOPSIS
    Validate suite.lock.json and (optionally) a built AI Suite zip.

.DESCRIPTION
    Runs offline: no game install, no network, no Useful Bots tree required.
    Checks the lock against the sibling mod repos and, when a zip is present,
    checks the archive layout and per-mod metadata in the zip itself.

    Usage:
      powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1
      powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1 -Zip dist\AI-Suite-2026.11.06.zip
#>
param(
    [string]$Zip = '',
    [string]$WorkspaceRoot = ''
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if (-not $WorkspaceRoot) { $WorkspaceRoot = Join-Path $RepoRoot '..\..' }
$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
$Failures = New-Object System.Collections.Generic.List[string]
$Checks = 0

function Check([bool]$Condition, [string]$Message) {
    $script:Checks++
    if ($Condition) { return }
    $script:Failures.Add($Message)
}

function Read-Json([string]$Path) {
    return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
}

$Git = (Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source
if (-not $Git) { $Git = (Get-Command git -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1).Source }
if (-not $Git) {
    Write-Host 'ERROR: git not found in PATH; the lock cannot be checked against the member repos' -ForegroundColor Red
    exit 1
}

$Lock = Read-Json (Join-Path $RepoRoot 'suite.lock.json')
$Names = @($Lock.mods.PSObject.Properties | ForEach-Object { $_.Name })
$LoadOrder = @($Lock.loadOrder)

Check ([bool]$Lock.suiteVersion) 'lock: suiteVersion is set'
Check ($Names.Count -eq 4) ('lock: exactly four mods (found {0})' -f $Names.Count)
Check (($LoadOrder | Where-Object { $Names -notcontains $_ }).Count -eq 0) 'lock: loadOrder only names known mods'
Check (($Names | Where-Object { $LoadOrder -notcontains $_ }).Count -eq 0) 'lock: every mod appears in loadOrder'

$Priorities = @($LoadOrder | ForEach-Object { [int]$Lock.mods.$_.priority })
Check (($Priorities | Sort-Object -Unique).Count -eq $Priorities.Count) 'lock: priorities are unique'

$Expected = @{ LIES = 100; Monkeepers = 99; Iter = 40; Keepers = 10 }
foreach ($Name in $Names) {
    Check ($Expected.ContainsKey($Name)) "lock: $Name is a known suite member"
    if ($Expected.ContainsKey($Name)) {
        Check ([int]$Lock.mods.$Name.priority -eq $Expected[$Name]) "lock: $Name priority is $($Expected[$Name]) (contract order)"
    }
}

foreach ($Pair in @(@($LoadOrder[0], $LoadOrder[1]), @($LoadOrder[1], $LoadOrder[2]), @($LoadOrder[2], $LoadOrder[3]))) {
    $Higher = [int]$Lock.mods.($Pair[0]).priority
    $Lower = [int]$Lock.mods.($Pair[1]).priority
    Check ($Higher -gt $Lower) ("lock: loadOrder is priority-descending at {0} > {1}" -f $Pair[0], $Pair[1])
}

foreach ($Name in $Names) {
    $Mod = $Lock.mods.$Name
    $RepoDir = Join-Path $WorkspaceRoot ('mods\' + $Mod.dir)
    Check (Test-Path -LiteralPath (Join-Path $RepoDir '.git')) "repo: $Name exists at mods\$($Mod.dir)"

    $Resolved = (& $Git -C $RepoDir rev-parse --verify --quiet "$($Mod.commit)^{commit}" 2>&1)
    Check ($LASTEXITCODE -eq 0 -and [bool]$Resolved) "repo: $Name commit $($Mod.commit) resolves"

    $Committed = (& $Git -C $RepoDir show "$($Mod.commit):mod.txt" 2>&1) -join "`n"
    if ($LASTEXITCODE -eq 0 -and $Committed) {
        try { $Info = $Committed | ConvertFrom-Json } catch { $Info = $null }
        Check ($null -ne $Info) "repo: $Name mod.txt at the pinned commit parses"
        if ($Info) {
            Check ($Info.name -eq $Name) "repo: $Name mod.txt name is '$Name'"
            Check ($Info.version -eq $Mod.version) "repo: $Name mod.txt version matches lock ($($Mod.version))"
            Check ([int]$Info.priority -eq [int]$Mod.priority) "repo: $Name mod.txt priority matches lock ($($Mod.priority))"
        }
    }
}

# ---------------------------------------------------------------------------
# Archive checks (skipped when nothing has been built yet)
# ---------------------------------------------------------------------------
if (-not $Zip) {
    $Dist = Join-Path $RepoRoot 'dist'
    if (Test-Path -LiteralPath $Dist) {
        $Latest = Get-ChildItem -LiteralPath $Dist -Filter 'AI-Suite-*.zip' -File |
            Sort-Object LastWriteTime | Select-Object -Last 1
        if ($Latest) { $Zip = $Latest.FullName }
    }
}

if (-not $Zip) {
    Write-Host 'archive: no zip found; lock/repo checks only'
} else {
    Check (Test-Path -LiteralPath $Zip) "archive: $Zip exists"
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $Archive = [System.IO.Compression.ZipFile]::OpenRead((Resolve-Path -LiteralPath $Zip).Path)
    try {
        $Entries = @($Archive.Entries)
        $Top = @($Entries | ForEach-Object { ($_.FullName -split '/')[0] } | Sort-Object -Unique)
        Check ($Top.Count -eq 4) ('archive: exactly four top-level folders (found {0}: {1})' -f $Top.Count, ($Top -join ', '))
        Check (($Top | Where-Object { $Names -notcontains $_ }).Count -eq 0) 'archive: top level is only the four mods'

        $Forbidden = @('dev', 'dist', 'tests', '.github', '.git', '.build')
        foreach ($Entry in $Entries) {
            $Parts = $Entry.FullName -split '/'
            if ($Parts.Count -ge 2) {
                Check ($Forbidden -notcontains $Parts[1]) ("archive: $($Entry.FullName) is not a dev-only path")
                Check (-not ($Parts[1] -like '.*-build')) ("archive: $($Entry.FullName) is not build provenance")
            }
        }

        foreach ($Name in $Names) {
            $Mod = $Lock.mods.$Name
            $Prefix = "$Name/"
            $Names2 = @($Entries | Where-Object { $_.FullName.StartsWith($Prefix) } | ForEach-Object { $_.FullName.Substring($Prefix.Length) })
            foreach ($Required in @('mod.txt', 'changelog.txt', 'LICENSE', 'README.md', 'MENU_OPTIONS.md')) {
                Check ($Names2 -contains $Required) "archive: $Name ships $Required"
            }
            Check (($Names2 | Where-Object { $_ -like 'loc/*' }).Count -gt 0) "archive: $Name ships loc/"
            Check (($Names2 | Where-Object { $_ -like 'menu/*' }).Count -gt 0) "archive: $Name ships menu/"
            Check (($Names2 | Where-Object { $_ -like 'lua/*.lua' -or $_ -eq 'menumanager.lua' }).Count -gt 0) "archive: $Name ships Lua"

            $Entry = $Archive.GetEntry($Prefix + 'mod.txt')
            if ($Entry) {
                $Reader = New-Object System.IO.StreamReader($Entry.Open())
                try { $Info = ($Reader.ReadToEnd() | ConvertFrom-Json) } finally { $Reader.Close() }
                Check ($Info.name -eq $Name) "archive: $Name mod.txt name is '$Name'"
                Check ($Info.version -eq $Mod.version) "archive: $Name version is $($Mod.version)"
                Check ([int]$Info.priority -eq [int]$Mod.priority) "archive: $Name priority is $($Mod.priority)"
            }
        }
    } finally {
        $Archive.Dispose()
    }

    $Notes = Join-Path (Split-Path $Zip -Parent) (('AI-Suite-{0}-release-notes.md' -f $Lock.suiteVersion))
    Check (Test-Path -LiteralPath $Notes) 'archive: release notes exist next to the zip'
    if (Test-Path -LiteralPath $Notes) {
        $Hash = (Get-FileHash -LiteralPath $Zip -Algorithm SHA256).Hash
        $NotesText = Get-Content -LiteralPath $Notes -Raw
        Check ($NotesText -match [regex]::Escape($Hash)) 'archive: release notes carry the archive SHA-256'
    }
}

Write-Host ''
if ($Failures.Count -eq 0) {
    Write-Host ("PASS: {0} checks" -f $Checks) -ForegroundColor Green
    exit 0
}
Write-Host ("FAIL: {0} of {1} checks" -f $Failures.Count, $Checks) -ForegroundColor Red
foreach ($Failure in $Failures) { Write-Host "  - $Failure" -ForegroundColor Red }
exit 1
