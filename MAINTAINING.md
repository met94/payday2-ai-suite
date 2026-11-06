# Maintaining the AI Suite bundle

This repository holds no mod code. It pins the four member repositories at
released commits, stages their runtime trees, gates the result, and emits one
ModWorkshop zip. The member repos keep their own versions, priorities, save
files, settings menus and update feeds.

## Member repositories

| Mod | Repository | Build input |
| --- | --- | --- |
| **LIES** | [met94/Little-Intelligence-Enhancements-x64](https://github.com/met94/Little-Intelligence-Enhancements-x64) | its `dev/build.ps1` (`dist/LIES`) |
| **Iter** | [met94/payday2-mod-Iter](https://github.com/met94/payday2-mod-Iter) | its `dev/build.ps1` (`dist/Iter`) |
| **Keepers** | [met94/payday2-mod-Keepers](https://github.com/met94/payday2-mod-Keepers) | runtime copy (no `dev/`) |
| **Monkeepers** | [met94/payday2-mod-Monkeepers](https://github.com/met94/payday2-mod-Monkeepers) | runtime copy (no `dev/`) |

Each one is expected to be checked out at `<workspace>\mods\<name>`.

## Layout

| Path | Purpose |
| --- | --- |
| `suite.lock.json` | member pins: repo dir, commit, `mod.txt` version, priority, license, build script / dist path, exclude list; plus the UB/HopLib pin and suite version |
| `build.ps1` | stage -> gates -> zip + release notes |
| `tests\run-tests.ps1` | lock vs member repos, plus archive layout/metadata |
| `dist\` | generated zip and release notes (gitignored) |
| `.build\` | generated staging area and temp worktrees (gitignored) |

## Lock file

`suite.lock.json` is the single source of truth for what ships:

```json
"LIES": {
  "dir": "LIES",
  "commit": "f9f6663",
  "version": "8.57.32",
  "priority": 100,
  "license": "AGPL-3.0",
  "build": "dev/build.ps1",
  "dist": "dist/LIES"
}
```

`loadOrder` is priority-descending and `tests\run-tests.ps1` asserts the order
`100 / 99 / 40 / 10`. Bump `commit` + `version` after a member release, then
bump `suiteVersion` (date form, `YYYY.MM.DD`).

## Build

```powershell
# from this repo; needs the four mods checked out under <workspace>\mods
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
   the runtime tree otherwise (Keepers, Monkeepers); member build markers
   (`.*-build`) are stripped as dev provenance;
4. asserts the staged `mod.txt` name/version/priority and that no `dev/`,
   `dist/`, `tests/`, `.git` or build marker ships;
5. runs `crossmod-check --strict` against the staged bytes with a real Useful
   Bots 2.6.3 tree (`-UbDir`, `PD2_UB_DIR`, or the live install from the
   workspace `workspace.json`), plus a Lua syntax gate (`luajit -bl`, or
   `tools\lua-check.mjs` as fallback);
6. writes `dist\AI-Suite-<version>.zip` through a `.partial` temp file, then
   `AI-Suite-<version>-release-notes.md` with the SHA-256.

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
| Lock + archive | `tests\run-tests.ps1` | PASS (~490 checks) |

The staged-bytes gate is the point: it validates the exact archive users
install, not the working copies.

The contract itself lives in the workspace, not here:
`docs\reference\ai-suite-compatibility.md` +
`docs\reference\ai-suite-ownership.json`.

## Release checklist

1. Land and release the changed member repo(s) first; note the commit and the
   `mod.txt` version.
2. Bump that entry in `suite.lock.json` (`commit`, `version`) and
   `suiteVersion`.
3. `build.ps1` -> all gates green.
4. `tests\run-tests.ps1` -> PASS.
5. Commit, tag `v<suiteVersion>` and push both.
6. `gh release create v<suiteVersion> dist\AI-Suite-<suiteVersion>.zip dist\AI-Suite-<suiteVersion>-release-notes.md --title "AI Suite <suiteVersion>" --notes-file dist\AI-Suite-<suiteVersion>-release-notes.md`
7. Upload the same zip + notes to the ModWorkshop page; update `changelog.txt`.
8. The user deploys; agents never copy mods into the game.

## Hard constraints

- **Never rename a bundled folder.** `Monkeepers` declares `Keepers` as a
  dependency; Useful Bots and other mods gate on `if Keepers then` and on
  `_G.Keepers`.
- **Never change a member's `priority`.** The order
  `LIES 100 -> Monkeepers 99 -> Iter 40 -> Keepers 10 -> Useful Bots 0 ->
  The Fixes -10` is the compatibility contract; the mods wrap each other's
  functions in that order.
- **Never ship dev paths.** `dev/`, `dist/`, `tests/`, `.git`, `.build` and
  `.*-build` markers are rejected by both the build and the archive tests.
- **External mods stay external.** Useful Bots, HopLib and The Fixes are never
  bundled; they are only pinned in the notes/metadata.

## Update feeds (why the bundle is not one)

| Mod | Path |
| --- | --- |
| Iter, Keepers, Monkeepers | SuperBLT `updates` -> GitHub `releases/latest/download/meta.json` |
| LIES | its own menu poll of `https://raw.githubusercontent.com/met94/Little-Intelligence-Enhancements-x64/main/autoupdate.json` (`LIES.update_url`, `menumanager.lua:51`, fetched at `:922`); equality compare, links to GitHub releases, never installs |

`autoupdate.json` is served from raw GitHub and is not part of the mod folder or
the zip. The `LIES-AI-MOD` string is only the identifier inside that JSON; LIES
has no ModWorkshop page and no SuperBLT feed.
