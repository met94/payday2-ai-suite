<#
.SYNOPSIS
    Assemble the AI Suite release zip: LIES + Iter + Keepers + Monkeepers.

.DESCRIPTION
    Reads suite.lock.json, checks out each member repo at its pinned commit in
    a temporary worktree, runs the member's own dev/build.ps1 when it has one
    and copies its runtime tree otherwise, then gates the staged bytes and
    writes one zip whose root holds the four mod folders.

    The member repos are never modified: the worktrees live under .build\ and
    are removed on exit (success or failure).

    Never touches the game. The user installs and uploads the zip.

.PARAMETER WorkspaceRoot
    The v2 workspace checkout (default: two levels above this repo).

.PARAMETER UbDir
    Useful Bots 2.6.3 tree for the ownership gate. Default: PD2_UB_DIR, else
    the live install recorded in workspace.json.

.PARAMETER ContractRoot
    Workspace checkout that holds the ownership contract
    (docs/reference/ai-suite-ownership.json). Default: WorkspaceRoot. Point
    this at a workspace worktree to gate against a contract that is not
    merged yet.

.PARAMETER OutDir
    Zip destination (default: <repo>\dist).

.PARAMETER SkipGates
    Stage and zip without the ownership/Lua gates. Development only.
#>
param(
    [string]$WorkspaceRoot = '',
    [string]$UbDir = '',
    [string]$ContractRoot = '',
    [string]$OutDir = '',
    [switch]$SkipGates
)

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path -LiteralPath $PSScriptRoot).Path
if (-not $WorkspaceRoot) {
    $WorkspaceRoot = (Resolve-Path -LiteralPath (Join-Path $RepoRoot '..\..')).Path
}
$WorkspaceRoot = (Resolve-Path -LiteralPath $WorkspaceRoot).Path
if (-not $ContractRoot) { $ContractRoot = $WorkspaceRoot }
$ContractRoot = (Resolve-Path -LiteralPath $ContractRoot).Path
if (-not $OutDir) { $OutDir = Join-Path $RepoRoot 'dist' }

$Git = $null
$StagedWorktrees = @()

# Native tools write progress to stderr; under 'Stop' PowerShell turns that
# into a terminating error, so every external call runs with 'Continue' and
# the caller checks the exit code instead.
function Invoke-Native {
    param(
        [string]$Exe,
        [string[]]$Arguments = @(),
        [switch]$Quiet
    )
    $Previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $Output = & $Exe @Arguments 2>&1
        $Code = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $Previous
    }
    $Lines = @($Output | ForEach-Object { [string]$_ })
    if (-not $Quiet) {
        foreach ($Line in $Lines) { if ($Line) { Write-Host "  $Line" } }
    }
    return [pscustomobject]@{ Code = $Code; Lines = $Lines }
}

function Remove-StagedWorktrees {
    if (-not $Git -or $StagedWorktrees.Count -eq 0) { return }
    $Previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        foreach ($Item in $StagedWorktrees) {
            & $Git -C $Item.Repo worktree remove --force $Item.Path 2>&1 | Out-Null
            & $Git -C $Item.Repo worktree prune 2>&1 | Out-Null
        }
    } finally {
        $ErrorActionPreference = $Previous
    }
    $script:StagedWorktrees = @()
}

function Fail([string]$Message) {
    Write-Host "ERROR: $Message" -ForegroundColor Red
    Remove-StagedWorktrees
    exit 1
}

function Step([string]$Message) {
    Write-Host ''
    Write-Host "== $Message" -ForegroundColor Cyan
}

function Get-CommandPath([string[]]$Names) {
    foreach ($Name in $Names) {
        $Hit = Get-Command $Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($Hit) { return $Hit.Source }
    }
    return $null
}

