# ModWorkshop page copy — AI Suite

Everything below is written for the public page. The "Description" block is the
part to paste into the description field; the field list above it is for the
page form.

## Page fields

- **Name:** AI Suite
- **Short description:** LIES + Iter + Keepers + Monkeepers — the PAYDAY 2 248.2
  AI stack in one download, with Keepers' two required utilities included.
- **Category:** BLT → Gameplay Changing
- **Tags:** Lua, Gameplay Changing, Bugfix
- **Version:** 2026.11.07
- **Dependencies (required):** SuperBLT (64-bit)
- **Dependencies (optional, tested):** Useful Bots 2.6.3
  (`https://modworkshop.net/mod/31221`), The Fixes
  (`https://modworkshop.net/mod/23732`)
- **Thumbnail:** `art/ai-suite-thumbnail.png`
- **Download:** `AI-Suite-2026.11.07.zip` (six folders at the archive root)

## Description (paste this)

**One download, six folders, one tested stack.** AI Suite packages the
PAYDAY 2 248.2 x64 AI setup: **LIES**, **Iter**, **Keepers** and
**Monkeepers**, plus the two utility mods **Keepers requires** —
**GoonMod's Custom Waypoints** and **No Duplicated Bullets**. All of it is
tested together, so you do not have to hunt down dependency prompts or match
versions.

Each mod keeps its own folder, its own settings page, its own changelog and its
own update path. The bundle only packages them — nothing is merged or rewritten.

### What each mod does

