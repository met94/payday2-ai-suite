# AI Suite

One download for the PAYDAY 2 248.2 x64 AI stack: **LIES**, **Iter**,
**Keepers** and **Monkeepers**, packaged together and tested as one stack. The
zip holds the four mod folders - extract all of them into `PAYDAY 2\mods\`.

## What it changes in-game

- Cops detect you, pick cover, push and coordinate as squads instead of
  trickling in one at a time.
- Enemy and bot AI uses ladders, doors and jumps without clumping up at nav
  links, and keeps pathing on maps that used to break it.
- You can order your bots to move, hold position, revive and fight, and
  converted cops and jokers follow those orders too.
- Bots pick up, carry and drop bags like players.

Every feature is tunable: each mod keeps its own settings page under
**BLT Options**.

## What's in the download

| Mod | What it does | Version |
| --- | --- | --- |
| [**LIES**](https://github.com/met94/Little-Intelligence-Enhancements-x64) | enemy AI: detection, aim, cover, travel, squad coordination | 8.57.32 |
| [**Iter**](https://github.com/met94/payday2-mod-Iter) | navigation: pathing, nav-link queueing, level nav fixes | 205.3 |
| [**Keepers**](https://github.com/met94/payday2-mod-Keepers) | bot orders, revive assistants, converted cops and jokers | 239.3 |
| [**Monkeepers**](https://github.com/met94/payday2-mod-Monkeepers) | bot bag logistics: pick up, carry and drop bags | 87.4 |

## Requirements

- **SuperBLT** (64-bit) - required by all four mods.
- [**Useful Bots 2.6.3**](https://modworkshop.net/mod/31221) + **HopLib** -
  optional, but this is the bot combat and utility layer the suite is tested
  with (intimidation, marking, target priority).
- [**The Fixes**](https://modworkshop.net/mod/23732) - optional general-fix
  mod; it works alongside the suite.

## Install

1. Download `AI-Suite-<version>.zip` from the release.
2. Extract all four folders into
   `C:\Program Files (x86)\Steam\steamapps\common\PAYDAY 2\mods`.
3. Keep the folder names exactly `LIES`, `Iter`, `Keepers`, `Monkeepers` - the
   mods find each other by name.
4. Optionally install Useful Bots + HopLib as well.
5. Start the game; the settings appear under **BLT Options**.

Already running one of the four? The bundle's copy replaces it - back up local
edits first. The mods share save files with their standalone versions, so your
settings carry over.

## Updates

- **Iter**, **Keepers** and **Monkeepers** update through SuperBLT's normal
  update prompt.
- **LIES** shows its own update prompt in-game and links to its GitHub
  releases.
- The four are versioned separately: updating one does not force a new bundle
  download. A new bundle is published when the whole stack moves.

## If something breaks

1. Check the newest file in `PAYDAY 2\mods\logs\` for a Lua error; the file path
   in the error names the mod that failed.
2. Report the bug on that mod's repository (linked in the table above), not
   here.
3. Installation or packaging problems (wrong folder structure, missing files)
   belong in this repository's issues.

## Credits

- **LIES** - fugsystem (original), 248.2 x64 fork maintenance by met94.
- **Iter**, **Keepers**, **Monkeepers** - TdlQ (original), BangL (Iter
  maintenance), translations by the authors listed in each `mod.txt`, 248.2
  fork maintenance by met94.
- **Useful Bots** - Hoppip; not part of this download.

Each mod folder ships its own `README.md`, `changelog.txt`, `MENU_OPTIONS.md`
and `LICENSE` - those are the authoritative per-mod documents.

## License

This bundle repository is public domain (Unlicense). The mods keep their own
licenses: LIES is AGPL-3.0, Iter/Keepers/Monkeepers are Unlicense. Bundling
them together does not relicense anything.

## For maintainers

Build, gate and release instructions: [`MAINTAINING.md`](MAINTAINING.md).
