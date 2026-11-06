# ModWorkshop page copy — AI Suite

Everything below is written for the public page. The "Description" block is the
part to paste into the description field; the field list above it is for the
page form.

## Page fields

- **Name:** AI Suite
- **Short description:** LIES + Iter + Keepers + Monkeepers in one download —
  the PAYDAY 2 248.2 AI stack, tested as one.
- **Category:** BLT → Gameplay Changing
- **Tags:** Lua, Gameplay Changing, Bugfix
- **Version:** 2026.11.06.1
- **Dependencies (required):** SuperBLT (64-bit)
- **Dependencies (optional, tested):** Useful Bots 2.6.3 (`https://modworkshop.net/mod/31221`),
  The Fixes (`https://modworkshop.net/mod/23732`)
- **Thumbnail:** `art/ai-suite-thumbnail.png`
- **Download:** `AI-Suite-2026.11.06.1.zip` (four folders at the archive root)

## Description (paste this)

**One download, four mods.** AI Suite packages the 248.2 x64 AI stack —
**LIES**, **Iter**, **Keepers** and **Monkeepers** — as a single archive. They
are designed and tested to run together, and this page is the easiest way to
install all four with matching versions.

Each mod is its own folder with its own settings page, changelog and license, and
each keeps its own update path. The bundle only packages them; nothing is merged
or rewritten.

### What is in the download

- **LIES 8.57.32** — enemy AI: detection, aim, cover use, suppression, travel and
  squad coordination. Cops push together, take sensible cover and no longer know
  where you are at all times.
- **Iter 205.3** — navigation: path streaming, coarse-search caching, nav-link
  queueing, direct-to-pos, path extension and per-level nav fixes. NPCs stop
  clumping on ladders, doors and vaults, and maps whose nav data broke after U247
  path again.
- **Keepers 239.3** — bot orders: stationary, use cover, patrol, follow and hold,
  precise waypoint positioning, revive assistants, joker control and shout
  filtering.
- **Monkeepers 87.4** — bot bag logistics: teammates pick up, carry and drop bags,
  use bag-capable ziplines, and deliver to vehicles that accept the loot.

Every feature can be tuned or turned off: each mod has its own page under
**BLT Options**.

### Requirements

- **PAYDAY 2 248.2 x64** and **SuperBLT**.
- **Useful Bots 2.6.3** + **HopLib** — optional, but this is the bot combat and
  utility layer the suite is tested with (intimidation, marking, target
  priority). Get Useful Bots here: https://modworkshop.net/mod/31221
- **The Fixes** — optional general-fix mod, works alongside the suite:
  https://modworkshop.net/mod/23732

### Installation

1. Close PAYDAY 2.
2. Extract the archive so the four folders end up here:
   `...\PAYDAY 2\mods\LIES\`, `...\mods\Iter\`, `...\mods\Keepers\`,
   `...\mods\Monkeepers\` — each with its `mod.txt` directly inside.
3. Start the game. Settings appear under **Mod Options**.

Keep the folder names exactly as they are: the mods find each other by name, and
Monkeepers requires Keepers.

Already using one of these mods standalone? The bundle's copy replaces it — your
save files are shared with the standalone versions, so settings carry over. Do
not keep two copies of the same mod folder; SuperBLT treats the name as the
dependency key and one copy will win unpredictably.

### Updating

- Iter, Keepers and Monkeepers update through SuperBLT's normal update prompt.
- LIES shows its own update prompt in-game and links to its GitHub releases.
- The four are versioned separately, so updating one does not force a new bundle
  download. A new bundle is published when the whole stack moves.

### If something breaks

1. Check the newest file in `PAYDAY 2\mods\logs\` — a Lua error names the file and
   therefore the mod that failed.
2. Report the bug on that mod's repository:
   - LIES: https://github.com/met94/Little-Intelligence-Enhancements-x64
   - Iter: https://github.com/met94/payday2-mod-Iter
   - Keepers: https://github.com/met94/payday2-mod-Keepers
   - Monkeepers: https://github.com/met94/payday2-mod-Monkeepers
3. Installation or packaging problems (missing folder, wrong structure) belong in
   the bundle repository:
   https://github.com/met94/payday2-ai-suite

### Credits

- **LIES** — original mod and AI design by fugsystem; 248.2 x64 fork maintenance
  by met94.
- **Iter**, **Keepers**, **Monkeepers** — original mods by TdlQ; Iter maintenance
  by BangL; translations by the authors listed in each `mod.txt`; 248.2 fork
  maintenance by met94.
- **Useful Bots** — Hoppip (not part of this download).
- Decompiled game reference: steam-test1/Payday-2-LuaJIT-Complete.

Each mod folder ships its own `README.md`, `changelog.txt`, `MENU_OPTIONS.md` and
`LICENSE` — those are the authoritative documents for that mod.

### License

The bundle repository is public domain (Unlicense). The mods keep their own
licenses: LIES is AGPL-3.0, Iter/Keepers/Monkeepers are Unlicense. Bundling them
does not relicense anything.

### Changelog

**2026.11.06.1** — documentation re-cut: same mods, same versions and code as
2026.11.06; each folder now ships a rewritten, player-facing README. Nothing
changes in-game.

**2026.11.06** — first bundle: LIES 8.57.32, Iter 205.3, Keepers 239.3,
Monkeepers 87.4.

## Notes for the upload

- Upload the zip from the GitHub release
  `https://github.com/met94/payday2-ai-suite/releases/tag/v2026.11.06.1`
  (`AI-Suite-2026.11.06.1.zip`, SHA-256
  `1F5198DBC202B1B583573B91A6683C7667AACD9DB9DE265752085F0935F84C75`).
- The archive root must contain the four folders, not a wrapper folder — it
  already does.
- ModWorkshop renders Markdown; the description above is plain Markdown.