**LIES — enemy AI** · [source and details](https://github.com/met94/Little-Intelligence-Enhancements-x64)

The big one. Cops detect you more plausibly, lose track of you, evaluate cover
against the actual threat, aim and suppress with more variation, and coordinate
pushes as squads instead of trickling in one by one. Includes fixes for special
units (shields, tasers, tanks, phalanx) and optional "Spicy Tactics" spawn and
tactics pressure (off by default). Every part is tunable in its own menu.

**Iter — navigation** · [source and details](https://github.com/met94/payday2-mod-Iter)

Fixes how NPCs move between places. Paths are streamlined and cached, ladders,
doors and vaults are queued instead of dogpiled, units can be sent directly to a
position, and their path is extended ahead while they walk. Adds per-level nav
fixes for maps whose nav data broke after U247. Iter is what makes the AI feel
fluid rather than stuck.

**Keepers — bot orders** · [source and details](https://github.com/met94/payday2-mod-Keepers)

Lets you command your AI teammates and jokers: stationary, use cover, patrol,
follow and hold; precise positioning via waypoints; sending bots to interact
with objects or carry bags; revive assistance; custom joker names and health
bars; and shout filtering so marking cops does not reassign your bots.

**Monkeepers — bot bag logistics** · [source and details](https://github.com/met94/payday2-mod-Monkeepers)

Your bots pick up, carry and drop loot bags like players. It learns routes from
where you take a bag to where it lands, applies them to the bags around that
spot, and expires them on its own. Bots catch thrown bags, use bag-capable
ziplines and pick bags off shelves. Requires Keepers.

**GoonMod's Custom Waypoints — utility** · [source and details](https://github.com/met94/payday2-mod-GoonmodCustomWaypoints)

Player and crew waypoints, including the prev/next waypoint list. Keepers uses
these marks for its positioning orders.

**No Duplicated Bullets — utility** · [source and details](https://github.com/met94/payday2-mod-NoDuplicatedBullets)

As a client, filters damage that should only be applied by the host, so
non-player attackers cannot produce duplicate damage locally. As host it does
nothing.

### Requirements

- **PAYDAY 2 248.2 x64** and **SuperBLT** — required.
- **Useful Bots 2.6.3 + HopLib** — optional, but this is the bot combat and
  utility layer the suite is tested with (intimidation, marking, target
  priority): https://modworkshop.net/mod/31221
- **The Fixes** — optional general-fix mod, works alongside the suite:
  https://modworkshop.net/mod/23732

Keepers' dependencies are already inside the download, so SuperBLT will not
prompt for anything.

### Installation

1. Close PAYDAY 2.
2. Extract the archive so all six folders end up in
   `...\PAYDAY 2\mods\`: `LIES`, `Iter`, `Keepers`, `Monkeepers`,
   `GoonmodCustomWaypoints`, `NoDuplicatedBullets` — each with its `mod.txt`
   directly inside.
3. Start the game. Settings appear under **Mod Options**.

Keep the folder names exactly as they are: the mods find each other by name, and
Monkeepers requires Keepers. Do not keep two copies of the same mod folder —
SuperBLT treats the name as the dependency key.

Already using one of these mods standalone? The bundle's copy replaces it. Save
files are shared with the standalone versions, so your settings carry over.

### Updating

- LIES, Iter, Keepers and Monkeepers update through SuperBLT's normal update
  prompt. (LIES builds older than 8.57.33 still show the old in-game prompt.)
- GoonMod's Custom Waypoints and No Duplicated Bullets keep the original author's
  updater chain; this bundle does not change or override it.
- Each mod is versioned separately, so updating one does not force a new bundle
  download. A new bundle is published when the whole stack moves.

### If something breaks

1. Check the newest file in `PAYDAY 2\mods\logs\` — a Lua error names the file
   and therefore the mod that failed.
2. Report the bug on that mod's repository (linked under each mod above).
3. Installation or packaging problems (missing folder, wrong structure) belong
   in the bundle repository:
   https://github.com/met94/payday2-ai-suite

### Credits

- **LIES** — original mod and AI design by fugsystem; 248.2 x64 fork maintenance
  by met94.
- **Iter**, **Keepers**, **Monkeepers** — original mods by TdlQ; Iter maintenance
  by BangL; translations by the authors listed in each `mod.txt`; 248.2 fork
  maintenance by met94.
- **GoonMod's Custom Waypoints** — Wilko (original), TdlQ (extensions); r50
  248.2 update by BangL, mirrored unmodified.
- **No Duplicated Bullets** — TdlQ; 248.2 maintenance by met94.
- **Useful Bots** — Hoppip (not part of this download).
- Decompiled game reference: steam-test1/Payday-2-LuaJIT-Complete.

The four AI mods ship their own `README.md`, `changelog.txt`, `MENU_OPTIONS.md`
and `LICENSE`. The two utilities ship their upstream `mod.txt` and
`changelog.txt`; they have no license file and are redistributed unchanged with
credit.

### License

The bundle repository is public domain (Unlicense). LIES is AGPL-3.0; Iter,
Keepers and Monkeepers are Unlicense; the two utilities carry no license file.
Bundling them does not relicense anything.

### Changelog

**2026.11.07** — LIES 8.57.33: update detection moves to SuperBLT, so LIES now
shows up in the normal update prompt with Iter, Keepers and Monkeepers. No
gameplay change.

**2026.11.06.2** — GoonMod's Custom Waypoints 50 and No Duplicated Bullets 10 are
now bundled, so Keepers' dependencies are satisfied by the download itself (no
SuperBLT dependency prompt). Both are the versions the suite is played with;
neither is modified.

**2026.11.06.1** — documentation re-cut: same mods and code as 2026.11.06; each
folder ships a rewritten, player-facing README. Nothing changes in-game.

**2026.11.06** — first bundle: LIES 8.57.32, Iter 205.3, Keepers 239.3,
Monkeepers 87.4.

## Notes for the upload

- Upload the zip from the GitHub release
  `https://github.com/met94/payday2-ai-suite/releases/tag/v2026.11.07`
  (`AI-Suite-2026.11.07.zip`, SHA-256 is printed in the release notes next to
  it).
- The archive root must contain the six folders, not a wrapper folder — it
  already does.
- ModWorkshop renders Markdown; the description above is plain Markdown.
