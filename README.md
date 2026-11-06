# AI Suite

One ModWorkshop download for the 248.2 x64 AI stack: **LIES + Iter + Keepers +
Monkeepers**. The zip contains four independent mod folders; extract all of
them into `PAYDAY 2\mods\`.

This repository is the **release assembler** only. It contains no mod code:
the four mods live in their own repositories, keep their own versions, save
files, settings menus and update feeds, and are maintained against upstream
there.

## What is in the zip

| Mod | Role | Version | License |
| --- | --- | --- | --- |
| **LIES** | enemy AI: detection, aim, cover, travel, squad coordination | 8.57.32 | AGPL-3.0 |
| **Monkeepers** | bot bag logistics and drop objectives | 87.4 | Unlicense |
| **Iter** | navigation core: coarse search, nav-link queue, level nav fixes | 205.3 | Unlicense |
| **Keepers** | bot orders, revive assistants, converted cops/jokers | 239.3 | Unlicense |

Load order is part of the integration and ships inside each `mod.txt`
(priority descending):

```
LIES 100 -> Monkeepers 99 -> Iter 40 -> Keepers 10 -> Useful Bots 0 -> The Fixes -10
```

Do not edit the priorities. The mods wrap each other's functions in that
order; the ownership contract in the workspace
(`docs\reference\ai-suite-compatibility.md`) is what proves the stack works.

## Not included

- **Useful Bots 2.6.3** + **HopLib 2.1.2** - required for bot combat and
  utility ([ModWorkshop #31221](https://modworkshop.net/mod/31221)). Install
  them separately; the suite is tested with them.
- **The Fixes** - optional general-fix supermod. Supported (it wins
  `CopActionWalk._init` in the full profile; Iter re-wraps afterwards).

## Install

1. Download `AI-Suite-<version>.zip` from the release.
2. Extract the four folders into
   `C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods`.
3. Install Useful Bots and HopLib if you want bot combat/utility.
4. Start the game. Each mod keeps its own options page under
   `BLT Options`.

Names matter: folders must stay `LIES`, `Iter`, `Keepers`, `Monkeepers`.
`Monkeepers` declares `Keepers` as a dependency, and Useful Bots/other mods
detect `Keepers` by name and by `_G.Keepers`.

## Updates

Per-mod update feeds are unchanged, and none of them knows about this bundle:

- **Iter, Keepers, Monkeepers** use SuperBLT's `updates` entry pointing at their
  GitHub `releases/latest/download/meta.json`, so SuperBLT offers their updates.
- **LIES** has no ModWorkshop page and no SuperBLT feed. Its own menu checks
  `https://raw.githubusercontent.com/met94/Little-Intelligence-Enhancements-x64/main/autoupdate.json`
  at startup (`LIES.update_url`, `menumanager.lua`), compares the advertised
  version for equality, and links to the GitHub releases page. It never
  downloads or installs anything. `autoupdate.json` is served from raw GitHub
  and is not part of the mod folder (nor of this zip).

So you can update a single mod and stay on the bundle's other three; when the
suite moves as a whole, a new bundle is cut with the versions in
`suite.lock.json`.

## Building the bundle

```powershell
# from this repo; needs the four mods checked out under <workspace>\mods
powershell -NoProfile -ExecutionPolicy Bypass -File build.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests\run-tests.ps1
```

`build.ps1`:

1. reads `suite.lock.json` (repo, commit, version, priority per mod);
2. checks each commit out in a temporary worktree under `.build\src\` (the
   member checkouts are not switched or modified; the worktrees are removed on
   exit, success or failure, and stale registrations are pruned before each
   `worktree add`);
3. runs each mod's own `dev/build.ps1` where it exists (LIES, Iter) and
   copies the runtime tree otherwise (Keepers, Monkeepers); the member build
   markers (`.lies-build`, `.iter-build`) are dev provenance and are dropped;
4. asserts the staged `mod.txt` name/version/priority and that no `dev/`,
   `dist/`, `tests/`, `.git` or build marker ships;
5. runs `crossmod-check --strict` against the staged bytes with a real
   Useful Bots 2.6.3 tree (`-UbDir`, `PD2_UB_DIR`, or the live install from
   `workspace.json`), plus a Lua syntax gate;
6. writes `dist\AI-Suite-<version>.zip` and `-release-notes.md` with the
   SHA-256 (via a temp file, so a failed run never leaves a half-written zip).

Options: `-WorkspaceRoot`, `-ContractRoot`, `-UbDir`, `-OutDir`, `-SkipGates`
(dev only). `-ContractRoot` points the ownership gate at a workspace checkout
whose `docs\reference\ai-suite-ownership.json` is the one to validate against —
use it to gate before a contract fix has merged into the workspace.
Never point `-UbDir` at the 2024 `old_mods` audit copy: it lacks the per-script
files and produces five phantom `missing-script` errors.

## Release checklist

1. Merge/update the affected mod repo(s), release them upstream first.
2. Bump its `commit`/`version` in `suite.lock.json` (and the suite version).
3. `build.ps1` -> gates green.
4. `tests\run-tests.ps1` -> PASS.
5. Upload the zip + `-release-notes.md` to ModWorkshop, update `changelog.txt`.

## Credits

- **LIES** - fugsystem (original), 248.2 x64 fork maintenance by met94.
  AGPL-3.0; full source ships inside the folder and at
  [met94/Little-Intelligence-Enhancements-x64](https://github.com/met94/Little-Intelligence-Enhancements-x64).
- **Iter**, **Keepers**, **Monkeepers** - TdlQ (original), BangL (Iter
  maintenance), translators per each `mod.txt`, 248.2 fork maintenance by
  met94. Unlicense.
- **Useful Bots** - Hoppip (not part of this bundle).

Each folder ships its own `LICENSE`, `README.md`, `changelog.txt` and
`MENU_OPTIONS.md`; they are the authoritative per-mod documents.

## License

This assembler repository is released into the public domain (Unlicense).
The bundled mod folders keep their own licenses - LIES is AGPL-3.0, the other
three are Unlicense. This bundle is an aggregation: it does not relicense any
member.