function Read-ModTxt([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { Fail "missing $Path" }
    try {
        return (Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json)
    } catch {
        Fail "invalid JSON in $Path`: $($_.Exception.Message)"
    }
}

$Git = Get-CommandPath @('git.exe', 'git')
if (-not $Git) { Fail 'git not found in PATH' }

$LockPath = Join-Path $RepoRoot 'suite.lock.json'
$Lock = Read-ModTxt $LockPath
if (-not $Lock.suiteVersion) { Fail 'suite.lock.json has no suiteVersion' }
if (-not $Lock.mods) { Fail 'suite.lock.json has no mods' }

$ModNames = @($Lock.mods.PSObject.Properties | ForEach-Object { $_.Name })
$LoadOrder = @($Lock.loadOrder)
foreach ($Name in $LoadOrder) {
    if ($ModNames -notcontains $Name) { Fail "loadOrder names '$Name' but the lock has no such mod" }
}
foreach ($Name in $ModNames) {
    if ($LoadOrder -notcontains $Name) { Fail "mod '$Name' is not listed in loadOrder" }
}

# ---------------------------------------------------------------------------
# Staging area
# ---------------------------------------------------------------------------
$BuildRoot = Join-Path $RepoRoot '.build'
$StageMarker = Join-Path $BuildRoot '.bundle-build'
$SrcRoot = Join-Path $BuildRoot 'src'
$StageMods = Join-Path $BuildRoot 'mods'

if (Test-Path -LiteralPath $BuildRoot) {
    if (-not (Test-Path -LiteralPath $StageMarker)) {
        Fail "refusing to delete $BuildRoot because it has no .bundle-build marker; move it to _archive or remove it manually"
    }
    Remove-Item -LiteralPath $BuildRoot -Recurse -Force
}
New-Item -ItemType Directory -Force $SrcRoot | Out-Null
New-Item -ItemType Directory -Force $StageMods | Out-Null
Set-Content -LiteralPath $StageMarker -Encoding utf8 -Value (@(
    'Generated by build.ps1',
    ('built: ' + (Get-Date).ToString('u'))
) -join "`n")

# ---------------------------------------------------------------------------
# Stage every member
# ---------------------------------------------------------------------------
try {
foreach ($Name in $LoadOrder) {
    $Mod = $Lock.mods.$Name
    $RepoDir = Join-Path $WorkspaceRoot ('mods\' + $Mod.dir)
    if (-not (Test-Path -LiteralPath (Join-Path $RepoDir '.git'))) {
        Fail "missing repo for $Name`: $RepoDir"
    }

    Step "stage $Name $($Mod.version) ($($Mod.commit))"
    $ResolveResult = Invoke-Native $Git @('-C', $RepoDir, 'rev-parse', '--verify', '--quiet', "$($Mod.commit)^{commit}") -Quiet
    $Resolved = ''
    if ($ResolveResult.Code -eq 0 -and $ResolveResult.Lines.Count -gt 0) { $Resolved = $ResolveResult.Lines[0].Trim() }
    if (-not $Resolved) { Fail "commit $($Mod.commit) not found in $RepoDir" }

    # A temporary worktree at the pinned commit: the member's own build script
    # expects a real .git, and the member checkout itself stays untouched.
    # Prune first: a build killed mid-way leaves a registration whose directory
    # this script has since deleted, and `worktree add` refuses those.
    Invoke-Native $Git @('-C', $RepoDir, 'worktree', 'prune') -Quiet | Out-Null
    $Src = Join-Path $SrcRoot $Name
    $AddResult = Invoke-Native $Git @('-C', $RepoDir, 'worktree', 'add', '--detach', $Src, $Resolved)
    if ($AddResult.Code -ne 0) { Fail "git worktree add failed for $Name" }
    $script:StagedWorktrees += [pscustomobject]@{ Repo = $RepoDir; Path = $Src }

    $HeadResult = Invoke-Native $Git @('-C', $Src, 'rev-parse', 'HEAD') -Quiet
    $Head = ''
    if ($HeadResult.Lines.Count -gt 0) { $Head = $HeadResult.Lines[0].Trim() }
    if ($Head -ne $Resolved) { Fail "$Name worktree is at $Head, expected $Resolved" }

    $Dest = Join-Path $StageMods $Name
    if ($Mod.build) {
        $BuildScript = Join-Path $Src $Mod.build
        if (-not (Test-Path -LiteralPath $BuildScript)) { Fail "$Name declares build '$($Mod.build)' but it is missing" }
        if (-not $Mod.dist) { Fail "$Name declares a build script but no dist folder name" }
        $BuildResult = Invoke-Native 'powershell' @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $BuildScript)
        if ($BuildResult.Code -ne 0) { Fail "$Name build script failed" }
        $DistDir = Join-Path $Src $Mod.dist
        if (-not (Test-Path -LiteralPath (Join-Path $DistDir 'mod.txt'))) { Fail "$Name build produced no mod.txt at $DistDir" }
        Copy-Item -LiteralPath $DistDir -Destination $StageMods -Recurse -Force
    } else {
        $Exclude = @('.git', '.gitignore', 'dev', 'dist', 'tests', '.github')
        if ($Mod.exclude) { $Exclude = @($Exclude + @($Mod.exclude) | Sort-Object -Unique) }
        New-Item -ItemType Directory -Force $Dest | Out-Null
        Get-ChildItem -LiteralPath $Src -Force | Where-Object { $Exclude -notcontains $_.Name } | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $Dest -Recurse -Force
        }
    }

    # Member build provenance is dev-only; it also carries a timestamp. Match
    # any dot-file ending in -build so a future member build script is covered.
    Get-ChildItem -LiteralPath $Dest -Force -File | Where-Object { $_.Name -like '.*-build' } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Force }


    # Lock assertions on the staged tree: this is what ships.
    $Info = Read-ModTxt (Join-Path $Dest 'mod.txt')
    if ($Info.name -ne $Name) { Fail "staged $Name has mod.txt name '$($Info.name)'" }
    if ($Info.version -ne $Mod.version) { Fail "staged $Name is $($Info.version), lock says $($Mod.version)" }
    if ([int]$Info.priority -ne [int]$Mod.priority) { Fail "staged $Name priority $($Info.priority), lock says $($Mod.priority)" }
    foreach ($Required in @('mod.txt', 'changelog.txt', 'LICENSE', 'README.md')) {
        if (-not (Test-Path -LiteralPath (Join-Path $Dest $Required))) { Fail "staged $Name is missing $Required" }
    }
    foreach ($Forbidden in @('.git', '.gitignore', 'dev', 'dist', 'tests', '.github', '.build')) {
        if (Test-Path -LiteralPath (Join-Path $Dest $Forbidden)) { Fail "staged $Name ships forbidden entry $Forbidden" }
    }
    Get-ChildItem -LiteralPath $Dest -Force -File | Where-Object { $_.Name -like '.*-build' } |
        ForEach-Object { Fail "staged $Name ships build provenance $($_.Name)" }
}
} catch {
    Fail "staging failed: $($_.Exception.Message)"
} finally {
    Remove-StagedWorktrees
}

