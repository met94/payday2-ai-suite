# Maintaining the AI Suite bundle

This repository holds no mod code. It pins the member repositories at released
commits, stages their runtime trees, gates the result, and emits two ModWorkshop
archives:

- **`AI-Suite-<version>.zip`** — the four AI mods we maintain (`LIES`, `Iter`,
  `Keepers`, `Monkeepers`). The compatibility contract validates these.
- **`AI-Suite-Dependencies-<version>.zip`** — the three upstream packages
  `Keepers` requires: `Simple Mod Updater`, `GoonMod's Custom Waypoints`,
  `No Duplicated Bullets`. Redistributed unmodified; outside the contract.

Member repos keep their own versions, priorities, save files, settings menus and
update feeds.

## Member repositories

| Mod | Group | Repository | Build input |
| --- | --- | --- | --- |
| **LIES** | suite | [met94/Little-Intelligence-Enhancements-x64](https://github.com/met94/Little-Intelligence-Enhancements-x64) | its `dev/build.ps1` (`dist/LIES`) |
| **Iter** | suite | [met94/payday2-mod-Iter](https://github.com/met94/payday2-mod-Iter) | its `dev/build.ps1` (`dist/Iter`) |
| **Keepers** | suite | [met94/payday2-mod-Keepers](https://github.com/met94/payday2-mod-Keepers) | runtime copy (no `dev/`) |
| **Monkeepers** | suite | [met94/payday2-mod-Monkeepers](https://github.com/met94/payday2-mod-Monkeepers) | runtime copy (no `dev/`) |
| **Simple Mod Updater** | dependencies | workspace mirror of the z77 zip (local repo `mods\Simple Mod Updater`) | runtime copy (upstream 34) |
| **GoonMod's Custom Waypoints** | dependencies | [met94/payday2-mod-GoonmodCustomWaypoints](https://github.com/met94/payday2-mod-GoonmodCustomWaypoints) | runtime copy (upstream r50) |
| **No Duplicated Bullets** | dependencies | [met94/payday2-mod-NoDuplicatedBullets](https://github.com/met94/payday2-mod-NoDuplicatedBullets) | runtime copy (upstream r10 + 248 trim) |

Each one is expected to be checked out at `<workspace>\mods\<name>`. The
dependencies have no `README`/`LICENSE`/`MENU_OPTIONS`, so the lock marks the
four AI mods with `"docs": true` and the build/test gates require those files
only for them. A lock entry may also carry `"name"` (mod.txt display name when
it differs from the key) and `"folder"` (shipped folder name when it differs,
e.g. `Simple Mod Updater`).

## Layout

| Path | Purpose |
| --- | --- |
| `suite.lock.json` | pins per mod (dir, group, commit, `mod.txt` version, priority, license, build/dist, excludes), the two groups, the UB/HopLib pin and the suite version |
| `build.ps1` | stage -> gates -> one zip + notes per group |
| `tests\run-tests.ps1` | lock vs member repos, plus both archives' layout/metadata |
| `dist\` | generated zips and release notes (gitignored) |
| `.build\` | generated staging area and temp worktrees (gitignored) |

## Lock file

`suite.lock.json` is the single source of truth for what ships:

```json
"LIES": {
  "dir": "LIES",
  "group": "suite",
  "commit": "dc08e92",
  "version": "8.57.33",
  "priority": 100,
  "license": "AGPL-3.0",
  "docs": true,
  "build": "dev/build.ps1",
  "dist": "dist/LIES"
}
```

`groups.suite` / `groups.dependencies` decide archive membership. `loadOrder`
is priority-descending and `tests\run-tests.ps1` asserts the order; the suite
priorities must stay unique (`100 / 99 / 40 / 10`), while the dependencies carry
their published keys (`10000` for the updater, `0` for the two utilities).

Bump a member's `commit` + `version` after its release, then bump
`suiteVersion` (date form, `YYYY.MM.DD[.n]`).

## Build

```powershell
# from this repo; needs the seven mods checked out under <workspace>\mods
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1
```

`build.ps1`:

1. reads `suite.lock.json`;
2. checks each pinned commit out in a temporary worktree under `.build\src\`
   (member checkouts are not switched or modified; worktrees are removed on
   exit, success or failure, and stale registrations are pruned before each
   `worktree add`);
3. runs each mod's own `dev/build.ps1` where it exists (LIES, Iter) and copies
   the runtime tree otherwise; member build markers (`.*-build`) are stripped;
4. asserts the staged `mod.txt` name/version/priority and that no `dev/`,
   `dist/`, `tests/`, `.git` or build marker ships;
5. runs `crossmod-check --strict` against the staged tree with a real Useful
   Bots 2.6.3 tree (`-UbDir`, `PD2_UB_DIR`, or the live install from the
   workspace `workspace.json`), plus a Lua syntax gate (`luajit -bl`, or
   `tools\lua-check.mjs` as fallback);
6. writes one zip per group through a `.partial` temp file, plus a
   `-release-notes.md` with that archive's SHA-256.

Flags: `-WorkspaceRoot`, `-ContractRoot`, `-UbDir`, `-OutDir`, `-SkipGates`
(dev only).

`-ContractRoot` points the ownership gate at another workspace checkout - use
it to gate against a contract fix that has not merged yet. Never point `-UbDir`
at the 2024 `old_mods` Useful Bots audit copy: it lacks the per-script files
and produces five phantom `missing-script` errors.

## Gates

| Gate | Command | Expected |
| --- | --- | --- |
| Ownership contract | `node <workspace>\tools\crossmod-check.mjs --root <workspace> --mods-dir <staged>\mods --ub-dir "<live>\Useful Bots" --strict` | PASS, 0 target deviations (5 gated / 2 rewrapped INFO lines) |
| Lua syntax | `tools\luajit\luajit.exe -bl` over every staged `.lua` | 0 errors |
| Lock + archives | `tests\run-tests.ps1` | PASS (~620 checks) |

The staged-bytes gate is the point: it validates the exact archives users
install, not the working copies. The contract only covers the four AI mods; the
three dependency mods are upstream code and are not validated against it.

The contract itself lives in the workspace, not here:
`docs\reference\ai-suite-compatibility.md` +
`docs\reference\ai-suite-ownership.json`.

## Release checklist

1. Land and release the changed AI mod repo(s) first; note the commit and the
   `mod.txt` version.
2. Bump that entry in `suite.lock.json` (`commit`, `version`) and
   `suiteVersion`.
3. `build.ps1` -> both archives, all gates green.
4. `tests\run-tests.ps1` -> PASS.
5. Commit, tag `v<suiteVersion>` and push both.
6. `gh release create v<suiteVersion> dist\AI-Suite-<v>.zip dist\AI-Suite-<v>-release-notes.md dist\AI-Suite-Dependencies-<v>.zip dist\AI-Suite-Dependencies-<v>-release-notes.md --title "AI Suite <v>" --notes-file dist\AI-Suite-<v>-release-notes.md`
7. Upload both zips and both notes files to the ModWorkshop page; update
   `changelog.txt`.
8. The user deploys; agents never copy mods into the game.

The dependency archive only changes when an upstream package changes. When that
happens, re-import it (verify byte-identical to the deployed copy), bump that
pin, and re-cut; do not edit the upstream files.

## Hard constraints

- **Never rename a bundled folder.** `Keepers`/`Simple Mod Updater` names are
  dependency keys; Useful Bots and other mods gate on `if Keepers then` and on
  `_G.Keepers`.
- **Never change a member's `priority`.** The order
  `Simple Mod Updater 10000 -> LIES 100 -> Monkeepers 99 -> Iter 40 -> Keepers
  10 -> GoonMod's Custom Waypoints 0 -> No Duplicated Bullets 0` is the
  compatibility contract; the AI mods wrap each other's functions in that order.
- **Never ship dev paths.** `dev/`, `dist/`, `tests/`, `.git`, `.build` and
  `.*-build` markers are rejected by both the build and the archive tests.
- **External mods stay external.** Useful Bots, HopLib and The Fixes are never
  bundled; they are only pinned in the notes/metadata.
- **The dependencies are outside the contract.** `Simple Mod Updater`,
  `GoonmodCustomWaypoints` and `NoDuplicatedBullets` are redistributed
  unmodified; do not add ownership rows, change their code, or touch their
  update feeds (`simple_update_url` / `SimpleModUpdater` belong to the original
  author). If they ever need a fork fix, that lives in their own repo and gets a
  new pin.

## Update feeds (why the bundle is not one)

| Mod | Path |
| --- | --- |
| LIES, Iter, Keepers, Monkeepers | SuperBLT `updates` -> GitHub `releases/latest/download/meta.json` |
| Simple Mod Updater, GoonMod's Custom Waypoints, No Duplicated Bullets | the original author's chain: `simple_update_url` -> `pd2mods.z77.fr`. SMU resolves the legacy `SimpleModUpdater` entries; nothing in this bundle changes them |
| LIES (pre-8.57.33) | legacy bridge `https://raw.githubusercontent.com/met94/Little-Intelligence-Enhancements-x64/main/autoupdate.json` (`LIES-AI-MOD`); still bumped every release, not shipped |

LIES moved to the SuperBLT feed in 8.57.33; `autoupdate.json` exists only so
builds older than that still see an update. Remove the bridge once those builds
have aged out. LIES has no ModWorkshop page.