# ---------------------------------------------------------------------------
# Gates
# ---------------------------------------------------------------------------
if (-not $SkipGates) {
    $Node = Get-CommandPath @('node.exe', 'node')
    if (-not $Node) { Fail 'node not found in PATH (needed for the ownership and Lua gates)' }

    Step 'ownership gate (crossmod-check --strict)'
    if (-not $UbDir) {
        if ($env:PD2_UB_DIR) {
            $UbDir = $env:PD2_UB_DIR
        } elseif (Test-Path -LiteralPath (Join-Path $WorkspaceRoot 'workspace.json')) {
            $Workspace = Get-Content -LiteralPath (Join-Path $WorkspaceRoot 'workspace.json') -Raw | ConvertFrom-Json
            if ($Workspace.gameInstall) {
                $Live = Join-Path $Workspace.gameInstall 'mods\Useful Bots'
                if (Test-Path -LiteralPath (Join-Path $Live 'mod.txt')) { $UbDir = $Live }
            }
        }
    }
    if (-not $UbDir -or -not (Test-Path -LiteralPath (Join-Path $UbDir 'mod.txt'))) {
        Fail 'Useful Bots tree not found; pass -UbDir (never the 2024 old_mods audit copy)'
    }
    $UbInfo = Read-ModTxt (Join-Path $UbDir 'mod.txt')
    $UbPin = [string]$Lock.testedWith.'Useful Bots'
    if ($UbPin -and $UbInfo.version -ne $UbPin) {
        Write-Host "WARNING: Useful Bots $($UbInfo.version) at $UbDir, tested pin is $UbPin" -ForegroundColor Yellow
    }

    $Luaparse = Join-Path $WorkspaceRoot 'tools\lua\node_modules\luaparse'
    if (Test-Path -LiteralPath $Luaparse) { $env:LUAPARSE_DIR = $Luaparse }

    $Checker = Join-Path $WorkspaceRoot 'tools\crossmod-check.mjs'
    if (-not (Test-Path -LiteralPath $Checker)) { Fail "missing $Checker" }
    $CheckResult = Invoke-Native $Node @($Checker, '--root', $ContractRoot, '--mods-dir', $StageMods, '--ub-dir', $UbDir, '--strict')
    if ($CheckResult.Code -ne 0) { Fail 'crossmod-check --strict reported a target deviation' }

    Step 'Lua syntax gate'
    $Luajit = Join-Path $WorkspaceRoot 'tools\luajit\luajit.exe'
    if (Test-Path -LiteralPath $Luajit) {
        $LuaFiles = @(Get-ChildItem -LiteralPath $StageMods -Recurse -File -Filter *.lua)
        foreach ($LuaFile in $LuaFiles) {
            $LuaResult = Invoke-Native $Luajit @('-bl', $LuaFile.FullName) -Quiet
            if ($LuaResult.Code -ne 0) { Fail "Lua syntax error: $($LuaFile.FullName)" }
        }
        Write-Host "  luajit -bl: $($LuaFiles.Count) files OK"
    } else {
        $LuaCheck = Join-Path $WorkspaceRoot 'tools\lua-check.mjs'
        if (-not (Test-Path -LiteralPath $LuaCheck)) { Fail 'no luajit and no tools\lua-check.mjs fallback' }
        $LuaResult = Invoke-Native $Node @($LuaCheck, $StageMods)
        if ($LuaResult.Code -ne 0) { Fail 'lua-check reported a syntax error' }
    }
} else {
    Write-Host 'WARNING: -SkipGates set; the zip is NOT gated.' -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------
# Zip + release notes
# ---------------------------------------------------------------------------
Step 'archive'
New-Item -ItemType Directory -Force $OutDir | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
Add-Type -AssemblyName System.IO.Compression
$ZipPath = Join-Path $OutDir ('AI-Suite-{0}.zip' -f $Lock.suiteVersion)
$ZipTemp = $ZipPath + '.partial'
if (Test-Path -LiteralPath $ZipTemp) { Remove-Item -LiteralPath $ZipTemp -Force }
# Drop any previous build first: a failed gate must not leave an older zip for
# tests\run-tests.ps1 to pick up and validate as if it were this build.
if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
# Build the archive entry by entry so every name uses '/' (the .NET Framework
# CreateFromDirectory helper writes '\' on Windows). Write to a temp name so a
# failed run cannot leave a half-written zip for the tests to pick up.
try {
    $Zip = [System.IO.Compression.ZipFile]::Open($ZipTemp, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($Name in $LoadOrder) {
            $ModDir = Join-Path $StageMods $Name
            foreach ($File in Get-ChildItem -LiteralPath $ModDir -Recurse -File -Force) {
                $Relative = $File.FullName.Substring($StageMods.Length + 1).Replace('\', '/')
                [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
                    $Zip,
                    $File.FullName,
                    $Relative,
                    [System.IO.Compression.CompressionLevel]::Optimal
                ) | Out-Null
            }
        }
    } finally {
        $Zip.Dispose()
    }
    if (Test-Path -LiteralPath $ZipPath) { Remove-Item -LiteralPath $ZipPath -Force }
    Move-Item -LiteralPath $ZipTemp -Destination $ZipPath -Force
} catch {
    if (Test-Path -LiteralPath $ZipTemp) { Remove-Item -LiteralPath $ZipTemp -Force }
    Fail "archive failed: $($_.Exception.Message)"
}
$Hash = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash
$Size = (Get-Item -LiteralPath $ZipPath).Length

$Lines = New-Object System.Collections.Generic.List[string]
$Lines.Add('# AI Suite ' + $Lock.suiteVersion)
$Lines.Add('')
$Lines.Add('One download, four mods. Extract every folder into `PAYDAY 2\mods\`.')
$Lines.Add('')
$Lines.Add('| Mod | Version | Commit | Role | License |')
$Lines.Add('| --- | --- | --- | --- | --- |')
foreach ($Name in $LoadOrder) {
    $Mod = $Lock.mods.$Name
    $Role = switch ($Name) {
        'LIES' { 'enemy AI: detection, aim, cover, travel' }
        'Monkeepers' { 'bot bag logistics' }
        'Iter' { 'navigation, coarse search, nav-link queue' }
        'Keepers' { 'bot orders, revives, jokers' }
        default { '' }
    }
    $Lines.Add(('| {0} | {1} | `{2}` | {3} | {4} |' -f $Name, $Mod.version, $Mod.commit, $Role, $Mod.license))
}
$Lines.Add('')
$Lines.Add('Load order (priority descending, shipped in each mod.txt): ' + (($LoadOrder | ForEach-Object { '{0} {1}' -f $_, $Lock.mods.$_.priority }) -join ', ') + '.')
$Lines.Add('')
$Lines.Add(('Tested with Useful Bots {0} + HopLib {1}; The Fixes optional.' -f $Lock.testedWith.'Useful Bots', $Lock.testedWith.HopLib))
$Lines.Add('')
$Lines.Add('Per-mod auto-updates are unchanged: Iter/Keepers/Monkeepers use their GitHub release feeds, LIES uses its ModWorkshop feed.')
$Lines.Add('')
$Lines.Add(('Archive: {0} ({1:N0} KB), SHA-256 `{2}`' -f (Split-Path $ZipPath -Leaf), ($Size / 1KB), $Hash))
$NotesPath = Join-Path $OutDir ('AI-Suite-{0}-release-notes.md' -f $Lock.suiteVersion)
Set-Content -LiteralPath $NotesPath -Value ($Lines -join "`n") -Encoding utf8

Write-Host ''
Write-Host "built $ZipPath" -ForegroundColor Green
Write-Host ('size:   {0:N0} KB' -f ($Size / 1KB))
Write-Host "sha256: $Hash"
Write-Host "notes:  $NotesPath"
Write-Host ''
Write-Host 'Upload the zip to the ModWorkshop page; users extract it into:'
Write-Host '  C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods'
